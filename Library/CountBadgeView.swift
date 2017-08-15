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
    self.bindStyles()
  }

  public override func bindStyles() {
    let required = UILayoutPriorityRequired

    _ = self
      |> roundedStyle(cornerRadius: floor(self.bounds.size.height / 2.0))
      |> CountBadgeView.lens.backgroundColor .~ .ksr_navy_400
      |> CountBadgeView.lens.layoutMargins .~ .init(topBottom: 4.0, leftRight: 8.0)
      |> CountBadgeView.lens.contentHuggingPriorityForAxis(.horizontal) .~ required
      |> CountBadgeView.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ required
      |> CountBadgeView.lens.translatesAutoresizingMaskIntoConstraints .~ false

    _ = self.label
      |> UILabel.lens.font .~ .ksr_footnote()
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.contentHuggingPriorityForAxis(.horizontal) .~ required
      |> UILabel.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ required
      |> UILabel.lens.translatesAutoresizingMaskIntoConstraints .~ false
  }
}
