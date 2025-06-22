import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../services/camera_service.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:async';

class PhotoCaptureScreen extends StatefulWidget {
  final CameraService cameraService;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String currentStep;

  const PhotoCaptureScreen({
    Key? key,
    required this.cameraService,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  }) : super(key: key);

  @override
  _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  int _countdown = 0;
  bool _isInitializing = false;
  String? _errorMessage;
  bool _isCaptureFlash = false; // 촬영 플래시 효과

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      await widget.cameraService.setupWebCamera();
      if (!widget.cameraService.isWebCameraInitialized) {
        setState(() {
          _errorMessage = '카메라를 초기화할 수 없습니다. 브라우저에서 카메라 권한을 허용해주세요.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '카메라 오류: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCameraStepHeader(),
            SizedBox(height: 40),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Stack(
                  children: [
                    // 카메라 프리뷰 영역
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: _buildCameraContent(),
                      ),
                    ),
                    // 카운트다운 오버레이 - 깜박임 없이 부드러운 전환
                    if (_countdown > 0)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              _countdown.toString(),
                              key: ValueKey<int>(_countdown),
                              style: TextStyle(
                                fontSize: 120,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // 촬영 플래시 효과
                    if (_isCaptureFlash)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    // 촬영 상태 표시 - 오버레이 최소화
                    if (widget.cameraService.isCapturing &&
                        _countdown == 0 &&
                        !_isCaptureFlash)
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                '촬영 중... (${widget.cameraService.captureCount}/8)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            // 컨트롤 버튼들
            if (!widget.cameraService.isCapturing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 촬영 시작 버튼
                  ElevatedButton(
                    onPressed: _startCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8),
                        Text(
                          '촬영 시작',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (!widget.cameraService.isCapturing) ...[
              SizedBox(height: 20),
              CommonWidgets.buildNavigationButtons(
                onBack: widget.onBack,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startCapture() {
    widget.cameraService.startContinuousCapture(
      onCountdownUpdate: (countdown) {
        // 카운트다운이 실제로 변경된 경우에만 setState 호출
        if (_countdown != countdown) {
          setState(() {
            _countdown = countdown;
          });
        }
      },
      onCaptureComplete: () {
        setState(() {
          _countdown = 0;
          _isCaptureFlash = false;
        });
        widget.onNext();
      },
      onPhotoTaken: () {
        // 촬영 시 플래시 효과
        setState(() {
          _isCaptureFlash = true;
        });

        // 1초 후 플래시 효과 제거
        Timer(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isCaptureFlash = false;
            });
          }
        });
      },
    );
  }

  Widget _buildCameraContent() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
            SizedBox(height: 20),
            Text(
              '카메라를 초기화하는 중...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (!widget.cameraService.isWebCameraInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 20),
            Text(
              '카메라 준비 중...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // 카메라가 초기화된 경우 실제 비디오 스트림 표시
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: _buildVideoView(),
      ),
    );
  }

  Widget _buildVideoView() {
    if (widget.cameraService.mediaStream == null) {
      return Container(
        color: Colors.grey.shade800,
        child: Center(
          child: Text(
            '카메라 스트림을 불러오는 중...',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // 웹에서는 HTML video 요소 사용
    final viewId = 'video-${DateTime.now().millisecondsSinceEpoch}';
    final videoElement = html.VideoElement()
      ..srcObject = widget.cameraService.mediaStream
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.transform = 'scaleX(-1)'; // 미러 효과

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => videoElement,
    );

    return HtmlElementView(viewType: viewId);
  }

  Widget _buildCameraStepHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '사진을 촬영해주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.currentStep,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
