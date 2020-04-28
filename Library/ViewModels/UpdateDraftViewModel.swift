import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol UpdateDraftViewModelInputs {
  /// Call when the creator taps "add attachment".
  func addAttachmentButtonTapped(availableSources: [AttachmentSource])

  /// Call when the creator taps a selection from the attachment actions sheet.
  func addAttachmentSheetButtonTapped(_ action: AttachmentSource)

  /// Call when a creator taps an attachment to be removed.
  func attachmentTapped(id: Int)

  /// Call when the draft body changes.
  func bodyTextChanged(to body: String)

  /// Call when the creator taps "Close".
  func closeButtonTapped()

  /// Call with the project provided to the view.
  func configureWith(project: Project)

  /// Call with the image picked by the image picker.
  func imagePicked(url: URL, fromSource source: AttachmentSource)

  /// Call when the image picker is canceled.
  func imagePickerCanceled()

  /// Call when the creator taps "public"/"backers only".
  func isBackersOnlyOn(_ isBackersOnly: Bool)

  /// Call when the creator taps "preview".
  func previewButtonTapped()

  /// Call when attachment removal confirmed.
  func remove(attachment: UpdateDraft.Attachment)

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
  var attachmentAdded: Signal<UpdateDraft.Attachment, Never> { get }

  /// An attachment was removed.
  var attachmentRemoved: Signal<UpdateDraft.Attachment, Never> { get }

  /// An collection of attachments.
  var attachments: Signal<[UpdateDraft.Attachment], Never> { get }

  /// The draft's working body.
  var body: Signal<String, Never> { get }

  /// When the body text view should become first responder.
  var bodyTextViewBecomeFirstResponder: Signal<(), Never> { get }

  /// Emits when the view controller should show a preview.
  var goToPreview: Signal<UpdateDraft, Never> { get }

  /// Whether or not to show the attachments section.
  var isAttachmentsSectionHidden: Signal<Bool, Never> { get }

  /// Whether or not the draft is being fetched from the API.
  var isLoading: Signal<Bool, Never> { get }

  /// Whether or not the draft is limited to backers only.
  var isBackersOnly: Signal<Bool, Never> { get }

  /// Whether or not the body placeholder is visible.
  var isBodyPlaceholderHidden: Signal<Bool, Never> { get }

  /// Whether or no the preview button should be enabled.
  var isPreviewButtonEnabled: Signal<Bool, Never> { get }

  /// Emits the update number, formatted.
  var navigationItemTitle: Signal<String, Never> { get }

  /// Emits when the view controller should be dismissed.
  var notifyPresenterViewControllerWantsDismissal: Signal<(), Never> { get }

  /// Emits when the keyboard should be dismissed.
  var resignFirstResponder: Signal<(), Never> { get }

  /// Emits when adding an attachment fails.
  var showAddAttachmentFailure: Signal<(), Never> { get }

  /// Emits when add attachment is tapped.
  var showAttachmentActions: Signal<[AttachmentSource], Never> { get }

  /// Emits when the creator selects "add photo" or "choose from camera roll".
  var showImagePicker: Signal<AttachmentSource, Never> { get }

  /// Emits when the view controller should show a load error.
  var showLoadFailure: Signal<(), Never> { get }

  /// Emits when an attachment is tapped.
  var showRemoveAttachmentConfirmation: Signal<UpdateDraft.Attachment, Never> { get }

  /// Emits when removing an attachment failed.
  var showRemoveAttachmentFailure: Signal<(), Never> { get }

  /// Emits when a save fails.
  var showSaveFailure: Signal<(), Never> { get }

  /// The draft's working title.
  var title: Signal<String, Never> { get }

  /// When the body text view should become first responder.
  var titleTextFieldBecomeFirstResponder: Signal<(), Never> { get }
}

public protocol UpdateDraftViewModelType {
  var inputs: UpdateDraftViewModelInputs { get }
  var outputs: UpdateDraftViewModelOutputs { get }
}

public final class UpdateDraftViewModel: UpdateDraftViewModelType, UpdateDraftViewModelInputs,
  UpdateDraftViewModelOutputs {
  public init() {
    // MARK: - Loading

    let project: Signal<Project, Never> = self.projectProperty.signal.skipNil()

    let draftEvent =
      Signal.combineLatest(self.viewDidLoadProperty.signal, project)
        .map(second)
        .flatMap {
          AppEnvironment.current.apiService.fetchUpdateDraft(forProject: $0)
            .materialize()
            .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        }

    let draft: Signal<UpdateDraft, Never> = draftEvent.values()

    self.showLoadFailure = draftEvent.errors().ignoreValues()

    self.isLoading = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      draft.mapConst(false)
    )

    self.navigationItemTitle = draft
      .map { $0.update.sequence }
      .map { Strings.dashboard_post_update_compose_update_number(update_number: Format.wholeNumber($0)) }

    // MARK: - Form Fields

    self.title = draft.map { $0.update.title }
    self.body = draft.map { $0.update.body ?? "" }

    let wasBackersOnly: Signal<Bool, Never> = draft.map { $0.update.isPublic }.map(negate)

    self.isBackersOnly = Signal.merge(wasBackersOnly, self.isBackersOnlyOnProperty.signal)

    let currentTitle: Signal<String, Never> = Signal.merge(self.title, self.titleTextChangedProperty.signal)
    let currentBody: Signal<String, Never> = Signal.merge(self.body, self.bodyTextChangedProperty.signal)

    let titleChanged: Signal<Bool, Never> = hasChanged(self.title, currentTitle)
    let bodyChanged: Signal<Bool, Never> = hasChanged(self.body, currentBody)
    let isBackersOnlyChanged: Signal<Bool, Never> = hasChanged(wasBackersOnly, self.isBackersOnly)

    // MARK: - Attachments

    self.attachments = draft
      .map {
        $0.images.map(UpdateDraft.Attachment.image)
          + [$0.video.map(UpdateDraft.Attachment.video)].compact()
      }

    self.showAttachmentActions = self.addAttachmentButtonTappedProperty.signal

    self.showImagePicker = self.addAttachmentSheetButtonTappedProperty.signal
      .skipNil()

    let addAttachmentEvent = draft
      .takePairWhen(self.imagePickedProperty.signal.skipNil().map(first))
      .switchMap { draft, url in
        AppEnvironment.current.apiService.addImage(file: url, toDraft: draft)
          .materialize()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      }

    self.showAddAttachmentFailure = addAttachmentEvent.errors().ignoreValues()

    self.attachmentAdded = addAttachmentEvent.values()
      .map(UpdateDraft.Attachment.image)

    let addedAttachments: Signal<[UpdateDraft.Attachment], Never> = Signal
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
      .map { attachments, id in attachments.first { $0.id == id } }
      .skipNil()

    let removeAttachmentEvent: Signal<Signal<UpdateDraft.Image, ErrorEnvelope>.Event, Never> = draft
      .takePairWhen(self.removeAttachmentProperty.signal.skipNil())
      .switchMap { (draft, attachment)
        -> SignalProducer<Signal<UpdateDraft.Image, ErrorEnvelope>.Event, Never> in
        guard case let .image(image) = attachment else { fatalError("Video not supported") }
        return AppEnvironment.current.apiService.delete(image: image, fromDraft: draft)
          .materialize()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      }

    self.showRemoveAttachmentFailure = removeAttachmentEvent.errors().ignoreValues()

    self.attachmentRemoved = removeAttachmentEvent.values()
      .map(UpdateDraft.Attachment.image)

    let removedAttachments: Signal<[UpdateDraft.Attachment], Never> = addedAttachments
      .switchMap { [attachmentRemoved] attachments in
        attachmentRemoved
          .scan(attachments) { currentAttachments, toRemove in
            currentAttachments.filter { toRemove != $0 }
          }
      }

    let currentAttachments: Signal<[UpdateDraft.Attachment], Never> = Signal
      .merge(
        self.attachments,
        addedAttachments,
        removedAttachments
      )

    self.isAttachmentsSectionHidden = Signal
      .merge(
        self.viewDidLoadProperty.signal.mapConst(true),
        currentAttachments.map { $0.isEmpty }
      )
      .skipRepeats()

    // MARK: - Validation

    let hasContent: Signal<Bool, Never> = Signal.combineLatest(currentTitle, currentBody, self.attachments)
      .map { title, body, attachments in
        !title.trimmed().isEmpty && (!body.trimmed().isEmpty || !attachments.isEmpty)
      }

    self.isPreviewButtonEnabled = Signal
      .merge(
        self.viewDidLoadProperty.signal.mapConst(false),
        hasContent
      )
      .skipRepeats()

    // MARK: - Focus

    let draftHasTitle: Signal<Bool, Never> = draft
      .map { !$0.update.title.isEmpty }

    let draftHasBody: Signal<Bool, Never> = draft
      .map { !($0.update.body ?? "").isEmpty }

    self.titleTextFieldBecomeFirstResponder = draftHasTitle
      .filter(isFalse)
      .ignoreValues()

    self.isBodyPlaceholderHidden = currentBody
      .map { !$0.isEmpty }
      .skipRepeats()

    self.bodyTextViewBecomeFirstResponder = .merge(
      self.titleTextFieldDoneEditingProperty.signal,
      Signal.combineLatest(
        draftHasTitle.filter(isTrue),
        draftHasBody.filter(isFalse)
      )
      .ignoreValues()
    )

    // MARK: - Saving

    let saveAction: Signal<SaveAction, Never> = Signal.merge(
      self.closeButtonTappedProperty.signal.mapConst(SaveAction.dismiss),
      self.previewButtonTappedProperty.signal.mapConst(SaveAction.preview)
    )

    let currentDraftEvent = Signal.combineLatest(
      draft,
      currentTitle,
      currentBody,
      self.isBackersOnly
    )
    .takeWhen(saveAction)
    .flatMap { (draft, title, body, isBackersOnly) ->
      SignalProducer<Signal<UpdateDraft, ErrorEnvelope>.Event, Never> in

      let unchanged = draft.update.title == title
        && draft.update.body == body
        && draft.update.isPublic == !isBackersOnly

      let producer: SignalProducer<Signal<UpdateDraft, ErrorEnvelope>.Event, Never>

      if unchanged {
        producer = SignalProducer(value: .value(draft))
      } else {
        producer = AppEnvironment.current.apiService
          .update(draft: draft, title: title, body: body, isPublic: !isBackersOnly)
          .materialize()
      }

      return producer
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    }
    let currentDraft = currentDraftEvent.values()

    self.notifyPresenterViewControllerWantsDismissal = Signal.merge(
      self.showLoadFailure,
      saveAction
        .takeWhen(currentDraft)
        .filter { $0 == .dismiss }
        .ignoreValues()
    )

    self.showSaveFailure = currentDraftEvent.errors().ignoreValues()

    self.goToPreview = saveAction
      .takePairWhen(currentDraft)
      .filter { action, _ in action == .preview }
      .map(second)

    self.resignFirstResponder = self.viewWillDisappearProperty.signal

    // MARK: - Koala

    project
      .observeValues { AppEnvironment.current.koala.trackViewedUpdateDraft(forProject: $0) }

    project
      .takeWhen(self.notifyPresenterViewControllerWantsDismissal)
      .observeValues { AppEnvironment.current.koala.trackClosedUpdateDraft(forProject: $0) }

    project
      .takeWhen(self.goToPreview)
      .observeValues { AppEnvironment.current.koala.trackPreviewedUpdate(forProject: $0) }

    let titleSynced = titleChanged
      .takeWhen(currentDraft)
      .filter(isTrue)

    project
      .takeWhen(titleSynced)
      .observeValues { AppEnvironment.current.koala.trackEditedUpdateDraftTitle(forProject: $0) }

    let bodySynced = bodyChanged
      .takeWhen(currentDraft)
      .filter(isTrue)

    project
      .takeWhen(bodySynced)
      .observeValues { AppEnvironment.current.koala.trackEditedUpdateDraftBody(forProject: $0) }

    let isBackersOnlySynced = isBackersOnlyChanged
      .takeWhen(currentDraft)
      .filter(isTrue)

    Signal.combineLatest(project, self.isBackersOnly)
      .takeWhen(isBackersOnlySynced)
      .observeValues {
        AppEnvironment.current.koala.trackChangedUpdateDraftVisibility(forProject: $0, isPublic: !$1)
      }

    project
      .takeWhen(self.addAttachmentSheetButtonTappedProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackStartedAddUpdateDraftAttachment(forProject: $0)
      }

    Signal.combineLatest(project, self.imagePickedProperty.signal.skipNil().map(second))
      .takeWhen(self.attachmentAdded)
      .observeValues {
        AppEnvironment.current.koala.trackCompletedAddUpdateDraftAttachment(forProject: $0, attachedFrom: $1)
      }

    project
      .takeWhen(self.imagePickerCanceledProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackCanceledAddUpdateDraftAttachment(forProject: $0)
      }

    project
      .takeWhen(self.showAddAttachmentFailure)
      .observeValues {
        AppEnvironment.current.koala.trackFailedAddUpdateDraftAttachment(forProject: $0)
      }

    project
      .takeWhen(self.attachmentTappedProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackStartedRemoveUpdateDraftAttachment(forProject: $0)
      }

    project
      .takeWhen(self.attachmentRemoved)
      .observeValues {
        AppEnvironment.current.koala.trackCompletedRemoveUpdateDraftAttachment(forProject: $0)
      }

    project
      .takeWhen(self.removeAttachmentConfirmationCanceledProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackCanceledRemoveUpdateDraftAttachment(forProject: $0)
      }

    project
      .takeWhen(self.showRemoveAttachmentFailure)
      .observeValues {
        AppEnvironment.current.koala.trackFailedRemoveUpdateDraftAttachment(forProject: $0)
      }
  }

  // INPUTS
  fileprivate let addAttachmentButtonTappedProperty = MutableProperty<[AttachmentSource]>([])
  public func addAttachmentButtonTapped(availableSources: [AttachmentSource]) {
    self.addAttachmentButtonTappedProperty.value = availableSources
  }

  fileprivate let addAttachmentSheetButtonTappedProperty = MutableProperty<AttachmentSource?>(nil)
  public func addAttachmentSheetButtonTapped(_ action: AttachmentSource) {
    self.addAttachmentSheetButtonTappedProperty.value = action
  }

  fileprivate let attachmentTappedProperty = MutableProperty(0)
  public func attachmentTapped(id: Int) {
    self.attachmentTappedProperty.value = id
  }

  fileprivate let bodyTextChangedProperty = MutableProperty("")
  public func bodyTextChanged(to body: String) {
    self.bodyTextChangedProperty.value = body
  }

  fileprivate let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let imagePickedProperty = MutableProperty<(URL, AttachmentSource)?>(nil)
  public func imagePicked(url: URL, fromSource source: AttachmentSource) {
    self.imagePickedProperty.value = (url, source)
  }

  fileprivate let imagePickerCanceledProperty = MutableProperty(())
  public func imagePickerCanceled() {
    self.imagePickerCanceledProperty.value = ()
  }

  fileprivate let isBackersOnlyOnProperty = MutableProperty(false)
  public func isBackersOnlyOn(_ isBackersOnly: Bool) {
    self.isBackersOnlyOnProperty.value = isBackersOnly
  }

  fileprivate let previewButtonTappedProperty = MutableProperty(())
  public func previewButtonTapped() {
    self.previewButtonTappedProperty.value = ()
  }

  fileprivate let removeAttachmentProperty = MutableProperty<UpdateDraft.Attachment?>(nil)
  public func remove(attachment: UpdateDraft.Attachment) {
    self.removeAttachmentProperty.value = attachment
  }

  fileprivate let removeAttachmentConfirmationCanceledProperty = MutableProperty(())
  public func removeAttachmentConfirmationCanceled() {
    self.removeAttachmentConfirmationCanceledProperty.value = ()
  }

  fileprivate let titleTextChangedProperty = MutableProperty("")
  public func titleTextChanged(to title: String) {
    self.titleTextChangedProperty.value = title
  }

  fileprivate let titleTextFieldDoneEditingProperty = MutableProperty(())
  public func titleTextFieldDoneEditing() {
    self.titleTextFieldDoneEditingProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillDisappearProperty = MutableProperty(())
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  // OUTPUTS
  public let attachmentAdded: Signal<UpdateDraft.Attachment, Never>
  public let attachmentRemoved: Signal<UpdateDraft.Attachment, Never>
  public let attachments: Signal<[UpdateDraft.Attachment], Never>
  public let body: Signal<String, Never>
  public let bodyTextViewBecomeFirstResponder: Signal<(), Never>
  public let goToPreview: Signal<UpdateDraft, Never>
  public let isAttachmentsSectionHidden: Signal<Bool, Never>
  public let isLoading: Signal<Bool, Never>
  public let isBodyPlaceholderHidden: Signal<Bool, Never>
  public let isBackersOnly: Signal<Bool, Never>
  public let isPreviewButtonEnabled: Signal<Bool, Never>
  public let navigationItemTitle: Signal<String, Never>
  public let notifyPresenterViewControllerWantsDismissal: Signal<(), Never>
  public let resignFirstResponder: Signal<(), Never>
  public let showAddAttachmentFailure: Signal<(), Never>
  public let showAttachmentActions: Signal<[AttachmentSource], Never>
  public let showImagePicker: Signal<AttachmentSource, Never>
  public let showLoadFailure: Signal<(), Never>
  public let showRemoveAttachmentConfirmation: Signal<UpdateDraft.Attachment, Never>
  public let showRemoveAttachmentFailure: Signal<(), Never>
  public let showSaveFailure: Signal<(), Never>
  public let title: Signal<String, Never>
  public let titleTextFieldBecomeFirstResponder: Signal<(), Never>

  public var inputs: UpdateDraftViewModelInputs { return self }
  public var outputs: UpdateDraftViewModelOutputs { return self }
}

public enum AttachmentSource: String {
  case camera
  case cameraRoll = "camera_roll"

  public init(sourceType: UIImagePickerController.SourceType) {
    switch sourceType {
    case .camera:
      self = .camera
    case .photoLibrary:
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

  public var sourceType: UIImagePickerController.SourceType {
    switch self {
    case .camera:
      return .camera
    case .cameraRoll:
      return .photoLibrary
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

private func hasChanged<T: Equatable>(_ original: Signal<T, Never>, _ updated: Signal<T, Never>)
  -> Signal<Bool, Never> {
  return Signal
    .merge(
      original.mapConst(false),
      Signal.combineLatest(original, updated)
        .map(!=)
    )
    .skipRepeats()
}
