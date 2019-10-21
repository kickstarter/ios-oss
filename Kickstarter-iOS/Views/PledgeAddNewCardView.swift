import Foundation
import Library
import Prelude
import UIKit

protocol PledgeAddNewCardViewDelegate: AnyObject {
  func pledgeAddNewCardView(_ view: PledgeAddNewCardView, didTapAddNewCardWith intent: AddNewCardIntent)
}

final class PledgeAddNewCardView: UIView {

  private lazy var addNewCardButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private lazy var addNewCardImageView: UIImageView = {
    UIImageView(image: UIImage.init(named: "icon--add"))
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private lazy var addNewCardImageViewContainer = { UIView(frame: .zero) }()
  private lazy var cardView: UIView = { UIView(frame: .zero) }()
  private lazy var containerStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var spacer: UIView = { UIView(frame: .zero) }()

  weak var delegate: PledgeAddNewCardViewDelegate?

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
  }()

  private let viewModel: PledgeAddNewCardViewModelType = PledgeAddNewCardViewModel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.accessibilityElements .~ [self.addNewCardButton]

    _ = self.cardView
      |> pledgeCardViewStyle

    _ = self.containerStackView
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(2)

    _ = self.rootStackView
      |> checkoutCardStackViewStyle

    _ = self.addNewCardImageView
      |> cardImageViewStyle

    _ = self.addNewCardButton
      |> cardSelectButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Add_new_card() }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateAddNewCardTappedWithIntent
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        guard let self = self else { return }

        self.delegate?.pledgeAddNewCardView(self, didTapAddNewCardWith: intent)
      }
  }

  // MARK: Functions

  private func configureViews() {
    _ = ([self.cardView, self.spacer], self.containerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.containerStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.cardView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.addNewCardImageView, self.addNewCardImageViewContainer)
      |> ksr_addSubviewToParent()

    _ = ([self.addNewCardImageViewContainer, self.addNewCardButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addNewCardButton.addTarget(
      self,
      action: #selector(PledgeAddNewCardView.addNewCardButtonTapped),
      for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor
        .constraint(equalToConstant: CheckoutConstants.PaymentSource.Card.width),
      self.addNewCardImageView.topAnchor
        .constraint(equalTo: self.addNewCardImageViewContainer.topAnchor),
      self.addNewCardImageView.leadingAnchor
        .constraint(equalTo: self.addNewCardImageViewContainer.leadingAnchor),
      self.addNewCardImageView.bottomAnchor
        .constraint(equalTo: self.addNewCardImageViewContainer.bottomAnchor),
      self.addNewCardButton.heightAnchor
        .constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.addNewCardImageView.widthAnchor
        .constraint(equalToConstant: CheckoutConstants.PaymentSource.ImageView.width),
      self.cardView.heightAnchor.constraint(greaterThanOrEqualToConstant:
        CheckoutConstants.CreditCardView.height)
    ])
  }

  // MARK: - Accessors

  @objc private func addNewCardButtonTapped() {
    self.viewModel.inputs.addNewCardButtonTapped()
  }
}
