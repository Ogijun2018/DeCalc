//
//  SavedSheetsViewModel.swift
//  DeCalc
//

import Foundation

/// 保存した記録の一覧画面のViewModel
final class SavedSheetsViewModel: ObservableObject {
  /// 一覧の1行分（保存した記録1件）の情報
  struct Row: Identifiable {
    let id: UUID
    /// タイトル（名前。なければ保存した日時）
    let title: String
    /// 名前がある場合に添える、保存した日時
    let subtitle: String?
    /// 合計点
    let total: Int
    /// 自己ベスト（合計点が最も高い記録）かどうか
    let isPersonalBest: Bool
    /// 種目ごとの記録と得点
    let details: [DetailRow]
  }

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

  /// 一覧に表示する行（新しい順）
  @Published private(set) var rows: [Row] = []

  let combinedEvent: CombinedEvent
  private let store: ScoreSheetStoring

  init(combinedEvent: CombinedEvent, store: ScoreSheetStoring = ScoreSheetStore()) {
    self.combinedEvent = combinedEvent
    self.store = store
    reload()
  }

  /// スワイプで削除したとき
  func delete(at offsets: IndexSet) {
    for index in offsets {
      store.delete(id: rows[index].id)
    }
    reload()
  }

  /// 保存した記録を読み直して、表示用の行を作る
  private func reload() {
    let sheets = store.sheets(for: combinedEvent)
    let personalBestID = sheets.personalBest?.id
    rows = sheets.map { sheet in
      let dateText = sheet.date.formatted(date: .abbreviated, time: .shortened)
      return Row(
        id: sheet.id,
        title: sheet.name.isEmpty ? dateText : sheet.name,
        subtitle: sheet.name.isEmpty ? nil : dateText,
        total: sheet.total,
        isPersonalBest: sheet.id == personalBestID,
        details: detailRows(for: sheet)
      )
    }
  }

  /// 種目ごとの記録と得点
  private func detailRows(for sheet: SavedScoreSheet) -> [DetailRow] {
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
}
