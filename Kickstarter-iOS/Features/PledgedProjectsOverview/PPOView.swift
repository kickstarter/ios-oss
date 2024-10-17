import Library
import SwiftUI

struct PPOView: View {
  @StateObject var viewModel = PPOViewModel()
  var onCountChange: ((Int?) -> Void)?
  var onNavigate: ((PPONavigationEvent) -> Void)?

  @State private var data: [PPOProjectCardViewModel] = []

  @AccessibilityFocusState private var isBannerFocused: Bool

  var body: some View {
    GeometryReader { reader in
      VStack {
        PaginatingLazyVStack(
          data: self.viewModel.results.values,
          canShowProgressView: self.viewModel.results.canLoadMore
        ) { viewModel in
          PPOProjectCard(viewModel: viewModel)
        } onRefresh: { () async in
          print("Loading \(Date().timeIntervalSince1970)")
          self.viewModel.pullToRefresh()
          _ = await self.viewModel.nextResult()
          print("Donezo \(Date().timeIntervalSince1970)")
        } onLoadMore: { () async in
          self.viewModel.loadMore()
          _ = await self.viewModel.nextResult()
        }

        // TODO: Show empty state view if user is logged in and has no PPO updates.
        // PPOEmptyStateView {
        //  self.onNavigate?(.backedProjects)
        // }

        // TODO: Remove this button once we're showing cards instead.
        Button("Show banner") {
          self.viewModel.shouldSendSampleMessage()
        }
      }
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
      .onReceive(self.viewModel.$results, perform: { results in
        self.data = results.values
      })
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
