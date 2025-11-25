import SwiftUI

struct ProvidersListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProvidersViewModel()
    @State private var showingAddProvider = false

    var body: some View {
        List {
            Section {
                ForEach(appState.connectedProviders) { provider in
                    NavigationLink(destination: FileListView(provider: provider)) {
                        ProviderCell(provider: provider)
                    }
                }
            } header: {
                Text("Connected Storage")
            }

            Section {
                ForEach(viewModel.availableProviders.filter { type in
                    !appState.connectedProviders.contains { $0.type == type }
                }, id: \.self) { providerType in
                    Button {
                        Task {
                            await viewModel.connectProvider(providerType, appState: appState)
                        }
                    } label: {
                        HStack {
                            Image(systemName: providerType.iconName)
                                .foregroundColor(colorForProvider(providerType))
                            Text("Add \(providerType.rawValue)")
                        }
                    }
                }
            } header: {
                Text("Available Providers")
            }
        }
        .navigationTitle("Cloud Storage")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddProvider = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.isAuthenticating {
                ProgressView("Connecting...")
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.errorDescription ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func colorForProvider(_ type: CloudProviderType) -> Color {
        switch type {
        case .googleDrive:
            return .blue
        case .dropbox:
            return .cyan
        case .oneDrive:
            return .indigo
        case .iCloudDrive:
            return .gray
        }
    }
}

struct ProviderCell: View {
    let provider: CloudProvider

    var body: some View {
        HStack {
            Image(systemName: provider.type.iconName)
                .font(.title2)
                .foregroundColor(colorForProvider(provider.type))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(provider.displayName)
                    .font(.headline)

                if let email = provider.accountEmail {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func colorForProvider(_ type: CloudProviderType) -> Color {
        switch type {
        case .googleDrive:
            return .blue
        case .dropbox:
            return .cyan
        case .oneDrive:
            return .indigo
        case .iCloudDrive:
            return .gray
        }
    }
}

struct ProvidersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProvidersListView()
                .environmentObject(AppState())
        }
    }
}
