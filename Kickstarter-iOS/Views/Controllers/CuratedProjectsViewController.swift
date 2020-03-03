import Library
import Prelude
import UIKit

final class CuratedProjectsViewController: UIViewController {
  // MARK: - Properties

  private lazy var collectionView: UICollectionView = {
    UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewFlowLayout()
    )
      |> \.delegate .~ self
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var doneButton: UIBarButtonItem = {
    UIBarButtonItem(
      title: Strings.Done(),
      style: .plain,
      target: self,
      action: #selector(CuratedProjectsViewController.doneButtonTapped)
    )
  }()

  private lazy var headerView: UIView = {
    CategorySelectionHeaderView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.collectionView.register(
      CategoryCollectionViewSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CategoryCollectionViewSectionHeaderView.defaultReusableId
    )

    self.configureSubviews()
    self.setupConstraints()
  }

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.collectionView, self.view)
      |> ksr_addSubviewToParent()
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
    ])
  }

  // MARK: - Accessors

  @objc func doneButtonTapped() {
    self.dismiss(animated: true)
  }
}

// MARK: - Styles

private let collectionViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
}

private let doneButtonStyle: BarButtonStyle = { button in
  button
    |> \.tintColor .~ .white
}

private let headerViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}

extension CuratedProjectsViewController: UICollectionViewDelegateFlowLayout {
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
