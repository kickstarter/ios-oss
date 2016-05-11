import Foundation
import Library
import Models
import ReactiveCocoa
import Result
import UIKit

internal protocol CommentCellViewModelInputs {
  func comment(comment: Comment, project: Project, viewer: User?)
}

internal protocol CommentCellViewModelOutputs {
  var avatarUrl: Signal<NSURL?, NoError> { get }
  var body: Signal<String, NoError> { get }
  var bodyColor: Signal<UIColor, NoError> { get }
  var bodyFont: Signal<UIFont, NoError> { get }
  var creatorHidden: Signal<Bool, NoError> { get }
  var name: Signal<String, NoError> { get }
  var timestamp: Signal<String, NoError> { get }
  var youHidden: Signal<Bool, NoError> { get }
}

internal protocol CommentCellViewModelType {
  var inputs: CommentCellViewModelInputs { get }
  var outputs: CommentCellViewModelOutputs { get }
}

internal final class CommentCellViewModel: CommentCellViewModelType, CommentCellViewModelInputs,
CommentCellViewModelOutputs {

  internal init() {
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
  internal func comment(comment: Comment, project: Project, viewer: User?) {
    self.commentProjectViewer.value = (comment, project, viewer)
  }

  internal let avatarUrl: Signal<NSURL?, NoError>
  internal let body: Signal<String, NoError>
  internal let bodyColor: Signal<UIColor, NoError>
  internal let bodyFont: Signal<UIFont, NoError>
  internal let creatorHidden: Signal<Bool, NoError>
  internal let name: Signal<String, NoError>
  internal let timestamp: Signal<String, NoError>
  internal let youHidden: Signal<Bool, NoError>

  internal var inputs: CommentCellViewModelInputs { return self }
  internal var outputs: CommentCellViewModelOutputs { return self }
}

// Italicizes the font provided
private func italicizeFont(font: UIFont) -> UIFont {
  let italicsDescriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitItalic)
  return UIFont(descriptor: italicsDescriptor, size: 0.0)
}
