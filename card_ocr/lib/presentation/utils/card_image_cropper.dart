import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect, Size;

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

class _CropRequest {
  final Uint8List bytes;
  final double viewportWidth;
  final double viewportHeight;
  final double cutoutLeft;
  final double cutoutTop;
  final double cutoutWidth;
  final double cutoutHeight;

  const _CropRequest({
    required this.bytes,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.cutoutLeft,
    required this.cutoutTop,
    required this.cutoutWidth,
    required this.cutoutHeight,
  });
}

Future<Uint8List> cropToCutout({required Uint8List bytes, required Size viewport, required Rect cutout}) {
  return compute(
    _cropSync,
    _CropRequest(
      bytes: bytes,
      viewportWidth: viewport.width,
      viewportHeight: viewport.height,
      cutoutLeft: cutout.left,
      cutoutTop: cutout.top,
      cutoutWidth: cutout.width,
      cutoutHeight: cutout.height,
    ),
  );
}

Uint8List _cropSync(_CropRequest request) {
  final decoded = img.decodeImage(request.bytes);
  if (decoded == null) return request.bytes;

  final imageWidth = decoded.width.toDouble();
  final imageHeight = decoded.height.toDouble();

  final scale = math.max(request.viewportWidth / imageWidth, request.viewportHeight / imageHeight);
  final overflowX = (imageWidth * scale - request.viewportWidth) / 2;
  final overflowY = (imageHeight * scale - request.viewportHeight) / 2;

  var left = ((request.cutoutLeft + overflowX) / scale).round();
  var top = ((request.cutoutTop + overflowY) / scale).round();
  var width = (request.cutoutWidth / scale).round();
  var height = (request.cutoutHeight / scale).round();

  left = left.clamp(0, decoded.width - 1);
  top = top.clamp(0, decoded.height - 1);
  width = width.clamp(1, decoded.width - left);
  height = height.clamp(1, decoded.height - top);

  final cropped = img.copyCrop(decoded, x: left, y: top, width: width, height: height);
  return img.encodeJpg(cropped, quality: 92);
}
