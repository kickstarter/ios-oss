import StringsScriptCore

let tool = StringsScript()

do {
  try tool.run()
} catch {
  print("Whoops! An error occurred: \(error)")
}
