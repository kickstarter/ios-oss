import UIKit
import KsApi
import ReactiveCocoa
import Library

protocol PlaylistTrayCellDelegate: class {
  func playlistTrayCell(cell: PlaylistTrayCell,
                        didSelectedProject project: Project,
                                           inPlaylist playlist: Playlist)
}

class PlaylistTrayCell: UICollectionViewCell, ValueCell {
  weak var delegate: PlaylistTrayCellDelegate?

  @IBOutlet private weak var selectedView: UIView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var countLabel: UILabel!
  @IBOutlet private weak var projectsCollectionView: UICollectionView!

  private let viewModel: PlaylistsMenuViewModel = PlaylistsMenuViewModel()
  let dataSource = SimpleDataSource<ProjectCell, Project>()

  func configureWith(value value: Playlist) {
    self.viewModel.inputs.playlist(value)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    self.viewModel.outputs.title
      .observeForUI()
      .observeNext { [weak titleLabel] title in
        titleLabel?.text = title
    }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [dataSource, weak projectsCollectionView] projects in
        dataSource.reload(projects)
        projectsCollectionView?.reloadData()
    }

    self.viewModel.outputs.selectedProjectAndPlaylist
      .observeForUI()
      .observeNext { [weak self] (project, playlist) in
        guard let cell = self else { return }
        cell.delegate?.playlistTrayCell(cell, didSelectedProject: project, inPlaylist: playlist)
    }

    self.dataSource.registerClasses(collectionView: self.projectsCollectionView)
    self.projectsCollectionView.dataSource = self.dataSource

    self.projectsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 80)
    if let layout = projectsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = CGSize(width: 560.0, height: 430.0)
    }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext,
                                        withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      self.selectedView.hidden = !self.focused
    }, completion: nil)
  }
}

extension PlaylistTrayCell: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let project = self.dataSource[indexPath] as? Project {
      self.viewModel.inputs.selectProject(project)
    }
  }
}
