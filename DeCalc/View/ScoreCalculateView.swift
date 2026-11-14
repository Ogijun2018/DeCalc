//
//  ScoreCalculateView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData
import TipKit

struct ScoreCalculateView: View {
  @StateObject var viewModel: ScoreCalculateViewModel
  // FocusStateはnilの場合にキーボード非表示を表現する
  // 現状は一つのcaseを持つenumを用いている
  @FocusState var isScoreFocused: Focus?
  @FocusState var isPointFocused: Focus?
  /// 削除ダイアログの表示状態
  @State private var isShowingClearAlert = false
  /// 外部URL（App Store等）を開くための環境値
  @Environment(\.openURL) private var openURL
  /// App StoreのアプリID
  private static let appStoreID = "6779939129"

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          ForEach(viewModel.combinedEventInfo.events, id: \.id) { event in
            eventCard(event, proxy: proxy)
          }
        }
        .safeAreaInset(edge: .top) {
          VStack(alignment: .leading, spacing: 4) {
            HStack() {
              Label("Total Point", systemImage: "p.circle")
                .font(.title2.weight(.semibold))
              Spacer()
              Text(String(viewModel.combinedEventInfo.point))
                .font(.title2.weight(.bold))
                .monospacedDigit()
                // 合計点の変化を数字が転がるアニメーションで表現する
                .contentTransition(.numericText(value: Double(viewModel.combinedEventInfo.point)))
                .animation(.snappy, value: viewModel.combinedEventInfo.point)
            }
          }
          .padding()
          .glassEffect(
            .regular.tint(Color.primaryColor.opacity(0.2)).interactive(),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
          )
          .padding(.horizontal)
        }
        .navigationTitle(viewModel.combinedEventInfo.event.localizedName)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Menu {
              // ヘルプ: 入力方法と計算式の説明をシートで表示
              Button {
                viewModel.helpButtonDidTap()
              } label: {
                Label("Help", systemImage: "questionmark.circle")
              }
              // 記録全削除: 既存のゴミ箱と同じ挙動（確認アラートを表示）
              Button(role: .destructive) {
                isShowingClearAlert = true
              } label: {
                Label("Delete all scores", systemImage: "trash")
              }
              // レビュー: App Storeのレビュー画面へ遷移
              Button {
                if let url = URL(string: "https://apps.apple.com/app/id\(Self.appStoreID)?action=write-review") {
                  openURL(url)
                }
              } label: {
                Label("Review", systemImage: "star")
              }
            } label: {
              Image(systemName: "ellipsis")
            }
          }
          ToolbarItemGroup(placement: .keyboard) {
            // 前後の種目の入力欄へ移動する
            Button { moveFocus(by: -1, proxy: proxy) } label: {
              Image(systemName: "chevron.up")
            }
            .disabled(!canMoveFocus(by: -1))
            .accessibilityLabel("Previous")
            Button { moveFocus(by: 1, proxy: proxy) } label: {
              Image(systemName: "chevron.down")
            }
            .disabled(!canMoveFocus(by: 1))
            .accessibilityLabel("Next")
            Spacer()
            // チェックボタンでキーボードを閉じる
            Button { dismissKeyboard() } label: {
              Image(systemName: "checkmark")
            }
            .accessibilityLabel("Done")
          }
        }
        // 得点欄（実体のあるTextField）はフォーカスの変化を検知してスクロールする
        .onChange(of: isPointFocused) { _, newValue in
          scrollToFocusedEvent(newValue, proxy: proxy)
        }
      }
    }
    .sheet(item: $viewModel.sheet) { $0 }
    .alert("Delete all scores?", isPresented: $isShowingClearAlert) {
      Button("Cancel", role: .cancel) {
        isShowingClearAlert = false
      }
      Button("OK", role: .destructive) {
        isScoreFocused = nil
        isPointFocused = nil
        viewModel.didTapDeleteButton()
      }
    }
    // 得点が確定したとき・逆算に失敗したときに触覚で知らせる
    .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.scoreFeedbackTrigger)
    .sensoryFeedback(.error, trigger: viewModel.errorFeedbackTrigger)
    .tint(Color.primaryColor)
  }

  /// 1種目分の入力カード（記録・得点・逆算ボタン）
  @ViewBuilder
  private func eventCard(_ event: EventInfo, proxy: ScrollViewProxy) -> some View {
    GroupBox {
      VStack(spacing: 5) {
        HStack {
          Text(event.event.description)
            .font(.system(size: 25, weight: .heavy))
          Spacer()
        }
        if let eventIndex = viewModel.combinedEventInfo.events.firstIndex(where: { $0.id == event.id }) {
          RecordTextView(
            record: $viewModel.combinedEventInfo.events[eventIndex].score,
            isFocused: $isScoreFocused,
            numberLength: event.event.digit,
            units: (
              event.event.leadUnit,
              event.event.centerUnit,
              event.event.trailUnit
            ),
            leadingUnitPoint: event.event.leadUnitPoint,
            unitPoint: event.event.unitPoint,
            textFieldId: event.id.hashValue,
            onPressTextView: {
              let targetFocus: Focus? = .focused(id: event.id.hashValue)
              let newFocus: Focus? = isScoreFocused == targetFocus ? nil : targetFocus
              isScoreFocused = newFocus
              // 記録欄は0サイズの隠しTextFieldをプログラム的にフォーカスするため
              // onChange(of: FocusState)では追従できない。タップ時に明示的にスクロールする
              scrollToFocusedEvent(newFocus, proxy: proxy)
            },
            scoreFilled: {
              viewModel.scoreFilled(index: eventIndex)
              advanceFocusIfNeeded(from: eventIndex, proxy: proxy)
            },
            recordIncomplete: {
              viewModel.recordBecameIncomplete(index: eventIndex)
            }
          )
          HStack(spacing: 10) {
            Image(systemName: "p.circle")
              .font(.system(size: 25))
            ScoreTextView(
              // 手で編集した得点は記録と連動させないため、ViewModel経由で書き込む
              point: Binding(
                get: { viewModel.combinedEventInfo.events[eventIndex].point },
                set: { viewModel.pointDidEdit(index: eventIndex, point: $0) }
              ),
              isFocused: $isPointFocused,
              textFieldId: event.idForScore.hashValue
            )
            Text("pt")
              .font(.system(size: 20, weight: .semibold))
            Button("\(Image(systemName: "p.circle"))→\(Image(systemName: "figure.run.circle"))") {
              viewModel.calculateButtonDidTap(index: eventIndex)
            }
            .padding(10)
            .glassEffect(
              .regular.tint(Color.primaryColor.opacity(0.2)).interactive()
            )
          }
          if let error = viewModel.combinedEventInfo.events[eventIndex].errorText {
            Text(error)
              .font(.system(size: 11))
              .foregroundStyle(.red)
              .padding(.top, 5)
          }
        }
      }
    }
    .padding(.horizontal)
    .id(event.id)
  }

  /// 記録欄が埋まったら、次の未入力の記録欄へフォーカスを移す（後ろ→先頭の順に探す）
  private func advanceFocusIfNeeded(from index: Int, proxy: ScrollViewProxy) {
    let events = viewModel.combinedEventInfo.events
    // 逆算ボタンなどキーボード入力以外で記録が埋まった場合は移動しない
    guard isScoreFocused == .focused(id: events[index].id.hashValue) else { return }
    if let next = viewModel.nextEmptyRecordIndex(after: index) {
      let focus: Focus = .focused(id: events[next].id.hashValue)
      isScoreFocused = focus
      scrollToFocusedEvent(focus, proxy: proxy)
    } else {
      // すべての種目の記録を入力し終えたらキーボードを閉じる
      dismissKeyboard()
    }
  }

  /// フォーカス中の入力欄がある種目のインデックス
  private var focusedEventIndex: Int? {
    if case let .focused(id)? = isScoreFocused {
      return viewModel.eventIndex(forFocusID: id)
    }
    if case let .focused(id)? = isPointFocused {
      return viewModel.eventIndex(forFocusID: id)
    }
    return nil
  }

  /// 前後の種目へフォーカスを移動できるか
  private func canMoveFocus(by offset: Int) -> Bool {
    guard let index = focusedEventIndex else { return false }
    return viewModel.neighborIndex(of: index, offset: offset) != nil
  }

  /// 前後の種目の同じ種類の入力欄（記録→記録、得点→得点）へフォーカスを移す
  private func moveFocus(by offset: Int, proxy: ScrollViewProxy) {
    guard let index = focusedEventIndex,
          let target = viewModel.neighborIndex(of: index, offset: offset) else { return }
    let event = viewModel.combinedEventInfo.events[target]
    if isScoreFocused != nil {
      let focus: Focus = .focused(id: event.id.hashValue)
      isScoreFocused = focus
      scrollToFocusedEvent(focus, proxy: proxy)
    } else {
      // 得点欄はonChange(of: isPointFocused)でスクロールされる
      isPointFocused = .focused(id: event.idForScore.hashValue)
    }
  }

  /// フォーカスを解除してソフトウェアキーボードを閉じる
  private func dismissKeyboard() {
    isScoreFocused = nil
    isPointFocused = nil
  }

  /// フォーカス中の入力欄を持つ種目を、ソフトウェアキーボードの上に表示されるようスクロールする
  private func scrollToFocusedEvent(
    _ focus: Focus?,
    proxy: ScrollViewProxy
  ) {
    guard case let .focused(id)? = focus else { return }
    guard let target = viewModel.combinedEventInfo.events.first(where: {
      $0.id.hashValue == id || $0.idForScore.hashValue == id
    }) else { return }
    // キーボードの表示アニメーション（およびScrollViewのインセット反映）を待ってからスクロールする
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(0.25))
      withAnimation(.easeInOut(duration: 0.25)) {
        proxy.scrollTo(target.id, anchor: .center)
      }
    }
  }
}

#Preview {
  ScoreCalculateView(viewModel: .init(combinedEvent: .decathlon))
}
