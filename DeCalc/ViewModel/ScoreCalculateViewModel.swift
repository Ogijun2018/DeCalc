//
//  ScoreCalculateViewModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/11/29.
//

import SwiftUI

final class ScoreCalculateViewModel: ObservableObject {
    @Published var combinedEventInfo: CombinedEventInfo

    func onPressCalcButton() {
        print("onPressCalcButton")
    }

    func didCompleteScore(index: Int, score: Int) {
        combinedEventInfo.events[index].score = score
    }

    init(combinedEvent: CombinedEvent) {
        self.combinedEventInfo = .init(event: combinedEvent, events: combinedEvent.events)
    }
}

extension Event {
    /// 記録入力時の桁数
    var digit: Int {
        switch self {
        case .Run(let event):
            switch event {
            case .eightHundredM, .thousandFiveHundredM: return 5
            case .hundredM, .fourHundredM, .twoHundredM, .hundredMHurdles, .hundredTenMHurdles: return 4
            }
        case .Jump: return 3
        case .Throw: return 4
        }
    }
    /// 単位1
    var leadUnit: String? {
        switch self {
        case .Run(.eightHundredM), .Run(.thousandFiveHundredM): "'"
        default: nil
        }
    }
    /// 単位2
    var centerUnit: String {
        switch self {
        case .Run: "\""
        case .Jump, .Throw: "m"
        }
    }
    /// 単位3
    var trailUnit: String? {
        switch self {
        case .Run: nil
        case .Jump, .Throw: "cm"
        }
    }
    /// 単位をどこで区切るか
    var unitPoint: Int {
        switch self {
        case .Jump: 1
        case .Throw: 2
        case .Run(let event):
            switch event {
            /// 一時的に2にしているが、800m/1500mのみ間に2つ挟まるため単純なIntでは表現できていない
            case .eightHundredM, .thousandFiveHundredM: 2
            case .hundredM, .fourHundredM, .twoHundredM, .hundredMHurdles, .hundredTenMHurdles: 2
            }
        }
    }
}
