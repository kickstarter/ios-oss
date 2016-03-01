import UIKit
import Models
import ReactiveCocoa
import class Library.SimpleDataSource
import class Library.SimpleViewModel
import protocol Library.ViewModeledCellType

protocol PlaylistTrayCellDelegate: class {
  func playlistTrayCell(cell: PlaylistTrayCell, didSelectedProject project: Project, inPlaylist playlist: Playlist)
}

class PlaylistTrayCell: UICollectionViewCell, ViewModeledCellType {
  weak var delegate: PlaylistTrayCellDelegate?

  @IBOutlet weak var selectedView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var projectsCollectionView: UICollectionView!

  let viewModel = MutableProperty<PlaylistsMenuViewModel?>(nil)
  let dataSource = SimpleDataSource<ProjectCell, Project>()

  override func awakeFromNib() {
    super.awakeFromNib()

    self.dataSource.registerClasses(collectionView: self.projectsCollectionView)
    self.projectsCollectionView.dataSource = self.dataSource

    self.projectsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 80)
    if let layout = projectsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = CGSize(width: 560.0, height: 430.0)
    }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      self.selectedView.hidden = !self.focused
    }, completion: nil)
  }

  override func bindViewModel() {
    let playlistViewModel = viewModel.producer.ignoreNil()

    playlistViewModel.map { $0.outputs.title }
      .observeForUI()
      .startWithNext { [weak self] title in
        self?.titleLabel.text = title
    }

    playlistViewModel.switchMap { $0.outputs.projects }
      .observeForUI()
      .startWithNext { [weak self] projects in
        self?.dataSource.reload(projects)
        self?.projectsCollectionView.reloadData()
    }



    playlistViewModel.switchMap { $0.outputs.selectedProjectAndPlaylist }
      .observeForUI()
      .startWithNext { [weak self] (project, playlist) in
        guard let cell = self else { return }
        cell.delegate?.playlistTrayCell(cell, didSelectedProject: project, inPlaylist: playlist)
    }

  }
}

extension PlaylistTrayCell : UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let projectViewModel = self.dataSource[indexPath] as? SimpleViewModel<Project> {
      self.viewModel.value?.inputs.selectProject(projectViewModel.model)
    }
  }

  // Keep focused fixed, scroll content. Show maggie.
//  func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
//
//    guard let nextFocusedIndexPath = context.nextFocusedIndexPath else { return }
//
//    coordinator.addCoordinatedAnimations({
//      collectionView.scrollToItemAtIndexPath(nextFocusedIndexPath, atScrollPosition: .Left, animated: true)
//    }, completion: nil)
//  }
}
