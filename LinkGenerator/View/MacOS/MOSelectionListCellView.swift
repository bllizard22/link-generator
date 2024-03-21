import SwiftUI

struct MOSelectionList<T: Selection>: View {

    @Binding var model: Set<T>

    var body: some View {
        List {
            ForEach(
                T.allCases.sorted(by: { $0.rawValue < $1.rawValue })
            ) { type in
                MOSelectionCell(model: $model, type: type)
            }
        }.backgroundStyle(Color.primary)
    }
}

struct MOSelectionCell<T: Selection>: View {

    @Binding var model: Set<T>

    @State var type: T
    @State private var isChecked: Bool = false

    var body: some View {
        Button {
            updateVal()
        } label: {
            HStack {
                Text(type.rawValue)
                Spacer()
                Image(
                    systemName: isChecked
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.gray)
            }
        }
        .foregroundColor(Color.primary)
        .onAppear(perform: {
            isChecked = model.contains(type)
        })
    }

    func updateVal() {
        isChecked.toggle()
        if isChecked {
            model.insert(type)
        } else {
            model.remove(type)
        }
    }
}
