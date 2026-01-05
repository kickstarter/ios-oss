import KDS
import Library
import SwiftUI

struct PPOEmptyStateView: View {
  var onOpenBackedProjects: (() -> Void)? = nil

  private enum Constants {
    public static let largePadding = Spacing.unit_06
    public static let horizontalPadding = Spacing.unit_04
  }

  var body: some View {
    VStack(alignment: .center) {
      Text(
        featurePledgedProjectsOverviewV2Enabled() ?
          Strings.No_funded_backings() :
          Strings.Youre_all_caught_up()
      )
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
        Text(
          featurePledgedProjectsOverviewV2Enabled() ?
            Strings.When_projects_youve_backed_have_successfully_funded_youll_see_them_here() :
            Strings.When_projects_youve_backed_need_your_attention_youll_see_them_here()
        )
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
