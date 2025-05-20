//
//  FreeFormDrawingView.swift
//  CanvaClassifier
//
//  Created by Niccolo Della Rocca on 29/01/25.
//


import SwiftUI
import PencilKit

struct FreeFormDrawingView: View {
    
    @State private var canvas = PKCanvasView()
    @State private var isDrawing = true
    @State private var color: Color = .black
    @State private var pencilType: PKInkingTool.InkType = .pencil
    @State private var colorPicker = false
    @Environment(\.undoManager) private var undoManager
    
    @State private var isMessaging = false
    @State private var isVideoCalling = false
    @State private var isScreenSharing = false
    @State private var isRecording = false
    @Environment(\.dismiss) private var dismiss
    
   
   
    
    var body: some View {
            DrawingView(canvas: $canvas, isDrawing: $isDrawing, pencilType: $pencilType, color: $color)
            //.navigationTitle("PKDraw")
                .navigationBarTitleDisplayMode(.inline)
    }
    
    func saveDrawing() {
        // Get the drawing image from the canvas
        let drawingImage = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1.0)
        
        // Save drawings to the Photos Album
        UIImageWriteToSavedPhotosAlbum(drawingImage, nil, nil, nil)
    }
}

struct DrawingView: UIViewRepresentable {
    // Capture drawings for saving in the photos library
    @Binding var canvas: PKCanvasView
    @Binding var isDrawing: Bool
    // Ability to switch a pencil
    @Binding var pencilType: PKInkingTool.InkType
    // Ability to change a pencil color
    @Binding var color: Color
    
    
    //let ink = PKInkingTool(.pencil, color: .black)
    // Update ink type
    var ink: PKInkingTool {
        PKInkingTool(pencilType, color: UIColor(color))
    }
    
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        // Allow finger and pencil drawing
        canvas.drawingPolicy = .anyInput
        
        canvas.tool = isDrawing ? ink : eraser
        canvas.isRulerActive = true
        canvas.backgroundColor = .init(red: 1, green: 1, blue: 0, alpha: 0.1)

        
        // From Brian Advent: Show the default toolpicker
        canvas.alwaysBounceVertical = true
        
        let toolPicker = PKToolPicker.init()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas) // Notify when the picker configuration changes
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool whenever the main view updates
        uiView.tool = isDrawing ? ink : eraser
    }
}


#Preview {
    FreeFormDrawingView()
}
