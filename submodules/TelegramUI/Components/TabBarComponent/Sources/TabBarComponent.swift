import Foundation
import UIKit
import Display
import TelegramPresentationData
import ComponentFlow
import ComponentDisplayAdapters
import GlassBackgroundComponent
import MultilineTextComponent
import LottieComponent
import UIKitRuntimeUtils
import BundleIconComponent
import TextBadgeComponent
import AppBundle

private final class TabBarGlassBackgroundView: UIView {
    private let shadowView: UIView
    private let blurView: UIVisualEffectView
    private let tintView: UIView
    private let borderView: UIView
    private let highlightGradient: CAGradientLayer

    override init(frame: CGRect) {
        self.shadowView = UIView()
        self.shadowView.isUserInteractionEnabled = false
        self.shadowView.backgroundColor = .clear
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.18
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.shadowView.layer.shadowRadius = 18

        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.blurView.isUserInteractionEnabled = false
        self.blurView.clipsToBounds = true
        self.blurView.layer.cornerCurve = .continuous

        self.tintView = UIView()
        self.tintView.isUserInteractionEnabled = false
        self.tintView.backgroundColor = .clear
        self.tintView.layer.cornerCurve = .continuous

        self.borderView = UIView()
        self.borderView.isUserInteractionEnabled = false
        self.borderView.backgroundColor = .clear
        self.borderView.layer.borderWidth = 1.0
        self.borderView.layer.cornerCurve = .continuous

        self.highlightGradient = CAGradientLayer()
        self.highlightGradient.colors = [
            UIColor.white.withAlphaComponent(0.45).cgColor,
            UIColor.white.withAlphaComponent(0.10).cgColor,
            UIColor.white.withAlphaComponent(0.00).cgColor
        ]
        self.highlightGradient.locations = [0.0, 0.35, 1.0]
        self.highlightGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.highlightGradient.endPoint = CGPoint(x: 1.0, y: 1.0)

        super.init(frame: frame)

        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear

        self.addSubview(self.shadowView)
        self.addSubview(self.blurView)

        self.blurView.contentView.addSubview(self.tintView)

        self.blurView.contentView.addSubview(self.borderView)
        self.blurView.contentView.layer.addSublayer(self.highlightGradient)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(size: CGSize, isDark: Bool, transition: ComponentTransition) {
        let bgFrame = CGRect(origin: .zero, size: size)
        let cornerRadius = bgFrame.height / 2.0

        transition.setFrame(view: self.shadowView, frame: bgFrame)
        self.shadowView.layer.cornerRadius = cornerRadius
        self.shadowView.layer.shadowOpacity = isDark ? 0.28 : 0.18
        self.shadowView.layer.shadowRadius = isDark ? 20 : 18
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: cornerRadius).cgPath

        transition.setFrame(view: self.blurView, frame: bgFrame)
        self.blurView.layer.cornerRadius = cornerRadius

        transition.setFrame(view: self.tintView, frame: self.blurView.bounds)
        self.tintView.layer.cornerRadius = cornerRadius

        self.tintView.backgroundColor = isDark
        ? UIColor.white.withAlphaComponent(0.06)
        : UIColor.white.withAlphaComponent(0.18)

        transition.setFrame(view: self.borderView, frame: self.blurView.bounds)
        self.borderView.layer.cornerRadius = cornerRadius
        self.borderView.layer.borderColor = UIColor.white.withAlphaComponent(isDark ? 0.18 : 0.32).cgColor

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.highlightGradient.frame = self.blurView.bounds
        self.highlightGradient.cornerRadius = cornerRadius
        CATransaction.commit()
    }
}

private final class LiquidLensView: UIView {
    let contentView: UIView
    let selectedContentView: UIView
    private let shadowView: UIView
    private let blurView: UIVisualEffectView
    private let lensBorder: UIView
    private let lensGradient: CAGradientLayer
    private let maskLayer: CAShapeLayer
    
    override init(frame: CGRect) {
        self.contentView = UIView()
        self.selectedContentView = UIView()
        
        self.shadowView = UIView()
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.15
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.shadowView.layer.shadowRadius = 8
        self.shadowView.isUserInteractionEnabled = false
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.blurView.clipsToBounds = true
        self.blurView.layer.cornerCurve = .continuous
        self.blurView.isUserInteractionEnabled = false
        
        self.lensBorder = UIView()
        self.lensBorder.layer.borderWidth = 1.0
        self.lensBorder.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        self.lensBorder.layer.cornerCurve = .continuous
        self.lensBorder.isUserInteractionEnabled = false
        
        self.lensGradient = CAGradientLayer()
        self.lensGradient.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        self.lensGradient.locations = [0.0, 0.4, 1.0]
        self.lensGradient.startPoint = CGPoint(x: 0, y: 0)
        self.lensGradient.endPoint = CGPoint(x: 1, y: 1)
        
        self.maskLayer = CAShapeLayer()
        self.maskLayer.fillColor = UIColor.black.cgColor
        
        super.init(frame: frame)
        
        self.addSubview(self.contentView)
        
        self.addSubview(self.shadowView)
        self.addSubview(self.blurView)
        
        self.blurView.contentView.addSubview(self.lensBorder)
        self.blurView.contentView.layer.addSublayer(self.lensGradient)
        
        self.addSubview(self.selectedContentView)
        self.selectedContentView.layer.mask = self.maskLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(size: CGSize, selectionX: CGFloat, selectionWidth: CGFloat, isDark: Bool, isLifted: Bool, transition: ComponentTransition) {
        
        self.contentView.frame = CGRect(origin: .zero, size: size)
        self.selectedContentView.frame = CGRect(origin: .zero, size: size)
        
        let lensHeight: CGFloat = 52.0
        let lensY = (size.height - lensHeight) / 2.0 - 2.0
        
        let targetWidth: CGFloat = 64.0
        let currentWidth = isLifted ? selectionWidth : targetWidth
        
        let centerX = selectionX + (selectionWidth / 2.0)
        let currentX = centerX - (currentWidth / 2.0)
        
        let lensFrame = CGRect(x: currentX, y: lensY, width: currentWidth, height: lensHeight)
        let cornerRadius = lensHeight / 2.0
        
        transition.setFrame(view: self.shadowView, frame: lensFrame)
        self.shadowView.layer.cornerRadius = cornerRadius
        
        transition.setFrame(view: self.blurView, frame: lensFrame)
        self.blurView.layer.cornerRadius = cornerRadius
        
        transition.setFrame(view: self.lensBorder, frame: self.blurView.bounds)
        self.lensBorder.layer.cornerRadius = cornerRadius
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.lensGradient.frame = self.blurView.bounds
        self.lensGradient.cornerRadius = cornerRadius
        CATransaction.commit()
        
        let path = UIBezierPath(roundedRect: lensFrame, cornerRadius: cornerRadius)
        
        if !transition.animation.isImmediate {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = self.maskLayer.path
            animation.toValue = path.cgPath
            animation.duration = 0.35
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.maskLayer.removeAnimation(forKey: "path")
            self.maskLayer.add(animation, forKey: "path")
        }
        
        self.maskLayer.path = path.cgPath
    }
}

private final class TabSelectionRecognizer: UIGestureRecognizer {
    private var initialLocation: CGPoint?
    private var currentLocation: CGPoint?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.delaysTouchesBegan = false
        self.delaysTouchesEnded = false
    }
    
    override func reset() {
        super.reset()
        self.initialLocation = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if self.initialLocation == nil {
            self.initialLocation = touches.first?.location(in: self.view)
        }
        self.currentLocation = self.initialLocation
        self.state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.state = .cancelled
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        self.currentLocation = touches.first?.location(in: self.view)
        self.state = .changed
    }
    
    func translation(in: UIView?) -> CGPoint {
        if let initialLocation = self.initialLocation, let currentLocation = self.currentLocation {
            return CGPoint(x: currentLocation.x - initialLocation.x, y: currentLocation.y - initialLocation.y)
        }
        return CGPoint()
    }
}

public final class TabBarComponent: Component {
    public final class Item: Equatable {
        public let item: UITabBarItem
        public let action: (Bool) -> Void
        public let contextAction: ((ContextGesture, ContextExtractedContentContainingView) -> Void)?
        
        fileprivate var id: AnyHashable {
            return AnyHashable(ObjectIdentifier(self.item))
        }
        
        public init(item: UITabBarItem, action: @escaping (Bool) -> Void, contextAction: ((ContextGesture, ContextExtractedContentContainingView) -> Void)?) {
            self.item = item
            self.action = action
            self.contextAction = contextAction
        }
        
        public static func ==(lhs: Item, rhs: Item) -> Bool {
            if lhs === rhs { return true }
            if lhs.item !== rhs.item { return false }
            if (lhs.contextAction == nil) != (rhs.contextAction == nil) { return false }
            return true
        }
    }
    
    public let theme: PresentationTheme
    public let items: [Item]
    public let selectedId: AnyHashable?
    public let isTablet: Bool
    
    public init(theme: PresentationTheme, items: [Item], selectedId: AnyHashable?, isTablet: Bool) {
        self.theme = theme
        self.items = items
        self.selectedId = selectedId
        self.isTablet = isTablet
    }
    
    public static func ==(lhs: TabBarComponent, rhs: TabBarComponent) -> Bool {
        if lhs.theme !== rhs.theme { return false }
        if lhs.items != rhs.items { return false }
        if lhs.selectedId != rhs.selectedId { return false }
        if lhs.isTablet != rhs.isTablet { return false }
        return true
    }
    
    public final class View: UIView, UITabBarDelegate, UIGestureRecognizerDelegate {
        private let barBackgroundView: TabBarGlassBackgroundView
        private let liquidLensView: LiquidLensView
        private let contextGestureContainerView: ContextControllerSourceView
        
        private var itemViews: [AnyHashable: ComponentView<Empty>] = [:]
        private var selectedItemViews: [AnyHashable: ComponentView<Empty>] = [:]
        
        private var tabSelectionRecognizer: TabSelectionRecognizer?
        private var itemWithActiveContextGesture: AnyHashable?
        
        private var component: TabBarComponent?
        private weak var state: EmptyComponentState?

        private var selectionGestureState: (startX: CGFloat, currentX: CGFloat)?
        private var overrideSelectedItemId: AnyHashable?
        
        public override init(frame: CGRect) {
            self.barBackgroundView = TabBarGlassBackgroundView(frame: .zero)
            self.liquidLensView = LiquidLensView(frame: .zero)
            
            self.contextGestureContainerView = ContextControllerSourceView()
            self.contextGestureContainerView.isGestureEnabled = true
            
            super.init(frame: frame)
            
            self.backgroundColor = .clear
            
            if #available(iOS 17.0, *) {
                self.traitOverrides.verticalSizeClass = .compact
                self.traitOverrides.horizontalSizeClass = .compact
            }
            
            self.addSubview(self.contextGestureContainerView)

            self.contextGestureContainerView.addSubview(self.barBackgroundView)
            self.contextGestureContainerView.addSubview(self.liquidLensView)
            
            let tabSelectionRecognizer = TabSelectionRecognizer(target: self, action: #selector(self.onTabSelectionGesture(_:)))
            self.tabSelectionRecognizer = tabSelectionRecognizer
            self.addGestureRecognizer(tabSelectionRecognizer)
            
            self.contextGestureContainerView.shouldBegin = { [weak self] point in
                guard let self, let component = self.component else { return false }
                
                if let itemId = self.item(at: point) {
                    guard let item = component.items.first(where: { $0.id == itemId }) else { return false }
                    if item.contextAction == nil { return false }
                    
                    self.itemWithActiveContextGesture = itemId
                    let startPoint = point
                    
                    self.contextGestureContainerView.contextGesture?.externalUpdated = { [weak self] _, point in
                        guard let self else { return }
                        let dist = sqrt(pow(startPoint.x - point.x, 2.0) + pow(startPoint.y - point.y, 2.0))
                        if dist > 10.0 {
                            self.contextGestureContainerView.contextGesture?.cancel()
                        }
                    }
                    return true
                }
                return false
            }
            
            self.contextGestureContainerView.customActivationProgress = { _, _ in }
            
            self.contextGestureContainerView.activated = { [weak self] gesture, _ in
                guard let self, let component = self.component else { return }
                guard let itemWithActiveContextGesture = self.itemWithActiveContextGesture else { return }
                
                var itemView: ItemComponent.View?
                if let componentView = self.itemViews[itemWithActiveContextGesture]?.view as? ItemComponent.View {
                    itemView = componentView
                }
                
                guard let itemView else { return }

                if let tabSelectionRecognizer = self.tabSelectionRecognizer {
                    tabSelectionRecognizer.state = .cancelled
                }
                
                guard let item = component.items.first(where: { $0.id == itemWithActiveContextGesture }) else { return }
                item.contextAction?(gesture, itemView.contextContainerView)
            }
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            guard let component = self.component else { return }
            if let index = tabBar.items?.firstIndex(where: { $0 === item }) {
                if index < component.items.count {
                    component.items[index].action(false)
                }
            }
        }
        
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        @objc private func onTabSelectionGesture(_ recognizer: TabSelectionRecognizer) {
            switch recognizer.state {
            case .began:
                if let itemId = self.item(at: recognizer.location(in: self)), let itemView = self.itemViews[itemId]?.view {
                    let startX = itemView.frame.minX
                    self.selectionGestureState = (startX, startX)
                    
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    
                    self.state?.updated(transition: .spring(duration: 0.4), isLocal: true)
                }
            case .changed:
                if var selectionGestureState = self.selectionGestureState {
                    selectionGestureState.currentX = selectionGestureState.startX + recognizer.translation(in: self).x
                    self.selectionGestureState = selectionGestureState
                    self.state?.updated(transition: .immediate, isLocal: true)
                }
            case .ended, .cancelled:
                self.selectionGestureState = nil
                if let component = self.component, let itemId = self.item(at: recognizer.location(in: self)) {
                    guard let item = component.items.first(where: { $0.id == itemId }) else { return }
                    self.overrideSelectedItemId = itemId
                    item.action(false)
                    
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
                self.state?.updated(transition: .spring(duration: 0.4), isLocal: true)
            default:
                break
            }
        }
        
        public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            return super.hitTest(point, with: event)
        }
        
        public func frameForItem(at index: Int) -> CGRect? {
            guard let component = self.component else { return nil }
            if index < 0 || index >= component.items.count { return nil }
            guard let itemView = self.itemViews[component.items[index].id]?.view else { return nil }
            return self.convert(itemView.bounds, from: itemView)
        }

        private func item(at point: CGPoint) -> AnyHashable? {
            var closestItem: (AnyHashable, CGFloat)?
            
            for (id, itemView) in self.itemViews {
                guard let itemView = itemView.view else { continue }
                
                let convertedFrame = self.convert(itemView.frame, from: itemView.superview)
                
                if convertedFrame.contains(point) {
                    return id
                } else {
                    let distance = abs(point.x - convertedFrame.midX)
                    if let closestItemValue = closestItem {
                        if closestItemValue.1 > distance {
                            closestItem = (id, distance)
                        }
                    } else {
                        closestItem = (id, distance)
                    }
                }
            }
            return closestItem?.0
        }
        
        public override func didMoveToWindow() {
            super.didMoveToWindow()
            self.state?.updated()
        }
        
        func update(component: TabBarComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
            let innerInset: CGFloat = 4.0
            let availableSize = CGSize(width: min(500.0, availableSize.width), height: availableSize.height)
            
            let previousComponent = self.component
            self.component = component
            self.state = state
            
            self.overrideUserInterfaceStyle = component.theme.overallDarkAppearance ? .dark : .light

            let itemSize = CGSize(width: floor((availableSize.width - innerInset * 2.0) / CGFloat(component.items.count)), height: 56.0)
            let contentWidth: CGFloat = innerInset * 2.0 + CGFloat(component.items.count) * itemSize.width
            let size = CGSize(width: min(availableSize.width, contentWidth), height: itemSize.height + innerInset * 2.0)

            var validIds: [AnyHashable] = []
            var selectionFrame: CGRect?
            
            for index in 0 ..< component.items.count {
                let item = component.items[index]
                validIds.append(item.id)
                
                let itemView: ComponentView<Empty>
                var itemTransition = transition
                
                if let current = self.itemViews[item.id] {
                    itemView = current
                } else {
                    itemTransition = itemTransition.withAnimation(.none)
                    itemView = ComponentView()
                    self.itemViews[item.id] = itemView
                }
                
                let selectedItemView: ComponentView<Empty>
                if let current = self.selectedItemViews[item.id] {
                    selectedItemView = current
                } else {
                    selectedItemView = ComponentView()
                    self.selectedItemViews[item.id] = selectedItemView
                }
                
                let isItemSelected: Bool
                if let overrideSelectedItemId = self.overrideSelectedItemId {
                    isItemSelected = overrideSelectedItemId == item.id
                } else {
                    isItemSelected = component.selectedId == item.id
                }
                
                let _ = itemView.update(
                    transition: itemTransition,
                    component: AnyComponent(ItemComponent(
                        item: item,
                        theme: component.theme,
                        isSelected: false
                    )),
                    environment: {},
                    containerSize: itemSize
                )
                
                let _ = selectedItemView.update(
                    transition: itemTransition,
                    component: AnyComponent(ItemComponent(
                        item: item,
                        theme: component.theme,
                        isSelected: true
                    )),
                    environment: {},
                    containerSize: itemSize
                )
                
                let itemFrame = CGRect(origin: CGPoint(x: innerInset + CGFloat(index) * itemSize.width, y: floor((size.height - itemSize.height) * 0.5)), size: itemSize)
                
                if let itemComponentView = itemView.view as? ItemComponent.View, let selectedItemComponentView = selectedItemView.view as? ItemComponent.View {
                    
                    if itemComponentView.superview == nil {
                        itemComponentView.isUserInteractionEnabled = false
                        self.liquidLensView.contentView.addSubview(itemComponentView)
                    }
                    if selectedItemComponentView.superview == nil {
                        selectedItemComponentView.isUserInteractionEnabled = false
                        self.liquidLensView.selectedContentView.addSubview(selectedItemComponentView)
                    }
                    
                    itemTransition.setFrame(view: itemComponentView, frame: itemFrame)
                    itemTransition.setFrame(view: selectedItemComponentView, frame: itemFrame)
                    
                    let scale: CGFloat = isItemSelected ? 1.05 : 1.0
                    itemTransition.setScale(view: selectedItemComponentView, scale: scale)
                    itemTransition.setScale(view: itemComponentView, scale: 1.0)
                    
                    if let previousComponent, previousComponent.selectedId != item.id, isItemSelected {
                        itemComponentView.playSelectionAnimation()
                        selectedItemComponentView.playSelectionAnimation()
                    }
                }
                
                if isItemSelected {
                    selectionFrame = itemFrame
                }
            }
            
            var removeIds: [AnyHashable] = []
            for (id, itemView) in self.itemViews {
                if !validIds.contains(id) {
                    removeIds.append(id)
                    itemView.view?.removeFromSuperview()
                    self.selectedItemViews[id]?.view?.removeFromSuperview()
                }
            }
            for id in removeIds {
                self.itemViews.removeValue(forKey: id)
                self.selectedItemViews.removeValue(forKey: id)
            }

            transition.setFrame(view: self.contextGestureContainerView, frame: CGRect(origin: CGPoint(), size: size))

            transition.setFrame(view: self.barBackgroundView, frame: CGRect(origin: CGPoint(), size: size))
            self.barBackgroundView.update(
                size: size,
                isDark: component.theme.overallDarkAppearance,
                transition: transition
            )

            transition.setFrame(view: self.liquidLensView, frame: CGRect(origin: CGPoint(), size: size))
            
            let lensSelection: (x: CGFloat, width: CGFloat)
            if let selectionGestureState = self.selectionGestureState {
                lensSelection = (selectionGestureState.currentX, itemSize.width)
            } else if let selectionFrame {
                lensSelection = (selectionFrame.minX, itemSize.width)
            } else {
                lensSelection = (0.0, itemSize.width)
            }

            self.liquidLensView.update(
                size: size,
                selectionX: lensSelection.x,
                selectionWidth: lensSelection.width,
                isDark: component.theme.overallDarkAppearance,
                isLifted: self.selectionGestureState != nil,
                transition: transition
            )

            return size
        }
    }
    
    public func makeView() -> View {
        return View(frame: CGRect())
    }
    
    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}

private final class ItemComponent: Component {
    let item: TabBarComponent.Item
    let theme: PresentationTheme
    let isSelected: Bool
    
    init(item: TabBarComponent.Item, theme: PresentationTheme, isSelected: Bool) {
        self.item = item
        self.theme = theme
        self.isSelected = isSelected
    }
    
    static func ==(lhs: ItemComponent, rhs: ItemComponent) -> Bool {
        if lhs.item != rhs.item { return false }
        if lhs.theme !== rhs.theme { return false }
        if lhs.isSelected != rhs.isSelected { return false }
        return true
    }
    
    final class View: UIView {
        let contextContainerView: ContextExtractedContentContainingView
        
        private var imageIcon: ComponentView<Empty>?
        private var animationIcon: ComponentView<Empty>?
        private let title = ComponentView<Empty>()
        private var badge: ComponentView<Empty>?
        
        private var component: ItemComponent?
        private weak var state: EmptyComponentState?
        
        private var setImageListener: Int?
        private var setSelectedImageListener: Int?
        private var setBadgeListener: Int?
        
        override init(frame: CGRect) {
            self.contextContainerView = ContextExtractedContentContainingView()
            super.init(frame: frame)
            self.addSubview(self.contextContainerView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            if let component = self.component {
                if let setImageListener = self.setImageListener {
                    component.item.item.removeSetImageListener(setImageListener)
                }
                if let setSelectedImageListener = self.setSelectedImageListener {
                    component.item.item.removeSetSelectedImageListener(setSelectedImageListener)
                }
                if let setBadgeListener = self.setBadgeListener {
                    component.item.item.removeSetBadgeListener(setBadgeListener)
                }
            }
        }
        
        func playSelectionAnimation() {
            if let animationIconView = self.animationIcon?.view as? LottieComponent.View {
                animationIconView.playOnce()
            }
        }
        
        func update(component: ItemComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
            let previousComponent = self.component
            
            if previousComponent?.item.item !== component.item.item {
                if let setImageListener = self.setImageListener {
                    self.component?.item.item.removeSetImageListener(setImageListener)
                }
                self.setImageListener = component.item.item.addSetImageListener { [weak self] _ in
                    self?.state?.updated(transition: .immediate, isLocal: true)
                }
            }
            
            self.component = component
            self.state = state
            
            if let animationName = component.item.item.animationName {
                if let imageIcon = self.imageIcon {
                    self.imageIcon = nil
                    imageIcon.view?.removeFromSuperview()
                }
                
                let animationIcon: ComponentView<Empty>
                var iconTransition = transition
                if let current = self.animationIcon {
                    animationIcon = current
                } else {
                    iconTransition = iconTransition.withAnimation(.none)
                    animationIcon = ComponentView()
                    self.animationIcon = animationIcon
                }
                
                let iconColor = component.isSelected ? component.theme.rootController.tabBar.selectedTextColor : component.theme.rootController.tabBar.textColor
                
                let iconSize = animationIcon.update(
                    transition: iconTransition,
                    component: AnyComponent(LottieComponent(
                        content: LottieComponent.AppBundleContent(name: animationName),
                        color: iconColor,
                        placeholderColor: nil,
                        startingPosition: .end,
                        size: CGSize(width: 32.0, height: 32.0),
                        loop: false
                    )),
                    environment: {},
                    containerSize: CGSize(width: 32.0, height: 32.0)
                )
                
                let iconFrame = CGRect(origin: CGPoint(x: floor((availableSize.width - iconSize.width) * 0.5), y: 6.0), size: iconSize)
                
                if let animationIconView = animationIcon.view {
                    if animationIconView.superview == nil {
                        self.contextContainerView.contentView.addSubview(animationIconView)
                    }
                    iconTransition.setFrame(view: animationIconView, frame: iconFrame)
                }
            } else {
                if let animationIcon = self.animationIcon {
                    self.animationIcon = nil
                    animationIcon.view?.removeFromSuperview()
                }
                
                let imageIcon: ComponentView<Empty>
                var iconTransition = transition
                if let current = self.imageIcon {
                    imageIcon = current
                } else {
                    iconTransition = iconTransition.withAnimation(.none)
                    imageIcon = ComponentView()
                    self.imageIcon = imageIcon
                }
                
                let displayImage = component.isSelected ? component.item.item.selectedImage : component.item.item.image
                let iconColor = component.isSelected ? component.theme.rootController.tabBar.selectedTextColor : component.theme.rootController.tabBar.textColor
                
                let iconSize = imageIcon.update(
                    transition: iconTransition,
                    component: AnyComponent(Image(
                        image: displayImage,
                        tintColor: iconColor,
                        contentMode: .center
                    )),
                    environment: {},
                    containerSize: CGSize(width: 40.0, height: 40.0)
                )
                let iconFrame = CGRect(origin: CGPoint(x: floor((availableSize.width - iconSize.width) * 0.5), y: 6.0), size: iconSize)
                
                if let imageIconView = imageIcon.view {
                    if imageIconView.superview == nil {
                        self.contextContainerView.contentView.addSubview(imageIconView)
                    }
                    iconTransition.setFrame(view: imageIconView, frame: iconFrame)
                }
            }
            
            if let badgeText = component.item.item.badgeValue, !badgeText.isEmpty {
                let badge: ComponentView<Empty>
                var badgeTransition = transition
                if let current = self.badge {
                    badge = current
                } else {
                    badgeTransition = badgeTransition.withAnimation(.none)
                    badge = ComponentView()
                    self.badge = badge
                }
                let badgeSize = badge.update(
                    transition: badgeTransition,
                    component: AnyComponent(TextBadgeComponent(
                        text: badgeText,
                        font: Font.regular(13.0),
                        background: component.theme.rootController.tabBar.badgeBackgroundColor,
                        foreground: component.theme.rootController.tabBar.badgeTextColor,
                        insets: UIEdgeInsets(top: 0.0, left: 6.0, bottom: 1.0, right: 6.0)
                    )),
                    environment: {},
                    containerSize: CGSize(width: 100.0, height: 100.0)
                )
                let badgeFrame = CGRect(origin: CGPoint(x: floor(availableSize.width / 2.0) + 10.0, y: 4.0), size: badgeSize)
                
                if let badgeView = badge.view {
                    if badgeView.superview == nil {
                        self.contextContainerView.contentView.addSubview(badgeView)
                    }
                    badgeTransition.setFrame(view: badgeView, frame: badgeFrame)
                }
            } else if let badge = self.badge {
                self.badge = nil
                badge.view?.removeFromSuperview()
            }
            
            transition.setFrame(view: self.contextContainerView, frame: CGRect(origin: CGPoint(), size: availableSize))
            transition.setFrame(view: self.contextContainerView.contentView, frame: CGRect(origin: CGPoint(), size: availableSize))
            self.contextContainerView.contentRect = CGRect(origin: CGPoint(), size: availableSize)
            
            return availableSize
        }
    }
    
    func makeView() -> View {
        return View(frame: CGRect())
    }
    
    func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}
