import Prelude

extension ExportDataEnvelope {
  public enum lens {
    public static let expiresAt = Lens<ExportDataEnvelope, String?>(
      view: { $0.expiresAt },
      set: { ExportDataEnvelope(expiresAt: $0, state: $1.state, dataUrl: $1.dataUrl) }
    )
    public static let state = Lens<ExportDataEnvelope, State>(
      view: { $0.state },
      set: { ExportDataEnvelope(expiresAt: $1.expiresAt, state: $0, dataUrl: $1.dataUrl) }
    )
    public static let dataUrl = Lens<ExportDataEnvelope, String?>(
      view: { $0.dataUrl },
      set: { ExportDataEnvelope(expiresAt: $1.expiresAt, state: $1.state, dataUrl: $0) }
    )
  }
}
