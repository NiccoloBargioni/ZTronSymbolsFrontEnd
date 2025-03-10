import Foundation

extension CGPoint: Sim {
    static func +(lhs: CGPoint, rhs: CGPoint) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> Point {
        return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func *(lhs: Double, rhs: CGPoint) -> Point {
        return Point(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    static func <(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return (lhs.x, lhs.y) < (rhs.x, rhs.y)
    }
    
    func dot(_ other: CGPoint) -> Double {
        return x * other.x + y * other.y
    }
    
    func norm() -> Double {
        return sqrt(self.dot(self))
    }
    
    func euclideanDistance(to other: CGPoint) -> Double {
        return (self - other).norm()
    }

    
    public static func ~~(_ lhs: CGPoint, _ rhs: CGPoint) -> Bool {
        return lhs.euclideanDistance(to: rhs) < Double.EPS
    }
}
