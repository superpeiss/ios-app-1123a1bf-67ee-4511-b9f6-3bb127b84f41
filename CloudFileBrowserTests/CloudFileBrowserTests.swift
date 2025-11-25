import XCTest
@testable import CloudFileBrowser

final class CloudFileBrowserTests: XCTestCase {
    func testCloudProviderCreation() {
        let provider = CloudProvider(type: .googleDrive, isConnected: true)
        XCTAssertEqual(provider.type, .googleDrive)
        XCTAssertTrue(provider.isConnected)
    }

    func testFileItemCreation() {
        let file = FileItem(
            id: "test1",
            name: "test.pdf",
            isFolder: false,
            size: 1024,
            modifiedDate: Date(),
            mimeType: "application/pdf",
            thumbnailURL: nil,
            downloadURL: nil,
            provider: .googleDrive,
            parentID: nil,
            path: "/test.pdf"
        )

        XCTAssertEqual(file.name, "test.pdf")
        XCTAssertFalse(file.isFolder)
        XCTAssertEqual(file.fileExtension, "pdf")
        XCTAssertTrue(file.isPreviewable)
    }

    func testAuthenticationManager() {
        let authManager = AuthenticationManager.shared
        XCTAssertNotNil(authManager.getService(for: .googleDrive))
        XCTAssertNotNil(authManager.getService(for: .dropbox))
        XCTAssertNotNil(authManager.getService(for: .oneDrive))
    }
}
