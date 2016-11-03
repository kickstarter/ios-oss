import ReactiveCocoa
import ReactiveExtensions
import Result
import KsApi
import Prelude

public protocol CommentsViewModelInputs {
  /// Call when the comment button is pressed.
  func commentButtonPressed()

  /// Call when the comment dialog has posted a comment.
  func commentPosted(comment: Comment)

  /// Call when the login button is pressed in the empty state.
  func loginButtonPressed()

  /// Call with the project/update that we are viewing comments for. Both can be provided to minimize
  /// the number of API requests made, but it will be assumed we are viewing the comments for the update.
  func configureWith(project project: Project?, update: Update?)

  ///  Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when a user session has started
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when a new row is displayed.
  func willDisplayRow(row: Int, outOf totalRows: Int)
}

public protocol CommentsViewModelOutputs {
  /// Emits a list of comments that should be displayed.
  var dataSource: Signal<([Comment], Project, User?), NoError> { get }

  /// Emits a boolean that determines if the comment bar button is visible.
  var commentBarButtonVisible: Signal<Bool, NoError> { get }

  /// Emits a project and an update to display the empty state.
  var emptyStateVisible: Signal<(Project, Update?), NoError> { get }

  /// Emits a project and optional update when the comment dialog should be presented.
  var presentPostCommentDialog: Signal<(Project, Update?), NoError> { get }

  /// Emits when the login tout should be opened.
  var openLoginTout: Signal<(), NoError> { get }

  /// Emits when the login tout should be closed.
  var closeLoginTout: Signal<(), NoError> { get }

  /// Emits a boolean that determines if comments are currently loading.
  var commentsAreLoading: Signal<Bool, NoError> { get }
}

public protocol CommentsViewModelType {
  var inputs: CommentsViewModelInputs { get }
  var outputs: CommentsViewModelOutputs { get }
}

public final class CommentsViewModel: CommentsViewModelType, CommentsViewModelInputs,
CommentsViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let projectOrUpdate = combineLatest(
      self.projectAndUpdateProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)
      .flatMap { project, update in
        return SignalProducer(value: project.map(Either.left) ?? update.map(Either.right))
          .ignoreNil()
    }

    let initialProject = projectOrUpdate
      .flatMap { projectOrUpdate in
        projectOrUpdate.ifLeft(SignalProducer.init(value:),
          ifRight: {
            AppEnvironment.current.apiService.fetchProject(param: .id($0.projectId)).demoteErrors()
        })
    }

    let refreshedProjectOnLogin = initialProject
      .takeWhen(self.userSessionStartedProperty.signal)
      .flatMap { AppEnvironment.current.apiService.fetchProject(project: $0).demoteErrors() }

    let project = Signal.merge(initialProject, refreshedProjectOnLogin)
    let update = self.projectAndUpdateProperty.signal.ignoreNil().map { _, update in update }

    let isCloseToBottom = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter { isClose in isClose }
      .ignoreValues()

    let user = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.userSessionStartedProperty.signal
      )
      .map { AppEnvironment.current.currentUser }

    let requestFirstPageWith = Signal.merge(
      projectOrUpdate,
      projectOrUpdate.takeWhen(self.refreshProperty.signal),
      projectOrUpdate.takeWhen(self.commentPostedProperty.signal)
    )

    let (comments, isLoading, pageCount) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.comments },
      cursorFromEnvelope: { $0.urls.api.moreComments },
      requestFromParams: { updateOrProject in
        updateOrProject.ifLeft(AppEnvironment.current.apiService.fetchComments(project:),
          ifRight: AppEnvironment.current.apiService.fetchComments(update:))
      },
      requestFromCursor: { AppEnvironment.current.apiService.fetchComments(paginationUrl: $0) })

    self.dataSource = combineLatest(comments, project, user)
      .skipRepeats { lhs, rhs in lhs.0.isEmpty && rhs.0.isEmpty }

    self.commentsAreLoading = isLoading

    self.emptyStateVisible = combineLatest(comments, project, update)
      .filter { comments, _, _ in comments.isEmpty }
      .map { _, project, update in (project, update) }

    let userCanComment = combineLatest(comments, project)
      .map { comments, project in !comments.isEmpty && canComment(onProject: project) }
      .skipRepeats()

    self.commentBarButtonVisible = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      userCanComment
      )
      .skipRepeats()

    self.presentPostCommentDialog = combineLatest(project, update)
      .takeWhen(
        Signal.merge(self.commentButtonPressedProperty.signal, self.userSessionStartedProperty.signal)
      )

    self.openLoginTout = self.loginButtonPressedProperty.signal
    self.closeLoginTout = self.userSessionStartedProperty.signal

    combineLatest(project, update)
      .takeWhen(self.viewDidLoadProperty.signal)
      .take(1)
      .observeNext { project, update in
        AppEnvironment.current.koala.trackCommentsView(
          project: project, update: update, context: update == nil ? .project : .update
        )
    }

    combineLatest(project, update)
      .takeWhen(pageCount.skip(1).filter { $0 == 1 })
      .observeNext { project, update in
        AppEnvironment.current.koala.trackLoadNewerComments(
          project: project, update: update, context: update == nil ? .project : .update
        )
    }

    combineLatest(project, update)
      .takePairWhen(pageCount.skip(1).filter { $0 > 1 })
      .map(unpack)
      .observeNext { project, update, pageCount in
        AppEnvironment.current.koala.trackLoadOlderComments(
          project: project, update: update, page: pageCount, context: update == nil ? .project : .update
        )
    }
  }
  // swiftlint:enable function_body_length

  private let commentButtonPressedProperty = MutableProperty()
  public func commentButtonPressed() {
    self.commentButtonPressedProperty.value = ()
  }

  private let commentPostedProperty = MutableProperty<Comment?>(nil)
  public func commentPosted(comment: Comment) {
    self.commentPostedProperty.value = comment
  }

  private let loginButtonPressedProperty = MutableProperty()
  public func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  private let projectAndUpdateProperty = MutableProperty<(Project?, Update?)?>(nil)
  public func configureWith(project project: Project?, update: Update?) {
    self.projectAndUpdateProperty.value = (project, update)
  }

  private let refreshProperty = MutableProperty()
  public func refresh() {
    self.refreshProperty.value = ()
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let closeLoginTout: Signal<(), NoError>
  public let commentBarButtonVisible: Signal<Bool, NoError>
  public let commentsAreLoading: Signal<Bool, NoError>
  public let dataSource: Signal<([Comment], Project, User?), NoError>
  public var emptyStateVisible: Signal<(Project, Update?), NoError>
  public let openLoginTout: Signal<(), NoError>
  public let presentPostCommentDialog: Signal<(Project, Update?), NoError>

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}

private func canComment(onProject project: Project) -> Bool {
  return project.personalization.isBacking == true
    || project.memberData.permissions.contains(.comment)
}
