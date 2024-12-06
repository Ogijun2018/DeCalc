//
//  Decathlon.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

struct ScoreCalculateView: View {
    @ObservedObject var viewModel: DecathlonViewModel

    @ViewBuilder
    func destinationView(for cell: EventTextFieldInfo) -> some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack {
                    Text(cell.event.description)
                        .font(.system(size: 25, weight: .heavy))
                    Spacer()
                }
                RecordTextView(
                    numberLength: cell.event.digit,
                    leadingUnit: cell.event.leadUnit,
                    centerUnit: cell.event.centerUnit,
                    trailingUnit: cell.event.trailUnit,
                    unitPoint: cell.event.unitPoint
                ) { value in
                    print(value)
                }
                HStack {
                    Spacer()
                    Text("Score:")
                        .font(.system(size: 20, weight: .bold))
                    Text("765")
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.events) { event in
                    destinationView(for: event)
                        .padding(.horizontal)
                }
                Text(String(viewModel.score))
            }
        }
    }
}

#Preview {
    ScoreCalculateView(viewModel: .init(combinedEvent: .decathlon))
}
