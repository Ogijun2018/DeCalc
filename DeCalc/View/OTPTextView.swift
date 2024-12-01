import SwiftUI

struct OTPTextView: View {
    @State private var verificationCode = ""
    @FocusState private var focusField: FocusField?

    var pinLength: Int
    var leadingUnit: String?
    var centerUnit: String
    var trailingUnit: String?
    var unitPoint: Int
    /// 長距離種目かどうか
    var isLongRunning: Bool = false
    var keyboardType: UIKeyboardType = .numberPad
    var onComplete: (String) -> ()

    // TODO: ここロジックやばいから整理
    func getPinIndex(index: Int) -> Int {
        // index: 今もらってきてるindex
        // 長距離種目の場合
        if isLongRunning {
            if index > 5 {
                return index - 2
            } else if index > unitPoint {
                return index - 1
            } else {
                return index
            }
        } else {
            return index <= unitPoint ? index : index - 1
        }
    }

    var body: some View {
        ZStack(alignment: .center) {
            OTPTextField(verificationCode: $verificationCode, pinLength: pinLength, keyboardType: keyboardType) {
                onComplete(verificationCode)
            }
            HStack {
                ForEach(isLongRunning ? 0..<pinLength + 3 : 0..<pinLength + 2, id: \.self) { i in
                    if isLongRunning && i == 2 {
                        if let leadingUnit {
                            Text(leadingUnit)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(alignment: .bottom)
                        }
                    } else if i == unitPoint {
                        Text(centerUnit)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(alignment: .bottom)
                    } else if i == pinLength + 1 {
                        // 最後の場合、末尾の単位があれば表示
                        if let trailingUnit {
                            Text(trailingUnit)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(alignment: .bottom)
                        }
                    } else if i != unitPoint {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.gray)
                                .padding(.vertical, 5)
                            Text(getPin(at: getPinIndex(index: i)))
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .onAppear{
            UITextField.appearance().clearButtonMode = .never
            UITextField.appearance().tintColor = UIColor.clear
        }
    }

    func getPin(at index: Int) -> String {
        guard index >= 0 && self.verificationCode.count > index else {
            return ""
        }
        // String.Indexを計算
        let stringIndex = verificationCode.index(verificationCode.startIndex, offsetBy: index)

        // 該当文字を返す
        return String(verificationCode[stringIndex])
    }
}

#Preview {
    OTPTextView(
        pinLength: 6,
        leadingUnit: ":",
        centerUnit: "\"",
        trailingUnit: nil,
        unitPoint: 5,
        isLongRunning: true,
        onComplete: { value in
            print(value)
        }
    )
    .frame(width: 200, height: 100)
    .background(.red)
}
