//
//  Social_MediaApp.swift
//  Social-Media
//
//  Created by KhaleD HuSsien on 12/01/2023.
//

import SwiftUI
import Firebase
@main
struct Social_MediaApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
