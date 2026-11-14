//
//  TargetScoreStore.swift
//  DeCalc
//

import Foundation

/// 混成競技ごとの目標合計点を読み書きする
protocol TargetScoreStoring {
  /// 保存されている目標合計点（未設定の場合はnil）
  func target(for event: CombinedEvent) -> Int?
  /// 目標合計点を保存する（nilまたは0以下で削除）
  func setTarget(_ target: Int?, for event: CombinedEvent)
}

/// UserDefaults（端末内のみ）に目標合計点を保存するストア
struct TargetScoreStore: TargetScoreStoring {
  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func target(for event: CombinedEvent) -> Int? {
    let value = defaults.integer(forKey: key(for: event))
    return value > 0 ? value : nil
  }

  func setTarget(_ target: Int?, for event: CombinedEvent) {
    if let target, target > 0 {
      defaults.set(target, forKey: key(for: event))
    } else {
      defaults.removeObject(forKey: key(for: event))
    }
  }

  private func key(for event: CombinedEvent) -> String {
    "targetScore.\(event.storageKey)"
  }
}
