import Foundation
import KsApi

public func getProjectBackingDetailsURL(with project: Project) -> URL? {
  let urlString =
    "\(AppEnvironment.current.apiService.serverConfig.webBaseUrl)/projects/\(project.creator.id)/\(project.slug)/backing/details"

  return URL(string: urlString)
}
