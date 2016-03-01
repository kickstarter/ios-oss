import UIKit
import Models
import AlamofireImage

class SearchViewController: MVVMCollectionViewController {
  let viewModel: SearchViewModel
  private let dataSource = SearchDataSource()

  init(viewModel: SearchViewModel = SearchViewModel()) {
    self.viewModel = viewModel

    super.init(nibName: SearchViewController.defaultNib, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView?.registerCellNibForClass(DiscoveryProjectCell.self)
    collectionView?.dataSource = dataSource

    if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.sectionInset = UIEdgeInsets(top: 0.0, left: 60.0, bottom: 0.0, right: 60.0)
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    viewModel.outputs.projects
      .observeForUI()
      .startWithNext { [weak self] projects in
        self?.collectionView?.reloadData()
    }
  }
}

// MARK: UICollectionViewDelegate
extension SearchViewController {
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//    let project = dataSource[indexPath]
//    let controller = ProjectViewController(viewModel: ProjectViewModel(project: project))
//    self.presentViewController(controller, animated: true, completion: nil)
  }
}

// MARK: UISearchResultsUpdating
extension SearchViewController : UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    guard let query = searchController.searchBar.text else { return }
    viewModel.inputs.updateQuery(query)
  }
}
