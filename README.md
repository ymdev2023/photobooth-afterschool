# Photo Booth App

This project is a Flutter-based photo booth application designed for exhibitions. It allows users to take photos, apply basic edits, select frames, and generate QR codes for downloading their photos and videos.

## Features

- **Photo Capture**: Users can take photos using the device's camera.
- **Photo Editing**: Basic editing functionalities such as cropping and applying filters.
- **Frame Selection**: Users can choose from various photo frames to enhance their captured images.
- **QR Code Generation**: After capturing a photo, users can download their images and videos via a generated QR code.

## Project Structure

```
photo_booth_app
├── lib
│   ├── main.dart                  # Entry point of the application
│   ├── screens
│   │   ├── home_screen.dart       # Main interface for users
│   │   ├── camera_screen.dart     # Camera interface for capturing photos
│   │   ├── frame_selection_screen.dart # Frame selection interface
│   │   └── result_screen.dart     # Displays captured photo and QR code
│   ├── widgets
│   │   ├── photo_frame_widget.dart # Renders selected photo frame
│   │   ├── photo_editor_widget.dart # Provides photo editing functionalities
│   │   └── qr_code_widget.dart    # Generates and displays QR code
│   ├── models
│   │   └── photo_model.dart       # Defines photo data structure
│   └── services
│       ├── camera_service.dart     # Handles camera functionalities
│       ├── photo_edit_service.dart  # Provides photo editing methods
│       └── qr_code_service.dart     # Generates QR codes
├── pubspec.yaml                   # Project configuration file
└── README.md                      # Project documentation
```

## Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd photo_booth_app
   ```

3. Install the dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run
   ```

## Usage Guidelines

- Launch the app to access the home screen.
- Navigate to the camera screen to take a photo.
- After capturing, select a frame and proceed to the result screen.
- Download your photo and video using the provided QR code.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.