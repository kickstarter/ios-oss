import Foundation
import KsApi
import ReactiveSwift
import UIKit

public protocol CommentCellViewModelInputs {
  func comment(_ comment: Comment, project: Project, viewer: User?)
}

public protocol CommentCellViewModelOutputs {
  var avatarUrl: Signal<URL?, Never> { get }
  var body: Signal<String, Never> { get }
  var bodyColor: Signal<UIColor, Never> { get }
  var bodyFont: Signal<UIFont, Never> { get }
  var creatorHidden: Signal<Bool, Never> { get }
  var name: Signal<String, Never> { get }
  var timestamp: Signal<String, Never> { get }
  var youHidden: Signal<Bool, Never> { get }
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
      .map { $0.author.avatar.thumb }
      .map(URL.init(string:))

    self.body = comment.map { $0.body }

    let isNotDeleted = comment.map { $0.deletedAt == nil }

    self.bodyColor = isNotDeleted.skipRepeats()
      .map { $0 ? .ksr_soft_black : .ksr_text_dark_grey_400 }

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

  public let avatarUrl: Signal<URL?, Never>
  public let body: Signal<String, Never>
  public let bodyColor: Signal<UIColor, Never>
  public let bodyFont: Signal<UIFont, Never>
  public let creatorHidden: Signal<Bool, Never>
  public let name: Signal<String, Never>
  public let timestamp: Signal<String, Never>
  public let youHidden: Signal<Bool, Never>

  public var inputs: CommentCellViewModelInputs { return self }
  public var outputs: CommentCellViewModelOutputs { return self }
}
