import Foundation
import UIKit
import Library
import Prelude

protocol PledgeAddNewCardViewDelegate: class {
  func pledgeAddNewCardViewDidTapAddNewCard()
}


final class PledgeAddNewCardView: UIView {
  private lazy var addNewCardImageView: UIImageView = {
    UIImageView(image: UIImage.init(named: "icon--add"))
  }()
  private lazy var addNewCardButton: UIButton = {
    UIButton(type: .custom)
  }()

  weak var delegate: PledgeAddNewCardViewDelegate?

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: Functions

  private func configureViews() {
    _ = ([self.addNewCardImageView, self.addNewCardButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addNewCardButton.addTarget(self, action: #selector(PledgeAddNewCardView.addNewCardButtonTapped), for: .touchUpInside)
  }

  //MARK: - Accessors

  @objc private func addNewCardButtonTapped() {
    self.delegate?.pledgeAddNewCardViewDidTapAddNewCard()
  }
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.alignment .~ .leading
    |> \.distribution .~ .fill
}
