import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectUpdatesViewModelTests: TestCase {
  private let vm: ProjectUpdatesViewModelType = ProjectUpdatesViewModel()

  private let goToSafariBrowser = TestObserver<NSURL, NoError>()
  private let goToUpdateId = TestObserver<Int, NoError>()
  private let goToUpdateCommentId = TestObserver<Int, NoError>()
  private let webViewLoadRequest = TestObserver<NSURLRequest, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.goToUpdate.map { project, update in update.id }.observe(self.goToUpdateId.observer)
    self.vm.outputs.goToUpdateComments.map { $0.id }.observe(self.goToUpdateCommentId.observer)
    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)
  }

  func testGoToSafariBrowser() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    let googleURL = NSURL(string: "http://www.google.com")!

    self.goToSafariBrowser.assertValues([])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: .init(URL: googleURL)
      )
    )

    self.goToSafariBrowser.assertValues([googleURL])
    XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
    XCTAssertEqual(["project_updates"], self.trackingClient.properties(forKey: "context"))
  }

  func testGoToUpdate() {
    let project = Project.template
      |> (Project.lens.urls.web • Project.UrlsEnvelope.WebEnvelope.lens.updates)
      .~ "https://www.kickstarter.com/projects/milk/duds/posts"

    let updateId = 11235

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: .init(URL: NSURL(string: "\(project.urls.web.updates!)/\(updateId)")!)
      )
    )

    self.goToUpdateId.assertValues([updateId])
  }

  func testGoToUpdateComments() {
    let project = Project.template
      |> (Project.lens.urls.web • Project.UrlsEnvelope.WebEnvelope.lens.updates)
      .~ "https://www.kickstarter.com/projects/smh/lol/posts"

    let updateId = 123456

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: .init(URL: NSURL(string: "\(project.urls.web.updates!)/\(updateId)/comments")!)
      )
    )

    self.goToUpdateCommentId.assertValues([updateId])
  }

  func testWebViewLoadRequests() {
    let project = Project.template
      |> (Project.lens.urls.web • Project.UrlsEnvelope.WebEnvelope.lens.updates)
        .~ "https://www.kickstarter.com/projects/shrimp/ijc/posts"

    let updatesIndexRequest = AppEnvironment.current.apiService.preparedRequest(
      forURL: NSURL(string: project.urls.web.updates!)!
    )

    let updateRequest = NSURLRequest(URL: NSURL(string: "\(project.urls.web.updates!)/1")!)

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues([updatesIndexRequest])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: updateRequest
      )
    )

    self.webViewLoadRequest.assertValues([updatesIndexRequest], "Update loaded in VC, not web view.")
  }
}
