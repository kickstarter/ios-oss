import Foundation
import Models
import ReactiveCocoa
import Result
import UIKit

public protocol CommentCellViewModelInputs {
  func comment(comment: Comment, project: Project, viewer: User?)
}

public protocol CommentCellViewModelOutputs {
  var avatarUrl: Signal<NSURL?, NoError> { get }
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
    let comment = self.commentProjectViewer.signal.ignoreNil()
      .map { comment, _, _ in comment }

    self.avatarUrl = comment
      .map { $0.author.avatar.large ?? $0.author.avatar.medium }
      .map { NSURL(string: $0) }

    self.body = comment.map { $0.body }

    let isNotDeleted = comment.map { $0.deletedAt == nil }

    self.bodyColor = isNotDeleted.skipRepeats()
      .map { $0 ? Color.TextDefault.toUIColor() : Color.TextDarkGray.toUIColor() }

    self.bodyFont = isNotDeleted.skipRepeats()
      .map { $0 ? FontStyle.Body.toUIFont() : italicizeFont(FontStyle.Body.toUIFont()) }

    self.creatorHidden = self.commentProjectViewer.signal.ignoreNil()
      .map { comment, project, viewer in
        viewer?.id != project.creator.id || comment.author.id == viewer?.id
    }

    self.name = comment.map { $0.author.name }

    self.timestamp = comment.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    }

    self.youHidden = self.commentProjectViewer.signal.ignoreNil()
      .map { comment, _, viewer in
        comment.author.id != viewer?.id
    }
  }

  private let commentProjectViewer = MutableProperty<(Comment, Project, User?)?>(nil)
  public func comment(comment: Comment, project: Project, viewer: User?) {
    self.commentProjectViewer.value = (comment, project, viewer)
  }

  public let avatarUrl: Signal<NSURL?, NoError>
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

// Italicizes the font provided
private func italicizeFont(font: UIFont) -> UIFont {
  let italicsDescriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitItalic)
  return UIFont(descriptor: italicsDescriptor, size: 0.0)
}
