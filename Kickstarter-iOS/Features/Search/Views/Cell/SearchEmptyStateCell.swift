import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class SearchEmptyStateCell: UITableViewCell, ValueCell {
  typealias Value = SearchEmptyStateSearchData

  fileprivate let viewModel: SearchEmptyStateCellViewModelType = SearchEmptyStateCellViewModel()

  private var titleLabel: UILabel = UILabel()
  private var subtitleLabel: UILabel = UILabel()
  private var clearFiltersButton: UIButton
  private var rootStackView: UIStackView = UIStackView()

  internal func configureWith(value: SearchEmptyStateSearchData) {
    self.viewModel.inputs.configureWith(data: value)
  }

  override init(
    style: UITableViewCell.CellStyle,
    reuseIdentifier: String?
  ) {
    self.clearFiltersButton = KSRButton(style: .filled)
    self.clearFiltersButton.setTitle("FPO: Remove all filters", for: .normal)

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.titleLabel.text = "temp"
    self.subtitleLabel.text = "temp2"

    self.rootStackView.addArrangedSubviews(self.titleLabel, self.subtitleLabel, self.clearFiltersButton)
    self.contentView.addSubview(self.rootStackView)

    self.bindViewModel()
    self.bindStyles()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.rootStackView.translatesAutoresizingMaskIntoConstraints = false
    self.clearFiltersButton.translatesAutoresizingMaskIntoConstraints = false

    self.rootStackView.axis = .vertical
    self.rootStackView.alignment = .center
    self.rootStackView.spacing = Styles.grid(3)

    NSLayoutConstraint.activate([
      self.rootStackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
      self.rootStackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
      self.rootStackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
      self.rootStackView.trailingAnchor
        .constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor)
    ])

    self.titleLabel.textColor = Colors.Text.primary.uiColor()
    self.titleLabel.font = InterFont.headingXL.font()
    self.titleLabel.textAlignment = .center
    self.titleLabel.numberOfLines = 3

    self.subtitleLabel.textColor = Colors.Text.secondary.uiColor()
    self.subtitleLabel.font = InterFont.bodyMD.font()
    self.subtitleLabel.textAlignment = .center
    self.subtitleLabel.numberOfLines = 0

    self.contentView.backgroundColor = .clear
    self.contentView.layoutMargins = self.traitCollection.isRegularRegular
      ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
      : .init(topBottom: Styles.grid(6), leftRight: Styles.grid(4))
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.titleLabel.rac.text = self.viewModel.outputs.titleText
    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleText
    self.viewModel.outputs.hideClearFiltersButton
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.clearFiltersButton.isHidden = isHidden
      }
  }
}
