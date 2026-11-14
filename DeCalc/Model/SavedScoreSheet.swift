//
//  SavedScoreSheet.swift
//  DeCalc
//

import Foundation

/// 端末内に保存した1試合分の記録と得点
struct SavedScoreSheet: Codable, Identifiable, Hashable {
  /// 1種目分の記録と得点
  struct Entry: Codable, Hashable {
    /// 入力用の数字列の記録（未入力の場合はnil）
    var record: String?
    /// 得点
    var point: Int
  }

  var id = UUID()
  /// 保存した日時
  var date: Date
  /// 任意でつけた名前（未入力の場合は空文字）
  var name: String
  /// 混成競技を識別するキー（`CombinedEvent.storageKey`）
  var eventKey: String
  /// 種目ごとの記録と得点（混成競技の種目順）
  var entries: [Entry]

  /// 合計点
  var total: Int {
    entries.reduce(0) { $0 + $1.point }
  }

  init(info: CombinedEventInfo, name: String, date: Date = .now) {
    self.date = date
    self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    self.eventKey = info.event.storageKey
    self.entries = info.events.map { event in
      // 桁がすべて埋まっている記録だけを保存する
      let record = event.score.flatMap { $0.count == event.event.digit ? $0 : nil }
      return Entry(record: record, point: event.point)
    }
  }
}

extension Collection where Element == SavedScoreSheet {
  /// 自己ベスト（合計点が最も高い記録）
  var personalBest: SavedScoreSheet? {
    self.max { $0.total < $1.total }
  }

  /// 種目ごとの自己ベスト得点（保存した記録の中でその種目の最高点。未入力の種目は0）
  /// 合計点の自己ベストとは別の試合の得点になることがある
  func bestEventPoints(eventCount: Int) -> [Int] {
    reduce(into: Array(repeating: 0, count: eventCount)) { best, sheet in
      for (index, entry) in sheet.entries.enumerated() where best.indices.contains(index) {
        best[index] = Swift.max(best[index], entry.point)
      }
    }
  }
}
