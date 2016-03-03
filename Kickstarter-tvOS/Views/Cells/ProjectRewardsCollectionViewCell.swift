import UIKit
import ReactiveCocoa
import Models
import protocol Library.ViewModeledCellType
import class Library.SimpleViewModel
import class Library.SimpleDataSource

class ProjectRewardsCollectionViewCell: UICollectionViewCell, ViewModeledCellType {
  @IBOutlet weak var collectionView: UICollectionView!

  let viewModelProperty = MutableProperty<SimpleViewModel<[Reward]>?>(nil)
  let dataSource = SimpleDataSource<ProjectRewardCell, Reward>()

  override func awakeFromNib() {
    super.awakeFromNib()
    
    collectionView.registerCellNibForClass(ProjectRewardCell.self)
    collectionView.dataSource = dataSource

    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.sectionInset = UIEdgeInsets(top: 0.0, left: 80.0, bottom: 0.0, right: 80.0)
    }
  }

  override func bindViewModel() {
    self.viewModel.map { $0.model }
      .observeForUI()
      .startWithNext { [weak self] rewards in
        self?.dataSource.reload(rewards)
        self?.collectionView.reloadData()
    }
  }
}

extension ProjectRewardsCollectionViewCell : UICollectionViewDelegate {
}
