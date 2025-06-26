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
  int _intervalCountdown = 0; // 촬영 간격 카운트다운 (10초)
  Timer? _captureTimer;
  Timer? _countdownTimer;
  Timer? _intervalTimer; // 촬영 간격 타이머

  // 영상 녹화 관련 변수들
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _recordedChunks = [];
  bool _isRecording = false;
  String? _recordedVideoUrl;

  // Getters
  bool get isWebCameraInitialized => _isWebCameraInitialized;
  bool get isCapturing => _isCapturing;
  int get captureCount => _captureCount;
  int get captureCountdown => _captureCountdown;
  int get intervalCountdown => _intervalCountdown; // 촬영 간격 카운트다운 getter
  html.MediaStream? get mediaStream => _mediaStream;
  bool get isRecording => _isRecording;
  String? get recordedVideoUrl => _recordedVideoUrl;

  List<XFile> getCapturedPhotos() {
    return List.from(_capturedPhotos);
  }

  List<XFile> get capturedPhotos => _capturedPhotos;
  String get videoElementId => _videoElementId;

  Future<void> setupWebCamera() async {
    try {
      // iOS Safari 호환성을 위한 설정
      _videoElement = html.VideoElement()
        ..width = 640
        ..height = 480
        ..autoplay = true
        ..setAttribute('playsinline', 'true') // iOS Safari에서 필수
        ..setAttribute('webkit-playsinline', 'true') // 구형 iOS 지원
        ..id = _videoElementId;

      // 비디오 요소를 DOM에 추가
      html.document.body?.append(_videoElement!);

      // Canvas 요소 생성
      _canvasElement = html.CanvasElement(width: 640, height: 480);
      _canvasContext =
          _canvasElement!.getContext('2d') as html.CanvasRenderingContext2D;

      // iOS Safari 호환 카메라 스트림 요청
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        throw Exception('MediaDevices API를 지원하지 않는 브라우저입니다.');
      }

      // iOS Safari를 위한 더 구체적인 constraints
      final constraints = {
        'video': {
          'width': {'ideal': 640, 'max': 1280},
          'height': {'ideal': 480, 'max': 720},
          'facingMode': 'user', // 전면 카메라 우선
          'frameRate': {'ideal': 30, 'max': 30}
        },
        'audio': false,
      };

      _mediaStream = await mediaDevices.getUserMedia(constraints);

      if (_mediaStream != null) {
        _videoElement!.srcObject = _mediaStream;

        // iOS Safari에서 비디오 로딩을 기다림
        await _videoElement!.onLoadedMetadata.first;
        await _videoElement!.play();

        _isWebCameraInitialized = true;
        print('웹 카메라 초기화 성공 (iOS 호환)');
      } else {
        throw Exception('카메라 스트림을 가져올 수 없습니다.');
      }
    } catch (e) {
      print('웹 카메라 초기화 실패: $e');
      // iOS에서 권한 거부 또는 카메라 없음 처리
      if (e.toString().contains('NotAllowedError')) {
        print('카메라 권한이 거부되었습니다. 브라우저 설정에서 카메라 권한을 허용해주세요.');
      } else if (e.toString().contains('NotFoundError')) {
        print('카메라를 찾을 수 없습니다.');
      } else if (e.toString().contains('NotSupportedError')) {
        print('이 브라우저에서는 카메라를 지원하지 않습니다.');
      }
      _isWebCameraInitialized = false;
    }
  }

  void disposeWebCamera() {
    try {
      _mediaStream?.getTracks().forEach((track) => track.stop());
      _videoElement?.remove();
      _captureTimer?.cancel();
      _countdownTimer?.cancel();
      _intervalTimer?.cancel();
    } catch (e) {
      print('카메라 해제 중 오류: $e');
    }
  }

  Future<void> startContinuousCapture({
    required Function(int) onCountdownUpdate,
    required VoidCallback onCaptureComplete,
    VoidCallback? onPhotoTaken,
    Function(int)? onIntervalUpdate, // 촬영 간격 업데이트 콜백 추가
    Function(XFile)? onPhotoPreview, // 촬영 결과 미리보기 콜백 추가
  }) async {
    if (_isCapturing) return;

    _isCapturing = true;
    _captureCount = 0;
    _capturedPhotos.clear();
    _captureCountdown = 5;
    _intervalCountdown = 0;

    // 영상 녹화 시작
    startVideoRecording();

    print('연속 촬영 및 영상 녹화 시작 - 총 8장 촬영');

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_captureCountdown > 0) {
        onCountdownUpdate(_captureCountdown);
        _captureCountdown--;
      } else {
        timer.cancel();
        onCountdownUpdate(0); // 카운트다운 완료 알림
        _startCapturingPhotos(
            onCaptureComplete, onPhotoTaken, onIntervalUpdate, onPhotoPreview);
      }
    });
  }

  void _startCapturingPhotos(
      VoidCallback onCaptureComplete,
      VoidCallback? onPhotoTaken,
      Function(int)? onIntervalUpdate,
      Function(XFile)? onPhotoPreview) async {
    // 첫 번째 사진을 바로 촬영
    XFile? capturedPhoto = await _capturePhoto();
    _captureCount++;

    if (capturedPhoto != null) {
      onPhotoPreview?.call(capturedPhoto); // 촬영 결과 미리보기

      // 1초 후에 다음 단계로
      await Future.delayed(Duration(seconds: 1));
    }

    onPhotoTaken?.call(); // 촬영 완료 알림
    print('촬영 완료: ${_captureCount}/8');

    // 나머지 사진들을 10초 간격으로 촬영
    if (_captureCount < 8) {
      _intervalCountdown = 10; // 10초 간격 설정

      // 1초마다 간격 카운트다운 업데이트
      _intervalTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_intervalCountdown > 0) {
          onIntervalUpdate?.call(_intervalCountdown);
          _intervalCountdown--;
        } else {
          timer.cancel();
        }
      });
    }

    _captureTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_captureCount < 8) {
        XFile? capturedPhoto = await _capturePhoto();
        _captureCount++;

        if (capturedPhoto != null) {
          onPhotoPreview?.call(capturedPhoto); // 촬영 결과 미리보기

          // 1초 후에 다음 단계로
          await Future.delayed(Duration(seconds: 1));
        }

        onPhotoTaken?.call(); // 촬영 완료 알림
        print('촬영 완료: ${_captureCount}/8');

        // 다음 촬영을 위한 간격 타이머 재시작
        if (_captureCount < 8) {
          _intervalCountdown = 10;
          _intervalTimer?.cancel();
          _intervalTimer =
              Timer.periodic(Duration(seconds: 1), (intervalTimer) {
            if (_intervalCountdown > 0) {
              onIntervalUpdate?.call(_intervalCountdown);
              _intervalCountdown--;
            } else {
              intervalTimer.cancel();
            }
          });
        }
      } else {
        timer.cancel();
        _intervalTimer?.cancel();
        _isCapturing = false;

        // 영상 녹화 중지
        stopVideoRecording();

        print('8장 촬영 및 영상 녹화 완료! 저장된 사진들:');
        for (int i = 0; i < _capturedPhotos.length; i++) {
          print('  ${i + 1}. ${_capturedPhotos[i].name}');
        }
        print('사진 선택 화면으로 이동합니다...');
        onCaptureComplete();
      }
    });
  }

  Future<XFile?> _capturePhoto() async {
    if (kIsWeb && _canvasContext != null && _videoElement != null) {
      try {
        print('사진 촬영 시작...');

        // 비디오를 캔버스에 그리기
        _canvasContext!.drawImage(_videoElement!, 0, 0);

        // 캔버스를 이미지로 변환
        String dataUrl = _canvasElement!.toDataUrl('image/jpeg', 0.9);

        // Base64 데이터를 Uint8List로 변환
        String base64String = dataUrl.split(',')[1];
        Uint8List bytes = base64Decode(base64String);

        // XFile 생성
        String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        XFile photo = XFile.fromData(
          bytes,
          name: fileName,
          mimeType: 'image/jpeg',
        );

        _capturedPhotos.add(photo);
        print('사진 촬영 완료: $fileName (크기: ${bytes.length} bytes)');
        print('현재 저장된 사진 수: ${_capturedPhotos.length}');

        return photo; // 촬영된 사진 반환
      } catch (e) {
        print('사진 촬영 실패: $e');
        return null;
      }
    } else {
      print('사진 촬영 실패: 카메라 또는 캔버스가 초기화되지 않음');
      return null;
    }
  }

  // 영상 녹화 시작
  void startVideoRecording() {
    if (_mediaStream == null || _isRecording) {
      print('영상 녹화 시작 실패: 스트림이 없거나 이미 녹화 중');
      return;
    }

    try {
      // 지원되는 MIME 타입 확인
      List<String> mimeTypes = [
        'video/webm;codecs=vp9',
        'video/webm;codecs=vp8',
        'video/webm',
        'video/mp4'
      ];

      String? supportedMimeType;
      for (String mimeType in mimeTypes) {
        if (html.MediaRecorder.isTypeSupported(mimeType)) {
          supportedMimeType = mimeType;
          break;
        }
      }

      if (supportedMimeType == null) {
        print('지원되는 비디오 형식이 없습니다.');
        return;
      }

      // MediaRecorder 생성
      _mediaRecorder = html.MediaRecorder(_mediaStream!, {
        'mimeType': supportedMimeType,
        'videoBitsPerSecond': 2500000, // 2.5 Mbps
      });

      _recordedChunks.clear();

      // 데이터 이벤트 리스너
      _mediaRecorder!.addEventListener('dataavailable', (html.Event event) {
        final blobEvent = event as html.BlobEvent;
        if (blobEvent.data!.size > 0) {
          _recordedChunks.add(blobEvent.data!);
        }
      });

      // 녹화 중지 이벤트 리스너
      _mediaRecorder!.addEventListener('stop', (html.Event event) {
        _createVideoUrl();
      });

      // 녹화 시작
      _mediaRecorder!.start(1000); // 1초마다 데이터 이벤트 발생
      _isRecording = true;
      print('영상 녹화 시작됨 (${supportedMimeType})');
    } catch (e) {
      print('영상 녹화 시작 실패: $e');
    }
  }

  // 영상 녹화 중지
  void stopVideoRecording() {
    if (_mediaRecorder == null || !_isRecording) {
      print('영상 녹화 중지 실패: 녹화 중이 아님');
      return;
    }

    try {
      _mediaRecorder!.stop();
      _isRecording = false;
      print('영상 녹화 중지됨');
    } catch (e) {
      print('영상 녹화 중지 실패: $e');
    }
  }

  // 녹화된 영상 URL 생성
  void _createVideoUrl() {
    if (_recordedChunks.isEmpty) {
      print('녹화된 데이터가 없습니다.');
      return;
    }

    try {
      final blob = html.Blob(_recordedChunks, 'video/webm');
      _recordedVideoUrl = html.Url.createObjectUrl(blob);
      print('영상 URL 생성됨: $_recordedVideoUrl');
      print('영상 크기: ${blob.size} bytes');
    } catch (e) {
      print('영상 URL 생성 실패: $e');
    }
  }

  // 영상 다운로드
  void downloadVideo() {
    if (_recordedVideoUrl == null) {
      print('다운로드할 영상이 없습니다.');
      return;
    }

    try {
      final anchor = html.document.createElement('a') as html.AnchorElement;
      anchor.href = _recordedVideoUrl!;
      anchor.download =
          'photobooth_video_${DateTime.now().millisecondsSinceEpoch}.webm';
      anchor.click();
      print('영상 다운로드 시작');
    } catch (e) {
      print('영상 다운로드 실패: $e');
    }
  }

  // 리소스 정리
  void dispose() {
    disposeWebCamera();

    // 영상 녹화 정리
    if (_isRecording) {
      stopVideoRecording();
    }

    if (_recordedVideoUrl != null) {
      html.Url.revokeObjectUrl(_recordedVideoUrl!);
      _recordedVideoUrl = null;
    }

    _recordedChunks.clear();
    _mediaRecorder = null;
  }
}
