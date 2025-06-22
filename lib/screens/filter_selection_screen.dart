import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../widgets/common_widgets.dart';

class FilterSelectionScreen extends StatefulWidget {
  final String? selectedFilter;
  final Function(String) onFilterSelected;
  final Uint8List? filteredImage;
  final Function(String) onApplyFilter;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String currentStep;

  const FilterSelectionScreen({
    Key? key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.filteredImage,
    required this.onApplyFilter,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  }) : super(key: key);

  @override
  _FilterSelectionScreenState createState() => _FilterSelectionScreenState();
}

class _FilterSelectionScreenState extends State<FilterSelectionScreen> {
  final List<String> filters = [
    'Original',
    'Sepia',
    'Black & White',
    'Vintage'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CommonWidgets.buildStepHeader('필터를 선택해주세요', widget.currentStep),
          SizedBox(height: 30),
          // 사진 미리보기
          Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.pink.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: widget.filteredImage != null
                  ? Image.memory(
                      widget.filteredImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.grey.shade600,
                              size: 60,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '필터 미리보기',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 30),
          // 필터 선택 버튼들
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = widget.selectedFilter == filter;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      widget.onFilterSelected(filter);
                      widget.onApplyFilter(filter);
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.pink : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              isSelected ? Colors.pink : Colors.grey.shade300,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getFilterIcon(filter),
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 30,
                          ),
                          SizedBox(height: 8),
                          Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Spacer(),
          CommonWidgets.buildNavigationButtons(
            onNext: widget.onNext,
            onBack: widget.onBack,
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Original':
        return Icons.image;
      case 'Sepia':
        return Icons.wb_sunny;
      case 'Black & White':
        return Icons.filter_b_and_w;
      case 'Vintage':
        return Icons.camera_roll;
      default:
        return Icons.filter;
    }
  }
}
