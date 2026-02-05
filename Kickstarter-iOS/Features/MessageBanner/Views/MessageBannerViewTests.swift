@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI
import XCTest

internal final class MessageBannerViewTests: TestCase {
  func testBannerSuccess() {
    @State var viewModel: MessageBannerViewViewModel? = nil
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }

  func testBannerError() {
    @State var viewModel: MessageBannerViewViewModel? = nil
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }

  func testBannerInfo_shortString() {
    @State var viewModel: MessageBannerViewViewModel? = nil
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }

  func testBannerInfo_longString() {
    @State var viewModel: MessageBannerViewViewModel? = nil
    let messageBannerView = MessageBannerView(viewModel: $viewModel)
      .defaultPortraitFrame()

    assertSnapshot(matching: messageBannerView, as: .image)
  }
}
