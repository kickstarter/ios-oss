import Library
import SwiftUI

struct ReportProjectLabelView: View {
  let flagged: Bool

  @SwiftUI.Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    if self.flagged {
      AlreadyReportedView()
    } else {
      HStack {
        Text(Strings.Report_this_project_to())
          .font(Font(UIFont.ksr_body(size: 14)))
          .foregroundColor(LegacyColors.ksr_support_700.swiftUIColor())

        Spacer()

        Image("chevron-right")
          .resizable()
          .scaledToFit()
          .frame(width: 10, height: 10)
      }
      .padding(self.horizontalSizeClass == .regular ? 0 : 10)
    }
  }

  private struct AlreadyReportedView: View {
    var body: some View {
      HStack(alignment: .top, spacing: 10) {
        Image("info")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(LegacyColors.ksr_support_500.swiftUIColor())

        Text(
          html: Strings.It_looks(
            our_rules: HelpType.prohibitedItems
              .url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl)?
              .absoluteString ?? "",
            community_guidelines: HelpType.community
              .url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl)?
              .absoluteString ?? ""
          ),
          with: [
            ReportProjectHyperLinkType.ourRules.stringLiteral(),
            ReportProjectHyperLinkType.communityGuidelines.stringLiteral()
          ]
        )
        .font(Font(UIFont.ksr_caption1()))
      }
      .padding()
      .background(LegacyColors.ksr_support_100.swiftUIColor())
      .cornerRadius(15)
    }
  }
}

struct ReportProjectView_Previews: PreviewProvider {
  static var previews: some View {
    ReportProjectLabelView(flagged: false)
  }
}
