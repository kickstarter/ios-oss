@testable import KsApi
@testable import Library
import Prelude
import XCTest

class ProjectActivityItemProviderTests: XCTestCase {
  private let project = .template
    |> Project.lens.name .~ "Awesome project"
    |> Project.lens.urls.web.project .~ "https://kickstarter.com/awesome-project"

  private var formattedString: String {
    return """
     \(self.project.name)\n
     \(self.project.urls.web.project)
    """
  }

  func testProviderInitReturnsCorrectPlaceholderItem() {
    let provider: ProjectActivityItemProvider = ProjectActivityItemProvider(project: project)
    XCTAssertEqual(project.name, provider.placeholderItem as? String)
  }

  func testItemForActivityTypeReturnsCorrectValue() {
    let provider: ProjectActivityItemProvider = ProjectActivityItemProvider(project: project)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])

    let mailType = provider.activityViewController(activityVC, itemForActivityType: .mail)
    XCTAssertEqual(mailType as? String, self.formattedString)

    let messageType = provider.activityViewController(activityVC, itemForActivityType: .message)
    XCTAssertEqual(messageType as? String, self.formattedString)

    let facebookType = provider.activityViewController(activityVC, itemForActivityType: .postToFacebook)
    XCTAssertEqual(facebookType as? String, self.project.urls.web.project)

    let pasteboardType = provider.activityViewController(activityVC, itemForActivityType: .copyToPasteboard)
    XCTAssertEqual(pasteboardType as? String, self.project.urls.web.project)

    let otherTypes = provider.activityViewController(
      activityVC,
      itemForActivityType: UIActivity.ActivityType("")
    )
    XCTAssertEqual(otherTypes as? String, self.formattedString)
  }

  func testItemForTwitterTypeReturnsCorrectValue() {
    let provider: ProjectActivityItemProvider = ProjectActivityItemProvider(project: project)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])
    let twitterOutput = Strings.project_checkout_share_twitter_via_kickstarter(
      project_or_update_title: self.formattedString
    )

    let twitterType = provider.activityViewController(activityVC, itemForActivityType: .postToTwitter)
    XCTAssertEqual(twitterType as? String, twitterOutput)
  }
}
