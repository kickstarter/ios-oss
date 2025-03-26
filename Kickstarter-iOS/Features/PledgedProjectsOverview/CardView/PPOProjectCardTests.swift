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
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

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
}
