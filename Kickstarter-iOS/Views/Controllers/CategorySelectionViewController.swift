import KsApi
import Library
import Prelude
import UIKit

public final class CategorySelectionViewController: UIViewController {
  // MARK: - Properties

  private lazy var buttonStackView = { UIStackView(frame: .zero) }()
  private lazy var buttonView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var continueButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var collectionView: UICollectionView = {
    UICollectionView(
      frame: .zero,
      collectionViewLayout: self.pillLayout
    )
      |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.always
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.allowsSelection .~ false
  }()

  private let dataSource = CategorySelectionDataSource()

  private lazy var headerView: CategorySelectionHeaderView = {
    CategorySelectionHeaderView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var loadingIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pillLayout: PillLayout = {
    let layout = PillLayout(
      minimumInteritemSpacing: Styles.grid(2),
      minimumLineSpacing: Styles.grid(2),
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

  private lazy var warningLabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.configureTransparentNavigationBar()

    self.navigationItem.setRightBarButton(self.skipButton, animated: false)
    self.navigationItem.setHidesBackButton(true, animated: false)

    self.navigationController?.setNavigationBarHidden(false, animated: false)

    self.collectionView.registerCellClass(CategoryPillCell.self)
    self.collectionView.register(
      CategoryCollectionViewSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CategoryCollectionViewSectionHeaderView.defaultReusableId
    )

    self.dataSource.collectionView = self.collectionView

    self.continueButton.addTarget(
      self, action: #selector(CategorySelectionViewController.continueButtonTapped),
      for: .touchUpInside
    )

    self.configureSubviews()
    self.setupConstraints()

    self.headerView.configure(with: .categorySelection)

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

    _ = self.loadingIndicator
      |> baseActivityIndicatorStyle

    _ = self.skipButton
      |> skipButtonStyle

    _ = self.headerView
      |> headerViewStyle

    _ = self.buttonView
      |> buttonViewStyle

    _ = self.buttonStackView
      |> buttonStackViewStyle

    _ = self.continueButton
      |> continueButtonStyle

    _ = self.warningLabel
      |> warningLabelStyle
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.headerView.layoutIfNeeded()

    let bottomSafeAreaInset = self.view.safeAreaInsets.bottom
    let topSafeAreaInset = self.view.safeAreaInsets.top
    let bottomInset = self.buttonView.frame.height - bottomSafeAreaInset
    let topInset = self.headerView.frame.height - topSafeAreaInset + Styles.grid(2) // collection view's inset
    let prevTopInset = self.collectionView.contentInset.top

    self.pillLayout.shouldInvalidateLayout = prevTopInset != topInset

    self.collectionView.contentInset = .init(
      top: topInset,
      left: self.collectionView.contentInset.left,
      bottom: bottomInset,
      right: self.collectionView.contentInset.right
    )
    self.collectionView.scrollIndicatorInsets = .init(
      top: topInset,
      left: self.collectionView.verticalScrollIndicatorInsets.left,
      bottom: bottomInset,
      right: self.collectionView.verticalScrollIndicatorInsets.right
    )
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicator.rac.animating = self.viewModel.outputs.isLoading

    self.viewModel.outputs.loadCategorySections
      .observeForUI()
      .observeValues { [weak self] sectionTitles, categories in
        self?.dataSource.load(sectionTitles, categories: categories)
        self?.collectionView.reloadData()
      }

    self.viewModel.outputs.goToCuratedProjects
      .observeForUI()
      .observeValues { [weak self] categories in
        let vc = CuratedProjectsViewController.instantiate()
        vc.configure(with: categories, context: .onboarding)

        self?.navigationController?.pushViewController(vc, animated: true)
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues { NotificationCenter.default.post($0) }

    self.viewModel.outputs.showErrorMessage
      .observeForUI()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true)
      }

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in self?.dismiss(animated: true) }

    self.warningLabel.rac.hidden = self.viewModel.outputs.warningLabelIsHidden
    self.continueButton.rac.enabled = self.viewModel.outputs.continueButtonEnabled
  }

  private func configureSubviews() {
    _ = (self.collectionView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.loadingIndicator, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.buttonView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.buttonStackView, self.buttonView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.continueButton, self.warningLabel], self.buttonStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.buttonView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.buttonView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.buttonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.continueButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height)
    ])
  }

  // MARK: - Accessors

  @objc func skipButtonTapped() {
    self.viewModel.inputs.skipButtonTapped()
  }

  @objc func continueButtonTapped() {
    self.viewModel.inputs.continueButtonTapped()
  }
}

// MARK: - UICollectionViewDelegate

extension CategorySelectionViewController: UICollectionViewDelegate {
  public func collectionView(
    _: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt index: IndexPath
  ) {
    guard let pillCell = cell as? CategoryPillCell else { return }

    _ = pillCell
      |> \.delegate .~ self

    let shouldSelect = self.viewModel.outputs.shouldSelectCell(at: index)

    pillCell.setIsSelected(shouldSelect)
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

// MARK: - CategoryPillCellDelegate

extension CategorySelectionViewController: CategoryPillCellDelegate {
  func categoryPillCell(
    _ cell: CategoryPillCell,
    didTapAtIndex index: IndexPath,
    withCategory category: KsApi.Category
  ) {
    self.viewModel.inputs.categorySelected(with: (index, category))

    let shouldSelectCell = self.viewModel.outputs.shouldSelectCell(at: index)

    cell.setIsSelected(shouldSelectCell)
  }
}

// MARK: - Styles

private let skipButtonStyle: BarButtonStyle = { button in
  button
    |> \.tintColor .~ .ksr_white
}

private let headerViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}

private let buttonStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(2)
}

private let buttonViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_white
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.layer.shadowColor .~ UIColor.ksr_black.cgColor
    |> \.layer.shadowOpacity .~ 0.12
    |> \.layer.shadowOffset .~ CGSize(width: 0, height: -1.0)
    |> \.layer.shadowRadius .~ CGFloat(1.0)
}

private let continueButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }
}

private let collectionViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_white
}

private let warningLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_alert
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textAlignment .~ .center
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text %~ { _ in Strings.Select_fewer_categories() }
}
