//
//  CalloutBubbleView.swift
//  City in Colors
//
//  Created by Frederick Dupray on 28/03/16.
//  Copyright © 2016 Carman. All rights reserved.
//

import UIKit

class CalloutBubbleView: UIView {

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        //let isInsideView = pointInside(viewPoint, withEvent: event)
        
        let view = super.hitTest(viewPoint, withEvent: event)
        
        return view
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        return CGRectContainsPoint(bounds, point)
    }
}
