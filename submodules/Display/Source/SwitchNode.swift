import Foundation
import UIKit
import AsyncDisplayKit
import SwiftUI

open class SwitchNode: ASDisplayNode {
    public var valueUpdated: ((Bool) -> Void)?
    
    public var frameColor = UIColor(rgb: 0xe0e0e0)
    public var handleColor = UIColor(rgb: 0xffffff)
    public var contentColor = UIColor(rgb: 0x42d451) {
        didSet {
            self.updateSwiftUIState()
        }
    }
    
    private var _isOn: Bool = false
    public var isOn: Bool {
        get {
            return self._isOn
        }
        set(value) {
            if value != self._isOn {
                self._isOn = value
                self.updateSwiftUIState()
            }
        }
    }
    
    private var hostingController: UIHostingController<LiquidGlassSwitchView>?
    
    override public init() {
        super.init()
        
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    override open func didLoad() {
        super.didLoad()
        
        let binding = Binding<Bool>(
            get: { [weak self] in
                return self?._isOn ?? false
            },
            set: { [weak self] newValue in
                guard let self = self else { return }
                if self._isOn != newValue {
                    self._isOn = newValue
                    self.valueUpdated?(newValue)
                }
            }
        )
        
        let swiftUIView = LiquidGlassSwitchView(
            isOn: binding,
            activeColor: self.contentColor,
            inactiveColor: self.frameColor
        )
        
        let host = UIHostingController(rootView: swiftUIView)
        host.view.backgroundColor = .clear
        host.view.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        
        self.view.addSubview(host.view)
        self.hostingController = host
    }
    
    private func updateSwiftUIState() {
        guard let host = self.hostingController else { return }
        
        let binding = Binding<Bool>(
            get: { [weak self] in self?._isOn ?? false },
            set: { [weak self] val in
                self?._isOn = val
                self?.valueUpdated?(val)
            }
        )
        
        host.rootView = LiquidGlassSwitchView(
            isOn: binding,
            activeColor: self.contentColor,
            inactiveColor: self.frameColor
        )
    }
    
    public func setOn(_ value: Bool, animated: Bool) {
        self.isOn = value
    }
    
    override open func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        return CGSize(width: 51.0, height: 31.0)
    }
    
    override open func layout() {
        super.layout()
        if let hostView = self.hostingController?.view {
            hostView.frame = self.bounds
        }
    }
}
