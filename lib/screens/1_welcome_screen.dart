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
                          '기억에 남는 사진을 찍어보세요!',
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.white70,
                          ),
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
                          Text(
                            'v2.4.0 (2025.06.26)',
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
                            '• 화면 깜박임 문제 근본적 해결\n• ValueNotifier와 ValueListenableBuilder로 성능 최적화\n• 촬영 타이머 및 플래시 효과 부드럽게 개선\n• setState() 제거로 불필요한 리빌드 방지\n• 자연스러운 촬영 진행 상태 표시',
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
