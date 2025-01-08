import KsApi
import Library
import UIKit

private enum Constants {
  static let animationDuration: TimeInterval = 0.3
  static let collapseIndicatorSize: CGFloat = 20.0
  static let contentInsets = NSDirectionalEdgeInsets(top: 1.0, leading: 0, bottom: 1.0, trailing: 0)
  static let paymentsScheduleStackViewSpacing = Styles.grid(3)
  static let rootStackViewSpacing = Styles.grid(4)
}

protocol PledgeOverTimePaymentScheduleDelegate: AnyObject {
  func termsOfUseTapped(with helpType: HelpType)
}

final class PledgeOverTimePaymentScheduleViewController: UIViewController {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var headerStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var collapseIndicatorImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var paymentsScheduleStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var termsOfUseButton: UIButton = { UIButton(frame: .zero) }()

  private let viewModel: PledgeOverTimePaymentScheduleViewModelType =
    PledgeOverTimePaymentScheduleViewModel()

  public weak var delegate: PledgeOverTimePaymentScheduleDelegate?

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()
    self.setupConstraints()
    self.setupGestureRecognizers()
    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Configuration

  private func configureViews() {
    self.view.addSubview(self.rootStackView)

    self.rootStackView.addArrangedSubview(self.headerStackView)
    self.headerStackView.addArrangedSubviews(
      self.titleLabel,
      self.collapseIndicatorImageView
    )

    self.rootStackView.addArrangedSubview(self.paymentsScheduleStackView)

    self.paymentsScheduleStackView.isHidden = true

    // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
    self.titleLabel.text = "Payment Schedule"

    self.termsOfUseButton.setAttributedTitle(
      NSAttributedString(
        string: Strings.login_tout_help_sheet_terms(),
        attributes: [NSAttributedString.Key.font: UIFont.ksr_subhead()]
      ),
      for: .normal
    )
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToEdges(in: self.view)

    NSLayoutConstraint.activate([
      self.collapseIndicatorImageView.widthAnchor
        .constraint(equalToConstant: Constants.collapseIndicatorSize),
      self.collapseIndicatorImageView.heightAnchor
        .constraint(equalToConstant: Constants.collapseIndicatorSize)
    ])
  }

  public func configure(with increments: [PledgePaymentIncrement], project: Project, collapsed: Bool = true) {
    self.viewModel.inputs.configure(with: increments, project: project, collapsed: collapsed)
  }

  private func setupGestureRecognizers() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.headerTapped))
    self.headerStackView.addGestureRecognizer(tapGestureRecognizer)

    self.termsOfUseButton.addTarget(
      self,
      action: #selector(self.onTermsOfUseButtonTapped),
      for: .touchUpInside
    )
  }

  private func configurePaymentScheduleItems(_ items: [PLOTPaymentScheduleItem]) {
    self.paymentsScheduleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    items.forEach { item in
      let itemView = PledgeOverTimePaymentScheduleItemView()
      itemView.configure(
        with: item.dateString,
        badgeTitle: item.stateLabel,
        badgeBackgroundColor: item.stateBackgroundColor,
        badgeTextColor: item.stateForegroundColor,
        amountAttributedText: item.amountAttributedText
      )
      self.paymentsScheduleStackView.addArrangedSubview(itemView)
    }

    self.paymentsScheduleStackView.addArrangedSubview(self.termsOfUseButton)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.collapsed
      .observeForUI()
      .observeValues { [weak self] isCollapsed in
        self?.updateCollapseState(isCollapsed: isCollapsed, animated: true)
      }

    self.viewModel.outputs.paymentScheduleItems
      .observeForUI()
      .observeValues { [weak self] items in
        self?.configurePaymentScheduleItems(items)
      }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyHeaderStackViewStyle(self.headerStackView)
    applyTitleLabelStyle(self.titleLabel)
    applyCollapseIndicatorImageViewStyle(self.collapseIndicatorImageView)
    applyRootStackViewStyle(self.rootStackView)
    applyPaymentsScheduleStackViewStyle(self.paymentsScheduleStackView)
    applyTermsOfUseStyle(self.termsOfUseButton)
  }

  // MARK: - Actions

  @objc public func headerTapped() {
    self.viewModel.inputs.collapseToggle()
  }

  @objc private func onTermsOfUseButtonTapped() {
    self.delegate?.termsOfUseTapped(with: .terms)
  }

  // MARK: - Collapse/Expand Logic

  private func updateCollapseState(isCollapsed: Bool, animated: Bool) {
    guard animated else {
      self.paymentsScheduleStackView.isHidden = isCollapsed
      self.collapseIndicatorImageView.transform =
        isCollapsed ? .identity : CGAffineTransform(rotationAngle: .pi)
      return
    }

    UIView.animate(
      withDuration: Constants.animationDuration,
      delay: 0,
      usingSpringWithDamping: 0.6,
      initialSpringVelocity: 0.7,
      options: .curveEaseInOut,
      animations: {
        self.paymentsScheduleStackView.isHidden = isCollapsed
        self.paymentsScheduleStackView.alpha = isCollapsed ? 0 : 1

        self.view.layoutIfNeeded()

        self.collapseIndicatorImageView.transform = isCollapsed
          ? .identity
          : CGAffineTransform(rotationAngle: .pi)
      },
      completion: nil
    )
  }
}

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Constants.rootStackViewSpacing
}

private func applyHeaderStackViewStyle(_ stackView: UIStackView) {
  stackView.alignment = .center
  stackView.axis = .horizontal
  stackView.distribution = .equalSpacing
}

private func applyPaymentsScheduleStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Constants.paymentsScheduleStackViewSpacing
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.adjustsFontForContentSizeCategory = true
  label.font = UIFont.ksr_subhead().bolded
  label.textColor = .ksr_black
}

private func applyCollapseIndicatorImageViewStyle(_ imageView: UIImageView) {
  imageView.contentMode = .scaleAspectFit
  imageView.image = UIImage(systemName: "chevron.down")
  imageView.tintColor = .ksr_support_700
}

private func applyTermsOfUseStyle(_ button: UIButton) {
  button.configuration = {
    var config = UIButton.Configuration.borderless()
    config.contentInsets = Constants.contentInsets
    config.baseForegroundColor = .ksr_create_700
    return config
  }()

  button.contentHorizontalAlignment = .leading
}
