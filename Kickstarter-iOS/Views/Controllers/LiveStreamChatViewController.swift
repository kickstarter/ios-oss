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

internal final class LiveStreamChatViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var chatInputViewContainer: UIView!
  @IBOutlet private weak var chatInputViewContainerBottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var chatInputViewContainerHeightConstraint: NSLayoutConstraint!

  fileprivate let dataSource = LiveStreamChatDataSource()
  fileprivate weak var liveStreamChatHandler: LiveStreamChatHandler?
  fileprivate let viewModel: LiveStreamChatViewModelType = LiveStreamChatViewModel()

  public static func configuredWith(liveStreamChatHandler: LiveStreamChatHandler) ->
    LiveStreamChatViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamChatViewController.self)
      vc.liveStreamChatHandler = liveStreamChatHandler

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

  internal override func bindViewModel() {
    super.bindViewModel()

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
  }

  private lazy var liveStreamChatInputView: LiveStreamChatInputView = {
    let chatInputView = LiveStreamChatInputView.fromNib()
    chatInputView.translatesAutoresizingMaskIntoConstraints = false
    chatInputView.configureWith(delegate: self)
    return chatInputView
  }()

  fileprivate func openLoginTout(loginIntent: LoginIntent) {
    let vc = LoginToutViewController.configuredWith(loginIntent: loginIntent)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }
}

extension LiveStreamChatViewController: LiveStreamChatInputViewDelegate {
  func liveStreamChatInputViewDidTapMoreButton(chatInputView: LiveStreamChatInputView) {

  }

  func liveStreamChatInputViewDidSend(chatInputView: LiveStreamChatInputView, message: String) {
    self.liveStreamChatHandler?.sendChatMessage(message: message)
  }

  func liveStreamChatInputViewRequestedLogin(chatInputView: LiveStreamChatInputView) {
    self.viewModel.inputs.chatInputViewRequestedLogin()
  }
}
