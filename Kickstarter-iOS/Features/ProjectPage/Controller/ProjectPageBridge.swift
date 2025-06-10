import UIKit
import Prelude
import KsApi
import Library

@objc(ProjectPageBridgeModule)
class ProjectPageBridgeModule: NSObject {
  @objc(presentProjectPage:)
  func presentProjectPage(_ encodedId: String) {
    DispatchQueue.main.async {
      guard let projectId = decompose(id: encodedId),
            let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
        NSLog("Uh oh...")
        return
      }
      
      let projectParam = Either<Project, any ProjectPageParam>(
        right: ProjectPageParamBox(param: .id(projectId), initialProject: nil)
      )
      let vc = ProjectPageViewController.configuredWith(
        projectOrParam: projectParam,
        refInfo: nil
      )

      let nav = NavigationController(rootViewController: vc)
      if let traitCollection = UIApplication.shared.delegate?.window??.traitCollection {
        nav.modalPresentationStyle =
            traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet
      }

      rootVC.present(nav, animated: true, completion: nil)
    }
  }
}
