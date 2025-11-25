import SwiftUI

struct FileListView: View {
    let provider: CloudProvider
    @StateObject private var viewModel: FileListViewModel
    @State private var showingNewFolder = false
    @State private var newFolderName = ""
    @State private var selectedFile: FileItem?
    @State private var showingFileActions = false
    @State private var showingRename = false
    @State private var renameText = ""

    init(provider: CloudProvider) {
        self.provider = provider
        _viewModel = StateObject(wrappedValue: FileListViewModel(provider: provider))
    }

    var body: some View {
        ZStack {
            if viewModel.files.isEmpty && !viewModel.isLoading {
                VStack(spacing: 20) {
                    Image(systemName: "folder")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("No Files")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("This folder is empty")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(viewModel.files) { file in
                        Button {
                            handleFileTap(file)
                        } label: {
                            FileRow(file: file)
                        }
                        .contextMenu {
                            fileContextMenu(for: file)
                        }
                    }
                }
                .searchable(text: $viewModel.searchQuery, prompt: "Search files")
            }
        }
        .navigationTitle(viewModel.currentFolder?.name ?? provider.displayName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingNewFolder = true
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }

                    Button {
                        Task {
                            await viewModel.loadFiles(in: viewModel.currentFolder?.id)
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.errorDescription ?? "Unknown error"),
                primaryButton: .default(Text("Retry")) {
                    Task {
                        await viewModel.loadFiles(in: viewModel.currentFolder?.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingNewFolder) {
            NewFolderSheet(
                folderName: $newFolderName,
                onCreate: {
                    Task {
                        await viewModel.createFolder(name: newFolderName)
                        newFolderName = ""
                        showingNewFolder = false
                    }
                }
            )
        }
        .sheet(isPresented: $showingRename) {
            RenameSheet(
                currentName: selectedFile?.name ?? "",
                newName: $renameText,
                onRename: {
                    if let file = selectedFile {
                        Task {
                            await viewModel.renameFile(file, newName: renameText)
                            showingRename = false
                        }
                    }
                }
            )
        }
        .sheet(item: $selectedFile) { file in
            if file.isPreviewable {
                FilePreviewView(file: file, viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadFiles(in: viewModel.currentFolder?.id)
        }
    }

    private func handleFileTap(_ file: FileItem) {
        if file.isFolder {
            Task {
                await viewModel.navigateToFolder(file)
            }
        } else if file.isPreviewable {
            selectedFile = file
        }
    }

    @ViewBuilder
    private func fileContextMenu(for file: FileItem) -> some View {
        Button {
            renameText = file.name
            selectedFile = file
            showingRename = true
        } label: {
            Label("Rename", systemImage: "pencil")
        }

        Button(role: .destructive) {
            Task {
                await viewModel.deleteFile(file)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

struct FileRow: View {
    let file: FileItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.iconName)
                .font(.title2)
                .foregroundColor(file.isFolder ? .blue : .secondary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.body)
                    .foregroundColor(.primary)

                HStack {
                    if !file.isFolder {
                        Text(file.formattedSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(file.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if file.isFolder {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewFolderSheet: View {
    @Binding var folderName: String
    let onCreate: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Folder Name", text: $folderName)
                } header: {
                    Text("New Folder")
                }
            }
            .navigationTitle("Create Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate()
                    }
                    .disabled(folderName.isEmpty)
                }
            }
        }
    }
}

struct RenameSheet: View {
    let currentName: String
    @Binding var newName: String
    let onRename: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $newName)
                } header: {
                    Text("Rename")
                } footer: {
                    Text("Current name: \(currentName)")
                }
            }
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Rename") {
                        onRename()
                    }
                    .disabled(newName.isEmpty)
                }
            }
        }
        .onAppear {
            if newName.isEmpty {
                newName = currentName
            }
        }
    }
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FileListView(provider: CloudProvider(type: .googleDrive, isConnected: true))
        }
    }
}
