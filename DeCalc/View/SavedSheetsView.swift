//
//  SavedSheetsView.swift
//  DeCalc
//

import SwiftUI

/// 保存した記録の一覧画面。自己ベストの記録と、現在の目標の記録に印を付ける
struct SavedSheetsView: View {
  @StateObject var viewModel: SavedSheetsViewModel

  var body: some View {
    Group {
      if viewModel.rows.isEmpty {
        ContentUnavailableView(
          "No saved scores",
          systemImage: "tray",
          description: Text("Save your scores from the menu to compare them with your personal best.")
        )
      } else {
        List {
          Section(viewModel.combinedEvent.localizedName) {
            ForEach(viewModel.rows) { row in
              NavigationLink {
                SavedSheetDetailView(row: row)
              } label: {
                rowLabel(row)
              }
            }
            .onDelete { viewModel.delete(at: $0) }
          }
        }
      }
    }
    .sheetNavigation(title: "Saved scores")
  }

  /// 一覧の1行（タイトル・日時・目標と自己ベストの印・合計点）
  private func rowLabel(_ row: SavedSheetsViewModel.Row) -> some View {
    HStack(spacing: 8) {
      VStack(alignment: .leading, spacing: 2) {
        Text(row.title)
          .font(.headline)
        if let subtitle = row.subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
      if row.isTarget {
        Image(systemName: "target")
          .foregroundStyle(Color.primaryColor)
          .accessibilityLabel("Target")
      }
      if row.isPersonalBest {
        Image(systemName: "crown.fill")
          .foregroundStyle(.yellow)
          .accessibilityLabel("Personal best")
      }
      Text(points: row.total)
        .font(.headline.monospacedDigit())
    }
  }
}

/// 保存した記録1件の詳細（種目ごとの記録と得点）
struct SavedSheetDetailView: View {
  let row: SavedSheetsViewModel.Row

  var body: some View {
    List {
      Section {
        LabeledContent("Total Point") {
          Text(points: row.total)
            .font(.headline.monospacedDigit())
            .foregroundStyle(.primary)
        }
      }
      Section {
        ForEach(row.details) { detail in
          HStack {
            Text(detail.name)
              .fontWeight(.semibold)
            Spacer()
            Text(verbatim: detail.record ?? "-")
              .foregroundStyle(.secondary)
            Text(String(detail.point))
              .fontWeight(.bold)
              .frame(minWidth: 48, alignment: .trailing)
          }
          .monospacedDigit()
        }
      }
    }
    .navigationTitle(row.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  SavedSheetsView(viewModel: .init(combinedEvent: .decathlon))
}
