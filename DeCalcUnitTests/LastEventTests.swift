//
//  LastEventTests.swift
//  DeCalcUnitTests
//

import Foundation
import Testing
@testable import DeCalc

/// 最後に開いた競技の記録と、起動時の復元
@MainActor
struct LastEventTests {

    /// テストごとに独立したUserDefaultsを使うストアを作る
    private func makeStore() throws -> (store: LastEventStore, cleanUp: () -> Void) {
        let suiteName = "LastEventTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        return (LastEventStore(defaults: defaults), { defaults.removePersistentDomain(forName: suiteName) })
    }

    @Test(arguments: CombinedEvent.allCases)
    func どの競技も記録して読み戻せる(event: CombinedEvent) throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        #expect(store.lastEvent() == nil)
        store.setLastEvent(event)
        #expect(store.lastEvent() == event)
    }

    @Test func 開いたことがなければホーム画面から始まる() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        let viewModel = HomeViewModel(selectedGender: .Women, store: store)
        #expect(viewModel.path.isEmpty)
        #expect(viewModel.selectedGender == .Women)
    }

    @Test func 競技を開くと記録され_次回はその競技を開いた状態で始まる() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        let viewModel = HomeViewModel(store: store)
        viewModel.path = [.Score(.heptathlon)]
        // ホーム画面に戻っても、最後に開いた競技は残る
        viewModel.path = []
        #expect(store.lastEvent() == .heptathlon)

        let relaunched = HomeViewModel(store: store)
        #expect(relaunched.path == [.Score(.heptathlon)])
        // 戻ったときに同じ性別の一覧が出るよう、性別も合わせる
        #expect(relaunched.selectedGender == .Women)
    }
}
