import Prelude

extension ExportDataEnvelope {

  internal static let template = ExportDataEnvelope(
    expiresAt: "2018-06-19T13:12:00Z",
    state: .completed,
    dataUrl: "http://requestdata.com/givemedata"
  )
}
