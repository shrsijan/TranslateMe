//
//  TranslateMeApp.swift
//  TranslateMe
//
//  Created by Sijan Shrestha on 3/24/26.
//

import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct TranslateMeApp: App {
    init() {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
