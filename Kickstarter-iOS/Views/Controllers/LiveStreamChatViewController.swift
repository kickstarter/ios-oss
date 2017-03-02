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

internal final class LiveStreamChatViewController: UITableViewController {
  private let dataSource = LiveStreamChatDataSource()
  private let viewModel: LiveStreamChatViewModelType = LiveStreamChatViewModel()

  fileprivate weak var liveStreamChatHandler: LiveStreamChatHandler?

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

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.becomeFirstResponder()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)
      |> UIViewController.lens.view.backgroundColor .~ UIColor.hex(0x353535)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    _ = self.liveStreamChatHandler?.chatMessages.observeValues { [weak self] in
      self?.viewModel.inputs.received(chatMessages: $0)
    }

    self.viewModel.outputs.appendChatMessagesToDataSource
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        let indexPaths = $0.map {
          _self.dataSource.appendRow(value: $0, cellClass:
            LiveStreamChatMessageCell.self, toSection: Section.messages.rawValue)
        }

        //FIXME: try move scrolling to bottom to vm
        if !indexPaths.isEmpty {
          if indexPaths.count > 5 {
            self?.tableView.reloadData()

            indexPaths.last.flatMap { self?.tableView.scrollToRow(at: $0, at: .top, animated: false) }
          } else {
            let pinToBottom = self?.tableViewAtBottom()

            _self.tableView.beginUpdates()
            if _self.tableView.numberOfSections == 0 {
              _self.tableView.insertSections(IndexSet(integer: Section.messages.rawValue), with: .none)
            }
            _self.tableView.insertRows(at: indexPaths, with: .bottom)
            _self.tableView.endUpdates()

            if pinToBottom == .some(true) {
              indexPaths.last.flatMap { self?.tableView.scrollToRow(at: $0, at: .top, animated: true) }
            }
          }
        }
    }

    NotificationCenter.default
      .addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [weak self] _ in
        guard let _self = self else { return }
        _self.viewModel.inputs.deviceOrientationDidChange(
          orientation: UIApplication.shared.statusBarOrientation,
          currentIndexPaths: _self.tableView.indexPathsForVisibleRows.coalesceWith([])
        )
    }

    self.viewModel.outputs.scrollToIndexPaths
      .observeForUI()
      .observeValues { [weak self] _ in
        let lastIndexPath = self?.lastIndexPath()
        lastIndexPath.flatMap { self?.tableView.scrollToRow(at: $0, at: .top, animated: false) }
    }

    self.viewModel.outputs.reloadInputViews
      .observeForUI()
      .observeValues { [weak self] in
        self?.reloadInputViews()
    }

    //FIXME: move to VM
    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        if change.notificationName == .UIKeyboardWillShow && self?.isFirstResponder == .some(false) {
          guard
            let offset = self?.tableView.contentOffset,
            let contentInsetBottom = self?.tableView.contentInset.bottom
            else {
              return
          }

          UIView.animate(withDuration: change.duration) {
            self?.tableView.contentOffset =
              CGPoint(x: 0, y: offset.y + (change.frame.size.height - contentInsetBottom))
          }
        }
    }
  }

  internal override var inputAccessoryView: UIView? {
    guard
      let inputView = self.liveStreamChatInputView,
      self.shouldShowInputView else {
        return nil
    }
    return inputView
  }

  internal override var canBecomeFirstResponder: Bool {
    return true
  }

  internal var shouldShowInputView: Bool {
    return !self.traitCollection.isVerticallyCompact
  }

  private lazy var liveStreamChatInputView: LiveStreamChatInputView? = {
    let chatInputView = LiveStreamChatInputView.fromNib()
    chatInputView?.configureWith(delegate: self)
    chatInputView?.frame = .init(x: 0, y: 0, width: 60, height: Styles.grid(10))
    return chatInputView
  }()

  //FIXME: consider moving to VM
  private func tableViewAtBottom() -> Bool {
    if self.tableView.numberOfRows(inSection: Section.messages.rawValue) == 0 {
      return true
    }

    let lastIndexPath = self.lastIndexPath()

    return self.tableView.indexPathsForVisibleRows.map { indexPaths -> Bool in
      for indexPath in indexPaths {
        if indexPath.row == lastIndexPath.row {
          return true
        }
      }

      return false
      }
      .coalesceWith(false)
  }

  private func lastIndexPath() -> IndexPath {
    let lastIndex = self.tableView.numberOfRows(inSection: Section.messages.rawValue) - 1
    return IndexPath(row: lastIndex, section: Section.messages.rawValue)
  }
}

extension LiveStreamChatViewController: LiveStreamChatInputViewDelegate {
  func liveStreamChatInputViewDidTapMoreButton(chatInputView: LiveStreamChatInputView) {

  }

  func liveStreamChatInputViewDidSend(chatInputView: LiveStreamChatInputView, message: String) {
    self.liveStreamChatHandler?.sendChatMessage(message: message)
  }

  func liveStreamChatInputViewRequestedLogin(chatInputView: LiveStreamChatInputView) {
    //self.openLoginTout()
  }
}
