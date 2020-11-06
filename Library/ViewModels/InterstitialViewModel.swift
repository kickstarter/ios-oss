import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol InterstitialViewModelInputs {
  /// Call when the view did load.
  func viewDidLoad()

}

public protocol InterstitialViewModelOutputs {
  
}

public protocol InterstitialViewModelType {
  var inputs: InterstitialViewModelInputs { get }
  var outputs: InterstitialViewModelOutputs { get }
}

public final class InterstitialViewModel: InterstitialViewModelType, InterstitialViewModelInputs, InterstitialViewModelOutputs {
  
  public init(){
    
  }
  
  public var inputs: InterstitialViewModelInputs { return self }
  public var outputs: InterstitialViewModelOutputs { return self }
  
  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
}
