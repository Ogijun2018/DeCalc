//
//  PlannerViewModel.swift
//  DeCalc
//

import Foundation

/// 目標点プランナー画面のViewModel
final class PlannerViewModel: ObservableObject {
  /// 目標合計点の最大桁数
  private static let maxLength = 5

  /// 目標合計点（未設定の場合はnil）
  @Published private(set) var target: Int?

  /// プランナーを開いた時点の記録・得点
  let combinedEventInfo: CombinedEventInfo
  private let store: TargetScoreStoring

  /// 入力欄に表示する文字列
  var targetText: String {
    target.map { String($0) } ?? ""
  }

  /// 目標に対する現在の状況（目標が未設定の場合はnil）
  var plan: TargetPlan? {
    target.map { TargetPlan(info: combinedEventInfo, target: $0) }
  }

  init(combinedEventInfo: CombinedEventInfo, store: TargetScoreStoring = TargetScoreStore()) {
    self.combinedEventInfo = combinedEventInfo
    self.store = store
    self.target = store.target(for: combinedEventInfo.event)
  }

  /// 目標合計点の入力が変わったとき
  func targetTextDidChange(_ text: String) {
    let value = Int(text.filter(\.isNumber).prefix(Self.maxLength)) ?? 0
    target = value > 0 ? value : nil
    store.setTarget(target, for: combinedEventInfo.event)
  }

  /// 目標をクリアするボタンをタップしたとき
  func clearButtonDidTap() {
    target = nil
    store.setTarget(nil, for: combinedEventInfo.event)
  }
}
