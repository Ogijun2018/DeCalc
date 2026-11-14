//
//  ShareResultView.swift
//  DeCalc
//

import SwiftUI

/// 結果カードのプレビューと、画像・テキストでのシェアを行う画面
struct ShareResultView: View {
  @StateObject var viewModel: ShareResultViewModel
  @Environment(\.dismiss) private var dismiss
  @Environment(\.displayScale) private var displayScale
  /// 画像として書き出した結果カード
  @State private var cardImage: Image?

  var body: some View {
    NavigationStack {
      ScrollView {
        ScoreCardView(viewModel: viewModel)
          .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
          .padding()
      }
      .frame(maxWidth: .infinity)
      .background(Color.backgroundColor)
      .safeAreaInset(edge: .bottom) {
        HStack(spacing: 12) {
          if let cardImage {
            ShareLink(
              item: cardImage,
              preview: SharePreview(viewModel.title, image: cardImage)
            ) {
              Label("Share image", systemImage: "photo")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
          }
          ShareLink(item: viewModel.summaryText) {
            Label("Share text", systemImage: "text.alignleft")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
        }
        .controlSize(.large)
        .padding()
      }
      .navigationTitle("Share result")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
      .task {
        renderCardImage()
      }
    }
    .tint(Color.primaryColor)
  }

  /// 結果カードを画像に書き出す
  @MainActor
  private func renderCardImage() {
    let renderer = ImageRenderer(content: ScoreCardView(viewModel: viewModel))
    renderer.scale = displayScale
    if let uiImage = renderer.uiImage {
      cardImage = Image(uiImage: uiImage)
    }
  }
}

#Preview {
  ShareResultView(viewModel: .init(
    combinedEventInfo: .init(event: .decathlon, events: CombinedEvent.decathlon.events)
  ))
}
