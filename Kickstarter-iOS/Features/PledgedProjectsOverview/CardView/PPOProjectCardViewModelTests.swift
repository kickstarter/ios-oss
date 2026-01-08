import Combine
@testable import Kickstarter_Framework
@testable import KsApi
import XCTest

final class PPOProjectCardViewModelTests: XCTestCase {
  func testAuthenticateCardButtonAction() throws {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      card: PPOProjectCardModel.authenticateCardTemplate
    )
    let clientSecret = "test123"

    let expectation = expectation(description: "Waiting for action to be performed")
    var events: [PPOCardEvent] = []
    viewModel.handleEvent
      .sink { event in
        events.append(event)
        expectation.fulfill()
      }
      .store(in: &cancellables)

    let authenticateCardEvent = PPOCardEvent.authenticateCard(clientSecret: clientSecret)

    viewModel.performAction(.authenticateCard(clientSecret: clientSecret))
    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(events, [authenticateCardEvent])
  }

  func testSendMessageEvent() throws {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      card: PPOProjectCardModel.authenticateCardTemplate
    )

    let expectation = expectation(description: "Waiting for message to be sent")
    var didSendMessage = false
    viewModel.handleEvent
      .sink { event in
        didSendMessage = event == .sendMessage
        expectation.fulfill()
      }
      .store(in: &cancellables)

    viewModel.eventTriggered(.sendMessage)
    waitForExpectations(timeout: 0.1)

    XCTAssertTrue(didSendMessage)
  }
}
