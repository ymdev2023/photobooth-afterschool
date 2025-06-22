import 'package:flutter/material.dart';
import '../models/photo_booth_step.dart';

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

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '📸 포토부스',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '인생네컷을 찍어보세요!',
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
              );
            },
          ),
        ),
      ),
    );
  }
}
