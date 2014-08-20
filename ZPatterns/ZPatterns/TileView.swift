//
//  TiledView.swift
//  ZPatterns
//
//  Created by Matt Appleby on 8/13/14.
//  Copyright (c) 2014 Zazzle. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


class TileView : UIView {
    let TILESIZE: CGFloat
    let pattern: UIPattern
    
    init(frame: CGRect, tilesize: CGFloat) {
        TILESIZE = tilesize
        pattern = UIPattern()
        pattern.generateTranslatedPaths(tilesize, factor: 8)
        
        super.init(frame: frame)
        self.layer.contentsScale = 2
        let tsz = TILESIZE * self.layer.contentsScale
        (layer as CATiledLayer).tileSize = CGSizeMake(tsz, tsz)
        (layer as CATiledLayer).levelsOfDetailBias = 4
        (layer as CATiledLayer).levelsOfDetail = 8
    }

    // appeasing the compiler, don't use this initializer
    convenience override init() {
        self.init(frame: (CGRect(x: 0, y: 0, width: 80, height: 80)), tilesize: 40)
    }
    
    // appeasing the compiler, don't use this initializer
    required init(coder: NSCoder!) {
        TILESIZE = 40
        pattern = UIPattern()
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clearColor()
    }
    
    override class func layerClass() -> AnyClass {
        return CATiledLayer.self
    }
    
    override func drawRect(r: CGRect) {
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()
        let scale: CGFloat = CGContextGetCTM(ctx).a
        let tiledLayer: CATiledLayer = self.layer as CATiledLayer
        let tileSize: CGSize = tiledLayer.tileSize
        
        let x = r.origin.x
        let y = r.origin.y
        
        // debug println
        var debug = false
        if (x==0 && y==0) {
            debug = true
        }
        
//        tileSize.width /= scale
//        tileSize.height /= scale
//        let col = floorf(CGRectGetMinX(r) / tileSize.width)
//        let row = floorf(CGRectGetMinY(r) / tileSize.height)
        
        let size = r.width
        let info = "\(x)\t\t\(y)\t\t Scale: \(scale) \t\t Size: \(size)"
        if(debug) { println(info) }

        // if we are zooming out
        if (scale <= 1) {
            var factor = (Int(size/TILESIZE))
            if (debug) { println("Factor: \(factor)") }
            
            CGContextTranslateCTM(ctx, x, y)
            pattern.renderPatternGridToContext(ctx, factor: factor)
            
        }
            
        // if we are zooming in
        else {
            CGContextTranslateCTM(ctx, translateOrigin(x), translateOrigin(y))
            pattern.renderPatternToContext(ctx)
        }
        
        UIColor.greenColor().set()
        CGContextSetLineWidth(ctx, 6.0/scale)
        CGContextStrokeRect(ctx, r)
    }
    
    func translateOrigin(i: CGFloat) -> CGFloat {
        return i - i%TILESIZE
    }
}