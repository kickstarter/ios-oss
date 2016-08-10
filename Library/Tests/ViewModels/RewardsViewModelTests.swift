import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class RewardsViewModelTests: TestCase {
  private let vm: RewardsViewModelType = RewardsViewModel()

  private let layoutHeaderView = TestObserver<CGPoint?, NoError>()
  private let loadProjectIntoDataSource = TestObserver<Project, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.layoutHeaderView.observe(self.layoutHeaderView.observer)
    self.vm.outputs.loadProjectIntoDataSource.observe(self.loadProjectIntoDataSource.observer)
  }

  func testLayoutHeaderView() {
    self.vm.inputs.configureWith(project: .template)

    self.layoutHeaderView.assertValues([])

    self.vm.inputs.transferredHeaderView(atContentOffset: .zero)

    self.layoutHeaderView.assertValues([.zero])

    self.vm.inputs.viewDidLayoutSubviews(contentSize: CGSize(width: 0, height: 100))

    self.layoutHeaderView.assertValues([.zero, nil])

    self.vm.inputs.viewDidLayoutSubviews(contentSize: CGSize(width: 0, height: 100))

    self.layoutHeaderView.assertValues([.zero, nil])

    self.vm.inputs.transferredHeaderView(atContentOffset: CGPoint(x: 0, y: 100))

    self.layoutHeaderView.assertValues([.zero, nil, CGPoint(x: 0, y: 100)])
  }

  func testLoadProjectIntoDataSource() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadProjectIntoDataSource.assertValues([])

    self.vm.inputs.transferredHeaderView(atContentOffset: .zero)

    self.loadProjectIntoDataSource.assertValues([project])
  }
}
