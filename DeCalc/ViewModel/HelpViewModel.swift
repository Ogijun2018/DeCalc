//
//  HelpViewModel.swift
//  DeCalc
//

import Foundation

/// ヘルプ画面のViewModel
final class HelpViewModel: ObservableObject {
  /// 計算式の係数を表示するための1行分の情報
  struct CoefficientRow: Identifiable {
    let id = UUID()
    /// 種目名
    let name: String
    /// 係数A
    let a: String
    /// 係数B
    let b: String
    /// 係数C
    let c: String
  }

  /// ヘルプを開いた混成競技
  let combinedEvent: CombinedEvent
  /// 混成競技に含まれる種目ごとの係数
  let coefficientRows: [CoefficientRow]
  /// サポートページ
  let supportURL = URL(string: "https://ogijun2018.github.io/DeCalc/")

  init(combinedEvent: CombinedEvent) {
    self.combinedEvent = combinedEvent
    self.coefficientRows = combinedEvent.events.map { info in
      CoefficientRow(
        name: info.event.description,
        a: Self.format(info.event.firstCoefficient),
        b: Self.format(info.event.secondCoefficient),
        c: Self.format(info.event.thirdCoefficient)
      )
    }
  }

  /// 係数を末尾の0を省いた文字列に変換する
  private static func format(_ value: Double) -> String {
    value.formatted(.number.precision(.fractionLength(0...6)).grouping(.never))
  }
}
