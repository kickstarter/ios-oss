@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import KsApi
import Prelude
import ReactiveCocoa
import Result
import XCTest

final class UpdateViewModelTests: TestCase {
  private let vm: UpdateViewModelType = UpdateViewModel()

  private let project = .template |> Project.lens.id .~ 1
  private let update = .template
    |> Update.lens.projectId .~ 1

  private let goToComments = TestObserver<Update, NoError>()
  private let goToProject = TestObserver<Project, NoError>()
  private let title = TestObserver<String, NoError>()
  private let webViewLoadRequest = TestObserver<String?, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.webViewLoadRequest.map { $0.URL?.absoluteString }
      .observe(self.webViewLoadRequest.observer)
  }

  func testUpdateUrlLoads() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(
      ["\(self.update.urls.web.update)?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)"]
    )
  }

  func testTitle() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    self.title.assertValues(
      [Strings.activity_project_update_update_count(update_count: String(self.update.sequence))]
    )
  }

  func testGoToAnotherUpdate() {
    let prevUpdate = .template
      |> Update.lens.id .~ 42
      |> Update.lens.sequence .~ 42

    let prevUpdateUrl = NSURL(string: prevUpdate.urls.web.update)
      .flatMap { $0.URLByDeletingLastPathComponent }
      .map { $0.URLByAppendingPathComponent(String(prevUpdate.id)) }!

    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(fetchUpdateResponse: prevUpdate)) {
      let policy = self.vm.inputs.decidePolicyFor(
        navigationAction: MockNavigationAction(
          navigationType: .LinkActivated,
          request: NSURLRequest(URL: prevUpdateUrl)
        )
      )

      XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue, policy.rawValue)

      self.webViewLoadRequest.assertValues(
        [
          "\(self.update.urls.web.update)?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)",
          "\(prevUpdateUrl.absoluteString)?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)"
        ]
      )

      self.title.assertValues(
        [
          Strings.activity_project_update_update_count(update_count: String(self.update.sequence)),
          Strings.activity_project_update_update_count(update_count: String(prevUpdate.sequence))
        ]
      )
    }
  }

  func testGoToProject() {
    let anotherProject = .template |> Project.lens.id .~ 42
    let anotherProjectUrl = NSURL(string: anotherProject.urls.web.project)
      .flatMap { $0.URLByDeletingLastPathComponent }
      .map { $0.URLByAppendingPathComponent(String(anotherProject.id)) }!

    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(fetchProjectResponse: anotherProject)) {
      let policy = self.vm.inputs.decidePolicyFor(
        navigationAction: MockNavigationAction(
          navigationType: .LinkActivated,
          request: NSURLRequest(URL: anotherProjectUrl)
        )
      )

      XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue, policy.rawValue)

      self.goToProject.assertValues([anotherProject])
      self.goToComments.assertValueCount(0)
    }

    self.webViewLoadRequest.assertValues(
      ["\(self.update.urls.web.update)?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)"]
    )
  }
}
