//
//  Grid.swift
//  Set
//
//  Created by J. Grishin on 8/10/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import UIKit

struct Grid {
    
    var cellCount = 0 { didSet { calculateGrid() } }
    var dimensions: (rowCount: Int, columnCount: Int) = (0, 0)
    
    // Array with frames for cells
    private var cellFrames = [CGRect]()
    private var aspectRatio: CGFloat
    private var frame: CGRect { didSet { calculateGrid() } }
   
    // - MARK: - Initialisation
    init(aspectRatio: CGFloat, frame: CGRect = CGRect.zero) {
        self.aspectRatio = aspectRatio
        self.frame = frame
        calculateGrid()
    }
    
    subscript(_ index: Int) -> CGRect? {
        return index < cellFrames.count ? cellFrames[index] : nil
    }

    private mutating func calculateGrid() {
        // Finding largest cell with given aspect ratio
        let cellSize = largestCellForAspectRatio()
        // Calculates number of rows and columns
        if cellSize.area > 0 {
        dimensions.columnCount = Int(frame.size.width / cellSize.width)
        dimensions.rowCount    = Int(cellCount + dimensions.columnCount - 1) / dimensions.columnCount
        } else {
            dimensions = (0, 0)
        }
        updateCellFrames(to: cellSize)
    }
    
    private mutating func updateCellFrames(to cellSize: CGSize) {
        cellFrames.removeAll()
        
        let boundingSize = CGSize(
            width:  CGFloat(dimensions.columnCount) * cellSize.width,
            height: CGFloat(dimensions.rowCount) * cellSize.height
        )
        let offset = (
            dx: (frame.size.width - boundingSize.width) / 2,
            dy: (frame.size.height - boundingSize.height) / 2
        )
        var origin = frame.origin
        origin.x += offset.dx
        origin.y += offset.dy
        
        if cellCount > 0 {
            for _ in 0..<cellCount {
                cellFrames.append(CGRect(origin: origin, size: cellSize))
                origin.x += cellSize.width
                if round(origin.x) > round(frame.maxX - cellSize.width) {
                    origin.x = frame.origin.x + offset.dx
                    origin.y += cellSize.height
                }
            }
        }
    }
    
    private func largestCellForAspectRatio() -> CGSize {
        var largestCell = CGSize.zero
        if cellCount > 0 && aspectRatio > 0 {
            for rowCount in 1...cellCount {
                let estimatedCell = estimatedCellSize(rowCount: rowCount, currentLargestAllowedSize: largestCell)
                // We do not need to go through from 1 to 'cellCount' to find out the largest cell available.
                // If 'estimatedCell' give us the same size 'largestCell' alrady has, we can break the loop.
                if estimatedCell != CGSize.zero {
                    if estimatedCell == largestCell { break }
                    largestCell = estimatedCell
                }
                
            }
            for columnCount in 1...cellCount {
                let estimatedCell = estimatedCellSize(columnCount: columnCount, currentLargestAllowedSize: largestCell)
                if estimatedCell != CGSize.zero {
                    if estimatedCell == largestCell { break }
                    largestCell = estimatedCell
                }
            }
        }
        return largestCell
    }
    /// - Returns: Cell size for given number of column or row.
    ///            Returns CGSize.zero, if estimated cells don't fit in the 'frame'.
    private func estimatedCellSize(rowCount: Int? = nil, columnCount: Int? = nil, currentLargestAllowedSize: CGSize = CGSize.zero) -> CGSize {
        var size = CGSize.zero
        if let columnCount = columnCount {
            size.width  = frame.size.width / CGFloat(columnCount)
            size.height = size.width / aspectRatio
        } else if let rowCount = rowCount {
            size.height = frame.size.height / CGFloat(rowCount)
            size.width  = size.height * aspectRatio
        }
        if size.area > currentLargestAllowedSize.area && (Int(frame.size.height / size.height) * Int(frame.size.width / size.width)) >= cellCount {
            return size
        } else {
            return CGSize.zero
        }
    }
}

extension CGSize {
    var area: CGFloat {
        return self.height * self.width
    }
}
