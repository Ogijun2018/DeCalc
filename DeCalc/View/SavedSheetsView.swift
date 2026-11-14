//
//  SavedSheetsView.swift
//  DeCalc
//

import SwiftUI

/// 保存した記録の一覧画面。最も合計点が高い記録を自己ベストとして表示する
struct SavedSheetsView: View {
  @StateObject var viewModel: SavedSheetsViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.sheets.isEmpty {
          ContentUnavailableView(
            "No saved scores",
            systemImage: "tray",
            description: Text("Save your scores from the menu to compare them with your personal best.")
          )
        } else {
          List {
            Section(viewModel.combinedEvent.localizedName) {
              ForEach(viewModel.sheets) { sheet in
                NavigationLink {
                  SavedSheetDetailView(
                    title: viewModel.title(for: sheet),
                    total: sheet.total,
                    rows: viewModel.detailRows(for: sheet)
                  )
                } label: {
                  row(for: sheet)
                }
              }
              .onDelete { viewModel.delete(at: $0) }
            }
          }
        }
      }
      .navigationTitle("Saved scores")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
    .tint(Color.primaryColor)
  }

  /// 一覧の1行（タイトル・日付・合計点・自己ベストの印）
  private func row(for sheet: SavedScoreSheet) -> some View {
    HStack(spacing: 8) {
      VStack(alignment: .leading, spacing: 2) {
        Text(viewModel.title(for: sheet))
          .font(.headline)
        if !sheet.name.isEmpty {
          Text(viewModel.dateText(for: sheet))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
      if sheet.id == viewModel.personalBestID {
        Image(systemName: "crown.fill")
          .foregroundStyle(.yellow)
          .accessibilityLabel("Personal best")
      }
      Text(points: sheet.total)
        .font(.headline.monospacedDigit())
    }
  }
}

/// 保存した記録1件の詳細（種目ごとの記録と得点）
struct SavedSheetDetailView: View {
  let title: String
  let total: Int
  let rows: [SavedSheetsViewModel.DetailRow]

  var body: some View {
    List {
      Section {
        LabeledContent("Total Point") {
          Text(points: total)
            .font(.headline.monospacedDigit())
            .foregroundStyle(.primary)
        }
      }
      Section {
        ForEach(rows) { row in
          HStack {
            Text(row.name)
              .fontWeight(.semibold)
            Spacer()
            Text(verbatim: row.record ?? "-")
              .foregroundStyle(.secondary)
            Text(String(row.point))
              .fontWeight(.bold)
              .frame(minWidth: 48, alignment: .trailing)
          }
          .monospacedDigit()
        }
      }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  SavedSheetsView(viewModel: .init(combinedEvent: .decathlon))
}
