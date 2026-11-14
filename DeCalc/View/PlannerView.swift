//
//  PlannerView.swift
//  DeCalc
//

import SwiftUI

/// 目標合計点を設定し、残り種目で必要な得点・記録の目安を確認する画面
struct PlannerView: View {
  @StateObject var viewModel: PlannerViewModel
  @Environment(\.dismiss) private var dismiss
  @FocusState private var isTargetFocused: Bool

  /// ViewModelのtargetと相互変換するテキスト
  private var targetText: Binding<String> {
    Binding(
      get: { viewModel.targetText },
      set: { viewModel.targetTextDidChange($0) }
    )
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Target total") {
          HStack(alignment: .firstTextBaseline) {
            TextField("0", text: targetText)
              .keyboardType(.numberPad)
              .font(.title.weight(.bold).monospacedDigit())
              .focused($isTargetFocused)
            Text("pt")
              .font(.title3.weight(.semibold))
          }
        }

        if let plan = viewModel.plan {
          summarySection(plan)
          if plan.isAchieved {
            Section {
              Label("Target reached!", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(.green)
            }
          } else if !plan.requirements.isEmpty {
            requirementsSection(plan)
          }
          Section {
            Button("Clear target", role: .destructive) {
              viewModel.clearButtonDidTap()
            }
          }
        } else {
          Section {
            Text("Set a target total to see how many points you still need.")
              .foregroundStyle(.secondary)
          }
        }
      }
      .scrollDismissesKeyboard(.immediately)
      .navigationTitle("Target planner")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
      .onAppear {
        // 目標が未設定のときはすぐ入力できるようにする
        isTargetFocused = viewModel.target == nil
      }
    }
    .tint(Color.primaryColor)
  }

  /// 現在の合計・残り・1種目あたりの必要得点
  private func summarySection(_ plan: TargetPlan) -> some View {
    Section {
      LabeledContent("Current total") {
        Text("\(plan.currentPoint) pt")
      }
      LabeledContent("Remaining") {
        Text("\(plan.remainingPoint) pt")
          .fontWeight(.bold)
          .foregroundStyle(Color.primaryColor)
      }
      if let averagePoint = plan.averagePoint {
        LabeledContent("Average needed per event") {
          Text("\(averagePoint) pt")
        }
      }
    }
    .monospacedDigit()
  }

  /// 記録の目安を表示できない理由
  private func unavailableText(_ reason: TargetPlan.Requirement.Unavailable?) -> Text {
    switch reason {
    case .aboveMaximum: Text("Above this event's maximum")
    case .outOfInputRange, nil: Text("Outside the input range")
    }
  }

  /// 残り種目ごとの記録の目安
  private func requirementsSection(_ plan: TargetPlan) -> some View {
    Section {
      ForEach(plan.requirements) { requirement in
        LabeledContent {
          if let record = requirement.record {
            Text(verbatim: record)
              .font(.body.weight(.semibold).monospacedDigit())
              .foregroundStyle(.primary)
          } else {
            // 目安を出せない場合は理由を表示する
            unavailableText(requirement.unavailable)
              .font(.footnote)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.trailing)
          }
        } label: {
          Text(requirement.name)
        }
      }
    } header: {
      Text("Guide for remaining events")
    } footer: {
      Text("Records needed to score the average in each remaining event.")
    }
  }
}

#Preview {
  PlannerView(viewModel: .init(
    combinedEventInfo: .init(event: .decathlon, events: CombinedEvent.decathlon.events)
  ))
}
