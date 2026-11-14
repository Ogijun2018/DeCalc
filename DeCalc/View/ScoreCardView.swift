//
//  ScoreCardView.swift
//  DeCalc
//

import SwiftUI

/// シェア用の結果カード
/// 画像として書き出すため、Liquid Glassなどの動的な効果は使わず固定の配色で描画する
struct ScoreCardView: View {
  private enum Const {
    static let width: CGFloat = 360
    static let cornerRadius: CGFloat = 24
  }

  let viewModel: ShareResultViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      header
      Divider()
      Grid(alignment: .trailing, horizontalSpacing: 12, verticalSpacing: 10) {
        ForEach(viewModel.rows) { row in
          GridRow {
            Text(row.name)
              .fontWeight(.semibold)
              .gridColumnAlignment(.leading)
            Text(verbatim: row.record ?? "-")
              .foregroundStyle(Color.black.opacity(0.6))
            Text(String(row.point))
              .fontWeight(.bold)
          }
        }
      }
      .font(.callout.monospacedDigit())
      .frame(maxWidth: .infinity, alignment: .leading)
      Divider()
      HStack {
        Text(verbatim: "DeCalc")
          .fontWeight(.heavy)
          .foregroundStyle(Color.primaryColor)
        Spacer()
        Text(viewModel.dateText)
          .foregroundStyle(Color.black.opacity(0.6))
      }
      .font(.footnote)
    }
    .padding(24)
    .frame(width: Const.width)
    .foregroundStyle(Color.black)
    .background(
      RoundedRectangle(cornerRadius: Const.cornerRadius, style: .continuous)
        .fill(Color.white)
    )
    .overlay(
      RoundedRectangle(cornerRadius: Const.cornerRadius, style: .continuous)
        .stroke(Color.primaryColor.opacity(0.3), lineWidth: 1)
    )
    // 端末がダークモードでも同じ見た目で書き出す
    .environment(\.colorScheme, .light)
  }

  /// 競技名と合計点
  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(viewModel.title)
        .font(.title2.weight(.heavy))
        .foregroundStyle(Color.primaryColor)
      Text(viewModel.subtitle)
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Color.black.opacity(0.6))
      HStack(alignment: .firstTextBaseline, spacing: 6) {
        Text(String(viewModel.total))
          .font(.system(size: 48, weight: .heavy).monospacedDigit())
        Text("pt")
          .font(.title3.weight(.bold))
      }
      .padding(.top, 4)
    }
  }
}

#Preview {
  ScoreCardView(viewModel: .init(
    combinedEventInfo: .init(event: .decathlon, events: CombinedEvent.decathlon.events)
  ))
  .padding()
  .background(Color.gray.opacity(0.2))
}
