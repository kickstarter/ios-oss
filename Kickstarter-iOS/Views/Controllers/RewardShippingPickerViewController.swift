import KsApi
import Library
import Prelude
import UIKit

internal protocol RewardShippingPickerViewControllerDelegate: class {
  /// Called when the user has chosen a shipping rule, and the picker should be dismissed.
  func rewardShippingPickerViewController(_ controller: RewardShippingPickerViewController,
                                          choseShippingRule: ShippingRule)

  /// Called when the user wants to cancel the picker.
  func rewardShippingPickerViewControllerCancelled(_ controller: RewardShippingPickerViewController)
}

internal final class RewardShippingPickerViewController: UIViewController {
  fileprivate var dataSource: [String] = []
  internal weak var delegate: RewardShippingPickerViewControllerDelegate!
  fileprivate let viewModel: RewardShippingPickerViewModelType = RewardShippingPickerViewModel()

  @IBOutlet fileprivate weak var cancelButton: UIButton!
  @IBOutlet fileprivate weak var countryPickerView: UIPickerView!
  @IBOutlet fileprivate weak var doneButton: UIButton!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate weak var titleShadowView: GradientView!
  @IBOutlet fileprivate weak var titleView: UIView!

  internal static func configuredWith(project: Project,
                                              shippingRules: [ShippingRule],
                                              selectedShippingRule: ShippingRule,
                                              delegate: RewardShippingPickerViewControllerDelegate)
    -> RewardShippingPickerViewController {

      let vc = Storyboard.RewardPledge.instantiate(RewardShippingPickerViewController.self)
      vc.viewModel.inputs.configureWith(project: project,
                                        shippingRules: shippingRules,
                                        selectedShippingRule: selectedShippingRule)
      vc.delegate = delegate
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    self.doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .clear

    _ = self.countryPickerView
      |> UIView.lens.backgroundColor .~ .white

    _ = self.cancelButton
      |> textOnlyButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.discovery_search_cancel() }

    _ = self.doneButton
      |> textOnlyButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Done() }

    self.titleShadowView.startPoint = CGPoint(x: 0, y: 1)
    self.titleShadowView.endPoint = CGPoint(x: 0, y: 0)
    self.titleShadowView.setGradient([
      (UIColor.init(white: 0.0, alpha: 0.1), 0),
      (UIColor.init(white: 0.0, alpha: 0.0), 1)
    ])

    _ = self.separatorViews
      ||> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.doneButton.rac.accessibilityHint = self.viewModel.outputs.doneButtonAccessibilityHint

    self.viewModel.outputs.dataSource
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dataSource = $0
        self?.countryPickerView.reloadAllComponents()
    }

    self.viewModel.outputs.selectRow
      .observeForControllerAction()
      .observeValues { [weak self] row in
        self?.countryPickerView.selectRow(row, inComponent: 0, animated: false)
    }

    self.viewModel.outputs.notifyDelegateChoseShippingRule
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate.rewardShippingPickerViewController(_self, choseShippingRule: $0)
    }

    self.viewModel.outputs.notifyDelegateToCancel
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate.rewardShippingPickerViewControllerCancelled(_self)
    }
  }

  @objc fileprivate func cancelButtonTapped() {
    self.viewModel.inputs.cancelButtonTapped()
  }

  @objc fileprivate func doneButtonTapped() {
    self.viewModel.inputs.doneButtonTapped()
  }
}

extension RewardShippingPickerViewController: UIPickerViewDataSource {

  internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.dataSource.count
  }
}

extension RewardShippingPickerViewController: UIPickerViewDelegate {

  internal func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
    return self.dataSource[row]
  }

  internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.viewModel.inputs.pickerView(didSelectRow: row)
  }
}
