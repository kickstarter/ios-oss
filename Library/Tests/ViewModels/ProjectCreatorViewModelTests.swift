import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectCreatorViewModelTests: TestCase {
  private let vm: ProjectCreatorViewModelType = ProjectCreatorViewModel()

  private let goToMessageDialogContext = TestObserver<Koala.MessageDialogContext, NoError>()
  private let goToMessageDialogSubject = TestObserver<MessageSubject, NoError>()
  private let goToSafariBrowser = TestObserver<NSURL, NoError>()
  private let loadWebViewRequest = TestObserver<NSURLRequest, NoError>()

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
        navigationType: .Other,
        request: .init(URL: NSURL(string: "https://www.kickstarter.com/projects/a/b/creator_bio")!)
      )
    )

    self.goToMessageDialogContext.assertValues([])
    self.goToMessageDialogSubject.assertValues([])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: .init(URL: NSURL(string: "https://www.kickstarter.com/projects/a/b/messages/new")!)
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
        navigationType: .Other,
        request: .init(URL: NSURL(string: "https://www.kickstarter.com/projects/a/b/creator_bio")!)
      )
    )

    self.goToSafariBrowser.assertValues([])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: .init(URL: NSURL(string: "http://www.google.com")!)
      )
    )

    self.goToSafariBrowser.assertValues([NSURL(string: "http://www.google.com")!])
  }

  func testLoadWebViewRequest() {
    let project = Project.template
    let creatorBioRequest = AppEnvironment.current.apiService.preparedRequest(
      forURL: NSURL(string: "\(project.urls.web.project)/creator_bio")!
    )

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadWebViewRequest.assertValues([creatorBioRequest])

    self.vm.inputs.decidePolicy(
      forNavigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: .init(URL: NSURL(string: "http://www.google.com")!)
      )
    )

    self.loadWebViewRequest.assertValues([creatorBioRequest])
  }
}
