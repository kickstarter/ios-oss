import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentsViewModelInputs {
  /// Call when the User is posting a comment or reply
  func postCommentButtonTapped()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentsViewModelOutputs {
  /// Emits a list of comments that should be displayed.
  var dataSource: Signal<([Comment], User?), Never> { get }
}

public protocol CommentsViewModelType {
  var inputs: CommentsViewModelInputs { get }
  var outputs: CommentsViewModelOutputs { get }
}

public final class CommentsViewModel: CommentsViewModelType,
  CommentsViewModelInputs,
  CommentsViewModelOutputs {
  public init() {
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

    // FIXME: This would be removed when we fetch comments from API
    self.dataSource = self.templatesComments.signal.skipNil()
  }

  fileprivate let postCommentButtonTappedProperty = MutableProperty(())
  public func postCommentButtonTapped() {
    self.postCommentButtonTappedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())

  // TODO: - This would be removed when we fetch comments from API
  fileprivate let templatesComments = MutableProperty<([Comment], User?)?>(nil)
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()

    // FIXME: This would be removed when we fetch comments from API
    self.templatesComments.value = (Comment.templates, AppEnvironment.current.currentUser)
  }

  public let dataSource: Signal<([Comment], User?), Never>

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}
