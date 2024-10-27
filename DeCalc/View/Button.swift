//
//  Button.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI

struct ClaymorphismButton: View {
    let buttonColor = Color.init(red: 0.38, green: 0.28, blue: 0.86)
    let lightColor = Color.init(red: 0.54, green: 0.41, blue: 0.95)
    let shadowColor = Color.init(red: 0.25, green: 0.17, blue: 0.75)
    let radius = CGFloat(15)

    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold, design: .default))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(
                        // shadowでボタン上部に光沢を持たせる
                        // .innerはiOS16から対応
                        .shadow(.inner(color: lightColor, radius: 6, x: 4, y: 4))
                        // shadowでボタン下部に影を落とす
                        .shadow(.inner(color: shadowColor, radius: 6, x: -2, y: -2))
                    )
                    .foregroundColor(buttonColor)
                    // ボタンのshadowはボタンの色に合わせる
//                        .shadow(color: buttonColor, radius: 20, y: 10)
            )
    }
}
