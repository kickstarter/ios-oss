import Apollo
import GraphAPI
@testable import KsApi
import XCTest

public extension GraphQLQuery {
  func snapshot(_ snapshotName: String, recordQuery: Bool = false, filePath: String = #filePath) -> Data? {
    if recordQuery {
      self.saveQueryToSnapshot(snapshotName, forTestPath: filePath)
    }

    return self.fromSnapshot(snapshotName, forTestPath: filePath)
  }

  internal func snapshotURL(_ snapshotName: String, forTestPath path: String) -> URL {
    // TODO: Create a __DATA__ directory and save the snapshot there
    let fileUrl = URL(fileURLWithPath: path, isDirectory: false)
    let testDirectory = fileUrl.deletingLastPathComponent()

    let snapshotName = "\(snapshotName).json"
    return testDirectory.appendingPathComponent(snapshotName)
  }

  private func blockComment(_ string: String) -> String {
    return "# " + string.components(separatedBy: CharacterSet.newlines)
      .joined(separator: "\n# ")
  }

  private func prettyPrintVariables() -> String {
    guard let variables = self.__variables else {
      return "{}"
    }

    do {
      let jsonEncodedVariables = try JSONSerialization.data(
        withJSONObject: variables as Any,
        options: [.prettyPrinted]
      )
      if let variablesString = String(data: jsonEncodedVariables, encoding: .utf8) {
        return variablesString
      }
    } catch {}

    return "{}"
  }

  private func createQueryText() -> String {
    let queryText = Self.operationDocument.definition?.queryDocument ?? ""

    let warning = """
    Fetch this query using your GraphQL interface of choice, 
    and copy the results into the snapshot file.

    With great power comes great responsibility:
    ⚠️ *YOU* are responsible for reviewing and redacting this data.
    """

    let variables = self.prettyPrintVariables()

    return """
    \(self.blockComment(warning))

    # Variables:
    \(self.blockComment(variables))

    # Query:
    \(queryText)
    """
  }

  internal func saveQueryToSnapshot(_ snapshotName: String, forTestPath path: String) {
    let snapshotURL = snapshotURL(snapshotName, forTestPath: path)
    self.writeData(self.createQueryText(), toURL: snapshotURL)
  }

  internal func writeData(_ result: String, toURL snapshotURL: URL) {
    do {
      if let data = result.data(using: .utf8) {
        try data.write(to: snapshotURL)
      } else {
        XCTFail("Unable to record query defintion.")
      }

      XCTFail(
        "Successfully recorded query definition to \(snapshotURL.absoluteString). Use the query definition to record your GraphQL query."
      )
    } catch {
      XCTFail("Failed to write query to snapshot: \(error.localizedDescription)")
    }
  }

  internal func fromSnapshot(_ snapshotName: String, forTestPath path: String) -> Data? {
    let url = self.snapshotURL(snapshotName, forTestPath: path)

    do {
      let jsonData = try Foundation.Data(contentsOf: url)

      // TODO: Verify that this is actually loading GraphQL data, not the test query.
      // Can probably do that here.
      let json = try JSONSerialization.jsonObject(with: jsonData) as! JSONObject
      let data = json["data"]
      return try Data.init(data: data as! JSONObject, variables: self.__variables)
    } catch {
      XCTFail("Unable to create data for \(snapshotName). Did you mean to use record?")
      return nil
    }
  }
}
