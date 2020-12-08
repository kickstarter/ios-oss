import Foundation
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public func baseTableControllerStyle<TVC: UITableViewControllerProtocol>
(estimatedRowHeight: CGFloat = 44.0) -> ((TVC) -> TVC) {
  let style = baseControllerStyle()
    <> TVC.lens.view.backgroundColor .~ .ksr_white
    <> TVC.lens.tableView.rowHeight .~ UITableView.automaticDimension
    <> TVC.lens.tableView.estimatedRowHeight .~ estimatedRowHeight

  return style <> TVC.lens.tableView.separatorStyle .~ .none
}

public func baseTableViewCellStyle<TVC: UITableViewCellProtocol>() -> ((TVC) -> TVC) {
  return
    TVC.lens.contentView.layoutMargins %~~ { _, cell in
      if cell.traitCollection.isRegularRegular {
        return .init(topBottom: Styles.grid(3), leftRight: Styles.grid(12))
      }
      return .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
    }
    <> TVC.lens.backgroundColor .~ .ksr_white
    <> (TVC.lens.contentView .. UIView.lens.preservesSuperviewLayoutMargins) .~ false
    <> TVC.lens.layoutMargins .~ .init(all: 0.0)
    <> TVC.lens.preservesSuperviewLayoutMargins .~ false
    <> TVC.lens.selectionStyle .~ .none
}

public let baseTableViewCellTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ .ksr_body()
}
