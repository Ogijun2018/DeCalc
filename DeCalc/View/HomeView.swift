//
//  HomeView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI

struct HomeView: View {
  @StateObject var viewModel: HomeViewModel

  struct EventButtonInfo: Identifiable {
    var id = UUID()
    var gender: Gender
    var event: CombinedEvent
  }

  var buttons: [EventButtonInfo] = {
    let menEvents = CombinedEvent.menEvents.map {
      EventButtonInfo(
        gender: .Men,
        event: $0
      )
    }
    let womenEvents = CombinedEvent.womenEvents.map {
      EventButtonInfo(
        gender: .Women,
        event: $0
      )
    }
    return menEvents + womenEvents
  }()

  var body: some View {
    NavigationStack {
      VStack {
        GlassEffectContainer {
          HStack(spacing: 12) {
            Button(action: {
              viewModel.genderButtonTapped(gender: .Men)
            }) {
              Image(systemName: "figure.stand")
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(viewModel.selectedGender == .Men ? .blue : .gray)
                .font(.system(size: 30))
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .glassEffect(
              viewModel.selectedGender == .Men
                ? .regular.tint(.blue.opacity(0.25)).interactive()
                : .regular.interactive(),
              in: .capsule
            )

            Button(action: {
              viewModel.genderButtonTapped(gender: .Women)
            }) {
              Image(systemName: "figure.stand.dress")
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(viewModel.selectedGender == .Women ? .red : .gray)
                .font(.system(size: 30))
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .glassEffect(
              viewModel.selectedGender == .Women
                ? .regular.tint(.red.opacity(0.25)).interactive()
                : .regular.interactive(),
              in: .capsule
            )
          }
          .padding(.horizontal)
          .padding(.top, 8)
        }

        ScrollView {
          VStack(spacing: 0) {
            ForEach(buttons) { button in
              NavigationLink(
                destination: Router.Score(button.event)
              ) {
                viewModel.selectedGender == button.gender ? EventButton(
                  title: button.event.localizedName,
                  subTitle: button.event.description,
                  imagePath: button.event.heroImagePath
                ) : nil
              }
            }
          }.padding()
        }
      }.background(
        LinearGradient(
          colors: [
            // 明るい空色 #A6C8F2
            Color(red: 0.651, green: 0.784, blue: 0.949),
            // 既存のbackgroundColor #6E97E6（中間色）
            Color.backgroundColor,
            // やや深い青 #5E83DE
            Color(red: 0.369, green: 0.514, blue: 0.871)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
      )
    }
  }
}

#Preview {
  HomeView(viewModel: .init(selectedGender: .Men))
}
