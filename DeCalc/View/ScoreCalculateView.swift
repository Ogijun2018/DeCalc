//
//  ScoreCalculateView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

struct ScoreCalculateView: View {
  @StateObject var viewModel: ScoreCalculateViewModel
  // FocusStateはnilの場合にキーボード非表示を表現する
  // 現状は一つのcaseを持つenumを用いている
  @FocusState var isScoreFocused: Focus?
  @FocusState var isPointFocused: Focus?

  var body: some View {
    NavigationView {
      ScrollView {
        ForEach(viewModel.combinedEventInfo.events, id: \.id) { event in
          GroupBox {
            VStack(spacing: 0) {
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
                  leadingUnit: event.event.leadUnit,
                  centerUnit: event.event.centerUnit,
                  trailingUnit: event.event.trailUnit,
                  unitPoint: event.event.unitPoint,
                  textFieldId: event.id.hashValue,
                  onPressTextView: {
                    isScoreFocused = switch isScoreFocused {
                    case .focused: nil
                    case nil: .focused(id: event.id.hashValue)
                    }
                  },
                  scoreFilled: {
                    viewModel.scoreFilled(index: eventIndex)
                  }
                )
                HStack {
                  Spacer()
                  Text("Point:")
                    .font(.system(size: 20, weight: .bold))
                  ScoreTextView(
                    point: $viewModel.combinedEventInfo.events[eventIndex].point,
                    isFocused: $isPointFocused,
                    textFieldId: event.idForScore.hashValue
                  )
                  Button("Point→Score") {
                    viewModel.calculateButtonDidTap(index: eventIndex)
                  }
                }
              }
            }
          }.padding(.horizontal)
        }
      }
      .safeAreaInset(edge: .top) {
        VStack(alignment: .leading, spacing: 4) {
          HStack() {
            Text("Total Point:")
              .font(.largeTitle.weight(.bold))
            Spacer()
            Text(String(viewModel.combinedEventInfo.point))
              .font(.largeTitle.weight(.bold))
          }
        }
        .padding()
        .background(
          LinearGradient(
            colors: [
              .green.opacity(0.3),
              .blue.opacity(0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
          .overlay(.ultraThinMaterial)
        )
      }
    }
    .navigationBarItems(trailing: Button(action: {
      print("hoge")
    }) {
      Image(systemName: "trash")
    })
    .tint(.purple)
  }
}

#Preview {
  ScoreCalculateView(viewModel: .init(combinedEvent: .decathlon))
}
