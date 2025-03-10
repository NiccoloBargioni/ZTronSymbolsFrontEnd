import CoreGraphics

extension CGRect {
    public func bottomRight() -> CGPoint {
        return CGPoint.init(
            x: CGRectGetMaxX(self),
            y: CGRectGetMaxY(self)
        )
    }
}
