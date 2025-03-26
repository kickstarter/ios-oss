import Library
import UIKit

class FilterBadgeView<A: SortOption, B: FilterCategory>: UIView {
  // FIXME: MBL-2250
  // Wait! Before you add more pills, refactor this.
  // This should be more dynamically generated and have its own view model.
  // I just kept it simple for now, because it only has two buttons.
  public let sortButton = UIButton()
  public let categoryButton = UIButton()
  private let stackView = UIStackView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.stackView.addArrangedSubviews(self.sortButton, self.categoryButton)
    self.addSubview(self.stackView)

    self.setupConstraints()
    self.bindStyles()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupConstraints() {
    self.stackView.translatesAutoresizingMaskIntoConstraints = false
    self.categoryButton.translatesAutoresizingMaskIntoConstraints = false
    self.sortButton.translatesAutoresizingMaskIntoConstraints = false

    self.stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    self.stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    self.stackView.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor).isActive = true

    self.sortButton.widthAnchor.constraint(
      equalTo: self.sortButton.heightAnchor,
      multiplier: 1.0
    ).isActive = true

    self.categoryButton.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  override func bindStyles() {
    super.bindStyles()

    self.backgroundColor = Colors.Background.surfacePrimary.adaptive()
    self.sortButton.setBackgroundColor(.ksr_white, for: .normal)

    self.stackView.axis = .horizontal
    self.stackView.spacing = Styles.grid(1)
    self.stackView.layoutMargins =
      UIEdgeInsets(
        top: Styles.grid(1),
        left: self.traitCollection.horizontalSizeClass == .compact ? Constants
          .pillLeftInsetForIPhone : Constants.pillLeftInsetForIPad,
        bottom: Styles.grid(1),
        right: 0 // Align to the left, no padding on the right.
      )
    self.stackView.isLayoutMarginsRelativeArrangement = true

    let filter = UIImage(named: "icon-sort")?
      .withRenderingMode(.alwaysTemplate)

    let carat = UIImage(named: "arrow-down")?
      .withRenderingMode(.alwaysTemplate)

    var sortConfig = self.sortButton.configuration ?? UIButton.Configuration.plain()
    sortConfig.image = filter
    self.sortButton.configuration = sortConfig
    self.sortButton.tintColor = Colors.Text.primary.adaptive()

    var categoryConfig = self.categoryButton.configuration ?? UIButton.Configuration.plain()
    categoryConfig.imagePlacement = .trailing
    categoryConfig.image = carat
    categoryConfig.imagePadding = Styles.grid(1)
    self.categoryButton.configuration = categoryConfig
    self.categoryButton.tintColor = Colors.Text.primary.adaptive()

    self.updatePillRadius()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.updatePillRadius()
  }

  func updatePillRadius() {
    let buttonHeight = self.sortButton.bounds.size.height > 0 ?
      self.sortButton.bounds.size.height : Constants.defaultButtonHeight

    self.sortButton.layer.cornerRadius = buttonHeight / 2
    self.categoryButton.layer.cornerRadius = buttonHeight / 2
  }

  internal func setCategoryTitle(_ title: String) {
    let attributes = [NSAttributedString.Key.font: UIFont.ksr_headingMD()]
    let attributedString = NSAttributedString(string: title, attributes: attributes)
    self.categoryButton.setAttributedTitle(attributedString, for: .normal)
  }

  internal func highlightSortButton(_ isHighlighted: Bool) {
    self.highlight(button: self.sortButton, isHighlighted: isHighlighted)
  }

  internal func highlightCategoryButton(_ isHighlighted: Bool) {
    self.highlight(button: self.categoryButton, isHighlighted: isHighlighted)
  }

  private func highlight(button: UIButton, isHighlighted: Bool) {
    if isHighlighted {
      button.layer.borderWidth = 2.0
      button.layer.borderColor = Colors.Text.primary.adaptive().cgColor
    } else {
      button.layer.borderWidth = 1.0
      button.layer.borderColor = Colors.Border.bold.adaptive().cgColor
    }
  }
}

private enum Constants {
  // This is the height the button will render at with size 14.0 font.
  // Setting a sensible default for the purposes of rendering an initial nice corner radius -
  // which will be updated on subsequent layout calls.
  static let defaultButtonHeight: CGFloat = 40.0

  // These match the card insets in BackerDashboardProjectCell
  static let pillLeftInsetForIPad: CGFloat = Styles.grid(20)
  static let pillLeftInsetForIPhone: CGFloat = Styles.grid(2)
}
