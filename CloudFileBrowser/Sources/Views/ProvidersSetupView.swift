import SwiftUI

struct ProvidersSetupView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProvidersViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.top, 60)

            Text("Connect Your Cloud Storage")
                .font(.title)
                .fontWeight(.bold)

            Text("Add one or more cloud storage providers to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.availableProviders, id: \.self) { providerType in
                        ProviderRow(providerType: providerType) {
                            Task {
                                await viewModel.connectProvider(providerType, appState: appState)
                            }
                        }
                    }
                }
                .padding()
            }

            Spacer()
        }
        .navigationTitle("Setup")
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
}

struct ProviderRow: View {
    let providerType: CloudProviderType
    let onConnect: () -> Void

    var body: some View {
        Button(action: onConnect) {
            HStack {
                Image(systemName: providerType.iconName)
                    .font(.title2)
                    .foregroundColor(colorForProvider(providerType))
                    .frame(width: 40)

                VStack(alignment: .leading) {
                    Text(providerType.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Tap to connect")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
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

struct ProvidersSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProvidersSetupView()
            .environmentObject(AppState())
    }
}
