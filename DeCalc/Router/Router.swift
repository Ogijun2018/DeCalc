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
    /// 結果のシェア画面
    case Share(CombinedEventInfo)
    /// 得点内訳グラフ画面
    case Chart(CombinedEventInfo)
    /// 記録の保存画面
    case Save(CombinedEventInfo)
    /// 保存した記録の一覧画面
    case SavedSheets(CombinedEvent)

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
        case .Share(let info): ShareResultView(viewModel: .init(combinedEventInfo: info))
        case .Chart(let info): ScoreChartView(viewModel: .init(combinedEventInfo: info))
        case .Save(let info): SaveScoresView(viewModel: .init(combinedEventInfo: info))
        case .SavedSheets(let event): SavedSheetsView(viewModel: .init(combinedEvent: event))
        }
    }
}
