import Foundation
import UIKit
import Display
import AsyncDisplayKit
import TelegramPresentationData
import LegacyComponents
import ComponentFlow

private func generateGlassKnobImage(
    trackColor: UIColor,
    knobSize: CGFloat?,
    knobColor: UIColor?,
    isDark: Bool
) -> UIImage? {
    let knobH: CGFloat = {
        if let knobSize { return max(28.0, min(40.0, knobSize)) }
        return 36.0
    }()
    let knobW: CGFloat = knobH + 26.0

    let canvas = CGSize(width: knobW + 30.0, height: knobH + 30.0)
    let rect = CGRect(
        x: floor((canvas.width - knobW) * 0.5),
        y: floor((canvas.height - knobH) * 0.5),
        width: knobW,
        height: knobH
    )
    let r = knobH * 0.5

    // Base fill is more transparent in the target image to look like clear glass
    let baseFill = knobColor ?? (isDark
                                 ? UIColor.white.withAlphaComponent(0.05)
                                 : UIColor.white.withAlphaComponent(0.15))
    
    let border = isDark
    ? UIColor.white.withAlphaComponent(0.22)
    : UIColor.white.withAlphaComponent(0.40)

    let shadowAlpha: CGFloat = isDark ? 0.34 : 0.15

    return generateImage(canvas, rotatedContext: { _, context in
        context.clear(CGRect(origin: .zero, size: canvas))

        let path = UIBezierPath(roundedRect: rect, cornerRadius: r).cgPath

        context.saveGState()
        context.addPath(path)
        context.setShadow(offset: CGSize(width: 0.0, height: 8.0), blur: 16.0, color: UIColor(white: 0.0, alpha: shadowAlpha).cgColor)
        context.setFillColor(baseFill.cgColor)
        context.fillPath()
        context.restoreGState()

        context.addPath(path)
        context.setFillColor(baseFill.cgColor)
        context.fillPath()

        context.saveGState()
        context.addPath(path)
        context.clip()

        let topA: CGFloat = isDark ? 0.22 : 0.45
        let midA: CGFloat = isDark ? 0.08 : 0.15

        let fogColors: [CGColor] = [
            UIColor.white.withAlphaComponent(topA).cgColor,
            UIColor.white.withAlphaComponent(midA).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        let fogLoc: [CGFloat] = [0.0, 0.50, 1.0]
        if let fog = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: fogColors as CFArray, locations: fogLoc) {
            context.drawLinearGradient(
                fog,
                start: CGPoint(x: rect.midX, y: rect.minY),
                end: CGPoint(x: rect.midX, y: rect.maxY),
                options: []
            )
        }

        let depthColors: [CGColor] = [
            UIColor(white: 0.0, alpha: isDark ? 0.05 : 0.02).cgColor,
            UIColor(white: 0.0, alpha: 0.0).cgColor
        ]
        let depthLoc: [CGFloat] = [0.0, 1.0]
        if let depth = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: depthColors as CFArray, locations: depthLoc) {
            context.drawLinearGradient(
                depth,
                start: CGPoint(x: rect.midX, y: rect.maxY),
                end: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.55),
                options: []
            )
        }

        let leftStrong = trackColor.withAlphaComponent(isDark ? 0.85 : 0.90)
        let leftWeak = trackColor.withAlphaComponent(0.0)
        let leftColors: [CGColor] = [leftStrong.cgColor, leftWeak.cgColor]
        let leftLoc: [CGFloat] = [0.0, 1.0]
        if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: leftColors as CFArray, locations: leftLoc) {
            context.drawLinearGradient(
                g,
                start: CGPoint(x: rect.minX - 2.0, y: rect.midY),
                end: CGPoint(x: rect.minX + rect.width * 0.60, y: rect.midY),
                options: []
            )
        }

        // Right Rim Reflection
        let rightRimA: CGFloat = isDark ? 0.16 : 0.25
        let rightColors: [CGColor] = [
            UIColor.white.withAlphaComponent(rightRimA).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        let rightLoc: [CGFloat] = [0.0, 1.0]
        if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: rightColors as CFArray, locations: rightLoc) {
            context.drawLinearGradient(
                g,
                start: CGPoint(x: rect.maxX + 2.0, y: rect.midY),
                end: CGPoint(x: rect.maxX - rect.width * 0.30, y: rect.midY),
                options: []
            )
        }

        // Top Gloss Band (The "Wet" look)
        let topBand = CGRect(x: rect.minX + 2.0, y: rect.minY + 2.0, width: rect.width - 4.0, height: rect.height * 0.45)
        let topPath = UIBezierPath(roundedRect: topBand, cornerRadius: topBand.height * 0.5).cgPath
        context.saveGState()
        context.addPath(topPath)
        context.clip()
        
        // Increased opacity here to match the strong white reflection in Image 1
        let bandColors: [CGColor] = [
            UIColor.white.withAlphaComponent(isDark ? 0.35 : 0.60).cgColor,
            UIColor.white.withAlphaComponent(isDark ? 0.15 : 0.20).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        let bandLoc: [CGFloat] = [0.0, 0.6, 1.0]
        if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bandColors as CFArray, locations: bandLoc) {
            context.drawLinearGradient(
                g,
                start: CGPoint(x: topBand.midX, y: topBand.minY),
                end: CGPoint(x: topBand.midX, y: topBand.maxY),
                options: []
            )
        }
        context.restoreGState()

        // Inner rim stroke
        let inner = rect.insetBy(dx: 1.5, dy: 1.5)
        let innerPath = UIBezierPath(roundedRect: inner, cornerRadius: inner.height * 0.5).cgPath
        context.addPath(innerPath)
        context.setStrokeColor(UIColor(white: 0.0, alpha: isDark ? 0.07 : 0.05).cgColor)
        context.setLineWidth(1.0)
        context.strokePath()

        // Inner Highlight stroke
        let highlightInner = rect.insetBy(dx: 1.0, dy: 1.0)
        let highlightPath = UIBezierPath(roundedRect: highlightInner, cornerRadius: highlightInner.height * 0.5).cgPath
        context.addPath(highlightPath)
        context.setStrokeColor(UIColor.white.withAlphaComponent(isDark ? 0.12 : 0.30).cgColor)
        context.setLineWidth(1.0)
        context.strokePath()

        // The Dot
        let dotSize: CGFloat = 3.0 // Slightly smaller/sharper
        let dotRect = CGRect(
            x: rect.midX - dotSize * 0.5,
            y: rect.maxY - dotSize - rect.height * 0.18,
            width: dotSize,
            height: dotSize
        )
        context.setFillColor(UIColor(white: 0.0, alpha: isDark ? 0.25 : 0.20).cgColor)
        context.fillEllipse(in: dotRect)

        context.restoreGState()

        // Outer Border
        context.addPath(path)
        context.setStrokeColor(border.cgColor)
        context.setLineWidth(1.0)
        context.strokePath()
        
        // Additional glow stroke for glass effect
        context.saveGState()
        context.addPath(path)
        context.setShadow(offset: .zero, blur: 4.0, color: UIColor.white.withAlphaComponent(isDark ? 0.1 : 0.3).cgColor)
        context.setStrokeColor(UIColor.white.withAlphaComponent(isDark ? 0.1 : 0.2).cgColor)
        context.setLineWidth(0.5)
        context.strokePath()
        context.restoreGState()
    })
}

public final class SliderComponent: Component {
    public final class Discrete: Equatable {
        public let valueCount: Int
        public let value: Int
        public let minValue: Int?
        public let markPositions: Bool
        public let valueUpdated: (Int) -> Void

        public init(valueCount: Int, value: Int, minValue: Int? = nil, markPositions: Bool, valueUpdated: @escaping (Int) -> Void) {
            self.valueCount = valueCount
            self.value = value
            self.minValue = minValue
            self.markPositions = markPositions
            self.valueUpdated = valueUpdated
        }

        public static func ==(lhs: Discrete, rhs: Discrete) -> Bool {
            if lhs.valueCount != rhs.valueCount {
                return false
            }
            if lhs.value != rhs.value {
                return false
            }
            if lhs.minValue != rhs.minValue {
                return false
            }
            if lhs.markPositions != rhs.markPositions {
                return false
            }
            return true
        }
    }

    public final class Continuous: Equatable {
        public let value: CGFloat
        public let minValue: CGFloat?
        public let valueUpdated: (CGFloat) -> Void

        public init(value: CGFloat, minValue: CGFloat? = nil, valueUpdated: @escaping (CGFloat) -> Void) {
            self.value = value
            self.minValue = minValue
            self.valueUpdated = valueUpdated
        }

        public static func ==(lhs: Continuous, rhs: Continuous) -> Bool {
            if lhs.value != rhs.value {
                return false
            }
            if lhs.minValue != rhs.minValue {
                return false
            }
            return true
        }
    }

    public enum Content: Equatable {
        case discrete(Discrete)
        case continuous(Continuous)
    }

    public let content: Content
    public let useNative: Bool
    public let trackBackgroundColor: UIColor
    public let trackForegroundColor: UIColor
    public let minTrackForegroundColor: UIColor?
    public let knobSize: CGFloat?
    public let knobColor: UIColor?
    public let isTrackingUpdated: ((Bool) -> Void)?

    public init(
        content: Content,
        useNative: Bool = false,
        trackBackgroundColor: UIColor,
        trackForegroundColor: UIColor,
        minTrackForegroundColor: UIColor? = nil,
        knobSize: CGFloat? = nil,
        knobColor: UIColor? = nil,
        isTrackingUpdated: ((Bool) -> Void)? = nil
    ) {
        self.content = content
        self.useNative = useNative
        self.trackBackgroundColor = trackBackgroundColor
        self.trackForegroundColor = trackForegroundColor
        self.minTrackForegroundColor = minTrackForegroundColor
        self.knobSize = knobSize
        self.knobColor = knobColor
        self.isTrackingUpdated = isTrackingUpdated
    }

    public static func ==(lhs: SliderComponent, rhs: SliderComponent) -> Bool {
        if lhs.content != rhs.content {
            return false
        }
        if lhs.trackBackgroundColor != rhs.trackBackgroundColor {
            return false
        }
        if lhs.trackForegroundColor != rhs.trackForegroundColor {
            return false
        }
        if lhs.minTrackForegroundColor != rhs.minTrackForegroundColor {
            return false
        }
        if lhs.knobSize != rhs.knobSize {
            return false
        }
        if lhs.knobColor != rhs.knobColor {
            return false
        }
        return true
    }

    final class SliderView: UISlider {
    }

    public final class View: UIView {
        private var nativeSliderView: SliderView?
        private var sliderView: TGPhotoEditorSliderView?

        private var component: SliderComponent?
        private weak var state: EmptyComponentState?

        public var hitTestTarget: UIView? {
            return self.sliderView
        }

        override public init(frame: CGRect) {
            super.init(frame: frame)
        }

        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func cancelGestures() {
            if let sliderView = self.sliderView, let gestureRecognizers = sliderView.gestureRecognizers {
                for gestureRecognizer in gestureRecognizers {
                    if gestureRecognizer.isEnabled {
                        gestureRecognizer.isEnabled = false
                        gestureRecognizer.isEnabled = true
                    }
                }
            }
        }

        func update(component: SliderComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
            self.component = component
            self.state = state

            let size = CGSize(width: availableSize.width, height: 44.0)
            let isDark = (self.traitCollection.userInterfaceStyle == .dark)

            if #available(iOS 26.0, *), component.useNative {
                let sliderView: SliderView
                if let current = self.nativeSliderView {
                    sliderView = current
                } else {
                    sliderView = SliderView()
                    sliderView.disablesInteractiveTransitionGestureRecognizer = true
                    sliderView.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
                    sliderView.layer.allowsGroupOpacity = true

                    self.addSubview(sliderView)
                    self.nativeSliderView = sliderView

                    switch component.content {
                    case let .continuous(continuous):
                        sliderView.minimumValue = Float(continuous.minValue ?? 0.0)
                        sliderView.maximumValue = 1.0
                    case let .discrete(discrete):
                        sliderView.minimumValue = 0.0
                        sliderView.maximumValue = Float(discrete.valueCount - 1)
                        sliderView.trackConfiguration = .init(numberOfTicks: discrete.valueCount)
                    }
                }

                switch component.content {
                case let .continuous(continuous):
                    sliderView.value = Float(continuous.value)
                case let .discrete(discrete):
                    sliderView.value = Float(discrete.value)
                }

                sliderView.minimumTrackTintColor = component.trackForegroundColor
                sliderView.maximumTrackTintColor = component.trackBackgroundColor

                if let thumb = generateGlassKnobImage(
                    trackColor: component.trackForegroundColor,
                    knobSize: component.knobSize,
                    knobColor: component.knobColor,
                    isDark: isDark
                ) {
                    sliderView.setThumbImage(thumb, for: .normal)
                    sliderView.setThumbImage(thumb, for: .highlighted)
                }

                transition.setFrame(view: sliderView, frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: availableSize.width, height: 44.0)))
            } else {
                var internalIsTrackingUpdated: ((Bool) -> Void)?
                if let isTrackingUpdated = component.isTrackingUpdated {
                    internalIsTrackingUpdated = { [weak self] isTracking in
                        if let self {
                            if !"".isEmpty {
                                if isTracking {
                                    self.sliderView?.bordered = true
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: { [weak self] in
                                        self?.sliderView?.bordered = false
                                    })
                                }
                            }
                        }
                        isTrackingUpdated(isTracking)
                    }
                }

                let sliderView: TGPhotoEditorSliderView
                if let current = self.sliderView {
                    sliderView = current
                } else {
                    sliderView = TGPhotoEditorSliderView()
                    sliderView.enablePanHandling = true

                    if let knobSize = component.knobSize {
                        sliderView.lineSize = max(6.0, knobSize * 0.20 + 6.0)
                    } else {
                        sliderView.lineSize = 8.0
                    }
                    sliderView.trackCornerRadius = sliderView.lineSize * 0.5
                    sliderView.dotSize = 5.0
                    sliderView.minimumValue = 0.0
                    sliderView.startValue = 0.0
                    sliderView.disablesInteractiveTransitionGestureRecognizer = true

                    switch component.content {
                    case let .discrete(discrete):
                        sliderView.maximumValue = CGFloat(discrete.valueCount - 1)
                        sliderView.positionsCount = discrete.valueCount
                        sliderView.useLinesForPositions = true
                        sliderView.markPositions = discrete.markPositions
                    case .continuous:
                        sliderView.maximumValue = 1.0
                    }

                    sliderView.backgroundColor = nil
                    sliderView.isOpaque = false
                    sliderView.backColor = component.trackBackgroundColor
                    sliderView.startColor = component.trackBackgroundColor
                    sliderView.trackColor = component.trackForegroundColor

                    sliderView.knobImage = generateGlassKnobImage(
                        trackColor: component.trackForegroundColor,
                        knobSize: component.knobSize,
                        knobColor: component.knobColor,
                        isDark: isDark
                    )

                    sliderView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
                    sliderView.hitTestEdgeInsets = UIEdgeInsets(top: -sliderView.frame.minX, left: 0.0, bottom: 0.0, right: -sliderView.frame.minX)

                    sliderView.disablesInteractiveTransitionGestureRecognizer = true
                    sliderView.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
                    sliderView.layer.allowsGroupOpacity = true
                    self.sliderView = sliderView
                    self.addSubview(sliderView)
                }

                sliderView.knobImage = generateGlassKnobImage(
                    trackColor: component.trackForegroundColor,
                    knobSize: component.knobSize,
                    knobColor: component.knobColor,
                    isDark: isDark
                )

                sliderView.lowerBoundTrackColor = component.minTrackForegroundColor
                switch component.content {
                case let .discrete(discrete):
                    sliderView.value = CGFloat(discrete.value)
                    if let minValue = discrete.minValue {
                        sliderView.lowerBoundValue = CGFloat(minValue)
                    } else {
                        sliderView.lowerBoundValue = 0.0
                    }
                case let .continuous(continuous):
                    sliderView.value = continuous.value
                    if let minValue = continuous.minValue {
                        sliderView.lowerBoundValue = minValue
                    } else {
                        sliderView.lowerBoundValue = 0.0
                    }
                }

                sliderView.interactionBegan = {
                    internalIsTrackingUpdated?(true)
                }
                sliderView.interactionEnded = {
                    internalIsTrackingUpdated?(false)
                }

                transition.setFrame(view: sliderView, frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: availableSize.width, height: 44.0)))
                sliderView.hitTestEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            }

            return size
        }

        @objc private func sliderValueChanged() {
            guard let component = self.component else {
                return
            }
            let floatValue: CGFloat
            if let sliderView = self.sliderView {
                floatValue = sliderView.value
            } else if let nativeSliderView = self.nativeSliderView {
                floatValue = CGFloat(nativeSliderView.value)
            } else {
                return
            }
            switch component.content {
            case let .discrete(discrete):
                discrete.valueUpdated(Int(floatValue))
            case let .continuous(continuous):
                continuous.valueUpdated(floatValue)
            }
        }
    }

    public func makeView() -> View {
        return View(frame: CGRect())
    }

    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}
