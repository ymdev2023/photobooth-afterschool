import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../widgets/common_widgets.dart';

class ReviewScreen extends StatelessWidget {
  final Uint8List? filteredImage;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ReviewScreen({
    Key? key,
    required this.filteredImage,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            final titleSize = isWideScreen ? 28.0 : 24.0;
            final imageWidth = isWideScreen 
                ? constraints.maxWidth * 0.4 
                : constraints.maxWidth * 0.8;
            final imageHeight = imageWidth * 1.33; // 4:3 비율
            
            return Padding(
              padding: EdgeInsets.all(isWideScreen ? 30 : 20),
              child: Column(
                children: [
                  CommonWidgets.buildStepHeader('최종 확인', '5 / 7'),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '완성된 사진입니다!',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: imageWidth,
                            height: imageHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: filteredImage != null
                                  ? Image.memory(
                                      filteredImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: Colors.grey.shade600,
                                              size: 80,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              '완성된 사진',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: onBack,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.grey.shade700,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWideScreen ? 40 : 30, 
                                    vertical: isWideScreen ? 18 : 15
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  '수정하기',
                                  style: TextStyle(
                                    fontSize: isWideScreen ? 18 : 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWideScreen ? 40 : 30, 
                                    vertical: isWideScreen ? 18 : 15
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  '확정하기',
                                  style: TextStyle(
                                    fontSize: isWideScreen ? 18 : 16,
                                  ),
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
