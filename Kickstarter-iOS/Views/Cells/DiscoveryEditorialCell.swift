import Foundation
import Library
import Prelude
import UIKit
import KsApi

protocol DiscoveryEditorialCellDelegate: AnyObject {
  func discoveryEditorialCellTapped(_ cell: DiscoveryEditorialCell)
}

final class DiscoveryEditorialCell: UITableViewCell, ValueCell {
  weak var delegate: DiscoveryEditorialCellDelegate?

  // MARK: - Properties

  private let containerView = UIView(frame: .zero)
  private let editorialImageView = UIImageView(frame: .zero)
  private let editorialTitleLabel = UILabel(frame: .zero)
  private let editorialSubtitleLabel = UILabel(frame: .zero)
  private let rootStackView = UIStackView(frame: .zero)

  private let viewModel: DiscoveryEditorialViewModelType = DiscoveryEditorialViewModel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateViewTapped
      .observeForUI()
      .observeValues { [weak self] tag in
        guard let self = self else { return }

        // TODO pass tag
        self.delegate?.discoveryEditorialCellTapped(self)
    }

    self.editorialTitleLabel.rac.text = self.viewModel.outputs.titleText
    self.editorialSubtitleLabel.rac.text = self.viewModel.outputs.subtitleText
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> DiscoveryEditorialCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(1), leftRight: Styles.grid(30))
          : .init(topBottom: Styles.grid(1), leftRight: layoutMargins.left)
    }

    _ = self.containerView
      |> \.backgroundColor .~ .ksr_trust_700
      |> roundedStyle(cornerRadius: Styles.grid(2))

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.editorialTitleLabel
      |> editorialLabelStyle
      |> \.font .~ UIFont.ksr_title2().bolded

    _ = self.editorialSubtitleLabel
      |> editorialLabelStyle
      |> \.font .~ UIFont.ksr_subhead()
  }

  func configureWith(value: DiscoveryEditorialCellValue) {
    self.viewModel.inputs.configureWith(value)
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.containerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.editorialTitleLabel, self.editorialSubtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                      action: #selector(DiscoveryEditorialCell
                                                        .editorialCellTapped))

    self.containerView.addGestureRecognizer(tapGestureRecognizer)
  }

  // MARK: - Accessors

  @objc private func editorialCellTapped() {
    self.viewModel.inputs.editorialCellTapped()
  }
}

// MARK: - Styles

private let editorialLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .white
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(3)
    |> \.alignment .~ .leading
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}
