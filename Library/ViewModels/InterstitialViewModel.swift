import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol InterstitialViewModelInputs {
  
}

public protocol InterstitialViewModelOutputs {
  
}

public protocol SignupViewModelType {
  var inputs: InterstitialViewModelInputs { get }
  var outputs: InterstitialViewModelOutputs { get }
}

public final class InterstitialViewModel: SignupViewModelType, InterstitialViewModelInputs, InterstitialViewModelOutputs {
  public var inputs: InterstitialViewModelInputs
  
  public var outputs: InterstitialViewModelOutputs
  
  
}
