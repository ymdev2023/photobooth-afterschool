import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;

  const WelcomeScreen({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade300,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;
              final titleSize = isWideScreen ? 56.0 : 48.0;
              final subtitleSize = isWideScreen ? 28.0 : 24.0;

              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '📸 PHOTO BOOTH',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '클래식 4컷 인생사진을 만들어보세요!',
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '6가지 아름다운 색상 프레임으로 완성하는 특별한 추억',
                          style: TextStyle(
                            fontSize: isWideScreen ? 18 : 16,
                            color: Colors.white60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 60),
                        ElevatedButton(
                          onPressed: onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.pink,
                            padding: EdgeInsets.symmetric(
                                horizontal: isWideScreen ? 50 : 40,
                                vertical: isWideScreen ? 25 : 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            '시작하기',
                            style: TextStyle(
                              fontSize: isWideScreen ? 22 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 개발자 정보 - 우측 상단
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'New Contents Academy',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isWideScreen ? 14 : 12,
                            ),
                          ),
                          Text(
                            '(Gong)dongchae',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isWideScreen ? 12 : 10,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Developed by Yoon Myung Kim',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: isWideScreen ? 11 : 9,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 버전 정보 - 하단
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(                          'v2.7.0 (2025.06.26)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isWideScreen ? 16 : 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '최신 업데이트:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: isWideScreen ? 14 : 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• 모든 프레임을 클래식 4컷 스타일로 통일\n• 6가지 아름다운 색상 프레임 제공 (화이트, 핑크, 블루, 그린, 퍼플, 오렌지)\n• 간편한 색상 선택으로 더욱 직관적인 사용자 경험\n• 1:10 세로 비율로 완벽한 포토부스 스타일 구현\n• 일관된 4장 사진 선택으로 단순화된 워크플로우',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: isWideScreen ? 13 : 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
