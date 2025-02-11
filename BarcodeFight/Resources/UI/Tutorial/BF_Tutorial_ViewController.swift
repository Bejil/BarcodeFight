//
//  BF_Tutorial_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 13/07/2024.
//

import Foundation
import UIKit

public class BF_Tutorial_ViewController: BF_ViewController {
	
	public struct Item {
		
		public var sourceView:UIView?
		public var title:String?
		public var subtitle:String?
		public var button:String?
	}
	
	public var completion:(()->Void)?
	public var key:UserDefaults.Keys?
	public var force:Bool = false
	public var items: [Item]?
	private lazy var titleLabel: BF_Label = {
		
		$0.font = Fonts.Content.Title.H1.withSize(Fonts.Size + 30)
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	private lazy var subtitleLabel: BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	
	private lazy var nextButton: BF_Button = {
		
		$0.style = .transparent
		$0.isText = true
		return $0
		
	}(BF_Button() { [weak self] _ in
		
		if self?.currentIndex ?? 0 < (self?.items?.count ?? 0) - 1 {
			
			self?.next()
		}
		else {
			
			self?.dismiss(animated: true, completion: self?.completion)
		}
	})
	private lazy var contentStackView: UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .center
		$0.alpha = 0.0
		
		var transform = CGAffineTransform.identity
		transform = transform.translatedBy(x: 0, y: -500)
		transform = transform.scaledBy(x: 10, y: 10)
		$0.transform = transform
		
		let stackView: UIStackView = .init(arrangedSubviews: [titleLabel, subtitleLabel, nextButton])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		
		$0.addArrangedSubview(stackView)
		
		return $0
		
	}(UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, nextButton]))
	private var currentIndex: Int = -1
	private var pulseTimer:Timer?
	private lazy var maskLayer:CAShapeLayer = .init()
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .overCurrentContext
		modalTransitionStyle = .crossDissolve
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		
		resetPulseTimer()
	}
	
	public override func loadView() {
		
		super.loadView()
		
		view.layer.sublayers?.forEach({
			
			$0.removeFromSuperlayer()
		})
		
		let dimBackgroundView: UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		dimBackgroundView.alpha = 0.85
		view.addSubview(dimBackgroundView)
		dimBackgroundView.snp.makeConstraints { make in
			
			make.edges.equalToSuperview()
		}
		
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			
			make.edges.equalToSuperview().inset(2 * UI.Margins)
		}
		
		let initialPath = UIBezierPath(rect: view.bounds)
		maskLayer.path = initialPath.cgPath
		maskLayer.fillRule = .evenOdd
		view.layer.mask = maskLayer
	}
	
	public func present() {
		
		if let key {
			
			if !(UserDefaults.get(key) as? Bool ?? false) || force {
				
				UserDefaults.set(true, key)
				
				UI.MainController.present(self, animated: true) { [weak self] in
					
					self?.next()
				}
			}
			else {
				
				completion?()
			}
		}
		else {
			
			completion?()
		}
	}
	
	private func resetPulseTimer() {
		
		items?.forEach({
			
			$0.sourceView?.stopPulse()
		})
		
		pulseTimer?.invalidate()
		pulseTimer = nil
	}
	
	private func next() {
		
		currentIndex += 1
		
		let animationDuration = 0.3
		
		if let title = items?[currentIndex].title {
			
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			animation.type = .fade
			titleLabel.text = String(key: title)
			animation.duration = animationDuration
			titleLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
		}
		
		if let subtitle = items?[currentIndex].subtitle {
			
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			animation.type = .fade
			subtitleLabel.text = String(key: subtitle)
			animation.duration = animationDuration
			subtitleLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
		}
		
		if let button = items?[currentIndex].button {
			
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			animation.type = .fade
			nextButton.title = String(key: button)
			animation.duration = animationDuration
			nextButton.titleLabel?.layer.add(animation, forKey: CATransitionType.push.rawValue)
		}
		
		UIView.animate(animationDuration) {
			
			self.titleLabel.isHidden = self.items?[self.currentIndex].title == nil
			self.titleLabel.superview?.layoutIfNeeded()
			
			self.subtitleLabel.isHidden = self.items?[self.currentIndex].subtitle == nil
			self.subtitleLabel.superview?.layoutIfNeeded()
			
			self.nextButton.isHidden = self.items?[self.currentIndex].button == nil
			self.nextButton.superview?.layoutIfNeeded()
		}
		
		if let sourceView = items?[currentIndex].sourceView {
			
			resetPulseTimer()
			
			pulseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
				
				sourceView.pulse(.white)
			})
			
			guard let sourceWindow = sourceView.window else { return }
			
			let sourceFrameInWindow = sourceView.convert(sourceView.bounds, to: sourceWindow)
			var frameInView = view.convert(sourceFrameInWindow, from: sourceWindow)
			
			let margins = UI.Margins
			
			frameInView.origin.x -= margins
			frameInView.origin.y -= margins
			frameInView.size.width += 2*margins
			frameInView.size.height += 2*margins
			
			let finalPath = UIBezierPath(rect: view.bounds)
			let finalRadius = max(frameInView.width, frameInView.height) / 2
			let finalCirclePath = UIBezierPath(arcCenter: CGPoint(x: frameInView.midX, y: frameInView.midY), radius: finalRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
			finalPath.append(finalCirclePath)
			finalPath.usesEvenOddFillRule = true
			
			if currentIndex > 0 {
				
				let pathAnimation = CABasicAnimation(keyPath: "path")
				pathAnimation.fromValue = maskLayer.path
				pathAnimation.toValue = finalPath.cgPath
				pathAnimation.duration = animationDuration
				maskLayer.add(pathAnimation, forKey: "pathAnimation")
			}
			
			maskLayer.path = finalPath.cgPath
			
			UIView.animate(currentIndex > 0 ? animationDuration : 0.0) { [weak self] in
				
				self?.positionContentStackView(avoiding: frameInView)
				self?.view.layoutIfNeeded()
			}
		}
		
		UIView.animate(withDuration: animationDuration, animations: {
			
			self.contentStackView.alpha = 1.0
			self.contentStackView.transform = .identity
		})
	}
	
	private func positionContentStackView(avoiding frameInView: CGRect) {
		
		let safeArea = view.safeAreaLayoutGuide.layoutFrame
		let margins = UI.Margins

		let topSpace = CGRect(
			x: safeArea.minX + margins,
			y: safeArea.minY + margins,
			width: safeArea.width - 2 * margins,
			height: frameInView.minY - safeArea.minY - margins
		)
		let bottomSpace = CGRect(
			x: safeArea.minX + margins,
			y: frameInView.maxY,
			width: safeArea.width - 2 * margins,
			height: safeArea.maxY - frameInView.maxY - margins
		)
		let leftSpace = CGRect(
			x: safeArea.minX + margins,
			y: safeArea.minY + margins,
			width: frameInView.minX - safeArea.minX - margins,
			height: safeArea.height - 2 * margins
		)
		let rightSpace = CGRect(
			x: frameInView.maxX,
			y: safeArea.minY + margins,
			width: safeArea.maxX - frameInView.maxX - margins,
			height: safeArea.height - 2 * margins
		)
		
		let spaces = [topSpace, bottomSpace, leftSpace, rightSpace]
		let largestSpace = spaces.max { $0.height * $0.width < $1.height * $1.width }
		
		contentStackView.snp.remakeConstraints { make in
			
			guard let largestSpace = largestSpace else { return }
			make.center.equalTo(CGPoint(x: largestSpace.midX, y: largestSpace.midY))
			make.width.lessThanOrEqualTo(largestSpace.width)
			make.height.lessThanOrEqualTo(largestSpace.height)
		}
	}
}
