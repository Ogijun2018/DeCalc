//
//  Decathlon.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

struct Hoge: Identifiable {
    var id = UUID()
    var event: CombinedModel.Event
    var pinLength: Int
    // 記録の単位1（ex. :）
    // 1500m/800mのみ
    var leadingUnit: String?
    // 記録の単位2（ex. m, "）
    var centerUnit: String
    // 末尾の記録の単位（ex. cm）
    var trailingUnit: String?
    var score: Int = 0
    var unitPoint: Int
}

struct DecathlonView: View {
    @ObservedObject var viewModel = DecathlonViewModel()
    @State var hundredMScore: Int = 0
    @State var hundredMPoint: Int = 0

    enum Const {
        static let decathlon: [CombinedModel.Event] = [
            .Run(.hundredM),
            .Jump(.longjump(.Men)),
            .Throw(.shotput(.Men)),
            .Jump(.highjump(.Men)),
            .Run(.fourHundredM),
            .Run(.hundredTenMHurdles),
            .Throw(.discusThrow),
            .Jump(.paulVault),
            .Throw(.javelinThrow(.Men)),
            .Run(.thousandFiveHundredM)
        ]
    }

    let cells: [Hoge] = Const.decathlon.map {
        let (pinLength, unitOne, unitTwo, unitThree, unitPoint): (Int, String?, String, String?, Int) = switch $0 {
        case .Run(let event):
            switch event {
            case .eightHundredM, .thousandFiveHundredM: (6, "'", "\"", nil, 2)
            case .hundredM, .fourHundredM, .twoHundredM, .hundredMHurdles, .hundredTenMHurdles: (4, nil, "\"", nil, 2)
            }
        case .Jump(let event): (3, nil, "m", "cm", 1)
        case .Throw(let event): (4, nil, "m", "cm", 2)
        }
        return .init(
            event: $0,
            pinLength: pinLength,
            leadingUnit: unitOne,
            centerUnit: unitTwo,
            trailingUnit: unitThree,
            unitPoint: unitPoint
        )
    }

//    struct UnitInfo {
//        var leadingUnit: String?
//        var centerUnit: String
//        var trailingUnit: String?
//        var leadingUnitPoint: Int?
//        var centerUnitPoint: Int
//        var trailingUnitPoint: Int?
//    }

    @ViewBuilder
    func destinationView(for cell: Hoge) -> some View {
        GroupBox {
            Text(cell.event.description)
            OTPTextView(
                pinLength: cell.pinLength,
                leadingUnit: cell.leadingUnit,
                centerUnit: cell.centerUnit,
                trailingUnit: cell.trailingUnit,
                // 単位が入るポイント
                unitPoint: cell.unitPoint
            ) { value in
                print(value)
            }
            .background(.white)
        }
    }

    var body: some View {
        ScrollView {
            HStack {
                // 記録
                VStack {
                    Text("記録")
                    ForEach(cells) { cell in
                        destinationView(for: cell)
                    }
                    Button(action: {
                        viewModel.onPressCalcButton()
                        let model = CombinedModel(score: hundredMScore, event: .Run(.hundredM))
                        hundredMPoint = model.point
                    }, label: {
                        Text("Calc")
                    })
                    Text(String(viewModel.score))
                }
                Spacer().frame(width: 200)
            }
        }
    }
}

#Preview {
    DecathlonView()
        .modelContainer(for: Item.self, inMemory: true)
}
