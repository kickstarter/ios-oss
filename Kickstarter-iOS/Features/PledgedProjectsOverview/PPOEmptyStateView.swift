import SwiftUI

struct PPOEmptyStateView: View {
  weak var tabBarController: RootTabBarViewController?

  private enum Constants {
    public static let largePadding = 24.0
    public static let horizontalPadding = 16.0
  }

  // TODO: Translate these strings (MBL-1558)
  var body: some View {
    VStack(alignment: .center) {
      Text("You're all caught up!")
        .font(Font(UIFont.ksr_title2().bolded))
        .padding(EdgeInsets(
          top: 0,
          leading: Constants.horizontalPadding,
          bottom: Constants.largePadding,
          trailing: Constants.horizontalPadding
        ))
        .multilineTextAlignment(.center)
        .accessibilityAddTraits(.isHeader)

      VStack(spacing: Constants.largePadding) {
        Text("When projects you've backed need your attention, you'll see them here.")
          .font(Font(UIFont.ksr_body()))
          .multilineTextAlignment(.center)

        Button("See all backed projects") {
          self.tabBarController?.switchToProfile()
        }
        .buttonStyle(GreenButtonStyle())
      }
      .padding(EdgeInsets(
        top: 0,
        leading: Constants.largePadding,
        bottom: 0,
        trailing: Constants.largePadding
      ))
    }
  }
}

#Preview {
  PPOEmptyStateView()
}
