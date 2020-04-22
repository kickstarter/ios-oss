@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

final class UpdateDraftViewModelTests: TestCase {
  let vm: UpdateDraftViewModelType = UpdateDraftViewModel()
  let attachmentAdded = TestObserver<UpdateDraft.Attachment, Never>()
  let attachmentRemoved = TestObserver<UpdateDraft.Attachment, Never>()
  let attachments = TestObserver<[UpdateDraft.Attachment], Never>()
  let body = TestObserver<String, Never>()
  let bodyTextViewBecomeFirstResponder = TestObserver<(), Never>()
  let goToPreview = TestObserver<UpdateDraft, Never>()
  let isAttachmentsSectionHidden = TestObserver<Bool, Never>()
  let isBackersOnly = TestObserver<Bool, Never>()
  let isBodyPlaceholderHidden = TestObserver<Bool, Never>()
  let isLoading = TestObserver<Bool, Never>()
  let isPreviewButtonEnabled = TestObserver<Bool, Never>()
  let navigationItemTitle = TestObserver<String, Never>()
  let notifyPresenterViewControllerWantsDismissal = TestObserver<(), Never>()
  let resignFirstResponder = TestObserver<(), Never>()
  let showAddAttachmentFailure = TestObserver<(), Never>()
  let showAttachmentActions = TestObserver<[AttachmentSource], Never>()
  let showImagePicker = TestObserver<AttachmentSource, Never>()
  let showLoadFailure = TestObserver<(), Never>()
  let showRemoveAttachmentConfirmation = TestObserver<UpdateDraft.Attachment, Never>()
  let showRemoveAttachmentFailure = TestObserver<(), Never>()
  let showSaveFailure = TestObserver<(), Never>()
  let title = TestObserver<String, Never>()
  let titleTextFieldBecomeFirstResponder = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.attachmentAdded.observe(self.attachmentAdded.observer)
    self.vm.outputs.attachmentRemoved.observe(self.attachmentRemoved.observer)
    self.vm.outputs.attachments.observe(self.attachments.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.bodyTextViewBecomeFirstResponder.observe(self.bodyTextViewBecomeFirstResponder.observer)
    self.vm.outputs.goToPreview.observe(self.goToPreview.observer)
    self.vm.outputs.isAttachmentsSectionHidden.observe(self.isAttachmentsSectionHidden.observer)
    self.vm.outputs.isBackersOnly.observe(self.isBackersOnly.observer)
    self.vm.outputs.isBodyPlaceholderHidden.observe(self.isBodyPlaceholderHidden.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.isPreviewButtonEnabled.observe(self.isPreviewButtonEnabled.observer)
    self.vm.outputs.navigationItemTitle.observe(self.navigationItemTitle.observer)
    self.vm.outputs.notifyPresenterViewControllerWantsDismissal
      .observe(self.notifyPresenterViewControllerWantsDismissal.observer)
    self.vm.outputs.resignFirstResponder.observe(self.resignFirstResponder.observer)
    self.vm.outputs.showAddAttachmentFailure.observe(self.showAddAttachmentFailure.observer)
    self.vm.outputs.showAttachmentActions.observe(self.showAttachmentActions.observer)
    self.vm.outputs.showImagePicker.observe(self.showImagePicker.observer)
    self.vm.outputs.showLoadFailure.observe(self.showLoadFailure.observer)
    self.vm.outputs.showRemoveAttachmentConfirmation.observe(self.showRemoveAttachmentConfirmation.observer)
    self.vm.outputs.showRemoveAttachmentFailure.observe(self.showRemoveAttachmentFailure.observer)
    self.vm.outputs.showSaveFailure.observe(self.showSaveFailure.observer)
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.titleTextFieldBecomeFirstResponder
      .observe(self.titleTextFieldBecomeFirstResponder.observer)
  }

  func testConfiguredBlank() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.title.assertValues([""])
      self.body.assertValues([""])
      self.isBackersOnly.assertValues([false])
      self.attachments.assertValues([[]])
    }
  }

  func testConfiguredWithNavigationItemTitle() {
    let draft = .template |> UpdateDraft.lens.update.sequence .~ 7
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.navigationItemTitle.assertValues([
        Strings.dashboard_post_update_compose_update_number(
          update_number: Format.wholeNumber(7)
        )
      ])
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

  func testIsLoading() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.isLoading.assertValues([true], "is loading")

      self.scheduler.advance()

      self.isLoading.assertValues([true, false], "is loaded")
    }
  }

  func testPreviewButtonEnabled() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.isPreviewButtonEnabled.assertValues([false], "emits on view did load")
      self.isBodyPlaceholderHidden.assertValues([false], "emits on view did load")

      self.scheduler.advance()

      self.vm.inputs.bodyTextChanged(to: "Thanks for believing in me.")
      self.isPreviewButtonEnabled.assertValues([false])
      self.isBodyPlaceholderHidden.assertValues([false, true])

      self.vm.inputs.titleTextChanged(to: "Hello")
      self.isPreviewButtonEnabled.assertValues([false, true])
      self.isBodyPlaceholderHidden.assertValues([false, true])

      self.vm.inputs.titleTextChanged(to: "Hello, world!")
      self.isPreviewButtonEnabled.assertValues([false, true])
      self.isBodyPlaceholderHidden.assertValues([false, true])

      self.vm.inputs.bodyTextChanged(to: "")
      self.isPreviewButtonEnabled.assertValues([false, true, false])
      self.isBodyPlaceholderHidden.assertValues([false, true, false])

      self.vm.inputs.bodyTextChanged(to: " ")
      self.isPreviewButtonEnabled.assertValues([false, true, false])
      self.isBodyPlaceholderHidden.assertValues([false, true, false, true])

      self.vm.inputs.bodyTextChanged(to: " \n\n\n")
      self.isPreviewButtonEnabled.assertValues([false, true, false])
      self.isBodyPlaceholderHidden.assertValues([false, true, false, true])

      self.vm.inputs.bodyTextChanged(to: "Thanks for believing in my project!")
      self.isPreviewButtonEnabled.assertValues([false, true, false, true])
      self.isBodyPlaceholderHidden.assertValues([false, true, false, true])
    }
  }

  func testBlankTitleBecomesFirstReponder() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.titleTextFieldBecomeFirstResponder.assertValueCount(1)
      self.bodyTextViewBecomeFirstResponder.assertValueCount(0)
    }
  }

  func testBlankBodyBecomesFirstReponderWithTitlePresent() {
    let titled = .blank |> UpdateDraft.lens.update.title .~ "Hello, world!"
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

  func testAddAttachments() {
    let image: UpdateDraft.Image = .template
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank, addAttachmentResponse: image)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.addAttachmentButtonTapped(availableSources: [.cameraRoll])
      self.showAttachmentActions.assertValues([[.cameraRoll]])

      self.vm.inputs.addAttachmentSheetButtonTapped(.cameraRoll)
      self.showImagePicker.assertValues([.cameraRoll])

      self.vm.inputs.imagePickerCanceled()
      XCTAssertEqual(
        ["Viewed Draft", "Started Add Attachment", "Canceled Add Attachment"],
        self.trackingClient.events, "Koala attachment events tracked"
      )

      self.vm.inputs.addAttachmentButtonTapped(availableSources: [.camera, .cameraRoll])
      self.showAttachmentActions.assertValues([[.cameraRoll], [.camera, .cameraRoll]])

      self.vm.inputs.addAttachmentSheetButtonTapped(.camera)
      self.showImagePicker.assertValues([.cameraRoll, .camera])

      self.vm.inputs.imagePicked(url: URL(string: "/tmp/photo.jpg")!, fromSource: .camera)

      self.attachmentAdded.assertValues([])
      self.scheduler.advance()
      self.attachmentAdded.assertValues([.image(image)])

      XCTAssertEqual(
        [
          "Viewed Draft", "Started Add Attachment", "Canceled Add Attachment",
          "Started Add Attachment", "Completed Add Attachment"
        ],
        self.trackingClient.events, "Koala attachment events tracked"
      )
    }
  }

  func testAddAttachmentFailure() {
    withEnvironment(apiService: MockService(
      fetchDraftResponse: .blank,
      addAttachmentError: .couldNotParseJSON
    )) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.addAttachmentButtonTapped(availableSources: [.cameraRoll])
      self.showAttachmentActions.assertValues([[.cameraRoll]])

      self.vm.inputs.addAttachmentSheetButtonTapped(.cameraRoll)
      self.showImagePicker.assertValues([.cameraRoll])

      self.vm.inputs.imagePicked(url: URL(string: "/tmp/photo.jpg")!, fromSource: .cameraRoll)

      self.showAddAttachmentFailure.assertValueCount(0)
      self.scheduler.advance()
      self.attachmentAdded.assertValues([])
      self.showAddAttachmentFailure.assertValueCount(1)

      XCTAssertEqual(
        [
          "Viewed Draft", "Started Add Attachment", "Failed Add Attachment"
        ],
        self.trackingClient.events, "Koala attachment events tracked"
      )
    }
  }

  func testRemoveAttachment() {
    let id = 1
    let image = .template |> UpdateDraft.Image.lens.id .~ id
    let draft = .template
      |> UpdateDraft.lens.images .~ [image]
    withEnvironment(apiService: MockService(fetchDraftResponse: draft, removeAttachmentResponse: image)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.attachmentTapped(id: id)
      self.showRemoveAttachmentConfirmation.assertValues([.image(image)])

      self.vm.inputs.removeAttachmentConfirmationCanceled()

      self.vm.inputs.attachmentTapped(id: id)
      self.showRemoveAttachmentConfirmation.assertValues([.image(image), .image(image)])

      self.vm.inputs.remove(attachment: .image(image))

      self.attachmentRemoved.assertValues([])
      self.scheduler.advance()
      self.attachmentRemoved.assertValues([.image(image)])

      XCTAssertEqual(
        [
          "Viewed Draft", "Started Remove Attachment", "Canceled Remove Attachment",
          "Started Remove Attachment", "Completed Remove Attachment"
        ],
        self.trackingClient.events, "Koala attachment events tracked"
      )
    }
  }

  func testRemoveAttachmentFailure() {
    let id = 1
    let image = .template |> UpdateDraft.Image.lens.id .~ id
    let draft = .template |> UpdateDraft.lens.images .~ [image]
    withEnvironment(apiService: MockService(
      fetchDraftResponse: draft,
      removeAttachmentError: .couldNotParseJSON
    )) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.attachmentTapped(id: id)
      self.showRemoveAttachmentConfirmation.assertValues([.image(image)])

      self.vm.inputs.remove(attachment: .image(image))

      self.showRemoveAttachmentFailure.assertValueCount(0)
      self.scheduler.advance()
      self.attachmentRemoved.assertValues([])
      self.showRemoveAttachmentFailure.assertValueCount(1)

      XCTAssertEqual(
        [
          "Viewed Draft", "Started Remove Attachment", "Failed Remove Attachment"
        ],
        self.trackingClient.events, "Koala attachment events tracked"
      )
    }
  }

  func testBlankAttachmentVisibility() {
    let id = 1
    let image = .template |> UpdateDraft.Image.lens.id .~ id
    withEnvironment(
      apiService: MockService(
        fetchDraftResponse: .blank, addAttachmentResponse: image, removeAttachmentResponse: image
      )
    ) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.isAttachmentsSectionHidden.assertValues([true])

      self.scheduler.advance()

      self.isAttachmentsSectionHidden.assertValues([true])

      self.vm.inputs.addAttachmentButtonTapped(availableSources: [.camera, .cameraRoll])
      self.vm.inputs.addAttachmentSheetButtonTapped(.camera)
      self.vm.inputs.imagePicked(url: URL(string: "/tmp/photo.jpg")!, fromSource: .camera)

      self.scheduler.advance()

      self.isAttachmentsSectionHidden.assertValues([true, false])

      self.vm.inputs.attachmentTapped(id: id)
      self.vm.inputs.remove(attachment: .image(image))

      self.scheduler.advance()

      self.isAttachmentsSectionHidden.assertValues([true, false, true])
    }
  }

  func testExistingAttachmentVisibility() {
    let existingId = 1
    let existingImage = .template |> UpdateDraft.Image.lens.id .~ existingId
    let newImage = .template |> UpdateDraft.Image.lens.id .~ 2
    let draft = .template |> UpdateDraft.lens.images .~ [existingImage]
    withEnvironment(
      apiService: MockService(
        fetchDraftResponse: draft, addAttachmentResponse: newImage, removeAttachmentResponse: existingImage
      )
    ) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.isAttachmentsSectionHidden.assertValues([true])

      self.scheduler.advance()

      self.isAttachmentsSectionHidden.assertValues([true, false])

      self.vm.inputs.addAttachmentButtonTapped(availableSources: [.camera, .cameraRoll])
      self.vm.inputs.addAttachmentSheetButtonTapped(.camera)
      self.vm.inputs.imagePicked(url: URL(string: "/tmp/photo.jpg")!, fromSource: .camera)

      self.scheduler.advance()

      self.isAttachmentsSectionHidden.assertValues([true, false])

      self.vm.inputs.attachmentTapped(id: existingId)
      self.vm.inputs.remove(attachment: .image(existingImage))

      self.scheduler.advance()

      self.isAttachmentsSectionHidden.assertValues([true, false])
    }
  }

  func testTitleTextFieldDoneEditing() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.bodyTextViewBecomeFirstResponder.assertValueCount(0)

      self.vm.inputs.titleTextFieldDoneEditing()
      self.bodyTextViewBecomeFirstResponder.assertValueCount(1)
    }
  }

  func testDismissalWithoutEdits() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
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

      XCTAssertEqual(
        ["Viewed Draft", "Closed Draft"], self.trackingClient.events,
        "Koala closed draft is tracked"
      )
    }
  }

  func testDismissalWithEdits() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.titleTextChanged(to: "Hello, world!")

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(
        ["Viewed Draft", "Closed Draft", "Edited Title"], self.trackingClient.events,
        "Koala edited title is tracked"
      )
    }
  }

  func testPreviewTapped() {
    let draft = UpdateDraft.template
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.goToPreview.assertValues([])
      self.vm.inputs.previewButtonTapped()
      self.scheduler.advance()

      XCTAssertEqual(
        ["Viewed Draft", "Previewed Update", "Update Preview"], self.trackingClient.events,
        "Koala previewed update is tracked"
      )

      self.goToPreview.assertValues([draft])
    }
  }

  func testPreviewTappedWithEdits() {
    let draft = UpdateDraft.template
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.titleTextChanged(to: "Hello, world!")

      self.goToPreview.assertValues([])
      self.vm.inputs.previewButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(0)

      XCTAssertEqual(
        ["Viewed Draft", "Previewed Update", "Update Preview", "Edited Title"],
        self.trackingClient.events, "Koala previewed update is tracked"
      )

      self.goToPreview.assertValues([draft])
    }
  }

  func testTrackEditBody() {
    withEnvironment(apiService: MockService(fetchDraftResponse: .blank)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.bodyTextChanged(to: "Hello, world!")

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(
        ["Viewed Draft", "Closed Draft", "Edited Body"], self.trackingClient.events,
        "Koala body editing is tracked"
      )
    }
  }

  func testTrackEditIsBackersOnly() {
    let draft = .blank |> UpdateDraft.lens.update.isPublic .~ true
    withEnvironment(apiService: MockService(fetchDraftResponse: draft)) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.isBackersOnlyOn(true)

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(1)

      XCTAssertEqual(
        ["Viewed Draft", "Closed Draft", "Changed Visibility"], self.trackingClient.events,
        "Koala changed visibility is tracked"
      )
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
    let apiService = MockService(fetchDraftResponse: .blank, updateDraftError: .couldNotParseJSON)
    withEnvironment(apiService: apiService) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.bodyTextChanged(to: "Hello, world!")

      self.vm.inputs.closeButtonTapped()
      self.scheduler.advance()

      self.notifyPresenterViewControllerWantsDismissal.assertValueCount(0)
      self.showSaveFailure.assertValueCount(1)

      XCTAssertEqual(["Viewed Draft"], self.trackingClient.events, "Koala body editing is not tracked")
    }
  }
}
