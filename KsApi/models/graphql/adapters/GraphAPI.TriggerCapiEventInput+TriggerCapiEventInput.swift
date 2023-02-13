extension GraphAPI.TriggerCapiEventInput {
  static func from(_ input: TriggerCapiEventInput) -> GraphAPI.TriggerCapiEventInput {
    return GraphAPI.TriggerCapiEventInput(
      projectId: input.projectId,
      eventName: input.eventName,
      externalId: input.externalId,
      userEmail: input.userEmail,
      appData: input.appData,
      customData: input.customData,
      waitForConsent: input.waitForConsent
    )
  }
}
