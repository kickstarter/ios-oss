import UIKit
import struct Models.Project
import struct Models.Reward
import class Library.MVVMDataSource
import class Library.SimpleViewModel

final class ProjectViewDataSource : MVVMDataSource {

  func loadProject(project: Project) {
    let projectViewModel = SimpleViewModel(model: project)
    setData([projectViewModel],
      cellClass: ProjectShelfCell.self,
      inSection: 0
    )

    setData([projectViewModel],
      cellClass: ProjectMoreInfoCell.self,
      inSection: 1
    )

    if let rewards = project.rewards {
      let finalRewards = rewards
        .filter { r in !r.isNoReward }
        .sort()
      
      setData([SimpleViewModel(model: finalRewards)],
        cellClass: ProjectRewardsCollectionViewCell.self,
        inSection: 2
      )
    }
  }

  func loadRecommendations(recommendations: [Project]) {
    setData([SimpleViewModel(model: recommendations)],
      cellClass: ProjectRecommendationsCell.self,
      inSection: 3
    )
  }

  override func registerClasses(collectionView collectionView: UICollectionView?) {
    collectionView?.registerCellNibForClass(ProjectShelfCell.self)
    collectionView?.registerCellNibForClass(ProjectMoreInfoCell.self)
    collectionView?.registerCellNibForClass(ProjectRewardsCollectionViewCell.self)
    collectionView?.registerCellNibForClass(ProjectRecommendationsCell.self)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withViewModel viewModel: AnyObject) {

    switch (cell, viewModel) {
    case let (cell as ProjectShelfCell, viewModel as SimpleViewModel<Project>):
      cell.viewModel.value = viewModel
    case let (cell as ProjectMoreInfoCell, viewModel as SimpleViewModel<Project>):
      cell.viewModel.value = viewModel
    case let (cell as ProjectRewardsCollectionViewCell, viewModel as SimpleViewModel<[Reward]>):
      cell.viewModel.value = viewModel
    case let (cell as ProjectRecommendationsCell, viewModel as SimpleViewModel<[Project]>):
      cell.viewModel.value = viewModel
    default:
      print("[MVVMDataSource] Potential error in \(self.dynamicType).configureCell : unhandled case of combo (\(cell.dynamicType), \(viewModel.dynamicType)). ")
    }
  }
}
