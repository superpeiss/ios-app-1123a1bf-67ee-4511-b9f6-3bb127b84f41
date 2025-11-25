import Foundation

/// Represents a cloud storage provider
enum CloudProviderType: String, Codable, CaseIterable {
    case googleDrive = "Google Drive"
    case dropbox = "Dropbox"
    case oneDrive = "OneDrive"
    case iCloudDrive = "iCloud Drive"

    var iconName: String {
        switch self {
        case .googleDrive:
            return "square.grid.3x3.fill"
        case .dropbox:
            return "shippingbox.fill"
        case .oneDrive:
            return "cloud.fill"
        case .iCloudDrive:
            return "icloud.fill"
        }
    }

    var color: String {
        switch self {
        case .googleDrive:
            return "blue"
        case .dropbox:
            return "cyan"
        case .oneDrive:
            return "indigo"
        case .iCloudDrive:
            return "gray"
        }
    }
}

/// Cloud provider instance
struct CloudProvider: Identifiable, Codable {
    let id: String
    let type: CloudProviderType
    let displayName: String
    var isConnected: Bool
    var accountEmail: String?

    init(id: String = UUID().uuidString,
         type: CloudProviderType,
         displayName: String? = nil,
         isConnected: Bool = false,
         accountEmail: String? = nil) {
        self.id = id
        self.type = type
        self.displayName = displayName ?? type.rawValue
        self.isConnected = isConnected
        self.accountEmail = accountEmail
    }
}
