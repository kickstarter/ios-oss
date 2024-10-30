@testable import Kickstarter_Framework
@testable import KsApi
import SnapshotTesting
import SwiftUI
import XCTest

final class PPOProjectCardTests: TestCase {
  let size = CGSize(width: 375, height: 700)
  func testAddressLocks() {
    let card =
      VStack {
        PPOProjectCard(viewModel: PPOProjectCardViewModel(
          card: .confirmAddressTemplate
        ), parentSize: self.size)
          .frame(width: self.size.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "addressLocks")
  }

  func testSurveyAvailableAddressLocks() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .addressLockTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "surveyAvailableAddressLocks")
  }

  func testPaymentFailedPledgeDropped() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .fixPaymentTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "paymentFailedPledgeDropped")
  }

  func testCardAuthPledgeDropped() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .authenticateCardTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "cardAuthPledgeDropped")
  }

  func testSurveyAvailable() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        card: .completeSurveyTemplate
      ), parentSize: self.size)
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "surveyAvailable")
  }
}
