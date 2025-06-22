#!/usr/bin/env python3
"""
포토부스 프레임 이미지 생성 스크립트
"""

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("PIL(Pillow)이 설치되어 있지 않습니다. 다음 명령어로 설치하세요:")
    print("pip install Pillow")
    exit(1)

import os


def create_frame_image(name, cuts, frame_color, border_color):
    """프레임 이미지 생성"""
    # 이미지 크기 설정 (세로로 긴 포토부스 스타일)
    width = 400
    height = 600

    # 새 이미지 생성 (투명 배경)
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 외부 테두리
    border_width = 20
    draw.rectangle([0, 0, width, height], fill=border_color, outline=None)

    # 내부 배경
    inner_margin = border_width
    draw.rectangle([inner_margin, inner_margin, width-inner_margin, height-inner_margin],
                   fill=frame_color, outline=None)

    # 사진 영역들 (투명하게 만들기)
    photo_margin = 30
    photo_spacing = 15
    photo_width = width - (2 * photo_margin)
    photo_height = (height - (2 * photo_margin) -
                    (cuts - 1) * photo_spacing) // cuts

    for i in range(cuts):
        y = photo_margin + i * (photo_height + photo_spacing)
        # 사진이 들어갈 부분을 투명하게 만들기
        draw.rectangle([photo_margin, y, photo_margin + photo_width, y + photo_height],
                       fill=(255, 255, 255, 100), outline=(200, 200, 200, 150), width=2)

        # 작은 원형 표시
        icon_size = 20
        icon_x = photo_margin + photo_width // 2 - icon_size // 2
        icon_y = y + photo_height // 2 - icon_size // 2
        draw.ellipse([icon_x, icon_y, icon_x + icon_size, icon_y + icon_size],
                     fill=(200, 200, 200, 150))

    return img


def main():
    frames_dir = "assets/frames"

    # 프레임 정의
    frames = [
        {
            'name': 'classic_4cut',
            'display_name': 'Classic',
            'cuts': 4,
            'frame_color': (255, 255, 255, 255),  # 흰색
            'border_color': (180, 180, 180, 255),  # 회색
        },
        {
            'name': 'romantic_6cut',
            'display_name': 'Romantic',
            'cuts': 6,
            'frame_color': (255, 240, 245, 255),  # 연핑크
            'border_color': (255, 182, 193, 255),  # 핑크
        },
        {
            'name': 'vintage_4cut',
            'display_name': 'Vintage',
            'cuts': 4,
            'frame_color': (255, 248, 220, 255),  # 크림색
            'border_color': (139, 69, 19, 255),   # 갈색
        },
        {
            'name': 'modern_6cut',
            'display_name': 'Modern',
            'cuts': 6,
            'frame_color': (245, 245, 245, 255),  # 연회색
            'border_color': (64, 64, 64, 255),    # 진회색
        }
    ]

    # 프레임 이미지들 생성
    for frame in frames:
        img = create_frame_image(
            frame['display_name'],
            frame['cuts'],
            frame['frame_color'],
            frame['border_color']
        )

        output_path = os.path.join(frames_dir, f"{frame['name']}.png")
        img.save(output_path, "PNG")
        print(f"Generated: {output_path}")


if __name__ == "__main__":
    main()
