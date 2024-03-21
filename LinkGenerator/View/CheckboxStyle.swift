import SwiftUI

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(
                systemName: configuration.isOn
                ? "checkmark.circle.fill"
                : "circle"
            )
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(Color.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture { configuration.isOn.toggle() }
    }
}
