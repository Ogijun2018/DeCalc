//
//  HomeView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI
import SwiftData

struct HomeView: View {
  //    @Environment(\.modelContext) private var modelContext
  @StateObject var viewModel: HomeViewModel

  // Animationの発火はtoggle()することでしか実現できない？
  @State private var menIconBounce: Bool = false
  @State private var womenIconBounce: Bool = false

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
        HStack {
          Button(action: {
            viewModel.genderButtonTapped(gender: .Men)
            menIconBounce.toggle()
          }) {
            Image(systemName: "figure.stand")
              .symbolRenderingMode(.multicolor)
              .foregroundStyle(viewModel.selectedGender == .Men ? .blue : .gray)
              .font(.system(size: 30))
              .symbolEffect(.bounce, value: menIconBounce)
          }.frame(
            maxWidth: .infinity,
            minHeight: 30
          ).buttonStyle(.plain)
          Button(action: {
            viewModel.genderButtonTapped(gender: .Women)
            womenIconBounce.toggle()
          }) {
            Image(systemName: "figure.stand.dress")
              .symbolRenderingMode(.multicolor)
              .foregroundStyle(viewModel.selectedGender == .Women ? .red : .gray)
              .font(.system(size: 30))
              .symbolEffect(.bounce, value: womenIconBounce)
          }.frame(
            maxWidth: .infinity,
            minHeight: 30
          ).buttonStyle(.plain)
        }
        .padding()
        .background(Color.secondaryColor)

        ScrollView {
          VStack(spacing: 0) {
            ForEach(buttons) { button in
              NavigationLink(
                destination: Router.Score(button.event)
              ) {
                viewModel.selectedGender == button.gender ? EventButton(
                  title: button.event.description,
                  subTitle: button.event.jpName,
                  imagePath: button.event.heroImagePath
                ) : nil
              }
            }
          }.padding()
        }
      }.background(Color.primaryColor)
    }
  }
}

#Preview {
  HomeView(viewModel: .init(selectedGender: .Men))
}
