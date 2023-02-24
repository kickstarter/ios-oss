import KsApi
import Library
import Prelude
import UIKit

final class PledgePaymentMethodAddCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var selectionView: UIView = { UIView(frame: .zero) }()
  private lazy var addButton: UIButton = { UIButton(type: .custom) }()

  private lazy var containerView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
    indicator.startAnimating()
    return indicator
  }()

  private let viewModel: PledgePaymentMethodAddCellViewModelType = PledgePaymentMethodAddCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View model

  override func bindViewModel() {
    self.activityIndicator.rac.animating = self.viewModel.outputs.showLoading
    self.addButton.rac.hidden = self.viewModel.outputs.showLoading
  }

  // MARK: - Configuration

  private func configureSubviews() {
    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    _ = ([self.activityIndicator, self.addButton], self.containerView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.addButton, self.containerView)
      |> ksr_constrainViewToEdgesInParent()
      |> ksr_constrainViewToCenterInParent()

    _ = (self.activityIndicator, self.containerView)
      |> ksr_constrainViewToEdgesInParent()
      |> ksr_constrainViewToCenterInParent()

    _ = (self.containerView, self.contentView)
      |> ksr_constrainViewToEdgesInParent()
      |> ksr_constrainViewToCenterInParent()

    NSLayoutConstraint.activate([
      self.activityIndicator.widthAnchor.constraint(equalToConstant: Styles.grid(9)),
      self.containerView.heightAnchor.constraint(equalToConstant: Styles.grid(9))
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.selectionView
      |> selectionViewStyle

    _ = self
      |> \.selectedBackgroundView .~ self.selectionView

    _ = self.addButton
      |> addButtonStyle

    _ = self.activityIndicator
      |> activityIndicatorStyle

    _ = self.containerView
      |> stackViewStyle
  }

  func configureWith(value flag: Bool) {
    self.viewModel.inputs.configureWith(value: flag)
  }
}

// MARK: - Styles

private let addButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.titleLabel.font .~ UIFont.boldSystemFont(ofSize: 15)
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "icon-add-round-green")
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.New_payment_method() }
    |> UIButton.lens.isUserInteractionEnabled .~ false
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_create_700
    |> UIButton.lens.tintColor .~ .ksr_create_700
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(3))
}

private let selectionViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_support_100
}

private let activityIndicatorStyle: ActivityIndicatorStyle = { activityIndicator in
  activityIndicator
    |> \.color .~ UIColor.ksr_support_400
    |> \.hidesWhenStopped .~ true
}

private let stackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.alignment .~ .center
    |> \.spacing .~ Styles.grid(0)
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
