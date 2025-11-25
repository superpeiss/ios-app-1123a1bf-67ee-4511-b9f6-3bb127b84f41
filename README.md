# CloudFileBrowser

A unified file browser app for iOS that integrates with multiple cloud storage providers.

## Features

- **Multi-Provider Support**: Connect to Google Drive, Dropbox, OneDrive, and iCloud Drive
- **Unified Interface**: Browse all your cloud files in one place
- **File Preview**: Preview images, PDFs, and text files directly in the app
- **File Operations**: Move, copy, rename, and delete files across different cloud services
- **Search**: Find files quickly across all connected providers
- **MVVM Architecture**: Clean separation of concerns with SwiftUI and Combine

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: Data structures for cloud providers, files, and errors
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management
- **Services**: Cloud storage service implementations with protocol-based architecture

## Project Structure

```
CloudFileBrowser/
├── Sources/
│   ├── App/                    # App entry point and global state
│   ├── Models/                 # Data models
│   ├── Views/                  # SwiftUI views
│   ├── ViewModels/             # View models
│   └── Services/               # Cloud storage service implementations
├── Resources/                  # Assets and resources
└── Preview Content/            # Preview assets for SwiftUI
```

## Building

This project uses a manually created Xcode project file. To build:

1. Open `CloudFileBrowser.xcodeproj` in Xcode
2. Select a simulator or device
3. Press Cmd+B to build or Cmd+R to run

## Testing

The project includes unit tests for core functionality. Run tests with Cmd+U in Xcode.

## License

MIT License
