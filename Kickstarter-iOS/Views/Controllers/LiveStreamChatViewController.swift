import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

fileprivate enum Section: Int {
  case messages
}

internal protocol LiveStreamChatViewControllerDelegate: class {
  func willPresentMoreMenuViewController(controller: LiveStreamChatViewController,
                                         moreMenuViewController: LiveStreamContainerMoreMenuViewController)
  func willDismissMoreMenuViewController(controller: LiveStreamChatViewController,
                                         moreMenuViewController: LiveStreamContainerMoreMenuViewController)
}

internal final class LiveStreamChatViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var chatInputViewContainer: UIView!
  @IBOutlet private weak var chatInputViewContainerBottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var chatInputViewContainerHeightConstraint: NSLayoutConstraint!

  fileprivate let dataSource = LiveStreamChatDataSource()
  fileprivate weak var delegate: LiveStreamChatViewControllerDelegate?
  fileprivate weak var liveStreamChatHandler: LiveStreamChatHandler?
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let viewModel: LiveStreamChatViewModelType = LiveStreamChatViewModel()

  public static func configuredWith(
    delegate: LiveStreamChatViewControllerDelegate,
    project: Project,
    liveStreamEvent: LiveStreamEvent,
    liveStreamChatHandler: LiveStreamChatHandler) ->
    LiveStreamChatViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamChatViewController.self)
      vc.delegate = delegate
      vc.liveStreamChatHandler = liveStreamChatHandler
      vc.viewModel.inputs.configureWith(project: project, liveStreamEvent: liveStreamEvent, chatHidden: false)
      vc.shareViewModel.inputs.configureWith(shareContext: .liveStream(project, liveStreamEvent))

      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource
    self.tableView.keyboardDismissMode = .interactive

    self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

    self.chatInputViewContainer.addSubview(self.liveStreamChatInputView)

    NSLayoutConstraint.activate([
      self.liveStreamChatInputView.leftAnchor.constraint(equalTo: self.chatInputViewContainer.leftAnchor),
      self.liveStreamChatInputView.topAnchor.constraint(equalTo: self.chatInputViewContainer.topAnchor),
      self.liveStreamChatInputView.bottomAnchor.constraint(equalTo: self.chatInputViewContainer.bottomAnchor),
      self.liveStreamChatInputView.rightAnchor.constraint(equalTo: self.chatInputViewContainer.rightAnchor)
      ])

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .hex(0x353535)

    _ = self.tableView
      |> UITableView.lens.backgroundColor .~ .hex(0x353535)
      |> UITableView.lens.separatorStyle .~ .none
      |> UITableView.lens.rowHeight .~ UITableViewAutomaticDimension
      |> UITableView.lens.estimatedRowHeight .~ 200

    self.chatInputViewContainerHeightConstraint.constant = Styles.grid(8)
  }

  //swiftlint:disable:next function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    _ = self.liveStreamChatHandler?.chatMessages.observeValues { [weak self] in
      self?.viewModel.inputs.received(chatMessages: $0)
    }

    self.viewModel.outputs.prependChatMessagesToDataSource
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        let indexPaths = $0.map {
          _self.dataSource.prependRow(value: $0, cellClass:
            LiveStreamChatMessageCell.self, toSection: Section.messages.rawValue)
        }

        if !indexPaths.isEmpty {
          if indexPaths.count > 5 {
            self?.tableView.reloadData()

          } else {
            _self.tableView.beginUpdates()
            if _self.tableView.numberOfSections == 0 {
              _self.tableView.insertSections(IndexSet(integer: Section.messages.rawValue), with: .none)
            }
            _self.tableView.insertRows(at: indexPaths, with: .top)
            _self.tableView.endUpdates()
          }
        }
    }

    self.viewModel.outputs.openLoginToutViewController
      .observeForControllerAction()
      .observeValues {
        self.openLoginTout(loginIntent: $0)
    }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        if change.notificationName == .UIKeyboardWillShow {
          self?.chatInputViewContainerBottomConstraint.constant = change.frame.height
        } else {
          self?.chatInputViewContainerBottomConstraint.constant = 0
        }

        UIView.animate(withDuration: change.duration, delay: 0,
                       options: change.options, animations: {
                        self?.view.layoutIfNeeded()
        }, completion: nil)
    }

    self.viewModel.outputs.presentMoreMenuViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.presentMoreMenu(liveStreamEvent: $0, chatHidden: $1)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showShareSheet(controller: $0) }

    self.viewModel.outputs.shouldHideChatTableView
      .observeForUI()
      .observeValues { [weak self] in
        self?.tableView.alpha = $0 ? 0 : 1
        self?.liveStreamChatInputView.didSetChatHidden(hidden: $0)
    }

    self.viewModel.outputs.updateLiveAuthTokenInEnvironment
      .observeValues {
        AppEnvironment.updateLiveAuthToken($0)
    }

    self.viewModel.outputs.configureChatHandlerWithUserInfo
      .observeValues { [weak self] in
        self?.liveStreamChatHandler?.configureChatUserInfo(info: $0)
    }
  }

  private lazy var liveStreamChatInputView: LiveStreamChatInputView = {
    let chatInputView = LiveStreamChatInputView.fromNib()
    chatInputView.translatesAutoresizingMaskIntoConstraints = false
    chatInputView.configureWith(delegate: self, chatHidden: false)
    return chatInputView
  }()

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(activityType: activityType,
                    completed: completed,
                    returnedItems: returnedItems,
                    activityError: error)
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.present(controller, animated: true, completion: nil)

    } else {
      self.present(controller, animated: true, completion: nil)
    }
  }

  private func presentMoreMenu(liveStreamEvent: LiveStreamEvent, chatHidden: Bool) {
    let vc = LiveStreamContainerMoreMenuViewController.configuredWith(
      liveStreamEvent: liveStreamEvent,
      delegate: self,
      chatHidden: chatHidden
    )
    vc.modalPresentationStyle = .overCurrentContext

    self.delegate?.willPresentMoreMenuViewController(controller: self, moreMenuViewController: vc)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func openLoginTout(loginIntent: LoginIntent) {
    let vc = LoginToutViewController.configuredWith(loginIntent: loginIntent)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }
}

extension LiveStreamChatViewController: LiveStreamChatInputViewDelegate {
  func liveStreamChatInputViewDidTapMoreButton(chatInputView: LiveStreamChatInputView) {
    self.viewModel.inputs.moreMenuButtonTapped()
  }

  func liveStreamChatInputViewDidSend(chatInputView: LiveStreamChatInputView, message: String) {
    self.liveStreamChatHandler?.sendChatMessage(message: message)
  }

  func liveStreamChatInputViewRequestedLogin(chatInputView: LiveStreamChatInputView) {
    self.viewModel.inputs.chatInputViewRequestedLogin()
  }
}

extension LiveStreamChatViewController: LiveStreamContainerMoreMenuViewControllerDelegate {
  func moreMenuViewControllerWillDismiss(controller: LiveStreamContainerMoreMenuViewController) {
    self.delegate?.willDismissMoreMenuViewController(controller: self, moreMenuViewController: controller)
    self.dismiss(animated: true)
  }

  func moreMenuViewControllerDidSetChatHidden(controller: LiveStreamContainerMoreMenuViewController,
                                              hidden: Bool) {
    self.delegate?.willDismissMoreMenuViewController(controller: self, moreMenuViewController: controller)
    self.dismiss(animated: true) {
      self.viewModel.inputs.didSetChatHidden(hidden: hidden)
    }
  }

  func moreMenuViewControllerDidShare(controller: LiveStreamContainerMoreMenuViewController,
                                      liveStreamEvent: LiveStreamEvent) {
    self.delegate?.willDismissMoreMenuViewController(controller: self, moreMenuViewController: controller)
    self.dismiss(animated: true) {
      self.shareViewModel.inputs.shareButtonTapped()
    }
  }
}
