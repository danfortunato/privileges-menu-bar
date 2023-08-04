import SwiftUI

@main
struct PrivilegesMenuBar: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView().frame(width:.zero)
        }
    }
}
