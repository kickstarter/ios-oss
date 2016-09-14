import KsApi
import Library
import Prelude
import UIKit

internal protocol RewardShippingPickerViewControllerDelegate: class {
  /// Called when the user has chosen a shipping rule, and the picker should be dismissed.
  func rewardShippingPickerViewController(controller: RewardShippingPickerViewController,
                                          choseShippingRule: ShippingRule)

  /// Called when the user wants to cancel the picker.
  func rewardShippingPickerViewControllerCancelled(controller: RewardShippingPickerViewController)
}

internal final class RewardShippingPickerViewController: UIViewController {
  private var dataSource: [String] = []
  internal weak var delegate: RewardShippingPickerViewControllerDelegate!
  private let viewModel: RewardShippingPickerViewModelType = RewardShippingPickerViewModel()

  @IBOutlet private weak var cancelButton: UIButton!
  @IBOutlet private weak var countryPickerView: UIPickerView!
  @IBOutlet private weak var doneButton: UIButton!
  @IBOutlet private var separatorViews: [UIView]!
  @IBOutlet private weak var titleShadowView: GradientView!
  @IBOutlet private weak var titleView: UIView!

  internal static func configuredWith(project project: Project,
                                              shippingRules: [ShippingRule],
                                              selectedShippingRule: ShippingRule,
                                              delegate: RewardShippingPickerViewControllerDelegate)
    -> RewardShippingPickerViewController {

      let vc = Storyboard.RewardPledge.instantiate(RewardShippingPickerViewController)
      vc.viewModel.inputs.configureWith(project: project,
                                        shippingRules: shippingRules,
                                        selectedShippingRule: selectedShippingRule)
      vc.delegate = delegate
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), forControlEvents: .TouchUpInside)
    self.doneButton.addTarget(self, action: #selector(doneButtonTapped), forControlEvents: .TouchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .clearColor()

    self.countryPickerView
      |> UIView.lens.backgroundColor .~ .whiteColor()

    self.cancelButton
      |> textOnlyButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.discovery_search_cancel() }

    self.doneButton
      |> textOnlyButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Done() }

    self.titleShadowView.startPoint = CGPoint(x: 0, y: 1)
    self.titleShadowView.endPoint = CGPoint(x: 0, y: 0)
    self.titleShadowView.setGradient([
      (UIColor.init(white: 0.0, alpha: 0.1), 0),
      (UIColor.init(white: 0.0, alpha: 0.0), 1)
    ])

    self.separatorViews
      ||> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.dataSource
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dataSource = $0
        self?.countryPickerView.reloadAllComponents()
    }

    self.viewModel.outputs.selectRow
      .observeForControllerAction()
      .observeNext { [weak self] row in
        self?.countryPickerView.selectRow(row, inComponent: 0, animated: false)
    }

    self.viewModel.outputs.notifyDelegateChoseShippingRule
      .observeForControllerAction()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate.rewardShippingPickerViewController(_self, choseShippingRule: $0)
    }

    self.viewModel.outputs.notifyDelegateToCancel
      .observeForControllerAction()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate.rewardShippingPickerViewControllerCancelled(_self)
    }
  }

  @objc private func cancelButtonTapped() {
    self.viewModel.inputs.cancelButtonTapped()
  }

  @objc private func doneButtonTapped() {
    self.viewModel.inputs.doneButtonTapped()
  }
}

extension RewardShippingPickerViewController: UIPickerViewDataSource {

  internal func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  internal func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.dataSource.count
  }
}

extension RewardShippingPickerViewController: UIPickerViewDelegate {

  internal func pickerView(pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
    return self.dataSource[row]
  }

  internal func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.viewModel.inputs.pickerView(didSelectRow: row)
  }
}
