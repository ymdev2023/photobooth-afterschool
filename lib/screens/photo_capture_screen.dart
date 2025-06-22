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
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CommonWidgets.buildStepHeader('사진을 촬영해주세요', '2 / 7'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_countdown > 0) ...[
                    Text(
                      '$_countdown',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '준비하세요!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ] else if (widget.cameraService.isCapturing) ...[
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 80,
                          ),
                          SizedBox(height: 20),
                          Text(
                            '촬영 중... ${widget.cameraService.captureCount}/8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: widget.cameraService.captureCount / 8,
                            backgroundColor: Colors.grey.shade700,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.pink),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.pink.shade300, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(height: 20),
                          Text(
                            '8장의 사진을 촬영합니다',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '각 사진은 10초 간격으로 촬영됩니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _startCapture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        '촬영 시작',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!widget.cameraService.isCapturing)
            CommonWidgets.buildNavigationButtons(
              onBack: widget.onBack,
            ),
        ],
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
