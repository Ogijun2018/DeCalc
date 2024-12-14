//
//  Event.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

import Foundation

/// 種目の情報のenum
enum Event: CustomStringConvertible, Hashable {

    case Run(RunEvent)
    case Jump(JumpEvent)
    case Throw(ThrowEvent)

    var description: String {
        switch self {
        case .Run(let event): event.rawValue
        case .Jump(let event): event.description
        case .Throw(let event): event.description
        }
    }

    enum RunEvent: String {
        case hundredTenMHurdles = "110mH"
        case fourHundredM = "400m"
        case hundredM = "100m"
        case thousandFiveHundredM = "1500m"
        case hundredMHurdles = "100mH"
        case twoHundredM = "200m"
        case eightHundredM = "800m"
    }
    // Associated ValuesとrawValuesは同時に利用できない
    // ref: https://medium.com/@hdk2200/swift-enum-associatedvalues-and-rawvalues-error-29d2bc92b90a
    // CustomStringConvertibleを使用することで種目ごとのStringを取り出せるようにする
    enum JumpEvent: CustomStringConvertible, Hashable {
        /// 走幅跳
        case longjump(Gender)
        /// 走高跳
        case highjump(Gender)
        /// 棒高跳
        case paulVault

        var description: String {
            switch self {
            case .highjump: "High Jump"
            case .longjump: "Long Jump"
            case .paulVault: "Paul Vault"
            }
        }

    }
    enum ThrowEvent: CustomStringConvertible, Hashable {
        /// 砲丸投
        case shotput(Gender)
        /// やり投
        case javelinThrow(Gender)
        /// 円盤投
        case discusThrow

        var description: String {
            switch self {
            case .shotput: "Shot Put"
            case .javelinThrow: "Javelin Throw"
            case .discusThrow: "Discus Throw"
            }
        }
    }

    var firstCoefficient: Double {
        switch self {
        case .Run(let event):
            switch event {
            case .hundredTenMHurdles: return 5.74352
            case .fourHundredM: return 1.53775
            case .hundredM: return 25.4347
            case .thousandFiveHundredM: return 0.03768
            case .hundredMHurdles: return 9.23076
            case .twoHundredM: return 4.99087
            case .eightHundredM: return 0.11193
            }
        case .Jump(let event):
            switch event {
            case .longjump(let gender): return gender == .Men ? 0.14354 : 0.188807
            case .highjump(let gender): return gender == .Men ? 0.8465 : 1.84523
            case .paulVault: return 0.2797
            }
        case .Throw(let event):
            switch event {
            case .shotput(let gender): return gender == .Men ? 51.39 : 56.0211
            case .javelinThrow(let gender): return gender == .Men ? 10.14 : 15.9803
            case .discusThrow: return 12.91
            }
        }
    }

    var secondCoefficient: Double {
        switch self {
        case .Run(let event):
            switch event {
            case .hundredTenMHurdles: return 28.5
            case .fourHundredM: return 82
            case .hundredM: return 18
            case .thousandFiveHundredM: return 480
            case .hundredMHurdles: return 26.7
            case .twoHundredM: return 42.5
            case .eightHundredM: return 254
            }
        case .Jump(let event):
            switch event {
            case .longjump(let gender): return gender == .Men ? 220 : 210
            case .highjump: return 75
            case .paulVault: return 100
            }
        case .Throw(let event):
            switch event {
            case .shotput: return 1.5
            case .javelinThrow(let gender): return gender == .Men ? 7 : 3.8
            case .discusThrow: return 4
            }
        }
    }

    var thirdCoefficient: Double {
        switch self {
        case .Run(let event):
            switch event {
            case .hundredTenMHurdles: return 1.92
            case .fourHundredM: return 1.81
            case .hundredM: return 1.81
            case .thousandFiveHundredM: return 1.85
            case .hundredMHurdles: return 1.835
            case .twoHundredM: return 1.81
            case .eightHundredM: return 1.88
            }
        case .Jump(let event):
            switch event {
            case .longjump(let gender): return gender == .Men ? 1.4 : 1.41
            case .highjump(let gender): return gender == .Men ? 1.42 : 1.348
            case .paulVault: return 1.35
            }
        case .Throw(let event):
            switch event {
            case .shotput: return 1.05
            case .javelinThrow(let gender): return gender == .Men ? 1.08 : 1.04
            case .discusThrow: return 1.1
            }
        }
    }
}
