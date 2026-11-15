//
//  PlannerView.swift
//  DeCalc
//

import SwiftUI

/// 目標合計点を設定し、残り種目で必要な得点・記録の目安を確認する画面
struct PlannerView: View {
  @StateObject var viewModel: PlannerViewModel
  @FocusState private var isTargetFocused: Bool

  /// ViewModelのtargetと相互変換するテキスト
  private var targetText: Binding<String> {
    Binding(
      get: { viewModel.targetText },
      set: { viewModel.targetTextDidChange($0) }
    )
  }

  var body: some View {
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
    .onAppear {
      // 目標が未設定のときはすぐ入力できるようにする
      isTargetFocused = viewModel.target == nil
    }
    .sheetNavigation(title: "Target planner")
  }

  /// 現在の合計・残り・1種目あたりの必要得点
  private func summarySection(_ plan: TargetPlan) -> some View {
    Section {
      LabeledContent("Current total") {
        Text(points: plan.currentPoint)
      }
      LabeledContent("Remaining") {
        Text(points: plan.remainingPoint)
          .fontWeight(.bold)
          .foregroundStyle(Color.primaryColor)
      }
      if let averagePoint = plan.averagePoint {
        LabeledContent("Average needed per event") {
          Text(points: averagePoint)
        }
      }
    }
    .monospacedDigit()
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
            // その種目の最高得点でも届かない場合
            Text("Above this event's maximum")
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
