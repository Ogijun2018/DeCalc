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
            Text(cell.event.description)
            OTPTextView(
                pinLength: cell.event.digit,
                leadingUnit: cell.event.leadUnit,
                centerUnit: cell.event.centerUnit,
                trailingUnit: cell.event.trailUnit,
                unitPoint: cell.event.unitPoint
            ) { value in
                print(value)
            }
        }
    }

    var body: some View {
        ScrollView {
            HStack {
                // 記録
                VStack {
                    Text("記録")
                    ForEach(viewModel.events) { event in
                        destinationView(for: event)
                    }
                    Text(String(viewModel.score))
                }
                Spacer().frame(width: 200)
            }
        }
    }
}

#Preview {
    ScoreCalculateView(viewModel: .init(combinedEvent: .decathlon))
}
