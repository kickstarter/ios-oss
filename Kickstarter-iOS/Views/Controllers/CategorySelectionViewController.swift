import Foundation
import KsApi
import Library
import Prelude
import UIKit

public final class CategorySelectionViewController: UIViewController {
  // MARK: - Properties

  private lazy var buttonView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var continueButton: UIButton = { UIButton(type: .custom) }()

  private lazy var collectionView: UICollectionView = {
    UICollectionView(
      frame: .zero,
      collectionViewLayout: self.pillLayout
    )
      |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.always
      |> \.contentInset .~ .init(top: Styles.grid(2))
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let dataSource = CategorySelectionDataSource()

  private lazy var headerView: UIView = {
    CategorySelectionHeaderView(frame: .zero, context: .categorySelection)
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

  private lazy var skipButton: UIBarButtonItem = {
    UIBarButtonItem(
      title: Strings.general_navigation_buttons_skip(),
      style: .plain,
      target: self,
      action: #selector(CategorySelectionViewController.skipButtonTapped)
    )
  }()

  private let viewModel: CategorySelectionViewModelType = CategorySelectionViewModel()

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> baseControllerStyle()

    _ = self.navigationController?.navigationBar
      ?|> navigationBarStyle

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationItem.setRightBarButton(self.skipButton, animated: false)
    self.navigationItem.setHidesBackButton(true, animated: false)

    self.navigationController?.setNavigationBarHidden(false, animated: false)

    self.collectionView.registerCellClass(PillCell.self)
    self.collectionView.register(
      CategoryCollectionViewSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CategoryCollectionViewSectionHeaderView.defaultReusableId
    )

    self.continueButton.addTarget(
      self, action: #selector(CategorySelectionViewController.continueButtonTapped),
      for: .touchUpInside
    )

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.collectionView
      |> collectionViewStyle

    _ = self.skipButton
      |> skipButtonStyle

    _ = self.headerView
      |> headerViewStyle

    _ = self.buttonView
      |> buttonViewStyle

    _ = self.continueButton
      |> continueButtonStyle
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let bottomSafeAreaInset = self.view.safeAreaInsets.bottom
    let bottomInset = self.buttonView.frame.height - bottomSafeAreaInset
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

    self.viewModel.outputs.goToCuratedProjects
      .observeForUI()
      .observeValues { [weak self] in
        let vc = CuratedProjectsViewController.instantiate()
        vc.configure(with: [KsApi.Category.filmAndVideo])
        self?.navigationController?.pushViewController(vc, animated: true)
      }
  }

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.collectionView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.buttonView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.continueButton, self.buttonView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
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
      self.buttonView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.buttonView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.buttonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Accessors

  @objc func skipButtonTapped() {
    self.dismiss(animated: true)
  }

  @objc func continueButtonTapped() {
    self.viewModel.inputs.continueButtonTapped()
  }
}

// MARK: - UICollectionViewDelegate

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

// MARK: - Styles

private let skipButtonStyle: BarButtonStyle = { button in
  button
    |> \.tintColor .~ .white
}

private let headerViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}

private let buttonViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.layer.shadowColor .~ UIColor.black.cgColor
    |> \.layer.shadowOpacity .~ 0.12
    |> \.layer.shadowOffset .~ CGSize(width: 0, height: -1.0)
    |> \.layer.shadowRadius .~ CGFloat(1.0)
}

private let continueButtonStyle: ButtonStyle = { button in
  button
    |> greyButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }
}

private let collectionViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
}

private let navigationBarStyle: NavigationBarStyle = { navBar in
  navBar
    ?|> \.backgroundColor .~ .clear
    ?|> \.shadowImage .~ UIImage()
    ?|> \.isTranslucent .~ true
}
