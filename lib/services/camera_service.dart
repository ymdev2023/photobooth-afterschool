import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'dart:convert';

class CameraService {
  // 웹 카메라 관련 변수들
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  bool _isWebCameraInitialized = false;
  html.CanvasElement? _canvasElement;
  html.CanvasRenderingContext2D? _canvasContext;
  String _videoElementId =
      'video-element-${DateTime.now().millisecondsSinceEpoch}';

  // 연속 촬영 관련 변수들
  List<XFile> _capturedPhotos = [];
  bool _isCapturing = false;
  int _captureCount = 0;
  int _captureCountdown = 0;
  Timer? _captureTimer;
  Timer? _countdownTimer;

  // Getters
  bool get isWebCameraInitialized => _isWebCameraInitialized;
  bool get isCapturing => _isCapturing;
  int get captureCount => _captureCount;
  int get captureCountdown => _captureCountdown;
  List<XFile> get capturedPhotos => _capturedPhotos;

  Future<void> setupWebCamera() async {
    try {
      _videoElement = html.VideoElement()
        ..width = 640
        ..height = 480
        ..autoplay = true
        ..id = _videoElementId;

      // 비디오 요소를 DOM에 추가
      html.document.body?.append(_videoElement!);

      // Canvas 요소 생성
      _canvasElement = html.CanvasElement(width: 640, height: 480);
      _canvasContext =
          _canvasElement!.getContext('2d') as html.CanvasRenderingContext2D;

      // 카메라 스트림 요청
      _mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {'width': 640, 'height': 480},
        'audio': false,
      });

      if (_mediaStream != null) {
        _videoElement!.srcObject = _mediaStream;
        _isWebCameraInitialized = true;
        print('웹 카메라 초기화 성공');
      }
    } catch (e) {
      print('웹 카메라 초기화 실패: $e');
    }
  }

  void disposeWebCamera() {
    try {
      _mediaStream?.getTracks().forEach((track) => track.stop());
      _videoElement?.remove();
      _captureTimer?.cancel();
      _countdownTimer?.cancel();
    } catch (e) {
      print('카메라 해제 중 오류: $e');
    }
  }

  Future<void> startContinuousCapture({
    required Function(int) onCountdownUpdate,
    required VoidCallback onCaptureComplete,
  }) async {
    if (_isCapturing) return;

    _isCapturing = true;
    _captureCount = 0;
    _capturedPhotos.clear();
    _captureCountdown = 5;

    print('연속 촬영 시작 - 총 8장 촬영');

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_captureCountdown > 0) {
        onCountdownUpdate(_captureCountdown);
        _captureCountdown--;
      } else {
        timer.cancel();
        _startCapturingPhotos(onCaptureComplete);
      }
    });
  }

  void _startCapturingPhotos(VoidCallback onCaptureComplete) {
    _captureTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_captureCount < 8) {
        await _capturePhoto();
        _captureCount++;
        print('촬영 완료: ${_captureCount}/8');
      } else {
        timer.cancel();
        _isCapturing = false;
        print('8장 촬영 완료!');
        onCaptureComplete();
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (kIsWeb && _canvasContext != null && _videoElement != null) {
      try {
        // 비디오를 캔버스에 그리기
        _canvasContext!.drawImage(_videoElement!, 0, 0);

        // 캔버스를 이미지로 변환
        String dataUrl = _canvasElement!.toDataUrl('image/jpeg', 0.9);

        // Base64 데이터를 Uint8List로 변환
        String base64String = dataUrl.split(',')[1];
        Uint8List bytes = base64Decode(base64String);

        // XFile 생성
        XFile photo = XFile.fromData(
          bytes,
          name: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          mimeType: 'image/jpeg',
        );

        _capturedPhotos.add(photo);
      } catch (e) {
        print('사진 촬영 실패: $e');
      }
    }
  }

  void stopCapture() {
    _captureTimer?.cancel();
    _countdownTimer?.cancel();
    _isCapturing = false;
  }
}
