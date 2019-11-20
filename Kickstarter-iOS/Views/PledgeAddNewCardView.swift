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
    UIImageView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var addNewCardImageViewContainer = { UIView(frame: .zero) }()
  private let bottomLayoutGuide = UILayoutGuide()
  private lazy var cardView: UIView = { UIView(frame: .zero) }()
  private lazy var containerStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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
      |> \.image .~ image(
        named: "icon--add",
        inBundle: Bundle.framework,
        compatibleWithTraitCollection: nil
      )

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
    _ = ([self.cardView], self.containerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.containerStackView, self)
      |> ksr_addSubviewToParent()

    _ = (self.rootStackView, self.cardView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.addNewCardImageView, self.addNewCardImageViewContainer)
      |> ksr_addSubviewToParent()

    _ = ([self.addNewCardImageViewContainer, self.addNewCardButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.bottomLayoutGuide, self)
      |> ksr_addLayoutGuideToView()

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
        .constraint(equalToConstant: Styles.minTouchSize.height),
      self.addNewCardImageView.widthAnchor
        .constraint(equalToConstant: CheckoutConstants.PaymentSource.ImageView.width),
      self.cardView.heightAnchor.constraint(
        greaterThanOrEqualToConstant:
        CheckoutConstants.CreditCardView.height
      )
    ])

    let margins = self.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.containerStackView.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.containerStackView.topAnchor.constraint(equalTo: margins.topAnchor),
      self.containerStackView.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomLayoutGuide.topAnchor),
      self.bottomLayoutGuide.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.bottomLayoutGuide.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.bottomLayoutGuide.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
    ])
  }

  // MARK: - Accessors

  @objc private func addNewCardButtonTapped() {
    self.viewModel.inputs.addNewCardButtonTapped()
  }
}
