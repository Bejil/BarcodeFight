//
//  BF_Battle_Fight_QTE_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 17/07/2024.
//

import Foundation
import UIKit

public class BF_Battle_Fight_QTE_ViewController: BF_ViewController {
	
	public var hitHandler:(()->Void)?
	public var completionHandler:(()->Void)?
	private var count:Int = 0
	private var success:Int = 0
	
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
		view.sendSubviewToBack(dimBackgroundView)
		dimBackgroundView.snp.makeConstraints { make in
			
			make.edges.equalToSuperview()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		showDimView(String(key: "fights.battle.limit.title")) { [weak self] in
			
			self?.displayQTE { [weak self] in
				
				self?.showDimView(String(key: "fights.battle.limit.\(self?.success ?? 0)")) { [weak self] in
					
					UI.MainController.dismiss(animated: true) { [weak self] in
						
						self?.completionHandler?()
					}
				}
			}
		}
	}
	
	private func displayQTE(_ completion:(()->Void)?) {
		
		count += 1
		
		let hitView:UIView = .init()
		hitView.alpha = 0.0
		view.addSubview(hitView)
		hitView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
		}
		
		hitView.layoutIfNeeded()
		
		let outterSize = max(view.frame.size.width, view.frame.size.height)
		let innerSize = 6*UI.Margins
		let margin = UI.Margins
		let randomPoint:CGPoint = .init(x: CGFloat.random(in: margin...hitView.frame.size.width-(2*margin)), y: CGFloat.random(in: margin...hitView.frame.size.height-(2*margin)))
		
		let hitOutterView:UIView = .init()
		hitOutterView.isUserInteractionEnabled = false
		hitOutterView.backgroundColor = .white.withAlphaComponent(0.1)
		hitOutterView.layer.cornerRadius = outterSize/2
		hitView.addSubview(hitOutterView)
		hitOutterView.snp.makeConstraints { make in
			make.center.equalTo(randomPoint)
			make.size.equalTo(outterSize)
		}
		
		let hitInnerView:UIView = .init()
		hitInnerView.isUserInteractionEnabled = false
		hitInnerView.backgroundColor = .white.withAlphaComponent(0.1)
		hitInnerView.layer.borderColor = UIColor.white.withAlphaComponent(0.75).cgColor
		hitInnerView.layer.borderWidth = UI.Margins/5
		hitInnerView.layer.cornerRadius = innerSize/2
		hitView.addSubview(hitInnerView)
		hitInnerView.snp.makeConstraints { make in
			make.center.equalTo(randomPoint)
			make.size.equalTo(innerSize)
		}
		
		hitView.layoutIfNeeded()
		
		UIView.animate {
			
			hitView.alpha = 1.0
		}
		
		var finishState = false
		
		let finishClosure:((Bool)->Void) = { [weak self] state in
			
			if !finishState {
				
				hitOutterView.removeFromSuperview()
				
				finishState = true
				
				let color = state ? Colors.Secondary : Colors.Primary
				
				hitInnerView.backgroundColor = color.withAlphaComponent(0.1)
				hitInnerView.layer.borderColor = color.withAlphaComponent(0.75).cgColor
				hitInnerView.pulse(color)
				
				UIApplication.feedBack(state ? .Success : .Error)
				
				hitView.isUserInteractionEnabled = false
				
				if state {
					
					self?.success += 1
					self?.hitHandler?()
				}
				
				if self?.count ?? 0 < 5 {
					
					self?.displayQTE(completion)
				}
				else {
					
					completion?()
				}
				
				UIView.animate(0.3, {
					
					hitView.alpha = 0
					hitInnerView.alpha = 0
					
				}, {
					
					hitView.removeFromSuperview()
					hitInnerView.removeFromSuperview()
				})
			}
		}
		
		UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut]) {
			
			hitOutterView.layer.cornerRadius = innerSize/4.0
			hitOutterView.snp.updateConstraints { (make) in
				make.size.equalTo(innerSize/2.0)
			}
			
			hitView.layoutIfNeeded()
			
		} completion: { _ in
			
			finishClosure(false)
		}
		
		hitView.addGestureRecognizer(UITapGestureRecognizer(block: { sender in
			
			let point = (sender as? UITapGestureRecognizer)?.location(in: hitView) ?? .zero
			let hitOutterViewWidth = hitOutterView.layer.presentation()?.bounds.size.width ?? 0.0
			let hitInnerViewWidth = hitInnerView.layer.presentation()?.bounds.size.width ?? 0.0
			let state = hitOutterViewWidth <= hitInnerViewWidth && hitInnerView.frame.contains(point)
			finishClosure(state)
		}))
	}
	
	private func showDimView(_ text:String?, _ endPause:TimeInterval = 0.5, _ completion:(()->Void)? = nil) {
		
		view.isUserInteractionEnabled = false
		
		let dimView:UIView = .init()
		dimView.alpha = 0.0
		view.addSubview(dimView)
		dimView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let dimBackgroundView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		dimView.addSubview(dimBackgroundView)
		dimBackgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let dimLabel:BF_Label = .init()
		dimLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Size+30)
		dimLabel.textColor = .white
		dimLabel.text = text
		dimLabel.textAlignment = .center
		dimLabel.alpha = 0.0
		dimLabel.transform = .init(scaleX: 10.0, y: 10.0)
		dimView.addSubview(dimLabel)
		dimLabel.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(2*UI.Margins)
		}
		
		UIView.animate(withDuration: 0.5, animations: {
			
			dimView.alpha = 1.0
			dimLabel.alpha = 1.0
			dimLabel.transform = .identity
			
		}) { _ in
			
			UIApplication.wait(endPause) {
				
				UIView.animate(0.3,{
					
					dimView.alpha = 0.0
					dimLabel.alpha = 0.0
					
				}, {
					
					dimLabel.removeFromSuperview()
					dimView.removeFromSuperview()
					
					self.view.isUserInteractionEnabled = true
					
					completion?()
				})
			}
		}
	}
}
