import KsApi
import Library
import Prelude
import UIKit

private enum ProjectNavigationSelectorViewStyles {
  fileprivate enum Layout {
    fileprivate static let layoutMargins: CGFloat = Styles.grid(3)
    fileprivate static let selectedButtonBorderViewHeight: CGFloat = 2.0
    fileprivate static let selectedButtonBorderViewVerticalOriginModifier: CGFloat = 1.0
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
      |> \.backgroundColor .~ .ksr_white

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
      self.scrollView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
      self.scrollView.heightAnchor.constraint(equalTo: self.buttonsStackView.heightAnchor),
      self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
      self.contentView.heightAnchor.constraint(equalTo: self.heightAnchor)
    ])
  }

  private func setupConstraintsForSelectedButtonBorderView(sections: [NavigationSection]) {
    let buttonViews: [UIButton] = sections.map { section in
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
        |> UIButton.lens.titleLabel.font .~ UIFont.ksr_footnote().weighted(.semibold)
        |> UIButton.lens.titleLabel.textAlignment .~ .center

      return navigationButton
    }

    let buttonViewConstraints: [NSLayoutConstraint] = buttonViews.map { button -> [NSLayoutConstraint]? in
      guard let titleLabel = button.titleLabel else { return nil }

      return [
        titleLabel.topAnchor.constraint(equalTo: button.topAnchor),
        titleLabel.leftAnchor.constraint(equalTo: button.leftAnchor, constant: Styles.grid(2)),
        titleLabel.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -Styles.grid(2)),
        titleLabel.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -Styles.grid(2))
      ]
    }
    .compact()
    .flatMap { $0 }

    _ = self.buttonsStackView
      |> UIStackView.lens.arrangedSubviews .~ buttonViews

    let firstButton = self.buttonsStackView.arrangedSubviews[0]

    let leadingConstraint = self.selectedButtonBorderView.leadingAnchor
      .constraint(
        equalTo: firstButton.leadingAnchor
      )
    let widthConstraint = self.selectedButtonBorderView.widthAnchor
      .constraint(
        equalTo: firstButton.widthAnchor
      )

    NSLayoutConstraint.activate([
      leadingConstraint,
      widthConstraint,
      self.selectedButtonBorderView.heightAnchor
        .constraint(equalToConstant: ProjectNavigationSelectorViewStyles.Layout
          .selectedButtonBorderViewHeight),
      self.selectedButtonBorderView.bottomAnchor
        .constraint(
          equalTo: self.scrollView.bottomAnchor,
          constant: ProjectNavigationSelectorViewStyles.Layout.selectedButtonBorderViewVerticalOriginModifier
        )
    ])

    NSLayoutConstraint.activate(buttonViewConstraints)

    self.selectedButtonBorderViewLeadingConstraint = leadingConstraint
    self.selectedButtonBorderViewWidthConstraint = widthConstraint
  }

  private func pinSelectedButtonBorderView(toIndex index: Int) {
    guard let navigationSection = NavigationSection(rawValue: index),
      let button = self.buttonsStackView.arrangedSubviews.first(where: { $0.tag == index }),
      let buttonSection = NavigationSection(rawValue: button.tag),
      buttonSection == navigationSection else { return }

    let leadingConstant = button.frame.origin.x - safeAreaInsets.left

    // The value of the constraint is originally set to the width of the first button so we have subtract this each time we want to calculate the constant
    let widthConstant = button.frame.width - self.buttonsStackView.arrangedSubviews[0].frame
      .width

    UIView.animate(
      withDuration: 0.3,
      delay: 0.0,
      options: .curveEaseOut,
      animations: {
        self.contentView.setNeedsLayout()
        self.selectedButtonBorderViewLeadingConstraint?.constant = leadingConstant
        self.selectedButtonBorderViewWidthConstraint?.constant = widthConstant
        self.contentView.layoutIfNeeded()
      }
    )

    let origin = CGPoint(
      x: button.frame
        .minX,
      y: 0.0
    )
    let size = CGSize(
      width: button.frame.size
        .width,
      height: 1.0
    )
    let scrollToRect = CGRect(
      origin: origin,
      size: size
    )

    self.scrollView.scrollRectToVisible(scrollToRect, animated: true)
  }

  private func selectButton(atIndex index: Int) {
    let indexSection = NavigationSection(rawValue: index)

    for button in self.buttonsStackView.arrangedSubviews {
      let navigationSection = NavigationSection(rawValue: button.tag)
      let validNavigationSection = navigationSection != nil

      let isButtonSelected = validNavigationSection ? navigationSection == indexSection : false
      let buttonSelectedFont = isButtonSelected ? UIFont.ksr_footnote().weighted(.bold) : UIFont
        .ksr_footnote().weighted(.semibold)

      _ = (button as? UIButton)
        ?|> UIButton.lens.isSelected .~ isButtonSelected
        ?|> UIButton.lens.titleLabel.font .~ buttonSelectedFont
    }
  }

  // MARK: - Actions

  @objc
  private func buttonTapped(_ button: UIButton) {
    self.viewModel.inputs.buttonTapped(index: button.tag)
  }
}

// MARK: - Styles

private let selectedButtonBorderViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_trust_500
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(
      top: Styles.grid(0),
      left: Styles.grid(0),
      bottom: Styles.grid(1),
      right: Styles.grid(0)
    )
    |> \.spacing .~ Styles.grid(2)
}
