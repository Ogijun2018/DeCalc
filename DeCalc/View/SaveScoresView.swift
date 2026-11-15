//
//  SaveScoresView.swift
//  DeCalc
//

import SwiftUI

/// 記録の保存画面。名前と、自己ベスト・目標として保存するかを選ぶ
struct SaveScoresView: View {
  @StateObject var viewModel: SaveScoresViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Name (optional)", text: $viewModel.name)
        } footer: {
          Text("The scores are saved on this device only.")
        }
        Section {
          Toggle("Save as personal best", isOn: $viewModel.isPersonalBest)
          Toggle("Save as target", isOn: $viewModel.isTarget)
        } footer: {
          Text("Personal bests and the target are compared with your scores in each event. A newly saved target replaces the current one.")
        }
      }
      .navigationTitle("Save scores")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            viewModel.saveButtonDidTap()
            dismiss()
          }
        }
      }
    }
    .tint(Color.primaryColor)
    .presentationDetents([.medium, .large])
    .sensoryFeedback(.success, trigger: viewModel.saveFeedbackTrigger)
  }
}

#Preview {
  SaveScoresView(viewModel: .init(combinedEventInfo: .init(event: .decathlon, events: CombinedEvent.decathlon.events)))
}
