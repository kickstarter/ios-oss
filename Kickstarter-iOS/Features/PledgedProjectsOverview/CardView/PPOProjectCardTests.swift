@testable import Kickstarter_Framework
import Kingfisher
@testable import KsApi
import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class PPOProjectCardTests: TestCase {
  let size = CGSize(width: 375, height: 700)

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  @MainActor
  func testFundedCards() {
    forEachScreenshotType(
      withData: PPOProjectCardModel.fundedProjectTemplates,
      // TODO(MBL-3044): Update view and test to support more content sizes.
      contentSizes: [.large]
    ) { type, template in
      let card = PPOProjectCard(
        viewModel: PPOProjectCardViewModel(card: template),
        parentSize: type.device.deviceSize
      )
      assertSnapshot(forSwiftUIView: card, withType: type)
    }
  }

  @MainActor
  func testLiveCards() {
    forEachScreenshotType(
      withData: PPOProjectCardModel.liveProjectTemplates,
      // TODO(MBL-3044): Update view and test to support more content sizes.
      contentSizes: [.large]
    ) { type, template in
      let card = PPOProjectCard(
        viewModel: PPOProjectCardViewModel(card: template),
        parentSize: type.device.deviceSize
      )
      assertSnapshot(forSwiftUIView: card, withType: type)
    }
  }

  @MainActor
  func testFailedCards() {
    forEachScreenshotType(
      withData: PPOProjectCardModel.failedPledgeTemplates,
      // TODO(MBL-3044): Update view and test to support more content sizes.
      contentSizes: [.large]
    ) { type, template in
      let card = PPOProjectCard(
        viewModel: PPOProjectCardViewModel(card: template),
        parentSize: type.device.deviceSize
      )
      assertSnapshot(forSwiftUIView: card, withType: type)
    }
  }

  @MainActor
  func testAlertCards() {
    forEachScreenshotType(
      withData: PPOProjectCardModel.alertTemplates,
      // TODO(MBL-3044): Update view and test to support more content sizes.
      contentSizes: [.large]
    ) { type, template in
      let card = PPOProjectCard(
        viewModel: PPOProjectCardViewModel(card: template),
        parentSize: type.device.deviceSize
      )
      assertSnapshot(forSwiftUIView: card, withType: type)
    }
  }

  @MainActor
  func testUIEdgeCases() {
    forEachScreenshotType(
      withData: PPOProjectCardModel.uiEdgeCaseTemplates,
      // TODO(MBL-3044): Update view and test to support more content sizes.
      contentSizes: [.large]
    ) { type, template in
      let card = PPOProjectCard(
        viewModel: PPOProjectCardViewModel(card: template),
        parentSize: type.device.deviceSize
      )
      assertSnapshot(forSwiftUIView: card, withType: type)
    }
  }
}
