public protocol LiveStreamChatMessageCellViewModelType {
  var inputs: LiveStreamChatMessageCellViewModelInputs { get }
  var outputs: LiveStreamChatMessageCellViewModelOutputs { get }
}

public protocol LiveStreamChatMessageCellViewModelInputs {

}

public protocol LiveStreamChatMessageCellViewModelOutputs {

}

public final class LiveStreamChatMessageCellViewModel: LiveStreamChatMessageCellViewModelType,
LiveStreamChatMessageCellViewModelInputs, LiveStreamChatMessageCellViewModelOutputs {

  init() {

  }

  public var inputs: LiveStreamChatMessageCellViewModelInputs { return self }
  public var outputs: LiveStreamChatMessageCellViewModelOutputs { return self }
}
