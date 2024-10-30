//
//  TabItemView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/31.
//

import SwiftUI

struct TabPageEntry {
    let title: String
}

struct TabItemView: View {
    let pageEntry: TabPageEntry
    let isSelected: Bool
    let onSelected: () -> Void

    var body: some View {
        Button (
            action: onSelected,
            label: {
                HStack(spacing: 2) {
                    Text(pageEntry.title)
                        .foregroundStyle(isSelected ? Color.green : Color.gray)
                }
            }
        ).frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .frame(width: 24, height: 2)
                }
            }
    }
}
