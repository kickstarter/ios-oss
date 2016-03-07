import protocol Library.ViewModelType
import struct Models.Project
import struct Library.AppEnvironment
import struct Library.Environment
import struct ReactiveCocoa.SignalProducer
import enum Result.NoError
import class Foundation.NSURL

internal protocol DiscoveryProjectViewModelOutputs {
  var projectImageURL: NSURL? { get }
  var projectName: String { get }
  var category: String { get }
  var blurb: String { get }
  var funding: String { get }
  var backers: String { get }
}

internal final class DiscoveryProjectViewModel: ViewModelType, DiscoveryProjectViewModelOutputs {
  typealias Model = Project

  private let project: Project

  // MARK: Outputs
  internal lazy var projectImageURL: NSURL? = NSURL(string: self.project.photo.full)
  internal lazy var projectName: String = self.project.name
  internal lazy var category: String = self.project.category.name
  internal lazy var blurb: String = self.project.blurb
  internal lazy var funding = "89% funded"
  internal lazy var backers: String = "154 backers"

  internal var outputs: DiscoveryProjectViewModelOutputs { return self }

  internal init(project: Project, env: Environment = AppEnvironment.current) {
    self.project = project
  }
}
