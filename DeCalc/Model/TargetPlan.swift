//
//  TargetPlan.swift
//  DeCalc
//

import Foundation

/// 目標合計点に対して、あと何点必要か・残り種目でどのくらいの記録が必要かをまとめたもの
struct TargetPlan {
  /// 残り種目1つ分の目安
  struct Requirement: Identifiable {
    let id: UUID
    /// 種目名
    let name: String
    /// 必要な得点
    let point: Int
    /// 必要な記録（単位つき）。その種目では届かない得点の場合はnil
    let record: String?
  }

  /// 目標合計点
  let target: Int
  /// 現在の合計点
  let currentPoint: Int
  /// 目標までの残り得点（達成済みの場合は0）
  let remainingPoint: Int
  /// 残り種目に均等に割り振ったときの1種目あたりの必要得点（残り種目がない・達成済みの場合はnil）
  let averagePoint: Int?
  /// 残り種目ごとの目安
  let requirements: [Requirement]

  /// 目標を達成しているか
  var isAchieved: Bool { remainingPoint == 0 }

  init(info: CombinedEventInfo, target: Int) {
    self.target = target
    self.currentPoint = info.point
    self.remainingPoint = max(0, target - info.point)

    // 得点が入っていない種目を「残り種目」として扱う
    let remainingEvents = info.events.filter { $0.point == 0 }
    guard remainingPoint > 0, !remainingEvents.isEmpty else {
      self.averagePoint = nil
      self.requirements = []
      return
    }
    // 端数は切り上げて、合計が目標を下回らないようにする
    let average = (remainingPoint + remainingEvents.count - 1) / remainingEvents.count
    self.averagePoint = average
    self.requirements = remainingEvents.map { event in
      Requirement(
        id: event.id,
        name: event.event.description,
        point: average,
        record: Self.requiredRecord(for: event, point: average)
      )
    }
  }

  /// 指定した得点を取るのに必要な記録を、単位つきの文字列で返す
  private static func requiredRecord(for info: EventInfo, point: Int) -> String? {
    guard var score = try? info.convertToScore(point: point) else { return nil }
    // 跳躍・投てきは逆算時の四捨五入で1点足りなくなることがあるため、その場合は1cm上乗せする
    if case .Run = info.event {
      // 走種目は速い側に丸められるため補正不要
    } else if let actual = try? info.convertToPoint(score: score), actual < point {
      score += 1
    }
    let digits = String(format: "%0\(info.event.digit)d", score)
    // 入力欄の桁数に収まらない記録（1分を超える短距離など）は表示しない
    guard digits.count == info.event.digit else { return nil }
    return info.event.formattedRecord(digits)
  }
}
