//
//  SimpleVStack.swift
//  CustomLayoutDemo
//
//  Created by Itsuki on 2024/11/24.
//


import SwiftUI

struct SimpleVStackDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack() {
                Text("Built-in VStack")
                    .font(.title3)
                    .fontWeight(.bold)
                VStack(alignment: .center, spacing: 8) {
                    content
                }
                .padding()
                .background(.mint)

            }

            VStack {
                Text("Custom VStack")
                    .font(.title3)
                    .fontWeight(.bold)
                
                SimpleVStack(spacing: 8, alignment: .center) {
                    content
                }
                .padding()
                .background(.mint)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.3))
    }
    
    @ViewBuilder private var content: some View {
            Text("Hello!")
            .background(.white.opacity(0.8))
            Text("Hello, World!")
            .background(.white.opacity(0.8))
            Text("Hello, Itsuki World!")
            .background(.white.opacity(0.8))
            Text("Hello\nNew Line!")
            .background(.white.opacity(0.8))
    }
}

struct SimpleVStack: Layout {
    var spacing: CGFloat? = nil
    var alignment: HorizontalAlignment = .leading
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let subviewSizes = sizes(subviews)
        let maxSize = maxSize(subviewSizes)
        
        let spacingArray = spacing(subviews: subviews)
        let totalSpacing = spacingArray.reduce(0) { $0 + $1 }
        let totalHeight = totalSpacing + subviewSizes.reduce(0) { $0 + $1.height }

        return CGSize(width: maxSize.width, height: totalHeight)
    }
    
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let spacingArray = spacing(subviews: subviews)
        let placementProposal = ProposedViewSize(width: bounds.width, height: bounds.height)
        
        var nextY = bounds.minY
        for index in subviews.indices {
            let subview = subviews[index]
            let size = subview.sizeThatFits(placementProposal)
            
            let (x, anchor): (CGFloat, UnitPoint)
            switch alignment {
            case .center:
                (x, anchor) = (bounds.midX, .top)
                break
            case .leading:
                (x, anchor) = (bounds.minX, .topLeading)
                break
            case .trailing:
                (x, anchor) = (bounds.maxX, .topTrailing)
                break
            default:
                (x, anchor) = (bounds.midX, UnitPoint.center)
                break
            }

            subview.place(
                at: CGPoint(x: x, y: nextY),
                anchor: anchor,
                proposal: placementProposal
            )
            nextY += size.height + spacingArray[index]
        }
    }
    
    private func maxSize(_ sizes: [CGSize]) -> CGSize {
        let maxSize: CGSize = sizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(width: max(currentMax.width, subviewSize.width),
                   height: max(currentMax.height, subviewSize.height))
        }
        return maxSize
    }

    private func spacing(subviews: Subviews) -> [CGFloat] {
        if let spacing = spacing {
            var spacingArray: [CGFloat] = Array(repeating: spacing, count: subviews.count-1)
            spacingArray.append(0)
            return spacingArray
        }
        
        return subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .vertical)
        }
    }

    
    private func sizes(_ subviews: Subviews) -> [CGSize] {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return subviewSizes
    }

}

#Preview {
    SimpleVStackDemo()
}
