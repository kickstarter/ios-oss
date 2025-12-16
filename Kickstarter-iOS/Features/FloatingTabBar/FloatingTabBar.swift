import KDS
import UIKit

/* A custom floating-style `UITabBar` that visually groups tab items inside a
 - Sets tabs in a centered container using a horizontal `UIStackView`.
 - Draws a background “pill” behind the tab items, including shadow.
 - Animates a selection indicator view behind the currently selected tab
 - Hides tab item titles and presents an icon-only navigation experience.
 */

final class FloatingTabBar: UITabBar {
  private enum Constants {
    static let tabBarItemSize: CGFloat = 40
    static let tabBarWidth: CGFloat = 152
    static let tabBarCornerRadius: CGFloat = 16
    static let tabBarShadowOpacity: Float = 0.28
    static let tabBarShadowRadius: CGFloat = 28
    static let tabBarShadowOffsetY: CGFloat = 8
    static let tabBarVerticalPadding: CGFloat = 8
    static let tabBarHorizontalInset: CGFloat = 12

    static let selectedTabBackgroundCornerRadius: CGFloat = 8
    static let selectedTabBackgroundSize: CGSize = CGSize(
      width: Constants.tabBarItemSize,
      height: Constants.tabBarItemSize
    )
    static let selectedTabAnimationDuration: TimeInterval = 0.18
  }

  private let tabBarBackgroundView = UIView()
  private let selectedTabBackgroundView = UIView()

  private let tabsStackView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .equalSpacing
    view.isUserInteractionEnabled = false
    return view
  }()

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundImage = UIImage()
    self.shadowImage = UIImage()
    self.isTranslucent = true
    self.backgroundColor = .clear

    self.tintColor = Colors.FloatingTabBar.iconColorSelected.uiColor()
    self.unselectedItemTintColor = Colors.FloatingTabBar.iconColorUnselected.uiColor()

    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.stackedLayoutAppearance.selected.iconColor = Colors.FloatingTabBar.iconColorSelected.uiColor()
    appearance.stackedLayoutAppearance.normal.iconColor = Colors.FloatingTabBar.iconColorUnselected.uiColor()

    // Hide icon labels.
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]

    self.standardAppearance = appearance
    self.scrollEdgeAppearance = appearance

    self.setupSubviews()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  /// Move the green background when the selected item changes.
  override var selectedItem: UITabBarItem? {
    didSet {
      self.updateSelection(animated: true)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.layoutTabs()

    self.updateSelection(animated: false)
  }

  private func setupSubviews() {
    self.tabBarBackgroundView.backgroundColor = Colors.FloatingTabBar.background.uiColor()
    self.tabBarBackgroundView.layer.cornerRadius = Constants.tabBarCornerRadius
    self.tabBarBackgroundView.layer.masksToBounds = false
    self.tabBarBackgroundView.layer.shadowColor = UIColor.black.cgColor
    self.tabBarBackgroundView.layer.shadowOpacity = Constants.tabBarShadowOpacity
    self.tabBarBackgroundView.layer.shadowRadius = Constants.tabBarShadowRadius
    self.tabBarBackgroundView.layer.shadowOffset = CGSize(width: 0, height: Constants.tabBarShadowOffsetY)

    self.selectedTabBackgroundView.backgroundColor = Colors.FloatingTabBar.iconHighlight.uiColor()
    self.selectedTabBackgroundView.layer.cornerRadius = Constants.selectedTabBackgroundCornerRadius
    self.selectedTabBackgroundView.clipsToBounds = true

    addSubview(self.tabBarBackgroundView)
    addSubview(self.selectedTabBackgroundView)
    addSubview(self.tabsStackView)

    sendSubviewToBack(self.tabBarBackgroundView)
  }

  /// Centers and lays out the tabs.
  private func layoutTabs() {
    let tabViews = self.sortedItemViews()
    let isEmpty = tabViews.isEmpty

    self.tabBarBackgroundView.isHidden = isEmpty
    self.selectedTabBackgroundView.isHidden = isEmpty
    self.tabsStackView.isHidden = isEmpty

    guard isEmpty == false else { return }

    let tabHeight = Constants.tabBarItemSize + (Constants.tabBarVerticalPadding * 2)
    let iconsCenterY = tabViews[0].center.y

    let tabFrame = CGRect(
      x: (bounds.width - Constants.tabBarWidth) / 2.0,
      y: iconsCenterY - (tabHeight / 2.0),
      width: Constants.tabBarWidth,
      height: tabHeight
    )
    self.tabBarBackgroundView.frame = tabFrame

    self.tabsStackView.frame = tabFrame.insetBy(
      dx: Constants.tabBarHorizontalInset,
      dy: Constants.tabBarVerticalPadding
    )

    self.syncStackViewArrangedSubviews(tabViews)
  }

  /// Make sure the tab StackView items are in the correct order.
  /// UITabBar manages these views, so we re-sync them during layout.
  private func syncStackViewArrangedSubviews(_ tabViews: [UIView]) {
    guard self.tabsStackView.arrangedSubviews != tabViews else { return }

    for view in self.tabsStackView.arrangedSubviews {
      self.tabsStackView.removeArrangedSubview(view)

      view.removeFromSuperview()
    }

    for view in tabViews {
      view.translatesAutoresizingMaskIntoConstraints = true
      view.frame.size = CGSize(width: Constants.tabBarItemSize, height: Constants.tabBarItemSize)

      self.tabsStackView.addArrangedSubview(view)
    }
  }

  /// Animates the green selection background behind the selected item.
  private func updateSelection(animated: Bool) {
    guard let selectedItem, let targetItemView = selectedItemView(for: selectedItem) else { return }

    let indicatorSize = Constants.selectedTabBackgroundSize

    let frame = CGRect(
      x: targetItemView.center.x - (indicatorSize.width / 2.0),
      y: self.tabBarBackgroundView.frame.midY - (indicatorSize.height / 2.0),
      width: indicatorSize.width,
      height: indicatorSize.height
    )

    if animated {
      UIView.animate(
        withDuration: Constants.selectedTabAnimationDuration,
        delay: 0,
        options: [.curveEaseInOut],
        animations: {
          self.selectedTabBackgroundView.frame = frame
        },
        completion: nil
      )
    } else {
      self.selectedTabBackgroundView.frame = frame
    }
  }

  /// Returns the view for the given tab item`.
  /// `UITabBar` does not expose item views publicly, but the items and their views are created in the same order, so we can just match them by index.
  private func selectedItemView(for selectedItem: UITabBarItem) -> UIView? {
    guard let items, let selectedIndex = items.firstIndex(of: selectedItem) else { return nil }

    let tabViews = self.sortedItemViews()

    guard selectedIndex < tabViews.count else { return nil }

    return tabViews[selectedIndex]
  }

  /// Sorts views left to right.
  private func sortedItemViews() -> [UIView] {
    subviews
      .compactMap { $0 as? UIControl }
      .sorted { $0.frame.minX < $1.frame.minX }
  }
}
