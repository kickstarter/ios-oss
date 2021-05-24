import Foundation
@testable import Kickstarter_Framework
@testable import Library
import Prelude
import UIKit
import XCTest

final class CommentComposerViewTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }
  
  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }
  
  func testComposerView_User_Is_Backing() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        
        let vc = composerInViewController(
          language: language,
          device: device,
          avatarURL: nil,
          isBackingProject: true
        )
        
        FBSnapshotVerifyView(
          vc.view,
          identifier: "CommentComposerView - lang_\(language)_device_\(device)"
        )
      }
    }
  }
  
  func testComposerView_User_Not_Backing() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        
        let vc = composerInViewController(
          language: language,
          device: device,
          avatarURL: nil,
          isBackingProject: false
        )
        
        FBSnapshotVerifyView(
          vc.view,
          identifier: "CommentComposerView - lang_\(language)_device_\(device)"
        )
      }
    }
  }
}

private func composerInViewController(
  language _: Language,
  device: Device,
  avatarURL: URL?,
  isBackingProject: Bool
) -> UIViewController {
  let composer = CommentComposerView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  
  let controller = UIViewController()
  let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
  _ = controller.view |> \.backgroundColor .~ .ksr_white
  controller.view.addSubview(composer)
  
  NSLayoutConstraint.activate([
    composer.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
    composer.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
    composer.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
  ])
  
  composer.configure(with: (avatarURL, isBackingProject))
  
  return parent
}
