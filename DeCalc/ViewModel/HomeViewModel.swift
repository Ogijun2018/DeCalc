//
//  HomeViewModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/31.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var selectedGender: Gender
    /// ホーム画面から開いている画面（空の場合はホーム画面を表示）
    @Published var path: [Router] {
        didSet {
            // 競技を開いたら、次回の起動時に同じ競技から始められるよう記録する
            if case .Score(let event) = path.last {
                store.setLastEvent(event)
            }
        }
    }
    private let store: LastEventStoring

    /// 前回開いた競技があれば、その競技の得点計算画面を開いた状態で始める
    /// - Parameter selectedGender: 前回開いた競技がない場合に選んでおく性別
    init(selectedGender: Gender = .Men, store: LastEventStoring = LastEventStore()) {
        let lastEvent = store.lastEvent()
        self.selectedGender = lastEvent?.gender ?? selectedGender
        self.path = lastEvent.map { [.Score($0)] } ?? []
        self.store = store
    }

    func genderButtonTapped(gender: Gender) {
        selectedGender = gender
    }
}
