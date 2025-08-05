import SwiftUI

public struct MarqueeText: View {
    public var text: String
    public var font: Font = .headline
    /// Points per second
    public var speed: Double = 35
    /// Pause before each scroll loop (seconds)
    public var delay: Double = 1.0
    /// Space between the duplicated texts for seamless looping
    public var gap: CGFloat = 32
    /// Width of the leading/trailing fade masks
    public var fadeWidth: CGFloat = 16

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var animTask: Task<Void, Never>?

    public init(
        _ text: String,
        font: Font = .headline,
        speed: Double = 35,
        delay: Double = 1.0,
        gap: CGFloat = 32,
        fadeWidth: CGFloat = 16
    ) {
        self.text = text
        self.font = font
        self.speed = speed
        self.delay = delay
        self.gap = gap
        self.fadeWidth = fadeWidth
    }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                // Two copies side-by-side for a seamless loop (only when needed)
                HStack(spacing: gap) {
                    marqueeText
                    if needsScroll {
                        marqueeText
                    }
                }
                .offset(x: needsScroll ? xOffset : 0)
                .frame(width: w, alignment: .leading)
                .clipped()
                .mask(fadeMask(width: w))
            }
            .onChange(of: w) { _, _ in containerWidth = w; restartIfNeeded() }
            .onChange(of: textWidth) { _, _ in restartIfNeeded() }
            .onChange(of: text) { _, _ in restartIfNeeded() }
            .onChange(of: reduceMotion) { _, _ in restartIfNeeded() }
            .onAppear { containerWidth = w; restartIfNeeded() }
            .onDisappear { animTask?.cancel() }
        }
        .frame(height: lineHeight(for: font))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(text))  // lets VoiceOver read the full string
    }

    private var marqueeText: some View {
        Text(text)
            .font(font)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: WidthKey.self, value: proxy.size.width)
                }
            )
            .onPreferenceChange(WidthKey.self) { textWidth = $0 }
            .truncationMode(.tail)
    }

    private var needsScroll: Bool { textWidth > 0 && containerWidth > 0 && textWidth > containerWidth }

    private func restartIfNeeded() {
        animTask?.cancel()
        xOffset = 0
        guard needsScroll, !reduceMotion else { return }
        let distance = textWidth + gap
        let duration = distance / speed

        animTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(delay))
                withAnimation(.linear(duration: duration)) {
                    xOffset = -distance
                }
                try? await Task.sleep(for: .seconds(duration))
                xOffset = 0
            }
        }
    }

    // Simple luminance mask for subtle edge fading
    private func fadeMask(width: CGFloat) -> some View {
        let fw = min(fadeWidth, width / 2)
        return LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black,  location: fw / width),
                .init(color: .black,  location: 1 - fw / width),
                .init(color: .clear, location: 1.0),
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: width)
    }

    private func lineHeight(for font: Font) -> CGFloat {
        // Reasonable defaults; tweak for your fonts if needed
        switch font {
        case .largeTitle: return 44
        case .title:      return 38
        case .title2:     return 34
        case .title3:     return 30
        case .headline:   return 24
        case .subheadline:return 22
        case .callout:    return 22
        case .footnote:   return 18
        case .caption, .caption2: return 16
        default:          return 24
        }
    }
}

private struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
