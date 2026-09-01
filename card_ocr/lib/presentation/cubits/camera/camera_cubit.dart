import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'camera_state.dart';

@injectable
class CameraCubit extends Cubit<CameraState> {
  CameraController? _controller;

  CameraCubit() : super(const CameraInitializing());

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(backCamera, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      _controller = controller;
      emit(CameraReady(_controller!));
    } catch (e) {
      emit(CameraFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
