import SwiftUI

struct SortingSection_Previews: PreviewProvider {
    @State static var model = CreateLinkView.ViewModel.makeStubForPreview()

    static var previews: some View {
        Form {
            SortingSection(viewModel: $model)
        }
    }
}

struct SortingSection: View {
    
    @Binding var viewModel: CreateLinkView.ViewModel

    var body: some View {
        Section(
            "Sorting",
            content: {
                Picker("Link Type", selection: $viewModel.linkType) {
                    ForEach(LinkType.allCases) {
                        Text($0.rawValue)
                    }
                }

                Picker("", selection: $viewModel.timeUnit) {
                    ForEach(TimeUnit.allCases) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                if viewModel.timeUnit != .any {
                    Picker("Period", selection: $viewModel.timeAmount) {
                        ForEach(1..<25) {
                            Text("\($0)")
                        }
                    }
                }

                Picker("Sort by", selection: $viewModel.sorting) {
                    ForEach(Sorting.allCases) {
                        Text($0.rawValue)
                    }
                }

                Toggle("EasyApply", isOn: $viewModel.isEasyApply)
                Toggle("Under 10 applications", isOn: $viewModel.isFewApplicants)
            }
        )
    }
}
