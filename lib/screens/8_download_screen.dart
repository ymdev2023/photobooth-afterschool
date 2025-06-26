import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/frame_composition_service.dart';
import 'dart:typed_data';

class DownloadScreen extends StatelessWidget {
  final String? downloadUrl;
  final String? videoUrl;
  final Uint8List? finalImage; // 최종 프레임 이미지 추가
  final VoidCallback onRestart;
  final VoidCallback? onVideoDownload;
  final String currentStep;

  const DownloadScreen({
    Key? key,
    required this.downloadUrl,
    this.videoUrl,
    this.finalImage, // 최종 이미지 파라미터 추가
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
                          if (finalImage != null) ...[
                            SizedBox(height: 10),
                            Text(
                              '🎨 프레임이 적용된 사진이 준비되었습니다!',
                              style: TextStyle(
                                fontSize: isWideScreen ? 16 : 14,
                                color: Colors.pink,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                          // 최종 이미지 미리보기 추가
                          if (finalImage != null) ...[
                            Text(
                              '완성된 프레임 사진 미리보기',
                              style: TextStyle(
                                fontSize: isWideScreen ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: isWideScreen ? 200 : 150,
                              height: (isWideScreen ? 200 : 150) * 1.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.pink.shade300, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  finalImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
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
                                onPressed: finalImage != null
                                    ? _downloadFinalImage
                                    : null,
                                icon: Icon(Icons.download),
                                label: Text('프레임 사진 다운로드'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: finalImage != null
                                      ? Colors.blue
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWideScreen ? 25 : 20,
                                    vertical: isWideScreen ? 15 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: finalImage != null ? 5 : 0,
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

  /// 최종 프레임 이미지를 다운로드합니다.
  void _downloadFinalImage() {
    if (finalImage != null) {
      print('📥 다운로드 스크린에서 프레임 이미지 다운로드 시작');
      print('  이미지 크기: ${finalImage!.length} bytes (${(finalImage!.length / 1024).toStringAsFixed(1)}KB)');
      
      final filename = 'photobooth_frame_${DateTime.now().millisecondsSinceEpoch}.png';
      print('  파일명: $filename');
      
      try {
        FrameCompositionService.downloadImage(finalImage!, filename);
        print('✅ 프레임 이미지 다운로드 성공: $filename');
        
        // 성공 메시지 표시 (브라우저 알림)
        // 추후 Snackbar나 Toast로 대체 가능
      } catch (e) {
        print('❌ 프레임 이미지 다운로드 실패: $e');
      }
    } else {
      print('⚠️ 다운로드할 프레임 이미지가 없습니다');
    }
  }
}
