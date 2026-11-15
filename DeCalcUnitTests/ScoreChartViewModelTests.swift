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

    @Test func 棒の長さは1000点を横幅いっぱいとした割合になる() {
        var events = CombinedEvent.decathlon.events
        events[0].point = 900
        events[1].point = 600
        let viewModel = ScoreChartViewModel(
            combinedEventInfo: .init(event: .decathlon, events: events)
        )
        #expect(viewModel.entries[0].ratio == 0.9)
        #expect(viewModel.entries[0].pointText == "900")
        #expect(viewModel.averageRatio == 0.75)
        // 未入力の種目は棒がなく、得点は「-」になる
        #expect(viewModel.entries[2].ratio == 0)
        #expect(viewModel.entries[2].pointText == "-")
    }

    @Test func 得点が1000点を超えると100点単位で横幅を広げる() {
        var events = CombinedEvent.decathlon.events
        events[0].point = 1101
        let viewModel = ScoreChartViewModel(
            combinedEventInfo: .init(event: .decathlon, events: events)
        )
        // 横幅いっぱいは1200点
        #expect(viewModel.entries[0].ratio == 1101.0 / 1200.0)
    }

    @Test func 種目は走_跳_投に分けられ_種類ごとの平均が出る() {
        // 十種: 100m・走幅跳・砲丸投・走高跳・400m …
        var events = CombinedEvent.decathlon.events
        events[0].point = 900
        events[1].point = 700
        events[3].point = 800
        events[4].point = 700
        let viewModel = ScoreChartViewModel(
            combinedEventInfo: .init(event: .decathlon, events: events)
        )
        #expect(viewModel.entries.prefix(5).map(\.kind) == [.run, .jump, .throwing, .jump, .run])
        #expect(viewModel.kindSummaries.map(\.kind) == [.run, .jump, .throwing])
        // 得点が入っていない種類は平均を出さない
        #expect(viewModel.kindSummaries.map(\.average) == [800, 750, nil])
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
