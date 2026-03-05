import KDS
import Library
import Prelude
import UIKit

final class LoadingBarButtonItemView: UIView {
  private lazy var activityIndicator: UIActivityIndicatorView = { UIActivityIndicatorView() }()
  private lazy var titleButton: UIButton = { UIButton() }()

  private let viewModel: LoadingBarButtonItemViewModelType = LoadingBarButtonItemViewModel()

  // Helper function for creating a UIBarButtonItem for the LoadingBarButtonItemView with liquid
  // glass animation off. The liquid glass animation is added directly to the UIButton instead,
  // which is necessary in order for it to respect the UIButton state.
  public static func uiBarButtonItem(for loadingBarButtonItemView: LoadingBarButtonItemView)
    -> UIBarButtonItem {
    let barButtonItem = UIBarButtonItem(customView: loadingBarButtonItemView)
    if #available(iOS 26.0, *) {
      barButtonItem.hidesSharedBackground = true
    }
    return barButtonItem
  }

  public static func instantiate() -> LoadingBarButtonItemView {
    let saveButtonView = LoadingBarButtonItemView.init()
    saveButtonView.translatesAutoresizingMaskIntoConstraints = false
    return saveButtonView
  }

  required init() {
    super.init(frame: .zero)

    self.setupView()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    self.titleButton.translatesAutoresizingMaskIntoConstraints = false
    self.titleButton.isEnabled = false
    self.addSubview(self.titleButton)

    if #available(iOS 26.0, *) {
      self.titleButton.configuration = .glass()
    } else {
      self.titleButton.setTitleColor(LegacyColors.ksr_create_700.uiColor(), for: .normal)
      self.titleButton.setTitleColor(LegacyColors.ksr_support_300.uiColor(), for: .disabled)
    }
    self.titleButton.titleLabel?.font = UIFont.ksr_body()

    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.activityIndicator)

    NSLayoutConstraint.activate([
      self.titleButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
      self.titleButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
      self.titleButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
      self.titleButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),

      self.activityIndicator.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
      self.activityIndicator.centerYAnchor.constraint(equalTo: self.titleButton.centerYAnchor),
      self.heightAnchor.constraint(greaterThanOrEqualTo: self.activityIndicator.heightAnchor, multiplier: 1)
    ])
  }

  override func bindStyles() {
    super.bindStyles()

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
