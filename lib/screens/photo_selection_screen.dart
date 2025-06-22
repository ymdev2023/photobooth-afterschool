import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common_widgets.dart';

class PhotoSelectionScreen extends StatefulWidget {
  final String? selectedFrame;
  final List<XFile> capturedPhotos;
  final List<XFile> selectedPhotos;
  final Function(List<XFile>) onPhotosSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PhotoSelectionScreen({
    Key? key,
    required this.selectedFrame,
    required this.capturedPhotos,
    required this.selectedPhotos,
    required this.onPhotosSelected,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _PhotoSelectionScreenState createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends State<PhotoSelectionScreen> {
  late List<XFile> _selectedPhotos;

  @override
  void initState() {
    super.initState();
    _selectedPhotos = List.from(widget.selectedPhotos);
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 프레임에 따른 필요한 사진 수 결정
    int requiredPhotoCount = _getRequiredPhotoCount(widget.selectedFrame);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            final crossAxisCount = isWideScreen ? 4 : 2;
            final padding = isWideScreen ? 30.0 : 20.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  CommonWidgets.buildStepHeader('사진을 선택해주세요', '3 / 7'),
                  SizedBox(height: 20),
                  // 선택 현황 표시
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.pink.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.pink),
                        SizedBox(width: 10),
                        Text(
                          '${_selectedPhotos.length} / $requiredPhotoCount 장 선택됨',
                          style: TextStyle(
                            fontSize: isWideScreen ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // 촬영된 사진들을 그리드로 표시
                  Expanded(
                    child: widget.capturedPhotos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '촬영된 사진이 없습니다',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '이전 단계로 돌아가서 사진을 촬영해주세요',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: widget.capturedPhotos.length,
                            itemBuilder: (context, index) {
                              final photo = widget.capturedPhotos[index];
                              final isSelected =
                                  _selectedPhotos.contains(photo);
                              final selectionIndex =
                                  _selectedPhotos.indexOf(photo) + 1;

                              return GestureDetector(
                                onTap: () => _togglePhotoSelection(
                                    photo, requiredPhotoCount),
                                child: Container(
                                  decoration: BoxDecoration(
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
                                  child: Stack(
                                    children: [
                                      // 사진 표시 (실제로는 Image.file을 사용해야 함)
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          child: Container(
                                            color: Colors.grey.shade400,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.photo,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    '사진 ${index + 1}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 선택 상태 표시
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.pink,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                selectionIndex.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // 선택되지 않은 상태 오버레이
                                      if (!isSelected)
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 20),
                  CommonWidgets.buildNavigationButtons(
                    onNext: _selectedPhotos.length == requiredPhotoCount
                        ? () {
                            widget.onPhotosSelected(_selectedPhotos);
                            widget.onNext();
                          }
                        : null,
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

  int _getRequiredPhotoCount(String? frameType) {
    switch (frameType) {
      case 'classic_4cut':
        return 4;
      case 'grid_6cut':
        return 6;
      case 'strip_frame':
        return 3;
      default:
        return 4;
    }
  }

  void _togglePhotoSelection(XFile photo, int requiredCount) {
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
      } else if (_selectedPhotos.length < requiredCount) {
        _selectedPhotos.add(photo);
      } else {
        // 최대 개수에 도달했을 때는 첫 번째 사진을 제거하고 새로운 사진을 추가
        _selectedPhotos.removeAt(0);
        _selectedPhotos.add(photo);
      }
    });
  }
}
