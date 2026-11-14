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
        events.totalPoint
    }

    /// 競技日ごとに種目をまとめたもの
    struct DaySection {
        /// 何日目か（1日で完結する競技はnil）。セクションの識別にも使う
        let day: Int?
        /// その日に行う種目（添字は全種目の配列での位置のまま）
        let events: ArraySlice<EventInfo>
    }

    /// 1日目・2日目に分けた種目（1日で完結する競技は1セクション）
    var daySections: [DaySection] {
        guard let firstDayCount = event.firstDayEventCount,
              firstDayCount < events.count else {
            return [DaySection(day: nil, events: events[...])]
        }
        return [
            DaySection(day: 1, events: events[..<firstDayCount]),
            DaySection(day: 2, events: events[firstDayCount...])
        ]
    }
}

extension Collection where Element == EventInfo {
    /// 合計点
    var totalPoint: Int {
        reduce(0) { $0 + $1.point }
    }

    /// 得点が入っている種目数
    var enteredCount: Int {
        filter { $0.point > 0 }.count
    }
}
