import KDS
import UIKit

final class FloatingTabBar: UITabBar {
  private enum Constants {
    // Tab Bar
    static let tabBarItemSize: CGFloat = 40
    static let tabBarWidth: CGFloat = 152
    static let tabBarCornerRadius: CGFloat = 16
    static let tabBarShadowOpacity: Float = 0.28
    static let tabBarShadowRadius: CGFloat = 28
    static let tabBarShadowOffsetY: CGFloat = 8
    static let tabBarVerticalPadding: CGFloat = 8
    static let tabBarHorizontalInset: CGFloat = 12

    // Selected tab background
    static let selectedTabBackgroundCornerRadius: CGFloat = 8
    static let selectedTabBackgroundSize: CGSize = CGSize(
      width: Constants.tabBarItemSize,
      height: Constants.tabBarItemSize
    )

    // Animation
    static let selectionAnimationDuration: TimeInterval = 0.18
  }

  private let tabBarBackgroundView = UIView()
  private let selectedTabBackgroundView = UIView()

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundImage = UIImage()
    self.shadowImage = UIImage()
    self.isTranslucent = true
    self.backgroundColor = .clear

    self.tintColor = Colors.Nav.iconColorSelected.uiColor()
    self.unselectedItemTintColor = Colors.Nav.iconColorUnselected.uiColor()

    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.stackedLayoutAppearance.selected.iconColor = Colors.Nav.iconColorSelected.uiColor()
    appearance.stackedLayoutAppearance.normal.iconColor = Colors.Nav.iconColorUnselected.uiColor()

    // Hide labels – icons only.
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]

    standardAppearance = appearance
    scrollEdgeAppearance = appearance

    // Tab Bar pill background
    self.tabBarBackgroundView.backgroundColor = Colors.Nav.background.uiColor()
    self.tabBarBackgroundView.layer.cornerRadius = Constants.tabBarCornerRadius
    self.tabBarBackgroundView.layer.masksToBounds = false
    self.tabBarBackgroundView.layer.shadowColor = UIColor.black.cgColor
    self.tabBarBackgroundView.layer.shadowOpacity = Constants.tabBarShadowOpacity
    self.tabBarBackgroundView.layer.shadowRadius = Constants.tabBarShadowRadius
    self.tabBarBackgroundView.layer.shadowOffset = CGSize(width: 0, height: Constants.tabBarShadowOffsetY)

    // Selected tab pill
    self.selectedTabBackgroundView.backgroundColor = Colors.Nav.iconHighlight.uiColor()
    self.selectedTabBackgroundView.layer.cornerRadius = Constants.selectedTabBackgroundCornerRadius
    self.selectedTabBackgroundView.clipsToBounds = true

    addSubview(self.tabBarBackgroundView)
    addSubview(self.selectedTabBackgroundView)
    sendSubviewToBack(self.tabBarBackgroundView)
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

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.layoutPillAndItems()

    self.updateSelection(animated: false)
  }

  /// Centers the pill and lays out the tab item views inside it.
  private func layoutPillAndItems() {
    guard let itemViews = sortedItemViews(), itemViews.isEmpty == false else {
      self.tabBarBackgroundView.isHidden = true
      self.selectedTabBackgroundView.isHidden = true
      return
    }

    self.tabBarBackgroundView.isHidden = false
    self.selectedTabBackgroundView.isHidden = false

    let pillHeight = Constants.tabBarItemSize + (Constants.tabBarVerticalPadding * 2)
    let iconsCenterY = itemViews[0].center.y

    let pillFrame = CGRect(
      x: (bounds.width - Constants.tabBarWidth) / 2.0,
      y: iconsCenterY - (pillHeight / 2.0),
      width: Constants.tabBarWidth,
      height: pillHeight
    )
    self.tabBarBackgroundView.frame = pillFrame

    /// Evenly space icons within the pill with horizontal insets.
    let count = CGFloat(itemViews.count)
    let usableWidth = Constants.tabBarWidth - (Constants.tabBarHorizontalInset * 2)
    let totalIconWidth = count * Constants.tabBarItemSize
    let spacing = (usableWidth - totalIconWidth) / max(count - 1, 1)

    var currentCenterX =
      pillFrame.minX + Constants.tabBarHorizontalInset + (Constants.tabBarItemSize / 2.0)

    for view in itemViews {
      view.frame = CGRect(
        x: currentCenterX - (Constants.tabBarItemSize / 2.0),
        y: pillFrame.midY - (Constants.tabBarItemSize / 2.0),
        width: Constants.tabBarItemSize,
        height: Constants.tabBarItemSize
      )
      currentCenterX += Constants.tabBarItemSize + spacing
    }
  }

  /// Moves the green selection background behind the selected item.
  private func updateSelection(animated: Bool) {
    guard
      let selectedItem,
      let itemViews = sortedItemViews(),
      let selectedIndex = items?.firstIndex(of: selectedItem),
      selectedIndex < itemViews.count
    else { return }

    let targetItemView = itemViews[selectedIndex]
    let indicatorSize = Constants.selectedTabBackgroundSize

    let frame = CGRect(
      x: targetItemView.center.x - (indicatorSize.width / 2.0),
      y: self.tabBarBackgroundView.frame.midY - (indicatorSize.height / 2.0),
      width: indicatorSize.width,
      height: indicatorSize.height
    )

    if animated {
      UIView.animate(
        withDuration: Constants.selectionAnimationDuration,
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

  /// Internal tab item views sorted left → right.
  private func sortedItemViews() -> [UIView]? {
    let controls = subviews.compactMap { $0 as? UIControl }

    return controls.isEmpty ? nil : controls.sorted { $0.frame.minX < $1.frame.minX }
  }
}
