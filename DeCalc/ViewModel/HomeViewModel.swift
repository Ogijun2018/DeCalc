//
//  HomeViewModel.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/31.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var selectedGender: Gender
    @Published var router: Router?

    init(selectedGender: Gender = .Men) {
        self.selectedGender = selectedGender
    }

    func genderButtonTapped(gender: Gender) {
        selectedGender = gender
    }
}
