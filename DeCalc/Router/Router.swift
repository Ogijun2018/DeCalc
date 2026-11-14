//
//  Router.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

import SwiftUI

/// 遷移先の画面を表す値
/// ViewModelからも扱えるよう、View型には依存しない（画面の生成はRouterViewが行う）
enum Router: Hashable, Identifiable {
    case Score(CombinedEvent)
    /// ヘルプ画面
    case Help(CombinedEvent)
    /// 目標点プランナー画面
    case Planner(CombinedEventInfo)

    /// 値そのものを識別子にする（`.sheet(item:)` での表示に使う）
    /// 以前は Hashable な Identifiable すべてにこの定義を広げていたが、自前の id を持つ型
    /// （EventInfo など）の識別子まで「値そのもの」に置き換わり、内容が変わるたびに
    /// 別の要素として扱われてしまうため、Router だけに限定している
    var id: Self { self }
}

/// Routerが表す画面
struct RouterView: View {
    let router: Router

    var body: some View {
        switch router {
        case .Score(let event): ScoreCalculateView(viewModel: .init(combinedEvent: event))
        case .Help(let event): HelpView(viewModel: .init(combinedEvent: event))
        case .Planner(let info): PlannerView(viewModel: .init(combinedEventInfo: info))
        }
    }
}
