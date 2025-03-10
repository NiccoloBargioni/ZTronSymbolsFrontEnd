import SwiftUI
import ZTronObservation

public struct ContentView: View {
    private var mediator: MSAMediator = .init()
    @StateObject private var pageModel: DrawingPageModel
    @StateObject private var fragmentModel: DrawingFragmentModel

    public init() {
        let mediator = self.mediator
        self._pageModel = StateObject(wrappedValue: DrawingPageModel(mediator: mediator))
        self._fragmentModel = StateObject(wrappedValue: DrawingFragmentModel(mediator: mediator))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AutographView(mediator: self.mediator, fragmentModel: self.fragmentModel)
            
            HStack(alignment: .center, spacing: 0) {
                Button {
                    self.pageModel.sendSave()
                } label: {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                
                Button {
                    self.pageModel.sendClear()
                } label: {
                    Image(systemName: "eraser.fill")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                
                Button {
                    self.pageModel.sendUndoLastStroke()
                } label: {
                    Image(systemName: "arrow.uturn.left")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                .disabled(self.pageModel.isUndoButtonDisabled)
            }
            .tint(.primary)
        }
    }
}
