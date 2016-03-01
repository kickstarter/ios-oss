import UIKit
import Models
import ReactiveCocoa
import protocol Library.ViewModeledCellType
import class Library.SimpleViewModel
import class Library.SimpleDataSource

protocol ProjectRecommendationsCellDelegate: class {
  func projectRecommendations(cell: ProjectRecommendationsCell, didSelect project: Project)
}

class ProjectRecommendationsCell: UICollectionViewCell, ViewModeledCellType {
  @IBOutlet weak var collectionView: UICollectionView!
  weak var delegate: ProjectRecommendationsCellDelegate? = nil

  let viewModel = MutableProperty<SimpleViewModel<[Project]>?>(nil)
  private let dataSource = SimpleDataSource<ProjectCell, Project>()

  override func awakeFromNib() {
    super.awakeFromNib()

    collectionView.registerCellNibForClass(ProjectCell.self)
    collectionView.dataSource = dataSource

    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.sectionInset = UIEdgeInsets(top: 0.0, left: 80.0, bottom: 0.0, right: 80.0)
    }
  }

  override func bindViewModel() {

    viewModel.producer.ignoreNil().map { $0.model }
      .startWithNext { [weak self] projects in
        self?.dataSource.reload(projects)
    }
  }
}

// MARK: UICollectionViewDelegate

extension ProjectRecommendationsCell : UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//    guard let project = dataSource[indexPath].project else { return }
//    delegate?.projectRecommendations(self, didSelect: project)
  }
}
