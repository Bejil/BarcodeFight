//
//  BF_Toss_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 17/01/2025.
//

import Foundation
import UIKit

public class BF_Toss_ViewController: BF_ViewController {
	
	public var completion:(()->Void)?
	private var currentstate = Bool.random()
	public var endState:Bool = Bool.random()
	public var isAuto:Bool = true {
		
		didSet {
			
			subtitleLabel.isHidden = isAuto
		}
	}
	private lazy var coinImageView:BF_ImageView = {
		
		$0.isUserInteractionEnabled = true
		$0.contentMode = .scaleAspectFit
		$0.alpha = 0.0
		$0.transform = .init(scaleX: 2.5, y: 2.5)
		$0.snp.makeConstraints { make in
			make.size.equalTo(10*UI.Margins)
		}
		return $0
		
	}(BF_ImageView())
	private lazy var titleLabel: BF_Label = {
		
		$0.font = Fonts.Content.Title.H1.withSize(Fonts.Size + 30)
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(BF_Label(String(key: "fights.toss.title")))
	private lazy var subtitleLabel: BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(BF_Label(String(key: "fights.toss.subtitle")))
	private lazy var stackView:UIStackView = {
		
		let coinView:UIView = .init()
		coinView.addSubview(coinImageView)
		coinImageView.snp.makeConstraints { make in
			
			make.edges.equalToSuperview().inset(2*UI.Margins)
		}
		
		$0.insertArrangedSubview(coinView, at: 0)
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		$0.alpha = 0
		return $0
		
	}(UIStackView(arrangedSubviews: [titleLabel,subtitleLabel]))
	private var timer:Timer?
	
	deinit {
		
		timer?.invalidate()
		timer = nil
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .overCurrentContext
		modalTransitionStyle = .crossDissolve
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
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
		
		var transform = CGAffineTransform.identity
		transform = transform.translatedBy(x: 0, y: -500)
		transform = transform.scaledBy(x: 10, y: 10)
		stackView.transform = transform
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
		}
		
		updateCoinImage(currentstate)
		
		UIApplication.wait { [weak self] in
			
			self?.stackView.alpha = 1.0
			self?.stackView.transform = .identity
			
			UIView.animate(0.5, { [weak self] in
				
				self?.coinImageView.alpha = 1.0
				self?.coinImageView.transform = .identity
				
			}, { [weak self] in
				
				UIApplication.feedBack(.Success)
				
				UIApplication.wait(0.15, { [weak self] in
					
					self?.coinImageView.pulse(.white)
					
					UIApplication.feedBack(.Success)
					
					if (self?.isAuto ?? true) {
						
						UIApplication.wait(1.5, { [weak self] in
							
							self?.launchToss()
						})
					}
					else {
						
						self?.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
							
							self?.coinImageView.pulse(.white)
						}
						
						let swipeGestureRecognizer:UISwipeGestureRecognizer = .init(block: { [weak self] _ in
							
							self?.launchToss()
						})
						swipeGestureRecognizer.direction = .up
						self?.coinImageView.addGestureRecognizer(swipeGestureRecognizer)
					}
				})
			})
		}
	}
	
	private func launchToss() {
		
		timer?.invalidate()
		timer = nil
		
		let flipAnimation = CATransition()
		flipAnimation.type = CATransitionType(rawValue: "flip")
		flipAnimation.subtype = .fromTop
		flipAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		flipAnimation.duration = 0.1
		
		var flips = 10
		
		updateCoinImage(currentstate)
		
		UIApplication.feedBack(.Success)
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
			
			self?.titleLabel.isHidden = true
			self?.titleLabel.alpha = 0.0
			
			self?.subtitleLabel.isHidden = true
			self?.subtitleLabel.alpha = 0.0
			
			self?.stackView.layoutIfNeeded()
			
			self?.coinImageView.transform = .init(scaleX: 2.25, y: 2.25).concatenating(.init(translationX: 0, y: -7*UI.Margins))
			
		}, completion: { _ in
			
			UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
				
				self?.coinImageView.transform = .identity
				
				let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
				shadowOffsetAnimation.fromValue = self?.coinImageView.layer.shadowOffset ?? .zero
				shadowOffsetAnimation.toValue = CGSize(width: 0, height: UI.Margins/2)
				shadowOffsetAnimation.duration = 0.5
				shadowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				self?.coinImageView.layer.add(shadowOffsetAnimation, forKey: "shadowOffsetAnimation")
				
				let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
				shadowRadiusAnimation.fromValue = self?.coinImageView.layer.shadowRadius ?? 0.0
				shadowRadiusAnimation.toValue = UI.Margins/5
				shadowRadiusAnimation.duration = 0.5
				shadowRadiusAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				self?.coinImageView.layer.add(shadowRadiusAnimation, forKey: "shadowRadiusAnimation")
			})
		})
		
		Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { [weak self] timer in
			
			UIApplication.feedBack(.On)
			
			self?.coinImageView.layer.add(flipAnimation, forKey: nil)
			
			self?.currentstate.toggle()
			
			self?.updateCoinImage(self?.currentstate ?? false)
			
			flips -= 1
			
			if flips == 0 {
				
				timer.invalidate()
				
				self?.updateCoinImage(self?.endState ?? false)
				
				self?.coinImageView.pulse(.white)
				
				UIApplication.feedBack(.Success)
				
				UIApplication.wait(0.15) { [weak self] in
					
					self?.coinImageView.pulse(.white)
					
					UIApplication.feedBack(.Success)
					
					UIApplication.wait(1.0) { [weak self] in
						
						UIView.animate(1.5, { [weak self] in
							
							self?.coinImageView.alpha = 0.0
						})
						
						self?.close()
						self?.completion?()
					}
				}
			}
		}
	}
	
	private func updateCoinImage(_ state:Bool) {
		
		coinImageView.image = UIImage(named: state ? "coins_on" : "coins_off")
	}
}
