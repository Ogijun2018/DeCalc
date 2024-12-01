//
//  CombinedModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import Foundation

struct CombinedEventInfo {
    /// 混成種目情報
    var event: CombinedEvent
    /// 合計スコア
    var point: Int {
        /// 全ての種目の合計
        return event.events.reduce(0) { $0 + $1.point }
    }
}
