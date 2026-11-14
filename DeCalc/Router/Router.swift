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

/// 遷移先の画面を表す値
/// ViewModelからも扱えるよう、View型には依存しない（画面の生成はRouterViewが行う）
enum Router: Hashable, Identifiable {
    case Score(CombinedEvent)
    /// ヘルプ画面
    case Help(CombinedEvent)
    /// 目標点プランナー画面
    case Planner(CombinedEventInfo)
    /// 結果のシェア画面
    case Share(CombinedEventInfo)
}

/// Routerが表す画面
struct RouterView: View {
    let router: Router

    var body: some View {
        switch router {
        case .Score(let event): ScoreCalculateView(viewModel: .init(combinedEvent: event))
        case .Help(let event): HelpView(viewModel: .init(combinedEvent: event))
        case .Planner(let info): PlannerView(viewModel: .init(combinedEventInfo: info))
        case .Share(let info): ShareResultView(viewModel: .init(combinedEventInfo: info))
        }
    }
}
