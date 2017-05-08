// swiftlint:disable force_unwrapping
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectCreatorViewModelTests: TestCase {
  fileprivate let vm: ProjectCreatorViewModelType = ProjectCreatorViewModel()

  fileprivate let goToLoginTout = TestObserver<LoginIntent, NoError>()
  fileprivate let goToMessageDialogContext = TestObserver<Koala.MessageDialogContext, NoError>()
  fileprivate let goToMessageDialogSubject = TestObserver<MessageSubject, NoError>()
  fileprivate let goToSafariBrowser = TestObserver<URL, NoError>()
  fileprivate let loadWebViewRequest = TestObserver<URLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.goToMessageDialog.map(second).observe(self.goToMessageDialogContext.observer)
    self.vm.outputs.goToMessageDialog.map(first).observe(self.goToMessageDialogSubject.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.loadWebViewRequest.observe(self.loadWebViewRequest.observer)
  }

  func testGoToLoginTout() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToLoginTout.assertValueCount(0)

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

    self.goToLoginTout.assertValueCount(0)

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

    self.goToLoginTout.assertValues([.messageCreator])
  }

  func testGoToMessageDialog_LoggedIn() {
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

  func testGoToMessageDialog_LoggedOut() {
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

    self.goToMessageDialogContext.assertValues([])
    self.goToMessageDialogSubject.assertValues([])
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
