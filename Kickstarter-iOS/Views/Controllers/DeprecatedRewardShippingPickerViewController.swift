import KsApi
import Library
import Prelude
import UIKit

internal protocol DeprecatedRewardShippingPickerViewControllerDelegate: AnyObject {
  /// Called when the user has chosen a shipping rule, and the picker should be dismissed.
  func rewardShippingPickerViewController(
    _ controller: DeprecatedRewardShippingPickerViewController,
    choseShippingRule: ShippingRule
  )

  /// Called when the user wants to cancel the picker.
  func rewardShippingPickerViewControllerCancelled(_ controller: DeprecatedRewardShippingPickerViewController)
}

internal final class DeprecatedRewardShippingPickerViewController: UIViewController {
  fileprivate var dataSource: [String] = []
  internal weak var delegate: DeprecatedRewardShippingPickerViewControllerDelegate!
  fileprivate let viewModel: DeprecatedRewardShippingPickerViewModelType
    = DeprecatedRewardShippingPickerViewModel()

  @IBOutlet fileprivate var cancelButton: UIButton!
  @IBOutlet fileprivate var countryPickerView: UIPickerView!
  @IBOutlet fileprivate var doneButton: UIButton!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate var titleShadowView: GradientView!
  @IBOutlet fileprivate var titleView: UIView!

  internal static func configuredWith(
    project: Project,
    shippingRules: [ShippingRule],
    selectedShippingRule: ShippingRule,
    delegate: DeprecatedRewardShippingPickerViewControllerDelegate
  )
    -> DeprecatedRewardShippingPickerViewController {
    let vc = Storyboard.RewardPledge.instantiate(DeprecatedRewardShippingPickerViewController.self)
    vc.viewModel.inputs.configureWith(
      project: project,
      shippingRules: shippingRules,
      selectedShippingRule: selectedShippingRule
    )
    vc.delegate = delegate
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped), for: .touchUpInside)
    self.doneButton.addTarget(self, action: #selector(self.doneButtonTapped), for: .touchUpInside)

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
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.discovery_search_cancel() }

    _ = self.doneButton
      |> textOnlyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Done() }

    self.titleShadowView.startPoint = CGPoint(x: 0, y: 1)
    self.titleShadowView.endPoint = CGPoint(x: 0, y: 0)
    let gradient: [(UIColor?, Float)] = [
      (UIColor.init(white: 0.0, alpha: 0.1), 0),
      (UIColor.init(white: 0.0, alpha: 0.0), 1)
    ]
    self.titleShadowView.setGradient(gradient)

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

extension DeprecatedRewardShippingPickerViewController: UIPickerViewDataSource {
  internal func numberOfComponents(in _: UIPickerView) -> Int {
    return 1
  }

  internal func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
    return self.dataSource.count
  }
}

extension DeprecatedRewardShippingPickerViewController: UIPickerViewDelegate {
  internal func pickerView(
    _: UIPickerView,
    titleForRow row: Int,
    forComponent _: Int
  ) -> String? {
    return self.dataSource[row]
  }

  internal func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
    self.viewModel.inputs.pickerView(didSelectRow: row)
  }
}
