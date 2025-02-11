//
//  LY_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 19/03/2023.
//

import Foundation
import UIKit

public class BF_ViewController: UIViewController {
	
	private lazy var closeButton:BF_Button = {
		
		$0.style = .transparent
		$0.isText = true
		$0.image = UIImage(named: "close_icon")
		$0.titleFont = Fonts.Navigation.Button
		$0.configuration?.contentInsets = .zero
		$0.configuration?.imagePadding = UI.Margins/2
		return $0
		
	}(BF_Button(String(key: "Fermer")) { [weak self] _ in
		
		UIApplication.feedBack(.On)
		self?.close()
	})
	public var isModal:Bool = false {
		
		didSet {
			
			if let navigationController = navigationController {
				
				if navigationController.viewControllers.count < 2 {
					
					navigationItem.leftBarButtonItem = isModal ? .init(customView: closeButton) : nil
				}
			}
			else {
				
				view.addSubview(closeButton)
				closeButton.snp.makeConstraints { make in
					make.top.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
				}
			}
		}
	}
	private lazy var gradientBackgroundLayer:CAGradientLayer = {
		
		let initialColorTop = Colors.Primary.cgColor
		let initialColorBottom = Colors.Secondary.cgColor
		let finalColorTop = Colors.Secondary.cgColor
		let finalColorBottom = Colors.Primary.cgColor
		
		$0.colors = [initialColorTop, initialColorBottom]
		$0.startPoint = CGPoint(x: 0.0, y: 0.0)
		$0.endPoint = CGPoint(x: 1.0, y: 1.0)
		
		let animation = CABasicAnimation(keyPath: "colors")
		animation.repeatCount = .infinity
		animation.autoreverses = true
		animation.duration = 5.0
		animation.toValue = [finalColorTop, finalColorBottom]
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		$0.add(animation, forKey: "animateGradient")
		
		return $0
		
	}(CAGradientLayer())
	private lazy var particulesView:BF_Monsters_Particules_View = {
		
		$0.isFade = false
		$0.alpha = 0.03
		$0.scale = 0.75
		return $0
		
	}(BF_Monsters_Particules_View())
	private var bezierPath:UIBezierPath?
	private var previousPoint:CGPoint = .zero
	private var panGestureTimer:Timer?
	
	deinit {
		
		panGestureTimer?.invalidate()
		panGestureTimer = nil
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .fullScreen
		modalTransitionStyle = .coverVertical
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var shapeLayer:CAShapeLayer = {
		
		$0.lineJoin = .round
		$0.lineCap = .round
		$0.fillColor = UIColor.clear.cgColor
		$0.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
		return $0
		
	}(CAShapeLayer())
	
	public override func loadView() {
		
		super.loadView()
		
		view.layer.addSublayer(gradientBackgroundLayer)
		view.layer.addSublayer(particulesView.layer)
		
		let tapGestureRecognizer:UITapGestureRecognizer = .init { [weak self] sender in
			
			if let weakSelf = self {
				
				let touchLocation = sender.location(in: weakSelf.view)
				
				let view:UIView = .init()
				view.isUserInteractionEnabled = false
				weakSelf.view.addSubview(view)
				view.snp.makeConstraints { make in
					make.centerX.equalTo(touchLocation.x)
					make.centerY.equalTo(touchLocation.y)
					make.size.equalTo(2*UI.Margins)
				}
				view.pulse(.white) {
					
					view.removeFromSuperview()
				}
			}
		}
		tapGestureRecognizer.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGestureRecognizer)
		
		UIApplication.wait { [weak self] in
			
			let gradient:CAGradientLayer = .init()
			gradient.frame = .init(origin: .zero, size: .init(width: self?.view.frame.size.width ?? 0, height: (self?.navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.statusBarHeight + (5*UI.Margins)))
			gradient.colors = [UIColor.black.cgColor,UIColor.clear.cgColor]
			gradient.opacity = 0.5
			gradient.locations = [0.0, 1.0]
			self?.view.layer.addSublayer(gradient)
			
			if let shapeLayer = self?.shapeLayer {
				
				self?.view.layer.addSublayer(shapeLayer)
			}
			
			let panGestureRecognizer:UIPanGestureRecognizer = .init(block: { [weak self] gestureRecognizer in
				
				let currentPoint = gestureRecognizer.location(in: self?.view)
				
				if gestureRecognizer.state == .began {
					
					self?.bezierPath = .init()
					self?.bezierPath?.move(to: currentPoint)
					
					self?.shapeLayer.opacity = 1.0
					self?.shapeLayer.lineWidth = 0
				}
				else if gestureRecognizer.state == .changed {
					
					if let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self?.view) {
						
						let speed = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
						
						if speed > 175 {
							
							if let previousPoint = self?.previousPoint {
								
								self?.shapeLayer.opacity = 1.0
								
								let midPoint:CGPoint = .init(x: (previousPoint.x + currentPoint.x)/2, y: (previousPoint.y + currentPoint.y)/2)
								self?.bezierPath?.addQuadCurve(to: midPoint, controlPoint: previousPoint)
								self?.shapeLayer.lineWidth = min((3*UI.Margins/4) * (sqrt(speed) / sqrt(1000)), (3*UI.Margins/4))
							}
						}
					}
					
					UIApplication.wait { [weak self] in
						
						UIView.animate { [weak self] in
							
							self?.shapeLayer.opacity = 0.0
							self?.shapeLayer.lineWidth = 0
							
						} completion: { _ in
							
							self?.bezierPath = .init()
							self?.bezierPath?.move(to: currentPoint)
						}
					}
				}
				else {
					
					self?.panGestureTimer?.invalidate()
					self?.panGestureTimer = nil
					
					UIView.animate(withDuration: 0.3, animations: { [weak self] in
						
						self?.shapeLayer.opacity = 0.0
						self?.shapeLayer.lineWidth = 0
						
					}, completion: { _ in
						
						self?.bezierPath = .init()
						self?.shapeLayer.opacity = 1.0
					})
				}
				
				self?.previousPoint = currentPoint
				
				self?.shapeLayer.path = self?.bezierPath?.cgPath
			})
			panGestureRecognizer.delegate = self
			self?.view.addGestureRecognizer(panGestureRecognizer)
		}
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		UIApplication.hideKeyboard()
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		view.bringSubviewToFront(closeButton)
		
		gradientBackgroundLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
		particulesView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
	}
	
	public func close() {
		
		dismiss()
	}
	
	public func dismiss(_ completion:(()->Void)? = nil) {
		
		dismiss(animated: true, completion: completion)
	}
}

extension BF_ViewController : UIGestureRecognizerDelegate {
	
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		
		return true
	}
}
