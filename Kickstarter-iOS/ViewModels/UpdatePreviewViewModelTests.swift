// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast
@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import KsApi
import Prelude
import ReactiveSwift
import Result
import XCTest

final class UpdatePreviewViewModelTests: TestCase {
  fileprivate let vm: UpdatePreviewViewModelType = UpdatePreviewViewModel()

  fileprivate let showPublishConfirmation = TestObserver<String, NoError>()
  fileprivate let showPublishFailure = TestObserver<(), NoError>()
  fileprivate let goToUpdate = TestObserver<Update, NoError>()
  fileprivate let goToUpdateProject = TestObserver<Project, NoError>()
  fileprivate let webViewLoadRequest = TestObserver<String?, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.showPublishConfirmation.observe(self.showPublishConfirmation.observer)
    self.vm.outputs.showPublishFailure.observe(self.showPublishFailure.observer)
    self.vm.outputs.goToUpdate.map(second).observe(self.goToUpdate.observer)
    self.vm.outputs.goToUpdate.map(first).observe(self.goToUpdateProject.observer)
    self.vm.outputs.webViewLoadRequest.map { $0.url?.absoluteString }
      .observe(self.webViewLoadRequest.observer)
  }

  func testWebViewLoaded() {
    let draft = .template
      |> UpdateDraft.lens.update.id .~ 1
      |> UpdateDraft.lens.update.projectId .~ 2
    self.vm.inputs.configureWith(draft: draft)
    self.vm.inputs.viewDidLoad()

    let previewUrl = "https://\(Secrets.Api.Endpoint.production)/projects/2/updates/1/preview"
    let query = "client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)"
    self.webViewLoadRequest.assertValues(
      ["\(previewUrl)?\(query)"]
    )

    let redirectUrl = "https://www.kickstarter.com/projects/smashmouth/somebody-once-told-me/posts/1"
    let request = URLRequest(url: URL(string: redirectUrl)!)
    let navigationAction = WKNavigationActionData(
      navigationType: .other,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue, policy.rawValue)
    self.webViewLoadRequest.assertValues(
      [
        "\(previewUrl)?\(query)",
        "\(redirectUrl)?\(query)"
      ]
    )
  }

  func testPublishSuccess() {
    let project = .template
      |> Project.lens.id .~ 2
      |> Project.lens.stats.backersCount .~ 1_024
    let draft = .template
      |> UpdateDraft.lens.update.id .~ 1
      |> UpdateDraft.lens.update.projectId .~ project.id

    let api = MockService(fetchProjectResponse: project, fetchUpdateResponse: draft.update)
    withEnvironment(apiService: api) {
      self.vm.inputs.configureWith(draft: draft)
      self.vm.inputs.viewDidLoad()

      self.showPublishConfirmation.assertValues([])
      self.vm.inputs.publishButtonTapped()
      let confirmation =
      "This will notify 1,024 backers that a new update is available. Are you sure you want to post?"
      self.showPublishConfirmation.assertValues([confirmation])

      self.goToUpdate.assertValues([])
      self.goToUpdateProject.assertValues([])

      self.vm.inputs.publishConfirmationButtonTapped()

      self.goToUpdate.assertValues([])
      self.goToUpdateProject.assertValues([])

      self.scheduler.advance()

      self.goToUpdate.assertValues([draft.update])
      self.goToUpdateProject.assertValues([project])
      self.showPublishFailure.assertValueCount(0)

      XCTAssertEqual(
        ["Triggered Publish Confirmation Modal", "Confirmed Publish", "Published Update", "Update Published"],
        trackingClient.events, "Koala event is tracked.")
    }
  }

  func testPublishCanceled() {
    let project = .template
      |> Project.lens.id .~ 2
      |> Project.lens.stats.backersCount .~ 1_024
    let draft = .template
      |> UpdateDraft.lens.update.id .~ 1
      |> UpdateDraft.lens.update.projectId .~ project.id

    let api = MockService(fetchProjectResponse: project, fetchUpdateResponse: draft.update)
    withEnvironment(apiService: api) {
      self.vm.inputs.configureWith(draft: draft)
      self.vm.inputs.viewDidLoad()

      self.showPublishConfirmation.assertValues([])
      self.vm.inputs.publishButtonTapped()
      let confirmation =
      "This will notify 1,024 backers that a new update is available. Are you sure you want to post?"
      self.showPublishConfirmation.assertValues([confirmation])

      self.goToUpdate.assertValues([])
      self.goToUpdateProject.assertValues([])

      self.vm.inputs.publishCancelButtonTapped()

      self.scheduler.advance()

      self.goToUpdate.assertValues([])
      self.goToUpdateProject.assertValues([])

      XCTAssertEqual(
        ["Triggered Publish Confirmation Modal", "Canceled Publish"],
        trackingClient.events, "Koala event is tracked.")
    }
  }

  func testPublishFailure() {
    let project = .template
      |> Project.lens.id .~ 2
      |> Project.lens.stats.backersCount .~ 1_024
    let draft = .template
      |> UpdateDraft.lens.update.id .~ 1
      |> UpdateDraft.lens.update.projectId .~ project.id

    let api = MockService(publishUpdateError: .couldNotParseJSON, fetchProjectResponse: project)
    withEnvironment(apiService: api) {
      self.vm.inputs.configureWith(draft: draft)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.publishButtonTapped()

      self.showPublishFailure.assertValueCount(0)
      self.vm.inputs.publishConfirmationButtonTapped()

      self.scheduler.advance()

      self.goToUpdate.assertValues([])
      self.showPublishFailure.assertValueCount(1)
    }

    XCTAssertEqual(["Triggered Publish Confirmation Modal", "Confirmed Publish"],
                   trackingClient.events, "Koala event is not tracked.")
  }
}
