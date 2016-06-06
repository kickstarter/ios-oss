import Library
import KsApi
import ReactiveExtensions
import UIKit

internal final class SearchMessagesViewController: UITableViewController {
  private let viewModel: MessagesSearchViewModelType = MessagesSearchViewModel()
  private let dataSource = SearchMessagesDataSource()

  @IBOutlet private weak var searchTextField: UITextField!
  @IBOutlet private weak var loadingView: UIActivityIndicatorView!

  internal func configureWith(project project: Project?) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 120.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.viewModel.inputs.viewWillDisappear()
  }

  internal override func bindViewModel() {
    self.searchTextField.rac.isFirstResponder = self.viewModel.outputs.showKeyboard
    self.loadingView.rac.animating = self.viewModel.outputs.isSearching

    self.viewModel.outputs.messageThreads
      .observeForUI()
      .observeNext { [weak self] messageThreads in
        self?.dataSource.load(messageThreads: messageThreads)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.emptyStateIsVisible
      .observeForUI()
      .observeNext { [weak self] isVisible in
        self?.dataSource.emptyState(isVisible: isVisible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToMessageThread
      .observeForUI()
      .observeNext { [weak self] in self?.goTo(messageThread: $0) }
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    if let messageThread = self.dataSource[indexPath] as? MessageThread {
      self.viewModel.inputs.tappedMessageThread(messageThread)
    }
  }

  private func goTo(messageThread messageThread: MessageThread) {

    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MessagesViewController")

    if let messages = vc as? MessagesViewController {

      messages.configureWith(messageThread: messageThread)
      self.navigationController?.pushViewController(messages, animated: true)
    }
  }

  @IBAction private func searchTextChanged(textField: UITextField) {
    self.viewModel.inputs.searchTextChanged(textField.text)
  }
}
