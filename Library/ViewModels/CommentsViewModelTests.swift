@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()

  internal let envelopeTemplate = TestObserver<GraphMutationPostCommentEnvelope, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.envelopeTemplate.observe(self.envelopeTemplate.observer)
  }

  func testEnvelopeTemplate_ViewDidLoad() {
    self.envelopeTemplate.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.envelopeTemplate.assertDidEmitValue()
  }
}
