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
        Picker("Gender", selection: $viewModel.selectedGender) {
          Text("Men").tag(Gender.Men)
          Text("Women").tag(Gender.Women)
        }
        .controlSize(.large)
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 8)

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
      }
    }
  }
}

#Preview {
  HomeView(viewModel: .init(selectedGender: .Men))
}
