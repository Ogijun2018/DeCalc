//
//  EventButton.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI

struct EventButton: View {
    private enum Const {
        static let imageSize: CGFloat = 200
        static let cornerRadius: CGFloat = 10.0
    }

    let title: String
    let subTitle: String
    let imagePath: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Const.cornerRadius)
                .fill(Color.secondaryColor)
            Image(imagePath)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 150)
                .offset(x: -100, y: 50)
            VStack(alignment: .center, spacing: 5) {
                Text(title)
                    .font(.system(size: 40, weight: .heavy, design: .default))
                    .frame(maxWidth: .infinity)
                    // 指定した倍率まで縮小され、それより小さい場合は`…`に省略
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(Color.primaryColor)
                Text(subTitle)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 5)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(Color.primaryColor)
                    .background(
                        Capsule()
                            .fill(Color.secondaryColor)
                            .stroke(Color.primaryColor, lineWidth: 3)
                    )
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: Const.cornerRadius)
        )
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    Group {
        EventButton(
            title: "Decathlon",
            subTitle: "十種競技",
            imagePath: "ten_hero"
        )
        EventButton(
            title: "Octathlon",
            subTitle: "八種競技",
            imagePath: "eight_hero"
        )
        EventButton(
            title: "Tetrathlon",
            subTitle: "四種競技",
            imagePath: "four_hero"
        )
        EventButton(
            title: "Heptathlon",
            subTitle: "七種競技",
            imagePath: "seven_hero"
        )
    }
}

