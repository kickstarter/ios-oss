import KsApi
import Library
import Prelude
import UIKit

internal final class CommentRepliesDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case rootComment
    case replies
    case empty
    case error
  }

  internal func loadRootComment(_ comment: Comment) {
    let section = Section.rootComment.rawValue
    self.clearValues()

    self.appendRow(value: comment, cellClass: RootCommentCell.self, toSection: section)
  }

  /// Loads in a new page of comments.
  internal func load(comments: [Comment], project: Project) {
    // Clear all but rootComment section.
    self.clearValues(section: Section.empty.rawValue)
    self.clearValues(section: Section.error.rawValue)

    self.padValuesForSection(Section.replies.rawValue)

    let current = (self[section: Section.replies.rawValue] as? [(comment: Comment, project: Project)]) ?? []

    self.clearValues(section: Section.replies.rawValue)

    let newComments = comments.map { comment in
      (comment, project)
    }

    let allComments = newComments + current

    allComments.forEach { comment, project in
      self.loadValue(comment, project: project)
    }
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
    case let (cell as CommentPostFailedCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as CommentRemovedCell, value as Comment):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }

  /// Retrieves a `Comment` object at a given `IndexPath`, if present.
  public func comment(at indexPath: IndexPath) -> Comment? {
    let value = self[indexPath]

    switch value {
    case let value as Comment: return value
    case let value as (comment: Comment, project: Project): return value.comment
    default: return nil
    }
  }

  /**
   Replaces a `Commment` at a given `IndexPath` by using `loadValue`.

   - parameter comment: `Comment` object that will be replacing an existing cell in the tableView..
   - parameter and: `Project` object required for `loadValue`to append the row.
   - parameter id: `String` object, representing the ID of the `Comment`object that is potentially already in the tableView.

   - returns: An optional tuple of `(IndexPath?, Bool)?`. The `Bool` object determines if the tableView needs to be reloaded.
   */
  @discardableResult
  internal func replace(
    comment: Comment, and project: Project,
    byCommentId id: String
  ) -> (IndexPath?, Bool) {
    let section = Section.replies.rawValue
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
      indexPath = IndexPath(row: commentIndex, section: Section.replies.rawValue)
      return (self.loadValue(comment, project: project, at: indexPath), false)
    }

    // If the comment we're replacing is not found, it's new, append it.
    return (self.loadValue(comment, project: project, append: true), true)
  }

  // MARK: Helpers

  /**
   Loads a `Comment` into the data source at a given `IndexPath`.

   - parameter comment: `Comment` object that will be loaded into the tableView..
   - parameter project: `Project` object required for the data source schema of the cell.
   - parameter at: `IndexPath?` object, representing a potential insertion point for a `Comment`.

   - returns: An optional `IndexPath?`representing where a given `Comment` needs to be inserted/appended.
   */
  @discardableResult
  private func loadValue(
    _ comment: Comment,
    project: Project,
    append: Bool = false,
    at indexPath: IndexPath? = nil
  ) -> IndexPath? {
    let section = Section.replies.rawValue

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
