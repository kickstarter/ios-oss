import Library
import Stripe
import SwiftUI

struct PPOView: View {
  @StateObject var viewModel = PPOViewModel()
  var authenticationContext: any STPAuthenticationContext
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
        onViewBackingDetails: { card in
          self.viewModel.viewBackingDetails(from: card)
        },
        onSendMessage: { card in
          self.viewModel.contactCreator(from: card)
        },
        onPerformAction: { model, action in
          switch action {
          case let .authenticateCard(clientSecret):
            self.viewModel.fix3DSChallenge(
              from: model,
              clientSecret: clientSecret,
              completion: { status in
                switch status {
                case .processing:
                  card.setLoading(true)
                case .succeeded, .cancelled, .failed:
                  card.setLoading(false)
                }
              }
            )
          case .completeSurvey:
            self.viewModel.openSurvey(from: model)
          case .confirmAddress:
            self.viewModel.confirmAddress(from: model)
          case .editAddress:
            self.viewModel.editAddress(from: model)
          case .fixPayment:
            self.viewModel.fixPaymentMethod(from: model)
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
            .padding(.horizontal.union(.bottom), CGFloat(PPOStyles.bannerPadding))
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
        .onAppear(perform: {
          self.viewModel.viewDidAppear(authenticationContext: self.authenticationContext)
        })
        .onChange(of: self.viewModel.results.values.count, perform: { value in
          self.onCountChange?(value)
        })
        .onReceive(self.viewModel.navigationEvents, perform: { event in
          self.onNavigate?(event)
        })
    }
  }
}

#Preview {
  PPOView(authenticationContext: PreviewAuthenticationContext())
}

#if targetEnvironment(simulator)
  fileprivate class PreviewAuthenticationContext: NSObject, STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
      fatalError()
    }
  }
#endif
