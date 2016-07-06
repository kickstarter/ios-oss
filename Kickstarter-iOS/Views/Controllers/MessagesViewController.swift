import Library
import KsApi
import UIKit

internal final class MessagesViewController: UITableViewController {
  private let viewModel: MessagesViewModelType = MessagesViewModel()
  private let dataSource = MessagesDataSource()

  internal func configureWith(messageThread messageThread: MessageThread) {
    self.viewModel.inputs.configureWith(data: .left(messageThread))
  }

  internal func configureWith(project project: Project, backing: Backing) {
    self.viewModel.inputs.configureWith(data: .right((project: project, backing: backing)))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    self.viewModel.outputs.project
      .observeForUI()
      .observeNext { [weak self] in
        self?.dataSource.load(project: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.backingAndProject
      .observeForUI()
      .observeNext { [weak self] backing, project in
        self?.dataSource.load(backing: backing, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.messages
      .observeForUI()
      .observeNext { [weak self] in
        self?.dataSource.load(messages: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.presentMessageDialog
      .observeForUI()
      .observeNext { [weak self] messageThread, context in
        self?.presentMessageDialog(messageThread: messageThread, context: context)
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
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
    guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MessageDialogViewController"),
      dialog = vc as? MessageDialogViewController else {
        fatalError("Could not instantiate MessageDialogViewController")
    }

    dialog.configureWith(messageThread: messageThread, context: context)
    dialog.modalPresentationStyle = .FormSheet
    dialog.delegate = self
    self.presentViewController(UINavigationController(rootViewController: dialog),
                               animated: true,
                               completion: nil)
  }

  private func goTo(project project: Project, refTag: RefTag) {
    guard let vc = UIStoryboard(name: "Project", bundle: .framework).instantiateInitialViewController(),
      projectVC = vc as? ProjectViewController else {
        fatalError("Could not instantiate ProjectViewController")
    }
    projectVC.configureWith(project: project, refTag: refTag)
    self.presentViewController(UINavigationController(rootViewController: projectVC),
                               animated: true,
                               completion: nil)
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
