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
  /// TODO: App Store ConnectのアプリIDに置き換える
  private static let appStoreID = "0000000000"

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          ForEach(viewModel.combinedEventInfo.events, id: \.id) { event in
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
                    }
                  )
                  HStack(spacing: 10) {
                    Image(systemName: "p.circle")
                      .font(.system(size: 25))
                    ScoreTextView(
                      point: $viewModel.combinedEventInfo.events[eventIndex].point,
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
        }
        .safeAreaInset(edge: .top) {
          VStack(alignment: .leading, spacing: 4) {
            HStack() {
              Label("Total Point", systemImage: "p.circle")
                .font(.title2.weight(.semibold))
              Spacer()
              Text(String(viewModel.combinedEventInfo.point))
                .font(.title2.weight(.bold))
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
              // ヘルプ: 一旦何もしない
              Button {
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
          // チェックボタンでキーボードを閉じる
          ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button { dismissKeyboard() } label: {
              Image(systemName: "checkmark")
            }
          }
        }
        // 得点欄（実体のあるTextField）はフォーカスの変化を検知してスクロールする
        .onChange(of: isPointFocused) { _, newValue in
          scrollToFocusedEvent(newValue, proxy: proxy)
        }
      }
    }
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
    .tint(Color.primaryColor)
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
