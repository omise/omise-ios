import UIKit


public protocol CheckoutViewControllerDelegate: AnyObject {
  func checkoutViewControllerDidTapCheckout(_ checkoutViewController: CheckoutViewController)
}

public class CheckoutViewController: UIViewController {
  
  public weak var delegate: CheckoutViewControllerDelegate?
  
  public override func loadView() {
    let button = UIButton(frame: CGRect(x: 10, y: 10,width:  300, height: 44))
    button.autoresizingMask = .flexibleWidth
    button.addTarget(self, action: #selector(didTapCheckout), for: .touchUpInside)
    button.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.3960784314, blue: 0.8784313725, alpha: 1)
    button.setTitleColor(.white, for: .normal)
    button.setTitle("Checkout", for: .normal)
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    view.backgroundColor = .white
    view.addSubview(button)
    self.view = view
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    title = "Checkout"
    edgesForExtendedLayout = []
  }
  
  @objc func didTapCheckout() {
    delegate?.checkoutViewControllerDidTapCheckout(self)
  }
    
}


