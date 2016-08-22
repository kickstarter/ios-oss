import Library
import KsApi
import UIKit

internal final class MessagesViewController: UITableViewController {
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

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
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
  }

  internal override func tableView(tableView: UITableView,
                                   estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if self.dataSource.isProjectBanner(indexPath: indexPath) {
      self.viewModel.inputs.projectBannerTapped()
    }
  }

  @IBAction private func replyButtonPressed() {
    self.viewModel.inputs.replyButtonPressed()
  }

  @IBAction private func backingInfoButtonPressed() {
    self.viewModel.inputs.backingInfoPressed()
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
    let vc = ProjectMagazineViewController.configuredWith(projectOrParam: .left(project), refTag: refTag)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
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
