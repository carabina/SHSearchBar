//
//  SHSearchBar.swift
//  Pods
//
//  Created by Stefan Herold on 01/08/16.
//
//

import UIKit

public class SHSearchBar: UIView, UITextFieldDelegate {
    public static var kDefaultAnimationDuration: TimeInterval = 0.25
    public static var kDefaultRasterSize: CGFloat = 11.0

    private(set) var backgroundView: UIImageView = UIImageView()

    public var cancelButton: UIButton = UIButton(type: .custom)
    public var textField: UITextField = UITextField()

    // Constraints for showing and hiding the cancel button
    private(set) var bgToCancelButtonConstraint: NSLayoutConstraint!
    private(set) var bgToParentConstraint: NSLayoutConstraint!
    
    public var delegate: SHSearchBarDelegate?
    
    
    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.isUserInteractionEnabled = true
        updateBackgroundWith(0, corners: .allCorners, color: UIColor.white)
        addSubview(backgroundView)

        // Text Field
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.adjustsFontSizeToFitWidth = false
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: SHSearchBar.kDefaultRasterSize, height: 10.0))

        // These are the properties you probably want to customize
        textField.leftViewMode = .always
        textField.rightViewMode = .never
        textField.clearButtonMode = .whileEditing
        textField.tintColor = UIColor.black // Styles the cursor as well as the selection marker
        textField.defaultTextAttributes = [NSForegroundColorAttributeName:UIColor.black, NSBackgroundColorAttributeName: UIColor.clear]
        textField.typingAttributes = textField.defaultTextAttributes

        textField.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(textField)

        // Cancel Button
        cancelButton.alpha = 0.0
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "") , for: UIControlState())
        cancelButton.setTitleColor(UIColor.black, for: UIControlState())
        cancelButton.setTitleColor(UIColor.darkGray, for: .highlighted)
        cancelButton.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        cancelButton.reversesTitleShadowWhenHighlighted = true
        cancelButton.adjustsImageWhenHighlighted = true
        cancelButton.addTarget(self, action: #selector(SHSearchBar.pressedCancelButton(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cancelButton)
        sendSubview(toBack: cancelButton)

        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupConstraints() {
        let views = ["text":textField, "bg":backgroundView, "cancel":cancelButton]
        let metrics = ["margin":SHSearchBar.kDefaultRasterSize]
        
        let formatList: [String] = [
            // Background
            "H:|[bg]",
            "V:|[bg]|",
            // Text field
            "H:|[text]|",
            "V:|[text]|",
            // Cancel Button
            "H:[cancel]|",
            "V:|[cancel]|"
            ]

        for format in formatList {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: metrics, views: views))
        }

        bgToCancelButtonConstraint = NSLayoutConstraint(item: backgroundView, attribute: .trailing, relatedBy: .equal, toItem: cancelButton, attribute: .leading, multiplier: 1, constant: -SHSearchBar.kDefaultRasterSize)
        bgToParentConstraint = NSLayoutConstraint(item: backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        bgToParentConstraint.isActive = true
    }


    // MARK: - UI Updates

    //! Use this function to specify the views corner radii. It will be applied to a special background image view (not the search bar itself) that spans the whole search bar. The backgroundColor of this view must remain clear to make the corner radius visible.
    public func updateBackgroundWith(_ radius: CGFloat, corners: UIRectCorner, color: UIColor) {
        let insets = UIEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
        let imgSize = CGSize(width: radius*2 + 1, height: radius*2 + 1)
        var img = UIImage.imageWithSolidColor(color, size: imgSize)
        img = img.roundedImage(with: radius, cornersToRound: corners)
        img = img.resizableImage(withCapInsets: insets)
        backgroundView.image = img
        backgroundColor = UIColor.clear
    }


    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBegin = delegate?.searchBarShouldBeginEditing?(self) ?? true
        if shouldBegin {
            setCancelButtonVisibility(true)
        }
        return shouldBegin
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarDidBeginEditing?(self)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let shouldEnd = delegate?.searchBarShouldEndEditing?(self) ?? true
        if shouldEnd {
            setCancelButtonVisibility(false)
        }
        return shouldEnd
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.searchBarDidEndEditing?(self)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let shouldChange = delegate?.searchBar?(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
        return shouldChange
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let shouldClear = delegate?.searchBarShouldClear?(self) ?? true
        return shouldClear
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = delegate?.searchBarShouldReturn?(self) ?? true
        return shouldReturn
    }
    
    // MARK: - Cancel Button Management
    
    func pressedCancelButton(_ sender: AnyObject) {
        textField.resignFirstResponder()
        delegate?.searchBarShouldCancel?(self)
    }

    func setCancelButtonVisibility(_ makeVisible: Bool) {
        // Thsi 'complex' if-else avoids constraint warnings in the console
        if makeVisible {
            bgToParentConstraint.isActive = false
            bgToCancelButtonConstraint.isActive = true
        } else {
            bgToCancelButtonConstraint.isActive = false
            bgToParentConstraint.isActive = true
        }

        UIView.animate(withDuration: SHSearchBar.kDefaultAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.layoutIfNeeded()
            self.cancelButton.alpha = makeVisible ? 1 : 0
        }, completion: nil)
    }
}



@objc
public protocol SHSearchBarDelegate : NSObjectProtocol {
    // UITextField Pendants
    @objc optional func searchBarShouldBeginEditing(_ searchBar: SHSearchBar) -> Bool // return NO to disallow editing.
    @objc optional func searchBarDidBeginEditing(_ searchBar: SHSearchBar) // became first responder
    @objc optional func searchBarShouldEndEditing(_ searchBar: SHSearchBar) -> Bool // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    @objc optional func searchBarDidEndEditing(_ searchBar: SHSearchBar) // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    @objc optional func searchBar(_ searchBar: SHSearchBar, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool // return NO to not change text
    @objc optional func searchBarShouldClear(_ searchBar: SHSearchBar) -> Bool // called when clear button pressed. return NO to ignore (no notifications)
    @objc optional func searchBarShouldReturn(_ searchBar: SHSearchBar) -> Bool // called when 'return' key pressed. return NO to ignore.
    
    // New delegate methods
    @objc optional func searchBarShouldCancel(_ searchBar: SHSearchBar) -> Bool // called when 'cancel' button pressed.
    @objc optional func searchBar(_ searchBar: SHSearchBar, textDidChange text: String) // Called when the text did change
}
