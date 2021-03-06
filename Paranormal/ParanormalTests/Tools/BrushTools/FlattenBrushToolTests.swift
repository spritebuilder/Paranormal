import Cocoa
import Quick
import Nimble
import Paranormal

class FlattenToolTests: QuickSpec {
    override func spec() {
        describe("AngleBrushTool") {
            var editorViewController : EditorViewController!
            var document : Document?
            var editorView : EditorView?
            var planeTool : PlaneTool!

            beforeEach {
                editorViewController = EditorViewController(nibName: "Editor", bundle: nil)
                editorView = editorViewController.view as? EditorView
                let documentController = DocumentController()
                for doc in documentController.documents {
                    documentController.removeDocument(doc as NSDocument)
                }

                documentController.createDocumentFromUrl(nil)
                document = documentController.documents[0] as? Document

                editorViewController.document = document

                planeTool = PlaneTool()
                expect(ThreadUtils.doneProcessingGPUImage()).toEventually(beTrue())
            }

            describe("Flattening makes an area flatter") {
                beforeEach {
                    document?.toolSettings.setColorAsNSColor(
                        NSColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0))
                    document?.toolSettings.size = 9.0;
                    document?.toolSettings.strength = 1.0;

                    planeTool.mouseDownAtPoint(NSPoint(x: 20, y: 20),
                        editorViewController: editorViewController)
                    planeTool.mouseDraggedAtPoint(NSPoint(x: 60, y: 60),
                        editorViewController: editorViewController)
                    planeTool.mouseUpAtPoint(NSPoint(x: 40, y: 40),
                        editorViewController: editorViewController)
                    planeTool?.stopUsingTool()
                    expect(planeTool.drawingKernel?.doneDrawing()).toEventually(beTrue())

                    document?.computeDerivedData()
                    expect(ThreadUtils.doneProcessingGPUImage()).toEventually(beTrue())
                }

                // Race condition is reappearing here. No idea why.
                xit("Without opacity") {
                    document?.toolSettings.size = 5.0;
                    let flattenTool = FlattenTool()

                    flattenTool.mouseDownAtPoint(NSPoint(x: 20, y: 20),
                        editorViewController: editorViewController)
                    flattenTool.mouseDraggedAtPoint(NSPoint(x: 60, y: 60),
                        editorViewController: editorViewController)
                    flattenTool.mouseUpAtPoint(NSPoint(x: 40, y: 40),
                        editorViewController: editorViewController)
                    flattenTool.stopUsingTool()
                    expect(flattenTool.drawingKernel?.doneDrawing()).toEventually(beTrue())
                    expect(flattenTool.editLayer).toEventually(beNil())

                    // kick the editor and document into updating
                    document?.computeDerivedData()
                    expect(ThreadUtils.doneProcessingGPUImage()).toEventually(beTrue())
                    let image = document?.computedNormalImage

                    var color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 0, y:0))
                    expect(color).to(beColor(127, 127, 255, 255))

                    color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 40, y:40))
                    expect(color).to(beColor(127, 127, 255, 255))
                }

                xit("With opacity") {
                    document?.toolSettings.size = 5.0;
                    document?.toolSettings.strength = 0.5;
                    let flattenTool = FlattenTool()

                    flattenTool.mouseDownAtPoint(NSPoint(x: 20, y: 20),
                        editorViewController: editorViewController)
                    flattenTool.mouseDraggedAtPoint(NSPoint(x: 60, y: 60),
                        editorViewController: editorViewController)
                    flattenTool.mouseUpAtPoint(NSPoint(x: 40, y: 40),
                        editorViewController: editorViewController)
                    flattenTool.stopUsingTool()

                    expect(flattenTool.drawingKernel?.doneDrawing()).toEventually(beTrue())
                    expect(flattenTool.editLayer).toEventually(beNil())

                    // kick the editor and document into updating
                    document?.computeDerivedData()
                    expect(ThreadUtils.doneProcessingGPUImage()).toEventually(beTrue())
                    let image = document?.computedNormalImage

                    var color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 0, y:0))
                    expect(color).to(beColor(127, 127, 255, 255))

                    color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 40, y:40))
                    expect(color).to(beColor(217, 128, 218, 255))
                }
            }
        }
    }
}
