//
//  Event+RecordFormat.swift
//  DeCalc
//

import Foundation

/// 記録の入力・表示の形式（桁数と単位）
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
  /// leadingUnitを差し込む桁数（recordの左からの桁数）
  var leadUnitPoint: Int? {
    switch self {
    case .Run(.eightHundredM), .Run(.thousandFiveHundredM): 1
    default: nil
    }
  }
  /// 単位をどこで区切るか
  var unitPoint: Int {
    switch self {
    case .Jump: 1
    case .Throw: 2
    case .Run(let event):
      switch event {
      case .eightHundredM, .thousandFiveHundredM: 3
      case .hundredM, .fourHundredM, .twoHundredM, .hundredMHurdles, .hundredTenMHurdles: 2
      }
    }
  }

  /// 入力用の数字列を、単位つきの表示用文字列に変換する
  /// ex. 1500m: "43050" → 4'30"50
  /// ex. 走幅跳: "650" → 6m50cm
  func formattedRecord(_ record: String) -> String {
    var result = ""
    for (offset, character) in record.enumerated() {
      result.append(character)
      if let leadUnit, let leadUnitPoint, offset + 1 == leadUnitPoint {
        result += leadUnit
      }
      if offset + 1 == unitPoint {
        result += centerUnit
      }
    }
    if let trailUnit {
      result += trailUnit
    }
    return result
  }
}
