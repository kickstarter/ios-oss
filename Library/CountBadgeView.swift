import Prelude
import Prelude_UIKit
import UIKit

public final class CountBadgeView: UIView {
  public let label: UILabel = UILabel()

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.addSubview(self.label)
    self.label.topAnchor.constraintEqualToAnchor(self.layoutMarginsGuide.topAnchor).active = true
    self.label.leftAnchor.constraintEqualToAnchor(self.layoutMarginsGuide.leftAnchor).active = true
    self.label.bottomAnchor.constraintEqualToAnchor(self.layoutMarginsGuide.bottomAnchor).active = true
    self.label.rightAnchor.constraintEqualToAnchor(self.layoutMarginsGuide.rightAnchor).active = true
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    self.bindStyles()
  }

  public override func bindStyles() {
    let required = UILayoutPriorityRequired

    self
      |> roundedStyle(cornerRadius: floor(self.bounds.size.height / 2.0))
      |> CountBadgeView.lens.backgroundColor .~ .ksr_navy_400
      |> CountBadgeView.lens.layoutMargins .~ .init(topBottom: 4.0, leftRight: 8.0)
      |> CountBadgeView.lens.contentHuggingPriorityForAxis(.Horizontal) .~ required
      |> CountBadgeView.lens.contentCompressionResistancePriorityForAxis(.Horizontal) .~ required
      |> CountBadgeView.lens.translatesAutoresizingMaskIntoConstraints .~ false

    self.label
      |> UILabel.lens.font .~ .ksr_footnote()
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.contentHuggingPriorityForAxis(.Horizontal) .~ required
      |> UILabel.lens.contentCompressionResistancePriorityForAxis(.Horizontal) .~ required
      |> UILabel.lens.translatesAutoresizingMaskIntoConstraints .~ false
  }
}
