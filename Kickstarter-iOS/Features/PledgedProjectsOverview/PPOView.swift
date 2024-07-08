import SwiftUI

struct PPOView: View {
  @StateObject private var viewModel = PPOViewModel()
  var body: some View {
    ScrollView {
      // Text(self.viewModel.greeting)
      // TODO: Show empty state view if user is logged in and has no PPO updates.
      PPOEmptyStateView()
    }
  }
}

#Preview {
  PPOView()
}
