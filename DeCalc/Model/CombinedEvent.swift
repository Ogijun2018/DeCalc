//
//  CombinedEvent.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

import Foundation

/// 混成競技の情報を持つenum
enum CombinedEvent: Hashable, CaseIterable, CustomStringConvertible {
    /// 英語名（ローカライズキーの基準にもなる正規名）
    var description: String {
        switch self {
        case .decathlon: "Decathlon"
        case .heptathlon: "Heptathlon"
        case .tetrathlon: "Tetrathlon"
        case .octathlon: "Octathlon"
        }
    }
    /// ローカライズされた競技名
    var localizedName: String {
        switch self {
        case .decathlon: String(localized: "Decathlon")
        case .heptathlon: String(localized: "Heptathlon")
        case .tetrathlon: String(localized: "Tetrathlon")
        case .octathlon: String(localized: "Octathlon")
        }
    }
    var heroImagePath: String {
        switch self {
        case .decathlon: "ten_hero"
        case .heptathlon: "seven_hero"
        case .tetrathlon: "four_hero"
        case .octathlon: "eight_hero"
        }
    }

    static var allCases: [CombinedEvent] {
        return [
            .decathlon,
            .octathlon,
            .heptathlon,
            .tetrathlon(.Men),
            .tetrathlon(.Women)
        ]
    }

    static var menEvents: [CombinedEvent] {
        return [
            .decathlon,
            .octathlon,
            .tetrathlon(.Men)
        ]
    }
    static var womenEvents: [CombinedEvent] {
        return [
            .heptathlon,
            .tetrathlon(.Women)
        ]
    }

    /// 十種競技
    case decathlon
    /// 八種競技
    case octathlon
    /// 四種競技（男・女）
    case tetrathlon(Gender)
    /// 七種競技
    case heptathlon

    var events: [EventInfo] {
        switch self {
        case .decathlon: [
            .init(event: .Run(.hundredM)),
            .init(event: .Jump(.longjump(.Men))),
            .init(event: .Throw(.shotput(.Men))),
            .init(event: .Jump(.highjump(.Men))),
            .init(event: .Run(.fourHundredM)),
            .init(event: .Run(.hundredTenMHurdles)),
            .init(event: .Throw(.discusThrow)),
            .init(event: .Jump(.paulVault)),
            .init(event: .Throw(.javelinThrow(.Men))),
            .init(event: .Run(.thousandFiveHundredM))
            ]
        case .octathlon: [
            .init(event: .Run(.hundredM)),
            .init(event: .Jump(.longjump(.Men))),
            .init(event: .Throw(.shotput(.Men))),
            .init(event: .Run(.fourHundredM)),
            .init(event: .Run(.hundredTenMHurdles)),
            .init(event: .Throw(.javelinThrow(.Men))),
            .init(event: .Jump(.highjump(.Men))),
            .init(event: .Run(.thousandFiveHundredM))
        ]
        case .tetrathlon(.Men): [
            .init(event: .Run(.fourHundredM)),
            .init(event: .Run(.hundredTenMHurdles)),
            .init(event: .Jump(.highjump(.Men))),
            .init(event: .Throw(.shotput(.Men))),
        ]
        case .tetrathlon(.Women): [
            .init(event: .Run(.twoHundredM)),
            .init(event: .Run(.hundredMHurdles)),
            .init(event: .Jump(.highjump(.Women))),
            .init(event: .Throw(.shotput(.Women))),
        ]
        case .heptathlon: [
            .init(event: .Run(.hundredMHurdles)),
            .init(event: .Jump(.highjump(.Women))),
            .init(event: .Throw(.shotput(.Women))),
            .init(event: .Run(.twoHundredM)),
            .init(event: .Jump(.longjump(.Women))),
            .init(event: .Throw(.javelinThrow(.Women))),
            .init(event: .Run(.eightHundredM))
        ]}
    }
}
