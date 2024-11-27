//
//  PyramidStack.swift
//  CustomLayoutDemo
//
//  Created by Itsuki on 2024/11/25.
//


import SwiftUI

struct PyramidStackDemo: View {
    var body: some View {
        VStack(spacing: 24) {
        
            VStack {
                PyramidStack(spacing: 8, alignment: .center) {
                    makeText("Hello!")
                    makeText("Hello World!")
                    makeText("Hello, Itsuki World!")
                }
                .padding()
                .background(.mint)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.3))
    }
    
    private func makeText(_ text: String, priority: CGFloat = 0) -> some View  {
        MySubview {
            Text(text)
                .font(.title)
                .background(.white.opacity(0.8))
                .layoutPriority(priority)
        }
    }
}

struct MySubview<V: View>: View {
    @ViewBuilder let content: () -> V
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        content()
            .scaleEffect(x: scale, y: scale, anchor: .top)
            .pyramidScale($scale)
    }
}

private struct PyramidScaleKey: LayoutValueKey {
    static let defaultValue: Binding<CGFloat>? = nil
}

extension View {
    func pyramidScale(_ value: Binding<CGFloat>?) -> some View {
        layoutValue(key: PyramidScaleKey.self, value: value)
    }
}

struct PyramidStack: Layout {
    var spacing: CGFloat? = nil
    var alignment: HorizontalAlignment = .leading
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let subviewSizes = sizes(subviews)
        let maxSize = maxSize(subviewSizes)
        let scaleArray = scale(subviews.count)
        let spacingArray = spacing(subviews: subviews)
        let totalHeight = totalHeight(spacingArray, subviewSizes, scaleArray)
        return CGSize(width: maxSize.width, height: totalHeight)
    }
    
    
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let spacingArray = spacing(subviews: subviews)
        let placementProposal = ProposedViewSize.unspecified
        let sortedView = subviews.sorted(by: { $0.priority > $1.priority })
        var nextY = bounds.minY
        let count = subviews.count
        let scale = 1.0/CGFloat(count)
        
        for index in sortedView.indices {
            let subview = sortedView[index]
            print(scale * CGFloat(index + 1))
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
            
            DispatchQueue.main.async {
                subview[PyramidScaleKey.self]?.wrappedValue = scale * CGFloat(index + 1)
            }
            
            nextY += (size.height + spacingArray[index]) * scale * CGFloat(index + 1)
        }
    }
    
    private func scale(_ count: Int) -> [CGFloat] {
        let scale = 1.0/CGFloat(count)
        var scaleArray: [CGFloat] = []
        for i in (0..<count) {
            scaleArray.append(scale * CGFloat(i + 1))
        }
        return scaleArray
    }
    
    private func totalHeight(_ spacing: [CGFloat], _ size: [CGSize], _ scale: [CGFloat]) -> CGFloat {
        var totalHeight: CGFloat = 0
        for i in (0..<spacing.count) {
            totalHeight = totalHeight + spacing[i] * scale[i] + size[i].height * scale[i]
        }
        return totalHeight
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
    PyramidStackDemo()
}
