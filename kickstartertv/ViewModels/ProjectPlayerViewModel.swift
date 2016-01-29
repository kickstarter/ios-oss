import Foundation
import Models

protocol ProjectPlayerViewModelInputs {
}

protocol ProjectPlayerViewModelOutputs {
  var videoURL: NSURL { get }
}

final class ProjectPlayerViewModel : ProjectPlayerViewModelInputs, ProjectPlayerViewModelOutputs {
  let videoURL: NSURL
  let project: Project

  var inputs: ProjectPlayerViewModelInputs { return self }
  var outputs: ProjectPlayerViewModelOutputs { return self }

  init?(project: Project) {
    self.project = project

    guard let urlString = project.video?.high,
      url = NSURL(string: urlString) else {
      videoURL = NSURL()
      return nil
    }

    videoURL = url
  }
}