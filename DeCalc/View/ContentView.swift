//
//  ContentView.swift
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
//    var color: Color
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    let cells = [
        Cell(name: "男子十種競技"),
        Cell(name: "女子七種競技"),
        Cell(name: "男子八種競技"),
        Cell(name: "女子四種競技"),
        Cell(name: "男子四種競技")
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
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(cells) { cell in
                        NavigationLink(
                            destination: destinationView(for: cell)
                        ) {
                            ClaymorphismButton(title: cell.name)
                        }
                    }
                }.padding()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
