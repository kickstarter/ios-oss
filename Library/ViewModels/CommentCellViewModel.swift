import Foundation
import KsApi
import ReactiveSwift
import Result
import UIKit

public protocol CommentCellViewModelInputs {
  func comment(_ comment: Comment, project: Project, viewer: User?)
}

public protocol CommentCellViewModelOutputs {
  var avatarUrl: Signal<URL?, NoError> { get }
  var body: Signal<String, NoError> { get }
  var bodyColor: Signal<UIColor, NoError> { get }
  var bodyFont: Signal<UIFont, NoError> { get }
  var creatorHidden: Signal<Bool, NoError> { get }
  var name: Signal<String, NoError> { get }
  var timestamp: Signal<String, NoError> { get }
  var youHidden: Signal<Bool, NoError> { get }
}

public protocol CommentCellViewModelType {
  var inputs: CommentCellViewModelInputs { get }
  var outputs: CommentCellViewModelOutputs { get }
}

public final class CommentCellViewModel: CommentCellViewModelType, CommentCellViewModelInputs,
CommentCellViewModelOutputs {

  public init() {
    let comment = self.commentProjectViewer.signal.skipNil()
      .map { comment, _, _ in comment }

    self.avatarUrl = comment
      .map { $0.author.avatar.large ?? $0.author.avatar.medium }
      .map(URL.init(string:))

    self.body = comment.map { $0.body }

    let isNotDeleted = comment.map { $0.deletedAt == nil }

    self.bodyColor = isNotDeleted.skipRepeats()
      .map { $0 ? .ksr_text_navy_700 : .ksr_text_navy_500 }

    self.bodyFont = isNotDeleted.skipRepeats()
      .map { $0 ? UIFont.ksr_body(size: 16.0) : UIFont.ksr_body(size: 16.0).italicized }

    self.creatorHidden = self.commentProjectViewer.signal.skipNil()
      .map { comment, project, _ in comment.author.id != project.creator.id }

    self.name = comment.map { $0.author.name }

    self.timestamp = comment.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .medium, timeStyle: .short)
    }

    self.youHidden = self.commentProjectViewer.signal.skipNil()
      .map { comment, project, viewer in
        comment.author.id != viewer?.id || comment.author.id == project.creator.id
    }
  }

  fileprivate let commentProjectViewer = MutableProperty<(Comment, Project, User?)?>(nil)
  public func comment(_ comment: Comment, project: Project, viewer: User?) {
    self.commentProjectViewer.value = (comment, project, viewer)
  }

  public let avatarUrl: Signal<URL?, NoError>
  public let body: Signal<String, NoError>
  public let bodyColor: Signal<UIColor, NoError>
  public let bodyFont: Signal<UIFont, NoError>
  public let creatorHidden: Signal<Bool, NoError>
  public let name: Signal<String, NoError>
  public let timestamp: Signal<String, NoError>
  public let youHidden: Signal<Bool, NoError>

  public var inputs: CommentCellViewModelInputs { return self }
  public var outputs: CommentCellViewModelOutputs { return self }
}
