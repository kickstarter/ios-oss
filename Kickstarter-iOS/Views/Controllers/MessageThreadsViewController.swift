import Library
import KsApi
import Prelude
import ReactiveCocoa
import UIKit

internal final class MessageThreadsViewController: UITableViewController {
  private let viewModel: MessageThreadsViewModelType = MessageThreadsViewModel()
  private let dataSource = MessageThreadsDataSource()

  @IBOutlet private weak var mailboxLabel: UILabel!
  @IBOutlet private weak var footerView: UIView!

  internal static func configuredWith(project project: Project?) -> MessageThreadsViewController {
    let vc = Storyboard.Messages.instantiate(MessageThreadsViewController)
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 100.0
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    self.mailboxLabel.rac.text = self.viewModel.outputs.mailboxName
    self.refreshControl?.rac.refreshing = self.viewModel.outputs.refreshControlEndRefreshing.mapConst(false)
    self.tableView.tableFooterView?.rac.hidden = self.viewModel.outputs.loadingFooterIsHidden

    self.viewModel.outputs.messageThreads
      .observeForControllerAction()
      .observeNext { [weak self] threads in
        self?.dataSource.load(messageThreads: threads)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.emptyStateIsVisible
      .observeForControllerAction()
      .observeNext { [weak self] isVisible in
        self?.dataSource.emptyState(isVisible: isVisible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showMailboxChooserActionSheet
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showMailboxChooserActionSheet() }

    self.viewModel.outputs.goToSearch
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToSearch() }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                                   forRowAtIndexPath indexPath: NSIndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(tableView: UITableView,
                                   didSelectRowAtIndexPath indexPath: NSIndexPath) {

    if let messageThread = self.dataSource[indexPath] as? MessageThread {
      let vc = MessagesViewController.configuredWith(messageThread: messageThread)
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func showMailboxChooserActionSheet() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

    alert.addAction(UIAlertAction(title: "Inbox", style: .Default) { [weak self] _ in
      self?.viewModel.inputs.switchTo(mailbox: .inbox)
    })
    alert.addAction(UIAlertAction(title: "Sent", style: .Default) { [weak self] _ in
      self?.viewModel.inputs.switchTo(mailbox: .sent)
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

    self.presentViewController(alert, animated: true, completion: nil)
  }

  @IBAction private func mailboxButtonPressed() {
    self.viewModel.inputs.mailboxButtonPressed()
  }

  @IBAction private func searchButtonPressed() {
    self.viewModel.inputs.searchButtonPressed()
  }

  @IBAction private func refresh() {
    self.viewModel.inputs.refresh()
  }

  private func goToSearch() {
    guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SearchMessagesViewController"),
      search = vc as? SearchMessagesViewController else {
        fatalError("Could not instantiate SearchMessagesViewController.")
    }

    self.navigationController?.pushViewController(search, animated: true)
  }
}
