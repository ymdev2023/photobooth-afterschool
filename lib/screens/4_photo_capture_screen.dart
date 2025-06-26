import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common_widgets.dart';
import '../services/camera_service.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:async';
import 'dart:typed_data';

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
  int _intervalCountdown = 0; // 촬영 간격 카운트다운
  bool _isCaptureFlash = false; // 촬영 플래시 효과
  XFile? _previewPhoto; // 촬영 결과 미리보기용
  bool _showPreview = false; // 미리보기 표시 여부
  bool _isProcessing = false; // 촬영 완료 후 처리 중

  @override
  void initState() {
    super.initState();
    // 카메라는 이미 테스트 단계에서 초기화되었음
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCaptureStepHeader(),
            SizedBox(height: 20),
            // 사진 촬영 안내 텍스트
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.pink.withOpacity(0.3), width: 1),
              ),
              child: Text(
                '📸 이제 본격적으로 사진을 촬영합니다!\n포즈를 취하고 준비되면 촬영 시작 버튼을 눌러주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20),
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
                    // 카운트다운 오버레이
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
                    // 촬영 결과 미리보기 오버레이
                    if (_showPreview && _previewPhoto != null)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: FutureBuilder<Uint8List>(
                            future: _previewPhoto!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(-1.0, 1.0), // 좌우반전
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                );
                              } else {
                                return Container(
                                  color: Colors.black.withOpacity(0.7),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.pink),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    // 촬영 완료 후 로딩 화면
                    if (_isProcessing)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.pink),
                                ),
                              ),
                              SizedBox(height: 30),
                              Text(
                                '멋진 사진들이 완성되었습니다!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '사진을 처리하고 있습니다...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
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
        if (_countdown != countdown) {
          setState(() {
            _countdown = countdown;
          });
        }
      },
      onIntervalUpdate: (intervalCountdown) {
        if (_intervalCountdown != intervalCountdown) {
          setState(() {
            _intervalCountdown = intervalCountdown;
          });
        }
      },
      onCaptureComplete: () {
        setState(() {
          _countdown = 0;
          _intervalCountdown = 0;
          _isCaptureFlash = false;
          _showPreview = false;
          _previewPhoto = null;
          _isProcessing = true;
        });

        // 3초 후 다음 화면으로 이동
        Timer(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            widget.onNext();
          }
        });
      },
      onPhotoTaken: () {
        setState(() {
          _isCaptureFlash = true;
        });

        Timer(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isCaptureFlash = false;
            });
          }
        });
      },
      onPhotoPreview: (photo) {
        setState(() {
          _previewPhoto = photo;
          _showPreview = true;
        });

        Timer(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showPreview = false;
            });
          }
        });
      },
    );
  }

  Widget _buildCameraContent() {
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
              '카메라 연결을 확인하는 중...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

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

    final viewId = 'video-capture-${DateTime.now().millisecondsSinceEpoch}';
    final videoElement = html.VideoElement()
      ..srcObject = widget.cameraService.mediaStream
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover' // 촬영용은 cover로 사용
      ..style.transform = 'scaleX(-1)'; // 미러 효과

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => videoElement,
    );

    return HtmlElementView(viewType: viewId);
  }

  Widget _buildCaptureStepHeader() {
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
          // 촬영 진행 상태 표시
          Container(
            width: 60,
            height: 60,
            child: widget.cameraService.isCapturing && _intervalCountdown > 0
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 45,
                          height: 45,
                          child: CircularProgressIndicator(
                            value: (_intervalCountdown) / 10.0,
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            backgroundColor: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        Text(
                          _intervalCountdown.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
