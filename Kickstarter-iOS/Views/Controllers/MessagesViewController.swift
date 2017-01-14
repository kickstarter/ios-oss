import KsApi
import Library
import Prelude
import UIKit

internal final class MessagesViewController: UITableViewController {
  @IBOutlet fileprivate weak var replyBarButtonItem: UIBarButtonItem!

  fileprivate let viewModel: MessagesViewModelType = MessagesViewModel()
  fileprivate let dataSource = MessagesDataSource()

  internal static func configuredWith(messageThread: MessageThread) -> MessagesViewController {
    let vc = instantiate()
    vc.viewModel.inputs.configureWith(data: .left(messageThread))
    return vc
  }

  internal static func configuredWith(project: Project, backing: Backing) -> MessagesViewController {
    let vc = instantiate()
    vc.viewModel.inputs.configureWith(data: .right((project: project, backing: backing)))
    return vc
  }

  fileprivate static func instantiate() -> MessagesViewController {
    return Storyboard.Messages.instantiate()
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.replyBarButtonItem
      |> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_reply() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.project
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dataSource.load(project: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.backingAndProject
      .observeForControllerAction()
      .observeValues { [weak self] backing, project in
        self?.dataSource.load(backing: backing, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.messages
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dataSource.load(messages: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.presentMessageDialog
      .observeForControllerAction()
      .observeValues { [weak self] messageThread, context in
        self?.presentMessageDialog(messageThread: messageThread, context: context)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, refTag in self?.goTo(project: project, refTag: refTag) }

    self.viewModel.outputs.goToBacking
      .observeForControllerAction()
      .observeValues { [weak self] project, user in self?.goToBacking(project: project, user: user)}
  }

  internal override func tableView(_ tableView: UITableView,
                                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.dataSource.isProjectBanner(indexPath: indexPath) {
      self.viewModel.inputs.projectBannerTapped()
    } else if self.dataSource.isBackingInfo(indexPath: indexPath) {
      self.viewModel.inputs.backingInfoPressed()
    }
  }

  internal override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
    if let cell = cell as? BackingCell, cell.delegate == nil {
      cell.delegate = self
    }
  }

  @IBAction fileprivate func replyButtonPressed() {
    self.viewModel.inputs.replyButtonPressed()
  }

  @IBAction fileprivate func backingInfoButtonPressed() {
    self.viewModel.inputs.backingInfoPressed()
  }

  fileprivate func presentMessageDialog(messageThread: MessageThread,
                                                  context: Koala.MessageDialogContext) {
    let dialog = MessageDialogViewController
      .configuredWith(messageSubject: .messageThread(messageThread), context: context)
    dialog.modalPresentationStyle = .formSheet
    dialog.delegate = self
    self.present(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
  }

  fileprivate func goTo(project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToBacking(project: Project, user: User) {
    let vc = BackingViewController.configuredWith(project: project, backer: user)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension MessagesViewController: MessageDialogViewControllerDelegate {

  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_ dialog: MessageDialogViewController, postedMessage message: Message) {
    self.viewModel.inputs.messageSent(message)
  }
}

extension MessagesViewController: BackingCellDelegate {
  func backingCellGoToBackingInfo() {
    self.viewModel.inputs.backingInfoPressed()
  }
}
