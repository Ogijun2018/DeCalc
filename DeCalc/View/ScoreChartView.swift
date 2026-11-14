//
//  ScoreChartView.swift
//  DeCalc
//

import SwiftUI
import Charts

/// 種目別の得点を棒グラフで表示し、得意・不得意を見える化する画面
struct ScoreChartView: View {
  private enum Const {
    static let barHeight: CGFloat = 36
  }

  @StateObject var viewModel: ScoreChartViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.hasData {
          List {
            Section(viewModel.title) {
              chart
                .frame(height: CGFloat(viewModel.entries.count) * Const.barHeight + 40)
                .padding(.vertical, 8)
            }
            summarySection
          }
        } else {
          ContentUnavailableView(
            "No scores yet",
            systemImage: "chart.bar.xaxis",
            description: Text("Enter records to see the breakdown by event.")
          )
        }
      }
      .navigationTitle("Score breakdown")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
    .tint(Color.primaryColor)
  }

  /// 種目別得点の横棒グラフ（破線は平均点）
  private var chart: some View {
    Chart {
      ForEach(viewModel.entries) { entry in
        BarMark(
          x: .value("Points", entry.point),
          y: .value("Event", entry.name)
        )
        .foregroundStyle(barColor(for: entry))
        .cornerRadius(4)
        .annotation(position: .trailing) {
          if entry.point > 0 {
            Text(String(entry.point))
              .font(.caption.weight(.semibold).monospacedDigit())
              .foregroundStyle(.secondary)
          }
        }
      }
      if let average = viewModel.average {
        RuleMark(x: .value("Average", average))
          .foregroundStyle(Color.secondary)
          .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
      }
    }
    .chartXAxis {
      AxisMarks(position: .bottom)
    }
  }

  /// 平均・得意種目・不得意種目
  @ViewBuilder
  private var summarySection: some View {
    Section {
      if let average = viewModel.average {
        LabeledContent("Average per event") {
          Text("\(average) pt")
        }
      }
      if let best = viewModel.best {
        LabeledContent("Best event") {
          Text(verbatim: "\(best.name)  \(best.point)")
        }
      }
      if let weakest = viewModel.weakest {
        LabeledContent("Weakest event") {
          Text(verbatim: "\(weakest.name)  \(weakest.point)")
        }
      }
    }
    .monospacedDigit()
  }

  /// 最も得点が高い種目を濃く、それ以外を薄く塗る
  private func barColor(for entry: ScoreChartViewModel.Entry) -> Color {
    guard let best = viewModel.best else { return Color.primaryColor }
    return entry.id == best.id ? Color.primaryColor : Color.primaryColor.opacity(0.55)
  }
}

#Preview {
  ScoreChartView(viewModel: .init(
    combinedEventInfo: .init(event: .decathlon, events: CombinedEvent.decathlon.events)
  ))
}
