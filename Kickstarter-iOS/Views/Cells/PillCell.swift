import Library
import Prelude
import UIKit

final class PillCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  private(set) lazy var label = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.label, self.contentView)
      |> ksr_addSubviewToParent()

    NSLayoutConstraint.activate([
      self.label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      self.label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.label
      |> pinLabelStyle
  }

  // MARK: - Configuration
  func configureWith(value: String) {
    _ = self.label
      |> \.text .~ value
  }
}

// MARK: - Styles

private let pinLabelStyle: LabelStyle = { label in
  label
    |> \.backgroundColor .~ UIColor.ksr_green_500.withAlphaComponent(0.06)
    |> \.font .~ UIFont.ksr_body(size: 13)
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_green_500
}
