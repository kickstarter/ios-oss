import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

internal protocol LiveStreamContainerMoreMenuViewControllerDelegate: class {
  func moreMenuViewControllerWillDismiss(controller: LiveStreamContainerMoreMenuViewController)
}

internal final class LiveStreamContainerMoreMenuViewController: UITableViewController {
  private let dataSource = LiveStreamContainerMoreMenuDataSource()
  private let viewModel: LiveStreamContainerMoreMenuViewModelType = LiveStreamContainerMoreMenuViewModel()

  private weak var delegate: LiveStreamContainerMoreMenuViewControllerDelegate?

  internal static func configuredWith(liveStreamEvent: LiveStreamEvent,
                                      delegate: LiveStreamContainerMoreMenuViewControllerDelegate,
                                      chatHidden: Bool) -> LiveStreamContainerMoreMenuViewController {
    let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerMoreMenuViewController.self)
    vc.viewModel.inputs.configureWith(liveStreamEvent: liveStreamEvent, chatHidden: chatHidden)
    vc.delegate = delegate

    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource
    self.tableView.isScrollEnabled = false
    self.automaticallyAdjustsScrollViewInsets = false

    let emptyFooterView = UIView(frame: CGRect())
    self.tableView.tableFooterView = emptyFooterView

    self.viewModel.inputs.viewDidLoad()
  }

  internal override var prefersStatusBarHidden: Bool {
    return true
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)
      |> UITableViewController.lens.tableView.separatorStyle .~ .singleLine
      |> UITableViewController.lens.view.backgroundColor .~ .clear

    self.tableView.separatorColor = UIColor.white.withAlphaComponent(0.8)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadDataSource
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(items: $0)
        self?.tableView.reloadData()

        self?.pinToBottom()
    }
  }

  private func pinToBottom() {
    let contentHeight = self.tableView.visibleCells.reduce(0, { (accum, cell) -> CGFloat in
      accum + cell.systemLayoutSizeFitting(
        CGSize(width: self.tableView.frame.size.width, height: 9999)).height
    })

    self.tableView.contentInset = UIEdgeInsets(
      top: self.tableView.frame.size.height - contentHeight
    )
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let menuItem = self.dataSource[indexPath] as? LiveStreamContainerMoreMenuItem {
      switch menuItem {
      case .cancel:
        self.delegate?.moreMenuViewControllerWillDismiss(controller: self)
      default:
        return
      }
    }
  }
}
