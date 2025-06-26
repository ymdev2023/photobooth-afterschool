import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class FrameSelectionScreen extends StatelessWidget {
  final String? selectedFrame;
  final Function(String) onFrameSelected;
  final VoidCallback? onNext;
  final VoidCallback onBack;
  final String currentStep;

  const FrameSelectionScreen({
    Key? key,
    required this.selectedFrame,
    required this.onFrameSelected,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 4컷 프레임의 다양한 색상 옵션
    final List<Map<String, dynamic>> frameColors = [
      {
        'name': '클래식 화이트',
        'description': '깔끔하고 심플한 화이트 프레임',
        'path': 'classic_4cut_white',
        'backgroundColor': Colors.white,
        'borderColor': Colors.grey.shade400,
        'accentColor': Colors.grey.shade600,
      },
      {
        'name': '로즈 핑크',
        'description': '사랑스러운 핑크 컬러 프레임',
        'path': 'classic_4cut_pink',
        'backgroundColor': Colors.pink.shade50,
        'borderColor': Colors.pink.shade300,
        'accentColor': Colors.pink,
      },
      {
        'name': '스카이 블루',
        'description': '상큼한 블루 컬러 프레임',
        'path': 'classic_4cut_blue',
        'backgroundColor': Colors.blue.shade50,
        'borderColor': Colors.blue.shade300,
        'accentColor': Colors.blue,
      },
      {
        'name': '민트 그린',
        'description': '싱그러운 그린 컬러 프레임',
        'path': 'classic_4cut_green',
        'backgroundColor': Colors.green.shade50,
        'borderColor': Colors.green.shade300,
        'accentColor': Colors.green,
      },
      {
        'name': '라벤더 퍼플',
        'description': '우아한 퍼플 컬러 프레임',
        'path': 'classic_4cut_purple',
        'backgroundColor': Colors.purple.shade50,
        'borderColor': Colors.purple.shade300,
        'accentColor': Colors.purple,
      },
      {
        'name': '선셋 오렌지',
        'description': '따뜻한 오렌지 컬러 프레임',
        'path': 'classic_4cut_orange',
        'backgroundColor': Colors.orange.shade50,
        'borderColor': Colors.orange.shade300,
        'accentColor': Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // 제목
              Text(
                '프레임 색상을 선택해주세요',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                '모든 프레임은 클래식 4컷 스타일입니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 화면 크기에 따라 그리드 설정 조정
                    final isWideScreen = constraints.maxWidth > 600;
                    final crossAxisCount = isWideScreen ? 3 : 2;
                    final childAspectRatio = isWideScreen ? 1.2 : 1.0;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                      ),
                      itemCount: frameColors.length,
                      itemBuilder: (context, index) {
                        final frameColor = frameColors[index];
                        final isSelected = selectedFrame == frameColor['path'];

                        return GestureDetector(
                          onTap: () {
                            onFrameSelected(frameColor['path']);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? frameColor['accentColor'].withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? frameColor['accentColor']
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  // 프레임 미리보기
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: frameColor['backgroundColor'],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: frameColor['borderColor'],
                                          width: 2,
                                        ),
                                      ),
                                      child: _buildFramePreview(frameColor),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // 색상 이름
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          frameColor['name'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (isSelected) ...[
                                          SizedBox(height: 5),
                                          Icon(
                                            Icons.check_circle,
                                            color: frameColor['accentColor'],
                                            size: 20,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              CommonWidgets.buildNavigationButtons(
                onNext: onNext,
                onBack: onBack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFramePreview(Map<String, dynamic> frameColor) {
    // 항상 4컷 프레임 - 1x4 세로 배치
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: frameColor['borderColor'],
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
