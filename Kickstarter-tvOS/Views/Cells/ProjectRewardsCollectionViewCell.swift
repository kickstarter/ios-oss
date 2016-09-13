import UIKit
import ReactiveCocoa
import KsApi
import Library

class ProjectRewardsCollectionViewCell: UICollectionViewCell, ValueCell {
  @IBOutlet private weak var collectionView: UICollectionView!

  let viewModel = SimpleViewModel<[Reward]>()
  let dataSource = SimpleDataSource<ProjectRewardCell, Reward>()

  override func awakeFromNib() {
    super.awakeFromNib()

    self.viewModel.model
      .observeForUI()
      .observeNext { [weak self] rewards in
        self?.dataSource.reload(rewards)
        self?.collectionView.reloadData()
    }

    collectionView.registerCellNibForClass(ProjectRewardCell.self)
    collectionView.dataSource = dataSource

    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.sectionInset = UIEdgeInsets(top: 0.0, left: 80.0, bottom: 0.0, right: 80.0)
    }
  }

  func configureWith(value value: [Reward]) {
    self.viewModel.model(value)
  }
}

extension ProjectRewardsCollectionViewCell: UICollectionViewDelegate {
}
