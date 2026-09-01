part of 'camera_cubit.dart';

sealed class CameraState {
  const CameraState();
}

class CameraInitializing extends CameraState {
  const CameraInitializing();
}

class CameraReady extends CameraState {
  final CameraController controller;
  const CameraReady(this.controller);
}

class CameraFailure extends CameraState {
  final String errorMessage;

  const CameraFailure(this.errorMessage);
}
