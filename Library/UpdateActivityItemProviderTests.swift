@testable import KsApi
@testable import Library
import Prelude
import XCTest

class UpdateActivityItemProviderTests: XCTestCase {
  
  private let update = Update.template
    |> Update.lens.sequence .~ 0
    |> Update.lens.title .~ "mock title"
    |> Update.lens.urls.web.update .~ "https://mockurl.com"
  
  private func formattedString(for update: Update) -> String {
     return [update.title, update.urls.web.update].joined(separator: "\n")
  }

  func testProviderInitReturnsCorrectPlaceholderItem() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    XCTAssertEqual(update.title, provider.placeholderItem as? String)
  }
  
  func testItemForTwitterTypeReturnsTitleUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])
    let twitterOutput = Strings.project_checkout_share_twitter_via_kickstarter(
      project_or_update_title: self.formattedString(for: update)
    )

    let twitterType = provider.activityViewController(activityVC, itemForActivityType: .postToTwitter)
    XCTAssertEqual(twitterType as? String, twitterOutput)
  }
  
  func testItemForMailTypeReturnsUpdateSequenceTitleUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])
    
    let mailOutput = Strings.social_update_sequence_and_title(
      update_number: String(update.sequence),
      update_title: self.formattedString(for: update)
    )

    let mailType = provider.activityViewController(activityVC, itemForActivityType: .mail)
    XCTAssertEqual(mailType as? String, mailOutput)
  }
  
  func testItemForMessageTypeReturnsTitleUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])
    
    let messageOutput = self.formattedString(for: update)

    let messageType = provider.activityViewController(activityVC, itemForActivityType: .message)
    XCTAssertEqual(messageType as? String, messageOutput)
  }
  
  func testItemForFacebookTypeReturnsUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])
    
    let facebookOutput = update.urls.web.update

    let facebookType = provider.activityViewController(activityVC, itemForActivityType: .postToFacebook)
    XCTAssertEqual(facebookType as? String, facebookOutput)
  }
  
  func testItemForCopyToPasteboardTypeReturnsUpdateLink() {
    let provider: UpdateActivityItemProvider = UpdateActivityItemProvider(update: update)
    let activityVC = UIActivityViewController.init(activityItems: [], applicationActivities: [])
    
    let pasteboardOutput = update.urls.web.update

    let pasteboardType = provider.activityViewController(activityVC, itemForActivityType: .copyToPasteboard)
    XCTAssertEqual(pasteboardType as? String, pasteboardOutput)
  }

}
