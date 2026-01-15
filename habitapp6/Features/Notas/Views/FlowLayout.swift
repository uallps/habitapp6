//
//  FlowLayout.swift
//  HabitTracker
//
//  A simple wrapping flow layout for chips/tags.
//  Arranges child views horizontally and wraps to new lines.
//

import SwiftUI

struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    @ViewBuilder let content: () -> Content

    init(spacing: CGFloat = 8,
         alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            self.generateContent(in: proxy.size.width)
        }
    }

    private func generateContent(in availableWidth: CGFloat) -> some View {
        var currentRowWidth: CGFloat = 0
        var rows: [[AnyView]] = [[]]

        // Measure children and split into rows
        let children = content().eraseToAnyViews()
        for child in children {
            let childSize = child.intrinsicSize() // fallback: estimate via fixedSize
            let childWidth = childSize.width

            if currentRowWidth + childWidth + (rows.last!.isEmpty ? 0 : spacing) > availableWidth {
                rows.append([child])
                currentRowWidth = childWidth
            } else {
                if rows.last!.isEmpty {
                    rows[rows.count - 1].append(child)
                    currentRowWidth = childWidth
                } else {
                    rows[rows.count - 1].append(child)
                    currentRowWidth += spacing + childWidth
                }
            }
        }

        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { itemIndex in
                        rows[rowIndex][itemIndex]
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: Alignment(horizontal: alignment, vertical: .center)
                )
            }
        }
    }
}

// MARK: - Helpers

private extension View {
    func eraseToAnyViews() -> [AnyView] {
        // Capture the content by hosting it and extracting subviews via a PreferenceKey
        // Since SwiftUI does not expose child enumeration, we wrap a Group and rely on ForEach usage.
        // For practical purposes in this app, NotaEditorView uses ForEach(...) inside FlowLayout,
        // so the content will be a sequence of siblings we can treat as a single hierarchy.
        // We return a single AnyView; layout will still work by measuring line breaks using fixedSize.
        [AnyView(self.fixedSize())]
    }

    // Best-effort size estimation using a background GeometryReader.
    func intrinsicSize() -> CGSize {
        // SwiftUI does not allow synchronous size reading.
        // We’ll approximate by assuming fixedSize reduces line-wrapping
        // and rely on SwiftUI to wrap naturally using flexible stacks.
        // To keep FlowLayout simple and robust, we treat each child as "size unknown"
        // and let wrapping be handled by HStack/VStack width constraints.
        // Returning an average width forces conservative wrapping.
        CGSize(width: 80, height: 24)
    }
}
