import 'dart:io';

import 'package:camera/camera.dart';
import 'package:card_ocr/core/injection.dart';
import 'package:card_ocr/presentation/cubits/camera/camera_cubit.dart';
import 'package:card_ocr/presentation/cubits/scan/scan_cubit.dart';
import 'package:card_ocr/presentation/screens/result_screen.dart';
import 'package:card_ocr/presentation/widgets/scanner_overlay_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> _capture(BuildContext context) async {
    final cameraState = context.read<CameraCubit>().state;
    if (cameraState is! CameraReady) return;

    final cubit = context.read<ScanCubit>();
    cubit.startCapture();

    final xFile = await cameraState.controller.takePicture();
    final bytes = await File(xFile.path).readAsBytes();
    await cubit.processImage(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Card')),
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
        child: BlocBuilder<ScanCubit, ScanState>(
          builder: (context, scanState) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _Viewport(scanState: scanState),
                const _ScannerOverlay(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: _ShutterButton(scanState: scanState, onPressed: () => _capture(context)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Viewport extends StatelessWidget {
  final ScanState scanState;

  const _Viewport({required this.scanState});

  @override
  Widget build(BuildContext context) {
    if (scanState is ScanUploading) {
      return Image.memory((scanState as ScanUploading).imageBytes, fit: BoxFit.cover, gaplessPlayback: true);
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
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.85;
        final height = width / 1.586; // ID-1 card ratio
        final left = (constraints.maxWidth - width) / 2;
        final top = (constraints.maxHeight - height) / 2;

        final cutout = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, width, height), const Radius.circular(12));

        return IgnorePointer(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: ScannerOverlayPainter(cutout),
          ),
        );
      },
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final ScanState scanState;
  final VoidCallback onPressed;

  const _ShutterButton({required this.scanState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final busy = scanState is ScanCapturing || scanState is ScanUploading;

    return FloatingActionButton.large(
      onPressed: busy ? null : onPressed,
      child: busy ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.camera_alt),
    );
  }
}
