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

  /// 計算式の説明1行分の情報
  struct FormulaRow: Identifiable {
    let id = UUID()
    /// 種目の種類（トラック・跳躍・投てき）
    let title: String
    /// 得点の計算式
    let formula: String
  }

  /// ヘルプを開いた混成競技
  let combinedEvent: CombinedEvent
  /// 混成競技に含まれる種目ごとの係数
  let coefficientRows: [CoefficientRow]
  /// 種目の種類ごとの得点の計算式
  let formulaRows = [
    FormulaRow(title: String(localized: "Track events"), formula: "P = A × (B − T)^C"),
    FormulaRow(title: String(localized: "Jumps"), formula: "P = A × (M − B)^C"),
    FormulaRow(title: String(localized: "Throws"), formula: "P = A × (D − B)^C"),
  ]

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
