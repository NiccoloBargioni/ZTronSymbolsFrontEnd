import Foundation
import ZTronObservation

public final class DrawingPageModel: ObservableObject, Component {
    public var id: String = "Drawing Page Model"
    @InteractionsManaging(setupOr: .replace, detachOr: .fail) private var delegate: (any MSAInteractionsManager)? = nil

    public init(mediator: MSAMediator) {
        self.delegate = DrawingPageDelegate(mediator: mediator, owner: self)
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
    
    public static func == (lhs: DrawingPageModel, rhs: DrawingPageModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
