//
//  SavedSheetsViewModel.swift
//  DeCalc
//

import Foundation

/// 保存した記録の一覧画面のViewModel
final class SavedSheetsViewModel: ObservableObject {
  /// 詳細画面に表示する1種目分の情報
  struct DetailRow: Identifiable {
    let id: Int
    /// 種目名
    let name: String
    /// 単位つきの記録（未入力の場合はnil）
    let record: String?
    /// 得点
    let point: Int
  }

  /// 保存済みの記録（新しい順）
  @Published private(set) var sheets: [SavedScoreSheet]

  let combinedEvent: CombinedEvent
  private let store: ScoreSheetStoring

  /// 自己ベスト（合計点が最も高い記録）のID
  var personalBestID: UUID? {
    sheets.max { $0.total < $1.total }?.id
  }

  init(combinedEvent: CombinedEvent, store: ScoreSheetStoring = ScoreSheetStore()) {
    self.combinedEvent = combinedEvent
    self.store = store
    self.sheets = store.sheets(for: combinedEvent)
  }

  /// 一覧に表示するタイトル（名前がなければ日付）
  func title(for sheet: SavedScoreSheet) -> String {
    sheet.name.isEmpty ? dateText(for: sheet) : sheet.name
  }

  /// 保存した日付
  func dateText(for sheet: SavedScoreSheet) -> String {
    sheet.date.formatted(date: .abbreviated, time: .shortened)
  }

  /// 詳細画面に表示する種目ごとの記録と得点
  func detailRows(for sheet: SavedScoreSheet) -> [DetailRow] {
    zip(combinedEvent.events, sheet.entries).enumerated().map { index, pair in
      let (info, entry) = pair
      return DetailRow(
        id: index,
        name: info.event.description,
        record: entry.record.map { info.event.formattedRecord($0) },
        point: entry.point
      )
    }
  }

  /// スワイプで削除したとき
  func delete(at offsets: IndexSet) {
    for index in offsets {
      store.delete(id: sheets[index].id)
    }
    sheets = store.sheets(for: combinedEvent)
  }
}
