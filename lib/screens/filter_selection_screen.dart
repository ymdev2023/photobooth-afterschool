import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../widgets/common_widgets.dart';

class FilterSelectionScreen extends StatefulWidget {
  final String? selectedFilter;
  final String? selectedFrame;
  final List<XFile> selectedPhotos;
  final Function(String) onFilterSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String currentStep;

  const FilterSelectionScreen({
    Key? key,
    required this.selectedFilter,
    required this.selectedFrame,
    required this.selectedPhotos,
    required this.onFilterSelected,
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
  void initState() {
    super.initState();
    print('FilterSelectionScreen 초기화');
    print('선택된 프레임: ${widget.selectedFrame}');
    print('선택된 사진 수: ${widget.selectedPhotos.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            final previewSize = isWideScreen ? 300.0 : 250.0;

            return Padding(
              padding: EdgeInsets.all(isWideScreen ? 30 : 20),
              child: Column(
                children: [
                  // 제목만 표시, step indicator 제거
                  Text(
                    '필터를 선택해주세요',
                    style: TextStyle(
                      fontSize: isWideScreen ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // 프레임 미리보기 섹션
                  Container(
                    width: previewSize,
                    height: previewSize * 1.2,
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
                      child: _buildFramePreview(previewSize),
                    ),
                  ),

                  SizedBox(height: 30),

                  // 필터 선택 섹션
                  Text(
                    '적용할 필터를 선택하세요',
                    style: TextStyle(
                      fontSize: isWideScreen ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 20),

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
                              print('필터 선택: $filter');
                            },
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.pink : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.pink
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
                    onNext:
                        widget.selectedFilter != null ? widget.onNext : null,
                    onBack: widget.onBack,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFramePreview(double size) {
    print('_buildFramePreview 호출됨');
    print('선택된 사진 수: ${widget.selectedPhotos.length}');
    print('선택된 프레임: ${widget.selectedFrame}');

    if (widget.selectedPhotos.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 10),
              Text(
                '선택된 사진이 없습니다',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 프레임 타입에 따른 레이아웃
    if (widget.selectedFrame == '4컷') {
      print('4컷 레이아웃 사용');
      return _build4CutLayout(size);
    } else if (widget.selectedFrame == '6컷') {
      print('6컷 레이아웃 사용');
      return _build6CutLayout(size);
    } else {
      print('기본 레이아웃 사용');
      return _buildDefaultLayout(size);
    }
  }

  Widget _build4CutLayout(double size) {
    return Column(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.all(2),
            child: _buildPhotoContainer(index),
          ),
        );
      }),
    );
  }

  Widget _build6CutLayout(double size) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.all(1),
                  child: _buildPhotoContainer(index),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.all(1),
                  child: _buildPhotoContainer(index + 3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLayout(double size) {
    // 선택된 사진 수에 따라 동적으로 레이아웃 결정
    int photoCount = widget.selectedPhotos.length;

    if (photoCount == 1) {
      return _buildPhotoContainer(0);
    } else if (photoCount <= 4) {
      // 4장 이하는 2x2 그리드로 표시
      return Column(
        children: List.generate(2, (row) {
          return Expanded(
            child: Row(
              children: List.generate(2, (col) {
                int index = row * 2 + col;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.all(1),
                    child: index < photoCount
                        ? _buildPhotoContainer(index)
                        : Container(color: Colors.grey.shade300),
                  ),
                );
              }),
            ),
          );
        }),
      );
    } else {
      // 4장 초과는 3x2 그리드로 표시 (6컷과 동일)
      return _build6CutLayout(size);
    }
  }

  Widget _buildPhotoContainer(int index) {
    print(
        '_buildPhotoContainer 호출됨 - index: $index, 전체 사진 수: ${widget.selectedPhotos.length}');

    if (index >= widget.selectedPhotos.length) {
      return Container(
        color: Colors.grey.shade300,
        child: Center(
          child: Icon(
            Icons.add_photo_alternate,
            color: Colors.grey.shade500,
            size: 30,
          ),
        ),
      );
    }

    return FutureBuilder<Uint8List>(
      future: widget.selectedPhotos[index].readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Widget imageWidget = Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );

          // 필터 적용
          return _applyFilter(imageWidget);
        } else if (snapshot.hasError) {
          return Container(
            color: Colors.red.shade200,
            child: Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 24,
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.grey.shade300,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _applyFilter(Widget image) {
    switch (widget.selectedFilter) {
      case 'Sepia':
        return ColorFiltered(
          colorFilter: ColorFilter.matrix([
            0.393,
            0.769,
            0.189,
            0,
            0,
            0.349,
            0.686,
            0.168,
            0,
            0,
            0.272,
            0.534,
            0.131,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: image,
        );
      case 'Black & White':
        return ColorFiltered(
          colorFilter: ColorFilter.matrix([
            0.33,
            0.33,
            0.33,
            0,
            0,
            0.33,
            0.33,
            0.33,
            0,
            0,
            0.33,
            0.33,
            0.33,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: image,
        );
      case 'Vintage':
        return ColorFiltered(
          colorFilter: ColorFilter.matrix([
            1.2,
            0,
            0.2,
            0,
            0,
            0,
            1.0,
            0,
            0,
            0,
            0,
            0,
            0.8,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
            ),
            child: image,
          ),
        );
      default: // Original
        return image;
    }
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
