@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ReportProjectFormViewModelTests: TestCase {
  fileprivate let vm: ReportProjectFormViewModelType = ReportProjectFormViewModel()

  private let userEmail = TestObserver<String, Never>()

  // MARK: Computed Properties

  private var userEmailSuccessMockService: MockService {
    let fetchUserQueryData = GraphAPI.FetchUserQuery
      .Data(unsafeResultMap: GraphUserEnvelopeTemplates.userJSONDict)
    guard let envelope = UserEnvelope<GraphUser>.userEnvelope(from: fetchUserQueryData) else {
      return MockService()
    }

    let mockService = MockService(
      fetchGraphUserResult: .success(envelope)
    )

    return mockService
  }

  override func setUp() {
    super.setUp()

    self.vm.outputs.userEmail.observe(self.userEmail.observer)
  }

  func testEmailText_AfterFetchingUsersEmail() {
    withEnvironment(apiService: self.userEmailSuccessMockService) {
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.userEmail.assertValues(["nativesquad@ksr.com"])
    }
  }
}
