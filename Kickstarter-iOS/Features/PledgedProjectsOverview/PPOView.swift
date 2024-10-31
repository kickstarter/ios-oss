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
         .loading(.empty),
         .loading(.error),
         .loading(previous: .loading(_)):
      self.loadingView
    case .empty:
      self.emptyView
    case .error:
      self.errorView
    case
      let .someLoaded(values, _, _, _),
      let .loading(previous: .someLoaded(values, _, _, _)),
      let .allLoaded(values, _),
      let .loading(previous: .allLoaded(values, _)):
      self.listView(values: values, parentSize: parentSize)
    }
  }

  @ViewBuilder func listViewHeader(numberOfValues: Int) -> some View {
    Text(Strings.Alerts_count(count: numberOfValues.formatted()))
      .font(Font(PPOStyles.header.font))
      .background(Color(PPOStyles.header.background))
      .foregroundStyle(Color(PPOStyles.header.foreground))
      .padding(PPOStyles.header.padding)
  }

  @ViewBuilder func listView(values: [PPOProjectCardViewModel], parentSize: CGSize) -> some View {
    PaginatingList(
      data: values,
      canLoadMore: false,
      selectedItem: nil,
      header: { self.listViewHeader(numberOfValues: values.count) }
    ) { card in
      PPOProjectCard(
        viewModel: card,
        parentSize: parentSize,
        onShowProject: { card in
          self.viewModel.showProject(from: card)
        },
        onSendMessage: { card in
          self.viewModel.contactCreator(from: card)
        },
        onPerformAction: { card, action in
          switch action {
          case .authenticateCard:
            self.viewModel.fix3DSChallenge(from: card)
          case .completeSurvey:
            self.viewModel.openSurvey(from: card)
          case .confirmAddress:
            self.viewModel.confirmAddress(from: card)
          case .editAddress:
            self.viewModel.editAddress(from: card)
          case .fixPayment:
            self.viewModel.fixPaymentMethod(from: card)
          }
        }
      )
      .listRowBackground(EmptyView())
      .listRowSeparator(PPOStyles.list.separator)
      .listRowInsets(PPOStyles.list.rowInsets)
    } onRefresh: {
      await self.viewModel.refresh()
    } onLoadMore: {
      await self.viewModel.loadMore()
    }
  }

  @ViewBuilder var loadingView: some View {
    VStack {
      Spacer()
      ProgressView()
        .controlSize(PPOStyles.loaderControlSize)
        .padding()
      Spacer()
    }
  }

  @ViewBuilder var emptyView: some View {
    PPOEmptyStateView {
      self.onNavigate?(.backedProjects)
    }
  }

  @ViewBuilder var errorView: some View {
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
        .font(Font(PPOStyles.error.font))
        .foregroundStyle(Color(PPOStyles.error.foreground))
        .background(Color(PPOStyles.error.background))
      Spacer()
    }
  }

  @ViewBuilder var body: some View {
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
