import Combine
@testable import Kickstarter_Framework
@testable import KsApi
import XCTest

final class PPOProjectCardViewModelTests: XCTestCase {
  func testPerformAction() throws {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      card: PledgedProjectOverviewCard.authenticateCardTemplate,
      parentSize: CGSize(width: 375, height: 700)
    )

    let expectation = expectation(description: "Waiting for action to be performed")
    var actions: [PledgedProjectOverviewCard.Action] = []
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
      card: PledgedProjectOverviewCard.authenticateCardTemplate,
      parentSize: CGSize(width: 375, height: 700)
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
