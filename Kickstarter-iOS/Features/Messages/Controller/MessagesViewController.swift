import KsApi
import Library
import Prelude
import SwiftUI
import UIKit

internal final class MessagesViewController: UITableViewController, MessageBannerViewControllerPresenting {
  @IBOutlet fileprivate var replyBarButtonItem: UIBarButtonItem!

  fileprivate let viewModel: MessagesViewModelType = MessagesViewModel()
  fileprivate let dataSource = MessagesDataSource()

  public var messageBannerViewController: MessageBannerViewController?
  var dismissedAfterBlockingUserHandler: (() -> Void)?

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

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)
    self.messageBannerViewController?.delegate = self
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.updateTableViewBottomContentInset()
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

    self.viewModel.outputs.participantPreviouslyBlocked
      .observeForControllerAction()
      .observeValues { [weak self] isBlocked in
        guard let self, isBlocked == true else { return }

        self.messageBannerViewController?
          .showBanner(with: .error, message: Strings.This_user_has_been_blocked(), dismissType: .persist)
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

    self.viewModel.outputs.goToPledgeManagementViewPledge
      .observeForControllerAction()
      .observeValues { [weak self] url in self?.goToPMPledeView(with: url) }

    self.viewModel.outputs.didBlockUser
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let self, let messageBanner = self.messageBannerViewController else { return }

        messageBanner.showBanner(with: .success, message: Strings.Block_user_success())
      }

    self.viewModel.outputs.didBlockUserError
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let self, let messageBanner = self.messageBannerViewController else { return }

        messageBanner.showBanner(with: .error, message: Strings.Block_user_fail())
      }
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
    (cell as? BackingCell)?.delegate = self
    (cell as? MessageCell)?.delegate = self
  }

  @IBAction fileprivate func replyButtonPressed() {
    self.viewModel.inputs.replyButtonPressed()
  }

  fileprivate func presentMessageDialog(
    messageThread: MessageThread,
    context: KSRAnalytics.MessageDialogContext
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
    let projectParam = Either<Project, Param>(left: project)
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: projectParam,
      refInfo: RefInfo(refTag)
    )

    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToBacking(with params: ManagePledgeViewParamConfigData) {
    let vc = ManagePledgeViewController.controller(with: params)
    self.present(vc, animated: true)
  }

  fileprivate func goToPMPledeView(with url: URL) {
    let vc = PledgeManagementDetailsWebViewController.configured(with: url)
    self.present(vc, animated: true)
  }

  private func updateTableViewBottomContentInset() {
    if let messageBannerView = messageBannerViewController?.view {
      self.tableView.contentInset.bottom = messageBannerView.bounds.height
    }
  }

  private func presentBlockUserAlert(username: String, userId: Int) {
    let alert = UIAlertController
      .blockUserAlert(username: username, blockUserHandler: { _ in
        self.viewModel.inputs.blockUser(id: "\(userId)")
      })
    self.present(alert, animated: true)
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

// MARK: - BackingCellDelegate

extension MessagesViewController: BackingCellDelegate {
  func backingCellGoToBackingInfo() {
    self.viewModel.inputs.backingInfoPressed()
  }
}

// MARK: - MessageCellDelegate

extension MessagesViewController: MessageCellDelegate {
  func messageCellDidTapHeader(_ cell: MessageCell, _ user: User) {
    guard
      let currentUser = AppEnvironment.current.currentUser,
      currentUser != user,
      !user.isBlocked
    else {
      return
    }

    let actionSheet = UIAlertController
      .blockUserActionSheet(
        blockUserHandler: { _ in self.presentBlockUserAlert(username: user.name, userId: user.id) },
        sourceView: cell,
        isIPad: self.traitCollection.userInterfaceIdiom == .pad
      )

    self.present(actionSheet, animated: true)
  }
}

// MARK: - MessageBannerViewControllerDelegate

extension MessagesViewController: MessageBannerViewControllerDelegate {
  func messageBannerViewDidHide(type: MessageBannerType) {
    if type == .success {
      self.dismissedAfterBlockingUserHandler?()
      self.navigationController?.popViewController(animated: true)
    }
  }
}
