import Combine
@testable import Kickstarter_Framework
@testable import KsApi
import XCTest

final class PPOProjectCardViewModelTests: XCTestCase {
  func testPerformAction() throws {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      card: PPOProjectCardModel.authenticateCardTemplate
    )

    let expectation = expectation(description: "Waiting for action to be performed")
    var actions: [PPOProjectCardModel.Action] = []
    viewModel.actionPerformed
      .sink { action in
        actions.append(action)
        expectation.fulfill()
      }
      .store(in: &cancellables)

    viewModel.performAction(action: .authenticateCard(clientSecret: "test123"))
    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(actions, [.authenticateCard(clientSecret: "test123")])
  }

  func testSendMessage() throws {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      card: PPOProjectCardModel.authenticateCardTemplate
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
