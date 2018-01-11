//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView

class ViewController: UIViewController {

    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var htmlTextView: UITextView!

    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
		editorView.placeholder = "Type here"
		editorView.placeholderColor = UIColor.gray
		editorView.fontColor = UIColor.white

        toolbar.delegate = self
        toolbar.editor = editorView

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar, _ in
            toolbar.editor?.html = ""
        }

        var options = toolbar.options
        options.append(item)
        toolbar.options = options
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		setFocusIfNeeded()
	}

	private var needsToSetFocus: Bool = false
	private func setFocusIfNeeded() {
		if needsToSetFocus {
			editorView.focus()
		}
		needsToSetFocus = !needsToSetFocus
	}
}

extension ViewController: RichEditorDelegate {

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }

	func richEditorDidLoad(_ editor: RichEditorView) {
		editorView.setFont(UIFont(name: "Avenir-Book", size: 24)!)

		setFocusIfNeeded()
	}
}

extension ViewController: RichEditorToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
}
