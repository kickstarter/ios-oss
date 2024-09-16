import SwiftUI

struct PPOView: View {
  weak var tabBarController: RootTabBarViewController?
  @StateObject private var viewModel = PPOViewModel()

  @AccessibilityFocusState private var isBannerFocused: Bool

  var body: some View {
    GeometryReader { reader in
      ScrollView {
        // TODO: Show empty state view if user is logged in and has no PPO updates.
        //      PPOEmptyStateView(tabBarController: self.tabBarController)

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

      .onChange(of: self.viewModel.bannerViewModel, perform: { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.isBannerFocused = self.viewModel.bannerViewModel != nil
        }
      })
      .onAppear(perform: { self.viewModel.viewDidAppear() })
    }
  }
}

#Preview {
  PPOView()
}
