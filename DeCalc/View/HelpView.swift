//
//  HelpView.swift
//  DeCalc
//

import SwiftUI

/// 入力方法と得点の計算式を説明するヘルプ画面
struct HelpView: View {
  @StateObject var viewModel: HelpViewModel

  var body: some View {
    List {
      Section("How to enter records") {
        Label("Enter digits only. Units are added automatically.", systemImage: "number")
        Label("Example: 10.50 seconds → 1050, 6.50 m → 650", systemImage: "character.cursor.ibeam")
        Label("Points are calculated automatically once all digits are entered.", systemImage: "p.circle")
      }

      Section("From points to record") {
        Label(
          "Enter points and tap the convert button to see the record needed to score them.",
          systemImage: "figure.run.circle"
        )
      }

      Section {
        ForEach(viewModel.formulaRows) { row in
          LabeledContent {
            Text(verbatim: row.formula)
              .font(.callout.monospaced())
          } label: {
            Text(row.title)
          }
        }
      } header: {
        Text("Scoring formula")
      } footer: {
        Text("T: time in seconds, M: height or distance in centimeters, D: distance in meters. Points are rounded down.")
      }

      Section(viewModel.combinedEvent.localizedName) {
        Grid(alignment: .trailing, horizontalSpacing: 12, verticalSpacing: 8) {
          GridRow {
            Text("Event")
              .gridColumnAlignment(.leading)
            Text(verbatim: "A")
            Text(verbatim: "B")
            Text(verbatim: "C")
          }
          .font(.caption)
          .foregroundStyle(.secondary)
          ForEach(viewModel.coefficientRows) { row in
            GridRow {
              Text(row.name)
                .fontWeight(.semibold)
              Text(row.a)
              Text(row.b)
              Text(row.c)
            }
          }
        }
        .font(.callout.monospacedDigit())
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      if let supportURL = viewModel.supportURL {
        Section {
          Link(destination: supportURL) {
            Label("Support page", systemImage: "safari")
          }
        }
      }
    }
    .sheetNavigation(title: "Help")
  }
}

#Preview {
  HelpView(viewModel: .init(combinedEvent: .decathlon))
}
