import Foundation
import Combine

/// Global application state
class AppState: ObservableObject {
    @Published var connectedProviders: [CloudProvider] = []
    @Published var currentError: AppError?
    @Published var isLoading: Bool = false

    private let authManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()

    init(authManager: AuthenticationManager = AuthenticationManager.shared) {
        self.authManager = authManager
        loadConnectedProviders()
    }

    func loadConnectedProviders() {
        connectedProviders = authManager.getConnectedProviders()
    }

    func addProvider(_ provider: CloudProvider) {
        if !connectedProviders.contains(where: { $0.id == provider.id }) {
            connectedProviders.append(provider)
        }
    }

    func removeProvider(_ provider: CloudProvider) {
        connectedProviders.removeAll { $0.id == provider.id }
        authManager.disconnect(provider: provider)
    }
}
