import KsApi
import Prelude
import ReactiveCocoa
import Result
import WebKit

public protocol ProjectDescriptionViewModelInputs {
  /// Call with the project given to the view.
  func configureWith(project project: Project)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction navigationAction: WKNavigationActionProtocol)
    -> WKNavigationActionPolicy

  /// Call when the `expandDescription` method is called on the view.
  func expandDescription()

  /// Call when the webview's content size changes.
  func observedWebViewContentSizeChange(contentSize: CGSize)

  /// Call when a header/footer is transfered to the view.
  func transferredHeaderAndFooter(atContentOffset contentOffset: CGPoint?)

  /// Call when the view appears.
  func viewDidAppear()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the web view finishes navigation.
  func webViewDidFinishNavigation()
}

public protocol ProjectDescriptionViewModelOutputs {
  /// Emits a boolean that determines if the footer should be hidden.
  var footerHidden: Signal<Bool, NoError> { get }

  /// Emits when the footer and header should be laid out.
  var layoutFooterAndHeader: Signal<(descriptionExpanded: Bool, contentOffset: CGPoint?), NoError> { get }

  /// Emits a url request that should be loaded into the webview.
  var loadWebViewRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol ProjectDescriptionViewModelType {
  var inputs: ProjectDescriptionViewModelInputs { get }
  var outputs: ProjectDescriptionViewModelOutputs { get }
}

public final class ProjectDescriptionViewModel: ProjectDescriptionViewModelType,
ProjectDescriptionViewModelInputs, ProjectDescriptionViewModelOutputs {

  public init() {
    let project = combineLatest(self.projectProperty.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let observedWebViewContentSizeChange = self.observedWebViewContentSizeChangeProperty.signal
      .skipRepeats()
      .ignoreValues()

    let projectDescriptionRequest = project
      .map {
        (NSURL(string: $0.urls.web.project)?.URLByAppendingPathComponent("description"))
      }
      .ignoreNil()
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    self.loadWebViewRequest = projectDescriptionRequest
      .takeWhen(self.viewDidAppearProperty.signal.take(1))

    let descriptionExpanded = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.expandDescriptionProperty.signal.mapConst(true)
    )

    let transferredHeaderAndFooter = descriptionExpanded
      .takePairWhen(self.transferredHeaderAndFooterOffsetProperty.signal)
      .map { (descriptionExpanded: $0, contentOffset: $1) }
      .skipRepeats { lhs, rhs in lhs.0 == rhs.0 && lhs.1 == rhs.1 }

    self.layoutFooterAndHeader = Signal.merge(
      // Layout when the description is expanded
      self.expandDescriptionProperty.signal.map { (true, nil) },

      // Layout when the header/footer are transferred over
      transferredHeaderAndFooter,

      // Layout when the webview finishes loading
      self.webViewDidFinishNavigationProperty.signal.take(1).map { (false, nil) },

      // Layout when the content size of the webview has changed
      descriptionExpanded.takeWhen(observedWebViewContentSizeChange).map { ($0, nil) }
    )

    self.footerHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      observedWebViewContentSizeChange.mapConst(false)
    )

    self.policyDecisionProperty <~ self.policyForNavigationActionProperty.signal.ignoreNil()
      .map { $0.request.URL?.path?.containsString("/description") == true ? .Allow : .Cancel }
  }

  private let transferredHeaderAndFooterOffsetProperty = MutableProperty<CGPoint?>(nil)
  public func transferredHeaderAndFooter(atContentOffset contentOffset: CGPoint?) {
    self.transferredHeaderAndFooterOffsetProperty.value = contentOffset
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let policyForNavigationActionProperty = MutableProperty<WKNavigationActionProtocol?>(nil)
  private let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.Allow)
  public func decidePolicyFor(navigationAction navigationAction: WKNavigationActionProtocol)
    -> WKNavigationActionPolicy {
      self.policyForNavigationActionProperty.value = navigationAction
      return self.policyDecisionProperty.value
  }

  private let expandDescriptionProperty = MutableProperty()
  public func expandDescription() {
    self.expandDescriptionProperty.value = ()
  }

  private let observedWebViewContentSizeChangeProperty = MutableProperty(CGSize.zero)
  public func observedWebViewContentSizeChange(contentSize: CGSize) {
    self.observedWebViewContentSizeChangeProperty.value = contentSize
  }

  private let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let webViewDidFinishNavigationProperty = MutableProperty()
  public func webViewDidFinishNavigation() {
    self.webViewDidFinishNavigationProperty.value = ()
  }

  public let footerHidden: Signal<Bool, NoError>
  public let layoutFooterAndHeader: Signal<(descriptionExpanded: Bool, contentOffset: CGPoint?), NoError>
  public let loadWebViewRequest: Signal<NSURLRequest, NoError>

  public var inputs: ProjectDescriptionViewModelInputs { return self }
  public var outputs: ProjectDescriptionViewModelOutputs { return self }
}
