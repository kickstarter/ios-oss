import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

internal final class LiveStreamContainerMoreMenuViewController: UITableViewController {
  private let dataSource = LiveStreamContainerMoreMenuDataSource()
  private let viewModel: LiveStreamContainerMoreMenuViewModelType = LiveStreamContainerMoreMenuViewModel()

  internal static func configuredWith(liveStreamEvent: LiveStreamEvent, chatHidden: Bool) ->
    LiveStreamContainerMoreMenuViewController {
      let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerMoreMenuViewController.self)
      vc.viewModel.inputs.configureWith(liveStreamEvent: liveStreamEvent, chatHidden: chatHidden)

      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource
    self.tableView.isScrollEnabled = false

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)
      |> UITableViewController.lens.tableView.separatorStyle .~ .singleLine

    self.tableView.separatorColor = UIColor.white.withAlphaComponent(0.8)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadDataSource
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(items: $0)

        self?.tableView.reloadData()
    }
  }

  private func offsetHeaderView() {
    let offset = self.tableView.contentSize.height -
      (self.tableView.frame.size.height + self.tableView.contentInset.bottom)
    self.tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
  }
}

extension LiveStreamContainerMoreMenuViewController {
  internal override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect())
    view.backgroundColor = .clear
    return view
  }

  internal override func tableView(_ tableView: UITableView,
                                   heightForHeaderInSection section: Int) -> CGFloat {
    return tableView.frame.size.height
  }
}
