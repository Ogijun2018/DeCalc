//
//  ScoreCalculateView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

struct ScoreCalculateView: View {
    @ObservedObject var viewModel: ScoreCalculateViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.combinedEventInfo.events) { event in
                    GroupBox {
                        VStack(spacing: 0) {
                            HStack {
                                Text(event.event.description)
                                    .font(.system(size: 25, weight: .heavy))
                                Spacer()
                            }
                            RecordTextView(
                                numberLength: event.event.digit,
                                leadingUnit: event.event.leadUnit,
                                centerUnit: event.event.centerUnit,
                                trailingUnit: event.event.trailUnit,
                                unitPoint: event.event.unitPoint
                            ) { value in
                                if let index = viewModel.combinedEventInfo.events.firstIndex(where: { $0.id == event.id }) {
                                    viewModel.didCompleteScore(
                                        index: index,
                                        score: value
                                    )
                                }
                            }
                            HStack {
                                Spacer()
                                Text("Score:")
                                    .font(.system(size: 20, weight: .bold))
                                Text(String(event.point))
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                    }.padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack() {
                        Text("Total Score:")
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
