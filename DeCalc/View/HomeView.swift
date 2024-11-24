//
//  HomeView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

struct Cell: Identifiable {
    var id = UUID()
    var name: String
    var jpName: String
    var gender: Gender
    var imagePath: String
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject var viewModel: HomeViewModel

    // Animationの発火はtoggle()することでしか実現できない？
    @State private var menIconBounce: Bool = false
    @State private var womenIconBounce: Bool = false

    let cells = [
        Cell(name: "Decathlon", jpName: "十種競技", gender: .Men, imagePath: "ten_hero_image"),
        Cell(name: "Heptathlon", jpName: "七種競技",gender: .Women, imagePath: "seven_hero_image"),
        Cell(name: "Octathlon", jpName: "八種競技", gender: .Men, imagePath: "eight_hero_image"),
        Cell(name: "Tetrathlon", jpName: "四種競技", gender: .Women, imagePath: "four_hero_image"),
        Cell(name: "Tetrathlon", jpName: "四種競技", gender: .Men, imagePath: "four_hero_image")
    ]

    @ViewBuilder
    func destinationView(for cell: Cell) -> some View {
        switch cell.name {
        case "Decathlon": DecathlonView()
        default:
            DecathlonView()
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        viewModel.genderButtonTapped(gender: .Men)
                        menIconBounce.toggle()
                    }) {
                        Image(systemName: "figure.stand")
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(viewModel.selectedGender == .Men ? .blue : .gray)
                            .font(.system(size: 30))
                            .symbolEffect(.bounce, value: menIconBounce)
                    }.frame(
                        maxWidth: .infinity,
                        minHeight: 30
                    ).buttonStyle(.plain)
                    Button(action: {
                        viewModel.genderButtonTapped(gender: .Women)
                        womenIconBounce.toggle()
                    }) {
                        Image(systemName: "figure.stand.dress")
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(viewModel.selectedGender == .Women ? .red : .gray)
                            .font(.system(size: 30))
                            .symbolEffect(.bounce, value: womenIconBounce)
                    }.frame(
                        maxWidth: .infinity,
                        minHeight: 30
                    ).buttonStyle(.plain)
                }
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(cells) { cell in
                            NavigationLink(
                                destination: destinationView(for: cell)
                            ) {
                                viewModel.selectedGender == cell.gender ? ClaymorphismButton(
                                    title: cell.name,
                                    subTitle: cell.jpName,
                                    imagePath: cell.imagePath
                                ) : nil
                            }
                        }
                    }.padding()
                }
            }
        }
    }
}

#Preview {
    HomeView(viewModel: .init(selectedGender: .Men))
        .modelContainer(for: Item.self, inMemory: true)
}
