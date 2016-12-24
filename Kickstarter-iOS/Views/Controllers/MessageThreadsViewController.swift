import Library
import KsApi
import Prelude
import ReactiveSwift
import UIKit

internal final class MessageThreadsViewController: UITableViewController {
  fileprivate let viewModel: MessageThreadsViewModelType = MessageThreadsViewModel()
  fileprivate let dataSource = MessageThreadsDataSource()

  @IBOutlet fileprivate weak var footerView: UIView!
  @IBOutlet fileprivate weak var mailboxLabel: UILabel!

  internal static func configuredWith(project: Project?) -> MessageThreadsViewController {
    let vc = Storyboard.Messages.instantiate(MessageThreadsViewController.self)
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

  internal override func bindStyles() {
    super.bindStyles()

    _ = self |> baseTableControllerStyle()

    _ = self.mailboxLabel
      |> UILabel.lens.font .~ UIFont.ksr_callout().bolded
      |> UILabel.lens.textColor .~ .ksr_navy_700
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.mailboxLabel.rac.text = self.viewModel.outputs.mailboxName
    self.navigationItem.rac.title = self.viewModel.outputs.mailboxName
    self.refreshControl?.rac.refreshing = self.viewModel.outputs.refreshControlEndRefreshing.mapConst(false)
    self.tableView.tableFooterView?.rac.hidden = self.viewModel.outputs.loadingFooterIsHidden

    self.viewModel.outputs.messageThreads
      .observeForControllerAction()
      .observeValues { [weak self] threads in
        self?.dataSource.load(messageThreads: threads)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.emptyStateIsVisible
      .observeForControllerAction()
      .observeValues { [weak self] isVisible in
        self?.dataSource.emptyState(isVisible: isVisible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showMailboxChooserActionSheet
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showMailboxChooserActionSheet() }

    self.viewModel.outputs.goToSearch
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToSearch() }
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                                   forRowAt indexPath: IndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(_ tableView: UITableView,
                                   didSelectRowAt indexPath: IndexPath) {

    if let messageThread = self.dataSource[indexPath] as? MessageThread {
      let vc = MessagesViewController.configuredWith(messageThread: messageThread)
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  fileprivate func showMailboxChooserActionSheet() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    alert.addAction(
      UIAlertAction(title: Strings.messages_navigation_inbox(), style: .default) { [weak self] _ in
        self?.viewModel.inputs.switchTo(mailbox: .inbox)
      }
    )

    alert.addAction(
      UIAlertAction(title: Strings.messages_navigation_sent(), style: .default) { [weak self] _ in
        self?.viewModel.inputs.switchTo(mailbox: .sent)
      }
    )

    alert.addAction(
      UIAlertAction(title: Strings.general_navigation_buttons_cancel(), style: .cancel, handler: nil)
    )

    if self.traitCollection.userInterfaceIdiom == .pad {
      alert.modalPresentationStyle = .popover
      let popover = alert.popoverPresentationController
      popover?.sourceView = self.mailboxLabel
      popover?.sourceRect = self.mailboxLabel.bounds
    }

    self.present(alert, animated: true, completion: nil)
  }

  @IBAction fileprivate func mailboxButtonPressed() {
    self.viewModel.inputs.mailboxButtonPressed()
  }

  @IBAction fileprivate func searchButtonPressed() {
    self.viewModel.inputs.searchButtonPressed()
  }

  @IBAction fileprivate func refresh() {
    self.viewModel.inputs.refresh()
  }

  fileprivate func goToSearch() {
    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchMessagesViewController"),
      let search = vc as? SearchMessagesViewController else {
        fatalError("Could not instantiate SearchMessagesViewController.")
    }

    self.navigationController?.pushViewController(search, animated: true)
  }
}
