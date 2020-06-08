//
//  GradientView.swift
//  StoreSearch
//
//  Created by Lazar Stojkovic on 6/5/20.
//  Copyright © 2020 lazar. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        // 1
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
        let locations: [CGFloat] = [ 0, 1 ]
        // 2
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        // 3
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y : y)
        let radius = max(x, y)
        // 4
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
}
