import KsApi
import Library
import Observation
import SwiftUI

private enum Constants {
  static let animationDuration: Double = 0.25
  static let closeIconPadding: CGFloat = 8
  static let horizontalPadding: CGFloat = 20
  static let titleSubtitleSpacing: CGFloat = 12
  static let verticalPadding: CGFloat = 20
  static let verticalSpacing: CGFloat = 24
}

public struct NextGenSearchView: View {
  @SwiftUI.Environment(\.dismiss) private var dismiss
  @State private var vm: NextGenSearchViewModel = NextGenSearchViewModel(service: NextGenProjectSearchService(
    apollo: AsyncApolloClient(client: GraphQL.shared.client)
  ))

  @State private var searchText: String = ""

  public init() {}

  public var body: some View {
    @Bindable var vm = self.vm

    ZStack {
      Color(.systemBackground).ignoresSafeArea()

      VStack(spacing: Constants.verticalSpacing) {
        self.TopBarView

        VStack(alignment: .leading, spacing: Constants.titleSubtitleSpacing) {
          TextField("Search projects…", text: self.$searchText)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.search)
            // send every keystroke to the VM. it handles debouncing
            .onChange(of: self.searchText) { newValue in
              vm.inputs.searchTextChanged(newValue)
            }
            .onSubmit {
              vm.inputs.searchTextChanged(self.searchText)
            }

          Text(vm.outputs.statusText)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
        }
        .padding(.horizontal, Constants.horizontalPadding)

        self.ResultsListView(items: vm.outputs.results)
          .animation(.easeInOut(duration: Constants.animationDuration), value: vm.outputs.results)
      }
      .padding(.top)
    }
    .onAppear {
      vm.inputs.onAppear()

      if !vm.searchQuery.isEmpty {
        self.searchText = vm.searchQuery
      }
    }
  }

  // MARK: - Subviews

  private var TopBarView: some View {
    HStack {
      Text("Projects")
        .font(.title.bold())

      Spacer()

      Button {
        self.dismiss()
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.title3)
          .foregroundColor(.secondary)
          .padding(Constants.closeIconPadding)
      }
    }
    .padding(.top, Constants.verticalPadding)
    .padding(.horizontal, Constants.horizontalPadding)
  }

  private func ResultsListView(items: [NextGenSearchResult]) -> some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(items) { item in
          VStack(alignment: .leading, spacing: 4) {
            Text(item.name).font(.headline)
          }
          .padding(.vertical, 4)
        }
      }
      .padding(.horizontal, Constants.horizontalPadding)
    }
  }
}
