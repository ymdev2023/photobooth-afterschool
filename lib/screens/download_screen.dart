import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/common_widgets.dart';

class DownloadScreen extends StatelessWidget {
  final String? downloadUrl;
  final VoidCallback onRestart;
  final String currentStep;

  const DownloadScreen({
    Key? key,
    required this.downloadUrl,
    required this.onRestart,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            final titleSize = isWideScreen ? 56.0 : 48.0;
            final subtitleSize = isWideScreen ? 22.0 : 18.0;
            final qrSize = isWideScreen ? 250.0 : 200.0;

            return Padding(
              padding: EdgeInsets.all(isWideScreen ? 30 : 20),
              child: Column(
                children: [
                  CommonWidgets.buildStepHeader('다운로드', currentStep),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎉 완성!',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'QR코드를 스캔하여 사진을 다운로드하세요',
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 40),
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: downloadUrl != null
                                ? QrImageView(
                                    data: downloadUrl!,
                                    version: QrVersions.auto,
                                    size: qrSize,
                                    gapless: false,
                                  )
                                : Container(
                                    width: qrSize,
                                    height: qrSize,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'QR 코드 생성 중...',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            '스마트폰으로 QR코드를 스캔하면\n고화질 사진을 다운로드할 수 있어요!',
                            style: TextStyle(
                              fontSize: isWideScreen ? 16 : 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 50),
                          ElevatedButton(
                            onPressed: onRestart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isWideScreen ? 50 : 40,
                                vertical: isWideScreen ? 20 : 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              '다시 찍기',
                              style: TextStyle(
                                fontSize: isWideScreen ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
