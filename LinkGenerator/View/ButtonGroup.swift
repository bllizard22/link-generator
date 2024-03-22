import SwiftUI

struct ButtonGroup: View {

    @Environment(\.openURL) var openURL
    @Binding var viewModel: CreateLinkView.ViewModel
    var resultURL: URL

    var body: some View {
        HStack {
            Button {
                openURL(resultURL)
                LocalParametersManager.saveData(viewModel)
            } label: {
                Text("Open")
                    .fontWeight(Font.Weight.semibold)
                    .foregroundStyle(Color.white)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.cyan)
            .cornerRadius(12)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                LocalParametersManager.saveData(viewModel)
            } label: {
                Text("Save")
                    .fontWeight(Font.Weight.semibold)
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.cyan)
            .cornerRadius(12)
            .ignoresSafeArea()
        }
        .padding()
        .ignoresSafeArea()
    }
}
