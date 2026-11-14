//
//  Router.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

import SwiftUI

extension Identifiable where Self: Hashable {
    typealias ID = Self
    var id: Self { self }
}

enum Router: View, Hashable, Identifiable {
    case Score(CombinedEvent)
    /// ヘルプ画面
    case Help(CombinedEvent)
    /// 目標点プランナー画面
    case Planner(CombinedEventInfo)
    /// 結果のシェア画面
    case Share(CombinedEventInfo)
    /// 得点内訳グラフ画面
    case Chart(CombinedEventInfo)
    /// 保存した記録の一覧画面
    case SavedSheets(CombinedEvent)

    var body: some View {
        switch self {
        case .Score(let event): return AnyView(ScoreCalculateView(viewModel: .init(combinedEvent: event)))
        case .Help(let event): return AnyView(HelpView(viewModel: .init(combinedEvent: event)))
        case .Planner(let info): return AnyView(PlannerView(viewModel: .init(combinedEventInfo: info)))
        case .Share(let info): return AnyView(ShareResultView(viewModel: .init(combinedEventInfo: info)))
        case .Chart(let info): return AnyView(ScoreChartView(viewModel: .init(combinedEventInfo: info)))
        case .SavedSheets(let event): return AnyView(SavedSheetsView(viewModel: .init(combinedEvent: event)))
        }
    }
}
