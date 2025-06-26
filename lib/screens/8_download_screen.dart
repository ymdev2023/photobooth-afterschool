import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DownloadScreen extends StatelessWidget {
  final String? downloadUrl;
  final String? videoUrl;
  final VoidCallback onRestart;
  final VoidCallback? onVideoDownload;
  final String currentStep;

  const DownloadScreen({
    Key? key,
    required this.downloadUrl,
    this.videoUrl,
    required this.onRestart,
    this.onVideoDownload,
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
                  // 제목만 표시, step indicator 제거
                  Text(
                    '다운로드',
                    style: TextStyle(
                      fontSize: isWideScreen ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
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
                                : QrImageView(
                                    data:
                                        'https://photobooth-afterschool.pages.dev/download',
                                    version: QrVersions.auto,
                                    size: qrSize,
                                    gapless: false,
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
                          // 버튼들
                          Wrap(
                            spacing: 15,
                            runSpacing: 15,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: onRestart,
                                icon: Icon(Icons.home),
                                label: Text('처음으로'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWideScreen ? 25 : 20,
                                    vertical: isWideScreen ? 15 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: 사진 다운로드 기능 구현
                                },
                                icon: Icon(Icons.photo),
                                label: Text('사진 다운로드'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWideScreen ? 25 : 20,
                                    vertical: isWideScreen ? 15 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed:
                                    videoUrl != null && onVideoDownload != null
                                        ? onVideoDownload
                                        : null,
                                icon: Icon(Icons.videocam),
                                label: Text('영상 다운로드'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: videoUrl != null
                                      ? Colors.green
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWideScreen ? 25 : 20,
                                    vertical: isWideScreen ? 15 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: videoUrl != null ? 5 : 0,
                                ),
                              ),
                            ],
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
