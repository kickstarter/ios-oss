import Library
import Prelude


import Library
import LiveStream
import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryViewModelInputs {
  func viewDidLoad()
}

public protocol LiveStreamDiscoveryViewModelOutputs {
  var loadDataSource: Signal<[LiveStreamEvent], NoError> { get }
}

public protocol LiveStreamDiscoveryViewModelType {
  var inputs: LiveStreamDiscoveryViewModelInputs { get }
  var outputs: LiveStreamDiscoveryViewModelOutputs { get }
}

public final class LiveStreamDiscoveryViewModel: LiveStreamDiscoveryViewModelType, LiveStreamDiscoveryViewModelInputs, LiveStreamDiscoveryViewModelOutputs {

  public init() {
    self.loadDataSource = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.liveStreamService.fetchEvents()
          .demoteErrors()
    }
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadDataSource: Signal<[LiveStreamEvent], NoError>

  public var inputs: LiveStreamDiscoveryViewModelInputs { return self }
  public var outputs: LiveStreamDiscoveryViewModelOutputs { return self }
}



internal final class LiveStreamDiscoveryViewController: UITableViewController {

  private let dataSource = LiveStreamDiscoveryDataSource()
  private let viewModel: LiveStreamDiscoveryViewModelType = LiveStreamDiscoveryViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 300.0)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadDataSource
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(liveStreams: $0)
        self?.tableView.reloadData()
    }
  }
}
