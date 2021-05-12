import UIKit

// NOTE: This code is not final. It is for demonstration purposes only. (Ie. No tests, no view models, styles until we merge  with https://kickstarter.atlassian.net/browse/NT-1893)
class CommentInputAccessoryView: UIView {
  // MARK: Properties
  private let commentTextView = UITextView()
  // TODO: 100 pixels here seems to be 200 pixels as described in the ticket above. May want to reconfirm if this is in points.
  private let maximumTextViewHeight: CGFloat = 100.0
  private let scrollTextViewThresholdHeight: CGFloat = 80.0
  
  // MARK: Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
    self.setupTextView()
    self.addSubview(commentTextView)
    self.constrainView(commentTextView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: View lifecycle
  override var intrinsicContentSize: CGSize {
    let textSize = self.commentTextView.sizeThatFits(CGSize(width: self.commentTextView.bounds.width,
                                                            height: CGFloat.greatestFiniteMagnitude))
    let contentSize = CGSize(width: self.bounds.width, height: textSize.height)
    
    return contentSize
  }
  
  // MARK: Helpers
  private func setupTextView() {
    commentTextView.backgroundColor = .lightGray
    commentTextView.translatesAutoresizingMaskIntoConstraints = false
    commentTextView.delegate = self
    commentTextView.isScrollEnabled = false
  }
  
  private func constrainView(_ view: UITextView) {
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: ["view": view]))
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view(<=\(maximumTextViewHeight))]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: ["view": view]))
  }
}

// MARK: UITextViewDelegate
// TODO: Is there a better reactive way to do this? I know RxSwift had things like textField.rx.didChange properties that could be subscribed to...
extension CommentInputAccessoryView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    invalidateIntrinsicContentSize()
    
    commentTextView.isScrollEnabled = bounds.height >= scrollTextViewThresholdHeight
  }
}
