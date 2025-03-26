import Library
import SwiftUI

struct PPOEmptyStateView: View {
  var onOpenBackedProjects: (() -> Void)? = nil

  private enum Constants {
    public static let largePadding = 24.0
    public static let horizontalPadding = 16.0
  }

  var body: some View {
    VStack(alignment: .center) {
      Text(Strings.Youre_all_caught_up())
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
        Text(Strings.When_projects_youve_backed_need_your_attention_youll_see_them_here())
          .font(Font(UIFont.ksr_body()))
          .multilineTextAlignment(.center)

        Button(Strings.See_all_backed__projects()) {
          self.onOpenBackedProjects?()
        }
        .buttonStyle(KSRButtonStyleModifier(style: .green))
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
