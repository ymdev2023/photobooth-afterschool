import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../services/camera_service.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final CameraService cameraService;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PhotoCaptureScreen({
    Key? key,
    required this.cameraService,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  int _countdown = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CommonWidgets.buildStepHeader('사진을 촬영해주세요', '2 / 7'),
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
                        child: true // widget.cameraService.isInitialized
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  color: Colors.grey.shade700,
                                  child: Center(
                                    child: Text(
                                      '카메라 프리뷰',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ), // widget.cameraService.buildCameraPreview(),
                              )
                            : Center(
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
                                      '카메라를 초기화하는 중...',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                          child: Text(
                            _countdown.toString(),
                            style: TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    // 촬영 상태 표시
                    if (widget.cameraService.isCapturing && _countdown == 0)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.pink),
                              ),
                              SizedBox(height: 20),
                              Text(
                                '사진을 촬영하는 중...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
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
        setState(() {
          _countdown = countdown;
        });
      },
      onCaptureComplete: () {
        setState(() {
          _countdown = 0;
        });
        widget.onNext();
      },
    );
  }
}
