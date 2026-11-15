//
//  SaveScoresViewModel.swift
//  DeCalc
//

import Foundation

/// 記録の保存画面のViewModel
final class SaveScoresViewModel: ObservableObject {
  /// 任意でつける名前
  @Published var name = ""
  /// 自己ベストの比較に使う記録として保存するか
  @Published var isPersonalBest = true
  /// 目標として保存するか
  @Published var isTarget = false
  /// 保存するたびに増えるカウンタ（触覚フィードバックのトリガー）
  @Published private(set) var saveFeedbackTrigger = 0

  private let combinedEventInfo: CombinedEventInfo
  private let store: ScoreSheetStoring

  init(combinedEventInfo: CombinedEventInfo, store: ScoreSheetStoring = ScoreSheetStore()) {
    self.combinedEventInfo = combinedEventInfo
    self.store = store
  }

  /// 保存ボタンをタップしたとき
  func saveButtonDidTap() {
    store.save(SavedScoreSheet(
      info: combinedEventInfo,
      name: name,
      isPersonalBest: isPersonalBest,
      isTarget: isTarget
    ))
    saveFeedbackTrigger += 1
  }
}
