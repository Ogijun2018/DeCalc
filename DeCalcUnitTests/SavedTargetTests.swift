//
//  SavedTargetTests.swift
//  DeCalcUnitTests
//

import Foundation
import Testing
@testable import DeCalc

/// 記録の保存画面と、保存した自己ベスト・目標との比較
struct SavedTargetTests {

    /// テストごとに独立したUserDefaultsを使うストアを作る
    private func makeStore() throws -> (store: ScoreSheetStore, cleanUp: () -> Void) {
        let suiteName = "SavedTargetTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        return (ScoreSheetStore(defaults: defaults), { defaults.removePersistentDomain(forName: suiteName) })
    }

    /// 保存画面で、指定した得点の記録を保存する
    private func save(
        points: [Int],
        isPersonalBest: Bool,
        isTarget: Bool,
        to store: ScoreSheetStore
    ) {
        var events = CombinedEvent.decathlon.events
        for (index, point) in points.enumerated() {
            events[index].point = point
        }
        let viewModel = SaveScoresViewModel(
            combinedEventInfo: .init(event: .decathlon, events: events),
            store: store
        )
        viewModel.isPersonalBest = isPersonalBest
        viewModel.isTarget = isTarget
        viewModel.saveButtonDidTap()
    }

    @Test func 保存画面で選んだ内容のとおりに保存される() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        var events = CombinedEvent.decathlon.events
        events[0].point = 900
        let viewModel = SaveScoresViewModel(
            combinedEventInfo: .init(event: .decathlon, events: events),
            store: store
        )
        // 何も変えなければ、自己ベストの比較に使う記録として保存される
        viewModel.name = " Trials "
        viewModel.saveButtonDidTap()
        #expect(viewModel.saveFeedbackTrigger == 1)

        let sheet = try #require(store.sheets(for: .decathlon).first)
        #expect(sheet.name == "Trials")
        #expect(sheet.total == 900)
        #expect(sheet.isPersonalBest)
        #expect(!sheet.isTarget)
    }

    @Test func 種目ごとに自己ベストと目標との差が出る() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        save(points: [800, 700], isPersonalBest: true, isTarget: false, to: store)
        save(points: [850, 0, 600], isPersonalBest: false, isTarget: true, to: store)

        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon, sheetStore: store)
        #expect(viewModel.personalBestTotal == 1500)
        #expect(viewModel.targetPoint == 1450)
        #expect(viewModel.remainingToTarget == 1450)

        // 未入力の種目は、比べる相手の得点だけが出る
        #expect(viewModel.targetComparison(at: 0)?.point == 850)
        #expect(viewModel.targetComparison(at: 0)?.diff == nil)
        // 目標・自己ベストに得点がない種目は比較を出さない
        #expect(viewModel.targetComparison(at: 1) == nil)
        #expect(viewModel.personalBestComparison(at: 2) == nil)

        viewModel.pointDidEdit(index: 0, point: 820)
        #expect(viewModel.personalBestComparison(at: 0)?.diffText == "+20")
        #expect(viewModel.targetComparison(at: 0)?.diffText == "−30")
        #expect(viewModel.remainingToTarget == 630)
    }

    @Test func 保存画面を閉じると新しい目標が反映される() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon, sheetStore: store)
        #expect(viewModel.targetPoint == nil)

        // 得点がないときは保存画面を開かない
        viewModel.saveButtonDidTap()
        #expect(viewModel.sheet == nil)

        viewModel.pointDidEdit(index: 0, point: 900)
        viewModel.saveButtonDidTap()
        #expect(viewModel.sheet == .Save(viewModel.combinedEventInfo))

        save(points: [900], isPersonalBest: false, isTarget: true, to: store)
        viewModel.sheetDidDismiss()
        #expect(viewModel.targetPoint == 900)
        #expect(viewModel.remainingToTarget == 0)
        #expect(viewModel.personalBestTotal == nil)
    }
}
