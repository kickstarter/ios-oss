import class ReactiveCocoa.MutableProperty
import struct ReactiveCocoa.SignalProducer
import enum Result.NoError
import protocol Prelude.OptionalType
import struct Prelude.Unit

/// View models that are used with cells (e.g. table/collection views) should conform to this protocol
/// so that MVVMDataSource can guarantee that the data fed to it matches what cells expect.
public protocol ViewModelType {
  associatedtype Model
}

/// Cells (e.g. table/collection cells) that bind to a view model should conform to this protocol so that
/// MVVMDataSource can guarantee that the data fed to it matches what cells expect.
public protocol ViewModeledCellType {
  associatedtype ViewModel: ViewModelType
  var viewModelProperty: MutableProperty<ViewModel?> { get }
}

public extension ViewModeledCellType {
  // A producer of view model signals. Automatically ignores the `nil` view model that
  // is initially emitted.
  public var viewModel: SignalProducer<ViewModel, NoError> {
    return self.viewModelProperty.producer.ignoreNil()
  }
}

/// `Unit` can trivially be made into a view model type.
extension Unit: ViewModelType {
  public typealias Model = Unit
}

/// Optionals of view models can trivially be made into view models.
extension Prelude.OptionalType where Wrapped: ViewModelType {
  public typealias Model = Wrapped
}
