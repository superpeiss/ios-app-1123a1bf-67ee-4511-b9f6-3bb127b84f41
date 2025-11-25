import Foundation

/// Represents a file or folder in cloud storage
struct FileItem: Identifiable, Codable {
    let id: String
    let name: String
    let isFolder: Bool
    let size: Int64?
    let modifiedDate: Date?
    let mimeType: String?
    let thumbnailURL: URL?
    let downloadURL: URL?
    let provider: CloudProviderType
    let parentID: String?
    let path: String

    var formattedSize: String {
        guard let size = size, !isFolder else { return "-" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var formattedDate: String {
        guard let date = modifiedDate else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var fileExtension: String {
        (name as NSString).pathExtension.lowercased()
    }

    var isPreviewable: Bool {
        let previewableExtensions = ["jpg", "jpeg", "png", "gif", "pdf", "txt", "md"]
        return !isFolder && previewableExtensions.contains(fileExtension)
    }

    var iconName: String {
        if isFolder {
            return "folder.fill"
        }

        switch fileExtension {
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo.fill"
        case "pdf":
            return "doc.fill"
        case "txt", "md":
            return "doc.text.fill"
        case "zip", "rar", "7z":
            return "doc.zipper"
        case "mp4", "mov", "avi":
            return "video.fill"
        case "mp3", "wav", "m4a":
            return "music.note"
        default:
            return "doc"
        }
    }
}
