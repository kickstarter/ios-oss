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
        $0.forEach { self?.dataSource.appendRow(value: $0,
                                                cellClass: LiveStreamChatMessageCell.self,
                                                toSection: Section.messages.rawValue)
        }
        
        self?.tableView.reloadData()
    }
  }

  internal func received(chatMessages: [LiveStreamChatMessage]) {
    self.viewModel.inputs.received(chatMessages: chatMessages)
  }
}
