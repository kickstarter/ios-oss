import Library
import Prelude
import SwiftUI
import UIKit

internal final class ReportProjectCell: UITableViewCell, ValueCell {
  internal func configureWith(value projectFlagged: Bool) {
    self.setupTableViewCellStyle(projectFlagged: projectFlagged)
    self.setupReportProjectLabelView(projectFlagged: projectFlagged)
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    self.setNeedsLayout()
  }

  // MARK: - Private Methods

  private func setupTableViewCellStyle(projectFlagged: Bool) {
    let accessibilityTraits = projectFlagged
      ? UIAccessibilityTraits.staticText
      : UIAccessibilityTraits.button

    _ = self
      |> baseTableViewCellStyle()
      |> ReportProjectCell.lens.accessibilityTraits .~ accessibilityTraits
      |> ReportProjectCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.gridHalf(5), leftRight: Styles.grid(16))
          : .init(topBottom: Styles.gridHalf(5), leftRight: Styles.gridHalf(7))
      }
  }

  private func setupReportProjectLabelView(projectFlagged: Bool) {
    if #available(iOS 15.0, *) {
      DispatchQueue.main.async {
        let hostingController =
          UIHostingController(rootView: ReportProjectLabelView(flagged: projectFlagged))

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        self.contentView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
          hostingController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
          hostingController.view.bottomAnchor
            .constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
          hostingController.view.leadingAnchor
            .constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
          hostingController.view.trailingAnchor
            .constraint(equalTo: self.contentView.trailingAnchor, constant: -12)
        ])
      }
    }
  }
}
