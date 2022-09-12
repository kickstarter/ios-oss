import KsApi
import Library
import Prelude
import UIKit

internal final class CommentRepliesDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case rootComment
    case viewMoreRepliesError
    case viewMoreReplies
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
  internal func load(repliesAndTotalCount: ([Comment], Int), project: Project) {
    let (replies, totalCount) = repliesAndTotalCount

    // Clear all but rootComment section.
    self.clearValues(section: Section.viewMoreRepliesError.rawValue)
    self.clearValues(section: Section.viewMoreReplies.rawValue)
    self.clearValues(section: Section.empty.rawValue)
    self.clearValues(section: Section.error.rawValue)

    self.padValuesForSection(Section.replies.rawValue)

    let current = (self[section: Section.replies.rawValue] as? [(comment: Comment, project: Project)]) ?? []

    self.clearValues(section: Section.replies.rawValue)

    let newReplies = replies.map { reply in
      (reply, project)
    }

    let allReplies = newReplies + current

    allReplies.forEach { reply, project in
      self.loadValue(reply, project: project)
    }

    // Add ViewMoreRepliesCell to the top if the totalCount from the response is larger than the current count.
    if totalCount > allReplies.count {
      self.set(
        values: [()],
        cellClass: ViewMoreRepliesCell.self,
        inSection: Section.viewMoreReplies.rawValue
      )
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CommentCell, value as (Comment, Project)):
      cell.configureWith(value: value)
    case let (cell as CommentPostFailedCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as CommentRemovedCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as CommentViewMoreRepliesFailedCell, _):
      cell.configureWith(value: ())
    case let (cell as RootCommentCell, value as Comment):
      cell.configureWith(value: value)
    case let (cell as ViewMoreRepliesCell, _):
      cell.configureWith(value: ())
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

  /**
   Returns an `IndexPath?` if the given replyId exists in the dataSource

   - parameter for: The replyId of a `Comment`.

   - returns: The `IndexPath?`with the matching replyId.

   */
  public func index(for replyId: String) -> IndexPath? {
    let commentIndex = self.items(in: Section.replies.rawValue).firstIndex { value in
      let foundAsCommentCell = (value as? (value: (Comment, Project), reusableId: String))?.value.0
        .id == replyId
      return foundAsCommentCell
    }

    if let commentIndex = commentIndex {
      return IndexPath(row: commentIndex, section: Section.replies.rawValue)
    }

    return nil
  }

  /**
   Returns `true` when  the `replies`section of the data source is empty.

   - parameter in: `UITableView` object that we need the number of sections from.

   - returns: A  `Bool` which is only true if the number of items in the `replies` section is 0.
   */
  public func isRepliesSectionEmpty(in tableView: UITableView) -> Bool {
    if self.numberOfSections(in: tableView) > Section.replies.rawValue {
      return self.numberOfItems(in: Section.replies.rawValue) == 0
    }
    return true
  }

  /**
   Returns `true` when  the `IndexPath`provided is from `Section.viewMoreReplies` or `Section.viewMoreRepliesError`.

   - parameter indexPath: `IndexPath` object that we need the `Section` value from.

   - returns: A  `Bool` which is only true if the section is either `viewMoreReplies` or `viewMoreRepliesError`.
   */
  public func sectionForViewMoreReplies(_ indexPath: IndexPath) -> Bool {
    switch indexPath.section {
    case Section.viewMoreReplies.rawValue, Section.viewMoreRepliesError.rawValue:
      return true
    default:
      return false
    }
  }

  /**
   Returns `true` when  the `IndexPath`provided is from `Section.replies`

   - parameter indexPath: `IndexPath` object that we need the `Section` value from.

   - returns: A  `Bool` which is only true is the section is `replies`
   */
  public func sectionForReplies(_ indexPath: IndexPath) -> Bool {
    return indexPath.section == Section.replies.rawValue
  }

  /// When this function is called we clear the `viewMoreReplies` section and set a `CommentViewMoreRepliesFailedCell` in the `viewMoreRepliesError` section of the data source.
  public func showPaginationErrorState() {
    self.clearValues(section: Section.viewMoreReplies.rawValue)

    self.set(
      values: [()],
      cellClass: CommentViewMoreRepliesFailedCell.self,
      inSection: Section.viewMoreRepliesError.rawValue
    )
  }
}
