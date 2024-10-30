import Library
import SwiftUI

struct PPOView: View {
  @StateObject var viewModel = PPOViewModel()
  var onCountChange: ((Int?) -> Void)?
  var onNavigate: ((PPONavigationEvent) -> Void)?

  @AccessibilityFocusState private var isBannerFocused: Bool

  @ViewBuilder func contentView(parentSize: CGSize) -> some View {
    switch self.viewModel.results {
    case .unloaded, .loading(.unloaded),
        .loading(.error),
        .loading(previous: .loading(_)):
      VStack {
        Spacer()
        ProgressView()
          .controlSize(.large)
          .padding()
        Spacer()
      }
    case .empty, .loading(.empty):
      PPOEmptyStateView {
        self.onNavigate?(.backedProjects)
      }
    case .error:
      VStack {
        Spacer()
        if let image = image(named: "icon--refresh-small") {
          Image(uiImage: image)
            // TODO: Localize
            .accessibilityLabel("Refresh")
            .accessibilityHint("Refreshes your project alerts.")
            .accessibilityAddTraits(.isButton)
            .accessibilityRemoveTraits(.isImage)
            .onTapGesture { [weak viewModel] () in
              Task {
                await viewModel?.refresh()
              }
            }
        }
        Text(Strings.general_error_something_wrong())
          .font(Font(UIFont.ksr_callout()))
          .foregroundStyle(Color(UIColor.ksr_black))
        Spacer()
      }
    case
      let .someLoaded(values, _, _, _),
      let .loading(previous: .someLoaded(values, _, _, _)),
      let .allLoaded(values, _),
      let .loading(previous: .allLoaded(values, _)):
      PaginatingList(
        data: values,
        canLoadMore: false,
        selectedItem: nil,
        header: {
          Text(Strings.Alerts_count(count: values.count.formatted()))
            .font(Font(UIFont.ksr_title2()))
            .foregroundStyle(Color(UIColor.ksr_black))
            .padding(.top)
        }
      ) { card in
          PPOProjectCard(
            viewModel: card,
            parentSize: parentSize
          )
            .listRowBackground(EmptyView())
            .listRowSeparator(.hidden)
            .listRowInsets(.none)
        } onRefresh: {
          await self.viewModel.refresh()
        } onLoadMore: {
          await self.viewModel.loadMore()
        }
    }
  }

  var body: some View {
    GeometryReader { reader in
      self.contentView(parentSize: reader.size)
        .frame(maxWidth: .infinity, alignment: .center)
      .overlay(alignment: .bottom) {
        MessageBannerView(viewModel: self.$viewModel.bannerViewModel)
          .frame(
            minWidth: reader.size.width,
            idealWidth: reader.size.width,
            alignment: .bottom
          )
          .animation(.easeInOut, value: self.viewModel.bannerViewModel != nil)
          .accessibilityFocused(self.$isBannerFocused)
      }
      .onChange(of: self.viewModel.bannerViewModel, perform: { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.isBannerFocused = self.viewModel.bannerViewModel != nil
        }
      })
      .onAppear(perform: { self.viewModel.viewDidAppear() })
      .onChange(of: self.viewModel.results.total, perform: { value in
        self.onCountChange?(value)
      })
      .onReceive(self.viewModel.navigationEvents, perform: { event in
        self.onNavigate?(event)
      })
    }
  }
}

#Preview {
  PPOView()
}
