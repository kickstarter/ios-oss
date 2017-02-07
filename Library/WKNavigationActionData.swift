#if os(iOS)
  import WebKit

  public struct WKNavigationActionData {
    public let navigationAction: WKNavigationAction
    public let navigationType: WKNavigationType
    public let request: URLRequest
    public let targetFrame: WKFrameInfoData?

    public init(navigationAction: WKNavigationAction) {
      self.navigationAction = navigationAction
      self.navigationType = navigationAction.navigationType
      self.request = navigationAction.request
      self.targetFrame = navigationAction.targetFrame.map(WKFrameInfoData.init(frameInfo:))
    }

    internal init(navigationType: WKNavigationType,
                  request: URLRequest,
                  sourceFrame: WKFrameInfoData,
                  targetFrame: WKFrameInfoData?) {
      self.navigationAction = WKNavigationAction()
      self.navigationType = navigationType
      self.request = request
      self.targetFrame = targetFrame
    }
  }

  public struct WKFrameInfoData {
    public let frameInfo: WKFrameInfo
    public let mainFrame: Bool

    public init(frameInfo: WKFrameInfo) {
      self.frameInfo = frameInfo
      self.mainFrame = frameInfo.isMainFrame
    }

    public init(mainFrame: Bool, request: URLRequest) {
      self.frameInfo = WKFrameInfo()
      self.mainFrame = mainFrame
    }
  }
#endif
