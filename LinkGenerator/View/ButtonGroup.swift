import SwiftUI

struct ButtonGroup: View {

    @Environment(\.openURL) var openURL
    @Binding var viewModel: CreateLinkView.ViewModel
    var resultURL: URL

    var body: some View {
        HStack {
            Button {
                openURL(resultURL)
                viewModel.saveData()
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
                viewModel.saveData()
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
