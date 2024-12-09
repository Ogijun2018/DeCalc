import SwiftUI

struct RecordTextView: View {
    @State private var record: String = ""
    @FocusState.Binding var isFocused: Focus?

    var numberLength: Int
    var leadingUnit: String?
    var centerUnit: String
    var trailingUnit: String?
    var unitPoint: Int
    var textFieldId: Int
    /// 長距離種目かどうか
    var isLongRunning: Bool = false
    var keyboardType: UIKeyboardType = .numberPad
    var onComplete: ((Int) -> Void)?
    var onPressTextView: (() -> Void)?

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
                textFieldId: textFieldId,
                isFocused: $isFocused
            ) {
                // 入力が完了したらIntに変換して計算を行う
                onComplete?(Int(record) ?? 0)
            }
        }
        .onAppear{
            UITextField.appearance().clearButtonMode = .never
            UITextField.appearance().tintColor = UIColor.clear
        }
        .padding()
        // contentShapreを行うことでTextView全体をタップ可能にする
        // 参照: https://www.hackingwithswift.com/quick-start/swiftui/how-to-control-the-tappable-area-of-a-view-using-contentshape
        .contentShape(Rectangle())
        .onTapGesture {
            onPressTextView?()
        }
    }

    func getPin(at index: Int) -> String {
        guard index >= 0 && record.count > index else {
            return ""
        }
        // String.Indexを計算
        let stringIndex = record.index(record.startIndex, offsetBy: index)

        // 該当文字を返す
        return String(record[stringIndex])
    }

    /// 実際には表示されないTextField
    /// このTextFieldで変更された数値をBindしてRecordTextViewで表示している
    struct RecordTextField: View {
        // recordは0始まりを許容しなければならないため、IntではなくStringを使用している
        // 例: 100m 09"98
        @Binding var record: String
        var numberLength: Int
        var textFieldId: Int
        @FocusState.Binding var isFocused: Focus?
        var didComplete: (() -> Void)?

        var body: some View {
            TextField("", text: $record)
                .frame(width: 0, height: 0, alignment: .center)
                .focused($isFocused, equals: .focused(id: textFieldId))
                .keyboardType(.numberPad)
                .onChange(of: record) {
                    // 数値以外の入力があった場合はrecordの内容を消去する
                    guard let _ = Int(record) else {
                        self.record = ""
                        return
                    }
                    guard record.count >= numberLength else { return }
                    // 最初に入力されたnumberLength分だけ取り出してあとは切り捨てる
                    self.record = String(record.prefix(numberLength))
                    didComplete?()
                }
        }
    }
}

#Preview {
    @FocusState var isFocused: Focus?
    RecordTextView(
        isFocused: $isFocused,
        numberLength: 5,
        leadingUnit: ":",
        centerUnit: "\"",
        trailingUnit: nil,
        unitPoint: 5,
        textFieldId: 5,
        isLongRunning: true
    )
}
