import SwiftUI

@main
struct LinkGeneratorApp: App {

    var body: some Scene {
        WindowGroup {
#if os(iOS)
            MainScreenView()
#else
            MacOSContentView()
#endif
        }
    }
}
