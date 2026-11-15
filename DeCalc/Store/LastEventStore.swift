//
//  LastEventStore.swift
//  DeCalc
//

import Foundation

/// 最後に開いた混成競技を読み書きする
protocol LastEventStoring {
  /// 最後に開いた混成競技（まだ開いたことがない場合はnil）
  func lastEvent() -> CombinedEvent?
  /// 開いた混成競技を記録する
  func setLastEvent(_ event: CombinedEvent)
}

/// UserDefaults（端末内のみ）に最後に開いた混成競技を保存するストア
struct LastEventStore: LastEventStoring {
  private static let key = "lastOpenedEvent"
  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func lastEvent() -> CombinedEvent? {
    let storageKey = defaults.string(forKey: Self.key)
    return CombinedEvent.allCases.first { $0.storageKey == storageKey }
  }

  func setLastEvent(_ event: CombinedEvent) {
    defaults.set(event.storageKey, forKey: Self.key)
  }
}
