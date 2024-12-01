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
//    case Second

    var body: some View {
        switch self {
        case .Score(let event): return AnyView(ScoreCalculateView(viewModel: .init(combinedEvent: event)))
        }
    }
}
