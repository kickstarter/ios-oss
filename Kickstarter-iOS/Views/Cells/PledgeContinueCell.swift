import Foundation
import Library
import Prelude

protocol PledgeContinueCellDelegate: AnyObject {
  func pledgeContinueCellDidTapContinue(_ cell: PledgeContinueCell)
}

final class PledgeContinueCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let continueButton = MultiLineButton(type: .custom)
  internal weak var delegate: PledgeContinueCellDelegate?
  private let viewModel = PledgeContinueCellViewModel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setupSubviews()

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateContinueButtonTapped
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let self = self else { return }

        self.delegate?.pledgeContinueCellDidTapContinue(self)
      }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_300

    _ = self.contentView
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.continueButton
      |> checkoutGreenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.Continue()
      }

    _ = self.continueButton.titleLabel
      ?|> checkoutGreenButtonTitleLabelStyle
  }

  func configureWith(value _: ()) {}

  private func setupSubviews() {
    _ = (self.continueButton, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    self.continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(8)).isActive = true

    self.continueButton.addTarget(
      self,
      action: #selector(PledgeContinueCell.continueButtonTapped),
      for: .touchUpInside
    )
  }

  @objc private func continueButtonTapped() {
    self.viewModel.inputs.continueButtonTapped()
  }
}
