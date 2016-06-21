import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import Prelude

final class ProjectActivitiesViewModelTests: TestCase {
  private let vm: ProjectActivitiesViewModelType = ProjectActivitiesViewModel()

  private let activitiesPresent = TestObserver<Bool, NoError>()
  private let isRefreshing = TestObserver<Bool, NoError>()
  private let showEmptyState = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activities.map { !$0.isEmpty }.observe(self.activitiesPresent.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.showEmptyState.observe(self.showEmptyState.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func testFlow() {
    let project = Project.template

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 1])) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.activitiesPresent.assertDidNotEmitValue("No activities")

      self.scheduler.advance()
      self.activitiesPresent.assertValues([true], "Show activities after scheduler advances")
    }

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 2])) {
      self.vm.inputs.refresh()
      self.scheduler.advance()
      self.activitiesPresent.assertValues([true, true], "Activities refreshed")
    }

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 3])) {
      self.vm.inputs.willDisplayRow(9, outOf: 10)
      self.scheduler.advance()
      self.activitiesPresent.assertValues([true, true, true], "Activities paginate")
    }

    self.showEmptyState.assertValues([false],
                                     "Don't show, because each activity emission was a non-empty array")
  }

  func testEmptyState() {
    let project = Project.template

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse: [])) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.activitiesPresent.assertValues([false], "No activities")
      self.showEmptyState.assertValues([true], "Activities not present, show empty state")
    }
  }
}
