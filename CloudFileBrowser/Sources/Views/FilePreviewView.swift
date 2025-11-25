import SwiftUI

struct FilePreviewView: View {
    let file: FileItem
    @ObservedObject var viewModel: FileListViewModel
    @State private var fileData: Data?
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("Loading preview...")
                } else if let data = fileData {
                    ScrollView {
                        VStack {
                            if isImage {
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            } else if isPDF {
                                // For PDF, show basic info
                                VStack(spacing: 20) {
                                    Image(systemName: "doc.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.red)

                                    Text(file.name)
                                        .font(.headline)

                                    Text("PDF Preview")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Text(file.formattedSize)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            } else if isText {
                                if let text = String(data: data, encoding: .utf8) {
                                    Text(text)
                                        .font(.system(.body, design: .monospaced))
                                        .padding()
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)

                        Text("Unable to load preview")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadPreview()
        }
    }

    private var isImage: Bool {
        ["jpg", "jpeg", "png", "gif", "heic"].contains(file.fileExtension)
    }

    private var isPDF: Bool {
        file.fileExtension == "pdf"
    }

    private var isText: Bool {
        ["txt", "md"].contains(file.fileExtension)
    }

    private func loadPreview() async {
        isLoading = true
        fileData = await viewModel.downloadFile(file)
        isLoading = false
    }
}

struct FilePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        FilePreviewView(
            file: FileItem(
                id: "1",
                name: "test.jpg",
                isFolder: false,
                size: 1024,
                modifiedDate: Date(),
                mimeType: "image/jpeg",
                thumbnailURL: nil,
                downloadURL: nil,
                provider: .googleDrive,
                parentID: nil,
                path: "/test.jpg"
            ),
            viewModel: FileListViewModel(provider: CloudProvider(type: .googleDrive, isConnected: true))
        )
    }
}
