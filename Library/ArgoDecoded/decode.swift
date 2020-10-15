/**
  Attempt to transform `Any` into a `Decodable` value.

  This function takes `Any` (usually the output from
  `NSJSONSerialization`) and attempts to transform it into a `Decodable` value.
  This works based on the type you ask for.

  For example, the following code attempts to decode to `Decoded<String>`,
  because that's what we have explicitly stated is the return type:

  ```
  do {
    let object = try NSJSONSerialization.JSONObjectWithData(data, options: nil)
    let str: Decoded<String> = decode(object)
  } catch {
    // handle error
  }
  ```

  - parameter object: The `Any` instance to attempt to decode

  - returns: A `Decoded<T>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ object: Any) -> Decoded<T> where T == T.DecodedType {
  return T.decode(JSON(object))
}

/**
  Attempt to transform `Any` into an `Array` of `Decodable` values.

  This function takes `Any` (usually the output from
  `NSJSONSerialization`) and attempts to transform it into an `Array` of
  `Decodable` values. This works based on the type you ask for.

  For example, the following code attempts to decode to
  `Decoded<[String]>`, because that's what we have explicitly stated is
  the return type:

  ```
  do {
    let object = try NSJSONSerialization.JSONObjectWithData(data, options: nil)
    let str: Decoded<[String]> = decode(object)
  } catch {
    // handle error
  }
  ```

  - parameter object: The `Any` instance to attempt to decode

  - returns: A `Decoded<[T]>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ object: Any) -> Decoded<[T]> where T == T.DecodedType {
  return Array<T>.decode(JSON(object))
}

/**
  Attempt to transform `Any` into a `Decodable` value and return an `Optional`.

  This function takes `Any` (usually the output from
  `NSJSONSerialization`) and attempts to transform it into a `Decodable` value,
  returning an `Optional`. This works based on the type you ask for.

  For example, the following code attempts to decode to `Optional<String>`,
  because that's what we have explicitly stated is the return type:

  ```
  do {
    let object = try NSJSONSerialization.JSONObjectWithData(data, options: nil)
    let str: String? = decode(object)
  } catch {
    // handle error
  }
  ```

  - parameter object: The `Any` instance to attempt to decode

  - returns: An `Optional<T>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ object: Any) -> T? where T == T.DecodedType {
  return decode(object).value
}

/**
  Attempt to transform `Any` into an `Array` of `Decodable` values and
  return an `Optional`.

  This function takes `Any` (usually the output from
  `NSJSONSerialization`) and attempts to transform it into an `Array` of
  `Decodable` values, returning an `Optional`. This works based on the type you
  ask for.

  For example, the following code attempts to decode to
  `Optional<[String]>`, because that's what we have explicitly stated is
  the return type:

  ```
  do {
    let object = try NSJSONSerialization.JSONObjectWithData(data, options: nil)
    let str: [String]? = decode(object)
  } catch {
    // handle error
  }
  ```

  - parameter object: The `Any` instance to attempt to decode

  - returns: An `Optional<[T]>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ object: Any) -> [T]? where T == T.DecodedType {
  return decode(object).value
}

/**
  Attempt to transform `Any` into a `Decodable` value using a specified
  root key.

  This function attempts to extract the embedded `JSON` object from the
  dictionary at the specified key and transform it into a `Decodable` value.
  This works based on the type you ask for.

  For example, the following code attempts to decode to `Decoded<String>`,
  because that's what we have explicitly stated is the return type:

  ```
  do {
    let dict = try NSJSONSerialization.JSONObjectWithData(data, options: nil) as? [String: Any] ?? [:]
    let str: Decoded<String> = decode(dict, rootKey: "value")
  } catch {
    // handle error
  }
  ```

  - parameter dict: The dictionary containing the `Any` instance to
                    attempt to decode
  - parameter rootKey: The root key that contains the object to decode

  - returns: A `Decoded<T>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ dict: [String: Any], rootKey: String) -> Decoded<T> where T == T.DecodedType {
  return JSON(dict as Any) <| rootKey
}

/**
  Attempt to transform `Any` into an `Array` of `Decodable` value using a
  specified root key.

  This function attempts to extract the embedded `JSON` object from the
  dictionary at the specified key and transform it into an `Array` of
  `Decodable` values. This works based on the type you ask for.

  For example, the following code attempts to decode to `Decoded<[String]>`,
  because that's what we have explicitly stated is the return type:

  ```
  do {
    let dict = try NSJSONSerialization.JSONObjectWithData(data, options: nil) as? [String: Any] ?? [:]
    let str: Decoded<[String]> = decode(dict, rootKey: "value")
  } catch {
    // handle error
  }
  ```

  - parameter dict: The dictionary containing the `Any` instance to
                    attempt to decode
  - parameter rootKey: The root key that contains the object to decode

  - returns: A `Decoded<[T]>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ dict: [String: Any], rootKey: String) -> Decoded<[T]> where T == T.DecodedType {
  return JSON(dict as Any) <|| rootKey
}

/**
  Attempt to transform `Any` into a `Decodable` value using a specified
  root key and return an `Optional`.

  This function attempts to extract the embedded `JSON` object from the
  dictionary at the specified key and transform it into a `Decodable` value,
  returning an `Optional`. This works based on the type you ask for.

  For example, the following code attempts to decode to `Optional<String>`,
  because that's what we have explicitly stated is the return type:

  ```
  do {
    let dict = try NSJSONSerialization.JSONObjectWithData(data, options: nil) as? [String: Any] ?? [:]
    let str: String? = decode(dict, rootKey: "value")
  } catch {
    // handle error
  }
  ```

  - parameter dict: The dictionary containing the `Any` instance to
                    attempt to decode
  - parameter rootKey: The root key that contains the object to decode

  - returns: A `Decoded<T>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ dict: [String: Any], rootKey: String) -> T? where T == T.DecodedType {
  return decode(dict, rootKey: rootKey).value
}

/**
  Attempt to transform `Any` into an `Array` of `Decodable` value using a
  specified root key and return an `Optional`

  This function attempts to extract the embedded `JSON` object from the
  dictionary at the specified key and transform it into an `Array` of
  `Decodable` values, returning an `Optional`. This works based on the type you
  ask for.

  For example, the following code attempts to decode to `Optional<[String]>`,
  because that's what we have explicitly stated is the return type:

  ```
  do {
    let dict = try NSJSONSerialization.JSONObjectWithData(data, options: nil) as? [String: Any] ?? [:]
    let str: [String]? = decode(dict, rootKey: "value")
  } catch {
    // handle error
  }
  ```

  - parameter dict: The dictionary containing the `Any` instance to
                    attempt to decode
  - parameter rootKey: The root key that contains the object to decode

  - returns: A `Decoded<[T]>` value where `T` is `Decodable`
*/
public func decode<T: Decodable>(_ dict: [String: Any], rootKey: String) -> [T]? where T == T.DecodedType {
  return decode(dict, rootKey: rootKey).value
}
