import Foundation
import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol UpdateDraftViewModelInputs {
  /// Call when the creator taps "add attachment".
  func addAttachmentButtonTapped()

  /// Call when the draft body changes.
  func bodyTextChanged(body: String)

  /// Call when the creator taps "Close".
  func closeButtonTapped()

  /// Call with the project provided to the view.
  func configureWith(project project: Project)

  /// Call when the creator taps "public"/"backers only".
  func isBackersOnlyOn(isBackersOnly: Bool)

  /// Call when the creator taps "preview".
  func previewButtonTapped()

  /// Call when a creator removes an attachment.
  func removeAttachment(attachment: UpdateDraft.Attachment)

  /// Call when the draft title changes.
  func titleTextChanged(title: String)

  /// Call when title text field keyboard returns.
  func titleTextFieldDoneEditing()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will disappear.
  func viewWillDisappear()
}

public protocol UpdateDraftViewModelOutputs {
  /// An collection of attachments.
  var attachments: Signal<[UpdateDraft.Attachment], NoError> { get }

  /// The draft's working body.
  var body: Signal<String, NoError> { get }

  /// When the body text view should become first responder.
  var bodyTextViewBecomeFirstResponder: Signal<(), NoError> { get }

  /// Whether or not the draft is being fetched from the API.
  var isLoading: Signal<Bool, NoError> { get }

  /// Whether or not the draft is limited to backers only.
  var isBackersOnly: Signal<Bool, NoError> { get }

  /// Whether or no the preview button should be enabled.
  var isPreviewButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits when the view controller should be dismissed.
  var notifyPresenterViewControllerWantsDismissal: Signal<(), NoError> { get }

  /// Emits when the keyboard should be dismissed.
  var resignFirstResponder: Signal<(), NoError> { get }

  /// Emits when the view controller should show a load error.
  var showLoadFailure: Signal<(), NoError> { get }

  /// Emits when the view controller should show a preview.
  var showPreview: Signal<NSURL, NoError> { get }

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

    self.title = draft.map { $0.update.title }
    self.body = draft.map { $0.update.body ?? "" }

    let wasBackersOnly = draft.map { $0.update.isPublic }.map(negate)
    self.isBackersOnly = Signal.merge(wasBackersOnly, self.isBackersOnlyOnProperty.signal)

    let currentTitle = Signal.merge(self.title, self.titleTextChangedProperty.signal)
    let currentBody = Signal.merge(self.body, self.bodyTextChangedProperty.signal)

    let titleChanged = hasChanged(self.title, currentTitle)
    let bodyChanged = hasChanged(self.body, currentBody)
    let isBackersOnlyChanged = hasChanged(wasBackersOnly, self.isBackersOnly)

    self.attachments = draft
      .map {
        $0.images.map(UpdateDraft.Attachment.image) + [$0.video.map(UpdateDraft.Attachment.video)].compact()
    }

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

    let draftHasTitle = draft
      .map { !$0.update.title.isEmpty }

    self.titleTextFieldBecomeFirstResponder = draftHasTitle
      .filter(isFalse)
      .ignoreValues()

    self.bodyTextViewBecomeFirstResponder = .merge(
      self.titleTextFieldDoneEditingProperty.signal,
      draftHasTitle.filter(isTrue).ignoreValues()
    )

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
      draftEvent.errors().ignoreValues(),
      saveAction
        .takeWhen(currentDraft)
        .filter { $0 == .dismiss }
        .ignoreValues())

    self.showSaveFailure = currentDraftEvent.errors().ignoreValues()

    self.showPreview = saveAction
      .takePairWhen(currentDraft)
      .filter { action, _ in action == .preview }
      .map { _, draft in AppEnvironment.current.apiService.previewUrl(forDraft: draft) }

    self.resignFirstResponder = self.viewWillDisappearProperty.signal

    // koala

    project
      .observeNext { AppEnvironment.current.koala.trackViewedUpdateDraft(forProject: $0) }

    project
      .takeWhen(self.notifyPresenterViewControllerWantsDismissal)
      .observeNext { AppEnvironment.current.koala.trackClosedUpdateDraft(forProject: $0) }

    project
      .takeWhen(self.showPreview)
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

    // trackPublishedUpdate(forProject: $0)
    // trackStartedAddUpdateDraftAttachment(forProject $0)
    // trackCompletedAddUpdateDraftAttachment(forProject: $0)
    // trackCanceledAddUpdateDraftAttachment(forProject: $0)
  }
  // swiftlint:enable function_body_length

  // INPUTS
  private let addAttachmentButtonTappedProperty = MutableProperty()
  public func addAttachmentButtonTapped() {
    self.addAttachmentButtonTappedProperty.value = ()
  }

  private let bodyTextChangedProperty = MutableProperty("")
  public func bodyTextChanged(body: String) {
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

  private let isBackersOnlyOnProperty = MutableProperty(false)
  public func isBackersOnlyOn(isBackersOnly: Bool) {
    self.isBackersOnlyOnProperty.value = isBackersOnly
  }

  private let previewButtonTappedProperty = MutableProperty()
  public func previewButtonTapped() {
    self.previewButtonTappedProperty.value = ()
  }

  private let removeAttachmentProperty = MutableProperty<UpdateDraft.Attachment?>(nil)
  public func removeAttachment(attachment: UpdateDraft.Attachment) {
    self.removeAttachmentProperty.value = attachment
  }

  private let titleTextChangedProperty = MutableProperty("")
  public func titleTextChanged(title: String) {
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
  public let attachments: Signal<[UpdateDraft.Attachment], NoError>
  public let body: Signal<String, NoError>
  public let bodyTextViewBecomeFirstResponder: Signal<(), NoError>
  public let isLoading: Signal<Bool, NoError>
  public let isBackersOnly: Signal<Bool, NoError>
  public let isPreviewButtonEnabled: Signal<Bool, NoError>
  public let notifyPresenterViewControllerWantsDismissal: Signal<(), NoError>
  public let resignFirstResponder: Signal<(), NoError>
  public let showLoadFailure: Signal<(), NoError>
  public let showPreview: Signal<NSURL, NoError>
  public let showSaveFailure: Signal<(), NoError>
  public let title: Signal<String, NoError>
  public let titleTextFieldBecomeFirstResponder: Signal<(), NoError>

  public var inputs: UpdateDraftViewModelInputs { return self }
  public var outputs: UpdateDraftViewModelOutputs { return self }
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
