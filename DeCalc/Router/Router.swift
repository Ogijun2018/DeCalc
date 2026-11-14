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
}

/// Routerが表す画面
struct RouterView: View {
    let router: Router

    var body: some View {
        switch router {
        case .Score(let event): ScoreCalculateView(viewModel: .init(combinedEvent: event))
        case .Help(let event): HelpView(viewModel: .init(combinedEvent: event))
        }
    }
}
