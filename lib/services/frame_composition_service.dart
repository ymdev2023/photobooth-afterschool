import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class FrameCompositionService {
  /// 프레임과 사진들을 합성하여 최종 이미지를 생성합니다.
  static Future<Uint8List> composeWithFrame({
    required List<XFile> photos,
    required String frameType,
    int width = 400,
    int height = 4000, // 1:10 비율 (400x4000)
  }) async {
    try {
      print('🎨 프레임 합성 시작: $frameType, 사진 ${photos.length}장');

      // Canvas 생성
      final canvas = html.CanvasElement(width: width, height: height);
      final ctx = canvas.getContext('2d') as html.CanvasRenderingContext2D;

      // 배경을 흰색으로 설정
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, width, height);

      // 프레임에 따른 사진 배치 정보 가져오기
      final positions = getPhotoPositions(frameType, width, height);

      // 각 사진을 정해진 위치에 배치
      for (int i = 0; i < photos.length && i < positions.length; i++) {
        await _drawPhotoAtPosition(ctx, photos[i], positions[i]);
      }

      // 프레임 오버레이 그리기 (선택사항)
      await _drawFrameOverlay(ctx, frameType, width, height);

      // Canvas를 이미지 데이터로 변환
      final dataUrl = canvas.toDataUrl('image/png');
      final base64String = dataUrl.split(',')[1];
      final bytes = base64Decode(base64String);

      print('✅ 프레임 합성 완료: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      print('❌ 프레임 합성 실패: $e');
      throw Exception('프레임 합성에 실패했습니다: $e');
    }
  }

  /// 사진을 지정된 위치에 그립니다.
  static Future<void> _drawPhotoAtPosition(
    html.CanvasRenderingContext2D ctx,
    XFile photo,
    PhotoPosition position,
  ) async {
    try {
      // 사진 데이터 읽기
      final photoBytes = await photo.readAsBytes();

      // HTML Image 요소 생성
      final photoImg = html.ImageElement();
      final blob = html.Blob([photoBytes]);
      photoImg.src = html.Url.createObjectUrlFromBlob(blob);

      // 이미지 로딩 대기
      await photoImg.onLoad.first;

      // 원본 이미지 크기
      final imgWidth = photoImg.naturalWidth;
      final imgHeight = photoImg.naturalHeight;

      // 프레임 영역에 맞게 크기 조정 (cover 모드)
      final frameRatio = position.width / position.height;
      final imageRatio = imgWidth / imgHeight;

      double drawWidth, drawHeight, sourceX, sourceY, sourceWidth, sourceHeight;

      if (imageRatio > frameRatio) {
        // 이미지가 더 넓은 경우 - 세로를 맞추고 좌우를 자름
        drawHeight = position.height;
        drawWidth = position.width;
        sourceHeight = imgHeight.toDouble();
        sourceWidth = imgHeight * frameRatio;
        sourceX = (imgWidth - sourceWidth) / 2;
        sourceY = 0;
      } else {
        // 이미지가 더 높은 경우 - 가로를 맞추고 상하를 자름
        drawWidth = position.width;
        drawHeight = position.height;
        sourceWidth = imgWidth.toDouble();
        sourceHeight = imgWidth / frameRatio;
        sourceX = 0;
        sourceY = (imgHeight - sourceHeight) / 2;
      }

      // 둥근 모서리 적용 (선택사항)
      if (position.borderRadius > 0) {
        ctx.save();
        _createRoundedPath(ctx, position.x, position.y, position.width,
            position.height, position.borderRadius);
        ctx.clip();
      }

      // 이미지 그리기
      ctx.drawImageToRect(
        photoImg,
        html.Rectangle(position.x, position.y, drawWidth, drawHeight),
        sourceRect: html.Rectangle(sourceX, sourceY, sourceWidth, sourceHeight),
      );

      if (position.borderRadius > 0) {
        ctx.restore();
      }

      // URL 해제
      html.Url.revokeObjectUrl(photoImg.src!);
    } catch (e) {
      print('❌ 사진 그리기 실패: ${photo.name}, 에러: $e');
      // 실패한 경우 회색 박스로 대체
      ctx.fillStyle = '#CCCCCC';
      ctx.fillRect(position.x, position.y, position.width, position.height);
    }
  }

  /// 둥근 모서리 경로를 생성합니다.
  static void _createRoundedPath(
    html.CanvasRenderingContext2D ctx,
    double x,
    double y,
    double width,
    double height,
    double radius,
  ) {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
  }

  /// 프레임 오버레이를 그립니다.
  static Future<void> _drawFrameOverlay(
    html.CanvasRenderingContext2D ctx,
    String frameType,
    int width,
    int height,
  ) async {
    // 기본적인 프레임 장식 그리기
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 4;

    switch (frameType) {
      case 'classic_4cut':
        // 클래식 4컷 프레임 장식
        ctx.strokeRect(20, 20, width - 40, height - 40);

        // 사진 구분선
        final positions = getPhotoPositions(frameType, width, height);
        for (int i = 1; i < positions.length; i++) {
          final prevPos = positions[i - 1];
          final currPos = positions[i];

          // 사진 간 구분선 그리기
          if (currPos.y > prevPos.y + prevPos.height + 5) {
            ctx.beginPath();
            ctx.moveTo(30, currPos.y - 10);
            ctx.lineTo(width - 30, currPos.y - 10);
            ctx.stroke();
          }
        }
        break;

      case 'grid_6cut':
        // 6컷 그리드 프레임 장식
        ctx.strokeRect(15, 15, width - 30, height - 30);

        // 세로 구분선
        ctx.beginPath();
        ctx.moveTo(width / 2, 25);
        ctx.lineTo(width / 2, height - 25);
        ctx.stroke();

        // 가로 구분선들
        final positions = getPhotoPositions(frameType, width, height);
        for (int i = 2; i < positions.length; i += 2) {
          final pos = positions[i];
          ctx.beginPath();
          ctx.moveTo(25, pos.y - 10);
          ctx.lineTo(width - 25, pos.y - 10);
          ctx.stroke();
        }
        break;
    }

    // 타이틀 텍스트 추가
    ctx.fillStyle = '#333333';
    ctx.font = 'bold 24px Arial, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText('📸 인생네컷 📸', width / 2, height - 30);
  }

  /// 프레임 타입에 따른 사진 배치 위치를 반환합니다.
  static List<PhotoPosition> getPhotoPositions(
      String frameType, int width, int height) {
    switch (frameType) {
      case 'classic_4cut':
        return _getClassic4CutPositions(width, height);
      case 'grid_6cut':
        return _getGrid6CutPositions(width, height);
      default:
        return _getClassic4CutPositions(width, height);
    }
  }

  /// 클래식 4컷 배치 위치
  static List<PhotoPosition> _getClassic4CutPositions(int width, int height) {
    const margin = 40.0;
    const spacing = 20.0;
    final photoWidth = width - (margin * 2);
    final availableHeight = height - (margin * 2) - 60; // 하단 텍스트 공간
    final photoHeight = (availableHeight - (spacing * 3)) / 4;

    return [
      PhotoPosition(
        x: margin,
        y: margin,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 8,
      ),
      PhotoPosition(
        x: margin,
        y: margin + photoHeight + spacing,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 8,
      ),
      PhotoPosition(
        x: margin,
        y: margin + (photoHeight + spacing) * 2,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 8,
      ),
      PhotoPosition(
        x: margin,
        y: margin + (photoHeight + spacing) * 3,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 8,
      ),
    ];
  }

  /// 6컷 그리드 배치 위치
  static List<PhotoPosition> _getGrid6CutPositions(int width, int height) {
    const margin = 30.0;
    const spacing = 15.0;
    final photoWidth = (width - (margin * 2) - spacing) / 2;
    final availableHeight = height - (margin * 2) - 60; // 하단 텍스트 공간
    final photoHeight = (availableHeight - (spacing * 2)) / 3;

    return [
      // 첫 번째 행
      PhotoPosition(
        x: margin,
        y: margin,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 6,
      ),
      PhotoPosition(
        x: margin + photoWidth + spacing,
        y: margin,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 6,
      ),
      // 두 번째 행
      PhotoPosition(
        x: margin,
        y: margin + photoHeight + spacing,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 6,
      ),
      PhotoPosition(
        x: margin + photoWidth + spacing,
        y: margin + photoHeight + spacing,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 6,
      ),
      // 세 번째 행
      PhotoPosition(
        x: margin,
        y: margin + (photoHeight + spacing) * 2,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 6,
      ),
      PhotoPosition(
        x: margin + photoWidth + spacing,
        y: margin + (photoHeight + spacing) * 2,
        width: photoWidth,
        height: photoHeight,
        borderRadius: 6,
      ),
    ];
  }

  /// 이미지를 다운로드합니다.
  static void downloadImage(Uint8List imageBytes, String filename) {
    try {
      final blob = html.Blob([imageBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.document.createElement('a') as html.AnchorElement;
      anchor.href = url;
      anchor.download = filename;
      anchor.click();

      html.Url.revokeObjectUrl(url);
      print('✅ 이미지 다운로드 시작: $filename');
    } catch (e) {
      print('❌ 이미지 다운로드 실패: $e');
    }
  }
}

/// 사진 배치 위치 정보
class PhotoPosition {
  final double x;
  final double y;
  final double width;
  final double height;
  final double borderRadius;

  const PhotoPosition({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.borderRadius = 0,
  });

  @override
  String toString() {
    return 'PhotoPosition(x: $x, y: $y, width: $width, height: $height, borderRadius: $borderRadius)';
  }
}
