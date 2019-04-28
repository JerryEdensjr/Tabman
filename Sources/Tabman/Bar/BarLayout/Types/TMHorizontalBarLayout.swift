//
//  TMHorizontalBarLayout.swift
//  Tabman
//
//  Created by Merrick Sapsford on 30/05/2018.
//  Copyright © 2019 UI At Six. All rights reserved.
//

import UIKit

/// Layout that displays bar buttons sequentially along the horizontal axis.
///
/// Simple but versatile, `TMHorizontalBarLayout` lays `BarButton`s out in a horizontal `UIStackView`.
open class TMHorizontalBarLayout: TMBarLayout {
    
    // MARK: Defaults
    
    private struct Defaults {
        static let interButtonSpacing: CGFloat = 16.0
        static let minimumRecommendedButtonWidth: CGFloat = 40.0
        static let separatorWidth: CGFloat = 0.5
    }
    
    // MARK: Properties
    internal let stackView = UIStackView()
    
    // MARK: Customization
    
    open override var contentMode: TMBarLayout.ContentMode {
        didSet {
            switch contentMode {
            case .intrinsic:
                buttonDistribution = .fill
            case .fit:
                buttonDistribution = .fillEqually
            }
        }
    }
    /// Spacing between each button.
    open var interButtonSpacing = Defaults.interButtonSpacing {
        didSet {
            stackView.spacing = interButtonSpacing
        }
    }
    /// Distribution of internal stack view.
    private var buttonDistribution: UIStackView.Distribution {
        set {
            stackView.distribution = newValue
        } get {
            return stackView.distribution
        }
    }
    
    open var showSeparators: Bool = false {
        didSet {
            guard showSeparators != oldValue else {
                return
            }
            setNeedsReload()
        }
    }
    
    // MARK: Lifecycle
    
    open override func layout(in view: UIView) {
        super.layout(in: view)
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        stackView.spacing = interButtonSpacing
    }
    
    open override func insert(buttons: [TMBarButton], at index: Int) {
        super.insert(buttons: buttons, at: index)
        
        var currentIndex = index
        for button in buttons {
            
            var separator: SeparatorView?
            if showSeparators {
                separator = SeparatorView()
            }
            
            if index >= stackView.arrangedSubviews.count { // just add
                stackView.addArrangedSubview(button)
                if let separator = separator {
                    stackView.addArrangedSubview(separator)
                }
            } else {
                stackView.insertArrangedSubview(button, at: currentIndex)
                if let separator = separator {
                    stackView.insertArrangedSubview(separator, at: currentIndex + 1)
                }
            }
            
            if separator != nil {
                currentIndex += 2
            } else {
                currentIndex += 1
            }
        }
    }
    
    open override func remove(buttons: [TMBarButton]) {
        super.remove(buttons: buttons)
        
        for button in buttons {
            stackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
    }
    
    open override func focusArea(for position: CGFloat, capacity: Int) -> CGRect {
        let range = BarMath.localIndexRange(for: position, minimum: 0, maximum: capacity - 1)
        let buttons = stackView.arrangedSubviews.compactMap({ $0 as? TMBarButton })
        guard buttons.count > range.upperBound else {
            return .zero
        }
        
        let lowerView = buttons[range.lowerBound]
        let upperView = buttons[range.upperBound]
        
        let progress = BarMath.localProgress(for: position)
        let interpolation = lowerView.frame.interpolate(with: upperView.frame, progress: progress)
        
        return CGRect(x: lowerView.frame.origin.x + interpolation.origin.x,
                      y: 0.0,
                      width: lowerView.frame.size.width + interpolation.size.width,
                      height: view.bounds.size.height)
    }
}

extension TMHorizontalBarLayout {
    
    class SeparatorView: UIView {
        
        @available (*, unavailable)
        override var backgroundColor: UIColor? {
            didSet {}
        }
        
        override var tintColor: UIColor! {
            didSet {
                super.backgroundColor = tintColor
            }
        }
        
        // MARK: Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            initialize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initialize()
        }
        
        private func initialize() {
            
            translatesAutoresizingMaskIntoConstraints = false
            widthAnchor.constraint(equalToConstant: Defaults.separatorWidth).isActive = true
            
            super.backgroundColor = tintColor
        }
    }
}
