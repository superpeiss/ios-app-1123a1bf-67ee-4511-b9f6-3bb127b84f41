import Foundation

/// Google Drive service implementation
class GoogleDriveService: CloudStorageService {
    let provider: CloudProviderType = .googleDrive
    private(set) var isAuthenticated: Bool = false

    private var mockFiles: [FileItem] = []

    init() {
        setupMockData()
    }

    private func setupMockData() {
        // Create mock folder structure
        mockFiles = [
            FileItem(
                id: "gdrive_root",
                name: "My Drive",
                isFolder: true,
                size: nil,
                modifiedDate: Date(),
                mimeType: "application/vnd.google-apps.folder",
                thumbnailURL: nil,
                downloadURL: nil,
                provider: .googleDrive,
                parentID: nil,
                path: "/"
            ),
            FileItem(
                id: "gdrive_docs",
                name: "Documents",
                isFolder: true,
                size: nil,
                modifiedDate: Date().addingTimeInterval(-86400),
                mimeType: "application/vnd.google-apps.folder",
                thumbnailURL: nil,
                downloadURL: nil,
                provider: .googleDrive,
                parentID: "gdrive_root",
                path: "/Documents"
            ),
            FileItem(
                id: "gdrive_photos",
                name: "Photos",
                isFolder: true,
                size: nil,
                modifiedDate: Date().addingTimeInterval(-172800),
                mimeType: "application/vnd.google-apps.folder",
                thumbnailURL: nil,
                downloadURL: nil,
                provider: .googleDrive,
                parentID: "gdrive_root",
                path: "/Photos"
            ),
            FileItem(
                id: "gdrive_file1",
                name: "Report.pdf",
                isFolder: false,
                size: 1024000,
                modifiedDate: Date().addingTimeInterval(-3600),
                mimeType: "application/pdf",
                thumbnailURL: nil,
                downloadURL: nil,
                provider: .googleDrive,
                parentID: "gdrive_docs",
                path: "/Documents/Report.pdf"
            ),
            FileItem(
                id: "gdrive_file2",
                name: "Vacation.jpg",
                isFolder: false,
                size: 2048000,
                modifiedDate: Date().addingTimeInterval(-7200),
                mimeType: "image/jpeg",
                thumbnailURL: nil,
                downloadURL: nil,
                provider: .googleDrive,
                parentID: "gdrive_photos",
                path: "/Photos/Vacation.jpg"
            )
        ]
    }

    func authenticate() async throws -> Bool {
        // Simulate authentication delay
        try await Task.sleep(nanoseconds: 500_000_000)
        isAuthenticated = true
        return true
    }

    func listFiles(in folderID: String?) async throws -> [FileItem] {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 300_000_000)

        let targetID = folderID ?? "gdrive_root"
        return mockFiles.filter { $0.parentID == targetID }
    }

    func downloadFile(_ file: FileItem) async throws -> Data {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        // Return mock data
        return "Mock file content for \(file.name)".data(using: .utf8) ?? Data()
    }

    func uploadFile(data: Data, name: String, to folderID: String?) async throws -> FileItem {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        let newFile = FileItem(
            id: "gdrive_\(UUID().uuidString)",
            name: name,
            isFolder: false,
            size: Int64(data.count),
            modifiedDate: Date(),
            mimeType: "application/octet-stream",
            thumbnailURL: nil,
            downloadURL: nil,
            provider: .googleDrive,
            parentID: folderID ?? "gdrive_root",
            path: "/\(name)"
        )

        mockFiles.append(newFile)
        return newFile
    }

    func createFolder(name: String, in folderID: String?) async throws -> FileItem {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 300_000_000)

        let newFolder = FileItem(
            id: "gdrive_\(UUID().uuidString)",
            name: name,
            isFolder: true,
            size: nil,
            modifiedDate: Date(),
            mimeType: "application/vnd.google-apps.folder",
            thumbnailURL: nil,
            downloadURL: nil,
            provider: .googleDrive,
            parentID: folderID ?? "gdrive_root",
            path: "/\(name)"
        )

        mockFiles.append(newFolder)
        return newFolder
    }

    func deleteFile(_ file: FileItem) async throws {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 300_000_000)
        mockFiles.removeAll { $0.id == file.id }
    }

    func renameFile(_ file: FileItem, newName: String) async throws -> FileItem {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 300_000_000)

        if let index = mockFiles.firstIndex(where: { $0.id == file.id }) {
            let updatedFile = FileItem(
                id: file.id,
                name: newName,
                isFolder: file.isFolder,
                size: file.size,
                modifiedDate: Date(),
                mimeType: file.mimeType,
                thumbnailURL: file.thumbnailURL,
                downloadURL: file.downloadURL,
                provider: file.provider,
                parentID: file.parentID,
                path: file.path
            )
            mockFiles[index] = updatedFile
            return updatedFile
        }

        throw AppError.fileNotFound
    }

    func moveFile(_ file: FileItem, to folderID: String) async throws -> FileItem {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 300_000_000)

        if let index = mockFiles.firstIndex(where: { $0.id == file.id }) {
            let updatedFile = FileItem(
                id: file.id,
                name: file.name,
                isFolder: file.isFolder,
                size: file.size,
                modifiedDate: Date(),
                mimeType: file.mimeType,
                thumbnailURL: file.thumbnailURL,
                downloadURL: file.downloadURL,
                provider: file.provider,
                parentID: folderID,
                path: file.path
            )
            mockFiles[index] = updatedFile
            return updatedFile
        }

        throw AppError.fileNotFound
    }

    func copyFile(_ file: FileItem, to folderID: String) async throws -> FileItem {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        let copiedFile = FileItem(
            id: "gdrive_\(UUID().uuidString)",
            name: file.name,
            isFolder: file.isFolder,
            size: file.size,
            modifiedDate: Date(),
            mimeType: file.mimeType,
            thumbnailURL: file.thumbnailURL,
            downloadURL: file.downloadURL,
            provider: .googleDrive,
            parentID: folderID,
            path: file.path
        )

        mockFiles.append(copiedFile)
        return copiedFile
    }

    func getFileMetadata(fileID: String) async throws -> FileItem {
        guard isAuthenticated else {
            throw AppError.providerNotConnected
        }

        try await Task.sleep(nanoseconds: 200_000_000)

        guard let file = mockFiles.first(where: { $0.id == fileID }) else {
            throw AppError.fileNotFound
        }

        return file
    }

    func disconnect() {
        isAuthenticated = false
    }
}
