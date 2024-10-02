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
          isUnread: true,
          alerts: [
            PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 8 hours")
          ],
          imageURL: URL(string: "http://localhost/")!,
          title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
          project: Project.template,
          pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
          creatorName: "rokaplay truncate if longer than",
          address: """
            Firsty Lasty
            123 First Street, Apt #5678
            Los Angeles, CA 90025-1234
            United States
          """,
          actions: (.confirmAddress, .editAddress),
          tierType: .confirmAddress,
          parentSize: self.size
        ))
        .frame(width: self.size.width)
        .frame(maxHeight: .infinity)
        .padding()
      }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "addressLocks")
  }

  func testSurveyAvailableAddressLocks() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        isUnread: true,
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available"),
          PPOProjectCardViewModel.Alert(type: .time, icon: .warning, message: "Address locks in 48 hours")
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        project: Project.template,
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: """
          Firsty Lasty
          123 First Street, Apt #5678
          Los Angeles, CA 90025-1234
          United States
        """,
        actions: (.confirmAddress, .editAddress),
        tierType: .confirmAddress,
        parentSize: self.size
      ))
      .frame(width: self.size.width)
      .frame(maxHeight: .infinity)
      .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "surveyAvailableAddressLocks")
  }

  func testPaymentFailedPledgeDropped() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        isUnread: true,
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Payment failed"),
          PPOProjectCardViewModel.Alert(
            type: .time,
            icon: .alert,
            message: "Pledge will be dropped in 6 days"
          )
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        project: Project.template,
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: nil,
        actions: (.fixPayment, nil),
        tierType: .fixPayment,
        parentSize: self.size
      ))
      .frame(width: self.size.width)
      .frame(maxHeight: .infinity)
      .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "paymentFailedPledgeDropped")
  }

  func testCardAuthPledgeDropped() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        isUnread: true,
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .alert, message: "Card needs authentication"),
          PPOProjectCardViewModel.Alert(
            type: .time,
            icon: .alert,
            message: "Pledge will be dropped in 6 days"
          )
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        project: Project.template,
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: nil,
        actions: (.authenticateCard, nil),
        tierType: .authenticateCard,
        parentSize: self.size
      ))
      .frame(width: self.size.width)
      .frame(maxHeight: .infinity)
      .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "cardAuthPledgeDropped")
  }

  func testSurveyAvailable() {
    let card = VStack {
      PPOProjectCard(viewModel: PPOProjectCardViewModel(
        isUnread: true,
        alerts: [
          PPOProjectCardViewModel.Alert(type: .alert, icon: .warning, message: "Survey available")
        ],
        imageURL: URL(string: "http://localhost/")!,
        title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
        project: Project.template,
        pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
        creatorName: "rokaplay truncate if longer than",
        address: """
          Firsty Lasty
          123 First Street, Apt #5678
          Los Angeles, CA 90025-1234
          United States
        """,
        actions: (.confirmAddress, .editAddress),
        tierType: .confirmAddress,
        parentSize: self.size
      ))
      .frame(width: self.size.width)
      .frame(maxHeight: .infinity)
      .padding()
    }.frame(height: 500)
    assertSnapshot(matching: card, as: .image, named: "surveyAvailable")
  }
}
