extension MessageThread {
  //boris-fixme make internal again
  public static let template = MessageThread(
    backing: nil,
    closed: false,
    id: 1,
    lastMessage: .template,
    participant: .template,
    project: .template,
    unreadMessagesCount: 1
  )
}
