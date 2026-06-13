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
    static let cornerRadius: CGFloat = 20.0
  }

  let title: String
  let subTitle: String
  let imagePath: String

  var body: some View {
    GlassEffectContainer {
      ZStack {
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
            .glassEffect(
              .clear.tint(Color.secondaryColor.opacity(0.4)),
              in: .capsule
            )
            .overlay(
              Capsule()
                .stroke(Color.primaryColor.opacity(0.5), lineWidth: 1)
            )
        }
      }
      // 画像がカード外にはみ出さないよう角丸でクリップ
      .clipShape(
        RoundedRectangle(cornerRadius: Const.cornerRadius, style: .continuous)
      )
      // カード背景を不透明な塗りからLiquid Glassの透明な背景に置き換え
      .glassEffect(
        .regular,
        in: RoundedRectangle(cornerRadius: Const.cornerRadius, style: .continuous)
      )
      .shadow(radius: Const.cornerRadius)
    }
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

