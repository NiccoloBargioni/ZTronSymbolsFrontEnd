import Autograph
import SwiftUI
import SVGView
import SwiftUIIntrospect

struct DrawingFragment: View {
    @State private var strokes: [[CGPoint]] = .init()
    @State private var canvaSize: CGSize = .zero
    @State private var isActive: Bool = false
    
    internal var didEndStroking: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            GeometryReader { geo in
                Autograph(self.$strokes, isActive: self.$isActive)
                    .background(.white)
                    .onAppear {
                        self.canvaSize = geo.size
                    }
                    .onChange(of: geo.size) { newSize in
                        self.canvaSize = newSize
                    }
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(self.isActive ? .green : .orange)
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                    .onChange(of: self.isActive) { isNowActive in
                        if !isNowActive {
                            self.didEndStroking?()
                        }
                    }
            }
            /*
            HStack(alignment: .center, spacing: 0) {
                Button {
                    print("SVG output is: \n\(self.strokes.svg(on: CGSize(width: self.canvaSize.width, height: self.canvaSize.height)) ?? "nil")")
                } label: {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                
                Button {
                    for i in 0..<self.strokes.count {
                        self.strokes[i].removeAll()
                    }
                    
                    self.strokes.removeAll()
                } label: {
                    Image(systemName: "eraser.fill")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                
                Button {
                    if self.strokes.count > 0 {
                        self.strokes[self.strokes.count - 1].removeAll()
                        self.strokes = self.strokes.dropLast()
                    }
                } label: {
                    Image(systemName: "arrow.uturn.left")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                .disabled(self.strokes.count <= 0)
            }
            .tint(.primary)
             */
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Canvas Classifier")
    }

}


extension DrawingFragment {
    public func onStrokeDrawingEnded(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.didEndStroking = action
        return copy
    }
}

#Preview {
    DrawingFragment()
}
