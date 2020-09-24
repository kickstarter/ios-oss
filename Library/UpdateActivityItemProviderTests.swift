@testable import KsApi
@testable import Library
import Prelude
import XCTest

class UpdateActivityItemProviderTests: XCTestCase {
  private let update = Update.template
    |> Update.lens.sequence .~ 0
    |> Update.lens.title .~ "mock title"
    |> Update.lens.urls.web.update .~ "https://mockurl.com"

  func testProviderInitReturnsCorrectPlaceholderItem() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    XCTAssertEqual(update.title, provider.placeholderItem as? String)
  }

  func testItemForTwitterTypeReturnsTitleUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])

    let twitterOutput = "mock title\nhttps://mockurl.com, via Kickstarter"

    let twitterType = provider.activityViewController(activityVC, itemForActivityType: .postToTwitter)
    XCTAssertEqual(twitterType as? String, twitterOutput)
  }

  func testItemForMailTypeReturnsUpdateSequenceTitleUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])

    let mailOutput = "Update #0: mock title\nhttps://mockurl.com"

    let mailType = provider.activityViewController(activityVC, itemForActivityType: .mail)
    XCTAssertEqual(mailType as? String, mailOutput)
  }

  func testItemForMessageTypeReturnsTitleUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])

    let messageOutput = "mock title\nhttps://mockurl.com"

    let messageType = provider.activityViewController(activityVC, itemForActivityType: .message)
    XCTAssertEqual(messageType as? String, messageOutput)
  }

  func testItemForFacebookTypeReturnsUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])

    let facebookOutput = "https://mockurl.com"

    let facebookType = provider.activityViewController(activityVC, itemForActivityType: .postToFacebook)
    XCTAssertEqual(facebookType as? String, facebookOutput)
  }

  func testItemForCopyToPasteboardTypeReturnsUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])

    let pasteboardOutput = "https://mockurl.com"

    let pasteboardType = provider.activityViewController(activityVC, itemForActivityType: .copyToPasteboard)
    XCTAssertEqual(pasteboardType as? String, pasteboardOutput)
  }
}
