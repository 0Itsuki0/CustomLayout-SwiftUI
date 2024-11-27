//
//  SimpleRadialStack.swift
//  CustomLayoutDemo
//
//  Created by Itsuki on 2024/11/25.
//

import SwiftUI

struct SimpleRadialStack: Layout {
   
    struct CacheData {
        var radius: CGFloat?
        var angle: CGFloat
        var count: Int
    }
    
    func makeCache(subviews: Subviews) -> CacheData {
        print("makeCache")
        let count = subviews.count
        let angle = Angle.degrees(360.0 / Double(count)).radians
        return CacheData(radius: nil, angle: angle, count: count)
    }
    
    func updateCache(_ cache: inout CacheData, subviews: Subviews) {
        print("update Cache")
        cache.radius = nil
        if cache.count != subviews.count {
            print("update angle")
            let count = subviews.count
            cache.count = count
            cache.angle = Angle.degrees(360.0 / Double(count)).radians
        }
    }
    
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
        print("place subview")
        if cache.radius == nil {
            print("calculating radius")
            let sizes = sizes(subviews)
            let maxSize = maxSize(sizes)
            
            let radius = min(bounds.size.width, bounds.size.height)/2  - max(maxSize.width, maxSize.height)/2
            cache.radius = radius
        }
        
        guard let radius = cache.radius else { return }
        let angle = cache.angle
        
        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index) ))
            point.x += bounds.midX
            point.y += bounds.midY
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
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

struct RadialStackDemo: View {
    private let images = ["sun.max.fill", "moon.fill", "star.fill", "cloud.fill", "bolt.fill", "wind.snow", "snowflake", "rainbow", "dog.fill"]
//    private let images = Array.init(repeating: "star.fill", count: 64)
    @State private var padding: CGFloat = 32
    var body: some View {
        VStack {
            SimpleRadialStack {
                ForEach(images, id: \.self) { image in
                    makeImage(image)
                }
            }
            .padding(.all, padding)

            VStack {
                Text("Padding: \(String(format: "%.1f", padding))")
                Slider(value: $padding, in: 16...128, step: 8.0, onEditingChanged: {editing in
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
    RadialStackDemo()
}
