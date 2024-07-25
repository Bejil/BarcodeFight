//
//  BF_Monsters_Details_Page_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 24/05/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Details_Page_ViewController : BF_ViewController {
	
	public var monsters:[BF_Monster]?
	public var currentIndex:Int = 0
	private lazy var pageViewController:UIPageViewController = {
		
		$0.dataSource = self
		$0.delegate = self
		return $0
		
	}(UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal))
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.Monster, self)
	
	public override func loadView() {
		
		super.loadView()
		
		navigationController?.navigationBar.prefersLargeTitles = false
		
		isModal = true
		
		addChild(pageViewController)
		
		let stackView:UIStackView = .init(arrangedSubviews: [pageViewController.view])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.right.left.equalToSuperview()
			make.bottom.equalTo(view.safeAreaLayoutGuide)
		}
		
		if let bannerView {
			
			stackView.addArrangedSubview(bannerView)
		}
		
		pageViewController.didMove(toParent: self)
		
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
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}
	
	private func setViewController(for index:Int, withDirection direction:UIPageViewController.NavigationDirection = .forward) {
		
		let viewControllers = [detailViewController(at: index)].compactMap({ $0 })
		pageViewController.setViewControllers(viewControllers, direction: direction, animated: true)
		pageViewController(pageViewController, didFinishAnimating: true, previousViewControllers: viewControllers, transitionCompleted: true)
	}
	
	private func detailViewController(at index:Int) -> BF_Monsters_Details_ViewController? {
		
		if index >= 0 && index < monsters?.count ?? 0 {
			
			currentIndex = index
			
			let viewController:BF_Monsters_Details_ViewController = .init()
			viewController.index = currentIndex
			viewController.monster = monsters?[currentIndex]
			return viewController
		}
		
		return nil
	}
	
	private func updateRightBarButtonItems() {
		
		let index = (pageViewController.viewControllers?.first as? BF_Monsters_Details_ViewController)?.index ?? 0
		navigationItem.rightBarButtonItems?.first?.isEnabled = index < (monsters?.count ?? 0) - 1
		navigationItem.rightBarButtonItems?.last?.isEnabled = index > 0
	}
}

extension BF_Monsters_Details_Page_ViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		return detailViewController(at: ((pageViewController.viewControllers?.last as? BF_Monsters_Details_ViewController)?.index ?? 0)-1)
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		return detailViewController(at: ((pageViewController.viewControllers?.last as? BF_Monsters_Details_ViewController)?.index ?? 0)+1)
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		
		updateRightBarButtonItems()
	}
}
