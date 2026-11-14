//
//  ScoreCalculateViewModelTests.swift
//  DeCalcUnitTests
//

import Testing
@testable import DeCalc

struct ScoreCalculateViewModelTests {

    @Test func 記録から計算した得点は記録を消すと消える() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        viewModel.combinedEventInfo.events[0].score = "1100"
        viewModel.scoreFilled(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].point > 0)

        viewModel.combinedEventInfo.events[0].score = "110"
        viewModel.recordBecameIncomplete(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].point == 0)
    }

    @Test func 手で編集した得点は記録を消しても残る() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        viewModel.combinedEventInfo.events[0].score = "1100"
        viewModel.scoreFilled(index: 0)
        viewModel.pointDidEdit(index: 0, point: 900)

        viewModel.combinedEventInfo.events[0].score = "110"
        viewModel.recordBecameIncomplete(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].point == 900)
    }
}
