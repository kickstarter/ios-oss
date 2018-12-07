import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

internal final class LiveStreamChatViewController: UIViewController {

  @IBOutlet private weak var chatInputView: UIView!
  @IBOutlet private weak var chatInputViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var chatInputViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var chatInputViewMessageLengthCountLabelStackView: UIStackView!
  @IBOutlet private weak var chatInputViewMessageLengthCountLabel: UILabel!
  @IBOutlet private weak var chatInputViewStackView: UIStackView!
  @IBOutlet private weak var sendButton: UIButton!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var textField: UITextField!

  fileprivate let dataSource = LiveStreamChatDataSource()
  private var deviceOrientationChangedObserver: Any?
  private var sessionStartedObserver: Any?
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()
  internal let viewModel: LiveStreamChatViewModelType = LiveStreamChatViewModel()

  public static func configuredWith(project: Project, liveStreamEvent: LiveStreamEvent)
    -> LiveStreamChatViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamChatViewController.self)
      vc.viewModel.inputs.configureWith(project: project, liveStreamEvent: liveStreamEvent)
      vc.shareViewModel.inputs.configureWith(shareContext: .liveStream(project, liveStreamEvent),
                                             shareContextView: nil)

      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource
    self.tableView.keyboardDismissMode = .onDrag
    self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.deviceOrientationChangedObserver = NotificationCenter.default
      .addObserver(forName: UIDevice.orientationDidChangeNotification,
                   object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.deviceOrientationDidChange(
          orientation: UIApplication.shared.statusBarOrientation
        )
    }

    self.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    self.textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.deviceOrientationChangedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseLiveStreamControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .ksr_soft_black

    _ = self.tableView
      |> UITableView.lens.backgroundColor .~ .ksr_soft_black
      |> UITableView.lens.separatorStyle .~ .none
      |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
      |> UITableView.lens.estimatedRowHeight .~ 200

    self.tableView.contentInset = .init(topBottom: Styles.grid(1))

    _ = self.chatInputView
      |> UIView.lens.backgroundColor .~ .ksr_soft_black

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.2)

    _ = self.chatInputViewMessageLengthCountLabel
      |> UILabel.lens.font .~ UIFont.ksr_body(size: 10).monospaced

    _ = self.chatInputViewMessageLengthCountLabelStackView
      |> UIStackView.lens.layoutMargins .~ .init(top: Styles.gridHalf(1))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.chatInputViewStackView
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.textField
      |> UITextField.lens.backgroundColor .~ .ksr_soft_black
      |> UITextField.lens.tintColor .~ .white
      |> UITextField.lens.textColor .~ .white
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.borderStyle .~ .none
      |> UITextField.lens.returnKeyType .~ .done
      |> UITextField.lens.autocapitalizationType .~ .sentences

    _ = self.sendButton
      |> UIButton.lens.tintColor .~ .white
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Send() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.prependChatMessagesToDataSourceAndReload
      .observeForUI()
      .observeValues { [weak self] chatMessages, reload in
        let indexPathsInserted = self?.dataSource.add(chatMessages: chatMessages) ?? []
        self?.insert(indexPathsInserted, andReload: reload)
    }

    self.viewModel.outputs.presentLoginToutViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.presentLoginTout(loginIntent: $0)
    }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        if change.notificationName == UIResponder.keyboardWillShowNotification {
          self?.chatInputViewBottomConstraint.constant = change.frame.height
        } else {
          self?.chatInputViewBottomConstraint.constant = 0
        }

        UIView.animate(withDuration: change.duration, delay: 0,
                       options: change.options, animations: {
                        self?.view.layoutIfNeeded()
        }, completion: nil)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller: controller) }

    self.viewModel.outputs.dismissKeyboard
      .observeForUI()
      .observeValues { [weak self] in
        self?.view.endEditing(true)
    }

    self.viewModel.outputs.collapseChatInputView
      .observeForUI()
      .observeValues { [weak self] in
        self?.chatInputViewHeightConstraint.constant = $0 ? 0 : Styles.grid(8)
    }

    self.viewModel.outputs.showErrorAlert
      .observeForUI()
      .observeValues { [weak self] in
        self?.present(UIAlertController.genericError($0), animated: true, completion: nil)
    }

    self.sendButton.rac.enabled = self.viewModel.outputs.sendButtonEnabled

    self.viewModel.outputs.clearTextFieldAndResignFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.textField.text = nil
        self?.textField.resignFirstResponder()
    }

    self.textField.rac.attributedPlaceholder = self.viewModel.outputs.chatInputViewPlaceholderText

    self.chatInputViewMessageLengthCountLabel.rac.text =
      self.viewModel.outputs.chatInputViewMessageLengthCountLabelText

    self.chatInputViewMessageLengthCountLabel.rac.textColor =
      self.viewModel.outputs.chatInputViewMessageLengthCountLabelTextColor
  }

  // MARK: Actions

  @objc private func sendButtonTapped() {
    self.viewModel.inputs.sendButtonTapped()
  }

  @objc private func textFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.textDidChange(toText: textField.text)
  }

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
      self?.shareViewModel.inputs.shareActivityCompletion(with: .init(activityType: activityType,
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

  private func insert(_ indexPaths: [IndexPath], andReload reload: Bool) {
    guard reload == false else {
      self.tableView.reloadData()
      return
    }

    guard let section = indexPaths.first?.section else { return }

    self.tableView.beginUpdates()
    defer { self.tableView.endUpdates() }

    if self.tableView.numberOfSections == 0 {
      self.tableView.insertSections(IndexSet(integer: section), with: .none)
    }

    self.tableView.insertRows(at: indexPaths, with: .top)
  }

  fileprivate func presentLoginTout(loginIntent: LoginIntent) {
    let vc = LoginToutViewController.configuredWith(loginIntent: loginIntent)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }
}

extension LiveStreamChatViewController: UITextFieldDelegate {

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return self.viewModel.inputs.textFieldShouldBeginEditing()
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()

    return true
  }
}
