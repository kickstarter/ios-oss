import Library
import Prelude
import UIKit

final class LoadingButton: UIButton {
  // MARK: - Properties

  private let viewModel: LoadingButtonViewModelType = LoadingButtonViewModel()

  private lazy var activityIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView(style: .white)
      |> \.hidesWhenStopped .~ true
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public var isLoading: Bool = false {
    didSet {
      self.viewModel.inputs.isLoading(self.isLoading)
    }
  }

  private var originalTitles: [UInt: String] = [:]

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    self.configureViews()
    self.bindViewModel()
  }

  override func setTitle(_ title: String?, for state: UIControl.State) {
    // Do not allow changing the title while the activity indicator is animating
    guard !self.activityIndicator.isAnimating else { return }

    super.setTitle(title, for: state)
  }

  // MARK: - Configuration

  private func configureViews() {
    self.addSubview(self.activityIndicator)
    self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.isUserInteractionEnabled
      .observeForUI()
      .observeValues { [weak self] isUserInteractionEnabled in
        _ = self
          ?|> \.isUserInteractionEnabled .~ isUserInteractionEnabled
      }

    self.viewModel.outputs.startLoading
      .observeForUI()
      .observeValues { [weak self] in
        self?.startLoading()
      }

    self.viewModel.outputs.stopLoading
      .observeForUI()
      .observeValues { [weak self] in
        self?.stopLoading()
      }
  }

  // MARK: - Loading

  private func startLoading() {
    self.removeTitle()

    self.activityIndicator.startAnimating()
  }

  private func stopLoading() {
    self.activityIndicator.stopAnimating()

    self.restoreTitle()
  }

  // MARK: - Titles

  private func removeTitle() {
    let disabledState = UIControl.State.disabled
    let highlightedState = UIControl.State.highlighted
    let normalState = UIControl.State.normal
    let selectedState = UIControl.State.selected

    if let disabledTitle = self.title(for: disabledState) {
      self.originalTitles[disabledState.rawValue] = disabledTitle
      self.setTitle(nil, for: disabledState)
    }

    if let highlightedTitle = self.title(for: highlightedState) {
      self.originalTitles[highlightedState.rawValue] = highlightedTitle
      self.setTitle(nil, for: highlightedState)
    }

    if let normalTitle = self.title(for: normalState) {
      self.originalTitles[normalState.rawValue] = normalTitle
      self.setTitle(nil, for: normalState)
    }

    if let selectedTitle = self.title(for: selectedState) {
      self.originalTitles[selectedState.rawValue] = selectedTitle
      self.setTitle(nil, for: selectedState)
    }

    _ = self
      |> \.accessibilityLabel %~ { _ in Strings.Loading() }

    UIAccessibility.post(notification: .layoutChanged, argument: self)
  }

  private func restoreTitle() {
    let disabledState = UIControl.State.disabled
    let highlightedState = UIControl.State.highlighted
    let normalState = UIControl.State.normal
    let selectedState = UIControl.State.selected

    if let disabledTitle = self.originalTitles[disabledState.rawValue] {
      self.setTitle(disabledTitle, for: disabledState)
      self.originalTitles[disabledState.rawValue] = nil
    }

    if let highlightedTitle = self.originalTitles[highlightedState.rawValue] {
      self.setTitle(highlightedTitle, for: highlightedState)
      self.originalTitles[highlightedState.rawValue] = nil
    }

    if let normalTitle = self.originalTitles[normalState.rawValue] {
      self.setTitle(normalTitle, for: normalState)
      self.originalTitles[normalState.rawValue] = nil
    }

    if let selectedTitle = self.originalTitles[selectedState.rawValue] {
      self.setTitle(selectedTitle, for: selectedState)
      self.originalTitles[selectedState.rawValue] = nil
    }

    _ = self
      |> \.accessibilityLabel .~ nil

    UIAccessibility.post(notification: .layoutChanged, argument: self)
  }
}
