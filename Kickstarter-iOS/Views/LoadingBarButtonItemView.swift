import Foundation
import Library
import Prelude

final class LoadingBarButtonItemView: UIView, NibLoading {
  @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var titleButton: UIButton!

  private let viewModel: LoadingBarButtonItemViewModelType = LoadingBarButtonItemViewModel()

  public static func instantiate() -> LoadingBarButtonItemView {
    guard let saveButtonView = LoadingBarButtonItemView.fromNib(nib: Nib.LoadingBarButtonItemView) else {
      fatalError("failed to load LoadingBarButtonItemView from Nib")
    }

    return saveButtonView
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleButton
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_green_800
      |> UIButton.lens.titleColor(for: .disabled) .~ .ksr_grey_500

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
      .observeValues { [weak self] (isLoading) in
        self?.animateActivityIndicator(isLoading)
    }
  }

  // MARK: Public Functions

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

  // MARK: Private Functions

  private func animateActivityIndicator(_ isAnimating: Bool) {
    if isAnimating {
      bringSubviewToFront(activityIndicator)

      activityIndicator.startAnimating()
    } else {
      activityIndicator.stopAnimating()

      bringSubviewToFront(titleButton)
    }
  }
}
