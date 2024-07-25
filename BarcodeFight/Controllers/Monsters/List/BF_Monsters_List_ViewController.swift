//
//  BF_Monsters_List_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 17/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_List_ViewController : BF_ViewController {
	
	public var monsters:[BF_Monster]? {
		
		didSet {
			
			isEditing = false
			
			updateNavigationItems()
			
			collectionView.dismissPlaceholder()
			collectionView.reloadData()
			
			if monsters?.isEmpty ?? true {
				
				collectionView.showPlaceholder(.Empty)
			}
		}
	}
	public var sort:[BF_Monster].Sort = .Date {
		
		didSet {
			
			monsters = monsters?.sort(sort)
			sortBarButtonItem.menu = sortMenu
		}
	}
	public lazy var sortBarButtonItem:UIBarButtonItem = .init(title: String(key: "monsters.sort.button"), menu: sortMenu)
	public var sortMenu:UIMenu {
		
		return .init(title: [String(key: "monsters.sort.title"),sort.name].joined(separator: " "), image: UIImage(systemName: "arrow.up.and.down.text.horizontal"), children: [[BF_Monster].Sort.Date,[BF_Monster].Sort.Name,[BF_Monster].Sort.Rank,[BF_Monster].Sort.Element].compactMap({ sort in
			
			UIAction(title: sort.name, handler: { [weak self] _ in
				
				self?.sort = sort
			})
			
		}) + [
			
			UIMenu(title: String(key: "monsters.sort.stats.button"), children: [[BF_Monster].Sort.StatsHp,[BF_Monster].Sort.StatsMp,[BF_Monster].Sort.StatsAtk,[BF_Monster].Sort.StatsDef,[BF_Monster].Sort.StatsLuk].compactMap({ sort in
				
				UIAction(title: sort.name, handler: { [weak self] _ in
					
					self?.sort = sort
				})
			})),
			UIMenu(title: String(key: "monsters.sort.status.button"), children: [[BF_Monster].Sort.StatusHp,[BF_Monster].Sort.StatusMp].compactMap({ sort in
				
				UIAction(title: sort.name, handler: { [weak self] _ in
					
					self?.sort = sort
				})
			})),
			UIMenu(title: String(key: "monsters.sort.fights.button"), children: [[BF_Monster].Sort.FightsVictories,[BF_Monster].Sort.FightsDefeats,[BF_Monster].Sort.FightsDropouts].compactMap({ sort in
				
				UIAction(title: sort.name, handler: { [weak self] _ in
					
					self?.sort = sort
				})
			}))
		])
	}
	public lazy var collectionViewLayout:UICollectionViewFlowLayout = {
		
		$0.scrollDirection = .vertical
		$0.sectionInset = .init(horizontal: UI.Margins)
		$0.minimumInteritemSpacing = UI.Margins
		return $0
		
	}(UICollectionViewFlowLayout())
	public lazy var collectionView:BF_CollectionView = {
		
		$0.register(BF_Monsters_CollectionViewCell.self, forCellWithReuseIdentifier: BF_Monsters_CollectionViewCell.identifier)
		$0.allowsMultipleSelectionDuringEditing = true
		$0.delegate = self
		$0.dataSource = self
		$0.contentInset.top = UI.Margins
		$0.contentInset.bottom = 2*UI.Margins
		return $0
		
	}(BF_CollectionView(frame: .zero, collectionViewLayout: collectionViewLayout))
	public lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		return $0
		
	}(UIStackView(arrangedSubviews: [collectionView]))
	
	public override func loadView() {
		
		super.loadView()
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.left.right.equalTo(view.safeAreaLayoutGuide)
			make.bottom.equalToSuperview()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		isEditing = false
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		isEditing = false
	}
	
	public override func setEditing(_ editing: Bool, animated: Bool) {
		
		super.setEditing(editing, animated: animated)
		
		updateNavigationItems()
		collectionView.isEditing = editing
	}
	
	public func updateNavigationItems() {
		
		sortBarButtonItem.isEnabled = !isEditing && (monsters?.count ?? 0 > 1)
		
		navigationItem.rightBarButtonItem = sortBarButtonItem
	}
}

extension BF_Monsters_List_ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		return monsters?.count ?? 0
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let viewLayout = collectionViewLayout as? UICollectionViewFlowLayout
		let leftInset = viewLayout?.sectionInset.left ?? UI.Margins
		let rightInset = viewLayout?.sectionInset.right ?? UI.Margins
		var space = viewLayout?.minimumInteritemSpacing ?? UI.Margins
		space = CGFloat(3-1)*space
		
		return .init(width: (collectionView.frame.size.width-(leftInset+rightInset+space))/CGFloat(3), height: 10*UI.Margins)
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BF_Monsters_CollectionViewCell.identifier, for: indexPath) as! BF_Monsters_CollectionViewCell
		cell.monster = monsters?[indexPath.item]
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		if !collectionView.isEditing {
			
			collectionView.deselectItem(at: indexPath, animated: false)
			
			let viewController:BF_Monsters_Details_Page_ViewController = .init()
			viewController.monsters = monsters
			viewController.currentIndex = indexPath.item
			UI.MainController.present(BF_NavigationController.init(rootViewController: viewController), animated: true)
		}
		
		UIApplication.feedBack(.On)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		
		UIApplication.feedBack(.Off)
	}
	
	public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
		
		if !collectionView.isEditing, let indexPath = indexPaths.first {
			
			return UIContextMenuConfiguration.init(identifier: indexPath as NSIndexPath, previewProvider: nil) { (suggestedActions) -> UIMenu? in
				
				let cell = collectionView.cellForItem(at: indexPath) as? BF_Monsters_CollectionViewCell
				return cell?.menu
			}
		}
		
		return nil
	}
}
