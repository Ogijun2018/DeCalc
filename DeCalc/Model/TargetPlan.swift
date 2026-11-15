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
    /// 種目
    let event: Event
    /// 必要な得点
    let point: Int
    /// 必要な記録（入力用の数字列）。その種目の最高得点でも届かない場合はnil
    let recordDigits: String?

    /// 種目名
    var name: String { event.description }
    /// 必要な記録（単位つき）
    var record: String? { recordDigits.map { event.formattedRecord($0) } }
  }

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
        event: event.event,
        point: average,
        recordDigits: Self.requiredRecord(for: event, point: average)
      )
    }
  }

  /// 指定した得点を取るのに必要な記録を、入力用の数字列で返す（最高得点でも届かない場合はnil）
  private static func requiredRecord(for info: EventInfo, point: Int) -> String? {
    guard var score = try? info.convertToScore(point: point) else { return nil }
    switch info.event {
    case .Run:
      // 走種目は速い側に丸められるため補正不要
      break
    case .Jump, .Throw:
      // 逆算時の四捨五入で1点足りなくなることがあるため、その場合は1cm上乗せする
      if let actual = try? info.convertToPoint(score: score), actual < point {
        score += 1
      }
    }
    return String(format: "%0\(info.event.digit)d", score)
  }
}
