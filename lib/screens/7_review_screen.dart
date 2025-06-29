import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/frame_composition_service.dart';

class ReviewScreen extends StatelessWidget {
  final Uint8List? filteredImage;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String currentStep;

  const ReviewScreen({
    Key? key,
    required this.filteredImage,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // 헤더
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Text(
                  '최종 완성된 사진을 확인해주세요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              // 완성된 사진 미리보기
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // 안내 텍스트
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.pink.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  '🎉 멋진 사진이 완성되었습니다!\n마음에 드시면 "확정하기"를 눌러 다운로드하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 네비게이션 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 8),
                        Text(
                          '수정하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 즉시 다운로드 버튼 추가
                  ElevatedButton(
                    onPressed: filteredImage != null ? _downloadImage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text(
                          '다운로드',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle),
                        SizedBox(width: 8),
                        Text(
                          '확정하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    print('🔍 리뷰 스크린 이미지 미리보기:');
    print('  filteredImage가 null인가? ${filteredImage == null}');
    if (filteredImage != null) {
      print('  filteredImage 크기: ${filteredImage!.length} bytes');
    }

    if (filteredImage != null) {
      return Container(
        child: Column(
          children: [
            // 이미지 정보 표시
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera, color: Colors.pink, size: 16),
                  SizedBox(width: 8),
                  Text(
                    '프레임이 적용된 최종 사진 (${(filteredImage!.length / 1024).toStringAsFixed(1)}KB)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // 실제 이미지
            Expanded(
              child: Image.memory(
                filteredImage!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.grey.shade800,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 80,
                color: Colors.white54,
              ),
              SizedBox(height: 20),
              Text(
                '완성된 사진을 불러오는 중...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '필터가 적용된 사진이 여기에 표시됩니다',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// 이미지를 다운로드합니다.
  void _downloadImage() {
    if (filteredImage != null) {
      final filename =
          'photobooth_review_${DateTime.now().millisecondsSinceEpoch}.png';
      FrameCompositionService.downloadImage(filteredImage!, filename);

      // 성공 메시지 표시 (선택사항)
      print('✅ 리뷰 이미지 다운로드 시작: $filename');
    }
  }
}
