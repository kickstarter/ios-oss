import Combine
@testable import Kickstarter_Framework
import KsApi
import XCTest

final class PPOProjectCardViewModelTests: XCTestCase {
  func testPerformAction() throws {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      isUnread: true,
      alerts: [],
      imageURL: URL(string: "http://localhost/")!,
      title: "Test project",
      pledge: GraphAPI.MoneyFragment.init(amount: "50.00", currency: .usd, symbol: "$"),
      creatorName: "Dave",
      address: nil,
      actions: (.authenticateCard, nil)
    )

    let expectation = expectation(description: "Waiting for action to be performed")
    var actions: [PPOProjectCardViewModel.Action] = []
    viewModel.actionPerformed
      .sink { action in
        actions.append(action)
        expectation.fulfill()
      }
      .store(in: &cancellables)

    viewModel.performAction(action: .authenticateCard)
    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(actions, [.authenticateCard])
  }

  func testSendMessage() throws {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      isUnread: true,
      alerts: [],
      imageURL: URL(string: "http://localhost/")!,
      title: "Test project",
      pledge: GraphAPI.MoneyFragment.init(amount: "50.00", currency: .usd, symbol: "$"),
      creatorName: "Dave",
      address: nil,
      actions: (.authenticateCard, nil)
    )

    let expectation = expectation(description: "Waiting for message to be sent")
    var didSendMessage = false
    viewModel.sendMessageTapped
      .sink { () in
        didSendMessage = true
        expectation.fulfill()
      }
      .store(in: &cancellables)

    viewModel.sendCreatorMessage()
    waitForExpectations(timeout: 0.1)

    XCTAssertTrue(didSendMessage)
  }
}
