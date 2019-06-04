import Prelude
import Prelude_UIKit
import UIKit

public enum Styles {
  public static let cornerRadius: CGFloat = 4.0
  public static let minTouchSize: CGSize = CGSize(width: 44, height: 44)

  public static func grid(_ count: Int) -> CGFloat {
    return 6.0 * CGFloat(count)
  }

  public static func gridHalf(_ count: Int) -> CGFloat {
    return self.grid(count) / 2.0
  }
}

public typealias ButtonStyle = (UIButton) -> UIButton
public typealias CollectionViewStyle = (UICollectionView) -> UICollectionView
public typealias ImageViewStyle = (UIImageView) -> UIImageView
public typealias LabelStyle = (UILabel) -> UILabel
public typealias LayerStyle = (CALayer) -> CALayer
public typealias ScrollStyle = (UIScrollView) -> UIScrollView
public typealias StackViewStyle = (UIStackView) -> UIStackView
public typealias TableViewStyle = (UITableView) -> UITableView
public typealias TextFieldStyle = (UITextField) -> UITextField
public typealias TextViewStyle = (UITextView) -> UITextView
public typealias ViewStyle = (UIView) -> UIView

public func baseControllerStyle<VC: UIViewControllerProtocol>() -> ((VC) -> VC) {
  return VC.lens.view.backgroundColor .~ .white
    <> (VC.lens.navigationController .. navBarLens) %~ { $0.map(baseNavigationBarStyle) }
}

public func baseTableControllerStyle<TVC: UITableViewControllerProtocol>
(estimatedRowHeight: CGFloat = 44.0) -> ((TVC) -> TVC) {
  let style = baseControllerStyle()
    <> TVC.lens.view.backgroundColor .~ .white
    <> TVC.lens.tableView.rowHeight .~ UITableView.automaticDimension
    <> TVC.lens.tableView.estimatedRowHeight .~ estimatedRowHeight

  return style <> TVC.lens.tableView.separatorStyle .~ .none
}

public func baseTableViewCellStyle<TVC: UITableViewCellProtocol>() -> ((TVC) -> TVC) {
  return
    TVC.lens.contentView.layoutMargins %~~ { _, cell in
      if cell.traitCollection.isRegularRegular {
        return .init(topBottom: Styles.grid(3), leftRight: Styles.grid(12))
      }
      return .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
    }
    <> TVC.lens.backgroundColor .~ .white
    <> (TVC.lens.contentView .. UIView.lens.preservesSuperviewLayoutMargins) .~ false
    <> TVC.lens.layoutMargins .~ .init(all: 0.0)
    <> TVC.lens.preservesSuperviewLayoutMargins .~ false
    <> TVC.lens.selectionStyle .~ .none
}

public func baseActivityIndicatorStyle(indicator: UIActivityIndicatorView) -> UIActivityIndicatorView {
  return indicator
    |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
    |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
    |> UIActivityIndicatorView.lens.color .~ .ksr_soft_black
}

/**
 - parameter radius: The corner radius. This parameter is optional, and will use a default value if omitted.

 - returns: A view transformer that rounds corners, sets background color, and sets border color.
 */
public func cardStyle<V: UIViewProtocol>(cornerRadius radius: CGFloat = 0) -> ((V) -> V) {
  return roundedStyle(cornerRadius: radius)
    <> V.lens.layer.borderColor .~ UIColor.ksr_grey_500.cgColor
    <> V.lens.layer.borderWidth .~ 1.0
    <> V.lens.backgroundColor .~ .white
}

public func darkCardStyle<V: UIViewProtocol>
(cornerRadius radius: CGFloat = Styles.cornerRadius) -> ((V) -> V) {
  return cardStyle(cornerRadius: radius)
    <> V.lens.layer.borderColor .~ UIColor.ksr_text_dark_grey_500.cgColor
}

public let containerViewBackgroundStyle =
  UIView.lens.backgroundColor .~ .ksr_grey_100

public func dropShadowStyle<V: UIViewProtocol>(
  radius: CGFloat = 2.0,
  offset: CGSize = .init(width: 0, height: 1)
) -> ((V) -> V) {
  return
    V.lens.layer.shadowColor .~ UIColor.black.cgColor
    <> V.lens.layer.shadowOpacity .~ 0.17
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

public let feedTableViewCellStyle = baseTableViewCellStyle()
  <> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
    cell.traitCollection.isRegularRegular
      ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(30))
      : .init(topBottom: Styles.gridHalf(3), leftRight: Styles.grid(2))
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
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.tintColor .~ UIColor.ksr_green_700
}

public let ignoresInvertColorsImageViewStyle: ImageViewStyle = { (imageView: UIImageView) in
  imageView
    |> \.accessibilityIgnoresInvertColors .~ true
}

public let separatorStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.ksr_grey_400
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

// Just a lil helper lens for getting inside a nav controller's nav bar.
private let navBarLens: Lens<UINavigationController?, UINavigationBar?> = Lens(
  view: { $0?.navigationBar },
  set: { _, whole in whole }
)

private let baseNavigationBarStyle =
  UINavigationBar.lens.titleTextAttributes .~ [
    NSAttributedString.Key.foregroundColor: UIColor.black
  ]
  <> UINavigationBar.lens.isTranslucent .~ false
  <> UINavigationBar.lens.barTintColor .~ .white
  <> UINavigationBar.lens.tintColor .~ .ksr_green_700
