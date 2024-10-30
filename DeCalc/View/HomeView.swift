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
//    var image: String
    var name: String
    var gender: Gender
//    var color: Color
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject var viewModel: HomeViewModel

    // Animationの発火はtoggle()することでしか実現できない？
    @State private var menIconBounce: Bool = false
    @State private var womenIconBounce: Bool = false

    let cells = [
        Cell(name: "男子十種競技", gender: .Men),
        Cell(name: "女子七種競技", gender: .Women),
        Cell(name: "男子八種競技", gender: .Men),
        Cell(name: "女子四種競技", gender: .Women),
        Cell(name: "男子四種競技", gender: .Men)
    ]

    @ViewBuilder
    func destinationView(for cell: Cell) -> some View {
        switch cell.name {
        case "男子十種競技": DecathlonView()
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
                                viewModel.selectedGender == cell.gender ? ClaymorphismButton(title: cell.name) : nil
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
