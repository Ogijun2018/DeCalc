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
  /// 「PBとして保存」した記録か（自己ベストの比較に使う）
  var isPersonalBest: Bool
  /// 「目標点として保存」した記録か（最も新しいものが目標になる）
  var isTarget: Bool

  /// 合計点
  var total: Int {
    entries.reduce(0) { $0 + $1.point }
  }

  init(
    info: CombinedEventInfo,
    name: String,
    isPersonalBest: Bool = false,
    isTarget: Bool = false,
    date: Date = .now
  ) {
    self.isPersonalBest = isPersonalBest
    self.isTarget = isTarget
    self.date = date
    self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    self.eventKey = info.event.storageKey
    self.entries = info.events.map { event in
      // 桁がすべて埋まっている記録だけを保存する
      let record = event.score.flatMap { $0.count == event.event.digit ? $0 : nil }
      return Entry(record: record, point: event.point)
    }
  }

  /// 「PB」「目標」の印がなかった頃に保存した記録も読めるようにする
  /// （以前と同じく自己ベストの比較に使い、目標にはしない）
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    date = try container.decode(Date.self, forKey: .date)
    name = try container.decode(String.self, forKey: .name)
    eventKey = try container.decode(String.self, forKey: .eventKey)
    entries = try container.decode([Entry].self, forKey: .entries)
    isPersonalBest = try container.decodeIfPresent(Bool.self, forKey: .isPersonalBest) ?? true
    isTarget = try container.decodeIfPresent(Bool.self, forKey: .isTarget) ?? false
  }
}

extension Collection where Element == SavedScoreSheet {
  /// 自己ベスト（「PBとして保存」した記録のうち、合計点が最も高いもの）
  var personalBest: SavedScoreSheet? {
    filter(\.isPersonalBest).max { $0.total < $1.total }
  }

  /// 目標（「目標点として保存」した記録のうち、最も新しいもの）
  var target: SavedScoreSheet? {
    filter(\.isTarget).max { $0.date < $1.date }
  }

  /// 種目ごとの自己ベスト得点（「PBとして保存」した記録の中でその種目の最高点。未入力の種目は0）
  /// 合計点の自己ベストとは別の試合の得点になることがある
  func bestEventPoints(eventCount: Int) -> [Int] {
    filter(\.isPersonalBest).reduce(into: Array(repeating: 0, count: eventCount)) { best, sheet in
      for (index, entry) in sheet.entries.enumerated() where best.indices.contains(index) {
        best[index] = Swift.max(best[index], entry.point)
      }
    }
  }
}
