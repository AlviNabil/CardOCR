import 'dart:io';

import 'package:camera/camera.dart';
import 'package:card_ocr/core/injection.dart';
import 'package:card_ocr/presentation/cubits/camera/camera_cubit.dart';
import 'package:card_ocr/presentation/cubits/scan_cubit.dart';
import 'package:card_ocr/presentation/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Future<void> _capture(BuildContext context, CameraController controller) async {
    final cubit = context.read<ScanCubit>();
    cubit.startCapture();

    final xFile = await controller.takePicture();
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
        child: BlocBuilder<CameraCubit, CameraState>(
          builder: (context, cameraState) {
            return switch (cameraState) {
              CameraInitializing() => const Center(child: CircularProgressIndicator()),
              CameraFailure(errorMessage: final message) => Center(child: Text('Camera Error: $message')),
              CameraReady(:final controller) => Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller),
                  const _FrameGuide(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: BlocBuilder<ScanCubit, ScanState>(
                        builder: (context, state) {
                          final busy = state is ScanCapturing || state is ScanUploading;
                          return FloatingActionButton.large(
                            onPressed: busy ? null : () => _capture(context, controller),
                            child: busy
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Icon(Icons.camera_alt),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            };
          },
        ),
      ),
    );
  }
}

class _FrameGuide extends StatelessWidget {
  const _FrameGuide();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.8;
        final height = width * 0.63;
        return Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
