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

  /// 目標合計点（未設定の場合はnil）
  @Published private(set) var targetPoint: Int?
  private let targetStore: TargetScoreStoring

  /// 目標までの残り得点（目標が未設定の場合はnil、達成済みの場合は0）
  var remainingToTarget: Int? {
    targetPoint.map { max(0, $0 - combinedEventInfo.point) }
  }

  /// 目標点の行をタップしたとき
  func plannerButtonDidTap() {
    sheet = .Planner(combinedEventInfo)
  }

  /// シートが閉じられたとき、シート側で変更された内容を読み直す
  func sheetDidDismiss() {
    targetPoint = targetStore.target(for: combinedEventInfo.event)
    personalBest = sheetStore.personalBest(for: combinedEventInfo.event)
  }

  /// 自己ベストとの比較結果
  struct PersonalBestComparison {
    /// 自己ベストの得点
    let point: Int
    /// 現在の得点との差（現在の得点が未入力の場合はnil）
    let diff: Int?

    /// 符号つきの差分表示（ex. +12, −5, ±0）
    var diffText: String? {
      guard let diff else { return nil }
      if diff > 0 { return "+\(diff)" }
      if diff < 0 { return "−\(-diff)" }
      return "±0"
    }
  }

  /// 自己ベスト（保存した記録のうち合計点が最も高いもの）
  @Published private(set) var personalBest: SavedScoreSheet?
  /// 記録を保存するたびに増えるカウンタ（触覚フィードバックのトリガー）
  @Published private(set) var saveFeedbackTrigger = 0
  private let sheetStore: ScoreSheetStoring

  /// 保存できる得点があるか
  var canSave: Bool {
    combinedEventInfo.point > 0
  }

  /// 指定した種目の、自己ベストとの比較（自己ベストがない・その種目が未入力だった場合はnil）
  func personalBestComparison(at index: Int) -> PersonalBestComparison? {
    guard let personalBest,
          personalBest.entries.indices.contains(index),
          personalBest.entries[index].point > 0 else { return nil }
    let bestPoint = personalBest.entries[index].point
    let currentPoint = combinedEventInfo.events[index].point
    return PersonalBestComparison(
      point: bestPoint,
      diff: currentPoint > 0 ? currentPoint - bestPoint : nil
    )
  }

  /// 合計点の、自己ベストとの比較（差分は全種目を入力し終えたときだけ出す）
  var personalBestTotalComparison: PersonalBestComparison? {
    guard let personalBest else { return nil }
    let isComplete = combinedEventInfo.enteredCount == combinedEventInfo.events.count
    return PersonalBestComparison(
      point: personalBest.total,
      diff: isComplete ? combinedEventInfo.point - personalBest.total : nil
    )
  }

  /// 保存ダイアログで保存を確定したとき
  func saveButtonDidTap(name: String) {
    guard canSave else { return }
    sheetStore.save(SavedScoreSheet(info: combinedEventInfo, name: name))
    personalBest = sheetStore.personalBest(for: combinedEventInfo.event)
    saveFeedbackTrigger += 1
  }

  /// 保存した記録の一覧ボタンをタップしたとき
  func savedSheetsButtonDidTap() {
    sheet = .SavedSheets(combinedEventInfo.event)
  }

  /// シェアボタンをタップしたとき
  func shareButtonDidTap() {
    sheet = .Share(combinedEventInfo)
  }

  /// グラフボタンをタップしたとき
  func chartButtonDidTap() {
    sheet = .Chart(combinedEventInfo)
  }

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

  init(
    combinedEvent: CombinedEvent,
    targetStore: TargetScoreStoring = TargetScoreStore(),
    sheetStore: ScoreSheetStoring = ScoreSheetStore()
  ) {
    self.combinedEventInfo = .init(event: combinedEvent, events: combinedEvent.events)
    self.targetStore = targetStore
    self.targetPoint = targetStore.target(for: combinedEvent)
    self.sheetStore = sheetStore
    self.personalBest = sheetStore.personalBest(for: combinedEvent)
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
