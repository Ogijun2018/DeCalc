//
//  ScoreChartViewModelTests.swift
//  DeCalcUnitTests
//

import Testing
@testable import DeCalc

struct ScoreChartViewModelTests {

    @Test func 得点が入っていない場合はデータなしになる() {
        let event = CombinedEvent.heptathlon
        let viewModel = ScoreChartViewModel(
            combinedEventInfo: .init(event: event, events: event.events)
        )
        #expect(viewModel.hasData == false)
        #expect(viewModel.average == nil)
        #expect(viewModel.best == nil)
        #expect(viewModel.weakest == nil)
        #expect(viewModel.entries.count == 7)
    }

    @Test func 入力済みの種目から平均と得意不得意が求まる() {
        var events = CombinedEvent.decathlon.events
        events[0].point = 900
        events[1].point = 600
        events[2].point = 750
        let viewModel = ScoreChartViewModel(
            combinedEventInfo: .init(event: .decathlon, events: events)
        )
        #expect(viewModel.average == 750)
        #expect(viewModel.best?.id == events[0].id)
        #expect(viewModel.weakest?.id == events[1].id)
    }

    @Test func 入力済みが1種目だけなら得意不得意は出さない() {
        var events = CombinedEvent.decathlon.events
        events[3].point = 800
        let viewModel = ScoreChartViewModel(
            combinedEventInfo: .init(event: .decathlon, events: events)
        )
        #expect(viewModel.average == 800)
        #expect(viewModel.best == nil)
        #expect(viewModel.weakest == nil)
    }
}
