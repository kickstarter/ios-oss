import Library
import Prelude
import UIKit

final class CommentsErrorCell: UITableViewCell, ValueCell {
  
  private let rootStackView = UIStackView()
  private let iconImageView = UIImageView()
  private let messageLabel = UILabel()
  
  // MARK: - Lifecycle
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.bindStyles()
    self.configureViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Styles
  
  override func bindStyles() {
    super.bindStyles()
    
    _ = self |> baseTableViewCellStyle()
    
    _ = self.rootStackView
      |> \.axis .~ .vertical
      |> \.distribution .~ .fill
      |> \.alignment .~ .center
      |> \.spacing .~ Styles.grid(2)
    
    _ = self.messageLabel
      |> messageLabelStyle
    
    _ = self.iconImageView
      |> UIImageView.lens.image .~ Library.image(named: "icon--alert")
  }
  
  // MARK: - Configuration
  
  func configureWith(value: Void) {
    self.messageLabel.text = Strings.Something_went_wrong_pull_to_refresh()
  }
  
  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
    
    _ = ([self.iconImageView, self.messageLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}

// MARK: - Styles

private let messageLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_subhead()
    |> \.textAlignment .~ .center
    |> \.textColor .~ UIColor.ksr_support_700
}
