import UIKit

// No view models, yet. --> Wait for Toby's stuff
// No tests yet. --> Wait for Toby's stuff
// See if you can fix that overpadding on hitting return in the text view. Think about enabling scrolling only once the text view has reached its maximum height, maybe a little less.
// See if you can make the textview's delegate reactive.

// Note: This code is not final. It is for demonstration purposes only.
class CommentInputAccessoryView: UIView, UITextViewDelegate {
   lazy private let commentTextView: UITextView {
      let textView = UITextView()
      
      textView.backgroundColor = .lightGray
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.delegate = self
      textView.isScrollEnabled = false
      
      return textView
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        self.addSubview(commentTextView)
        self.constrainView(commentTextView)
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let textSize = self.commentTextView.sizeThatFits(CGSize(width: self.commentTextView.bounds.width,
                                                                height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: self.bounds.width,
                      height: textSize.height)
    }

    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        // Re-calculate intrinsicContentSize when text changes
        self.invalidateIntrinsicContentSize()
    }
  
  // MARK: Helpers

  private func constrainView(_ view: UITextView) {
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: ["view": view]))
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view(<=100)]|",
                                                       options: [],
                                                       metrics: nil,
                                                       views: ["view": view]))
  }
}
