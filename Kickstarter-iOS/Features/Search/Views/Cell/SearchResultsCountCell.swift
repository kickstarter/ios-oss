import Library
import UIKit

internal final class SearchResultsCountCell: UITableViewCell, ValueCell {
  fileprivate var titleLabel: UILabel

  override init(
    style: UITableViewCell.CellStyle,
    reuseIdentifier: String?
  ) {
    self.titleLabel = UILabel()
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.contentView.addSubview(self.titleLabel)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal func configureWith(value count: Int) {
    let formattedCount = Format.wholeNumber(count)
    
    //TODO: Use translated strings (see #31242)
    if count == 1 {
      self.titleLabel.text = "1 result"
    } else {
      self.titleLabel.text = "\(formattedCount) results"
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.selectionStyle = .none
    // FIXME: MBL-2423 this should be surfaceSecondary.
    self.backgroundColor = Colors.Background.surfacePrimary.adaptive()

    self.titleLabel.constrainViewToMargins(in: self.contentView)
    self.contentView.layoutMargins = UIEdgeInsets(all: 18.0)

    self.titleLabel.textColor = Colors.Text.secondary.adaptive()
    self.titleLabel.textAlignment = .center
    self.titleLabel.font = InterFont.bodyMD.font()
  }
}
