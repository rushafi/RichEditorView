//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol RichEditorToolbarDelegate: class {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}

/// RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
@objcMembers open class RichBarButtonItem: UIBarButtonItem {
	public var isSelected: Bool = false {
		didSet {
			updateTintColor()
		}
	}
	open var defaultTintColor = UIColor.black
	open var selectedTintColor = UIColor.blue
	open var actionHandler: ((_ item: RichBarButtonItem) -> Void)?

	var formattingType: FormattingType? {
		didSet {
			let defaultCenter = NotificationCenter.default

			guard let formattingType = self.formattingType else {return}

			switch formattingType {
			case .bold:
				defaultCenter.addObserver(forName: Notification.Name.RichEditor.BoldFormattingChanged, object: nil, queue: OperationQueue.main) { (notification) -> Void in
					if let flag = notification.userInfo!["flag"] as? Bool {
						self.isSelected = flag
					}
				}
			case .italic:
				defaultCenter.addObserver(forName: Notification.Name.RichEditor.ItalicFormattingChanged, object: nil, queue: OperationQueue.main) { (notification) -> Void in
					if let flag = notification.userInfo!["flag"] as? Bool {
						self.isSelected = flag
					}
				}
			case .underline:
				defaultCenter.addObserver(forName: Notification.Name.RichEditor.UnderlineFormattingChanged, object: nil, queue: OperationQueue.main) { (notification) -> Void in
					if let flag = notification.userInfo!["flag"] as? Bool {
						self.isSelected = flag
					}
				}
			case .strikeThrough:
				defaultCenter.addObserver(forName: Notification.Name.RichEditor.StrikeThroughFormattingChanged, object: nil, queue: OperationQueue.main) { (notification) -> Void in
					if let flag = notification.userInfo!["flag"] as? Bool {
						self.isSelected = flag
					}
				}
			case .unorderedList:
				defaultCenter.addObserver(forName: Notification.Name.RichEditor.UnorderedListFormattingChanged, object: nil, queue: OperationQueue.main) { (notification) -> Void in
					if let flag = notification.userInfo!["flag"] as? Bool {
						self.isSelected = flag
					}
				}
			}
		}
	}
    
	public convenience init(image: UIImage? = nil, handler: ((_ item: RichBarButtonItem) -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        commonInit(handler)
    }
    
    public convenience init(title: String = "", handler: ((_ item: RichBarButtonItem) -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        commonInit(handler)
    }

	private func commonInit(_ handler: ((_ item: RichBarButtonItem) -> Void)?) {
		target = self
		action = #selector(RichBarButtonItem.buttonWasTapped)
		actionHandler = handler
		tintColor = defaultTintColor
	}
    
	@objc func buttonWasTapped() {
		isSelected = !isSelected
		updateTintColor()
        actionHandler?(self)
    }

	private func updateTintColor() {
		if isSelected {
			tintColor = selectedTintColor
		} else {
			tintColor = defaultTintColor
		}
	}
}

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
@objcMembers open class RichEditorToolbar: UIView {

    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: RichEditorToolbarDelegate?

    /// A reference to the RichEditorView that it should be performing actions on
    open weak var editor: RichEditorView?

    /// The list of options to be displayed on the toolbar
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    /// The tint color to apply to the toolbar background.
    open var barTintColor: UIColor? {
        get { return toolbar.barTintColor }
        set { toolbar.barTintColor = newValue }
    }

	open var defaultTintColor = UIColor.black {
		didSet {
			updateToolbar()
		}
	}
	open var selectedTintColor = UIColor.blue {
		didSet {
			updateToolbar()
		}
	}

    private var toolbarScroll: UIScrollView
    private var toolbar: UIToolbar

    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear

		toolbar.autoresizingMask = .flexibleWidth
		toolbar.backgroundColor = .black
		toolbar.isTranslucent = false
		toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
		toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

		toolbarScroll.frame = bounds
		toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		toolbarScroll.showsHorizontalScrollIndicator = false
		toolbarScroll.showsVerticalScrollIndicator = false
		toolbarScroll.backgroundColor = .clear

        toolbarScroll.addSubview(toolbar)

		options = [RichEditorDefaultOption.bold, RichEditorDefaultOption.italic, RichEditorDefaultOption.underline, RichEditorDefaultOption.strike, RichEditorDefaultOption.unorderedList]

        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    private func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        for option in options {
			let handler = { [weak self] (item: RichBarButtonItem) in
				if let strongSelf = self {
					option.action(strongSelf, item)
				}
			}
			var button: RichBarButtonItem
			if let image = option.image {
				button = RichBarButtonItem(image: image, handler: handler)
			} else {
				let title = option.title
				button = RichBarButtonItem(title: title, handler: handler)
			}
			button.defaultTintColor = defaultTintColor
			button.selectedTintColor = selectedTintColor
			option.configure(withItem: button)
			buttons.append(button)
        }
		let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = Array(buttons.map {[$0]}.joined(separator: [separator]))

        let defaultIconWidth: CGFloat = 22
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            toolbar.frame.size.width = frame.size.width
        } else {
            toolbar.frame.size.width = width
        }
        toolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
    
}
