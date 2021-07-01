import KsApi
import Library
import Prelude
import UIKit

internal final class CommentRepliesDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case rootComment
    case comments
    case empty
    case error
  }

  internal func createContext(comment: Comment) {
    let section = Section.rootComment.rawValue
    self.clearValues()

    self.appendRow(value: comment, cellClass: RootCommentCell.self, toSection: section)
  }

  /// Loads in a new page of comments.
  internal func load(comments: [Comment], project: Project) {
    // Clear all but rootComment section.
    self.clearValues(section: Section.empty.rawValue)
    self.clearValues(section: Section.error.rawValue)

    self.padValuesForSection(Section.comments.rawValue)

    let current = (self[section: Section.comments.rawValue] as? [(comment: Comment, project: Project)]) ?? []

    self.clearValues(section: Section.comments.rawValue)

    let newComments = comments.map { comment in
      (comment, project)
    }

    let allComments = newComments + current

    allComments.forEach { comment, project in
      self.loadValue(comment, project: project)
    }
  }

  // TODO: Implement and write tests
  internal func showEmptyState() {
    self.clearValues(section: Section.comments.rawValue)
    self.clearValues(section: Section.error.rawValue)

    self.appendRow(
      value: .errorPullToRefresh,
      cellClass: EmptyStateCell.self,
      toSection: Section.empty.rawValue
    )
  }

  // TODO: Implement and write tests
  internal func showErrorState() {
    self.clearValues()

    self.appendRow(
      value: (),
      cellClass: CommentsErrorCell.self,
      toSection: Section.error.rawValue
    )
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RootCommentCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as CommentCell, value as (Comment, Project)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }

  public func comment(at indexPath: IndexPath) -> Comment? {
    let value = self[indexPath]

    switch value {
    case let value as Comment: return value
    case let value as (comment: Comment, project: Project): return value.comment
    default: return nil
    }
  }

  internal func replace(comment: Comment, and project: Project,
                        byCommentId id: String) -> (IndexPath?, Bool)? {
    let section = Section.comments.rawValue
    let values = self.items(in: section)

    // TODO: We may need to introduce optimizations here if this becomes problematic for projects that have
    /// thousands of comments. Consider an accompanying `Set` to track membership or replacing entirely
    /// with an `OrderedSet`.
    let commentIndex = values.firstIndex { value in
      let foundAsCommentCell = (value as? (value: (Comment, Project), reusableId: String))?.value.0.id == id
      let foundAsOtherCell = (value as? (value: Comment, reusableId: String))?.value.id == id

      return foundAsCommentCell || foundAsOtherCell
    }

    var indexPath: IndexPath?

    // We found an existing comment, let's update the value at that IndexPath.
    if let commentIndex = commentIndex {
      indexPath = IndexPath(row: commentIndex, section: Section.comments.rawValue)
      return (self.loadValue(comment, project: project, at: indexPath), false)
    }

    // If the comment we're replacing is not found, it's new, append it.
    return (self.loadValue(comment, project: project, append: true), true)
  }

  @discardableResult
  private func loadValue(
    _ comment: Comment,
    project: Project,
    append: Bool = false,
    at indexPath: IndexPath? = nil
  ) -> IndexPath? {
    let section = Section.comments.rawValue

    // Removed
    guard comment.isDeleted == false else {
      if let indexPath = indexPath {
        self.set(
          value: comment,
          cellClass: CommentRemovedCell.self,
          inSection: indexPath.section,
          row: indexPath.row
        )

        return indexPath
      } else if append {
        return self.appendRow(
          value: comment,
          cellClass: CommentRemovedCell.self,
          toSection: section
        )
      }

      return self.insertRow(
        value: comment,
        cellClass: CommentRemovedCell.self,
        atIndex: 0,
        inSection: section
      )
    }

    // Failed and retrying
    switch comment.status {
    case .failed, .retrying:
      if let indexPath = indexPath {
        self.set(
          value: comment,
          cellClass: CommentPostFailedCell.self,
          inSection: indexPath.section,
          row: indexPath.row
        )

        return indexPath
      } else if append {
        return self.appendRow(
          value: comment,
          cellClass: CommentPostFailedCell.self,
          toSection: section
        )
      }

      return self.insertRow(
        value: comment,
        cellClass: CommentPostFailedCell.self,
        atIndex: 0,
        inSection: section
      )

    // Retry success and success
    case .success, .retrySuccess:
      if let indexPath = indexPath {
        self.set(
          value: (comment, project),
          cellClass: CommentCell.self,
          inSection: indexPath.section,
          row: indexPath.row
        )

        return indexPath
      } else if append {
        return self.appendRow(
          value: (comment, project),
          cellClass: CommentCell.self,
          toSection: section
        )
      }

      return self.appendRow(value: (comment, project), cellClass: CommentCell.self, toSection: section)
    case .unknown:
      assertionFailure("Comments that have not had their state set should not be added to the data source.")
    }

    return nil
  }
}
