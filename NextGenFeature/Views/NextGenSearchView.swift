import KsApi
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

  public init() {}

  public var body: some View {
    ZStack {
      Color(.systemBackground).ignoresSafeArea()

      VStack(spacing: Constants.verticalSpacing) {
        self.TopBarView()

        // Search field + status row
        VStack(alignment: .leading, spacing: Constants.titleSubtitleSpacing) {
          self.SearchFieldView(vm: self.vm)
          self.StatusRowView(vm: self.vm)
        }
        .padding(.horizontal, Constants.horizontalPadding)

        // Value-based results list (no Binding).
        self.ResultsListView(items: Array(self.vm.outputs.results))
          .animation(.easeInOut(duration: Constants.animationDuration), value: self.vm.outputs.results)
      }
      .padding(.top)
    }
    .onAppear { self.vm.inputs.onAppear() }
  }

  // MARK: - ViewBuilders

  private func TopBarView() -> some View {
    HStack {
      Text("Projects").font(.title.bold())

      Spacer()

      Button(action: { self.handleClose() }) {
        Image(systemName: "xmark.circle.fill")
          .font(.title3)
          .foregroundColor(.secondary)
          .padding(Constants.closeIconPadding)
      }
    }
    .padding(.top, Constants.verticalPadding)
    .padding(.horizontal, Constants.horizontalPadding)
  }

  private func SearchFieldView(vm: NextGenSearchViewModel) -> some View {
    TextField(
      "Search projects…",
      text: Binding(
        get: {
          vm.searchQuery
        },
        set: {
          vm.inputs.searchTextChanged($0)
        }
      )
    )
    .textFieldStyle(.roundedBorder)
    .autocorrectionDisabled()
  }

  private func StatusRowView(vm: NextGenSearchViewModel) -> some View {
    Text(vm.outputs.statusText)
      .font(.footnote)
      .foregroundStyle(.secondary)
      .lineLimit(1)
      .truncationMode(.tail)
  }

  private func ResultsListView(items: [NextGenSearchResult]) -> some View {
    // ScrollView + LazyVStack keeps it simple and avoids List’s Binding requirement on init.
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(items, id: \.id) { (item: NextGenSearchResult) in
          VStack(alignment: .leading, spacing: 4) {
            Text(item.name).font(.headline)
          }
          .padding(.vertical, 4)
        }
      }
      .padding(.horizontal, Constants.horizontalPadding)
    }
  }

  // MARK: - Helpers

  private func handleClose() {
    self.dismiss()
  }
}
