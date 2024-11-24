//
//  Button.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/10/27.
//

import SwiftUI

struct ClaymorphismButton: View {
    private enum Const {
        static let imageSize: CGFloat = 75
        static let cornerRadius: CGFloat = 10.0
    }

    let title: String
    let subTitle: String
    let imagePath: String

    var body: some View {
        HStack {
            Image(imagePath)
                .resizable()
                .scaledToFit()
                .frame(width: Const.imageSize, height: Const.imageSize)
                .padding(2)
                .shadow(radius: 5, x: 3, y: 3)
                .background(
                    RoundedRectangle(cornerRadius: Const.cornerRadius + 5)
                        .foregroundColor(.white)
                )
            VStack(alignment: .center, spacing: 5) {
                Text(title)
                    .font(.system(size: 40, weight: .heavy, design: .default))
                    // 指定した倍率まで縮小され、それより小さい場合は`…`に省略
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(.white)
                    .italic()
                Text(subTitle)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 5)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .stroke(Color.gray, lineWidth: 4)
                            .shadow(radius: 2)
                    )
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: Const.cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [.gray, .black, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(radius: 5)
        )
    }
}

#Preview {
    ClaymorphismButton(
        title: "Decathlon",
        subTitle: "十種競技",
        imagePath: "ten_hero_image"
    )
}

