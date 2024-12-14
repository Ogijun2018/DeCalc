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
}
