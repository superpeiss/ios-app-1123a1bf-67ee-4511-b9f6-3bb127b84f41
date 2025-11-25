import Foundation

/// Application-specific errors
enum AppError: LocalizedError, Identifiable {
    case authenticationFailed(String)
    case networkError(Error)
    case fileNotFound
    case operationFailed(String)
    case permissionDenied
    case invalidOperation
    case providerNotConnected

    var id: String {
        errorDescription ?? "unknown"
    }

    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .fileNotFound:
            return "File not found"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        case .permissionDenied:
            return "Permission denied"
        case .invalidOperation:
            return "Invalid operation"
        case .providerNotConnected:
            return "Cloud provider not connected"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .authenticationFailed:
            return "Please check your credentials and try again."
        case .networkError:
            return "Please check your internet connection."
        case .fileNotFound:
            return "The file may have been moved or deleted."
        case .permissionDenied:
            return "Please grant necessary permissions."
        case .providerNotConnected:
            return "Please connect to the cloud provider first."
        default:
            return "Please try again."
        }
    }
}
