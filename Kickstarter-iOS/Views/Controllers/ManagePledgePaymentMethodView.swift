import UIKit

final class ManagePledgePaymentMethodView: UIView {
  // MARK: Properties

  private lazy var cardImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var expirationDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var lastFourLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: Life cycle

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
