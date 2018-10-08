import UIKit


@objc class Tool : NSObject {
    @objc static func imageWith(size: CGSize, color: UIColor) -> UIImage? {
        return Tool.imageWith(size: size, actions: { (context) in
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        })
    }
    
    @objc static func imageWith(size: CGSize, actions: (CGContext) -> Void) -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image(actions: { context in
                actions(context.cgContext)
            })
        } else {
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            let context = UIGraphicsGetCurrentContext()
            if let context = context {
                actions(context)
            }
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    
}
