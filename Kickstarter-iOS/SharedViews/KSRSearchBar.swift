import Library
import UIKit

private enum Constants {
  static let animationDuration = 0.25
  static let alphaVisible = 1.0
  static let alphaHidden = 0.0

  static let searchIconSize = 24.0
  static let borderWidth = 1.0

  static let focusedBorderColor = Colors.Border.active.uiColor().cgColor
  static let unfocusedBorderColor = Colors.Border.bold.uiColor().cgColor

  static let textInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 20)

  static let defaultInsets = Styles.grid(2)
}

/// A custom search bar view that mimics the native UISearchBar but allows
/// better control over layout, styling, and behavior such as animations for the clear and cancel buttons.
/// Uses a KSRPaddedTextField to support custom padding and icon positioning.
final class KSRSearchBar: UIView {
  // MARK: - Callbacks

  /// Callback triggered whenever the text in the search field changes.
  /// Use this to update search results.
  var onTextChange: ((String) -> Void)?

  /// Callback triggered when the user taps the Cancel button.
  /// Use this to dismiss the search context or reset search state.
  var onCancel: (() -> Void)?

  // MARK: - UI Elements

  private lazy var rootStackView = { UIStackView(frame: .zero) }()
  private lazy var cancelButton = { UIButton(type: .system) }()
  private(set) lazy var textField = { KSRPaddedTextField() }()

  // MARK: - ViewModel

  private let viewModel: KSRSearchBarViewModelType = KSRSearchBarViewModel()

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: - ViewModel Outputs Bindings

  override func bindViewModel() {
    self.textField.rac.text = self.viewModel.outputs.searchFieldText

    // Using `observeForUI` here caused a crash due to `os_unfair_lock` reentrancy when calling `resignFirstResponder`.
    // Switching to `observeForControllerAction` avoids triggering the callback while ReactiveSwift internals are holding the lock.
    self.viewModel.outputs
      .resignFirstResponder
      .observeForControllerAction()
      .observeValues { _ in
        self.textField.resignFirstResponder()
      }

    self.viewModel.outputs
      .changeSearchFieldFocus
      .observeForUI()
      .observeValues { isFocused in
        self.updateAppearance(isFocused: isFocused)
      }

    self.viewModel.outputs
      .searchFieldText
      .observeForUI()
      .observeValues { text in
        self.onTextChange?(text)
        self.updateClearButton()
      }
  }

  // MARK: - Setup

  private func configureSubviews() {
    self.backgroundColor = .clear
    self.addSubview(self.rootStackView)
    self.rootStackView.addArrangedSubviews(self.textField, self.cancelButton)

    self.rootStackView.axis = .horizontal
    self.rootStackView.spacing = Styles.grid(2)

    self.textField.textInsets = Constants.textInsets

    self.textField.delegate = self
    self.textField.addTarget(self, action: #selector(self.textDidChange), for: .editingChanged)

    self.textField.adjustsFontForContentSizeCategory = true
    self.textField.backgroundColor = Colors.Background.Surface.primary.uiColor()
    self.textField.font = .ksr_bodyLG()
    self.textField.layer.borderWidth = Constants.borderWidth
    self.textField.layer.borderColor = Constants.unfocusedBorderColor
    self.textField.rounded()
    self.textField.textColor = Colors.Text.primary.uiColor()

    self.textField.autocorrectionType = .no
    self.textField.clearButtonMode = .never
    self.textField.enablesReturnKeyAutomatically = true
    self.textField.returnKeyType = .search
    self.textField.spellCheckingType = .no

    self.textField.attributedPlaceholder = placeholderAttributeText(Strings.tabbar_search())

    let searchIconView = UIImageView(image: Library.image(named: "Search"))
    searchIconView.tintColor = Colors.Icon.primary.uiColor()
    searchIconView.contentMode = .center
    searchIconView.frame = CGRect(
      x: 0,
      y: 0,
      width: Constants.searchIconSize,
      height: Constants.searchIconSize
    )
    self.textField.leftView = searchIconView
    self.textField.leftViewMode = .always

    let clearButton = UIButton(type: .custom)
    clearButton.setImage(Library.image(named: "icon--cross"), for: .normal)
    clearButton.contentMode = .center
    clearButton.tintColor = Colors.Icon.primary.uiColor()
    clearButton.addTarget(self, action: #selector(self.clearTapped), for: .touchUpInside)
    clearButton.alpha = Constants.alphaHidden
    self.textField.rightView = clearButton
    self.textField.rightViewMode = .never

    self.cancelButton.addTarget(self, action: #selector(self.cancelTapped), for: .touchUpInside)
    self.cancelButton.alpha = Constants.alphaHidden
    self.cancelButton.isHidden = true
    self.cancelButton.setTitle(Strings.discovery_search_cancel(), for: .normal)
    self.cancelButton.tintColor = Colors.Background.Accent.Green.bold.uiColor()
    self.cancelButton.titleLabel?.adjustsFontForContentSizeCategory = true
    self.cancelButton.titleLabel?.font = .ksr_bodyLG()
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToEdges(in: self)
    self.cancelButton.setContentHuggingPriority(.required, for: .horizontal)
    self.cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  // The clear button (rightView) should appear whenever the text field contains text, regardless of focus state
  private func updateClearButton() {
    let hasText = !(self.textField.text ?? "").isEmpty
    let shouldAnimateIn = hasText && self.textField.rightViewMode != .always
    let shouldAnimateOut = !hasText && self.textField.rightViewMode != .never

    if shouldAnimateIn {
      self.textField.rightViewMode = .always
      self.textField.rightView?.alpha = Constants.alphaHidden
      UIView.animate(withDuration: Constants.animationDuration) {
        self.textField.rightView?.alpha = Constants.alphaVisible
      }
    } else if shouldAnimateOut {
      UIView.animate(withDuration: Constants.animationDuration, animations: {
        self.textField.rightView?.alpha = Constants.alphaHidden
      }, completion: { _ in
        self.textField.rightViewMode = .never
      })
    }
  }

  private func updateAppearance(isFocused: Bool) {
    UIView.animate(withDuration: Constants.animationDuration) {
      self.cancelButton.alpha = isFocused ? Constants.alphaVisible : Constants.alphaHidden
      self.cancelButton.isHidden = !isFocused
      self.textField.layer.borderColor = isFocused ? Constants.focusedBorderColor : Constants
        .unfocusedBorderColor
      self.layoutIfNeeded()
    }
  }

  // MARK: - Actions

  @objc private func textDidChange() {
    self.viewModel.inputs.searchTextChanged(self.textField.text ?? "")
  }

  @objc private func clearTapped() {
    self.viewModel.inputs.clearSearchText()
  }

  @objc private func cancelTapped() {
    self.viewModel.inputs.cancelButtonPressed()
    self.onCancel?()
  }
}

// MARK: - UITextFieldDelegate

extension KSRSearchBar: UITextFieldDelegate {
  func textFieldShouldReturn(_: UITextField) -> Bool {
    self.viewModel.inputs.searchTextEditingDidEnd()
    return true
  }

  func textFieldDidBeginEditing(_: UITextField) {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }

  func textFieldDidEndEditing(_: UITextField) {
    self.viewModel.inputs.searchTextEditingDidEnd()
  }
}

// MARK: - KSRPaddedTextField

/// Custom UITextField subclass to support configurable text insets and icon (left/rightView) positioning.
/// UIKit's standard UITextField does not provide public APIs to adjust padding or icon placement.
final class KSRPaddedTextField: UITextField {
  /// Padding for text and placeholder inside the text field
  var textInsets: UIEdgeInsets = UIEdgeInsets(
    top: 0,
    left: Constants.defaultInsets,
    bottom: 0,
    right: Constants.defaultInsets
  )

  /// Horizontal offset for leftView (e.g. magnifying glass icon)
  var leftViewHorizontalOffset: CGFloat = Constants.defaultInsets

  /// Horizontal offset for rightView (e.g. clear button)
  var rightViewHorizontalOffset: CGFloat = -Constants.defaultInsets

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return super.textRect(forBounds: bounds.inset(by: self.textInsets))
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return super.editingRect(forBounds: bounds.inset(by: self.textInsets))
  }

  override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    let original = super.leftViewRect(forBounds: bounds)
    return original.offsetBy(dx: self.leftViewHorizontalOffset, dy: 0)
  }

  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    let original = super.rightViewRect(forBounds: bounds)
    return original.offsetBy(dx: self.rightViewHorizontalOffset, dy: 0)
  }
}

func placeholderAttributeText(_ text: String) -> NSAttributedString {
  return NSAttributedString(
    string: text,
    attributes: [NSAttributedString.Key.foregroundColor: Colors.Text.placeholder.uiColor()]
  )
}
