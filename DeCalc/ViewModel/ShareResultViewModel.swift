//
//  ShareResultViewModel.swift
//  DeCalc
//

import Foundation

/// 結果のシェア画面のViewModel
final class ShareResultViewModel: ObservableObject {
  /// カードに表示する1種目分の情報
  struct Row: Identifiable {
    let id: UUID
    /// 種目名
    let name: String
    /// 単位つきの記録（未入力の場合はnil）
    let record: String?
    /// 得点
    let point: Int
  }

  /// 混成競技名（ローカライズ済み）
  let title: String
  /// 混成競技名（英語）
  let subtitle: String
  /// 合計点
  let total: Int
  /// 種目ごとの記録と得点
  let rows: [Row]
  /// シェアした日付
  let dateText: String

  init(combinedEventInfo: CombinedEventInfo, date: Date = .now) {
    self.title = combinedEventInfo.event.localizedName
    self.subtitle = combinedEventInfo.event.description
    self.total = combinedEventInfo.point
    self.dateText = date.formatted(date: .abbreviated, time: .omitted)
    self.rows = combinedEventInfo.events.map { info in
      // 桁がすべて埋まっている記録だけを表示する
      let record = info.score.flatMap { score in
        score.count == info.event.digit ? info.event.formattedRecord(score) : nil
      }
      return Row(id: info.id, name: info.event.description, record: record, point: info.point)
    }
  }

  /// テキストでシェアする内容
  var summaryText: String {
    var lines = ["\(title) \(String(localized: "\(total) pt"))"]
    lines += rows.map { row in
      "\(row.name)  \(row.record ?? "-")  \(row.point)"
    }
    lines.append("#DeCalc")
    return lines.joined(separator: "\n")
  }
}
