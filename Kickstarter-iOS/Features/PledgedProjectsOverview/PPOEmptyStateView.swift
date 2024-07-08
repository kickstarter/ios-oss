import SwiftUI

struct PPOEmptyStateView: View {
  private enum Constants {
    public static let largePadding = 24.0
    public static let horizontalPadding = 16.0
    public static let verticalButtonPadding = 13.0
    public static let buttonRadius = 12.0
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

        Button {
          print("Looking!")
        } label: {
          Text("See all backed projects")
            .frame(maxWidth: .infinity)
        }
        .padding(EdgeInsets(
          top: Constants.verticalButtonPadding,
          leading: Constants.horizontalPadding,
          bottom: Constants.verticalButtonPadding,
          trailing: Constants.horizontalPadding
        ))
        .foregroundColor(.white)
        .background(
          Color(UIColor.ksr_create_700),
          in: RoundedRectangle(cornerRadius: Constants.buttonRadius)
        )
        .font(Font(UIFont.ksr_body()))
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
