//
//  DeCalcApp.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

@main
struct DeCalcApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: .init())
        }
    }
}
