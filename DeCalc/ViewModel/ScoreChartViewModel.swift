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
    /// 種目の種類（棒の色分けに使う）
    let kind: Event.Kind
    /// 得点
    let point: Int
    /// 棒の長さ（グラフの横幅に対する割合。0〜1）
    let ratio: Double
    /// 表示用の得点（未入力の場合は「-」）
    let pointText: String
  }

  /// 種目の種類（走・跳・投）ごとの情報。凡例と種類別の平均に使う
  struct KindSummary: Identifiable {
    let kind: Event.Kind
    /// 種類名（ローカライズ済み）
    let name: String
    /// 得点が入っている種目の平均点（1種目も入っていない場合はnil）
    let average: Int?

    var id: Event.Kind { kind }
  }

  /// 混成競技名（ローカライズ済み）
  let title: String
  /// 全種目の得点（未入力は0点）
  let entries: [Entry]
  /// この混成競技に含まれる種目の種類（走・跳・投の順）
  let kindSummaries: [KindSummary]
  /// 得点が入っている種目の平均点（1種目も入っていない場合はnil）
  let average: Int?
  /// 平均点の位置（グラフの横幅に対する割合。0〜1）
  let averageRatio: Double?
  /// 最も得点が高い種目（得点が入っている種目が2つ未満の場合はnil）
  let best: Entry?
  /// 最も得点が低い種目（得点が入っている種目が2つ未満の場合はnil）
  let weakest: Entry?

  /// グラフに表示できる得点があるか
  var hasData: Bool { average != nil }

  init(combinedEventInfo: CombinedEventInfo) {
    self.title = combinedEventInfo.event.localizedName
    let events = combinedEventInfo.events

    // 横幅いっぱいを1000点とし、それを超える得点があれば100点単位で広げる
    let scaleMax = max(1000, ((events.map(\.point).max() ?? 0) + 99) / 100 * 100)
    let entries = events.map {
      Entry(
        id: $0.id,
        name: $0.event.description,
        kind: $0.event.kind,
        point: $0.point,
        ratio: Double($0.point) / Double(scaleMax),
        pointText: $0.point > 0 ? String($0.point) : "-"
      )
    }
    self.entries = entries

    let entered = entries.filter { $0.point > 0 }
    let average = Self.average(of: entered)
    self.average = average
    self.averageRatio = average.map { Double($0) / Double(scaleMax) }
    self.kindSummaries = Event.Kind.allCases
      .filter { kind in entries.contains { $0.kind == kind } }
      .map { kind in
        KindSummary(
          kind: kind,
          name: kind.localizedName,
          average: Self.average(of: entered.filter { $0.kind == kind })
        )
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

  /// 平均点（対象がない場合はnil）
  private static func average(of entries: [Entry]) -> Int? {
    entries.isEmpty ? nil : entries.reduce(0) { $0 + $1.point } / entries.count
  }
}
