import UIKit
import KsApi
import Library

final class ProjectViewDataSource: ValueCellDataSource {

  func loadProject(project: Project) {
    set(values: [project],
        cellClass: ProjectShelfCell.self,
        inSection: 0)

    set(values: [project],
        cellClass: ProjectMoreInfoCell.self,
        inSection: 1)

    if let rewards = project.rewards {
      let finalRewards = rewards
        .filter { r in !r.isNoReward }
        .sort()

      set(values: [finalRewards],
          cellClass: ProjectRewardsCollectionViewCell.self,
          inSection: 2)
    }
  }

  func loadRecommendations(recommendations: [Project]) {
    set(values: [recommendations],
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

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ProjectShelfCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectMoreInfoCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectRewardsCollectionViewCell, value as [Reward]):
      cell.configureWith(value: value)
    case let (cell as ProjectRecommendationsCell, value as [Project]):
      cell.configureWith(value: value)
    default:
      fatalError("[ValueCellDataSource] Potential error in \(self.dynamicType).configureCell: unhandled " +
        "case of combo (\(cell.dynamicType), \(value.dynamicType)).")
    }
  }
}
