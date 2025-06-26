import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../widgets/common_widgets.dart';
import '../services/frame_composition_service.dart';

class PhotoSelectionScreen extends StatefulWidget {
  final String? selectedFrame;
  final List<XFile> capturedPhotos;
  final List<XFile> selectedPhotos;
  final Function(List<XFile>) onPhotosSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String currentStep;

  const PhotoSelectionScreen({
    Key? key,
    required this.selectedFrame,
    required this.capturedPhotos,
    required this.selectedPhotos,
    required this.onPhotosSelected,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
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

    // 전달받은 사진 정보 로깅
    print('📷 PhotoSelectionScreen 초기화');
    print('전달받은 촬영 사진 수: ${widget.capturedPhotos.length}');
    print('기존에 선택된 사진 수: ${widget.selectedPhotos.length}');
    print('선택된 프레임: ${widget.selectedFrame}');

    for (int i = 0; i < widget.capturedPhotos.length; i++) {
      print('  촬영 사진 ${i + 1}: ${widget.capturedPhotos[i].name}');
    }

    if (widget.capturedPhotos.isEmpty) {
      print('⚠️ 경고: 촬영된 사진이 없습니다!');
    }

    // 필요한 사진 수 확인
    int requiredCount = _getRequiredPhotoCount(widget.selectedFrame);
    print('필요한 사진 수: $requiredCount');
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
            final isWideScreen = constraints.maxWidth > 800;
            final padding = isWideScreen ? 30.0 : 20.0;

            if (isWideScreen) {
              // 와이드 스크린: 좌우 분할 레이아웃
              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    // 제목
                    Text(
                      '사진을 선택해주세요',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, color: Colors.pink),
                          SizedBox(width: 10),
                          Text(
                            '${_selectedPhotos.length} / $requiredPhotoCount 장 선택됨',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                          ),
                          if (_selectedPhotos.length == requiredPhotoCount) ...[
                            SizedBox(width: 10),
                            Icon(Icons.check_circle, color: Colors.green),
                            Text(
                              '완료!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // 메인 콘텐츠 영역
                    Expanded(
                      child: Row(
                        children: [
                          // 왼쪽: 사진 그리드
                          Expanded(
                            flex: 3,
                            child: _buildPhotoGrid(4), // 와이드스크린에서는 4열
                          ),
                          SizedBox(width: 30),
                          // 오른쪽: 프레임 미리보기
                          Expanded(
                            flex: 2,
                            child: _buildFramePreview(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    CommonWidgets.buildNavigationButtons(
                      onNext: _selectedPhotos.length == requiredPhotoCount
                          ? () {
                              print('다음 단계로 이동');
                              print('선택된 사진들:');
                              for (int i = 0; i < _selectedPhotos.length; i++) {
                                print('  ${i + 1}. ${_selectedPhotos[i].name}');
                              }
                              widget.onPhotosSelected(_selectedPhotos);
                              widget.onNext();
                            }
                          : null,
                      onBack: widget.onBack,
                    ),
                  ],
                ),
              );
            } else {
              // 모바일: 세로 레이아웃
              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    // 제목
                    Text(
                      '사진을 선택해주세요',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // 프레임 미리보기 (모바일에서는 작게)
                    Container(
                      height: 200,
                      child: _buildFramePreview(),
                    ),
                    SizedBox(height: 20),
                    // 사진 그리드
                    Expanded(
                      child: _buildPhotoGrid(2), // 모바일에서는 2열
                    ),
                    SizedBox(height: 20),
                    CommonWidgets.buildNavigationButtons(
                      onNext: _selectedPhotos.length == requiredPhotoCount
                          ? () {
                              print('다음 단계로 이동');
                              print('선택된 사진들:');
                              for (int i = 0; i < _selectedPhotos.length; i++) {
                                print('  ${i + 1}. ${_selectedPhotos[i].name}');
                              }
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
      default:
        return 4;
    }
  }

  void _togglePhotoSelection(XFile photo, int requiredCount) {
    print('_togglePhotoSelection 호출됨');
    print('선택하려는 사진: ${photo.name}');
    print('현재 선택된 사진 수: ${_selectedPhotos.length}');
    print('필요한 사진 수: $requiredCount');
    print('이미 선택되어 있는가? ${_selectedPhotos.contains(photo)}');

    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
        print('✅ 사진 선택 해제: ${photo.name}');
      } else if (_selectedPhotos.length < requiredCount) {
        _selectedPhotos.add(photo);
        print('✅ 사진 선택: ${photo.name}');
      } else {
        // 최대 개수에 도달했을 때는 첫 번째 사진을 제거하고 새로운 사진을 추가
        XFile removedPhoto = _selectedPhotos.removeAt(0);
        _selectedPhotos.add(photo);
        print('✅ 사진 교체: ${removedPhoto.name} -> ${photo.name}');
      }
      print('📊 현재 선택된 사진 수: ${_selectedPhotos.length}/$requiredCount');

      // 선택된 사진 목록 출력
      print('📋 선택된 사진 목록:');
      for (int i = 0; i < _selectedPhotos.length; i++) {
        print('  ${i + 1}. ${_selectedPhotos[i].name}');
      }
    });
  }

  /// 사진 그리드를 빌드합니다.
  Widget _buildPhotoGrid(int crossAxisCount) {
    int requiredPhotoCount = _getRequiredPhotoCount(widget.selectedFrame);

    if (widget.capturedPhotos.isEmpty) {
      return Center(
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
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: widget.capturedPhotos.length,
      itemBuilder: (context, index) {
        final photo = widget.capturedPhotos[index];
        final isSelected = _selectedPhotos.contains(photo);
        final selectionIndex = _selectedPhotos.indexOf(photo) + 1;

        return GestureDetector(
          onTap: () {
            print('🖱️ 사진 탭됨: index=$index, name=${photo.name}');
            _togglePhotoSelection(photo, requiredPhotoCount);
          },
          child: Container(
            decoration: BoxDecoration(
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
            child: Stack(
              children: [
                // 실제 사진 표시
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: FutureBuilder<Uint8List>(
                      future: photo.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          print(
                              '✅ 사진 로드 완료: ${photo.name}, 크기: ${snapshot.data!.length} bytes');
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        } else if (snapshot.hasError) {
                          print(
                              '❌ 사진 로드 에러: ${photo.name}, 에러: ${snapshot.error}');
                          return Container(
                            color: Colors.red.shade200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error,
                                      size: 30, color: Colors.red),
                                  SizedBox(height: 5),
                                  Text(
                                    '로딩 실패',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            color: Colors.grey.shade400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '로딩 중...',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
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
                        border: Border.all(color: Colors.white, width: 2),
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
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 프레임 미리보기를 빌드합니다.
  Widget _buildFramePreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '프레임 미리보기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: _selectedPhotos.length ==
                    _getRequiredPhotoCount(widget.selectedFrame)
                ? _buildCompletePreview()
                : _buildIncompletePreview(),
          ),
          SizedBox(height: 15),
          if (_selectedPhotos.length ==
              _getRequiredPhotoCount(widget.selectedFrame))
            ElevatedButton.icon(
              onPressed: _generateAndDownloadFrame,
              icon: Icon(Icons.download),
              label: Text('프레임 다운로드'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 완전한 프레임 미리보기를 빌드합니다.
  Widget _buildCompletePreview() {
    return FutureBuilder<Uint8List>(
      future: FrameCompositionService.composeWithFrame(
        photos: _selectedPhotos,
        frameType: widget.selectedFrame ?? 'classic_4cut',
        width: 400,
        height: 600,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 40, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    '미리보기 생성 실패',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    '미리보기 생성 중...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  /// 불완전한 프레임 미리보기를 빌드합니다.
  Widget _buildIncompletePreview() {
    final positions = FrameCompositionService.getPhotoPositions(
      widget.selectedFrame ?? 'classic_4cut',
      400,
      600,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // 프레임 배경
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          // 사진 슬롯들
          ...List.generate(positions.length, (index) {
            final position = positions[index];
            final scaleFactor = 0.5; // 미리보기용 축소

            return Positioned(
              left: position.x * scaleFactor,
              top: position.y * scaleFactor,
              width: position.width * scaleFactor,
              height: position.height * scaleFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: index < _selectedPhotos.length
                      ? Colors.pink.shade100
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(
                      position.borderRadius * scaleFactor),
                  border: Border.all(
                    color: index < _selectedPhotos.length
                        ? Colors.pink
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: index < _selectedPhotos.length
                    ? FutureBuilder<Uint8List>(
                        future: _selectedPhotos[index].readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  position.borderRadius * scaleFactor),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
              ),
            );
          }),
          // 중앙 안내 텍스트
          if (_selectedPhotos.isEmpty)
            Center(
              child: Text(
                '사진을 선택하면\n미리보기가 표시됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 프레임을 생성하고 다운로드합니다.
  Future<void> _generateAndDownloadFrame() async {
    try {
      print('🎨 프레임 생성 및 다운로드 시작');

      final frameBytes = await FrameCompositionService.composeWithFrame(
        photos: _selectedPhotos,
        frameType: widget.selectedFrame ?? 'classic_4cut',
        width: 800,
        height: 1200,
      );

      final filename =
          'photobooth_frame_${DateTime.now().millisecondsSinceEpoch}.png';
      FrameCompositionService.downloadImage(frameBytes, filename);

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 프레임 이미지가 다운로드되었습니다!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('❌ 프레임 다운로드 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ 프레임 생성에 실패했습니다: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
