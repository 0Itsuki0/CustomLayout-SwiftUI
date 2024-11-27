//
//  ComposedStack.swift
//  CustomLayoutDemo
//
//  Created by Itsuki on 2024/11/27.
//

import SwiftUI

struct ComposedStackDemo: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    
    private let images = Array.init(repeating: "star.fill", count: 24)


    var body: some View {
        ComposedLayout(verticalSizeClass, horizontalSizeClass) {
            ForEach(images, id: \.self) { image in
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.all, 8)
                    .background(Circle().fill(.mint.opacity(0.8)))

            }

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.3))
    }
}

extension ComposedLayout {
    init (_ verticalSizeClass: UserInterfaceSizeClass?, _ horizontalSizeClass: UserInterfaceSizeClass?) {
        self.verticalSizeClass = verticalSizeClass
        self.horizontalSizeClass = horizontalSizeClass
    }
}

struct ComposedLayout: Layout {
    var verticalSizeClass: UserInterfaceSizeClass?
    var horizontalSizeClass: UserInterfaceSizeClass?
    
    enum LayoutType {
        case hStack
        case radialStack
    }
    var layoutType: LayoutType {
        (verticalSizeClass == .compact) ?  .hStack : .radialStack
    }

    private let hStackLayout = AnyLayout(HStackLayout(spacing: 16))
    private let radialStackLayout = AnyLayout(RadialStack())
    
    struct LayoutCache {
        var hStackCache: AnyLayout.Cache
        var radialStackCache: AnyLayout.Cache
    }
    
    func makeCache(subviews: Subviews) -> LayoutCache {
        Cache(hStackCache: hStackLayout.makeCache(subviews: subviews), radialStackCache: radialStackLayout.makeCache(subviews: subviews))
    }


    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) -> CGSize {
        switch layoutType {
        case .hStack:
            hStackLayout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache.hStackCache)
        case .radialStack:
            radialStackLayout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache.radialStackCache)
        }
    }
    
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {
        switch layoutType {
        case .hStack:
            hStackLayout.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache.hStackCache)
        case .radialStack:
            radialStackLayout.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache.radialStackCache)
        }
    }
}


private struct RadialStack: Layout {

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = sizes(subviews)
        let maxSize = maxSize(sizes)
        
        let radius = min(bounds.size.width, bounds.size.height)/2  - max(maxSize.width, maxSize.height)/2
        
        let angle = Angle.degrees(360.0 / Double(subviews.count)).radians

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

struct ScreenSizeClassDemo: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    
    private let image: some View = Image(systemName: "sun.max.fill")
        .resizable()
        .scaledToFit()
        .foregroundStyle(.white)
        .padding()
        .frame(width: 240, height: 160)
        .background(RoundedRectangle(cornerRadius: 8).fill(.mint))

    var body: some View {
        Group {
            if verticalSizeClass == .compact {
                HStack(spacing: 16) {
                    image
                    image
                    image
                }
            } else {
                VStack(spacing: 16) {
                    image
                    image
                    image
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.3))
    }
}

struct ViewThatFitsDemo: View {
    private let image: some View = Image(systemName: "sun.max.fill")
        .resizable()
        .scaledToFit()
        .foregroundStyle(.white)
        .padding()
        .frame(width: 240, height: 160)
        .background(RoundedRectangle(cornerRadius: 8).fill(.mint))

    var body: some View {
        ViewThatFits {
            VStack(spacing: 16) {
                image
                image
                image
            }
            HStack(spacing: 16) {
                image
                image
                image
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.3))
    }
}


#Preview {
    ComposedStackDemo()
}
