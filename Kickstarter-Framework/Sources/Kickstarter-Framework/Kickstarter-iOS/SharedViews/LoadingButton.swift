import Library
import Prelude
import UIKit

final class LoadingButton: UIButton {
  // MARK: - Properties

  private let viewModel: LoadingButtonViewModelType = LoadingButtonViewModel()

  private lazy var activityIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView(style: .medium)
      |> \.hidesWhenStopped .~ true
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public var activityIndicatorStyle: UIActivityIndicatorView.Style = .medium {
    didSet {
      self.activityIndicator.style = self.activityIndicatorStyle
    }
  }

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
    guard !self.activityIndicator.isAnimating else {
      self.originalTitles[state.rawValue] = title
      return
    }

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
    let states: [UIControl.State] = [.disabled, .highlighted, .normal, .selected]

    states.compactMap { state -> (String, UIControl.State)? in
      guard let title = self.title(for: state) else { return nil }
      return (title, state)
    }
    .forEach { title, state in
      self.originalTitles[state.rawValue] = title
      self.setTitle(nil, for: state)
    }

    _ = self
      |> \.accessibilityLabel %~ { _ in Strings.Loading() }

    UIAccessibility.post(notification: .layoutChanged, argument: self)
  }

  private func restoreTitle() {
    let states: [UIControl.State] = [.disabled, .highlighted, .normal, .selected]

    states.compactMap { state -> (String, UIControl.State)? in
      guard let title = self.originalTitles[state.rawValue] else { return nil }
      return (title, state)
    }
    .forEach { title, state in
      self.originalTitles[state.rawValue] = nil
      self.setTitle(title, for: state)
    }

    _ = self
      |> \.accessibilityLabel .~ nil

    UIAccessibility.post(notification: .layoutChanged, argument: self)
  }
}
