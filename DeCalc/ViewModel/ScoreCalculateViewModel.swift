//
//  ScoreCalculateViewModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/11/29.
//

import Foundation

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
    reloadPersonalBest()
  }

  /// 保存した記録から自己ベストを読み直す
  private func reloadPersonalBest() {
    let sheets = sheetStore.sheets(for: combinedEventInfo.event)
    personalBestTotal = sheets.personalBest?.total
    personalBestEventPoints = sheets.bestEventPoints(eventCount: combinedEventInfo.events.count)
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

  /// 合計点の自己ベスト（保存した記録のうち最も高い合計点。記録がない場合はnil）
  @Published private(set) var personalBestTotal: Int?
  /// 種目ごとの自己ベスト得点（保存した記録の中でその種目の最高点、未入力は0）
  @Published private(set) var personalBestEventPoints: [Int] = []
  /// 記録を保存するたびに増えるカウンタ（触覚フィードバックのトリガー）
  @Published private(set) var saveFeedbackTrigger = 0
  private let sheetStore: ScoreSheetStoring

  /// 保存できる得点があるか
  var canSave: Bool {
    combinedEventInfo.point > 0
  }

  /// 指定した種目の、その種目の自己ベストとの比較（保存した記録にその種目の得点がない場合はnil）
  func personalBestComparison(at index: Int) -> PersonalBestComparison? {
    guard personalBestEventPoints.indices.contains(index),
          personalBestEventPoints[index] > 0 else { return nil }
    let bestPoint = personalBestEventPoints[index]
    let currentPoint = combinedEventInfo.events[index].point
    return PersonalBestComparison(
      point: bestPoint,
      diff: currentPoint > 0 ? currentPoint - bestPoint : nil
    )
  }

  /// 合計点の、自己ベストとの比較（差分は全種目を入力し終えたときだけ出す）
  var personalBestTotalComparison: PersonalBestComparison? {
    guard let personalBestTotal else { return nil }
    let isComplete = combinedEventInfo.events.enteredCount == combinedEventInfo.events.count
    return PersonalBestComparison(
      point: personalBestTotal,
      diff: isComplete ? combinedEventInfo.point - personalBestTotal : nil
    )
  }

  /// 保存ダイアログで保存を確定したとき
  func saveButtonDidTap(name: String) {
    guard canSave else { return }
    sheetStore.save(SavedScoreSheet(info: combinedEventInfo, name: name))
    reloadPersonalBest()
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

  /// App StoreのアプリID
  private static let appStoreID = "6779939129"

  /// App Storeのレビュー投稿画面のURL
  var reviewURL: URL? {
    URL(string: "https://apps.apple.com/app/id\(Self.appStoreID)?action=write-review")
  }

  /// 記録のTextViewをタップしたときに
  func onPressRecordTextView(id: Int) {
  }

  /// 記録から得点が確定するたびに増えるカウンタ（触覚フィードバックのトリガー）
  @Published private(set) var scoreFeedbackTrigger = 0
  /// 逆算に失敗するたびに増えるカウンタ（触覚フィードバックのトリガー）
  @Published private(set) var errorFeedbackTrigger = 0

  /// 記録欄の入力が変わったとき
  /// 桁がそろえば得点を計算し、欠けたら記録から計算した得点が残らないよう消す
  func recordDidChange(index: Int, record: String?) {
    // 同じ値の書き戻しでは何もしない
    guard combinedEventInfo.events[index].score != record else { return }
    combinedEventInfo.events[index].score = record
    if (record ?? "").count >= combinedEventInfo.events[index].event.digit {
      scoreFilled(index: index)
    } else if combinedEventInfo.events[index].isPointFromRecord {
      combinedEventInfo.events[index].point = 0
      combinedEventInfo.events[index].isPointFromRecord = false
    }
  }

  /// 入力済みの記録から得点を計算する（計算できない記録は0点）
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

  /// 次に入力する、記録が未入力の種目のインデックス
  /// 指定した種目より後ろを優先し、なければ先頭から探す。すべて入力済みならnil
  func nextEmptyRecordIndex(after index: Int) -> Int? {
    let events = combinedEventInfo.events
    let isEmpty: (Int) -> Bool = { (events[$0].score ?? "").isEmpty }
    let later = events.indices.filter { $0 > index }
    let earlier = events.indices.filter { $0 < index }
    return later.first(where: isEmpty) ?? earlier.first(where: isEmpty)
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
    // ここからは入力された得点が基準になる
    combinedEventInfo.events[index].isPointFromRecord = false
    do {
      // 計算後の記録の桁数がdigitに満たない場合は0埋めする
      // ex. 100m 1100pt → 09"98
      combinedEventInfo.events[index].score = try String(
        format: "%0\(eventInfo.event.digit)d",
        eventInfo.convertToScore(point: eventInfo.point)
      )
      combinedEventInfo.events[index].errorText = nil
      // 表示する得点を、逆算した記録の実際の得点にそろえる
      scoreFilled(index: index)
    } catch EventInfo.CalculationError.overPoint {
      // 整数をそのまま埋め込むと「4,753」と桁区切りが入るため、文字列にしてから渡す
      showCalculationError(
        String(localized: "Please enter a score of \(String(eventInfo.maxPoint)) or less"),
        index: index
      )
    } catch {
      showCalculationError(String(localized: "Invalid input"), index: index)
    }
  }

  /// 得点から記録を逆算できなかったとき、エラーを表示して記録を空にする
  private func showCalculationError(_ message: String, index: Int) {
    combinedEventInfo.events[index].errorText = message
    combinedEventInfo.events[index].score = ""
    errorFeedbackTrigger += 1
  }

  /// 得点欄を手で編集したとき
  /// 手入力の得点は、記録を消しても連動して消さない
  func pointDidEdit(index: Int, point: Int) {
    // 同じ値の書き戻し（フォーカスの移動時など）は手入力として扱わない
    guard combinedEventInfo.events[index].point != point else { return }
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
    reloadPersonalBest()
  }
}
