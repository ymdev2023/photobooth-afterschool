import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:ui_web' as ui_web;

void main() {
  runApp(PhotoBoothApp());
}

enum PhotoBoothStep {
  welcome, // 메인 화면
  frameSelection, // 프레임 선택
  photoCapture, // 사진 촬영
  filterSelection, // 필터 선택
  review, // 최종 확인
  download // QR코드 다운로드
}

class PhotoBoothApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Booth',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      home: PhotoBoothHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PhotoBoothHomePage extends StatefulWidget {
  @override
  _PhotoBoothHomePageState createState() => _PhotoBoothHomePageState();
}

class _PhotoBoothHomePageState extends State<PhotoBoothHomePage> {
  PhotoBoothStep currentStep = PhotoBoothStep.welcome;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String? _downloadUrl;
  String? _selectedFrame;

  // 카메라 관련 변수들
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isBackCamera = true;

  // 웹 카메라 관련 변수들
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  bool _isWebCameraInitialized = false;
  html.CanvasElement? _canvasElement;
  html.CanvasRenderingContext2D? _canvasContext;
  String _videoElementId = 'video-element-${DateTime.now().millisecondsSinceEpoch}';

  List<Map<String, dynamic>> _frames = [
    {
      'name': '4컷 프레임',
      'description': '세로로 긴 클래식 4컷',
      'path': 'classic_4cut',
      'cuts': 4,
      'layout': 'vertical', // 세로 4컷
      'color': Colors.white,
      'borderColor': Colors.grey.shade400,
    },
    {
      'name': '6컷 프레임',
      'description': '2x3 그리드 6컷',
      'path': 'grid_6cut',
      'cuts': 6,
      'layout': 'grid', // 2x3 그리드
      'color': Colors.pink.shade50,
      'borderColor': Colors.pink.shade300,
    },
  ];

  List<String> filters = ['Original', 'Sepia', 'Black & White', 'Vintage'];
  String? _selectedFilter;
  img.Image? _filteredImage;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    _disposeWebCamera();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWebCamera();
    } else {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![_isBackCamera ? 0 : 1],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('카메라 초기화 실패: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras != null && _cameras!.length > 1) {
      setState(() {
        _isBackCamera = !_isBackCamera;
        _isCameraInitialized = false;
      });

      await _cameraController?.dispose();
      _cameraController = CameraController(
        _cameras![_isBackCamera ? 0 : 1],
        ResolutionPreset.high,
      );

      try {
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } catch (e) {
        print('카메라 전환 실패: $e');
      }
    }
  }

  // 웹 카메라 관련 메서드들
  Future<void> _initWebCamera() async {
    try {
      // HTML5 getUserMedia API를 사용하여 카메라 스트림 가져오기
      final mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'user', 'width': 640, 'height': 480},
        'audio': false,
      });

      _mediaStream = mediaStream;
      
      // 비디오 엘리먼트 생성 및 설정
      _videoElement = html.VideoElement()
        ..id = _videoElementId
        ..srcObject = _mediaStream
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // 플랫폼 뷰에 비디오 엘리먼트 등록
      ui_web.platformViewRegistry.registerViewFactory(
        _videoElementId,
        (int viewId) => _videoElement!,
      );

      // 캔버스 엘리먼트 생성 (사진 캡처용)
      _canvasElement = html.CanvasElement(width: 640, height: 480);
      _canvasContext = _canvasElement!.getContext('2d') as html.CanvasRenderingContext2D;

      setState(() {
        _isWebCameraInitialized = true;
      });

      print('웹 카메라 초기화 성공');
    } catch (e) {
      print('웹 카메라 초기화 실패: $e');
      setState(() {
        _isWebCameraInitialized = false;
      });
    }
  }

  Future<void> _switchWebCamera() async {
    if (_mediaStream != null) {
      // 현재 스트림 정지
      _mediaStream!.getTracks().forEach((track) => track.stop());
      
      try {
        // 카메라 전환 (전면/후면)
        final mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
          'video': {'facingMode': _isBackCamera ? 'user' : 'environment'},
          'audio': false,
        });

        _mediaStream = mediaStream;
        _videoElement!.srcObject = _mediaStream;

        setState(() {
          _isBackCamera = !_isBackCamera;
        });

        print('웹 카메라 전환 성공');
      } catch (e) {
        print('웹 카메라 전환 실패: $e');
      }
    }
  }

  Future<XFile?> _captureWebPhoto() async {
    if (_videoElement == null || _canvasElement == null || _canvasContext == null) {
      return null;
    }

    try {
      // 비디오에서 캔버스로 현재 프레임 그리기
      _canvasContext!.drawImageScaled(
        _videoElement!,
        0, 0,
        _canvasElement!.width!,
        _canvasElement!.height!,
      );

      // 캔버스를 데이터 URL로 변환
      final dataUrl = _canvasElement!.toDataUrl('image/jpeg', 0.95);
      
      // 데이터 URL에서 base64 데이터 추출
      final base64Data = dataUrl.split(',')[1];
      final bytes = base64Decode(base64Data);

      // 임시 파일명 생성
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // XFile 생성
      return XFile.fromData(bytes, name: fileName, mimeType: 'image/jpeg');
      
    } catch (e) {
      print('웹 사진 캡처 실패: $e');
      return null;
    }
  }

  void _disposeWebCamera() {
    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) => track.stop());
      _mediaStream = null;
    }
    _videoElement = null;
    _canvasElement = null;
    _canvasContext = null;
    _isWebCameraInitialized = false;
  }

  // 헬퍼 메서드들
  Widget _buildStepHeader(String title, String step) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Text(
            step,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({VoidCallback? onNext, VoidCallback? onBack}) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onBack != null)
            ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('이전'),
            )
          else
            SizedBox(width: 80),
          if (onNext != null)
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('다음'),
            )
          else
            SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    if (_filteredImage != null) {
      return Image.memory(
        Uint8List.fromList(img.encodeJpg(_filteredImage!)),
        fit: BoxFit.cover,
      );
    } else if (_image != null) {
      return FutureBuilder<Uint8List>(
        future: _image!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          }
          return Container(
            color: Colors.grey.shade300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Text('사진이 없습니다'),
      ),
    );
  }

  // 프레임 썸네일 위젯
  Widget _buildFrameThumbnail(Map<String, dynamic> frame) {
    int cuts = frame['cuts'] as int;
    String layout = frame['layout'] as String;
    Color frameColor = frame['color'] as Color;
    Color borderColor = frame['borderColor'] as Color;

    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: frameColor,
        border: Border.all(color: borderColor, width: 4),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: layout == 'vertical'
          ? Column(
              children: List.generate(cuts, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.photo_camera_outlined,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                );
              }),
            )
          : Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  // 상단 2개
                  Expanded(
                    child: Row(
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // 중간 2개
                  Expanded(
                    child: Row(
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // 하단 2개
                  Expanded(
                    child: Row(
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 선택된 프레임과 함께 사진을 표시하는 위젯
  Widget _buildPhotoWithFrame() {
    if (_image == null) return _buildPhotoPreview();

    // 선택된 프레임 정보 가져오기
    Map<String, dynamic>? selectedFrameData;
    if (_selectedFrame != null) {
      selectedFrameData = _frames.firstWhere(
        (frame) => frame['path'] == _selectedFrame,
        orElse: () => _frames[0],
      );
    }

    if (selectedFrameData == null) {
      return _buildPhotoPreview();
    }

    int cuts = selectedFrameData['cuts'] as int;
    String layout = selectedFrameData['layout'] as String;
    Color frameColor = selectedFrameData['color'] as Color;
    Color borderColor = selectedFrameData['borderColor'] as Color;

    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: frameColor,
        border: Border.all(color: borderColor, width: 6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // 브랜드명 또는 로고 영역
            Container(
              height: 30,
              child: Center(
                child: Text(
                  'AFTERSCHOOL PHOTO BOOTH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            // 사진 영역들
            Expanded(
              child: layout == 'vertical'
                  ? Column(
                      children: List.generate(cuts, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: _buildPhotoPreview(),
                            ),
                          ),
                        );
                      }),
                    )
                  : Column(
                      children: [
                        // 상단 2개
                        Expanded(
                          child: Row(
                            children: List.generate(2, (index) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade400, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: _buildPhotoPreview(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // 중간 2개
                        Expanded(
                          child: Row(
                            children: List.generate(2, (index) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade400, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: _buildPhotoPreview(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // 하단 2개
                        Expanded(
                          child: Row(
                            children: List.generate(2, (index) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade400, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: _buildPhotoPreview(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 8),
            // 하단 날짜 또는 로고 영역
            Container(
              height: 20,
              child: Center(
                child: Text(
                  DateTime.now().toString().substring(0, 10),
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCountdown() {
    setState(() {
      _countdown = 3;
    });

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown == 0) {
        timer.cancel();
        _takePicture();
      }
    });
  }

  Future<void> _takePicture() async {
    if (kIsWeb) {
      // 웹에서는 HTML5 카메라 스트림 사용
      if (_isWebCameraInitialized) {
        final XFile? photo = await _captureWebPhoto();
        if (photo != null) {
          setState(() {
            _image = photo;
          });
        }
      } else {
        // 웹 카메라가 초기화되지 않은 경우 파일 피커 사용 (폴백)
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          setState(() {
            _image = photo;
          });
        }
      }
    } else {
      // 모바일에서는 카메라 컨트롤러 사용
      if (_cameraController != null && _isCameraInitialized) {
        try {
          final XFile photo = await _cameraController!.takePicture();
          setState(() {
            _image = photo;
          });
        } catch (e) {
          print('사진 촬영 실패: $e');
        }
      }
    }
  }

  Future<void> _applyFilter(String filterName) async {
    if (_image == null) return;

    var imageBytes = await _image!.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return;

    // 간단한 필터 시뮬레이션 (웹 호환성을 위해)
    img.Image? filtered;
    switch (filterName) {
      case 'Sepia':
        filtered = img.sepia(image);
        break;
      case 'Black & White':
        filtered = img.grayscale(image);
        break;
      case 'Vintage':
        filtered = img.adjustColor(image, brightness: -0.1, contrast: 1.2);
        break;
      default:
        filtered = image;
    }

    setState(() {
      _filteredImage = filtered;
      _selectedFilter = filterName;
    });
  }

  Future<void> _saveAndGenerateQr() async {
    // 실제로는 서버 업로드 후 다운로드 URL을 받아야 함
    // 여기서는 임시 URL을 사용
    String downloadUrl =
        'https://example.com/photo/${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (_filteredImage != null) {
      // 필터가 적용된 경우의 처리
      downloadUrl =
          'https://example.com/photo/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    setState(() {
      _downloadUrl = downloadUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case PhotoBoothStep.welcome:
        return _buildWelcomeScreen();
      case PhotoBoothStep.frameSelection:
        return _buildFrameSelectionScreen();
      case PhotoBoothStep.photoCapture:
        return _buildPhotoCaptureScreen();
      case PhotoBoothStep.filterSelection:
        return _buildFilterSelectionScreen();
      case PhotoBoothStep.review:
        return _buildReviewScreen();
      case PhotoBoothStep.download:
        return _buildDownloadScreen();
    }
  }

  // 메인 화면
  Widget _buildWelcomeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink.shade200, Colors.purple.shade300],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 120,
              color: Colors.white,
            ),
            SizedBox(height: 30),
            Text(
              'AFTERSCHOOL',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'PHOTO BOOTH',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                letterSpacing: 8,
              ),
            ),
            SizedBox(height: 60),
            Text(
              '나만의 특별한 순간을 담아보세요',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = PhotoBoothStep.frameSelection;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                '시작하기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 프레임 선택 화면
  Widget _buildFrameSelectionScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade200, Colors.purple.shade300],
        ),
      ),
      child: Column(
        children: [
          _buildStepHeader('프레임을 선택해주세요', '1 / 4'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _frames.map((frame) {
                  final isSelected = _selectedFrame == frame['path'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFrame = frame['path'];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected ? Colors.pink : Colors.transparent,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: _buildFrameThumbnail(frame),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    frame['name']!,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    frame['description']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          _buildNavigationButtons(
            onNext: _selectedFrame != null
                ? () {
                    setState(() {
                      currentStep = PhotoBoothStep.photoCapture;
                    });
                  }
                : null,
            onBack: () {
              setState(() {
                currentStep = PhotoBoothStep.welcome;
              });
            },
          ),
        ],
      ),
    );
  }

  // 사진 촬영 화면
  Widget _buildPhotoCaptureScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade200, Colors.blue.shade300],
        ),
      ),
      child: Column(
        children: [
          _buildStepHeader('사진을 촬영해주세요', '2 / 4'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_countdown > 0) ...[
                    Text(
                      '$_countdown',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '준비하세요!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ] else if (_image == null) ...[
                    // 카메라 미리보기 또는 기본 UI
                    if (!kIsWeb &&
                        _isCameraInitialized &&
                        _cameraController != null) ...[
                      Container(
                        width: 350,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 카메라 전환 버튼
                          if (_cameras != null && _cameras!.length > 1)
                            IconButton(
                              onPressed: _switchCamera,
                              icon: Icon(Icons.flip_camera_ios,
                                  color: Colors.white),
                              iconSize: 40,
                            ),
                          SizedBox(width: 20),
                          // 촬영 버튼
                          ElevatedButton(
                            onPressed: _startCountdown,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              padding: EdgeInsets.all(20),
                              shape: CircleBorder(),
                              elevation: 10,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ] else if (kIsWeb && _isWebCameraInitialized) ...[
                      // 웹 카메라 미리보기
                      Container(
                        width: 350,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: HtmlElementView(
                            viewType: _videoElementId,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 카메라 전환 버튼
                          IconButton(
                            onPressed: _switchWebCamera,
                            icon: Icon(Icons.flip_camera_ios, color: Colors.white),
                            iconSize: 40,
                          ),
                          SizedBox(width: 20),
                          // 촬영 버튼
                          ElevatedButton(
                            onPressed: _startCountdown,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              padding: EdgeInsets.all(20),
                              shape: CircleBorder(),
                              elevation: 10,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // 웹 또는 카메라 초기화 실패 시
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 150,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 30),
                      Text(
                        kIsWeb 
                          ? (_isWebCameraInitialized ? '카메라 버튼을 눌러 촬영하세요' : '카메라 접근 권한을 허용해주세요')
                          : '카메라 버튼을 눌러 촬영하세요',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: kIsWeb && !_isWebCameraInitialized ? _initWebCamera : _startCountdown,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          shape: CircleBorder(),
                          elevation: 10,
                        ),
                        child: Icon(
                          kIsWeb && !_isWebCameraInitialized ? Icons.camera_enhance : Icons.camera_alt,
                          size: 40,
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FutureBuilder<Uint8List>(
                          future: _image!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            }
                            return Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text('다시 촬영'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentStep = PhotoBoothStep.filterSelection;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text('다음 단계'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_image == null)
            _buildNavigationButtons(
              onBack: () {
                setState(() {
                  currentStep = PhotoBoothStep.frameSelection;
                });
              },
            ),
        ],
      ),
    );
  }

  // 필터 선택 화면
  Widget _buildFilterSelectionScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange.shade200, Colors.red.shade300],
        ),
      ),
      child: Column(
        children: [
          _buildStepHeader('필터를 선택해주세요', '3 / 4'),
          Expanded(
            child: Column(
              children: [
                // 사진 미리보기
                Container(
                  margin: EdgeInsets.all(20),
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildPhotoWithFrame(),
                  ),
                ),
                // 필터 선택
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () => _applyFilter(filter),
                        child: Container(
                          width: 80,
                          margin: EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white70,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter,
                                color: isSelected ? Colors.orange : Colors.grey,
                                size: 30,
                              ),
                              SizedBox(height: 5),
                              Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      isSelected ? Colors.orange : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildNavigationButtons(
            onNext: () {
              setState(() {
                currentStep = PhotoBoothStep.review;
              });
            },
            onBack: () {
              setState(() {
                currentStep = PhotoBoothStep.photoCapture;
              });
            },
          ),
        ],
      ),
    );
  }

  // 최종 확인 화면
  Widget _buildReviewScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade200, Colors.teal.shade300],
        ),
      ),
      child: Column(
        children: [
          _buildStepHeader('최종 확인', '4 / 4'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '완성된 사진입니다!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildPhotoWithFrame(),
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentStep = PhotoBoothStep.filterSelection;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text('수정하기'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _saveAndGenerateQr();
                          setState(() {
                            currentStep = PhotoBoothStep.download;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text('저장하기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // QR코드 다운로드 화면
  Widget _buildDownloadScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade200, Colors.pink.shade300],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              '사진이 저장되었습니다!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _downloadUrl ?? 'https://example.com/photo',
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'QR코드를 스캔하여',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '사진을 다운로드하세요',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = PhotoBoothStep.welcome;
                  _image = null;
                  _selectedFrame = null;
                  _selectedFilter = null;
                  _filteredImage = null;
                  _downloadUrl = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                '처음으로',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
