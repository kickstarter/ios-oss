public protocol Decodable {
  /**
    The type of object that will be decoded.

    In order to work with the rest of Argo, this needs to be the same as `Self`.

    You will only need to worry about this if the object conforming to
    `Decodable` is a reference type (i.e. a `class`), and one of the following
    is true:

     - Your type is not marked as `final`
     - Your `decode` function is not marked as either `final` or `static`

    In that case, you will need to explicitly set `DecodedType` to the type you
    are returning in order for the compiler to be able to guarantee that this
    protocol is being fully conformed to.

    We expect the need for this typealias to be removed in a later version of Swift.
  */
  associatedtype DecodedType = Self

  /**
    Decode an object from JSON.

    This is the main entry point for Argo. This function declares how the
    conforming type should be decoded from JSON. Since this is a failable
    operation, we need to return a `Decoded` type from this function.

    - parameter json: The `JSON` representation of this object

    - returns: A decoded instance of the `DecodedType`
  */
  static func decode(_ json: JSON) -> Decoded<DecodedType>
}
