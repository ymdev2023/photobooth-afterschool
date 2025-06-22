import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/photo_booth_step.dart';
import 'screens/welcome_screen.dart';
import 'screens/frame_selection_screen.dart';
import 'screens/photo_capture_screen.dart';
import 'screens/photo_selection_screen.dart';
import 'screens/filter_selection_screen.dart';
import 'screens/review_screen.dart';
import 'screens/download_screen.dart';
import 'services/camera_service.dart';
import 'dart:typed_data';

void main() {
  runApp(const PhotoBoothApp());
}

class PhotoBoothApp extends StatelessWidget {
  const PhotoBoothApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Booth',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      home: const PhotoBoothHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PhotoBoothHomePage extends StatefulWidget {
  const PhotoBoothHomePage({Key? key}) : super(key: key);

  @override
  _PhotoBoothHomePageState createState() => _PhotoBoothHomePageState();
}

class _PhotoBoothHomePageState extends State<PhotoBoothHomePage> {
  PhotoBoothStep currentStep = PhotoBoothStep.welcome;
  String? selectedFrame;
  String? selectedFilter;
  List<XFile> capturedPhotos = [];
  List<XFile> selectedPhotos = [];
  String? qrCodeData;
  late CameraService cameraService;
  Uint8List? filteredImage;
  String? downloadUrl;

  @override
  void initState() {
    super.initState();
    cameraService = CameraService();
  }

  void _nextStep() {
    setState(() {
      switch (currentStep) {
        case PhotoBoothStep.welcome:
          currentStep = PhotoBoothStep.frameSelection;
          break;
        case PhotoBoothStep.frameSelection:
          currentStep = PhotoBoothStep.photoCapture;
          break;
        case PhotoBoothStep.photoCapture:
          // 촬영된 사진들을 가져와서 저장
          capturedPhotos = cameraService.getCapturedPhotos();
          currentStep = PhotoBoothStep.photoSelection;
          break;
        case PhotoBoothStep.photoSelection:
          currentStep = PhotoBoothStep.filterSelection;
          break;
        case PhotoBoothStep.filterSelection:
          currentStep = PhotoBoothStep.review;
          break;
        case PhotoBoothStep.review:
          currentStep = PhotoBoothStep.download;
          break;
        case PhotoBoothStep.download:
          _resetToWelcome();
          break;
      }
    });
  }

  void _previousStep() {
    setState(() {
      switch (currentStep) {
        case PhotoBoothStep.frameSelection:
          currentStep = PhotoBoothStep.welcome;
          break;
        case PhotoBoothStep.photoCapture:
          currentStep = PhotoBoothStep.frameSelection;
          break;
        case PhotoBoothStep.photoSelection:
          currentStep = PhotoBoothStep.photoCapture;
          break;
        case PhotoBoothStep.filterSelection:
          currentStep = PhotoBoothStep.photoSelection;
          break;
        case PhotoBoothStep.review:
          currentStep = PhotoBoothStep.filterSelection;
          break;
        case PhotoBoothStep.download:
          currentStep = PhotoBoothStep.review;
          break;
        case PhotoBoothStep.welcome:
          break;
      }
    });
  }

  void _resetToWelcome() {
    setState(() {
      currentStep = PhotoBoothStep.welcome;
      selectedFrame = null;
      selectedFilter = null;
      capturedPhotos.clear();
      selectedPhotos.clear();
      qrCodeData = null;
    });
  }

  void _updateFrame(String frame) {
    setState(() {
      selectedFrame = frame;
    });
  }

  void _updateFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  void _updateSelectedPhotos(List<XFile> photos) {
    setState(() {
      selectedPhotos = photos;
    });
  }

  String _getCurrentStepText() {
    switch (currentStep) {
      case PhotoBoothStep.welcome:
        return '시작';
      case PhotoBoothStep.frameSelection:
        return '1 / 8';
      case PhotoBoothStep.photoCapture:
        return '2 / 8';
      case PhotoBoothStep.photoSelection:
        return '3 / 8';
      case PhotoBoothStep.filterSelection:
        return '4 / 8';
      case PhotoBoothStep.review:
        return '5 / 8';
      case PhotoBoothStep.download:
        return '6 / 8';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (currentStep) {
      case PhotoBoothStep.welcome:
        return WelcomeScreen(
          onStart: _nextStep,
        );
      case PhotoBoothStep.frameSelection:
        return FrameSelectionScreen(
          selectedFrame: selectedFrame,
          onFrameSelected: _updateFrame,
          onNext: selectedFrame != null ? _nextStep : null,
          onBack: _previousStep,
          currentStep: _getCurrentStepText(),
        );
      case PhotoBoothStep.photoCapture:
        return PhotoCaptureScreen(
          cameraService: cameraService,
          onNext: _nextStep,
          onBack: _previousStep,
          currentStep: _getCurrentStepText(),
        );
      case PhotoBoothStep.photoSelection:
        return PhotoSelectionScreen(
          selectedFrame: selectedFrame,
          capturedPhotos: capturedPhotos,
          selectedPhotos: selectedPhotos,
          onPhotosSelected: _updateSelectedPhotos,
          onNext: _nextStep,
          onBack: _previousStep,
          currentStep: _getCurrentStepText(),
        );
      case PhotoBoothStep.filterSelection:
        return FilterSelectionScreen(
          selectedFilter: selectedFilter,
          selectedFrame: selectedFrame,
          selectedPhotos: selectedPhotos,
          onFilterSelected: _updateFilter,
          onNext: _nextStep,
          onBack: _previousStep,
          currentStep: _getCurrentStepText(),
        );
      case PhotoBoothStep.review:
        return ReviewScreen(
          filteredImage: filteredImage,
          onNext: _nextStep,
          onBack: _previousStep,
          currentStep: _getCurrentStepText(),
        );
      case PhotoBoothStep.download:
        return DownloadScreen(
          downloadUrl: downloadUrl,
          onRestart: _resetToWelcome,
          currentStep: _getCurrentStepText(),
        );
      default:
        return WelcomeScreen(onStart: _nextStep);
    }
  }
}
