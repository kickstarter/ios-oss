@testable import Kickstarter_Framework
import Kingfisher
@testable import KsApi
@testable import KsApiTestHelpers
import Library
@testable import LibraryTestHelpers
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
    orthogonalCombos(
      PPOProjectCardModel.fundedProjectTemplates,
      Language.allLanguages,
      [UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    ).forEach {
      cardTemplate, language, interfaceStyle in
      withEnvironment(
        language: language
      ) {
        let card = VStack {
          PPOProjectCard(viewModel: PPOProjectCardViewModel(
            card: cardTemplate
          ), parentSize: self.size)
            .frame(width: self.size.width)
            .frame(maxHeight: .infinity)
            .padding()
        }.frame(height: 500)

        let traits = UITraitCollection.init(userInterfaceStyle: interfaceStyle)
        assertSnapshot(of: card, as: .image(traits: traits), named: cardTemplate.tierType.rawValue)
      }
    }
  }

  // MARK: Test project alert cards.

  @MainActor
  func testAddressLocks() async {
    let card =
      VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .confirmAddressTemplate
        ), parentSize: self.size)
          .frame(width: self.size.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "addressLocks")
  }

  @MainActor
  func testSurveyAvailableAddressLocks() async {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .addressLockTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "surveyAvailableAddressLocks")
  }

  @MainActor
  func testPaymentFailedPledgeDropped() async {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .fixPaymentTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "paymentFailedPledgeDropped")
  }

  @MainActor
  func testCardAuthPledgeDropped() async {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .authenticateCardTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "cardAuthPledgeDropped")
  }

  @MainActor
  func testSurveyAvailable() async {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .completeSurveyTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "surveyAvailable")
  }

  @MainActor
  func testFinalizeYourPledge() async {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .managePledgeTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "finalizeYourPledge")
  }

  // MARK: Test UI edge cases.

  @MainActor
  func testShortTemplateText() async {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .shortTextTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "testShortTemplateText")
  }

  @MainActor
  func testLotsOfFlags() async {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .lotsOfFlagsTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: card, as: .image, named: "testLotsOfFlags")
  }
}
