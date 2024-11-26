import Library
import UIKit

protocol PledgePaymentPlansViewControllerDelegate: AnyObject {
  func pledgePaymentPlansViewController(
    _ viewController: PledgePaymentPlansViewController,
    didSelectPaymentPlan paymentPlan: PledgePaymentPlansType
  )
}

final class PledgePaymentPlansViewController: UIViewController {
  // MARK: Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  private var planOptionViews: [PledgePaymentPlanOptionView] = []

  private lazy var separatorView: UIView = { UIView(frame: .zero) }()

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

    let pledgeInfullOption = PledgePaymentPlanOptionView(frame: .zero)
    pledgeInfullOption.delegate = self

    let pledgeInfullOptionData = PledgePaymentPlanOptionData(type: .pledgeInFull, selectedType: .pledgeInFull)
    pledgeInfullOption.configureWith(value: pledgeInfullOptionData)

    let pledgeOverTimeOption = PledgePaymentPlanOptionView(frame: .zero)
    pledgeOverTimeOption.delegate = self

    let pledgeOverTimeOptionData = PledgePaymentPlanOptionData(
      type: .pledgeOverTime,
      selectedType: .pledgeInFull
    )
    pledgeOverTimeOption.configureWith(value: pledgeOverTimeOptionData)

    self.planOptionViews = [pledgeInfullOption, pledgeOverTimeOption]

    let arrangedSubviews = [pledgeInfullOption, self.separatorView, pledgeOverTimeOption]

    addArrangedSubviews(arrangedSubviews, to: self.rootStackView)
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

    self.viewModel.outputs.reloadPaymentPlans.observeForUI().observeValues { [weak self] data in
      guard let self = self else { return }

      self.planOptionViews.forEach {
        $0.refreshSelectedOption(data.selectedPlan)
      }
    }

    self.viewModel.outputs.notifyDelegatePaymentPlanSelected
      .observeForUI()
      .observeValues { [weak self] paymentPlan in
        guard let self = self else { return }

        self.delegate?.pledgePaymentPlansViewController(self, didSelectPaymentPlan: paymentPlan)
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
}

// MARK: Styles

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = 0
}

private func applyWhiteBackgroundStyle(_ view: UIView) {
  view.backgroundColor = UIColor.ksr_white
}

private func applySeparatorStyle(_ view: UIView) {
  view.backgroundColor = UIColor.ksr_support_300
  view.accessibilityElementsHidden = true
}

private func addArrangedSubviews(_ subviews: [UIView], to stackView: UIStackView) {
  subviews.forEach(stackView.addArrangedSubview)
}
