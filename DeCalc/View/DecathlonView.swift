//
//  Decathlon.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

struct DecathlonView: View {
    @State var hundredMScore: Int = 0
    @State var hundredMPoint: Int = 0

    var body: some View {
        ScrollView {
            VStack {
                GroupBox {
                    Text("100m")
                    TextField("", value: $hundredMScore, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                Button(action: {
                    let model = CombinedModel(score: hundredMScore, event: .Run(.hundredM))
                    hundredMPoint = model.point
                }, label: {
                    Text("Calc")
                })
                Text(String(hundredMPoint))
            }
        }
    }
}

#Preview {
    DecathlonView()
        .modelContainer(for: Item.self, inMemory: true)
}
