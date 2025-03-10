import Foundation
import ZTronObservation

public final class DrawingFragmentModel: ObservableObject, Component {
    public var id: String = "Drawing Fragment Model"
    @InteractionsManaging(setupOr: .replace, detachOr: .fail) private var delegate: (any MSAInteractionsManager)? = nil
    
    @Published internal var strokes: [[CGPoint]] = .init()
    @Published internal var canvaSize: CGSize = .zero
    @Published internal var isActive: Bool = false

    public init(mediator: MSAMediator) {
        self.delegate = DrawingFragmentDelegate(mediator: mediator, owner: self)
    }
    
    public func getDelegate() -> (any ZTronObservation.InteractionsManager)? {
        return self.delegate
    }
    
    public func setDelegate(_ interactionsManager: (any ZTronObservation.InteractionsManager)?) {
        guard let manager = interactionsManager as? any MSAInteractionsManager else {
            if interactionsManager != nil {
                fatalError("Expected interactions manager of type \(String(describing: MSAInteractionsManager.self))")
            } else {
                self.delegate = nil
                return
            }
        }
        
        self.delegate = manager
    }
    
    public static func == (lhs: DrawingFragmentModel, rhs: DrawingFragmentModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public final func clear() -> Void {
        for i in 0..<self.strokes.count {
            self.strokes[i].removeAll()
        }
        
        self.strokes.removeAll()
    }
    
    
    public final func undoLastStroke() -> Void {
        if self.strokes.count > 0 {
            self.strokes[self.strokes.count - 1].removeAll()
            self.strokes = self.strokes.dropLast()
        }
    }
}
