import UIKit


extension UIColor {
    
    private static let defaultBackground: UIColor = UIColor.white
    public static let background: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor.systemBackground
        } else {
            return defaultBackground
        }
        #else
        return defaultBackground
        #endif
    }()
    
    private static let defaultFormAccessoryBarTintColor: UIColor = UIColor.background
    public static let formAccessoryBarTintColor: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor.secondarySystemBackground
        } else {
            return defaultBackground
        }
        #else
        return defaultBackground
        #endif
    }()
    
    private static let defaultSelectedCellBackgroundColor: UIColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9803921569, alpha: 1)
    public static let selectedCellBackgroundColor: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1803921569, alpha: 1)
                } else {
                    return defaultSelectedCellBackgroundColor
                }
            })
        } else {
            return defaultSelectedCellBackgroundColor
        }
        #else
        return defaultLine
        #endif
    }()
    
    private static let defaultBadgeBackground: UIColor = #colorLiteral(red: 0.9411764706, green: 0.9490196078, blue: 0.9607843137, alpha: 1)
    public static let badgeBackground: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    if traitCollection.userInterfaceLevel == .elevated {
                        return UIColor.systemGray5
                    } else {
                        return #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
                    }
                } else {
                    return defaultBackground
                }
            })
        } else {
            return defaultBadgeBackground
        }
        #else
        return defaultBackground
        #endif
    }()
    
    private static let defaultBody: UIColor = #colorLiteral(red: 0.2352941176, green: 0.2549019608, blue: 0.3019607843, alpha: 1)
    public static let body: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8392156863, alpha: 1)
                } else {
                    return defaultBody
                }
            })
        } else {
            return defaultBody
        }
        #else
        return defaultBody
        #endif
    }()
    
    private static let defaultDescription: UIColor = #colorLiteral(red: 0.5215686275, green: 0.5450980392, blue: 0.6039215686, alpha: 1)
    public static let description: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
                } else {
                    return defaultDescription
                }
            })
        } else {
            return defaultDescription
        }
        #else
        return defaultDescription
        #endif
    }()
    
    private static let defaultEmptyPage: UIColor = #colorLiteral(red: 0.6705882353, green: 0.6980392157, blue: 0.7607843137, alpha: 1)
    public static let emptyPage: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.3882352941, green: 0.3882352941, blue: 0.4, alpha: 1)
                } else {
                    return defaultEmptyPage
                }
            })
        } else {
            return defaultEmptyPage
        }
        #else
        return defaultEmptyPage
        #endif
    }()
    
    private static let defaultError: UIColor = #colorLiteral(red: 0.937254902, green: 0.2078431373, blue: 0.1490196078, alpha: 1)
    public static let error: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.9882352941, green: 0.4431372549, blue: 0.4, alpha: 1)
                } else {
                    return defaultError
                }
            })
        } else {
            return defaultError
        }
        #else
        return defaultError
        #endif
    }()
    
    private static let defaultErrorHighlighed: UIColor = #colorLiteral(red: 0.8352941176, green: 0.07843137255, blue: 0.01568627451, alpha: 1)
    public static let errorHighlighed: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.937254902, green: 0.2078431373, blue: 0.1490196078, alpha: 1)
                } else {
                    return defaultErrorHighlighed
                }
            })
        } else {
            return defaultErrorHighlighed
        }
        #else
        return defaultErrorHighlighed
        #endif
    }()
    
    private static let defaultHeadings: UIColor = #colorLiteral(red: 0.01568627451, green: 0.02745098039, blue: 0.05098039216, alpha: 1)
    public static let headings: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    return defaultHeadings
                }
            })
        } else {
            return defaultHeadings
        }
        #else
        return defaultHeadings
        #endif
    }()
    
    private static let defaultLine: UIColor = #colorLiteral(red: 0.8941176471, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
    public static let line: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.2274509804, green: 0.2274509804, blue: 0.2352941176, alpha: 1)
                } else {
                    return defaultLine
                }
            })
        } else {
            return defaultLine
        }
        #else
        return defaultLine
        #endif
    }()
    
    private static let defaultOmise: UIColor = #colorLiteral(red: 0.1019607843, green: 0.337254902, blue: 0.9411764706, alpha: 1)
    public static let omise: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.1294117647, green: 0.462745098, blue: 1, alpha: 1)
                } else {
                    return defaultOmise
                }
            })
        } else {
            return defaultOmise
        }
        #else
        return defaultOmise
        #endif
    }()
    
    private static let defaultOmiseHighlighted: UIColor = #colorLiteral(red: 0.05882352941, green: 0.2274509804, blue: 0.6666666667, alpha: 1)
    public static let omiseHighlighted: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.1019607843, green: 0.337254902, blue: 0.9411764706, alpha: 1)
                } else {
                    return defaultOmiseHighlighted
                }
            })
        } else {
            return defaultOmiseHighlighted
        }
        #else
        return defaultOmiseHighlighted
        #endif
    }()
    
    private static let defaultPending: UIColor = #colorLiteral(red: 1, green: 0.7019607843, blue: 0, alpha: 1)
    public static let pending: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 1, green: 0.7921568627, blue: 0.2980392157, alpha: 1)
                } else {
                    return defaultPending
                }
            })
        } else {
            return defaultPending
        }
        #else
        return defaultPending
        #endif
    }()
    
    private static let defaultPlaceholder: UIColor = #colorLiteral(red: 0.8156862745, green: 0.8392156863, blue: 0.8862745098, alpha: 1)
    public static let placeholder: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.2823529412, green: 0.2823529412, blue: 0.2901960784, alpha: 1)
                } else {
                    return defaultPlaceholder
                }
            })
        } else {
            return defaultPlaceholder
        }
        #else
        return defaultPlaceholder
        #endif
    }()
    
    private static let defaultRefund: UIColor = #colorLiteral(red: 0.4901960784, green: 0.3333333333, blue: 0.9647058824, alpha: 1)
    public static let refund: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.6509803922, green: 0.5411764706, blue: 0.9921568627, alpha: 1)
                } else {
                    return defaultRefund
                }
            })
        } else {
            return defaultRefund
        }
        #else
        return defaultRefund
        #endif
    }()
    
    private static let defaultSuccess: UIColor = #colorLiteral(red: 0.05490196078, green: 0.7490196078, blue: 0.6039215686, alpha: 1)
    public static let success: UIColor = {
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.3960784314, green: 0.8235294118, blue: 0.7333333333, alpha: 1)
                } else {
                    return defaultSuccess
                }
            })
        } else {
            return defaultSuccess
        }
        #else
        return defaultSuccess
        #endif
    }()
}

