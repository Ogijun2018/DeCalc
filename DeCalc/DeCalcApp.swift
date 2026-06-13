//
//  DeCalcApp.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct DeCalcApp: App {
    init() {
        // セグメンテッドコントロールの文字を大きくして高さを確保する
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.font: UIFont.systemFont(ofSize: 18, weight: .semibold)],
            for: .normal
        )
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: .init())
        }
    }
}
