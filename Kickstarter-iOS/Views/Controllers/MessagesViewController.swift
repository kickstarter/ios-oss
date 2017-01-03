import KsApi
import Library
import Prelude
import UIKit

internal final class MessagesViewController: UITableViewController {
  @IBOutlet private weak var replyBarButtonItem: UIBarButtonItem!

  private let viewModel: MessagesViewModelType = MessagesViewModel()
  private let dataSource = MessagesDataSource()

  internal static func configuredWith(messageThread messageThread: MessageThread) -> MessagesViewController {
    let vc = instantiate()
    vc.viewModel.inputs.configureWith(data: .left(messageThread))
    return vc
  }

  internal static func configuredWith(project project: Project, backing: Backing) -> MessagesViewController {
    let vc = instantiate()
    vc.viewModel.inputs.configureWith(data: .right((project: project, backing: backing)))
    return vc
  }

  private static func instantiate() -> MessagesViewController {
    return Storyboard.Messages.instantiate(MessagesViewController)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.replyBarButtonItem
      |> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_reply() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.project
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dataSource.load(project: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.backingAndProject
      .observeForControllerAction()
      .observeNext { [weak self] backing, project in
        self?.dataSource.load(backing: backing, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.messages
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dataSource.load(messages: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.presentMessageDialog
      .observeForControllerAction()
      .observeNext { [weak self] messageThread, context in
        self?.presentMessageDialog(messageThread: messageThread, context: context)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeNext { [weak self] project, refTag in self?.goTo(project: project, refTag: refTag) }

    self.viewModel.outputs.goToBacking
      .observeForControllerAction()
      .observeNext { [weak self] project, user in self?.goToBacking(project: project, user: user)}
  }

  internal override func tableView(tableView: UITableView,
                                   estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if self.dataSource.isProjectBanner(indexPath: indexPath) {
      self.viewModel.inputs.projectBannerTapped()
    } else if self.dataSource.isBackingInfo(indexPath: indexPath) {
      self.viewModel.inputs.backingInfoPressed()
    }
  }

  internal override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = cell as? BackingCell where cell.delegate == nil {
      cell.delegate = self
    }
  }

  @IBAction private func replyButtonPressed() {
    self.viewModel.inputs.replyButtonPressed()
  }

  private func presentMessageDialog(messageThread messageThread: MessageThread,
                                                  context: Koala.MessageDialogContext) {
    let dialog = MessageDialogViewController
      .configuredWith(messageSubject: .messageThread(messageThread), context: context)
    dialog.modalPresentationStyle = .FormSheet
    dialog.delegate = self
    self.presentViewController(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
  }

  private func goTo(project project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func goToBacking(project project: Project, user: User) {
    let vc = BackingViewController.configuredWith(project: project, backer: user)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension MessagesViewController: MessageDialogViewControllerDelegate {

  internal func messageDialogWantsDismissal(dialog: MessageDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func messageDialog(dialog: MessageDialogViewController, postedMessage message: Message) {
    self.viewModel.inputs.messageSent(message)
  }
}

extension MessagesViewController: BackingCellDelegate {
  func backingCellGoToBackingInfo() {
    self.viewModel.inputs.backingInfoPressed()
  }
}
