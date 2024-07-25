//
//  LY_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 19/03/2023.
//

import Foundation
import UIKit

public class BF_ViewController: UIViewController {
	
	private lazy var closeButton:UIButton = {
		
		$0.setImage(UIImage(named: "close_icon"), for: .normal)
		$0.addAction(.init(handler: { [weak self] _ in
			
			UIApplication.feedBack(.On)
			self?.close()
			
		}), for: .touchUpInside)
		return $0
		
	}(UIButton())
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
					make.size.equalTo(UI.Margins*2)
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
		
		let monster:BF_Monster = .init()
		monster.element = .Lightness
		
		$0.monster = monster
		$0.alpha = 0.05
		
		return $0
		
	}(BF_Monsters_Particules_View())
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .fullScreen
		modalTransitionStyle = .coverVertical
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
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
