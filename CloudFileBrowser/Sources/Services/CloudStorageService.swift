import Foundation

/// Protocol for cloud storage service implementations
protocol CloudStorageService {
    var provider: CloudProviderType { get }
    var isAuthenticated: Bool { get }

    /// Authenticate with the cloud service
    func authenticate() async throws -> Bool

    /// List files in a directory
    func listFiles(in folderID: String?) async throws -> [FileItem]

    /// Download file data
    func downloadFile(_ file: FileItem) async throws -> Data

    /// Upload a file
    func uploadFile(data: Data, name: String, to folderID: String?) async throws -> FileItem

    /// Create a folder
    func createFolder(name: String, in folderID: String?) async throws -> FileItem

    /// Delete a file or folder
    func deleteFile(_ file: FileItem) async throws

    /// Rename a file or folder
    func renameFile(_ file: FileItem, newName: String) async throws -> FileItem

    /// Move a file or folder
    func moveFile(_ file: FileItem, to folderID: String) async throws -> FileItem

    /// Copy a file
    func copyFile(_ file: FileItem, to folderID: String) async throws -> FileItem

    /// Search files
    func searchFiles(query: String) async throws -> [FileItem]

    /// Get file metadata
    func getFileMetadata(fileID: String) async throws -> FileItem

    /// Disconnect/logout
    func disconnect()
}

/// Default implementations
extension CloudStorageService {
    func searchFiles(query: String) async throws -> [FileItem] {
        // Default implementation: list all files and filter
        let allFiles = try await listFiles(in: nil)
        return allFiles.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
