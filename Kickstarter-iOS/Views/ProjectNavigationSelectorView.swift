import KsApi
import Library
import Prelude
import UIKit

private enum ProjectNavigationSelectorViewStyles {
  fileprivate enum Layout {
    fileprivate static let bottomBorderViewHeight: CGFloat = 1.0
    fileprivate static let layoutMargins: CGFloat = Styles.grid(3)
    fileprivate static let selectedButtonBorderViewHeight: CGFloat = 2.0
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

  internal func configure() {
    self.viewModel.inputs.configureNavigationSelector()
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
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.animateButtonBottomBorderViewConstraints
      .observeForUI()
      .observeValues { [weak self] index in
        self?.pinSelectedButtonBorderView(toIndex: index)
      }

    self.viewModel.outputs.createButtons
      .observeForUI()
      .observeValues { [weak self] sections in
        self?.createButtons(sections)
      }

    self.viewModel.outputs.configureSelectedButtonBottomBorderView
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.setupConstraintsForSelectedButtonBorderView()
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
    _ = (self.bottomBorderView, self.scrollView)
      |> ksr_addSubviewToParent()

    _ = (self.buttonsStackView, self.scrollView)
      |> ksr_addSubviewToParent()

    _ = (self.selectedButtonBorderView, self.scrollView)
      |> ksr_addSubviewToParent()

    _ = (self.scrollView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  private func createButtons(_ navigationSections: [NavigationSection]) {
    _ = self.buttonsStackView
      |> UIStackView.lens.arrangedSubviews .~ navigationSections.enumerated().map { idx, section in
        UIButton()
          |> UIButton.lens.backgroundColor .~ .ksr_white
          |> UIButton.lens.tag .~ idx
          |> UIButton.lens.targets .~ [
            (self, #selector(buttonTapped(_:)), .touchUpInside)
          ]
          |> UIButton.lens.title(for: .normal) %~ { _ in section.displayString }
          |> UIButton.lens.titleColor(for: .normal) %~ { _ in .ksr_support_400 }
          |> UIButton.lens.titleColor(for: .selected) %~ { _ in .ksr_trust_500 }
          |> UIButton.lens.titleLabel.font .~ UIFont.ksr_footnote().bolded
      }
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.buttonsStackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
      self.buttonsStackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
      self.buttonsStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
      self.bottomBorderView.heightAnchor
        .constraint(equalToConstant: ProjectNavigationSelectorViewStyles.Layout.bottomBorderViewHeight),
      self.bottomBorderView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
      self.bottomBorderView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
      self.bottomBorderView.topAnchor
        .constraint(equalTo: self.buttonsStackView.bottomAnchor, constant: Styles.grid(2)),
      self.bottomBorderView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
    ])
  }

  private func setupConstraintsForSelectedButtonBorderView() {
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
      self.selectedButtonBorderView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
    ])

    self.selectedButtonBorderViewLeadingConstraint = leadingConstraint
    self.selectedButtonBorderViewWidthConstraint = widthConstraint
  }

  private func pinSelectedButtonBorderView(toIndex index: Int) {
    guard let button = self.buttonsStackView.arrangedSubviews[index] as? UIButton else { return }

    let leadingConstant = button.frame.origin.x - ProjectNavigationSelectorViewStyles.Layout.layoutMargins

    // The value of the constraint is originally set to the width of the first button so we have subtract this each time we want to calculate the constant
    let widthConstant = button.frame.width - self.buttonsStackView.arrangedSubviews[0].frame.width

    UIView.animate(
      withDuration: 0.3,
      delay: 0.0,
      options: .curveEaseOut,
      animations: {
        self.scrollView.setNeedsLayout()
        self.selectedButtonBorderViewLeadingConstraint?.constant = leadingConstant
        self.selectedButtonBorderViewWidthConstraint?.constant = widthConstant
        self.scrollView.layoutIfNeeded()

        // Moves the button to the approximate center of the scrollView if the device is not an iPad and in portrait orientation
        let isNotIpad = AppEnvironment.current.device.userInterfaceIdiom != .pad
        let isPortrait = UIDevice.current.orientation == .portrait

        if isPortrait, isNotIpad {
          switch NavigationSection(rawValue: index) {
          case .campaign:
            self.scrollView.contentOffset = CGPoint(x: self.center.x / 3, y: 0)
          case .overview:
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
          case .environmentalCommitments:
            self.scrollView.contentOffset = CGPoint(x: button.frame.minX / 2, y: 0)
          case .faq:
            self.scrollView.contentOffset = CGPoint(x: self.center.x / 3, y: 0)
          default:
            break
          }
        }
      }
    )
  }

  private func selectButton(atIndex index: Int) {
    for (idx, button) in self.buttonsStackView.arrangedSubviews.enumerated() {
      _ = (button as? UIButton)
        ?|> UIButton.lens.isSelected .~ (idx == index)
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
    |> \.layer.shadowColor .~ UIColor.ksr_black.cgColor
    |> \.layer.shadowOpacity .~ 0.12
    |> \.layer.shadowOffset .~ CGSize(width: 0, height: -2.0)
    |> \.layer.shadowRadius .~ CGFloat(1.0)
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
