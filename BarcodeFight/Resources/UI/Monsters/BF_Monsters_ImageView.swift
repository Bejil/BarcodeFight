//
//  BF_Monsters_ImageView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_ImageView : BF_ImageView {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			animate(false)
			
			if let monster = monster {
				
				if monster.isDead {
					
					image = UIImage(named: "dead")
					image = image?.noir
					alpha = 0.25
					
					deadMonsterImageView.image = UIImage(named: monster.picture)?.withHorizontallyFlippedOrientation().noir
					deadMonsterImageView.isHidden = false
				}
				else {
					
					image = UIImage(named: monster.picture)?.withHorizontallyFlippedOrientation()
					alpha = 1.0
					
					animate(true)
					
					deadMonsterImageView.isHidden = true
				}
			}
		}
	}
	private var animationTimer:Timer?
	private lazy var deadMonsterImageView:BF_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		return $0
		
	}(BF_ImageView())
	
	deinit {
		
		animate(false)
	}
	
	init() {
		
		super.init(frame: .zero)
		
		contentMode = .scaleAspectFit
		
		addSubview(deadMonsterImageView)
		deadMonsterImageView.snp.makeConstraints { make in
			make.size.equalToSuperview().multipliedBy(0.4)
			make.center.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func animate(_ state:Bool) {
		
		layer.removeAllAnimations()
		
		if state {
			
			UIApplication.wait { [weak self] in
				
				self?.shakeAnimation()
				self?.pulseAnimation()
				self?.backAndForthAnimation()
				self?.jiggleAnimation()
			}
		}
	}
	
	private func jiggleAnimation() {
		
		let animation:CABasicAnimation = .init(keyPath: "transform.rotation")
		animation.duration = CGFloat.random(in: 0.25...0.35)
		animation.repeatCount = .greatestFiniteMagnitude
		animation.autoreverses = true
		
		let amplitude:Float = Float.random(in: 0.7...0.8)
		let r:Float = (Float(arc4random())/Float(RAND_MAX)) - 0.5
		let angleInDegrees:Float = amplitude * (1.0 + r * 0.1)
		let animationRotate:Float = angleInDegrees / 180.0 * .pi
		
		animation.fromValue = -animationRotate
		animation.toValue = animationRotate
		
		layer.add(animation, forKey: "jiggle")
	}
	
	private func shakeAnimation() {
		
		let shake = CABasicAnimation(keyPath: "position")
		shake.duration = CGFloat.random(in: 0.1...0.25)
		shake.repeatCount = .greatestFiniteMagnitude
		shake.autoreverses = true
		
		let fromPoint = CGPoint(x: center.x - CGFloat.random(in: 1.0...2.0), y: center.y - CGFloat.random(in: 1.0...2.0))
		let fromValue = NSValue(cgPoint: fromPoint)
		
		let toPoint = CGPoint(x: center.x + CGFloat.random(in: 1.0...2.0), y: center.y + CGFloat.random(in: 1.0...2.0))
		let toValue = NSValue(cgPoint: toPoint)
		
		shake.fromValue = fromValue
		shake.toValue = toValue
		
		layer.add(shake, forKey: "position")
	}
	
	private func pulseAnimation() {
		
		let pulse = CASpringAnimation(keyPath: "transform.scale")
		pulse.duration = CGFloat.random(in: 0.25...0.75)
		pulse.repeatCount = .greatestFiniteMagnitude
		pulse.autoreverses = true
		
		pulse.fromValue = 1.0
		pulse.toValue = CGFloat.random(in: 1.0...1.01)
		
		layer.add(pulse, forKey: "pulse")
	}
	
	private func backAndForthAnimation() {
		
		let move = CABasicAnimation(keyPath: "position")
		move.duration = CGFloat.random(in: 0.85...1.25)
		move.repeatCount = .greatestFiniteMagnitude
		move.autoreverses = true
		
		let fromPoint = CGPoint(x: center.x - CGFloat.random(in: 0.5...1.5), y: center.y)
		let fromValue = NSValue(cgPoint: fromPoint)
		
		let toPoint = CGPoint(x: center.x + CGFloat.random(in: 0.5...1.5), y: center.y)
		let toValue = NSValue(cgPoint: toPoint)
		
		move.fromValue = fromValue
		move.toValue = toValue
		
		layer.add(move, forKey: "position")
	}
}
