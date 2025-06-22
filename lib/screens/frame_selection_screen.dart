import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class FrameSelectionScreen extends StatelessWidget {
  final String? selectedFrame;
  final Function(String) onFrameSelected;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  const FrameSelectionScreen({
    Key? key,
    required this.selectedFrame,
    required this.onFrameSelected,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> frames = [
      {
        'name': '4컷 프레임',
        'description': '세로로 긴 클래식 4컷',
        'path': 'classic_4cut',
        'cuts': 4,
        'layout': 'vertical',
        'color': Colors.white,
        'borderColor': Colors.grey.shade400,
      },
      {
        'name': '6컷 프레임',
        'description': '2x3 그리드 6컷',
        'path': 'grid_6cut',
        'cuts': 6,
        'layout': 'grid',
        'color': Colors.pink.shade50,
        'borderColor': Colors.pink.shade300,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CommonWidgets.buildStepHeader('프레임을 선택해주세요', '1 / 7'),
          SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2.5,
                mainAxisSpacing: 20,
              ),
              itemCount: frames.length,
              itemBuilder: (context, index) {
                final frame = frames[index];
                final isSelected = selectedFrame == frame['path'];

                return GestureDetector(
                  onTap: () {
                    onFrameSelected(frame['path']);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.pink.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? Colors.pink : Colors.grey.shade300,
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
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: frame['color'],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: frame['borderColor']),
                            ),
                            child: CommonWidgets.buildFramePreview(frame),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  frame['name'],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.pink.shade800
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  frame['description'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Colors.pink,
                              size: 30,
                            ),
                        ],
                      ),
                    ),
                  ),
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
    );
  }
}
