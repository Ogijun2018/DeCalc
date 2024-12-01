//
//  DecathlonViewModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/11/29.
//

import SwiftUI

class DecathlonViewModel: ObservableObject {
    @Published var score = 0

    func onPressCalcButton() {
        score += 1
    }
}
