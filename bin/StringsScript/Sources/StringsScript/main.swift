import StringsScriptCore

let tool = CommandLineTool()

do {
  try tool.run()
} catch {
  print("Whoops! An error occurred: \(error)")
}
