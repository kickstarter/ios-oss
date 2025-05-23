import Prelude
import Prelude_UIKit
import UIKit

public final class CountBadgeView: UIView {
  public let label: UILabel = UILabel()

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.addSubview(self.label)
    self.label.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
    self.label.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
    self.label.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
    self.label.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    let required = UILayoutPriority.required

    _ = self
      |> roundedStyle(cornerRadius: floor(self.bounds.size.height / 2.0))
      |> CountBadgeView.lens.backgroundColor .~ LegacyColors.ksr_support_300.uiColor()
      |> CountBadgeView.lens.layoutMargins .~ .init(topBottom: 4.0, leftRight: 8.0)
      |> CountBadgeView.lens.contentHuggingPriority(for: .horizontal) .~ required
      |> CountBadgeView.lens.contentCompressionResistancePriority(for: .horizontal) .~ required
      |> CountBadgeView.lens.translatesAutoresizingMaskIntoConstraints .~ false

    _ = self.label
      |> UILabel.lens.font .~ .ksr_footnote()
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
      |> UILabel.lens.contentHuggingPriority(for: .horizontal) .~ required
      |> UILabel.lens.contentCompressionResistancePriority(for: .horizontal) .~ required
      |> UILabel.lens.translatesAutoresizingMaskIntoConstraints .~ false
  }
}
