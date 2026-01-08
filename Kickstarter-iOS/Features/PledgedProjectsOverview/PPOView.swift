import Combine
import Library
import SwiftUI

struct PPOView: View {
  @StateObject var viewModel = PPOViewModel()
  var shouldRefresh: AnyPublisher<Void, Never>
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
    Text(
      featurePledgedProjectsOverviewV2Enabled() ?
        Strings.Backings() :
        Strings.Alerts_count(count: numberOfValues.formatted())
    )
    .font(Font(PPOStyles.header.font))
    .background(Color(PPOStyles.header.background))
    .foregroundStyle(Color(PPOStyles.header.foreground))
    .padding(PPOStyles.header.padding)
    .accessibilityAddTraits(.isHeader)
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
        onHandleEvent: { cardModel, event in
          switch event {
          case .viewProjectDetails:
            self.viewModel.viewProjectDetails(from: cardModel)
          case .sendMessage:
            self.viewModel.contactCreator(from: cardModel)
          case .editAddress:
            self.viewModel.editAddress(from: cardModel)
          case let .authenticateCard(clientSecret):
            self.viewModel.fix3DSChallenge(
              from: cardModel,
              clientSecret: clientSecret,
              onProgress: { [weak card] state in
                card?.handle3DSState(state)
              }
            )
          case .completeSurvey:
            self.viewModel.openSurvey(from: cardModel)
          case .managePledge:
            self.viewModel.managePledge(from: cardModel)
          case let .confirmAddress(address, addressId):
            self.viewModel.confirmAddress(from: cardModel, address: address, addressId: addressId)
          case .fixPayment:
            self.viewModel.fixPaymentMethod(from: cardModel)
          }
        }
      )
      .listRowBackground(EmptyView())
      .listRowSeparator(PPOStyles.list.separator)
      .listRowInsets(PPOStyles.list.rowInsets)
      .transition(.opacity.combined(with: .move(edge: .leading)))
    } onRefresh: {
      await self.viewModel.refresh()
    } onLoadMore: {
      await self.viewModel.loadMore()
    }
    .animation(.easeOut(duration: 0.3), value: values.map { $0.card.id })
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
    .frame(maxHeight: .infinity)
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
        .onAppear(perform: {
          self.viewModel.viewDidAppear()
        })
        .onChange(of: self.viewModel.results.values, initial: true) { _, newValues in
          let newAlerts = newValues.filter { cardViewModel in
            PPOTierType.projectAlertTypes().contains(cardViewModel.card.tierType)
          }
          self.onCountChange?(newAlerts.count)
        }
        .onReceive(self.viewModel.navigationEvents, perform: { event in
          self.onNavigate?(event)
        })
        .onReceive(self.shouldRefresh.throttle(
          for: .milliseconds(300),
          scheduler: RunLoop.main,
          latest: false
        )) { () in
          Task {
            await self.viewModel.refresh()
          }
        }
        .background(Color(PPOStyles.background))
    }
  }
}

#Preview {
  PPOView(shouldRefresh: Empty().eraseToAnyPublisher())
}
