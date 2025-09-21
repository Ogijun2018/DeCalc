import SwiftUI
import Combine

struct RecordTextView: View {
  @Binding var record: String?
  @FocusState.Binding var isFocused: Focus?

  var numberLength: Int
  /// TextView内に表示する単位
  /// ex. 1500m: ( `'`, `"`, `nil`)
  /// ex. 100m: (`nil`, `"`, `nil`)
  var units: (
    leading: String?,
    center: String,
    trailing: String?
  )
  var leadingUnitPoint: Int?
  var unitPoint: Int
  var textFieldId: Int
  var keyboardType: UIKeyboardType = .numberPad
  var onPressTextView: (() -> Void)?
  var scoreFilled: (() -> Void)?

  var body: some View {
    ZStack(alignment: .center) {
      HStack(alignment: .center) {
        ForEach(0..<numberLength, id: \.self) { index in
          ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 5)
              .stroke(isFocused == .focused(id: textFieldId)
                      ? Color.primaryColor
                      : .gray, lineWidth: 2)
              .frame(
                width: 40,
                height: 40
              )
            Text(getPin(at: index))
              .font(.system(size: 30))
              .fontWeight(.semibold)
              .foregroundColor(.black)
          }
          ForEach(Array(unitsToInsert(after: index).enumerated()), id: \.offset) { entry in
            unitLabel(entry.element)
          }
        }
        // unitPointが入力桁数を超えるケースを考慮
        if unitPoint > numberLength {
          unitLabel(units.center)
        }
        if let trailingUnit = units.trailing {
          unitLabel(trailingUnit)
        }
      }
      RecordTextField(
        record: $record,
        textFieldId: textFieldId,
        maxLength: numberLength,
        isFocused: $isFocused,
        onChanged: { text in
          guard let text else { return }
          record = text
          if text.count >= numberLength {
            scoreFilled?()
          }
        }
      )
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
    guard let record, index >= 0 && record.count > index else {
      return ""
    }
    // String.Indexを計算
    let stringIndex = record.index(record.startIndex, offsetBy: index)

    // 該当文字を返す
    return String(record[stringIndex])
  }

  /// 実際には表示されないTextField
  /// このTextFieldで変更された数値をonChangeで取得し、RecordTextViewでBindしているrecordを更新する
  struct RecordTextField: View {
    // recordは0始まりを許容しなければならないため、IntではなくStringを使用している
    // 例: 100m 09"98
    @Binding var record: String?
    var textFieldId: Int
    var maxLength: Int
    @FocusState.Binding var isFocused: Focus?
    var onChanged: ((String?) -> Void)?

    var body: some View {
      TextField("", text: $record ?? "")
        .onReceive(Just(record)) { _ in
          guard record != nil, record?.count ?? 0 > maxLength else { return }
          // maxLength桁以降の入力を制限
          record = String(record?.prefix(maxLength) ?? "")
        }
        .frame(width: 0, height: 0, alignment: .center)
        .focused($isFocused, equals: .focused(id: textFieldId))
        .keyboardType(.numberPad)
        .onChange(of: record, {
          onChanged?(record)
        })
    }
  }
}

private extension RecordTextView {
  func unitsToInsert(after index: Int) -> [String] {
    var insertions: [String] = []
    if let leadingUnitPoint,
       index + 1 == leadingUnitPoint,
       let leadingUnit = units.leading {
      insertions.append(leadingUnit)
    }
    if unitPoint > 0, index + 1 == unitPoint {
      insertions.append(units.center)
    }
    return insertions
  }

  @ViewBuilder
  func unitLabel(_ unit: String) -> some View {
    Text(unit)
      .font(.system(size: 20, weight: .semibold))
      .frame(alignment: .bottom)
  }
}

#Preview {
  @Previewable @State var record: String? = ""
  @FocusState var isFocused: Focus?
  RecordTextView(
    record: $record,
    isFocused: $isFocused,
    numberLength: 5,
    units: ("'", "\"", nil),
    leadingUnitPoint: 1,
    unitPoint: 3,
    textFieldId: 5
  )
}
