//
//  SavedSheetsViewModelTests.swift
//  DeCalcUnitTests
//

import Foundation
import Testing
@testable import DeCalc

struct SavedSheetsViewModelTests {

    @Test func 行のタイトルと自己ベスト_目標の印はViewModelが決める() throws {
        let suiteName = "SavedSheetsViewModelTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = ScoreSheetStore(defaults: defaults)

        var events = CombinedEvent.decathlon.events
        events[0].point = 800
        store.save(SavedScoreSheet(
            info: .init(event: .decathlon, events: events),
            name: "Spring",
            isPersonalBest: true,
            isTarget: true,
            date: Date(timeIntervalSince1970: 1_000)
        ))
        events[1].point = 700
        store.save(SavedScoreSheet(
            info: .init(event: .decathlon, events: events),
            name: "",
            isPersonalBest: true,
            date: Date(timeIntervalSince1970: 2_000)
        ))

        let viewModel = SavedSheetsViewModel(combinedEvent: .decathlon, store: store)
        // 新しい順に並ぶ。名前がない記録は日時がタイトルになり、副題は出ない
        #expect(viewModel.rows.map(\.total) == [1500, 800])
        #expect(viewModel.rows[0].subtitle == nil)
        #expect(viewModel.rows[1].title == "Spring")
        #expect(viewModel.rows[1].subtitle != nil)
        #expect(viewModel.rows.map(\.isPersonalBest) == [true, false])
        #expect(viewModel.rows.map(\.isTarget) == [false, true])
        #expect(viewModel.rows[0].details.count == 10)

        viewModel.delete(at: IndexSet(integer: 0))
        #expect(viewModel.rows.map(\.title) == ["Spring"])
        #expect(viewModel.rows.map(\.isPersonalBest) == [true])
    }
}
