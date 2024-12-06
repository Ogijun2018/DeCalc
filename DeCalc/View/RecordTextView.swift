import SwiftUI

struct RecordTextView: View {
    @State private var record: Int?
    @FocusState private var isFocused: Bool

    var numberLength: Int
    var leadingUnit: String?
    var centerUnit: String
    var trailingUnit: String?
    var unitPoint: Int
    /// 長距離種目かどうか
    var isLongRunning: Bool = false
    var keyboardType: UIKeyboardType = .numberPad
    var onComplete: (Int) -> ()

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
            HStack(alignment: .center) {
                Spacer()
                ForEach(isLongRunning ? 0..<numberLength + 3 : 0..<numberLength + 2, id: \.self) { i in
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
                    } else if i == numberLength + 1 {
                        // 最後の場合、末尾の単位があれば表示
                        if let trailingUnit {
                            Text(trailingUnit)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(alignment: .bottom)
                        }
                    } else if i != unitPoint {
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(
                                    width: 40,
                                    height: 40
                                )
                            Text(getPin(at: getPinIndex(index: i)))
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                    }
                }
                Spacer()
            }
            RecordTextField(
                record: $record,
                numberLength: numberLength,
                isFocused: $isFocused
            ) {
                onComplete(record ?? 0)
            }
        }
        .onTapGesture {
            print("onTapGesture")
            self.isFocused = true
        }
        .onAppear{
            UITextField.appearance().clearButtonMode = .never
            UITextField.appearance().tintColor = UIColor.clear
        }
        .padding()
    }

    func getPin(at index: Int) -> String {
        guard let record else {
            return ""
        }
        let stringRecord = String(record)
        guard index >= 0 && stringRecord.count > index else {
            return ""
        }
        // String.Indexを計算
        let stringIndex = stringRecord.index(stringRecord.startIndex, offsetBy: index)

        // 該当文字を返す
        return String(stringRecord[stringIndex])
    }

    /// 実際には表示されないTextField
    /// このTextFieldで変更された数値をBindしてRecordTextViewで表示している
    struct RecordTextField: View {
        @Binding var record: Int?
        var numberLength: Int
        @FocusState.Binding var isFocused: Bool
        var didComplete: (() -> Void)?

        // NOTE: TextField(_, value, format: .number)を使うと自動的にカンマ区切りがついてしまい、表示が崩れるため独自でFormatterを作成している
        @State private var numberFormatter: NumberFormatter = {
            var nf = NumberFormatter()
            nf.numberStyle = .decimal
            // カンマ区切りを行わない
            nf.usesGroupingSeparator = false
            return nf
        }()

        var body: some View {
            TextField(
                "", value: $record,
                formatter: numberFormatter
            )
                .frame(width: 0, height: 0, alignment: .center)
                .focused($isFocused)
                .keyboardType(.numberPad)
                .onChange(of: record) {
                    guard let record, String(record).count >= numberLength else { return }
                    // 最初に入力されたnumberLength分だけ取り出してあとは切り捨てる
                    self.record = Int(String(record).prefix(numberLength))
                    didComplete?()
                }
        }
    }
}

#Preview {
    RecordTextView(
        numberLength: 5,
        leadingUnit: ":",
        centerUnit: "\"",
        trailingUnit: nil,
        unitPoint: 5,
        isLongRunning: true,
        onComplete: { value in
            print(value)
        }
    )
}
