//
//  colors.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-08.
//

import Foundation
import UIKit

extension UIColor{
    static var categoryColor: [UIColor]{
        return [UIColor(named: "color1") ?? .systemBackground,
                UIColor(named: "color2") ?? .systemBackground,
                UIColor(named: "color3") ?? .systemBackground,
                UIColor(named: "color4") ?? .systemBackground,
                UIColor(named: "color5") ?? .systemBackground,
                UIColor(named: "color6") ?? .systemBackground,
                UIColor(named: "color7") ?? .systemBackground]
    }
    static var color1: UIColor{
        return UIColor(named: "color1") ?? .systemBackground
    }
    static var color2: UIColor{
        return UIColor(named: "color2") ?? .systemBackground
    }
    static var color3: UIColor{
        return UIColor(named: "color3") ?? .systemBackground
    }
    static var color4: UIColor{
        return UIColor(named: "color4") ?? .systemBackground
    }
    static var color5: UIColor{
        return UIColor(named: "color5") ?? .systemBackground
    }
    static var color6: UIColor{
        return UIColor(named: "color6") ?? .systemBackground
    }
    static var color7: UIColor{
        return UIColor(named: "color7") ?? .systemBackground
    }
    
    static var pieChart01: UIColor{
        return UIColor(named: "pieChart01") ?? .systemBackground
    }
    static var pieChart02: UIColor{
        return UIColor(named: "pieChart02") ?? .systemBackground
    }
    static var pieChart03: UIColor{
        return UIColor(named: "pieChart03") ?? .systemBackground
    }
    static var pieChart04: UIColor{
        return UIColor(named: "pieChart04") ?? .systemBackground
    }
    static var pieChart05: UIColor{
        return UIColor(named: "pieChart05") ?? .systemBackground
    }
    static var pieChart06: UIColor{
        return UIColor(named: "pieChart06") ?? .systemBackground
    }
    static var linearBackground: UIColor{
        return UIColor(named: "backgroundColor") ?? .systemBackground
    }
    static var linearHighlight: UIColor{
        return UIColor(named: "highlightColor") ?? .systemBackground
    }
}
