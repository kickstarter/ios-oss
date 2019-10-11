import Library
import Prelude
import UIKit

final class LoadingButton: UIButton {
  // MARK: - Properties

  private lazy var activityIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView(style: .white)
      |> \.hidesWhenStopped .~ true
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public var isLoading: Bool = false {
    didSet {
      guard self.isLoading != oldValue else { return }
      
      if self.isLoading {
        self.startLoading()
      } else {
        self.stopLoading()
      }

      _ = self
        |> \.isUserInteractionEnabled .~ !self.isLoading
    }
  }

  private var originalTitles: [UInt: String] = [:]

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(self.activityIndicator)
    self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    self.addSubview(self.activityIndicator)
    self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }

  override func setTitle(_ title: String?, for state: UIControl.State) {
    // Do not allow changing the title while the activity indicator is animating
    guard !self.activityIndicator.isAnimating else { return }

    super.setTitle(title, for: state)
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

    self.originalTitles[disabledState.rawValue] = self.title(for: disabledState)
    self.originalTitles[highlightedState.rawValue] = self.title(for: highlightedState)
    self.originalTitles[normalState.rawValue] = self.title(for: normalState)
    self.originalTitles[selectedState.rawValue] = self.title(for: selectedState)

    self.setTitle(nil, for: disabledState)
    self.setTitle(nil, for: highlightedState)
    self.setTitle(nil, for: normalState)
    self.setTitle(nil, for: selectedState)

    _ = self
      |> \.accessibilityLabel %~ { _ in Strings.Loading() }

    UIAccessibility.post(notification: .layoutChanged, argument: self)
  }

  private func restoreTitle() {
    let disabledState = UIControl.State.disabled
    let highlightedState = UIControl.State.highlighted
    let normalState = UIControl.State.normal
    let selectedState = UIControl.State.selected

    self.setTitle(self.originalTitles[disabledState.rawValue], for: disabledState)
    self.setTitle(self.originalTitles[highlightedState.rawValue], for: highlightedState)
    self.setTitle(self.originalTitles[normalState.rawValue], for: normalState)
    self.setTitle(self.originalTitles[selectedState.rawValue], for: selectedState)

    self.originalTitles[disabledState.rawValue] = nil
    self.originalTitles[highlightedState.rawValue] = nil
    self.originalTitles[normalState.rawValue] = nil
    self.originalTitles[selectedState.rawValue] = nil

    _ = self
      |> \.accessibilityLabel .~ nil

    UIAccessibility.post(notification: .layoutChanged, argument: self)
  }
}
