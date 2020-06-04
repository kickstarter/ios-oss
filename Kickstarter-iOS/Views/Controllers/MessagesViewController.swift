import KsApi
import Library
import Prelude
import UIKit

internal final class MessagesViewController: UITableViewController {
  @IBOutlet fileprivate var replyBarButtonItem: UIBarButtonItem!

  fileprivate let viewModel: MessagesViewModelType = MessagesViewModel()
  fileprivate let dataSource = MessagesDataSource()

  internal static func configuredWith(messageThread: MessageThread) -> MessagesViewController {
    let vc = self.instantiate()
    vc.viewModel.inputs.configureWith(data: .left(messageThread))
    return vc
  }

  internal static func configuredWith(project: Project, backing: Backing) -> MessagesViewController {
    let vc = self.instantiate()
    vc.viewModel.inputs.configureWith(data: .right((project: project, backing: backing)))
    return vc
  }

  fileprivate static func instantiate() -> MessagesViewController {
    return Storyboard.Messages.instantiate(MessagesViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.rowHeight = UITableView.automaticDimension
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

    self.replyBarButtonItem.rac.enabled = self.viewModel.outputs.replyButtonIsEnabled

    self.viewModel.outputs.emptyStateIsVisibleAndMessageToUser
      .observeForControllerAction()
      .observeValues { [weak self] isVisible, message in
        self?.dataSource.emptyState(isVisible: isVisible, messageToUser: message)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.project
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dataSource.load(project: $0)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.backingAndProjectAndIsFromBacking
      .observeForControllerAction()
      .observeValues { [weak self] backing, project, isFromBacking in
        self?.dataSource.load(backing: backing, project: project, isFromBacking: isFromBacking)
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
      .observeValues { [weak self] params in self?.goToBacking(with: params) }
  }

  internal override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath)
    -> CGFloat {
    return UITableView.automaticDimension
  }

  internal override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.dataSource.isProjectBanner(indexPath: indexPath) {
      self.viewModel.inputs.projectBannerTapped()
    } else if self.dataSource.isBackingInfo(indexPath: indexPath) {
      self.viewModel.inputs.backingInfoPressed()
    }
  }

  internal override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
    if let cell = cell as? BackingCell, cell.delegate == nil {
      cell.delegate = self
    }
  }

  @IBAction fileprivate func replyButtonPressed() {
    self.viewModel.inputs.replyButtonPressed()
  }

  fileprivate func presentMessageDialog(
    messageThread: MessageThread,
    context: Koala.MessageDialogContext
  ) {
    let dialog = MessageDialogViewController
      .configuredWith(messageSubject: .messageThread(messageThread), context: context)
    dialog.modalPresentationStyle = .formSheet
    dialog.delegate = self
    self.present(
      UINavigationController(rootViewController: dialog),
      animated: true,
      completion: nil
    )
  }

  fileprivate func goTo(project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    if UIDevice.current.userInterfaceIdiom == .pad {
      vc.modalPresentationStyle = .fullScreen
    }
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToBacking(with params: ManagePledgeViewParamConfigData) {
    let vc = ManagePledgeViewController.controller(with: params)
    self.present(vc, animated: true)
  }
}

extension MessagesViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage message: Message) {
    self.viewModel.inputs.messageSent(message)
  }
}

extension MessagesViewController: BackingCellDelegate {
  func backingCellGoToBackingInfo() {
    self.viewModel.inputs.backingInfoPressed()
  }
}
