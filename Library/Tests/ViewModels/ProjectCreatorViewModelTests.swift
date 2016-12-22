import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectCreatorViewModelTests: TestCase {
  fileprivate let vm: ProjectCreatorViewModelType = ProjectCreatorViewModel()

  fileprivate let goToMessageDialogContext = TestObserver<Koala.MessageDialogContext, NoError>()
  fileprivate let goToMessageDialogSubject = TestObserver<MessageSubject, NoError>()
  fileprivate let goToSafariBrowser = TestObserver<URL, NoError>()
  fileprivate let loadWebViewRequest = TestObserver<URLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToMessageDialog.map(second).observe(self.goToMessageDialogContext.observer)
    self.vm.outputs.goToMessageDialog.map(first).observe(self.goToMessageDialogSubject.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.loadWebViewRequest.observe(self.loadWebViewRequest.observer)
  }

  func testGoToMessageDialog() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToMessageDialogContext.assertValues([])
    self.goToMessageDialogSubject.assertValues([])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .other,
        request: .init(url: URL(string: "https://www.kickstarter.com/projects/a/b/creator_bio")!)
      )
    )

    self.goToMessageDialogContext.assertValues([])
    self.goToMessageDialogSubject.assertValues([])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .linkActivated,
        request: .init(url: URL(string: "https://www.kickstarter.com/projects/a/b/messages/new")!)
      )
    )

    self.goToMessageDialogContext.assertValues([.projectPage])
    self.goToMessageDialogSubject.assertValues([.project(project)])
  }

  func testGoToSafariBrowser() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToSafariBrowser.assertValues([])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .other,
        request: .init(url: URL(string: "https://www.kickstarter.com/projects/a/b/creator_bio")!)
      )
    )

    self.goToSafariBrowser.assertValues([])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .linkActivated,
        request: .init(url: URL(string: "http://www.google.com")!)
      )
    )

    self.goToSafariBrowser.assertValues([URL(string: "http://www.google.com")!])
    XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
    XCTAssertEqual(["project_creator"], self.trackingClient.properties(forKey: "context"))
  }

  func testLoadWebViewRequest() {
    let project = Project.template
    let creatorBioRequest = AppEnvironment.current.apiService.preparedRequest(
      forURL: URL(string: "\(project.urls.web.project)/creator_bio")!
    )

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadWebViewRequest.assertValues([creatorBioRequest])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .linkActivated,
        request: .init(url: URL(string: "http://www.google.com")!)
      )
    )

    self.loadWebViewRequest.assertValues([creatorBioRequest])
  }
}
