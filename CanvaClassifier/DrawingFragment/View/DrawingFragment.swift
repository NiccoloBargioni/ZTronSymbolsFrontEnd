import Autograph
import SwiftUI
import SVGView
import SwiftUIIntrospect

public struct DrawingFragment: View {
    @ObservedObject private var fragmentModel: DrawingFragmentModel
    
    public init(model: DrawingFragmentModel) {
        self._fragmentModel = ObservedObject(wrappedValue: model)
    }
    
    internal var didEndStroking: (() -> Void)?
    private var backgroundColor: Color = Color(UIColor.systemBackground)
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            GeometryReader { geo in
                Autograph(
                    $fragmentModel.strokes,
                    isActive: self.$fragmentModel.isActive,
                    strokeColor: Color.primary
                )
                    .background(self.backgroundColor)
                    .onAppear {
                        fragmentModel.canvaSize = geo.size
                    }
                    .onChange(of: geo.size) { newSize in
                        fragmentModel.canvaSize = newSize
                    }
                    .onChange(of: fragmentModel.isActive) { isNowActive in
                        self.fragmentModel.pushNotification()
                        
                        if !isNowActive {
                            self.didEndStroking?()
                            
                            for stroke in self.fragmentModel.strokes {
                                print("[")
                                for point in stroke {
                                    print("(x: \(point.x), y: \(point.y)),")
                                }
                                print("]")
                            }
                        }
                    }
                    .onChange(of: fragmentModel.strokes.count) { _ in
                        self.fragmentModel.pushNotification()
                    }
            }
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
    
    public func backgroundColor(_ color: Color) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }
}

#Preview {
    DrawingFragment(model: .init(mediator: .init()))
}
