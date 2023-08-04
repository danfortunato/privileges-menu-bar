import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    var cli = URL(
        fileURLWithPath:"Applications/Privileges.app/Contents/Resources/PrivilegesCLI",
        relativeTo: FileManager.default.homeDirectoryForCurrentUser
    )
    var args: [String]!
    var icon: String!
    var statusItem: NSStatusItem!
    var statusMenu: NSMenu!

    func isAdmin() -> Bool {
        let outputPipe = Pipe()
        let task = Process()
        task.executableURL = self.cli
        task.arguments = ["--status"]
        task.standardOutput = nil
        task.standardError  = outputPipe
        try! task.run()
        task.waitUntilExit()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let tokens = output.components(separatedBy: " ")
        return (tokens[3] == "admin")
    }
    
    @objc func refresh() {
        if ( isAdmin() ) {
            self.icon = "lock.open.fill"
            self.args = ["--remove"]
        } else {
            self.icon = "lock.fill"
            self.args = ["--add"]
        }
        self.statusItem.button?.image = NSImage(
            systemSymbolName: self.icon,
            accessibilityDescription: "Privileges"
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let statusBar = NSStatusBar.system
        self.statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        self.refresh()
        
        self.statusItem.button?.action = #selector(self.statusBarButtonClicked(sender:))
        self.statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        self.statusMenu = NSMenu()
        self.statusMenu.addItem(
            withTitle: "Refresh",
            action: #selector(self.refresh),
            keyEquivalent: ""
        )
        self.statusMenu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: ""
        )
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type ==  NSEvent.EventType.rightMouseUp {
            self.statusItem.menu = self.statusMenu
            self.statusItem.button?.performClick(nil)
            self.statusItem.menu = nil
        } else {
            let task = Process()
            task.executableURL = self.cli
            task.arguments = self.args
            task.standardOutput = nil
            task.standardError = nil
            try! task.run()
            task.waitUntilExit()
            self.refresh()
        }
    }
}
