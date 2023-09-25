import Library
import SwiftUI
import UIKit

internal final class ReportProjectCell: UITableViewCell, ValueCell {
  let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad

  internal func configureWith(value projectFlagged: Bool) {
    self.setupReportProjectLabelView(projectFlagged: projectFlagged)

    self.selectionStyle = .none
    self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    self.setNeedsLayout()
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
  }

  private func setupReportProjectLabelView(projectFlagged: Bool) {
    if #available(iOS 15.0, *) {
      DispatchQueue.main.async {
        let hostingController = UIHostingController(rootView: ReportProjectLabelView(flagged: projectFlagged))

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        self.contentView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
          hostingController.view.topAnchor
            .constraint(equalTo: self.contentView.topAnchor, constant: self.isIpad ? Styles.grid(5) : 12),
          hostingController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
          hostingController.view.leadingAnchor
            .constraint(
              equalTo: self.contentView.leadingAnchor,
              constant: self.isIpad ? Styles.grid(16) : 12
            ),
          hostingController.view.trailingAnchor
            .constraint(
              equalTo: self.contentView.trailingAnchor,
              constant: self.isIpad ? -Styles.grid(16) : -12
            )
        ])
      }
    }
  }
}
