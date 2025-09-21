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

  var body: some View {
    NavigationView {
      ScrollView {
        ForEach(viewModel.combinedEventInfo.events, id: \.id) { event in
          GroupBox {
            VStack(spacing: 5) {
              HStack {
                Image(systemName: "figure.run.circle")
                  .font(.system(size: 25))
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
                    isScoreFocused = switch isScoreFocused {
                    case .focused: nil
                    case nil: .focused(id: event.id.hashValue)
                    }
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
                  .buttonStyle(.borderedProminent)
                  .cornerRadius(10)
                }
                if let error = viewModel.combinedEventInfo.events[eventIndex].errorText {
                  Text(error)
                    .font(.system(size: 11))
                    .foregroundStyle(.red)
                    .padding(.top, 5)
                }
              }
            }
          }.padding(.horizontal)
        }
      }
      .safeAreaInset(edge: .top) {
        VStack(alignment: .leading, spacing: 4) {
          HStack() {
            Label("Total Point", systemImage: "p.circle")
              .font(.largeTitle.weight(.semibold))
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
    .tint(Color.primaryColor)
  }
}

#Preview {
  ScoreCalculateView(viewModel: .init(combinedEvent: .decathlon))
}
