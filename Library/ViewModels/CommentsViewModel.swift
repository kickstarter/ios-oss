import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentsViewModelInputs {
  /// Call after instantiating the view controller
  func configureWith(project: Project)

  /// Call when the User is posting a comment or reply
  func postCommentButtonTapped()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentsViewModelOutputs {
  /// Emits a URL for the avatar image view.
  var avatarURL: Signal<URL?, Never> { get }

  /// Emits a boolean that determines if the comment input area is visible.
  var isCommentComposerHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the user is a backer on the project.
  var isBacking: Signal<Bool, Never> { get }

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
    let currentUser = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.currentUser }

    // FIXME: Configure this VM with a project in order to feed the slug in here to fetch comments
    // Call this again with a cursor to paginate.
    self.viewDidLoadProperty.signal.switchMap { _ in
      AppEnvironment.current.apiService
        .fetchComments(query: comments(withProjectSlug: "bring-back-weekly-world-news"))
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }
    .observeValues { print($0) }

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

    self.avatarURL = currentUser
      .skipNil()
      .map { URL(string: $0.avatar.medium) }

    // FIXME: This will be updated/removed when we fetch comments from API
    self.dataSource = self.templatesComments.signal
      .skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    self.isBacking = self.projectProperty.signal
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { $0 }
      .skipNil()
      .map(userIsBackingProject)

    self.isCommentComposerHidden = currentUser.signal
      .map { user in user.isNil }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project

    self.templatesComments.value = (
      Comment.templates,
      project
    )
  }

  fileprivate let postCommentButtonTappedProperty = MutableProperty(())
  public func postCommentButtonTapped() {
    self.postCommentButtonTappedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())

  // TODO: - This would be removed when we fetch comments from API
  fileprivate let templatesComments = MutableProperty<([Comment], Project)?>(nil)
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var avatarURL: Signal<URL?, Never>
  public let isCommentComposerHidden: Signal<Bool, Never>
  public let isBacking: Signal<Bool, Never>
  public let dataSource: Signal<([Comment], Project), Never>

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}
