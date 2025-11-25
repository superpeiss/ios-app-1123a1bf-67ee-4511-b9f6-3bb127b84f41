import Foundation
import Combine

/// ViewModel for managing cloud providers
@MainActor
class ProvidersViewModel: ObservableObject {
    @Published var availableProviders: [CloudProviderType] = CloudProviderType.allCases
    @Published var isAuthenticating: Bool = false
    @Published var error: AppError?

    private let authManager = AuthenticationManager.shared

    func connectProvider(_ providerType: CloudProviderType, appState: AppState) async {
        isAuthenticating = true
        error = nil

        do {
            let provider = try await authManager.authenticate(provider: providerType)
            appState.addProvider(provider)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .authenticationFailed(error.localizedDescription)
        }

        isAuthenticating = false
    }

    func disconnectProvider(_ provider: CloudProvider, appState: AppState) {
        authManager.disconnect(provider: provider)
        appState.removeProvider(provider)
    }
}
