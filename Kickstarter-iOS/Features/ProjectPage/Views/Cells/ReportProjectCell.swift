import Library
import SwiftUI
import UIKit

internal final class ReportProjectCell: UITableViewCell, ValueCell {
  var configuredWithCalled = false

  internal func configureWith(value projectFlagged: Bool) {
    self.setupReportProjectLabelView(projectFlagged: projectFlagged)

    self.selectionStyle = .none
    self.setNeedsLayout()
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
  }

  private func setupReportProjectLabelView(projectFlagged: Bool) {
    /** FIXME: ReportProjectLabelView (SwiftUI View) re-renders when its text labels contain hyperlinks. Since we're rendering hyperlinks with the helper in Text+HTML.swift, this seems to cause a `precondition failure: cyclic graph` crash. This check prevents that by making sure the cell is only configured once on dequeue.
     */
    guard !self.configuredWithCalled else { return }

    self.configuredWithCalled = true

    if #available(iOS 15.0, *) {
      DispatchQueue.main.async {
        let hostingController = UIHostingController(rootView: ReportProjectLabelView(flagged: projectFlagged))

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        self.contentView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
          hostingController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
          hostingController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
          hostingController.view.leadingAnchor
            .constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
          hostingController.view.trailingAnchor
            .constraint(equalTo: self.contentView.trailingAnchor, constant: -12)
        ])
      }
    }
  }
}
