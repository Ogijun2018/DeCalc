//
//  Event+RecordFormat.swift
//  DeCalc
//

import Foundation

extension Event {
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
