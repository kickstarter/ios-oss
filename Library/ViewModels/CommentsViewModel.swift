import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentsViewModelInputs {
  /// Call with the project/update that we are viewing comments for. Both can be provided to minimize
  /// the number of API requests made, but it will be assumed we are viewing the comments for the update.
  func configureWith(project: Project?, update: Update?)

  /// Call when the User is posting a comment or reply
  func postCommentButtonTapped()

  ///  Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol CommentsViewModelOutputs {
  /// Emits a URL for the avatar image view.
  var avatarURL: Signal<URL?, Never> { get }

  /// Emits a boolean that determines if comments are currently loading.
  var commentsAreLoading: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the comment input area is visible.
  var inputAreaVisible: Signal<Bool, Never> { get }

  /// Emits a list of comments that should be displayed.
  var dataSource: Signal<([Comment], Project), Never> { get }
}

public protocol CommentsViewModelType {
  var inputs: CommentsViewModelInputs { get }
  var outputs: CommentsViewModelOutputs { get }
}

public final class CommentsViewModel: CommentsViewModelType,
  CommentsViewModelInputs,
  CommentsViewModelOutputs {
  public init() {
    let projectOrUpdate = Signal.combineLatest(
      self.projectAndUpdateProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .flatMap { project, update in
      SignalProducer(value: project.map(Either.left) ?? update.map(Either.right))
        .skipNil()
    }

    let currentUser = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.currentUser }
      .skipNil()

    let initialProject = projectOrUpdate
      .flatMap { projectOrUpdate in
        projectOrUpdate.ifLeft(
          SignalProducer.init(value:),
          ifRight: {
            AppEnvironment.current.apiService.fetchProject(param: .id($0.projectId)).demoteErrors()
          }
        )
      }

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter { isClose in isClose }
      .ignoreValues()

    let requestFirstPageWith = Signal.merge(
      initialProject,
      initialProject.takeWhen(self.refreshProperty.signal)
      /** TODO: Add this in once comment composer is added.
       projectOrUpdate.takeWhen(self.commentPostedProperty.signal)
        **/
    )

    let (comments, isLoading, _, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.comments },
      cursorFromEnvelope: { ($0.slug, $0.cursor) },
      requestFromParams: { project in
        AppEnvironment.current.apiService
          .fetchComments(query: commentsQuery(withProjectSlug: project.slug))
      },
      requestFromCursor: { projectSlug, cursor in
        AppEnvironment.current.apiService
          .fetchComments(query: commentsQuery(
            withProjectSlug: projectSlug,
            after: cursor
          ))
      }
    )

    let commentsAndProject = Signal.combineLatest(comments, initialProject)

    self.dataSource = commentsAndProject
    self.commentsAreLoading = isLoading

    // FIXME: We need to dynamically supply the IDs when the UI is built.
    // The IDs here correspond to the following project: `THE GREAT GATSBY: Limited Edition Letterpress Print`.
    // When testing, replace with a project you have Backed or Created.
    self.postCommentButtonTappedProperty.signal.switchMap { _ in
      AppEnvironment.current.apiService
        .postComment(input: .init(
          body: "Testing on iOS!",
          commentableId: "UHJvamVjdC02NDQ2NzAxMzU=",
          parentId: "Q29tbWVudC0zMjY2MjUzOQ=="
        ))
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }
    .observeValues { print($0) }

    self.avatarURL = currentUser.map { URL(string: $0.avatar.medium) }
    // TODO: https://github.com/kickstarter/ios-oss/pull/1483 NT-1796
    self.inputAreaVisible = self.viewDidLoadProperty.signal.mapConst(true)
  }

  fileprivate let postCommentButtonTappedProperty = MutableProperty(())
  public func postCommentButtonTapped() {
    self.postCommentButtonTappedProperty.value = ()
  }

  fileprivate let projectAndUpdateProperty = MutableProperty<(Project?, Update?)?>(nil)
  public func configureWith(project: Project?, update: Update?) {
    self.projectAndUpdateProperty.value = (project, update)
  }

  fileprivate let refreshProperty = MutableProperty(())
  public func refresh() {
    self.refreshProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let commentsAreLoading: Signal<Bool, Never>
  public var avatarURL: Signal<URL?, Never>
  public var inputAreaVisible: Signal<Bool, Never>
  public let dataSource: Signal<([Comment], Project), Never>

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}
