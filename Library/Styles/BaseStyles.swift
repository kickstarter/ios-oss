import Prelude
import Prelude_UIKit
import UIKit

public enum Styles {
  public static let cornerRadius: CGFloat = 4.0
  public static let minTouchSize: CGSize = CGSize(width: 44, height: 44)
  public static let projectPageLeftRightInset: CGFloat = Styles.grid(3)
  public static let projectPageTopBottomInset: CGFloat = Styles.grid(4)

  public static func grid(_ count: Int) -> CGFloat {
    return 6.0 * CGFloat(count)
  }

  public static func gridHalf(_ count: Int) -> CGFloat {
    return self.grid(count) / 2.0
  }
}

public typealias ActivityIndicatorStyle = (UIActivityIndicatorView) -> UIActivityIndicatorView
public typealias BarButtonStyle = (UIBarButtonItem) -> UIBarButtonItem
public typealias ButtonStyle = (UIButton) -> UIButton
public typealias CollectionViewStyle = (UICollectionView) -> UICollectionView
public typealias ImageViewStyle = (UIImageView) -> UIImageView
public typealias LabelStyle = (UILabel) -> UILabel
public typealias LayerStyle = (CALayer) -> CALayer
public typealias NavigationBarStyle = (UINavigationBar?) -> UINavigationBar?
public typealias PageControlStyle = (UIPageControl) -> UIPageControl
public typealias ScrollStyle = (UIScrollView) -> UIScrollView
public typealias StackViewStyle = (UIStackView) -> UIStackView
public typealias SwitchControlStyle = (UISwitch) -> UISwitch
public typealias TableViewStyle = (UITableView) -> UITableView
public typealias TableViewCellStyle = (UITableViewCell) -> UITableViewCell
public typealias TextFieldStyle = (UITextField) -> UITextField
public typealias TextViewStyle = (UITextView) -> UITextView
public typealias ToolbarStyle = (UIToolbar) -> UIToolbar
public typealias ViewStyle = (UIView) -> UIView

public func baseControllerStyle<VC: UIViewControllerProtocol>() -> ((VC) -> VC) {
  return VC.lens.view.backgroundColor .~ LegacyColors.ksr_white.uiColor()
    <> (VC.lens.navigationController .. navBarLens) %~ { $0.map(baseNavigationBarStyle) }
}

public func baseActivityIndicatorStyle(indicator: UIActivityIndicatorView) -> UIActivityIndicatorView {
  return indicator
    |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
    |> UIActivityIndicatorView.lens.style .~ .medium
    |> UIActivityIndicatorView.lens.color .~ LegacyColors.ksr_support_700.uiColor()
}

/**
 - parameter radius: The corner radius. This parameter is optional, and will use a default value if omitted.

 - returns: A view transformer that rounds corners, sets background color, and sets border color.
 */
public func cardStyle<V: UIViewProtocol>(cornerRadius radius: CGFloat = 0) -> ((V) -> V) {
  return roundedStyle(cornerRadius: radius)
    <> V.lens.layer.borderColor .~ LegacyColors.ksr_support_300.uiColor().cgColor
    <> V.lens.layer.borderWidth .~ 1.0
    <> V.lens.backgroundColor .~ LegacyColors.ksr_white.uiColor()
}

public func darkCardStyle<V: UIViewProtocol>
(cornerRadius radius: CGFloat = Styles.cornerRadius) -> ((V) -> V) {
  return cardStyle(cornerRadius: radius)
    <> V.lens.layer.borderColor .~ LegacyColors.ksr_support_400.uiColor().cgColor
}

public func adaptableStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    let alignment: UIStackView.Alignment = (isAccessibilityCategory ? .leading : .center)
    let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
    let distribution: UIStackView.Distribution = (isAccessibilityCategory ? .equalSpacing : .fill)
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    return stackView
      |> \.alignment .~ alignment
      |> \.axis .~ axis
      |> \.distribution .~ distribution
      |> \.spacing .~ spacing
  }
}

public let containerViewBackgroundStyle =
  UIView.lens.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()

public func dropShadowStyle<V: UIViewProtocol>(
  radius: CGFloat = 2.0,
  offset: CGSize = .init(width: 0, height: 1),
  shadowOpacity: Float = 0.17
) -> ((V) -> V) {
  return
    V.lens.layer.shadowColor .~ LegacyColors.ksr_black.uiColor().cgColor
      <> V.lens.layer.shadowOpacity .~ shadowOpacity
      <> V.lens.layer.shadowRadius .~ radius
      <> V.lens.layer.masksToBounds .~ false
      <> V.lens.layer.shouldRasterize .~ true
      <> V.lens.layer.shadowOffset .~ offset
}

public func dropShadowStyleMedium<V: UIViewProtocol>() -> ((V) -> V) {
  return dropShadowStyle(radius: 5.0, offset: .init(width: 0, height: 2.0))
}

public func dropShadowStyleLarge<V: UIViewProtocol>() -> ((V) -> V) {
  return dropShadowStyle(radius: 6.0, offset: .init(width: 0, height: 3.0))
}

public let feedTableViewCellStyle: (UITableViewCell) -> UITableViewCell = { cell in
  cell
    |> baseTableViewCellStyle()
    |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
      cell.traitCollection.isRegularRegular
        ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(30))
        : .init(topBottom: Styles.gridHalf(3), leftRight: Styles.grid(2))
    }
}

public let formTextInputStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.autocapitalizationType .~ UITextAutocapitalizationType.none
    |> \.autocorrectionType .~ UITextAutocorrectionType.no
    |> \.spellCheckingType .~ UITextSpellCheckingType.no
}

public let formFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> formTextInputStyle
    |> \.backgroundColor .~ UIColor.clear
    |> \.borderStyle .~ UITextField.BorderStyle.none
    |> \.font .~ UIFont.ksr_body()
    |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
    |> \.tintColor .~ LegacyColors.ksr_create_700.uiColor()
}

public let ignoresInvertColorsImageViewStyle: ImageViewStyle = { (imageView: UIImageView) in
  imageView
    |> \.accessibilityIgnoresInvertColors .~ true
}

public let separatorStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ LegacyColors.ksr_support_300.uiColor()
    |> \.accessibilityElementsHidden .~ true
}

public let separatorStyleDark: ViewStyle = { view in
  view
    |> \.backgroundColor .~ LegacyColors.ksr_support_300.uiColor()
    |> \.accessibilityElementsHidden .~ true
}

/**
 - parameter r: The corner radius. This parameter is optional, and will use a default value if omitted.

 - returns: A view transformer that rounds corners.
 */
public func roundedStyle<V: UIViewProtocol>(cornerRadius r: CGFloat = Styles.cornerRadius) -> ((V) -> V) {
  return V.lens.clipsToBounds .~ true
    <> V.lens.layer.masksToBounds .~ true
    <> V.lens.layer.cornerRadius .~ r
}

public let baseSwitchControlStyle: SwitchControlStyle = { switchControl in
  switchControl
    |> \.onTintColor .~ LegacyColors.ksr_create_700.uiColor()
    |> \.tintColor .~ LegacyColors.ksr_support_100.uiColor()
}

// MARK: - Private Helpers

// Just a lil helper lens for getting inside a nav controller's nav bar.
private let navBarLens: Lens<UINavigationController?, UINavigationBar?> = Lens(
  view: { $0?.navigationBar },
  set: { _, whole in whole }
)

private let baseNavigationBarStyle =
  UINavigationBar.lens.titleTextAttributes .~ [
    NSAttributedString.Key.foregroundColor: LegacyColors.ksr_black.uiColor()
  ]
  <> UINavigationBar.lens.isTranslucent .~ false
  <> UINavigationBar.lens.tintColor .~ LegacyColors.ksr_create_700.uiColor()
  <> UINavigationBar.lens.standardAppearance .~ navigationBarAppearance
  <> UINavigationBar.lens.scrollEdgeAppearance .~ navigationBarAppearance

private var navigationBarAppearance: UINavigationBarAppearance {
  let navBarAppearance = UINavigationBarAppearance()
  navBarAppearance.configureWithOpaqueBackground()
  navBarAppearance.backgroundColor = LegacyColors.ksr_white.uiColor()

  return navBarAppearance
}

public let keyboardToolbarStyle: ToolbarStyle = { toolbar -> UIToolbar in
  toolbar
    |> roundedStyle(cornerRadius: 8)
    |> \.layer.backgroundColor .~ LegacyColors.ksr_white.uiColor().cgColor
    |> \.layer.maskedCorners .~ [.layerMaxXMinYCorner, .layerMinXMinYCorner]
}

public let keyboardDoneButtonStyle: ButtonStyle = { button -> UIButton in
  button
    |> greenButtonStyle
}

public let verticalStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
}
