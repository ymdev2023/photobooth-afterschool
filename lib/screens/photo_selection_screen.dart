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
  List<XFile> _selectedPhotos = [];

  @override
  void initState() {
    super.initState();
    _selectedPhotos = List.from(widget.selectedPhotos);
  }

  @override
  Widget build(BuildContext context) {
    final requiredCount = widget.selectedFrame == 'classic_4cut' ? 4 : 6;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CommonWidgets.buildStepHeader('사진을 선택해주세요', '3 / 7'),
          SizedBox(height: 20),
          Text(
            '촬영된 ${widget.capturedPhotos.length}장 중 ${requiredCount}장을 선택하세요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '선택됨: ${_selectedPhotos.length}/${requiredCount}장',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.capturedPhotos.length,
              itemBuilder: (context, index) {
                final photo = widget.capturedPhotos[index];
                final isSelected = _selectedPhotos.contains(photo);

                return GestureDetector(
                  onTap: () => _togglePhotoSelection(photo, requiredCount),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.grey.shade600,
                                  size: 30,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
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
            onNext: _selectedPhotos.length == requiredCount
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
  }

  void _togglePhotoSelection(XFile photo, int requiredCount) {
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
      } else if (_selectedPhotos.length < requiredCount) {
        _selectedPhotos.add(photo);
      } else {
        // 이미 최대 개수에 도달한 경우, 가장 오래된 것을 제거하고 새로운 것을 추가
        _selectedPhotos.removeAt(0);
        _selectedPhotos.add(photo);
      }
    });
  }
}
