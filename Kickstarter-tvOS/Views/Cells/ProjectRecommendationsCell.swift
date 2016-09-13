import UIKit
import KsApi
import ReactiveCocoa
import Library
import Library

internal protocol ProjectRecommendationsCellDelegate: class {
  func projectRecommendations(cell: ProjectRecommendationsCell, didSelect project: Project)
}

internal final class ProjectRecommendationsCell: UICollectionViewCell, ValueCell {
  @IBOutlet private weak var collectionView: UICollectionView!
  weak var delegate: ProjectRecommendationsCellDelegate? = nil

  let viewModel = SimpleViewModel<[Project]>()
  private let dataSource = SimpleDataSource<ProjectCell, Project>()

  internal func configureWith(value value: [Project]) {
    self.viewModel.model(value)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    collectionView.registerCellNibForClass(ProjectCell.self)
    collectionView.dataSource = dataSource

    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.sectionInset = UIEdgeInsets(top: 0.0, left: 80.0, bottom: 0.0, right: 80.0)
    }
  }

  override func bindViewModel() {

    self.viewModel.model
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.reload(projects)
    }
  }
}

// MARK: UICollectionViewDelegate

extension ProjectRecommendationsCell: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//    guard let project = dataSource[indexPath].project else { return }
//    delegate?.projectRecommendations(self, didSelect: project)
  }
}
