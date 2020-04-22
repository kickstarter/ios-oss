@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectCreatorViewModelTests: TestCase {
  fileprivate let vm: ProjectCreatorViewModelType = ProjectCreatorViewModel()

  fileprivate let goBackToProject = TestObserver<(), Never>()
  fileprivate let goToLoginTout = TestObserver<LoginIntent, Never>()
  fileprivate let goToMessageDialogContext = TestObserver<Koala.MessageDialogContext, Never>()
  fileprivate let goToMessageDialogSubject = TestObserver<MessageSubject, Never>()
  fileprivate let goToSafariBrowser = TestObserver<URL, Never>()
  fileprivate let loadWebViewRequest = TestObserver<URLRequest, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goBackToProject.observe(self.goBackToProject.observer)
    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.goToMessageDialog.map(second).observe(self.goToMessageDialogContext.observer)
    self.vm.outputs.goToMessageDialog.map(first).observe(self.goToMessageDialogSubject.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.loadWebViewRequest.observe(self.loadWebViewRequest.observer)
  }

  func testGoToLoginTout_LoggedOut() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToMessageDialogContext.assertValueCount(0)
    self.goToMessageDialogSubject.assertValueCount(0)
    self.goToLoginTout.assertValueCount(0)

    let messagesRequest = URLRequest(
      url: URL(string: "https://www.kickstarter.com/projects/a/b/messages/new")!
    )
    let policy = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .linkActivated,
        request: messagesRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: messagesRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: messagesRequest)
      )
    )
    XCTAssertEqual(.cancel, policy)

    self.goToMessageDialogContext.assertValues([])
    self.goToMessageDialogSubject.assertValues([])
    self.goToLoginTout.assertValues([.messageCreator])
  }

  func testGoToLoginTout_LoggedIn() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToLoginTout.assertValueCount(0)

    let messagesRequest = URLRequest(
      url: URL(string: "https://www.kickstarter.com/projects/a/b/messages/new")!
    )
    let policy = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .linkActivated,
        request: messagesRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: messagesRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: messagesRequest)
      )
    )
    XCTAssertEqual(.cancel, policy)

    self.goToLoginTout.assertValueCount(0)
  }

  func testGoToMessageDialog() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToMessageDialogContext.assertValues([])
    self.goToMessageDialogSubject.assertValues([])

    let creatorBioRequest = URLRequest(
      url: URL(string: "https://www.kickstarter.com/projects/a/b/creator_bio")!
    )
    var policy = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .other,
        request: creatorBioRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: creatorBioRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: creatorBioRequest)
      )
    )
    XCTAssertEqual(.allow, policy)

    self.goToMessageDialogContext.assertValues([])
    self.goToMessageDialogSubject.assertValues([])

    let messagesRequest = URLRequest(
      url: URL(string: "https://www.kickstarter.com/projects/a/b/messages/new")!
    )
    policy = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .linkActivated,
        request: messagesRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: messagesRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: messagesRequest)
      )
    )
    XCTAssertEqual(.cancel, policy)

    self.goToMessageDialogContext.assertValues([.projectPage])
    self.goToMessageDialogSubject.assertValues([.project(project)])
  }

  func testGoBackToProjectDoesNotEmit_whenRequestURL_IsEqualToProjectURL() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goBackToProject.assertDidNotEmitValue()

    let projectRequest = URLRequest(
      url: URL(string: "https://www.kickstarter.com/projects/creator/a-fun-project")!
    )
    _ = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .linkActivated,
        request: projectRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: projectRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: projectRequest)
      )
    )
    self.goBackToProject.assertDidEmitValue()
  }

  func testGoBackToProjectDoesNotEmit_whenRequestURL_IsNotEqualToProjectURL() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goBackToProject.assertDidNotEmitValue()

    let linkRequest = URLRequest(
      url: URL(string: "https://www.kickstarter.com/projects/creator/about")!
    )
    _ = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .linkActivated,
        request: linkRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: linkRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: linkRequest)
      )
    )
    self.goBackToProject.assertDidNotEmitValue()
  }

  func testGoToSafariBrowser() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToSafariBrowser.assertValues([])

    let creatorBioRequest = URLRequest(
      url: URL(string: "https://www.kickstarter.com/projects/a/b/creator_bio")!
    )
    var policy = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .other,
        request: creatorBioRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: creatorBioRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: creatorBioRequest)
      )
    )
    XCTAssertEqual(.allow, policy)

    self.goToSafariBrowser.assertValues([])

    let googleRequest = URLRequest(
      url: URL(string: "http://www.google.com")!
    )
    policy = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .linkActivated,
        request: googleRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: googleRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: googleRequest)
      )
    )
    XCTAssertEqual(.cancel, policy)

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

    let googleRequest = URLRequest(
      url: URL(string: "https://www.google.com")!
    )
    let policy = self.vm.inputs.decidePolicy(
      forNavigationAction: WKNavigationActionData(
        navigationType: .linkActivated,
        request: googleRequest,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: googleRequest),
        targetFrame: WKFrameInfoData(mainFrame: true, request: googleRequest)
      )
    )
    XCTAssertEqual(.cancel, policy)

    self.loadWebViewRequest.assertValues([creatorBioRequest])
  }
}
