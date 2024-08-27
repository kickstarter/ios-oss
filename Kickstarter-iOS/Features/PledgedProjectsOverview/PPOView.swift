import SwiftUI

struct PPOView: View {
  weak var tabBarController: RootTabBarViewController?
  @StateObject private var viewModel = PPOViewModel()

  @AccessibilityFocusState private var isBannerFocused: Bool

  var body: some View {
    GeometryReader { _ in
      ScrollView {
        switch self.viewModel.state {
        case .notStarted:
          Text("Not loaded")
        case let .loading(data):
          Text("Loading")
        case let .loaded(data, _):
          ForEach(data) { viewModel in
            PPOProjectCard(viewModel: viewModel)
          }
          .padding(.vertical)
        case .empty:
          PPOEmptyStateView(tabBarController: self.tabBarController)
        case let .failed(error):
          Text("Failed: \(error)")
        }
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .onAppear(perform: {
        self.viewModel.viewDidAppear()
      })
//      .overlay(alignment: .bottom) {
//        MessageBannerView(viewModel: self.$viewModel.bannerViewModel)
//          .frame(
//            minWidth: reader.size.width,
//            idealWidth: reader.size.width,
//            alignment: .bottom
//          )
//          .animation(.easeInOut, value: self.viewModel.bannerViewModel != nil)
//          .accessibilityFocused(self.$isBannerFocused)
//      }
//
//      .onChange(of: self.viewModel.bannerViewModel, perform: { _ in
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//          self.isBannerFocused = self.viewModel.bannerViewModel != nil
//        }
//      })
    }
  }
}

#Preview {
  PPOView()
}
