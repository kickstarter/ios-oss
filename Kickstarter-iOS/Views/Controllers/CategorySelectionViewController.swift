import Foundation
import KsApi
import Library
import Prelude
import SpriteKit
import UIKit

public final class CategorySelectionViewController: UIViewController {
  private let dataSource = CategorySelectionDataSource()
  private let viewModel: CategorySelectionViewModelType = CategorySelectionViewModel()

  private lazy var collectionView: UICollectionView = {
    UICollectionView(
      frame: .zero,
      collectionViewLayout: self.pillLayout
    )
      |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.always
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pillLayout: PillLayout = {
    let layout = PillLayout(
      minimumInteritemSpacing: Styles.grid(1),
      minimumLineSpacing: Styles.grid(1),
      sectionInset: .init(
        top: Styles.grid(1),
        left: Styles.grid(3),
        bottom: Styles.grid(3),
        right: Styles.grid(3)
      )
    )

    return layout
  }()

  private lazy var headerView: UIView = {
    CategorySelectionHeaderView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var buttonsView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var continueButton: UIButton = { UIButton(type: .custom) }()
  private lazy var skipButton: UIBarButtonItem = {
    UIBarButtonItem(
      title: Strings.general_navigation_buttons_skip(),
      style: .plain,
      target: self,
      action: #selector(CategorySelectionViewController.skipButtonTapped)
    )
  }()

  private lazy var buttonsStackView: UIStackView = { UIStackView(frame: .zero) }()

  public override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> baseControllerStyle()

    _ = self.navigationController?.navigationBar
      ?|> \.backgroundColor .~ .clear
      ?|> \.shadowImage .~ UIImage()
      ?|> \.isTranslucent .~ true

    _ = self.collectionView
      |> \.backgroundColor .~ .white
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

    self.navigationItem.setRightBarButton(self.skipButton, animated: false)

    self.collectionView.registerCellClass(PillCell.self)
    self.collectionView.register(
      CategoryCollectionViewSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CategoryCollectionViewSectionHeaderView.defaultReusableId
    )

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.skipButton
      |> \.tintColor .~ .white

    _ = self.headerView
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.buttonsView
      |> \.backgroundColor .~ .white
      |> \.layoutMargins .~ .init(all: Styles.grid(2))
      |> \.layer.shadowColor .~ UIColor.black.cgColor
      |> \.layer.shadowOpacity .~ 0.12
      |> \.layer.shadowOffset .~ CGSize(width: 0, height: -1.0)
      |> \.layer.shadowRadius .~ CGFloat(1.0)

    _ = self.buttonsStackView
      |> verticalStackViewStyle

    _ = self.continueButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let bottomSafeAreaInset = self.view.safeAreaInsets.bottom
    let bottomInset = self.buttonsView.frame.height - bottomSafeAreaInset
    self.collectionView.contentInset.bottom = bottomInset
    self.collectionView.scrollIndicatorInsets.bottom = bottomInset
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadCategorySections
      .observeForUI()
      .observeValues { [weak self] sectionTitles, categories in
        self?.dataSource.load(sectionTitles, categories: categories)
        self?.collectionView.reloadData()
      }
  }

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.collectionView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.buttonsView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.buttonsStackView, self.buttonsView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.continueButton], self.buttonsStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.collectionView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
      self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.buttonsView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.buttonsView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.buttonsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Accessors

  @objc func skipButtonTapped() {
    self.dismiss(animated: true)
  }
}

// MARK: - UICollectionViewDelegate

extension CategorySelectionViewController: UICollectionViewDelegate {
  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    guard let pillCell = cell as? PillCell else { return }

    _ = pillCell.label
      |> \.preferredMaxLayoutWidth .~ collectionView.bounds.width
  }
}

extension CategorySelectionViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(
    _ collectionView: UICollectionView,
    layout _: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int
  ) -> CGSize {
    let indexPath = IndexPath.init(item: 0, section: section)
    let headerView = collectionView.dataSource?
      .collectionView?(
        collectionView,
        viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
        at: indexPath
      )
    headerView?.layoutIfNeeded()

    let height = headerView?.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height ?? 0

    return CGSize(width: collectionView.bounds.width, height: height)
  }
}
