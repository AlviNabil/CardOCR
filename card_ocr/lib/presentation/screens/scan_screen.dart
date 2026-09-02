import 'dart:io';

import 'package:camera/camera.dart';
import 'package:card_ocr/core/injection.dart';
import 'package:card_ocr/presentation/cubits/camera/camera_cubit.dart';
import 'package:card_ocr/presentation/cubits/scan/scan_cubit.dart';
import 'package:card_ocr/presentation/screens/result_screen.dart';
import 'package:card_ocr/presentation/utils/card_image_cropper.dart';
import 'package:card_ocr/presentation/widgets/scanner_geometry.dart';
import 'package:card_ocr/presentation/widgets/scanner_overlay_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ScanCubit>()),
        BlocProvider(create: (_) => getIt<CameraCubit>()..initialize()),
      ],
      child: const _ScanView(),
    );
  }
}

class _ScanView extends StatelessWidget {
  const _ScanView();

  Future<void> _capture(BuildContext context, Size viewport) async {
    final cameraState = context.read<CameraCubit>().state;
    if (cameraState is! CameraReady) return;

    final cubit = context.read<ScanCubit>();
    cubit.startCapture();

    final xFile = await cameraState.controller.takePicture();
    final full = await File(xFile.path).readAsBytes();

    final cropped = await cropToCutout(bytes: full, viewport: viewport, cutout: ScannerGeometry.cutoutRect(viewport));

    await cubit.processImage(cropped);
  }

  /// Imports a card image from the photo library instead of the camera.
  /// Useful for a photo taken earlier, for re-running a card without
  /// re-photographing it, and on the iOS Simulator, which has no camera.
  ///
  /// Not cropped — an imported photo was framed by the user, not by our
  /// cutout, so there is no rectangle to map it against.
  ///
  /// The bytes take exactly the same path as a capture — straight to OCR in
  /// memory, never written to disk by us. Note the library itself is
  /// iCloud-backed and outside our encryption, so an imported photo is not
  /// protected the way a saved CardRecord is.
  Future<void> _pickFromLibrary(BuildContext context) async {
    final cubit = context.read<ScanCubit>();

    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    cubit.startCapture();
    await cubit.processImage(await file.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card'),
        actions: [
          IconButton(icon: const Icon(Icons.credit_card), onPressed: () => Navigator.pushNamed(context, '/history')),
        ],
      ),

      body: BlocListener<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state is ScanParsed) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(value: context.read<ScanCubit>(), child: const ResultScreen()),
              ),
            );
          } else if (state is ScanError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = Size(constraints.maxWidth, constraints.maxHeight);

            return BlocBuilder<ScanCubit, ScanState>(
              builder: (context, scanState) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _Viewport(scanState: scanState, viewport: viewport),
                    _ScannerOverlay(viewport: viewport),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GalleryButton(scanState: scanState, onPressed: () => _pickFromLibrary(context)),
                            const SizedBox(width: 32),
                            _ShutterButton(scanState: scanState, onPressed: () => _capture(context, viewport)),
                            // Balances the gallery button so the shutter stays
                            // centred in the viewport.
                            const SizedBox(width: 32),
                            const SizedBox(width: _galleryButtonSize),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Viewport extends StatelessWidget {
  final ScanState scanState;
  final Size viewport;

  const _Viewport({required this.scanState, required this.viewport});

  @override
  Widget build(BuildContext context) {
    final state = scanState;

    // The frozen frame is already cropped to the cutout, so it is drawn inside
    // the cutout rather than filling the screen — otherwise the still would
    // spill past the border the live preview was framed by.
    if (state is ScanUploading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          Positioned.fromRect(
            rect: ScannerGeometry.cutoutRect(viewport),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ScannerGeometry.cornerRadius),
              child: Image.memory(state.imageBytes, fit: BoxFit.cover, gaplessPlayback: true),
            ),
          ),
        ],
      );
    }

    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, cameraState) => switch (cameraState) {
        CameraInitializing() => const ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator()),
        ),
        CameraFailure(errorMessage: final message) => ColoredBox(
          color: Colors.black,
          child: Center(child: Text('Camera Error: $message')),
        ),
        CameraReady(:final controller) => CameraPreview(controller),
      },
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  final Size viewport;

  const _ScannerOverlay({required this.viewport});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: viewport, painter: ScannerOverlayPainter(ScannerGeometry.cutoutRRect(viewport))),
    );
  }
}

/// Matches FloatingActionButton.small, used to balance the shutter's centring.
const double _galleryButtonSize = 40;

bool _isBusy(ScanState state) => state is ScanCapturing || state is ScanUploading;

class _ShutterButton extends StatelessWidget {
  final ScanState scanState;
  final VoidCallback onPressed;

  const _ShutterButton({required this.scanState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final busy = _isBusy(scanState);

    return FloatingActionButton.large(
      // Two FABs share this route, so each needs its own tag — the shared
      // default would collide and throw at build time.
      heroTag: 'scanShutter',
      onPressed: busy ? null : onPressed,
      child: busy ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.camera_alt),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  final ScanState scanState;
  final VoidCallback onPressed;

  const _GalleryButton({required this.scanState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'scanGallery',
      tooltip: 'Import card from library',
      onPressed: _isBusy(scanState) ? null : onPressed,
      child: const Icon(Icons.photo_library_outlined),
    );
  }
}
