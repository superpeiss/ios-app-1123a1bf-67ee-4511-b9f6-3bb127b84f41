import Foundation
import Combine

/// ViewModel for file browsing
@MainActor
class FileListViewModel: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var isLoading: Bool = false
    @Published var error: AppError?
    @Published var currentFolder: FileItem?
    @Published var searchQuery: String = ""

    private let provider: CloudProvider
    private let service: CloudStorageService
    private var cancellables = Set<AnyCancellable>()

    init(provider: CloudProvider) {
        self.provider = provider

        guard let service = AuthenticationManager.shared.getService(for: provider.type) else {
            fatalError("Service not found for provider: \(provider.type)")
        }
        self.service = service

        setupSearchDebounce()
    }

    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    Task {
                        await self?.searchFiles(query: query)
                    }
                } else if self?.currentFolder != nil {
                    Task {
                        await self?.loadFiles(in: self?.currentFolder?.id)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func loadFiles(in folderID: String? = nil) async {
        isLoading = true
        error = nil

        do {
            files = try await service.listFiles(in: folderID)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func searchFiles(query: String) async {
        isLoading = true
        error = nil

        do {
            files = try await service.searchFiles(query: query)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func navigateToFolder(_ folder: FileItem) async {
        guard folder.isFolder else { return }
        currentFolder = folder
        await loadFiles(in: folder.id)
    }

    func navigateBack() async {
        currentFolder = nil
        await loadFiles(in: nil)
    }

    func deleteFile(_ file: FileItem) async {
        isLoading = true
        error = nil

        do {
            try await service.deleteFile(file)
            files.removeAll { $0.id == file.id }
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func renameFile(_ file: FileItem, newName: String) async {
        isLoading = true
        error = nil

        do {
            let updatedFile = try await service.renameFile(file, newName: newName)
            if let index = files.firstIndex(where: { $0.id == file.id }) {
                files[index] = updatedFile
            }
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func createFolder(name: String) async {
        isLoading = true
        error = nil

        do {
            let newFolder = try await service.createFolder(name: name, in: currentFolder?.id)
            files.append(newFolder)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func moveFile(_ file: FileItem, to destination: FileItem) async {
        guard destination.isFolder else {
            error = .invalidOperation
            return
        }

        isLoading = true
        error = nil

        do {
            _ = try await service.moveFile(file, to: destination.id)
            files.removeAll { $0.id == file.id }
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func copyFile(_ file: FileItem, to destination: FileItem) async {
        guard destination.isFolder else {
            error = .invalidOperation
            return
        }

        isLoading = true
        error = nil

        do {
            let copiedFile = try await service.copyFile(file, to: destination.id)
            if currentFolder?.id == destination.id {
                files.append(copiedFile)
            }
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
    }

    func downloadFile(_ file: FileItem) async -> Data? {
        isLoading = true
        error = nil

        do {
            let data = try await service.downloadFile(file)
            isLoading = false
            return data
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .networkError(error)
        }

        isLoading = false
        return nil
    }
}
