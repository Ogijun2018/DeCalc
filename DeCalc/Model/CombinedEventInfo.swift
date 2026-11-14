//
//  CombinedModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import Foundation

/// 混成種目の種目情報とスコアの情報を持つstruct
struct CombinedEventInfo: Hashable {
    /// 混成種目情報
    var event: CombinedEvent
    /// 種目の配列
    var events: [EventInfo]
    /// 合計スコア
    var point: Int {
        /// 全ての種目の合計
        return events.reduce(0) { $0 + ($1.point ?? 0) }
    }

    /// 得点が入っている種目数
    var enteredCount: Int {
        events.filter { $0.point > 0 }.count
    }

    /// 競技日ごとに種目をまとめたもの
    struct DaySection: Identifiable, Hashable {
        /// 何日目か（1日で完結する競技はnil）
        let day: Int?
        /// その日に行う種目
        let events: [EventInfo]

        var id: Int { day ?? 0 }
        /// その日の小計
        var point: Int {
            events.reduce(0) { $0 + $1.point }
        }
        /// 得点が入っている種目数
        var enteredCount: Int {
            events.filter { $0.point > 0 }.count
        }
    }

    /// 1日目・2日目に分けた種目（1日で完結する競技は1セクション）
    var daySections: [DaySection] {
        guard let firstDayCount = event.firstDayEventCount,
              firstDayCount < events.count else {
            return [DaySection(day: nil, events: events)]
        }
        return [
            DaySection(day: 1, events: Array(events[..<firstDayCount])),
            DaySection(day: 2, events: Array(events[firstDayCount...]))
        ]
    }
}
