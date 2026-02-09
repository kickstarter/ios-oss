import KDS
import Library
import SwiftUI

struct PPOEmptyStateView: View {
  var onOpenBackedProjects: (() -> Void)?
  var onExploreProjects: (() -> Void)?

  private enum Constants {
    public static let largePadding = Spacing.unit_06
    public static let horizontalPadding = Spacing.unit_04
  }

  var body: some View {
    VStack(alignment: .center) {
      Text(
        self.titleString()
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
          self.descriptionString()
        )
        .font(Font(UIFont.ksr_body()))
        .multilineTextAlignment(.center)

        if featurePledgedProjectsOverviewV4Enabled() {
          Button(Strings.Explore_projects()) {
            self.onExploreProjects?()
          }
          .buttonStyle(KSRButtonStyleModifier(style: KSRButtonStyle.green))
        } else {
          Button(Strings.See_all_backed__projects()) {
            self.onOpenBackedProjects?()
          }
          .buttonStyle(KSRButtonStyleModifier(style: KSRButtonStyle.green))
        }
      }
      .padding(EdgeInsets(
        top: 0,
        leading: Constants.largePadding,
        bottom: 0,
        trailing: Constants.largePadding
      ))
    }
  }

  private func titleString() -> String {
    if featurePledgedProjectsOverviewV4Enabled() {
      return Strings.No_backings()
    }
    if featurePledgedProjectsOverviewV2Enabled() {
      return Strings.No_funded_backings()
    }
    return Strings.Youre_all_caught_up()
  }

  private func descriptionString() -> String {
    if featurePledgedProjectsOverviewV4Enabled() {
      return Strings.When_youve_backed_a_project_itll_show_up_here()
    }
    if featurePledgedProjectsOverviewV2Enabled() {
      return Strings.When_projects_youve_backed_have_successfully_funded_youll_see_them_here()
    }
    return Strings.When_projects_youve_backed_need_your_attention_youll_see_them_here()
  }
}

#Preview {
  PPOEmptyStateView()
}
