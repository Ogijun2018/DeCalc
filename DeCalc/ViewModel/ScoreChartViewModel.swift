//
//  ScoreChartViewModel.swift
//  DeCalc
//

import Foundation

/// 得点内訳グラフ画面のViewModel
final class ScoreChartViewModel: ObservableObject {
  /// グラフの1本分（1種目）の情報
  struct Entry: Identifiable {
    let id: UUID
    /// 種目名
    let name: String
    /// 得点
    let point: Int
  }

  /// 混成競技名（ローカライズ済み）
  let title: String
  /// 全種目の得点（未入力は0点）
  let entries: [Entry]
  /// 得点が入っている種目の平均点（1種目も入っていない場合はnil）
  let average: Int?
  /// 最も得点が高い種目（得点が入っている種目が2つ未満の場合はnil）
  let best: Entry?
  /// 最も得点が低い種目（得点が入っている種目が2つ未満の場合はnil）
  let weakest: Entry?

  /// グラフに表示できる得点があるか
  var hasData: Bool { average != nil }

  init(combinedEventInfo: CombinedEventInfo) {
    self.title = combinedEventInfo.event.localizedName
    let entries = combinedEventInfo.events.map {
      Entry(id: $0.id, name: $0.event.description, point: $0.point)
    }
    self.entries = entries

    let entered = entries.filter { $0.point > 0 }
    if entered.isEmpty {
      self.average = nil
    } else {
      self.average = entered.reduce(0) { $0 + $1.point } / entered.count
    }
    // 比較対象が2種目以上あるときだけ得意・不得意を出す
    if entered.count >= 2 {
      self.best = entered.max { $0.point < $1.point }
      self.weakest = entered.min { $0.point < $1.point }
    } else {
      self.best = nil
      self.weakest = nil
    }
  }
}
