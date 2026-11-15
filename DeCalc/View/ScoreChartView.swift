//
//  ScoreChartView.swift
//  DeCalc
//

import SwiftUI

/// 種目別の得点を棒グラフで表示し、得意・不得意を見える化する画面
struct ScoreChartView: View {
  private enum Const {
    static let rowHeight: CGFloat = 36
    static let barHeight: CGFloat = 16
  }

  @StateObject var viewModel: ScoreChartViewModel
  /// 表示されたときに棒を伸ばすアニメーションの状態
  @State private var isBarShown = false

  var body: some View {
    Group {
      if viewModel.hasData {
        List {
          Section(viewModel.title) {
            VStack(alignment: .leading, spacing: 12) {
              chart
              legend
            }
            .padding(.vertical, 8)
          }
          kindSection
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
    .sheetNavigation(title: "Score breakdown")
    .onAppear {
      withAnimation(.snappy(duration: 0.6)) {
        isBarShown = true
      }
    }
  }

  /// 種目別得点の横棒グラフ（破線は平均点）
  /// 種目名・棒・得点を列にそろえて並べる。種目名の列は最も長い名前に合わせた幅になり、
  /// 残りの幅を棒に使うため、種目名がはみ出したり棒に重なったりしない
  private var chart: some View {
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
      ForEach(viewModel.entries) { entry in
        GridRow {
          kindLabel(entry.kind, name: entry.name)
            .fixedSize()
          bar(for: entry)
          Text(verbatim: entry.pointText)
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .fixedSize()
            .gridColumnAlignment(.trailing)
        }
      }
    }
    .font(.subheadline.weight(.semibold))
    // 文字を大きくしすぎると棒の幅がなくなるため、グラフの中だけ上限を設ける
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
  }

  /// 1種目分の棒。種類ごとの色で塗り、平均点の位置に破線を引く
  private func bar(for entry: ScoreChartViewModel.Entry) -> some View {
    GeometryReader { proxy in
      ZStack(alignment: .leading) {
        // 棒が伸びる範囲（0点側は角を丸めず、基準の線をそろえる）
        Self.barShape
          .fill(Color.primary.opacity(0.06))
          .frame(height: Const.barHeight)
        Self.barShape
          .fill(entry.kind.color.gradient)
          .frame(width: isBarShown ? proxy.size.width * entry.ratio : 0, height: Const.barHeight)
        if let averageRatio = viewModel.averageRatio {
          // 行の高さいっぱいに引き、上下の行とつながった1本の破線に見せる
          averageLine
            .frame(width: 1, height: proxy.size.height)
            .offset(x: proxy.size.width * averageRatio)
        }
      }
      .frame(height: proxy.size.height)
    }
    .frame(height: Const.rowHeight)
  }

  private static let barShape = UnevenRoundedRectangle(bottomTrailingRadius: 4, topTrailingRadius: 4)

  /// 平均点を表す縦の破線
  private var averageLine: some View {
    VerticalLine()
      .stroke(Color.primary.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
  }

  /// 凡例（種目の種類と平均点の破線）。横に並べて収まらない言語・文字サイズでは縦に並べる
  private var legend: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: 14) { legendItems }
      VStack(alignment: .leading, spacing: 4) { legendItems }
    }
    .font(.caption)
    .foregroundStyle(.secondary)
  }

  @ViewBuilder
  private var legendItems: some View {
    ForEach(viewModel.kindSummaries) { summary in
      kindLabel(summary.kind, name: summary.name)
    }
    HStack(spacing: 5) {
      // 幅を種類の印とそろえて、縦に並べたときも文字の位置がずれないようにする
      averageLine
        .frame(width: 11, height: 12)
        .accessibilityHidden(true)
      Text("Average")
        .lineLimit(1)
    }
  }

  /// 種類を表す印（色と形の両方で見分けられるようにする）と名前
  private func kindLabel(_ kind: Event.Kind, name: String) -> some View {
    HStack(spacing: 5) {
      Image(systemName: kind.symbolName)
        .font(.caption2)
        .foregroundStyle(kind.color)
        .accessibilityHidden(true)
      Text(name)
        .lineLimit(1)
    }
  }

  /// 種類（走・跳・投）ごとの平均
  @ViewBuilder
  private var kindSection: some View {
    Section("Average by event type") {
      ForEach(viewModel.kindSummaries) { summary in
        if let average = summary.average {
          LabeledContent {
            Text(points: average)
          } label: {
            kindLabel(summary.kind, name: summary.name)
          }
        }
      }
    }
    .monospacedDigit()
  }

  /// 平均・得意種目・不得意種目
  @ViewBuilder
  private var summarySection: some View {
    Section {
      if let average = viewModel.average {
        LabeledContent("Average per event") {
          Text(points: average)
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
}

/// 縦に1本引いた線
private struct VerticalLine: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.move(to: CGPoint(x: rect.midX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    }
  }
}

/// 種目の種類ごとの見た目（色と印の形）
private extension Event.Kind {
  var color: Color {
    switch self {
    case .run: .runEventColor
    case .jump: .jumpEventColor
    case .throwing: .throwEventColor
    }
  }

  /// 色だけに頼らず見分けられるよう、種類ごとに形を変える
  var symbolName: String {
    switch self {
    case .run: "circle.fill"
    case .jump: "triangle.fill"
    case .throwing: "square.fill"
    }
  }
}

#Preview {
  ScoreChartView(viewModel: .init(
    combinedEventInfo: .init(event: .decathlon, events: CombinedEvent.decathlon.events)
  ))
}
