@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI
import XCTest

internal final class MessageBannerViewTests: TestCase {
  func testBannerSuccess() {
    @State var viewModel: MessageBannerViewViewModel? = MessageBannerViewViewModel((
      .success,
      "Everything completed successfully and now's the time to celebrate! Goooooo team!"
    ))
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }

  func testBannerError() {
    @State var viewModel: MessageBannerViewViewModel? = MessageBannerViewViewModel((
      .error,
      "Something went wrong"
    ))
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }

  func testBannerInfo_shortString() {
    @State var viewModel: MessageBannerViewViewModel? = MessageBannerViewViewModel((
      .info,
      "Something happened"
    ))
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }

  func testBannerInfo_longString() {
    @State var viewModel: MessageBannerViewViewModel? = MessageBannerViewViewModel((
      .info,
      "Something unexpected happened but everything is probably fine."
    ))
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }
}
