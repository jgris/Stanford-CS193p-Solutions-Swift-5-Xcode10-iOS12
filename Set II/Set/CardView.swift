//
//  CardView.swift
//  Set Card
//
//  Created by J. Grishin on 8/8/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    var card: Card? {
        didSet {
            setup()
        }
    }
    
    /// Returns 'true' if card is selected
    var cardIsSelected: Bool         = false { didSet { setNeedsDisplay() } }
    var cardIsSelectedByIphone: Bool = false { didSet { setNeedsDisplay() } }
    var cheatHilighted: Bool         = false { didSet { setNeedsDisplay() } }
    /// Returns matching state of type 'Game.MatchState';
    /// Can be in one of three states:
    /// .matched, if card is matched;
    /// .notMatched, if not;
    /// .notSet, if no cards to test for matching
    var matchState: Game.MatchState = .matched { didSet { setNeedsDisplay() } }
    
    private func setup() {
        if let card = self.card {
            
            numberOfShapes = card.number
            
            switch card.shape {
            case 1: shape = .diamond
            case 2: shape = .oval
            case 3: shape = .squiggle
            default: break
            }
            
            switch card.fill {
            case 1: fill = .empty
            case 2: fill = .striped
            case 3: fill = .solid
            default: break
            }
            
            switch card.color {
            case 1: color = .green
            case 2: color = .red
            case 3: color = .purple
            default: break
            }
        }
        
    }
    
    private var numberOfShapes: Int = 1         { didSet { setNeedsDisplay(); setNeedsLayout() } }
    private var shape: Shape        = .diamond  { didSet { setNeedsDisplay() } }
    private var fill: Fill          = .empty    { didSet { setNeedsDisplay() } }
    private var color: Color        = .green    { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = bounds.insetBy(dx: Constant.spaceForStroke, dy: Constant.spaceForStroke)
        let roundedCard = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
//        roundedCard.addClip()
        switch cardIsSelected {
        case true:  Theme.cardColorSelected.setFill()
        case false: Theme.cardColor.setFill()
        }
        switch cheatHilighted {
        case true:  Theme.cardColorHilighted.setFill()
        case false: break
        }
        switch matchState {
        case .matched:
            roundedCard.lineWidth = 8.0
            Theme.cardStrokeColorMatched.setStroke()
            roundedCard.stroke()
        case .notMatched:
            roundedCard.lineWidth = 8.0
            Theme.cardStrokeColorNotMatched.setStroke()
            roundedCard.stroke()
       case .notSet:
            break
        }
        switch cardIsSelectedByIphone {
        case true:
            roundedCard.lineWidth = 8.0
            Theme.cardStrokeColorIphoneSelected.setStroke()
            roundedCard.stroke()
        case false:
            break
        }
        roundedCard.fill()
        dispayShapes()
    }

    private func dispayShapes() {
        color.UIColor.setStroke()
        color.UIColor.setFill()
        
        let shapeRectOrigin = CGPoint(x: faceRect.minX, y: faceRect.midY - shapeRectHeight/2)
        let shapeRectSize   = CGSize(width: faceRect.size.width, height: shapeRectHeight)
        let middleShapeRect = CGRect(origin: shapeRectOrigin, size: shapeRectSize)
    
        switch numberOfShapes {
        case 1:
            drawShape(in: middleShapeRect)
        case 2:
            let upperShapeRect  = middleShapeRect.offsetBy(dx: 0.0, dy: -shapeRectOffcet/2)
            let bottomShapeRect = middleShapeRect.offsetBy(dx: 0.0, dy: shapeRectOffcet/2)
            drawShape(in: upperShapeRect)
            drawShape(in: bottomShapeRect)
        case 3:
            let upperShapeRect  = middleShapeRect.offsetBy(dx: 0.0, dy: -shapeRectOffcet)
            let bottomShapeRect = middleShapeRect.offsetBy(dx: 0.0, dy: shapeRectOffcet)
            drawShape(in: upperShapeRect)
            drawShape(in: middleShapeRect)
            drawShape(in: bottomShapeRect)
        default: break
        }
    }
    
    //    MARK: - Drawing Shapes
    private func drawShape(in rect: CGRect) {
        let shape: UIBezierPath
        
        switch self.shape {
        case  .diamond: shape = drawDiamond(in: rect)
        case     .oval: shape = drawOval(in: rect)
        case .squiggle: shape = drawSquiggle(in: rect)
        }
        
        shape.lineWidth = 2.0
        shape.stroke()
        
        switch self.fill {
        case .solid:    shape.fill()
        case .striped:  fillWithStripes(shape: shape, in: rect)
        default: break
        }
        
    }

    private func drawDiamond(in rect: CGRect) -> UIBezierPath{
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: rect.minX, y: rect.midY))
        shape.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        shape.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        shape.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        shape.close()
        return shape
    }
    
    private func drawOval(in rect: CGRect) -> UIBezierPath {
        let shape = UIBezierPath(roundedRect: rect, cornerRadius: 45.0)
        return shape
    }
    
    private func drawSquiggle(in rect: CGRect) -> UIBezierPath {
        let shape = UIBezierPath()

        shape.move(to: CGPoint(x: rect.minX, y: rect.midY))
        shape.addQuadCurve(to: CGPoint(x: rect.midX,
                                       y: rect.minY + rect.height*0.2),
                 controlPoint: CGPoint(x: rect.minX - rect.width * 0.02,
                                       y: rect.minY - rect.height * 0.3))
        
        shape.addCurve(to: CGPoint(x: rect.maxX,
                                   y: rect.midY),
                       controlPoint1: CGPoint(x: rect.maxX - rect.width * 0.27,
                                              y: rect.midY + rect.height * 0.01),
                       controlPoint2: CGPoint(x: rect.maxX - rect.width * 0.02,
                                              y: rect.minY - rect.height * 0.6))
        let bottomPart = UIBezierPath(cgPath: shape.cgPath)
        bottomPart.apply(CGAffineTransform.identity
            .translatedBy(x: frame.width, y: frame.height)
            .rotated(by: CGFloat.pi)
        )
        shape.append(bottomPart)
        return shape
    }
    //    MARK: - Fill with Stripes
    private func fillWithStripes(shape: UIBezierPath, in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        shape.addClip()
        let stripe = UIBezierPath()
        stripe.move(to: CGPoint(x: faceRect.minX, y: faceRect.minY))
        stripe .addLine(to: CGPoint(x: faceRect.minX, y: faceRect.maxY))
        stripe.lineWidth = Constant.stripeWidth
        let count = Int(faceRect.width / Constant.stripesInterval)
        for _ in 1...count {
            stripe.apply(CGAffineTransform(translationX: Constant.stripesInterval, y: 0))
            stripe.stroke()
        }
        context?.restoreGState()
    }
    
    enum Shape {
        case squiggle
        case oval
        case diamond
    }
    
    enum Fill {
        case empty
        case striped
        case solid
    }
    
    enum Color {
        case green
        case red
        case purple
        
        var UIColor: UIColor {
            switch self {
            case  .green:    return #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
            case    .red:    return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            case .purple:    return #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)
            }
        }
    }
    
}

extension CardView
{
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat      = 0.06
        static let cornerOffsetToCornerRadius: CGFloat      = 0.33
        static let shapeRectHeightToFaceRectHeight: CGFloat = 0.25
        static let gapHeightToShapeRectHeight: CGFloat      = 0.25
    }
    
    private struct Constant {
        static let stripeWidth: CGFloat     = 1.0
        static let stripesInterval: CGFloat = 4.0
        
        static let spaceForStroke: CGFloat = 3.0
    }
    
    private var faceRect: CGRect {
        return bounds.zoom(by: 0.70)
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var shapeRectHeight: CGFloat {
        return faceRect.size.height * SizeRatio.shapeRectHeightToFaceRectHeight
    }
    
    private var interShapesGap: CGFloat {
        return shapeRectHeight * SizeRatio.gapHeightToShapeRectHeight
    }
    
    private var shapeRectOffcet: CGFloat {
        return shapeRectHeight + interShapesGap
    }
}

extension CGRect {
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}
