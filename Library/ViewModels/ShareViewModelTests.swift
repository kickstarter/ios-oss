@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ShareViewModelTests: TestCase {
  internal let vm: ShareViewModelType = ShareViewModel()

  fileprivate let showShareSheet = TestObserver<(UIActivityViewController, UIView?), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.showShareSheet.observe(self.showShareSheet.observer)
  }

  func testShowShareSheet_Discovery() {
    let project = .template |> Project.lens.id .~ 30
    let newProject = .template |> Project.lens.id .~ 55
    let view = UIView()

    self.vm.inputs.configureWith(shareContext: .discovery(project), shareContextView: view)
    self.vm.inputs.shareButtonTapped()
    self.vm.inputs.configureWith(shareContext: .discovery(newProject), shareContextView: view)

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_Project() {
    self.vm.inputs.configureWith(shareContext: .project(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_Thanks() {
    self.vm.inputs.configureWith(shareContext: .thanks(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_CreatorDashboard() {
    self.vm.inputs.configureWith(shareContext: .creatorDashboard(.template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_Update() {
    self.vm.inputs.configureWith(shareContext: .update(.template, .template), shareContextView: nil)
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }

  func testShowShareSheet_BackerOnlyUpdate() {
    self.vm.inputs.configureWith(
      shareContext: .update(
        .template,
        .template |> Update.lens.isPublic .~ false
      ),
      shareContextView: nil
    )
    self.vm.inputs.shareButtonTapped()

    self.showShareSheet.assertValueCount(1)
  }
}
