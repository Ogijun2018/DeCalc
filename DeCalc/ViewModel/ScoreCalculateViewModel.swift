//
//  ScoreCalculateViewModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/11/29.
//

import SwiftUI

final class ScoreCalculateViewModel: ObservableObject {
  @Published var combinedEventInfo: CombinedEventInfo

  /// 記録のTextViewをタップしたときに
  func onPressRecordTextView(id: Int) {
  }

  func scoreFilled(index: Int) {
    let eventInfo = combinedEventInfo.events[index]
    let score = eventInfo.score
    guard let score, let intScore = Int(score) else { return }
    do {
      combinedEventInfo.events[index].point = try eventInfo.convertToPoint(score: intScore)
    } catch {
      combinedEventInfo.events[index].point = 0
    }
  }

  func calculateButtonDidTap(index: Int) {
    let eventInfo = combinedEventInfo.events[index]
    let point = eventInfo.point
    do {
      combinedEventInfo.events[index].errorText = ""
      // 計算後の記録の桁数がdigitに満たない場合は0埋めする
      // ex. 100m 1100pt → 09"98
      combinedEventInfo.events[index].score = try String(
        format: "%0\(eventInfo.event.digit)d",
        eventInfo.convertToScore(point: point)
      )
    } catch EventInfo.CalculationError.overPoint {
      combinedEventInfo.events[index].errorText = "ポイントは\(eventInfo.maxPoint)以下を入力してください"
      combinedEventInfo.events[index].score = ""
    } catch EventInfo.CalculationError.invalidResult {
      combinedEventInfo.events[index].errorText = "入力エラー"
      combinedEventInfo.events[index].score = ""
    } catch {
      combinedEventInfo.events[index].errorText = "入力エラー"
      combinedEventInfo.events[index].score = ""
    }
  }

  func didCompletePoint(index: Int, point: Int) {
    combinedEventInfo.events[index].point = point
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
