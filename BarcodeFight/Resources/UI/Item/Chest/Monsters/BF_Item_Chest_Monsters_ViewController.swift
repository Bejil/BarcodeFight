//
//  BF_Item_Chest_Monsters_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/09/2024.
//

import Foundation
import UIKit

public class BF_Item_Chest_Monsters_ViewController : BF_ViewController {
	
	public var monsters:[BF_Monster]? {
		
		didSet {
			
			if oldValue == nil {
				
				monstersStackView.arrangedSubviews.forEach({
					
					$0.removeFromSuperview()
				})
				
				monsters?.forEach({
					
					let containerView:UIView = .init()
					monstersStackView.addArrangedSubview(containerView)
					containerView.snp.makeConstraints { make in
						make.width.equalTo(scrollView)
					}
					
					let contentVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
					contentVisualEffectView.layer.cornerRadius = 5*UI.CornerRadius
					contentVisualEffectView.clipsToBounds = true
					containerView.addSubview(contentVisualEffectView)
					contentVisualEffectView.snp.makeConstraints { make in
						make.top.bottom.equalToSuperview()
						make.left.right.equalToSuperview()
					}
					
					let contentScrollView = UIScrollView()
					contentVisualEffectView.contentView.addSubview(contentScrollView)
					contentScrollView.snp.makeConstraints { make in
						make.edges.equalToSuperview().inset(UI.Margins)
					}
					
					let monsterStackView:BF_Monsters_Full_StackView = .init()
					monsterStackView.monster = $0
					contentScrollView.addSubview(monsterStackView)
					monsterStackView.snp.makeConstraints { make in
						make.top.bottom.equalToSuperview().inset(UI.Margins)
						make.leading.trailing.width.equalToSuperview().inset(UI.Margins)
						make.height.equalToSuperview().priority(700)
					}
				})
				
				scrollView.delegate?.scrollViewDidScroll?(scrollView)
				
				button.isHidden = monsters?.isEmpty ?? true
			}
			
			pageControl.numberOfPages = monsters?.count ?? 0
		}
	}
	private lazy var monstersStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .center
		return $0
		
	}(UIStackView())
	private lazy var scrollView:UIScrollView = {
		
		$0.delegate = self
		$0.clipsToBounds = false
		$0.isPagingEnabled = true
		$0.showsHorizontalScrollIndicator = false
		$0.addSubview(monstersStackView)
		monstersStackView.snp.makeConstraints { make in
			make.edges.height.equalToSuperview()
		}
		return $0
		
	}(UIScrollView())
	private lazy var pageControl:UIPageControl = {
		
		$0.currentPage = 0
		$0.addAction(.init(handler: { [weak self] _ in
			
			if let scrollView = self?.scrollView, let pageControl = self?.pageControl {
				
				scrollView.setContentOffset(.init(x: scrollView.frame.size.width * CGFloat(pageControl.currentPage), y: 0), animated: true)
			}
			
		}), for: .valueChanged)
		return $0
		
	}(UIPageControl())
	private lazy var button:BF_Button = .init(String(key: "monsters.add.button")) { [weak self] button in
		
		if let scrollView = self?.scrollView, let pageControl = self?.pageControl {
			
			let page = pageControl.currentPage
			
			if let monster = self?.monsters?[page] {
				
				button?.isLoading = true
				
				monster.add { [weak self] in
					
					button?.isLoading = false
					
					self?.monsters?.remove(at: page)
					
					if let monsterContainerView = self?.monstersStackView.arrangedSubviews[page] {
						
						button?.isLoading = true
						
						UIView.animate(0.3, { [weak self] in
							
							monsterContainerView.alpha = 0.0
							monsterContainerView.transform = .init(translationX: 0, y: -monsterContainerView.frame.size.height).concatenating(.init(scaleX: 0.8, y: 0.8))
							
						}, {
							
							UIView.animate(0.3, { [weak self] in
								
								monsterContainerView.isHidden = true
								monsterContainerView.superview?.layoutIfNeeded()
								
							}, {
								
								monsterContainerView.removeFromSuperview()
								scrollView.delegate?.scrollViewDidScroll?(scrollView)
								
								button?.isLoading = false
								
								if self?.monsters?.isEmpty ?? true {
									
									self?.dismiss()
								}
							})
						})
					}
				}
			}
		}
	}
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "chest.alert.title")
		
		let stackView:UIStackView = .init(arrangedSubviews: [scrollView,pageControl,button])
		stackView.axis = .vertical
		stackView.spacing = 2*UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
			make.left.right.equalTo(view.safeAreaLayoutGuide).inset(3*UI.Margins)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		BF_Confettis.start()
		
		button.isLoading = false
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		BF_Confettis.stop()
	}
}

extension BF_Item_Chest_Monsters_ViewController : UIScrollViewDelegate {
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let page = Int(max(0.0, round(scrollView.contentOffset.x / scrollView.bounds.width)))
		
		pageControl.currentPage = page
		
		if let stackView = scrollView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
			
			UIView.animate {
				
				for i in 0..<stackView.arrangedSubviews.count {
					
					let view = stackView.arrangedSubviews[i]
					
					if !view.isHidden {
						
						view.transform = i == page ? .identity : .init(scaleX: 0.85, y: 0.85)
						view.alpha = i == page ? 1.0 : 0.5
					}
				}
			}
		}
	}
}
