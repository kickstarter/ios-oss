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

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)
      |> UIViewController.lens.view.backgroundColor .~ UIColor.hex(0x353535)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.appendChatMessagesToDataSource
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        let indexPaths = $0.map {
          _self.dataSource.appendRow(value: $0, cellClass:
            LiveStreamChatMessageCell.self, toSection: Section.messages.rawValue)
        }

        if !indexPaths.isEmpty {
          if indexPaths.count > 5 {
            self?.tableView.reloadData()

            indexPaths.last.flatMap { self?.tableView.scrollToRow(at: $0, at: .top, animated: false) }
          } else {
            _self.tableView.beginUpdates()
            if _self.tableView.numberOfSections == 0 {
              _self.tableView.insertSections(IndexSet(integer: Section.messages.rawValue), with: .none)
            }
            _self.tableView.insertRows(at: indexPaths, with: .bottom)
            _self.tableView.endUpdates()

            indexPaths.last.flatMap { self?.tableView.scrollToRow(at: $0, at: .top, animated: true) }
          }
        }
    }
  }

  internal func received(chatMessages: [LiveStreamChatMessage]) {
    self.viewModel.inputs.received(chatMessages: chatMessages)
  }
}
