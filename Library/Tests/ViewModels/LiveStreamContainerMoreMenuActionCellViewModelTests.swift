import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamContainerMoreMenuActionCellViewModelTests: TestCase {
  let vm: LiveStreamContainerMoreMenuActionCellViewModelType = LiveStreamContainerMoreMenuActionCellViewModel()

  let creatorAvatarUrl = TestObserver<String?, NoError>()
  let rightActionActivityIndicatorViewHidden = TestObserver<Bool, NoError>()
  let rightActionButtonHidden = TestObserver<Bool, NoError>()
  let rightActionButtonImageName = TestObserver<String, NoError>()
  let rightActionButtonTitle = TestObserver<String, NoError>()
  let titleLabelText = TestObserver<String, NoError>()

  internal override func setUp() {
    self.vm.outputs.creatorAvatarUrl.map { $0?.absoluteString }.observe(self.creatorAvatarUrl.observer)
    self.vm.outputs.rightActionActivityIndicatorViewHidden.observe(self.rightActionActivityIndicatorViewHidden.observer)
    self.vm.outputs.rightActionButtonHidden.observe(self.rightActionButtonHidden.observer)
    self.vm.outputs.rightActionButtonImageName.observe(self.rightActionButtonImageName.observer)
    self.vm.outputs.rightActionButtonTitle.observe(self.rightActionButtonTitle.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
  }

  func testHideChat_Hidden() {
    self.vm.inputs.configureWith(moreMenuItem: .hideChat(hidden: true))
  }

  func testHideChat_Shown() {
  }

  func testShare() {

  }

  func testGoToProject() {
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(moreMenuItem: .goToProject(liveStreamEvent: event))

    self.creatorAvatarUrl.assertValues([nil])
//    self.rightActionActivityIndicatorViewHidden.assertValues([true])
//    self.rightActionButtonHidden.assertValues([true])
//    self.rightActionButtonImageName.assertValues([""])
//    self.rightActionButtonTitle.assertValues([""])
    self.titleLabelText.assertValues(["Sign up for this creator's live streams"])
  }

  func testSubscribe_Subscribed() {

  }

  func testSubscribe_Unsubscribed() {

  }

  func testCancel() {

  }
}
