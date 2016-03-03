import class ReactiveCocoa.MutableProperty
import protocol Prelude.OptionalType
import struct Prelude.Unit

/// View models that are used with cells (e.g. table/collection views) should conform to this protocol
/// so that MVVMDataSource can guarantee that the data fed to it matches what cells expect.
public protocol ViewModelType {
  typealias Model
}

/// Cells (e.g. table/collection cells) that bind to a view model should conform to this protocol so that
/// MVVMDataSource can guarantee that the data fed to it matches what cells expect.
public protocol ViewModeledCellType {
  typealias ViewModel: ViewModelType
  var viewModel: MutableProperty<ViewModel?> { get }
}

/// `Unit` can trivially be made into a view model type.
extension Unit : ViewModelType {
  public typealias Model = Unit
}

/// Optionals of view models can trivially be made into view models.
extension Prelude.OptionalType where Wrapped: ViewModelType {
  typealias Model = Wrapped
}
