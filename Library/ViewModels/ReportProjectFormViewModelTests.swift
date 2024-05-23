@testable import KsApi
@testable import Library

import XCTest

final class ReportProjectFormViewModelTests: TestCase {
  // MARK: Computed Properties

  private var userEmailSuccessMockService: MockService {
    let fetchUserEmailQueryData = GraphAPI.FetchUserEmailQuery
      .Data(unsafeResultMap: GraphUserEnvelopeTemplates.userJSONDict)

    guard let envelope = UserEnvelope<GraphUserEmail>.userEnvelope(from: fetchUserEmailQueryData) else {
      return MockService()
    }

    let mockService = MockService(
      fetchGraphUserEmailResult: .success(envelope)
    )

    return mockService
  }

  func testEmailText_AfterFetchingUsersEmail() {
    let vm = ReportProjectFormViewModel()
    vm.projectID = "123"
    vm.projectFlaggingKind = GraphAPI.NonDeprecatedFlaggingKind.commentDoxxing

    withEnvironment(apiService: self.userEmailSuccessMockService) {
      let userEmail = CombineTestObserver<String?, Never>()
      userEmail.observe(vm.$retrievedEmail)

      XCTAssertEqual(userEmail.events.count, 1)

      if case let .value(value) = userEmail.events.last {
        XCTAssertEqual(value, nil)
      }

      vm.inputs.viewDidLoad()
      self.scheduler.advance()

      XCTAssertEqual(userEmail.events.count, 2)

      if case let .value(value) = userEmail.events.last {
        XCTAssertEqual(value, "user@example.com")
      } else {
        XCTFail()
      }
    }
  }

  func test_submitIsDisabled_untilDetailTextIsNotEmpty() {
    let vm = ReportProjectFormViewModel()
    vm.projectID = "123"
    vm.projectFlaggingKind = GraphAPI.NonDeprecatedFlaggingKind.commentDoxxing

    let saveButtonEnabled = CombineTestObserver<Bool, Never>()
    saveButtonEnabled.observe(vm.$saveButtonEnabled)

    XCTAssertEqual(saveButtonEnabled.events.count, 1)

    if case let .value(value) = saveButtonEnabled.events.last {
      XCTAssertEqual(value, false)
    } else {
      XCTFail()
    }

    vm.detailsText = "This is my report. I don't like this project very much."
    XCTAssertEqual(saveButtonEnabled.events.count, 2)
    if case let .value(value) = saveButtonEnabled.events.last {
      XCTAssertEqual(value, true)
    } else {
      XCTFail()
    }

    vm.detailsText = ""

    XCTAssertEqual(saveButtonEnabled.events.count, 3)
    if case let .value(value) = saveButtonEnabled.events.last {
      XCTAssertEqual(value, false)
    } else {
      XCTFail()
    }
  }
}
