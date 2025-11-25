import Foundation

/// Manages authentication for all cloud providers
class AuthenticationManager {
    static let shared = AuthenticationManager()

    private var services: [CloudProviderType: CloudStorageService] = [:]
    private let userDefaults = UserDefaults.standard
    private let connectedProvidersKey = "connected_providers"

    private init() {
        // Initialize all services
        services[.googleDrive] = GoogleDriveService()
        services[.dropbox] = DropboxService()
        services[.oneDrive] = OneDriveService()
    }

    func getService(for provider: CloudProviderType) -> CloudStorageService? {
        return services[provider]
    }

    func authenticate(provider: CloudProviderType) async throws -> CloudProvider {
        guard let service = services[provider] else {
            throw AppError.operationFailed("Service not found")
        }

        let success = try await service.authenticate()

        if success {
            let cloudProvider = CloudProvider(
                type: provider,
                isConnected: true,
                accountEmail: "user@example.com"
            )
            saveConnectedProvider(cloudProvider)
            return cloudProvider
        } else {
            throw AppError.authenticationFailed("Authentication failed")
        }
    }

    func disconnect(provider: CloudProvider) {
        if let service = services[provider.type] {
            service.disconnect()
        }
        removeConnectedProvider(provider)
    }

    func getConnectedProviders() -> [CloudProvider] {
        guard let data = userDefaults.data(forKey: connectedProvidersKey),
              let providers = try? JSONDecoder().decode([CloudProvider].self, from: data) else {
            return []
        }
        return providers
    }

    private func saveConnectedProvider(_ provider: CloudProvider) {
        var providers = getConnectedProviders()
        if !providers.contains(where: { $0.id == provider.id }) {
            providers.append(provider)
            if let data = try? JSONEncoder().encode(providers) {
                userDefaults.set(data, forKey: connectedProvidersKey)
            }
        }
    }

    private func removeConnectedProvider(_ provider: CloudProvider) {
        var providers = getConnectedProviders()
        providers.removeAll { $0.id == provider.id }
        if let data = try? JSONEncoder().encode(providers) {
            userDefaults.set(data, forKey: connectedProvidersKey)
        }
    }
}
