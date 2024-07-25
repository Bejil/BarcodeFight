//
//  BF_Onboarding_Game_Page_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/05/2024.
//

import Foundation
import UIKit

public class BF_Onboarding_Game_Page_ViewController : BF_ViewController {
	
	public var dataSource:[(String,String,String)] = [
		("onboarding.game.0.title","scan_icon","onboarding.game.0.content"),
		("onboarding.game.1.title","items_place","onboarding.game.1.content"),
		("onboarding.game.2.title","battle_icon","onboarding.game.2.content"),
	]
	public var currentIndex:Int = 0
	private lazy var pageControl:UIPageControl = {
		
		$0.numberOfPages = dataSource.count
		$0.currentPage = currentIndex
		$0.isUserInteractionEnabled = false
		return $0
		
	}(UIPageControl())
	private lazy var pageViewController:UIPageViewController = {
		
		$0.dataSource = self
		$0.delegate = self
		return $0
		
	}(UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal))
	
	public override func loadView() {
		
		super.loadView()
		
		navigationController?.navigationBar.prefersLargeTitles = false
		
		isModal = true
		
		addChild(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.didMove(toParent: self)
		pageViewController.view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		view.addSubview(pageControl)
		pageControl.snp.makeConstraints { make in
			make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		setViewController(for: currentIndex)
		
		let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), primaryAction: .init(handler: { [weak self] _ in
			
			self?.setViewController(for: (self?.currentIndex ?? 0)+1)
		}))
		let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: .init(handler: { [weak self] _ in
			
			self?.setViewController(for: (self?.currentIndex ?? 0)-1, withDirection: .reverse)
		}))
		
		navigationItem.rightBarButtonItems = [nextButton,previousButton]
		updateRightBarButtonItems()
	}
	
	private func setViewController(for index:Int, withDirection direction:UIPageViewController.NavigationDirection = .forward) {
		
		let viewControllers = [detailViewController(at: index)].compactMap({ $0 })
		pageViewController.setViewControllers(viewControllers, direction: direction, animated: true)
		pageViewController(pageViewController, didFinishAnimating: true, previousViewControllers: viewControllers, transitionCompleted: true)
	}
	
	private func detailViewController(at index:Int) -> BF_Onboarding_Game_Detail_ViewController? {
		
		if index >= 0 && index < dataSource.count {
			
			currentIndex = index
			
			let viewController:BF_Onboarding_Game_Detail_ViewController = .init()
			viewController.index = currentIndex
			viewController.placeholderView.title = String(key: dataSource[currentIndex].0)
			viewController.placeholderView.image = UIImage(named: dataSource[currentIndex].1)
			
			let label = viewController.placeholderView.addLabel(String(key: dataSource[currentIndex].2))
			label.font = Fonts.Content.Text.Regular.withSize(Fonts.Size+2)
			
			if currentIndex == dataSource.count - 1 {
				
				viewController.placeholderView.addButton(String(key: "onboarding.game.start.button")) { [weak self] _ in
					
					self?.dismiss()
				}
			}
			
			return viewController
		}
		
		return nil
	}
	
	private func updateRightBarButtonItems() {
		
		let index = (pageViewController.viewControllers?.first as? BF_Onboarding_Game_Detail_ViewController)?.index ?? 0
		navigationItem.rightBarButtonItems?.first?.isEnabled = index < dataSource.count - 1
		navigationItem.rightBarButtonItems?.last?.isEnabled = index > 0
	}
}

extension BF_Onboarding_Game_Page_ViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		return detailViewController(at: ((pageViewController.viewControllers?.last as? BF_Onboarding_Game_Detail_ViewController)?.index ?? 0)-1)
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		return detailViewController(at: ((pageViewController.viewControllers?.last as? BF_Onboarding_Game_Detail_ViewController)?.index ?? 0)+1)
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		
		updateRightBarButtonItems()
		
		let viewController = pageViewController.viewControllers?.first as? BF_Onboarding_Game_Detail_ViewController
		let index = viewController?.index ?? 0
		pageControl.currentPage = index
	}
}
