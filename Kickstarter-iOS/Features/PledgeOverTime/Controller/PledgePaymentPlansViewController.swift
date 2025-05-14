import Library
import UIKit

protocol PledgePaymentPlansViewControllerDelegate: AnyObject {
  func pledgePaymentPlansViewController(
    _ viewController: PledgePaymentPlansViewController,
    didSelectPaymentPlan paymentPlan: PledgePaymentPlansType
  )
  func pledgePaymentPlansViewController(
    _ viewController: PledgePaymentPlansViewController,
    didTapTermsOfUseWith helpType: HelpType
  )
}

final class PledgePaymentPlansViewController: UIViewController {
  // MARK: Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var separatorView: UIView = { UIView(frame: .zero) }()
  private lazy var pledgeInFullOption = PledgePaymentPlanOptionView(frame: .zero)
  private lazy var pledgeOverTimeOption = PledgePaymentPlanOptionView(frame: .zero)

  private lazy var pledgeInFullLoadingOption = PledgePaymentPlanOptionLoadingView(frame: .zero)
  private lazy var pledgeOverTimeLoadingOption = PledgePaymentPlanOptionLoadingView(frame: .zero)

  internal weak var delegate: PledgePaymentPlansViewControllerDelegate?

  private let viewModel: PledgePaymentPlansViewModelType = PledgePaymentPlansViewModel()

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    self.view.addSubview(self.rootStackView)

    self.pledgeInFullOption.delegate = self
    self.pledgeOverTimeOption.delegate = self

    self.rootStackView.addArrangedSubviews(
      self.pledgeInFullOption,
      self.pledgeInFullLoadingOption,
      self.separatorView,
      self.pledgeOverTimeOption,
      self.pledgeOverTimeLoadingOption
    )
  }

  private func setupConstraints() {
    self.rootStackView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.rootStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.rootStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.rootStackView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.rootStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.separatorView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()

    applyRootStackViewStyle(self.rootStackView)

    applyWhiteBackgroundStyle(self.view)

    applySeparatorStyle(self.separatorView)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    let isLoading = self.viewModel.outputs.isLoading
    let notLoading = self.viewModel.outputs.isLoading.map { !$0 }

    self.pledgeInFullOption.rac.hidden = isLoading
    self.pledgeOverTimeOption.rac.hidden = isLoading
    self.pledgeInFullLoadingOption.rac.hidden = notLoading
    self.pledgeOverTimeLoadingOption.rac.hidden = notLoading

    self.viewModel.outputs.reloadPaymentPlans
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self = self else { return }

        self.pledgeInFullOption.configureWith(value: PledgePaymentPlanOptionData(
          ineligible: data.ineligible,
          type: .pledgeInFull,
          selectedType: data.selectedPlan,
          paymentIncrements: data.paymentIncrements,
          project: data.project
        ))
        self.pledgeOverTimeOption.configureWith(value: PledgePaymentPlanOptionData(
          ineligible: data.ineligible,
          type: .pledgeOverTime,
          selectedType: data.selectedPlan,
          paymentIncrements: data.paymentIncrements,
          project: data.project
        ))
      }

    self.viewModel.outputs.notifyDelegatePaymentPlanSelected
      .observeForUI()
      .observeValues { [weak self] paymentPlan in
        guard let self = self else { return }

        self.delegate?.pledgePaymentPlansViewController(self, didSelectPaymentPlan: paymentPlan)
      }
    self.viewModel.outputs.notifyDelegateTermsOfUseTapped
      .observeForUI()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }

        self.delegate?.pledgePaymentPlansViewController(self, didTapTermsOfUseWith: helpType)
      }
  }

  // MARK: - Configuration

  func configure(with value: PledgePaymentPlansAndSelectionData) {
    self.viewModel.inputs.configure(with: value)
  }
}

// MARK: - UITableViewDelegate

extension PledgePaymentPlansViewController: PledgePaymentPlanOptionViewDelegate {
  func pledgePaymentPlanOptionView(
    _: PledgePaymentPlanOptionView,
    didSelectPlanType paymentPlanType: PledgePaymentPlansType
  ) {
    self.viewModel.inputs.didSelectPlanType(paymentPlanType)
  }

  func pledgePaymentPlansViewController(
    _: PledgePaymentPlanOptionView,
    didTapTermsOfUseWith helpType: HelpType
  ) {
    self.viewModel.inputs.didTapTermsOfUse(with: helpType)
  }
}

// MARK: Styles

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = 0
}

private func applyWhiteBackgroundStyle(_ view: UIView) {
  view.backgroundColor = LegacyColors.ksr_white.uiColor()
}

private func applySeparatorStyle(_ view: UIView) {
  view.backgroundColor = LegacyColors.ksr_support_300.uiColor()
  view.accessibilityElementsHidden = true
}
