import Library
import Prelude
import UIKit

final class LoadingBarButtonItemView: UIView, NibLoading {
  @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
  @IBOutlet fileprivate var titleButton: UIButton!

  private let viewModel: LoadingBarButtonItemViewModelType = LoadingBarButtonItemViewModel()

  public static func instantiate() -> LoadingBarButtonItemView {
    guard let saveButtonView = LoadingBarButtonItemView.fromNib(nib: Nib.LoadingBarButtonItemView) else {
      fatalError("failed to load LoadingBarButtonItemView from Nib")
    }

    saveButtonView.translatesAutoresizingMaskIntoConstraints = false

    return saveButtonView
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleButton
      |> UIButton.lens.titleLabel.font .~ UIFont.systemFont(ofSize: 17)
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_create_700
      |> UIButton.lens.titleColor(for: .disabled) .~ .ksr_support_300

    _ = self.activityIndicator
      |> baseActivityIndicatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.titleButton.rac.hidden = self.viewModel.outputs.titleButtonIsHidden
    self.titleButton.rac.enabled = self.viewModel.outputs.titleButtonIsEnabled
    self.titleButton.rac.title = self.viewModel.outputs.titleButtonText

    self.viewModel.outputs.activityIndicatorIsLoading
      .observeForUI()
      .observeValues { [weak self] isLoading in
        self?.animateActivityIndicator(isLoading)
      }
  }

  // MARK: - Public Functions

  func setIsEnabled(isEnabled: Bool) {
    self.viewModel.inputs.setIsEnabled(isEnabled: isEnabled)
  }

  func setTitle(title: String) {
    self.viewModel.inputs.setTitle(title: title)
  }

  func startAnimating() {
    self.viewModel.inputs.setAnimating(isAnimating: true)
  }

  func stopAnimating() {
    self.viewModel.inputs.setAnimating(isAnimating: false)
  }

  func addTarget(_ target: Any?, action: Selector) {
    self.titleButton.addTarget(target, action: action, for: .touchUpInside)
  }

  // MARK: - Functions

  private func animateActivityIndicator(_ isAnimating: Bool) {
    if isAnimating {
      bringSubviewToFront(self.activityIndicator)

      self.activityIndicator.startAnimating()
    } else {
      self.activityIndicator.stopAnimating()

      bringSubviewToFront(self.titleButton)
    }
  }
}
