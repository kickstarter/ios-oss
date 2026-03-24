import Combine
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
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

    viewModel.performAction(.authenticateCard(clientSecret: clientSecret))
    waitForExpectations(timeout: 0.1)

    let authenticateCardEvent = PPOCardEvent.authenticateCard(
      clientSecret: clientSecret,
      onProgress: { _ in }
    )
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

  func testProjectDetailsTapped_noProjectPageParam() {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      card: PPOProjectCardModel.authenticateCardTemplate
    )

    let expectation = expectation(description: "Waiting for open project details")
    var didOpenProjectDetails = false
    viewModel.handleEvent
      .sink { event in
        let expectedParam = Param.id(viewModel.card.projectId)
        didOpenProjectDetails = event == .viewProjectDetails(param: expectedParam)
        expectation.fulfill()
      }
      .store(in: &cancellables)

    viewModel.projectDetailsTapped()
    waitForExpectations(timeout: 0.1)

    XCTAssertTrue(didOpenProjectDetails)
  }

  func testProjectDetailsTapped_withProjectPageParam() {
    var cancellables: [AnyCancellable] = []
    let viewModel = PPOProjectCardViewModel(
      card: PPOProjectCardModel.noRewardPledgeCollected
    )

    let expectation = expectation(description: "Waiting for open project details")
    var didOpenProjectDetails = false
    viewModel.handleEvent
      .sink { event in
        let expectedParam = viewModel.card.projectPageParam!
        didOpenProjectDetails = event == .viewProjectDetails(param: expectedParam)
        expectation.fulfill()
      }
      .store(in: &cancellables)

    viewModel.projectDetailsTapped()
    waitForExpectations(timeout: 0.1)

    XCTAssertTrue(didOpenProjectDetails)
  }
}
