//
//  ScoreSheetStore.swift
//  DeCalc
//

import Foundation

/// 保存した記録を読み書きする
protocol ScoreSheetStoring {
  /// 指定した混成競技の保存済み記録（新しい順）
  func sheets(for event: CombinedEvent) -> [SavedScoreSheet]
  /// 記録を保存する
  func save(_ sheet: SavedScoreSheet)
  /// 記録を削除する
  func delete(id: UUID)
}

/// UserDefaults（端末内のみ）に記録を保存するストア
struct ScoreSheetStore: ScoreSheetStoring {
  private static let key = "savedScoreSheets"
  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func sheets(for event: CombinedEvent) -> [SavedScoreSheet] {
    allSheets()
      .filter { $0.eventKey == event.storageKey }
      .sorted { $0.date > $1.date }
  }

  func save(_ sheet: SavedScoreSheet) {
    var sheets = allSheets()
    sheets.append(sheet)
    write(sheets)
  }

  func delete(id: UUID) {
    write(allSheets().filter { $0.id != id })
  }

  private func allSheets() -> [SavedScoreSheet] {
    guard let data = defaults.data(forKey: Self.key),
          let sheets = try? JSONDecoder().decode([SavedScoreSheet].self, from: data) else {
      return []
    }
    return sheets
  }

  private func write(_ sheets: [SavedScoreSheet]) {
    guard let data = try? JSONEncoder().encode(sheets) else { return }
    defaults.set(data, forKey: Self.key)
  }
}
