import XCTest
import UIKit
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import Library
import Prelude
import ReactiveCocoa
import Result

final class UpdateDraftViewModelTests: TestCase {
  let vm: UpdateDraftViewModelType = UpdateDraftViewModel()
  let attachments = TestObserver<[UpdateDraft.Attachment], NoError>()
  let body = TestObserver<String, NoError>()
  let bodyTextViewBecomeFirstResponder = TestObserver<(), NoError>()
  let isLoading = TestObserver<Bool, NoError>()
  let isBackersOnly = TestObserver<Bool, NoError>()
  let isPreviewButtonEnabled = TestObserver<Bool, NoError>()
  let notifyPresenterViewControllerWantsDismissal = TestObserver<(), NoError>()
  let resignFirstResponder = TestObserver<(), NoError>()
  let showLoadFailure = TestObserver<(), NoError>()
  let showPreview = TestObserver<NSURL, NoError>()
  let showSaveFailure = TestObserver<(), NoError>()
  let title = TestObserver<String, NoError>()
  let titleTextFieldBecomeFirstResponder = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.attachments.observe(self.attachments.observer)
    vm.outputs.body.observe(self.body.observer)
    vm.outputs.bodyTextViewBecomeFirstResponder.observe(self.bodyTextViewBecomeFirstResponder.observer)
    vm.outputs.isBackersOnly.observe(self.isBackersOnly.observer)
    vm.outputs.isLoading.observe(self.isLoading.observer)
    vm.outputs.isPreviewButtonEnabled.observe(self.isPreviewButtonEnabled.observer)
    vm.outputs.notifyPresenterViewControllerWantsDismissal
      .observe(self.notifyPresenterViewControllerWantsDismissal.observer)
    vm.outputs.resignFirstResponder.observe(self.resignFirstResponder.observer)
    vm.outputs.showLoadFailure.observe(self.showLoadFailure.observer)
    vm.outputs.showPreview.observe(self.showPreview.observer)
    vm.outputs.showSaveFailure.observe(self.showSaveFailure.observer)
    vm.outputs.title.observe(self.title.observer)
    vm.outputs.titleTextFieldBecomeFirstResponder.observe(self.titleTextFieldBecomeFirstResponder.observer)
  }

  func testConfiguredEmpty() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.title.assertValues([""])
      self.body.assertValues([""])
      self.isBackersOnly.assertValues([false])
      self.attachments.assertValues([[]])
    }
  }

  func testConfiguredWithTitle() {
    let draft = .template |> UpdateDraft.lens.update.title .~ "Hello, world!"
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.title.assertValues(["Hello, world!"])
    }
  }

  func testConfiguredWithBody() {
    let draft = .template |> UpdateDraft.lens.update.body .~ "Thanks for your support!"
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.body.assertValues(["Thanks for your support!"])
    }
  }

  func testConfiguredWithPublic() {
    let draft = .template |> UpdateDraft.lens.update.isPublic .~ true
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.isBackersOnly.assertValues([false])
    }
  }

  func testConfiguredWithPrivate() {
    let draft = .template |> UpdateDraft.lens.update.isPublic .~ false
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.isBackersOnly.assertValues([true])
    }
  }

  func testConfiguredWithVideo() {
    let video = UpdateDraft.Video.template
    let draft = .template |> UpdateDraft.lens.video .~ video
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.attachments.assertValues([[.video(video)]])
    }
  }

  func testConfiguredWithImages() {
    let images = [.template, .template |> UpdateDraft.Image.lens.id %~ { $0 + 1 }]
    let draft = .template |> UpdateDraft.lens.images .~ images
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.attachments.assertValues([images.map(UpdateDraft.Attachment.image)])
    }
  }

  func testConfiguredWithVideoAndImages() {
    let video = UpdateDraft.Video.template
    let images = [.template, .template |> UpdateDraft.Image.lens.id %~ { $0 + 1 }]
    let draft = .template
      |> UpdateDraft.lens.video .~ video
      |> UpdateDraft.lens.images .~ images
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.attachments.assertValues([images.map(UpdateDraft.Attachment.image) + [.video(video)]])
    }
  }

  func testPreviewButtonEnabled() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.isPreviewButtonEnabled.assertValues([false], "emits on view did load")

      self.scheduler.advance()

      self.vm.inputs.titleTextChanged("Hello")
      self.isPreviewButtonEnabled.assertValues([false])

      self.vm.inputs.titleTextChanged("Hello, world!")
      self.isPreviewButtonEnabled.assertValues([false])

      self.vm.inputs.bodyTextChanged("Thanks for believing in me.")
      self.isPreviewButtonEnabled.assertValues([false, true])

      self.vm.inputs.bodyTextChanged("")
      self.isPreviewButtonEnabled.assertValues([false, true, false])

      self.vm.inputs.bodyTextChanged(" ")
      self.isPreviewButtonEnabled.assertValues([false, true, false])

      self.vm.inputs.bodyTextChanged(" \n\n\n")
      self.isPreviewButtonEnabled.assertValues([false, true, false])

      self.vm.inputs.bodyTextChanged("Thanks for believing in my project!")
      self.isPreviewButtonEnabled.assertValues([false, true, false, true])
    }
  }

  func testIsLoading() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.isLoading.assertValues([true], "is loading")

      self.scheduler.advance()

      self.isLoading.assertValues([true, false], "is loaded")
    }
  }

  func testBlankTitleBecomesFirstReponder() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.titleTextFieldBecomeFirstResponder.assertValueCount(1)
      self.bodyTextViewBecomeFirstResponder.assertValueCount(0)
    }
  }

  func testBlankBodyBecomesFirstReponderWithTitlePresent() {
    let titled = .empty |> UpdateDraft.lens.update.title .~ "Hello, world!"
    withEnvironment(apiService: MockService(fetchDraftResponse: titled)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.titleTextFieldBecomeFirstResponder.assertValueCount(0)
      self.bodyTextViewBecomeFirstResponder.assertValueCount(1)
    }
  }

  func testIsBackersOnlyOnTappedFlipsVisibility() {
    let draft = .template |> UpdateDraft.lens.update.isPublic .~ false
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.isBackersOnly.assertValues([true])

      self.vm.inputs.isBackersOnlyOn(false)
      self.isBackersOnly.assertValues([true, false])

      self.vm.inputs.isBackersOnlyOn(true)
      self.isBackersOnly.assertValues([true, false, true])
    }
  }

  func testTitleTextFieldDoneEditing() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.bodyTextViewBecomeFirstResponder.assertValueCount(0)

      self.vm.inputs.titleTextFieldDoneEditing()
      self.bodyTextViewBecomeFirstResponder.assertValueCount(1)
    }
  }

  func testDismissalWithoutEdits() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(0)
      self.resignFirstResponder.assertValueCount(0)

      self.vm.inputs.closeButtonTapped()
      self.vm.inputs.viewWillDisappear()
      self.scheduler.advance()

      self.resignFirstResponder.assertValueCount(1)
      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(["Viewed Draft", "Closed Draft"], self.trackingClient.events,
                     "Koala closed draft is tracked")
    }
  }

  func testDismissalWithEdits() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.titleTextChanged("Hello, world!")

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(["Viewed Draft", "Closed Draft", "Edited Title"], self.trackingClient.events,
                     "Koala edited title is tracked")
    }
  }

  func testPreviewTapped() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .template)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.previewButtonTapped()
      self.scheduler.advance()

      XCTAssertEqual(["Viewed Draft", "Previewed Update", "Update Preview"], self.trackingClient.events,
                     "Koala previewed update is tracked")

      self.showPreview.assertValues([NSURL(string: "***REMOVED***/v1/projects/1/draft/preview")!])
    }
  }


  func testPreviewTappedWithEdits() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .template)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.titleTextChanged("Hello, world!")

      self.vm.inputs.previewButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(0)

      XCTAssertEqual(["Viewed Draft", "Previewed Update", "Update Preview", "Edited Title"],
                     self.trackingClient.events, "Koala previewed update is tracked")

      self.showPreview.assertValues([NSURL(string: "***REMOVED***/v1/projects/1/draft/preview")!])
    }
  }

  func testTrackEditBody() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .empty)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.bodyTextChanged("Hello, world!")

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(["Viewed Draft", "Closed Draft", "Edited Body"], self.trackingClient.events,
                     "Koala body editing is tracked")
    }
  }

  func testTrackEditIsBackersOnly() {
    let draft = .empty |> UpdateDraft.lens.update.isPublic .~ true
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.isBackersOnlyOn(true)

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(["Viewed Draft", "Closed Draft", "Changed Visibility"], self.trackingClient.events,
                     "Koala changed visibility is tracked")
    }
  }

  func testErrorLoadingDraft() {
    withEnvironment(apiService: MockService(fetchDraftError: .couldNotParseJSON)) {
      self.showLoadFailure.assertValueCount(0)
      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(0)

      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.showLoadFailure.assertValueCount(1)
      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(["Viewed Draft", "Closed Draft"], self.trackingClient.events)
    }
  }

  func testErrorSavingDraft() {
    let apiService = MockService(fetchDraftResponse: .empty, updateDraftError: .couldNotParseJSON)
    withEnvironment(apiService: apiService) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.bodyTextChanged("Hello, world!")

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(0)
      self.showSaveFailure.assertValueCount(1)

      XCTAssertEqual(["Viewed Draft"], self.trackingClient.events, "Koala body editing is not tracked")
    }
  }
}
