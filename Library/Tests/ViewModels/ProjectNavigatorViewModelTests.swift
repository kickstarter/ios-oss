@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import ReactiveSwift
import Result
import UIKit
import XCTest

internal final class ProjectNavigatorViewModelTests: TestCase {
  fileprivate let vm: ProjectNavigatorViewModelType = ProjectNavigatorViewModel()

  fileprivate let cancelInteractiveTransition = TestObserver<(), NoError>()
  fileprivate let dismissViewController = TestObserver<(), NoError>()
  fileprivate let finishInteractiveTransition = TestObserver<(), NoError>()
  fileprivate let setInitialPagerViewController = TestObserver<(), NoError>()
  fileprivate let setNeedsStatusBarAppearanceUpdate = TestObserver<(), NoError>()
  fileprivate let setTransitionAnimatorIsInFlight = TestObserver<Bool, NoError>()
  fileprivate let updateInteractiveTransition = TestObserver<CGFloat, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cancelInteractiveTransition.observe(self.cancelInteractiveTransition.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.finishInteractiveTransition.observe(self.finishInteractiveTransition.observer)
    self.vm.outputs.setInitialPagerViewController.observe(self.setInitialPagerViewController.observer)
    self.vm.outputs.setNeedsStatusBarAppearanceUpdate.observe(self.setNeedsStatusBarAppearanceUpdate.observer)
    self.vm.outputs.setTransitionAnimatorIsInFlight.observe(self.setTransitionAnimatorIsInFlight.observer)
    self.vm.outputs.updateInteractiveTransition.observe(self.updateInteractiveTransition.observer)
  }

  func testTransitionLifecycle_ScrollDown_BackUp() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 20),
                           translation: CGPoint(x: 0, y: -20),
                           velocity: CGPoint(x: 0, y: -20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 0),
                           translation: CGPoint(x: 0, y: 0),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 0),
                           translation: CGPoint(x: 0, y: 0),
                           velocity: CGPoint(x: 0, y: 0),
                           isDragging: false)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])
  }

  func testTransitionLifecycle_ScrollDown_BackUp_Overscroll() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 20),
                           translation: CGPoint(x: 0, y: -20),
                           velocity: CGPoint(x: 0, y: -20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 0),
                           translation: CGPoint(x: 0, y: 0),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([false])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -20),
                           translation: CGPoint(x: 0, y: 20),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([false, true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -40),
                           translation: CGPoint(x: 0, y: 40),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([false, true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -40),
                           translation: CGPoint(x: 0, y: 40),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: false)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(1)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([false, true, false])
  }

  func testTransitionLifecycle_Overscroll_Cancel() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -20),
                           translation: CGPoint(x: 0, y: 20),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -10),
                           translation: CGPoint(x: 0, y: 10),
                           velocity: CGPoint(x: 0, y: -10),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -10),
                           translation: CGPoint(x: 0, y: 10),
                           velocity: CGPoint(x: 0, y: -10),
                           isDragging: false)

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])
  }

  func testTransitionLifecycle_Overscroll_ScrollBack() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValues([])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -20),
                           translation: CGPoint(x: 0, y: 20),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 0),
                           translation: CGPoint(x: 0, y: 20),
                           velocity: CGPoint(x: 0, y: -20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 20),
                           translation: CGPoint(x: 0, y: -20),
                           velocity: CGPoint(x: 0, y: -20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 20),
                           translation: CGPoint(x: 0, y: -20),
                           velocity: CGPoint(x: 0, y: -20),
                           isDragging: false)

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])
  }

  // This test exercises a particular bug experienced if you are not careful with the transition phases.
  // It does the following:
  //   - Pull down a bit to start dismissing
  //   - Scroll back up to precisely contentOffset=0 to cancel dismissal
  //   - Transition phase is in weird state where it cannot dismiss.
  func testTransitionLifecycle_Bug() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(0)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(0)
    self.setTransitionAnimatorIsInFlight.assertValueCount(0)

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: -20),
                           translation: CGPoint(x: 0, y: 20),
                           velocity: CGPoint(x: 0, y: 20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(1)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 0),
                           translation: CGPoint(x: 0, y: 0),
                           velocity: CGPoint(x: 0, y: -20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(0)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 20),
                           translation: CGPoint(x: 0, y: -20),
                           velocity: CGPoint(x: 0, y: -20),
                           isDragging: true)

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])

    self.vm.inputs.panning(contentOffset: CGPoint(x: 0, y: 20),
                           translation: CGPoint(x: 0, y: -20),
                           velocity: CGPoint(x: 0, y: 0),
                           isDragging: false)

    self.cancelInteractiveTransition.assertValueCount(1)
    self.dismissViewController.assertValueCount(1)
    self.finishInteractiveTransition.assertValueCount(0)
    self.updateInteractiveTransition.assertValueCount(2)
    self.setTransitionAnimatorIsInFlight.assertValues([true, false])
  }

  func testSetNeedsStatusBarAppearanceUpdate() {
    let playlist = (0...4).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let project = playlist.first!

    self.vm.inputs.configureWith(project: project, refTag: .category)
    self.vm.inputs.viewDidLoad()

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(0)

    self.vm.inputs.willTransition(toProject: playlist[1])

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(0)

    self.vm.inputs.pageTransition(completed: true)

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(1)
  }

  func testSetInitialPagerViewController() {
    self.vm.inputs.configureWith(project: .template, refTag: .category)

    self.setInitialPagerViewController.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.setInitialPagerViewController.assertValueCount(1)
  }
}
