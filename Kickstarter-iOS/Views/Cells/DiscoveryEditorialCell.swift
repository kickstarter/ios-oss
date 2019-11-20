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

    self.viewModel.outputs.imageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        guard let self = self else { return }

        _ = self.editorialImageView
          |> \.image %~ { _ in Library.image(named: imageName,
                                             inBundle: Bundle.framework,
                                             compatibleWithTraitCollection: nil) }
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
          ? .init(top: Styles.grid(2), left: Styles.grid(30), bottom: 0, right: Styles.grid(30))
          : .init(top: Styles.grid(2), left: Styles.grid(2), bottom: 0, right: Styles.grid(2))
    }

    _ = self.containerView
      |> \.backgroundColor .~ .ksr_trust_700
      |> roundedStyle(cornerRadius: Styles.grid(2))

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.editorialImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill

    _ = self.editorialTitleLabel
      |> editorialLabelStyle
      |> \.font .~ UIFont.ksr_title2().bolded

    _ = self.editorialSubtitleLabel
      |> editorialLabelStyle
      |> \.font .~ UIFont.ksr_callout()
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

    _ = ([self.editorialTitleLabel, self.editorialSubtitleLabel, self.editorialImageView], self.rootStackView)
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
    |> \.textAlignment .~ .left
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(2)
//    |> \.alignment .~ .leading
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(top: Styles.grid(3), left: Styles.grid(3), bottom: 0,
                                            right: Styles.grid(3))
}
