// swiftlint:disable file_length
import KsApi
import Prelude
import ReactiveCocoa
import Result
import UIKit

public protocol UpdateDraftViewModelInputs {
  /// Call when the creator taps "add attachment".
  func addAttachmentButtonTapped(availableSources availableSources: [AttachmentSource])

  /// Call when the creator taps a selection from the attachment actions sheet.
  func addAttachmentSheetButtonTapped(action: AttachmentSource)

  /// Call when a creator taps an attachment to be removed.
  func attachmentTapped(id id: Int)

  /// Call when the draft body changes.
  func bodyTextChanged(to body: String)

  /// Call when the creator taps "Close".
  func closeButtonTapped()

  /// Call with the project provided to the view.
  func configureWith(project project: Project)

  /// Call with the image picked by the image picker.
  func imagePicked(url url: NSURL, fromSource source: AttachmentSource)

  /// Call when the image picker is canceled.
  func imagePickerCanceled()

  /// Call when the creator taps "public"/"backers only".
  func isBackersOnlyOn(isBackersOnly: Bool)

  /// Call when the creator taps "preview".
  func previewButtonTapped()

  /// Call when attachment removal confirmed.
  func remove(attachment attachment: UpdateDraft.Attachment)

  /// Call when the creator cancels out of the remove attachment flow.
  func removeAttachmentConfirmationCanceled()

  /// Call when the draft title changes.
  func titleTextChanged(to title: String)

  /// Call when title text field keyboard returns.
  func titleTextFieldDoneEditing()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will disappear.
  func viewWillDisappear()
}

public protocol UpdateDraftViewModelOutputs {
  /// An attachment was added.
  var attachmentAdded: Signal<UpdateDraft.Attachment, NoError> { get }

  /// An attachment was removed.
  var attachmentRemoved: Signal<UpdateDraft.Attachment, NoError> { get }

  /// An collection of attachments.
  var attachments: Signal<[UpdateDraft.Attachment], NoError> { get }

  /// The draft's working body.
  var body: Signal<String, NoError> { get }

  /// When the body text view should become first responder.
  var bodyTextViewBecomeFirstResponder: Signal<(), NoError> { get }

  /// Emits when the view controller should show a preview.
  var goToPreview: Signal<UpdateDraft, NoError> { get }

  /// Whether or not to show the attachments section.
  var isAttachmentsSectionHidden: Signal<Bool, NoError> { get }

  /// Whether or not the draft is being fetched from the API.
  var isLoading: Signal<Bool, NoError> { get }

  /// Whether or not the draft is limited to backers only.
  var isBackersOnly: Signal<Bool, NoError> { get }

  /// Whether or not the body placeholder is visible.
  var isBodyPlaceholderHidden: Signal<Bool, NoError> { get }

  /// Whether or no the preview button should be enabled.
  var isPreviewButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits the update number, formatted.
  var navigationItemTitle: Signal<String, NoError> { get }

  /// Emits when the view controller should be dismissed.
  var notifyPresenterViewControllerWantsDismissal: Signal<(), NoError> { get }

  /// Emits when the keyboard should be dismissed.
  var resignFirstResponder: Signal<(), NoError> { get }

  /// Emits when adding an attachment fails.
  var showAddAttachmentFailure: Signal<(), NoError> { get }

  /// Emits when add attachment is tapped.
  var showAttachmentActions: Signal<[AttachmentSource], NoError> { get }

  /// Emits when the creator selects "add photo" or "choose from camera roll".
  var showImagePicker: Signal<AttachmentSource, NoError> { get }

  /// Emits when the view controller should show a load error.
  var showLoadFailure: Signal<(), NoError> { get }

  /// Emits when an attachment is tapped.
  var showRemoveAttachmentConfirmation: Signal<UpdateDraft.Attachment, NoError> { get }

  /// Emits when removing an attachment failed.
  var showRemoveAttachmentFailure: Signal<(), NoError> { get }

  /// Emits when a save fails.
  var showSaveFailure: Signal<(), NoError> { get }

  /// The draft's working title.
  var title: Signal<String, NoError> { get }

  /// When the body text view should become first responder.
  var titleTextFieldBecomeFirstResponder: Signal<(), NoError> { get }
}

public protocol UpdateDraftViewModelType {
  var inputs: UpdateDraftViewModelInputs { get }
  var outputs: UpdateDraftViewModelOutputs { get }
}

public final class UpdateDraftViewModel: UpdateDraftViewModelType, UpdateDraftViewModelInputs,
UpdateDraftViewModelOutputs {
  // swiftlint:disable function_body_length
  public init() {
    // MARK: Loading

    let project = self.projectProperty.signal.ignoreNil()
    let draftEvent = combineLatest(self.viewDidLoadProperty.signal, project)
      .map(second)
      .flatMap {
        AppEnvironment.current.apiService.fetchUpdateDraft(forProject: $0)
          .materialize()
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
    }
    let draft = draftEvent.values()

    self.showLoadFailure = draftEvent.errors().ignoreValues()

    self.isLoading = .merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      draft.mapConst(false)
    )

    self.navigationItemTitle = draft
      .map { Strings.dashboard_post_update_compose_update_number(
        update_number: Format.wholeNumber($0.update.sequence))
    }

    // MARK: Form Fields

    self.title = draft.map { $0.update.title }
    self.body = draft.map { $0.update.body ?? "" }

    let wasBackersOnly = draft.map { $0.update.isPublic }.map(negate)
    self.isBackersOnly = Signal.merge(wasBackersOnly, self.isBackersOnlyOnProperty.signal)

    let currentTitle = Signal.merge(self.title, self.titleTextChangedProperty.signal)
    let currentBody = Signal.merge(self.body, self.bodyTextChangedProperty.signal)

    let titleChanged = hasChanged(self.title, currentTitle)
    let bodyChanged = hasChanged(self.body, currentBody)
    let isBackersOnlyChanged = hasChanged(wasBackersOnly, self.isBackersOnly)

    // MARK: Attachments

    self.attachments = draft
      .map {
        $0.images.map(UpdateDraft.Attachment.image)
          + [$0.video.map(UpdateDraft.Attachment.video)].compact()
    }

    self.showAttachmentActions = self.addAttachmentButtonTappedProperty.signal

    self.showImagePicker = self.addAttachmentSheetButtonTappedProperty.signal
      .ignoreNil()

    let addAttachmentEvent = draft
      .takePairWhen(self.imagePickedProperty.signal.ignoreNil().map(first))
      .switchMap { draft, url in
        AppEnvironment.current.apiService.addImage(file: url, toDraft: draft)
          .materialize()
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
    }
    self.showAddAttachmentFailure = addAttachmentEvent.errors().ignoreValues()

    self.attachmentAdded = addAttachmentEvent.values()
      .map(UpdateDraft.Attachment.image)

    let addedAttachments = Signal
      .merge(
        self.attachments,
        self.attachments
          .switchMap { [attachmentAdded] attachments in
            attachmentAdded
              .scan(attachments) { $0 + [$1] }
        }
    )

    self.showRemoveAttachmentConfirmation = addedAttachments
      .takePairWhen(self.attachmentTappedProperty.signal)
      .map { attachments, id in attachments.filter { $0.id == id }.first }
      .ignoreNil()

    let removeAttachmentEvent = draft
      .takePairWhen(self.removeAttachmentProperty.signal.ignoreNil())
      .switchMap { (draft, attachment) -> SignalProducer<Event<UpdateDraft.Image, ErrorEnvelope>, NoError> in
        guard case let .image(image) = attachment else { fatalError("Video not supported") }
        return AppEnvironment.current.apiService.delete(image: image, fromDraft: draft)
          .materialize()
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
    }
    self.showRemoveAttachmentFailure = removeAttachmentEvent.errors().ignoreValues()

    self.attachmentRemoved = removeAttachmentEvent.values()
      .map(UpdateDraft.Attachment.image)

    let removedAttachments = addedAttachments
      .switchMap { [attachmentRemoved] attachments in
        attachmentRemoved
          .scan(attachments) { currentAttachments, toRemove in
            currentAttachments.filter { toRemove != $0 }
        }
    }

    let currentAttachments = Signal
      .merge(
        self.attachments,
        addedAttachments,
        removedAttachments
    )
    removedAttachments.observeNext { print($0) }

    self.isAttachmentsSectionHidden = Signal
      .merge(
        self.viewDidLoadProperty.signal.mapConst(true),
        currentAttachments.map { $0.isEmpty }
      )
      .skipRepeats()

    // MARK: Validation

    let hasContent = combineLatest(currentTitle, currentBody, self.attachments)
      .map { title, body, attachments in
        !title.trimmed().isEmpty && (!body.trimmed().isEmpty || !attachments.isEmpty)
    }

    self.isPreviewButtonEnabled = Signal
      .merge(
        self.viewDidLoadProperty.signal.mapConst(false),
        hasContent
      )
      .skipRepeats()

    // MARK: Focus

    let draftHasTitle = draft
      .map { !$0.update.title.isEmpty }

    let draftHasBody = draft
      .map { !($0.update.body ?? "").isEmpty }

    self.titleTextFieldBecomeFirstResponder = draftHasTitle
      .filter(isFalse)
      .ignoreValues()

    self.isBodyPlaceholderHidden = currentBody
      .map { !$0.isEmpty }
      .skipRepeats()

    self.bodyTextViewBecomeFirstResponder = .merge(
      self.titleTextFieldDoneEditingProperty.signal,
      combineLatest(
        draftHasTitle.filter(isTrue),
        draftHasBody.filter(isFalse)
      )
      .ignoreValues()
    )

    // MARK: Saving

    let saveAction = Signal.merge(
      self.closeButtonTappedProperty.signal.mapConst(SaveAction.dismiss),
      self.previewButtonTappedProperty.signal.mapConst(SaveAction.preview)
    )

    let currentDraftEvent = combineLatest(
      draft,
      currentTitle,
      currentBody,
      self.isBackersOnly
      )
      .takeWhen(saveAction)
      .flatMap { (draft, title, body, isBackersOnly) ->
        SignalProducer<Event<UpdateDraft, ErrorEnvelope>, NoError> in

        let unchanged = draft.update.title == title
          && draft.update.body == body
          && draft.update.isPublic == !isBackersOnly

        let producer: SignalProducer<Event<UpdateDraft, ErrorEnvelope>, NoError>

        if unchanged {
          producer = SignalProducer(value: .Next(draft))
        } else {
          producer = AppEnvironment.current.apiService
            .update(draft: draft, title: title, body: body, isPublic: !isBackersOnly)
            .materialize()
        }

        return producer
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
      }
    let currentDraft = currentDraftEvent.values()

    self.notifyPresenterViewControllerWantsDismissal = Signal.merge(
      self.showLoadFailure,
      saveAction
        .takeWhen(currentDraft)
        .filter { $0 == .dismiss }
        .ignoreValues())

    self.showSaveFailure = currentDraftEvent.errors().ignoreValues()

    self.goToPreview = saveAction
      .takePairWhen(currentDraft)
      .filter { action, _ in action == .preview }
      .map(second)

    self.resignFirstResponder = self.viewWillDisappearProperty.signal

    // MARK: Koala

    project
      .observeNext { AppEnvironment.current.koala.trackViewedUpdateDraft(forProject: $0) }

    project
      .takeWhen(self.notifyPresenterViewControllerWantsDismissal)
      .observeNext { AppEnvironment.current.koala.trackClosedUpdateDraft(forProject: $0) }

    project
      .takeWhen(self.goToPreview)
      .observeNext { AppEnvironment.current.koala.trackPreviewedUpdate(forProject: $0) }

    let titleSynced = titleChanged
      .takeWhen(currentDraft)
      .filter(isTrue)

    project
      .takeWhen(titleSynced)
      .observeNext { AppEnvironment.current.koala.trackEditedUpdateDraftTitle(forProject: $0) }

    let bodySynced = bodyChanged
      .takeWhen(currentDraft)
      .filter(isTrue)

    project
      .takeWhen(bodySynced)
      .observeNext { AppEnvironment.current.koala.trackEditedUpdateDraftBody(forProject: $0) }

    let isBackersOnlySynced = isBackersOnlyChanged
      .takeWhen(currentDraft)
      .filter(isTrue)

    combineLatest(project, self.isBackersOnly)
      .takeWhen(isBackersOnlySynced)
      .observeNext {
        AppEnvironment.current.koala.trackChangedUpdateDraftVisibility(forProject: $0, isPublic: !$1)
    }

    project
      .takeWhen(self.addAttachmentSheetButtonTappedProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackStartedAddUpdateDraftAttachment(forProject: $0)
    }

    combineLatest(project, self.imagePickedProperty.signal.ignoreNil().map(second))
      .takeWhen(self.attachmentAdded)
      .observeNext {
        AppEnvironment.current.koala.trackCompletedAddUpdateDraftAttachment(forProject: $0, attachedFrom: $1)
    }

    project
      .takeWhen(self.imagePickerCanceledProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackCanceledAddUpdateDraftAttachment(forProject: $0)
    }

    project
      .takeWhen(self.showAddAttachmentFailure)
      .observeNext {
        AppEnvironment.current.koala.trackFailedAddUpdateDraftAttachment(forProject: $0)
    }

    project
      .takeWhen(self.attachmentTappedProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackStartedRemoveUpdateDraftAttachment(forProject: $0)
    }

    project
      .takeWhen(self.attachmentRemoved)
      .observeNext {
        AppEnvironment.current.koala.trackCompletedRemoveUpdateDraftAttachment(forProject: $0)
    }

    project
      .takeWhen(self.removeAttachmentConfirmationCanceledProperty.signal)
      .observeNext {
        AppEnvironment.current.koala.trackCanceledRemoveUpdateDraftAttachment(forProject: $0)
    }

    project
      .takeWhen(self.showRemoveAttachmentFailure)
      .observeNext {
        AppEnvironment.current.koala.trackFailedRemoveUpdateDraftAttachment(forProject: $0)
    }
  }
  // swiftlint:enable function_body_length

  // INPUTS
  private let addAttachmentButtonTappedProperty = MutableProperty<[AttachmentSource]>([])
  public func addAttachmentButtonTapped(availableSources availableSources: [AttachmentSource]) {
    self.addAttachmentButtonTappedProperty.value = availableSources
  }

  private let addAttachmentSheetButtonTappedProperty = MutableProperty<AttachmentSource?>(nil)
  public func addAttachmentSheetButtonTapped(action: AttachmentSource) {
    self.addAttachmentSheetButtonTappedProperty.value = action
  }

  private let attachmentTappedProperty = MutableProperty(0)
  public func attachmentTapped(id id: Int) {
    self.attachmentTappedProperty.value = id
  }

  private let bodyTextChangedProperty = MutableProperty("")
  public func bodyTextChanged(to body: String) {
    self.bodyTextChangedProperty.value = body
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let imagePickedProperty = MutableProperty<(NSURL, AttachmentSource)?>(nil)
  public func imagePicked(url url: NSURL, fromSource source: AttachmentSource) {
    self.imagePickedProperty.value = (url, source)
  }

  private let imagePickerCanceledProperty = MutableProperty()
  public func imagePickerCanceled() {
    self.imagePickerCanceledProperty.value = ()
  }

  private let isBackersOnlyOnProperty = MutableProperty(false)
  public func isBackersOnlyOn(isBackersOnly: Bool) {
    self.isBackersOnlyOnProperty.value = isBackersOnly
  }

  private let previewButtonTappedProperty = MutableProperty()
  public func previewButtonTapped() {
    self.previewButtonTappedProperty.value = ()
  }

  private let removeAttachmentProperty = MutableProperty<UpdateDraft.Attachment?>(nil)
  public func remove(attachment attachment: UpdateDraft.Attachment) {
    self.removeAttachmentProperty.value = attachment
  }

  private let removeAttachmentConfirmationCanceledProperty = MutableProperty()
  public func removeAttachmentConfirmationCanceled() {
    self.removeAttachmentConfirmationCanceledProperty.value = ()
  }

  private let titleTextChangedProperty = MutableProperty("")
  public func titleTextChanged(to title: String) {
    self.titleTextChangedProperty.value = title
  }

  private let titleTextFieldDoneEditingProperty = MutableProperty()
  public func titleTextFieldDoneEditing() {
    self.titleTextFieldDoneEditingProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillDisappearProperty = MutableProperty()
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  // OUTPUTS
  public let attachmentAdded: Signal<UpdateDraft.Attachment, NoError>
  public let attachmentRemoved: Signal<UpdateDraft.Attachment, NoError>
  public let attachments: Signal<[UpdateDraft.Attachment], NoError>
  public let body: Signal<String, NoError>
  public let bodyTextViewBecomeFirstResponder: Signal<(), NoError>
  public let goToPreview: Signal<UpdateDraft, NoError>
  public let isAttachmentsSectionHidden: Signal<Bool, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let isBodyPlaceholderHidden: Signal<Bool, NoError>
  public let isBackersOnly: Signal<Bool, NoError>
  public let isPreviewButtonEnabled: Signal<Bool, NoError>
  public let navigationItemTitle: Signal<String, NoError>
  public let notifyPresenterViewControllerWantsDismissal: Signal<(), NoError>
  public let resignFirstResponder: Signal<(), NoError>
  public let showAddAttachmentFailure: Signal<(), NoError>
  public let showAttachmentActions: Signal<[AttachmentSource], NoError>
  public let showImagePicker: Signal<AttachmentSource, NoError>
  public let showLoadFailure: Signal<(), NoError>
  public let showRemoveAttachmentConfirmation: Signal<UpdateDraft.Attachment, NoError>
  public let showRemoveAttachmentFailure: Signal<(), NoError>
  public let showSaveFailure: Signal<(), NoError>
  public let title: Signal<String, NoError>
  public let titleTextFieldBecomeFirstResponder: Signal<(), NoError>

  public var inputs: UpdateDraftViewModelInputs { return self }
  public var outputs: UpdateDraftViewModelOutputs { return self }
}

public enum AttachmentSource: String {
  case camera = "camera"
  case cameraRoll = "camera_roll"

  public init(sourceType: UIImagePickerControllerSourceType) {
    switch sourceType {
    case .Camera:
      self = .camera
    case .PhotoLibrary:
      self = .cameraRoll
    default:
      fatalError("unsupported source: \(sourceType)")
    }
  }

  public var title: String {
    switch self {
    case .camera:
      return Strings.dashboard_post_update_compose_attachment_buttons_new_photo()
    case .cameraRoll:
      return Strings.dashboard_post_update_compose_attachment_buttons_choose_from_camera_roll()
    }
  }

  public var sourceType: UIImagePickerControllerSourceType {
    switch self {
    case .camera:
      return .Camera
    case .cameraRoll:
      return .PhotoLibrary
    }
  }
}

extension AttachmentSource: Equatable {}
public func == (lhs: AttachmentSource, rhs: AttachmentSource) -> Bool {
  switch (lhs, rhs) {
  case (.camera, .camera), (.cameraRoll, .cameraRoll):
    return true
  default:
    return false
  }
}

private enum SaveAction {
  case dismiss
  case preview
}

private func hasChanged<T: Equatable>(original: Signal<T, NoError>, _ updated: Signal<T, NoError>)
  -> Signal<Bool, NoError> {

    return Signal
      .merge(
        original.mapConst(false),
        combineLatest(original, updated)
          .map(!=)
      )
      .skipRepeats()
}
