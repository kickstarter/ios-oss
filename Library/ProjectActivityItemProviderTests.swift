// swiftlint:disable force_unwrapping
import XCTest
@testable import KsApi
@testable import Prelude
@testable import Library

class ProjectActivityItemProviderTests: XCTestCase {

  private let project = .template
    |> Project.lens.name .~ "Awesome project"
    |> Project.lens.urls.web.project .~ "https://kickstarter.com/awesome-project"

  private var formattedString: String {
    return """
            \(project.name)\n
            \(project.urls.web.project)
           """
  }

  func testProviderInitReturnsCorrectPlaceholderItem() {
    let provider: ProjectActivityItemProvider = ProjectActivityItemProvider(project: project)
    XCTAssertEqual(project.name, provider.placeholderItem as! String)
  }

  func testItemForActivityTypeReturnsCorrectValue() {
    let provider: ProjectActivityItemProvider = ProjectActivityItemProvider(project: project)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])

    let mailType =  provider.activityViewController(activityVC, itemForActivityType: .mail)
    XCTAssertEqual(mailType as! String, formattedString)

    let messageType =  provider.activityViewController(activityVC, itemForActivityType: .message)
    XCTAssertEqual(messageType as! String, formattedString)

    let facebookType = provider.activityViewController(activityVC, itemForActivityType: .postToFacebook)
    XCTAssertEqual(facebookType as! String, project.urls.web.project)

    let otherTypes =  provider.activityViewController(activityVC, itemForActivityType: UIActivityType(""))
    XCTAssertEqual(otherTypes as! String, formattedString)
  }

  func testItemForTwitterTypeReturnsCorrectValue() {
    let provider: ProjectActivityItemProvider = ProjectActivityItemProvider(project: project)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])
    let twitterOutput = Strings.project_checkout_share_twitter_via_kickstarter(
      project_or_update_title: formattedString)

    let twitterType =  provider.activityViewController(activityVC, itemForActivityType: .postToTwitter)
    XCTAssertEqual(twitterType as! String, twitterOutput)
  }
}
