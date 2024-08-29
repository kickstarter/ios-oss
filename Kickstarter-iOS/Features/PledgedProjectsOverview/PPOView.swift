import SwiftUI

struct PPOView: View {
  weak var tabBarController: RootTabBarViewController?
  @StateObject private var viewModel = PPOViewModel()

  var body: some View {
    GeometryReader { _ in
      ScrollView {
        // TODO: Show empty state view if user is logged in and has no PPO updates.
        //      PPOEmptyStateView(tabBarController: self.tabBarController)

        // TODO: Remove this button once we're showing cards instead.
        Button("Show banner") {}
      }
      .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}

#Preview {
  PPOView()
}
