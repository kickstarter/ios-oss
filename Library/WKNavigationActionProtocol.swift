#if os(iOS)
  import WebKit

  public struct WKNavigationActionData {
    public let navigationAction: WKNavigationAction
    public let navigationType: WKNavigationType
    public let request: NSURLRequest
    public let sourceFrame: WKFrameInfoData
    public let targetFrame: WKFrameInfoData?

    public init(navigationAction: WKNavigationAction) {
      self.navigationAction = navigationAction
      self.navigationType = navigationAction.navigationType
      self.request = navigationAction.request
      self.sourceFrame = .init(frameInfo: navigationAction.sourceFrame)
      self.targetFrame = navigationAction.targetFrame.map(WKFrameInfoData.init(frameInfo:))
    }

    internal init(navigationType: WKNavigationType,
                  request: NSURLRequest,
                  sourceFrame: WKFrameInfoData,
                  targetFrame: WKFrameInfoData?) {
      self.navigationAction = WKNavigationAction()
      self.navigationType = navigationType
      self.request = request
      self.sourceFrame = sourceFrame
      self.targetFrame = targetFrame
    }
  }

  public struct WKFrameInfoData {
    public let frameInfo: WKFrameInfo
    public let mainFrame: Bool
    public let request: NSURLRequest

    public init(frameInfo: WKFrameInfo) {
      self.frameInfo = frameInfo
      self.mainFrame = frameInfo.mainFrame
      self.request = frameInfo.request
    }

    public init(mainFrame: Bool, request: NSURLRequest) {
      self.frameInfo = WKFrameInfo()
      self.mainFrame = mainFrame
      self.request = request
    }
  }

  // Deprecated stuff

  @available(*, deprecated, message="Use WKNavigationActionData to handle navigation actions")
  public protocol WKNavigationActionProtocol {
    var navigationType: WKNavigationType { get }
    var request: NSURLRequest { get }
  }

  @available(*, deprecated, message="Use WKNavigationActionData to handle navigation actions")
  extension WKNavigationAction: WKNavigationActionProtocol {}

  @available(*, deprecated, message="Use WKNavigationActionData to handle navigation actions")
  internal struct MockNavigationAction: WKNavigationActionProtocol {
    internal let navigationType: WKNavigationType
    internal let request: NSURLRequest
  }
#endif
