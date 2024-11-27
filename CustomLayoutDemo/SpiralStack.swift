//
//  RecursiveRadioStack.swift
//  CustomLayoutDemo
//
//  Created by Itsuki on 2024/11/24.
//


import SwiftUI

struct SpiralStack: Layout {
   
    var elementPerLayer: Int = 24
    var spiralPadding: CGFloat = 4.0
    
    struct CacheData {
        var radius: CGFloat?
        var maxSize: CGSize
        var angle: CGFloat
        var radiusChange: CGFloat
    }
    
    func makeCache(subviews: Subviews) -> CacheData {
        print("makeCache")
        let sizes = sizes(subviews)
        let maxSize = maxSize(sizes)
        let radiusChange = (max(maxSize.width, maxSize.height) + spiralPadding) / Double(elementPerLayer)

        return CacheData(radius: nil, maxSize: maxSize, angle: Angle.degrees(360.0 / Double(elementPerLayer)).radians, radiusChange: radiusChange)
    }
    
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
        print("place subview")

        if cache.radius == nil {
            print("calculating radius")
            let radius = min(bounds.size.width, bounds.size.height)/2  - max(cache.maxSize.width, cache.maxSize.height)/2
            cache.radius = radius
        }
        
        guard let radius = cache.radius else { return }
        let maxSize = cache.maxSize
        let count = elementPerLayer
        let angle = cache.angle
        let radiusChange = cache.radiusChange

        
        for (index, subview) in subviews[0..<min(subviews.count, count)].enumerated() {
            var point = CGPoint(x: 0, y: -radius+radiusChange*Double(index))
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index) ))
            point.x += bounds.midX
            point.y += bounds.midY
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
        
        // Save cache values to restore them after all sub-layouts finished
        let saveCache = cache
        cache.radius = radius - (max(maxSize.width, maxSize.height) + spiralPadding)
        
        // Place sub-layout views
        if subviews.count > count {
            placeSubviews(in: bounds, proposal: proposal, subviews: subviews[count..<subviews.count], cache: &cache)
        }
        
        // restore cache
        cache = saveCache
    }

    
    private func maxSize(_ sizes: [CGSize]) -> CGSize {
        let maxSize: CGSize = sizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(width: max(currentMax.width, subviewSize.width),
                   height: max(currentMax.height, subviewSize.height))
        }
        return maxSize
    }

    
    private func sizes(_ subviews: Subviews) -> [CGSize] {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return subviewSizes
    }
}


struct SpiralStackDemo: View {
    private let images = Array.init(repeating: "star.fill", count: 64)
    @State private var padding: CGFloat = 32
    var body: some View {
        VStack {
            SpiralStack {
                ForEach(images, id: \.self) { image in
                    makeImage(image)
                }
            }
            .padding(.all, padding)

            VStack {
                Text("Padding: \(String(format: "%.1f", padding))")
                Slider(value: $padding, in: 16...96, step: 8.0, onEditingChanged: {editing in
                    if editing {
                        print("padding changed")
                    }
                })
            }
            .padding(.all, 32)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.2))
    }
    
    private func makeImage(_ name: String) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(.white.opacity(0.8))
            .padding(.all, 8)
            .background(Circle().fill(.mint.opacity(0.8)))
    }
}

#Preview {
    SpiralStackDemo()
}
