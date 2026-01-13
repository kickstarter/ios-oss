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

  // MARK: Test funded project cards.

  @MainActor
  func testFundedCards() {
    forEachScreenshotType(withData: PPOProjectCardModel.fundedProjectTemplates) { type, cardTemplate in
      withEnvironment(language: type.language) {
        let targetSize = CGSize(
          width: type.device.deviceSize(in: type.orientation).width,
          height: 500
        )

        let card = VStack {
          PPOProjectCard(viewModel: PPOProjectCardViewModel(
            card: cardTemplate
          ), parentSize: targetSize)
            .frame(width: targetSize.width)
            .frame(maxHeight: .infinity)
            .padding()
        }.frame(height: 500)

        assertSnapshot(
          forSwiftUIView: card,
          withType: type,
          size: targetSize,
          testName: "testFundedCards_\(cardTemplate.tierType.rawValue)"
        )
      }
    }
  }

  // MARK: Test project alert cards.

  @MainActor
  func testAddressLocks() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card =
        VStack {
          PPOProjectCard(viewModel: PPOProjectCardViewModel(
            card: .confirmAddressTemplate
          ), parentSize: targetSize)
            .frame(width: targetSize.width)
            .frame(maxHeight: .infinity)
            .padding()
        }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testAddressLocks"
      )
    }
  }

  @MainActor
  func testSurveyAvailableAddressLocks() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card = VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .addressLockTemplate
        ), parentSize: targetSize)
          .frame(width: targetSize.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testSurveyAvailableAddressLocks"
      )
    }
  }

  @MainActor
  func testPaymentFailedPledgeDropped() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card = VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .fixPaymentTemplate
        ), parentSize: targetSize)
          .frame(width: targetSize.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testPaymentFailedPledgeDropped"
      )
    }
  }

  @MainActor
  func testCardAuthPledgeDropped() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card = VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .authenticateCardTemplate
        ), parentSize: targetSize)
          .frame(width: targetSize.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testCardAuthPledgeDropped"
      )
    }
  }

  @MainActor
  func testSurveyAvailable() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card = VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .completeSurveyTemplate
        ), parentSize: targetSize)
          .frame(width: targetSize.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testSurveyAvailable"
      )
    }
  }

  @MainActor
  func testFinalizeYourPledge() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card = VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .managePledgeTemplate
        ), parentSize: targetSize)
          .frame(width: targetSize.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testFinalizeYourPledge"
      )
    }
  }

  // MARK: Test UI edge cases.

  @MainActor
  func testShortTemplateText() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card = VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .shortTextTemplate
        ), parentSize: targetSize)
          .frame(width: targetSize.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testShortTemplateText"
      )
    }
  }

  @MainActor
  func testLotsOfFlags() async {
    let targetHeight: CGFloat = 500

    forEachScreenshotType { type in
      let targetSize = CGSize(
        width: type.device.deviceSize(in: type.orientation).width,
        height: targetHeight
      )

      let card = VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .lotsOfFlagsTemplate
        ), parentSize: targetSize)
          .frame(width: targetSize.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: targetHeight)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(
        forSwiftUIView: card,
        withType: type,
        size: targetSize,
        testName: "testLotsOfFlags"
      )
    }
  }
}
