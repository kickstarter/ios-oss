import KsApi
import Library
import Prelude
import UIKit

private enum ProjectNavigationSelectorViewStyles {
  fileprivate enum Layout {
    fileprivate static let bottomBorderViewHeight: CGFloat = 2.0
    fileprivate static let layoutMargins: CGFloat = Styles.grid(3)
    fileprivate static let selectedButtonBorderViewHeight: CGFloat = 2.0
    fileprivate static let selectedButtonBorderViewWidthExtensionLeading: CGFloat = 10.0
    fileprivate static let selectedButtonBorderViewWidthExtensionFull: CGFloat = 20.0
  }
}

internal protocol ProjectNavigationSelectorViewDelegate: AnyObject {
  func projectNavigationSelectorViewDidSelect(_ view: ProjectNavigationSelectorView, index: Int)
}

final class ProjectNavigationSelectorView: UIView {
  // MARK: - Properties

  internal weak var delegate: ProjectNavigationSelectorViewDelegate?
  private var selectedButtonBorderViewLeadingConstraint: NSLayoutConstraint?
  private var selectedButtonBorderViewWidthConstraint: NSLayoutConstraint?
  private let viewModel: ProjectNavigationSelectorViewModelType = ProjectNavigationSelectorViewModel()

  private lazy var bottomBorderView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var buttonsStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var selectedButtonBorderView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var scrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var contentView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal func configure(with projectProperties: (Project, RefTag?)) {
    self.viewModel.inputs.configureNavigationSelector(with: projectProperties)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.layoutMargins .~ .init(all: ProjectNavigationSelectorViewStyles.Layout.layoutMargins)

    _ = self.bottomBorderView
      |> bottomBorderViewStyle

    _ = self.buttonsStackView
      |> rootStackViewStyle

    _ = self.selectedButtonBorderView
      |> selectedButtonBorderViewStyle

    _ = self.scrollView
      |> \.showsHorizontalScrollIndicator .~ false
      |> \.showsVerticalScrollIndicator .~ false
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.animateButtonBottomBorderViewConstraints
      .observeForUI()
      .observeValues { [weak self] index in
        self?.pinSelectedButtonBorderView(toIndex: index)
      }

    self.viewModel.outputs.configureNavigationSelectorUI
      .observeForUI()
      .observeValues { [weak self] sections in
        self?.setupConstraintsForSelectedButtonBorderView(sections: sections)
      }

    self.viewModel.outputs.notifyDelegateProjectNavigationSelectorDidSelect
      .observeForUI()
      .observeValues { [weak self] index in
        guard let self = self else { return }
        self.delegate?.projectNavigationSelectorViewDidSelect(self, index: index)
      }

    self.viewModel.outputs.updateNavigationSelectorUI
      .observeForUI()
      .observeValues { [weak self] index in
        self?.selectButton(atIndex: index)
      }
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.contentView, self)
      |> ksr_addSubviewToParent()

    _ = (self.scrollView, self.contentView)
      |> ksr_addSubviewToParent()

    _ = (self.bottomBorderView, self.contentView)
      |> ksr_addSubviewToParent()

    _ = (self.selectedButtonBorderView, self.contentView)
      |> ksr_addSubviewToParent()

    _ = (self.buttonsStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.scrollView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.scrollView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
      self.scrollView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
      self.scrollView.heightAnchor.constraint(equalTo: self.buttonsStackView.heightAnchor),
      self.bottomBorderView.heightAnchor
        .constraint(equalToConstant: ProjectNavigationSelectorViewStyles.Layout.bottomBorderViewHeight),
      self.bottomBorderView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
      self.bottomBorderView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
      self.bottomBorderView.topAnchor
        .constraint(equalTo: self.scrollView.bottomAnchor, constant: Styles.grid(1)),
      self.contentView.bottomAnchor.constraint(equalTo: self.bottomBorderView.bottomAnchor),
      self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
      self.contentView.heightAnchor.constraint(equalTo: self.heightAnchor)
    ])
  }

  private func setupConstraintsForSelectedButtonBorderView(sections: [NavigationSection]) {
    _ = self.buttonsStackView
      |> UIStackView.lens.arrangedSubviews .~ sections.map { section in
        var sectionIndex = 0

        switch section {
        case .overview:
          sectionIndex = 0
        case .campaign:
          sectionIndex = 1
        case .faq:
          sectionIndex = 2
        case .risks:
          sectionIndex = 3
        case .environmentalCommitments:
          sectionIndex = 4
        }

        let navigationButton = UIButton()
          |> UIButton.lens.backgroundColor .~ .ksr_white
          |> UIButton.lens.tag .~ sectionIndex
          |> UIButton.lens.targets .~ [
            (self, #selector(buttonTapped(_:)), .touchUpInside)
          ]
          |> UIButton.lens.title(for: .normal) %~ { _ in section.displayString.uppercased() }
          |> UIButton.lens.titleColor(for: .normal) %~ { _ in .ksr_support_400 }
          |> UIButton.lens.titleColor(for: .selected) %~ { _ in .ksr_trust_500 }
          |> UIButton.lens.titleLabel.font .~ UIFont.ksr_footnote().bolded

        return navigationButton
      }

    let firstButton = self.buttonsStackView.arrangedSubviews[0]

    let leadingConstraint = self.selectedButtonBorderView.leadingAnchor
      .constraint(
        equalTo: firstButton.leadingAnchor,
        constant: -ProjectNavigationSelectorViewStyles.Layout.selectedButtonBorderViewWidthExtensionLeading
      )
    let widthConstraint = self.selectedButtonBorderView.widthAnchor
      .constraint(
        equalTo: firstButton.widthAnchor,
        constant: ProjectNavigationSelectorViewStyles.Layout.selectedButtonBorderViewWidthExtensionFull
      )

    NSLayoutConstraint.activate([
      leadingConstraint,
      widthConstraint,
      self.selectedButtonBorderView.heightAnchor
        .constraint(equalToConstant: ProjectNavigationSelectorViewStyles.Layout
          .selectedButtonBorderViewHeight),
      self.selectedButtonBorderView.bottomAnchor.constraint(equalTo: self.bottomBorderView.topAnchor)
    ])

    self.selectedButtonBorderViewLeadingConstraint = leadingConstraint
    self.selectedButtonBorderViewWidthConstraint = widthConstraint
  }

  private func pinSelectedButtonBorderView(toIndex index: Int) {
    guard let navigationSection = NavigationSection(rawValue: index),
      let button = self.buttonsStackView.arrangedSubviews.first(where: { $0.tag == index }),
      let buttonSection = NavigationSection(rawValue: button.tag),
      buttonSection == navigationSection else { return }

    let leadingConstant = button.frame.origin.x - ProjectNavigationSelectorViewStyles.Layout
      .layoutMargins - safeAreaInsets.left - ProjectNavigationSelectorViewStyles.Layout
      .selectedButtonBorderViewWidthExtensionLeading

    // The value of the constraint is originally set to the width of the first button so we have subtract this each time we want to calculate the constant
    let widthConstant = button.frame.width - self.buttonsStackView.arrangedSubviews[0].frame
      .width + ProjectNavigationSelectorViewStyles.Layout.selectedButtonBorderViewWidthExtensionFull

    UIView.animate(
      withDuration: 0.3,
      delay: 0.0,
      options: .curveEaseOut,
      animations: {
        self.contentView.setNeedsLayout()
        self.selectedButtonBorderViewLeadingConstraint?.constant = leadingConstant
        self.selectedButtonBorderViewWidthConstraint?.constant = widthConstant
        self.contentView.layoutIfNeeded()

        // Moves the button to the approximate center of the scrollView if the device is not an iPad, not in portrait orientation or fits within the bounds of the screens width
//        let isNotIpad = AppEnvironment.current.device.userInterfaceIdiom != .pad
//        let isPortrait = UIDevice.current.orientation == .portrait
//        let isButtonStackViewScrollable = self.buttonsStackView.frame.width > self.scrollView.frame.width
//
//        if isPortrait, isNotIpad, isButtonStackViewScrollable {
//          switch NavigationSection(rawValue: index) {
//          case .campaign:
//            self.scrollView.contentOffset = CGPoint(x: self.center.x / 3, y: 0)
//          case .overview:
//            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
//          case .environmentalCommitments:
//            self.scrollView.contentOffset = CGPoint(x: button.frame.midX / 2, y: 0)
//          case .faq, .risks:
//            self.scrollView.contentOffset = CGPoint(x: self.center.x / 3, y: 0)
//          default:
//            break
//          }
//        }
      }
    )
  }

  private func selectButton(atIndex index: Int) {
    let indexSection = NavigationSection(rawValue: index)

    for button in self.buttonsStackView.arrangedSubviews {
      let navigationSection = NavigationSection(rawValue: button.tag)
      let validNavigationSection = navigationSection != nil

      _ = (button as? UIButton)
        ?|> UIButton.lens.isSelected .~ (validNavigationSection ? navigationSection == indexSection : false)
    }
  }

  // MARK: - Actions

  @objc
  private func buttonTapped(_ button: UIButton) {
    self.viewModel.inputs.buttonTapped(index: button.tag)
  }
}

// MARK: - Styles

private let bottomBorderViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_support_100
    |> dropShadowStyle()
}

private let selectedButtonBorderViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_trust_500
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(
      top: Styles.grid(1),
      left: Styles.grid(3),
      bottom: Styles.grid(1),
      right: Styles.grid(3)
    )
    |> \.spacing .~ Styles.grid(6)
}
