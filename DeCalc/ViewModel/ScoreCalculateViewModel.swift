//
//  ScoreCalculateViewModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/11/29.
//

import SwiftUI

final class ScoreCalculateViewModel: ObservableObject {
  @Published var combinedEventInfo: CombinedEventInfo
  /// シートとして表示する画面（nilの場合は非表示）
  @Published var sheet: Router?

  /// ヘルプボタンをタップしたとき
  func helpButtonDidTap() {
    sheet = .Help(combinedEventInfo.event)
  }

  /// 記録のTextViewをタップしたときに
  func onPressRecordTextView(id: Int) {
  }

  /// 記録から得点が確定するたびに増えるカウンタ（触覚フィードバックのトリガー）
  @Published private(set) var scoreFeedbackTrigger = 0
  /// 逆算に失敗するたびに増えるカウンタ（触覚フィードバックのトリガー）
  @Published private(set) var errorFeedbackTrigger = 0

  func scoreFilled(index: Int) {
    let eventInfo = combinedEventInfo.events[index]
    let score = eventInfo.score
    guard let score, let intScore = Int(score) else { return }
    do {
      let point = try eventInfo.convertToPoint(score: intScore)
      combinedEventInfo.events[index].point = point
      if point > 0 {
        scoreFeedbackTrigger += 1
      }
    } catch {
      combinedEventInfo.events[index].point = 0
    }
    combinedEventInfo.events[index].isPointFromRecord = true
  }

  /// 記録が桁数に満たなくなったとき、記録から計算した得点が残らないよう消す
  func recordBecameIncomplete(index: Int) {
    guard combinedEventInfo.events[index].isPointFromRecord else { return }
    combinedEventInfo.events[index].point = 0
    combinedEventInfo.events[index].isPointFromRecord = false
  }

  /// 指定した種目より後ろにある、記録が未入力の最初の種目のインデックス
  func nextEmptyRecordIndex(after index: Int) -> Int? {
    let events = combinedEventInfo.events
    guard index + 1 < events.count else { return nil }
    return events.indices[(index + 1)...].first { (events[$0].score ?? "").isEmpty }
  }

  /// 最後の種目かどうか
  func isLastEvent(index: Int) -> Bool {
    index == combinedEventInfo.events.count - 1
  }

  /// フォーカスID（記録欄・得点欄のどちらでも）から種目のインデックスを求める
  func eventIndex(forFocusID id: Int) -> Int? {
    combinedEventInfo.events.firstIndex {
      $0.id.hashValue == id || $0.idForScore.hashValue == id
    }
  }

  /// 前後の種目のインデックス（範囲外の場合はnil）
  func neighborIndex(of index: Int, offset: Int) -> Int? {
    let target = index + offset
    return combinedEventInfo.events.indices.contains(target) ? target : nil
  }

  func calculateButtonDidTap(index: Int) {
    let eventInfo = combinedEventInfo.events[index]
    let point = eventInfo.point
    // ここからは入力された得点が基準になる
    combinedEventInfo.events[index].isPointFromRecord = false
    do {
      combinedEventInfo.events[index].errorText = nil
      // 計算後の記録の桁数がdigitに満たない場合は0埋めする
      // ex. 100m 1100pt → 09"98
      combinedEventInfo.events[index].score = try String(
        format: "%0\(eventInfo.event.digit)d",
        eventInfo.convertToScore(point: point)
      )
    } catch EventInfo.CalculationError.overPoint {
      combinedEventInfo.events[index].errorText = String(localized: "Please enter a score of \(eventInfo.maxPoint) or less")
      combinedEventInfo.events[index].score = ""
      errorFeedbackTrigger += 1
    } catch EventInfo.CalculationError.invalidResult {
      combinedEventInfo.events[index].errorText = String(localized: "Invalid input")
      combinedEventInfo.events[index].score = ""
      errorFeedbackTrigger += 1
    } catch {
      combinedEventInfo.events[index].errorText = String(localized: "Invalid input")
      combinedEventInfo.events[index].score = ""
      errorFeedbackTrigger += 1
    }
  }

  func didCompletePoint(index: Int, point: Int) {
    combinedEventInfo.events[index].point = point
  }

  /// 得点欄を手で編集したとき
  /// 手入力の得点は、記録を消しても連動して消さない
  func pointDidEdit(index: Int, point: Int) {
    combinedEventInfo.events[index].point = point
    combinedEventInfo.events[index].isPointFromRecord = false
  }

  func didTapDeleteButton() {
    for index in combinedEventInfo.events.indices {
      combinedEventInfo.events[index].score = nil
      combinedEventInfo.events[index].point = 0
      combinedEventInfo.events[index].errorText = nil
      combinedEventInfo.events[index].isPointFromRecord = false
    }
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
}
