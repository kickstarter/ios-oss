@testable import Kickstarter_Framework
import SnapshotTesting
import SwiftUI
import XCTest

final class PPOProjectCardTests: TestCase {
  func testAddressLocks() {
    let card = PPOProjectCard(viewModel: PPOProjectCardViewModel(
      isUnread: true,
      alerts: [
        PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 8 hours")
      ],
      imageURL: URL(string: "http://localhost/")!,
      title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
      creatorName: "rokaplay truncate if longer than",
      address: """
        Firsty Lasty
        123 First Street, Apt #5678
        Los Angeles, CA 90025-1234
        United States
      """,
      actions: (.confirmAddress, .editAddress)
    ))
    .frame(minWidth: 375, maxWidth: 375, maxHeight: .infinity)
    .padding()
    assertSnapshot(matching: card, as: .image, named: "addressLocks")
  }

  func testSurveyAvailableAddressLocks() {
    let card = PPOProjectCard(viewModel: PPOProjectCardViewModel(
      isUnread: true,
      alerts: [
        PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available"),
        PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 48 hours")
      ],
      imageURL: URL(string: "http://localhost/")!,
      title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
      creatorName: "rokaplay truncate if longer than",
      address: nil,
      actions: (.completeSurvey, nil)
    ))
    .frame(minWidth: 375, maxWidth: 375, maxHeight: .infinity)
    .padding()
    assertSnapshot(matching: card, as: .image, named: "surveyAvailableAddressLocks")
  }

  func testPaymentFailedPledgeDropped() {
    let card = PPOProjectCard(viewModel: PPOProjectCardViewModel(
      isUnread: true,
      alerts: [
        PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Payment failed"),
        PPOProjectCardViewModel.Alert(type: .time, icon: .alert, message: "Pledge will be dropped in 6 days")
      ],
      imageURL: URL(string: "http://localhost/")!,
      title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
      creatorName: "rokaplay truncate if longer than",
      address: nil,
      actions: (.fixPayment, nil)
    ))
    .frame(minWidth: 375, maxWidth: 375, maxHeight: .infinity)
    .padding()
    assertSnapshot(matching: card, as: .image, named: "paymentFailedPledgeDropped")
  }

  func testCardAuthPledgeDropped() {
    let card = PPOProjectCard(viewModel: PPOProjectCardViewModel(
      isUnread: true,
      alerts: [
        PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Card needs authentication"),
        PPOProjectCardViewModel.Alert(type: .time, icon: .alert, message: "Pledge will be dropped in 6 days")
      ],
      imageURL: URL(string: "http://localhost/")!,
      title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
      creatorName: "rokaplay truncate if longer than",
      address: nil,
      actions: (.authenticateCard, nil)
    ))
    .frame(minWidth: 375, maxWidth: 375, maxHeight: .infinity)
    .padding()
    assertSnapshot(matching: card, as: .image, named: "cardAuthPledgeDropped")
  }

  func testSurveyAvailable() {
    let card = PPOProjectCard(viewModel: PPOProjectCardViewModel(
      isUnread: true,
      alerts: [
        PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available")
      ],
      imageURL: URL(string: "http://localhost/")!,
      title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
      creatorName: "rokaplay truncate if longer than",
      address: nil,
      actions: (.completeSurvey, nil)
    ))
    .frame(minWidth: 375, maxWidth: 375, maxHeight: .infinity)
    .padding()
    assertSnapshot(matching: card, as: .image, named: "surveyAvailable")
  }
}
