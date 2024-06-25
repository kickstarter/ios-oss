import SwiftUI

struct PPOView: View {
  @StateObject private var viewModel = PPOViewModel()
  var body: some View {
    Text(self.viewModel.greeting)
  }
}

#Preview {
  PPOView()
}
