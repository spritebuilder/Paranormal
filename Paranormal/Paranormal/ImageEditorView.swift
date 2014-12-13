import Foundation
import Cocoa
import AppKit

class ImageEditorView : NSImageView {

    @IBOutlet var delegate : EditorViewController?

    override func layout () {
        super.layout()
        delegate?.editorViewDidLayout()
    }

    override func mouseDown(theEvent: NSEvent) {
        delegate?.mouseDown(theEvent)
    }

    override func mouseDragged(theEvent: NSEvent) {
        delegate?.mouseDragged(theEvent)
    }

    override func mouseUp(theEvent: NSEvent) {
        delegate?.mouseUp(theEvent)
    }
}