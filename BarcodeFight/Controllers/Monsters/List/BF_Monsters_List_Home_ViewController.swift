//
//  BF_Monsters_List_Home_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 03/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_List_Home_ViewController : BF_Monsters_List_ViewController {
	
	public override var monsters:[BF_Monster]? {
		
		didSet {
			
			updateNavigationItems()
			
			let state = monsters?.isEmpty ?? true
			
			if state {
				
				let placeholder = collectionView.showPlaceholder(.Empty)
				placeholder.contentStackView.addArrangedSubview(BF_Button(String(key: "monsters.placeholder.button")) { _ in
					
					BF_Scan.scan()
				})
			}
		}
	}
	private lazy var scanButton:BF_Menu_Button_StackView = {
		
		$0.color = Colors.Button.Primary.Background
		$0.image = UIImage(named: "scan_icon")
		$0.title = String(key: "menu.scan.title")
		$0.handler = { _ in
			
			BF_Scan.scan()
		}
		return $0
		
	}(BF_Menu_Button_StackView())
	private lazy var battleButton:BF_Menu_Button_StackView = {
		
		$0.color = Colors.Button.Secondary.Background
		$0.image = UIImage(named: "battle_icon")
		$0.title = String(key: "menu.fight.title")
		$0.handler = { _ in
			
			BF_Fight.new()
		}
		return $0
		
	}(BF_Menu_Button_StackView())
	private lazy var storyButton:BF_Menu_Button_StackView = {
		
		$0.color = Colors.Button.Secondary.Background
		$0.image = UIImage(named: "map_icon")
		$0.title = String(key: "menu.story.title")
		$0.handler = { _ in
		
			UI.MainController.present(BF_NavigationController(rootViewController: BF_Story_ViewController()), animated: true)
		}
		return $0
		
	}(BF_Menu_Button_StackView())
	private lazy var menuElementsStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins/2
		$0.alignment = .bottom
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		$0.setCustomSpacing(UI.Margins, after: userStackView)
		
		return $0
		
	}(UIStackView(arrangedSubviews: [userStackView,scanButton,battleButton,storyButton]))
	private lazy var editStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		$0.distribution = .fillProportionally
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		
		return $0
		
	}(UIStackView(arrangedSubviews: [selectAllButton,deleteButton]))
	private lazy var selectAllButton:BF_Button = {
		
		$0.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size-3)
		return $0
		
	}(BF_Button())
	private lazy var deleteButton:BF_Button = {
		
		$0.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size-3)
		$0.image = UIImage(systemName: "trash")?.applyingSymbolConfiguration(.init(scale: .small))
		$0.isDelete = true
		return $0
		
	}(BF_Button(){ [weak self] _ in
		
		self?.deleteAction()
	})
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.Home, self)
	private lazy var menuView:UIView = { view in
		
		let menuStackView:UIStackView = .init(arrangedSubviews: [menuElementsStackView,editStackView,bannerView].compactMap({ $0 }))
		menuStackView.axis = .vertical
		view.addSubview(menuStackView)
		menuStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		return view
		
	}(UIView())
	private lazy var userStackView:BF_User_StackView = .init()
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "monsters.navigation.title")
		
		let challengesView:BF_Challenges_View = .init()
		stackView.addArrangedSubview(challengesView)
		
		stackView.addArrangedSubview(collectionView)
		
		//collectionView.contentInset.top = 2*UI.Margins
		collectionView.register(BF_Monsters_Add_CollectionViewCell.self, forCellWithReuseIdentifier: BF_Monsters_Add_CollectionViewCell.identifier)
		collectionView.register(BF_Monsters_Empty_CollectionViewCell.self, forCellWithReuseIdentifier: BF_Monsters_Empty_CollectionViewCell.identifier)
		collectionView.addGestureRecognizer(UILongPressGestureRecognizer(block: { [weak self] gesture in
			
			if gesture.state == .began {
				
				let state = !(self?.isEditing ?? false)
				
				UIApplication.feedBack(state ? .On : .Off)
				
				self?.isEditing = state
				
			}
		}))
		
		stackView.setCustomSpacing(-2*UI.Margins, after: collectionView)
		stackView.addArrangedSubview(menuView)
		
		let menuElementsVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		menuElementsStackView.insertSubview(menuElementsVisualEffectView, at: 0)
		menuElementsVisualEffectView.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(2*UI.Margins)
			make.left.right.equalToSuperview()
			make.bottom.equalTo(view)
		}
		
		let editVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		editStackView.insertSubview(editVisualEffectView, at: 0)
		editVisualEffectView.snp.makeConstraints { make in
			make.top.left.right.equalToSuperview()
			make.bottom.equalTo(view)
		}
		
		NotificationCenter.add(.updateAccount) { [weak self] _ in
			
			self?.userStackView.user = BF_User.current
		}
		
		NotificationCenter.add(.updateMonsters) { [weak self] _ in
			
			self?.launchRequest()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		launchRequest()
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		let sourceViews = [userStackView,scanButton,battleButton,storyButton]
		
		let viewController:BF_Tutorial_ViewController = .init()
		viewController.key = .homeTutorial
		viewController.items = sourceViews.compactMap({
			
			if let index = sourceViews.firstIndex(of: $0) {
				
				return BF_Tutorial_ViewController.Item(sourceView: $0,
													   title: String(key: "tutorial.home.\(index).title"),
													   subtitle: String(key: "tutorial.home.\(index).subtitle"),
													   button: String(key: "tutorial.home.\(index).button"))
			}
			
			return nil
		})
		viewController.present()
	}
	
	public override func setEditing(_ editing: Bool, animated: Bool) {
		
		super.setEditing(editing, animated: animated)
		
		collectionView.reloadData()
		
		menuElementsStackView.isHidden = editing
		editStackView.isHidden = !editing
		stackView.layoutIfNeeded()
		
		updateEditButtons()
		
		collectionView.visibleCells.forEach({
			
			if let cell = $0 as? BF_Monsters_CollectionViewCell {
				
				isEditing ? cell.jiggle(isRepeat: true, duration: 0.15) : cell.layer.removeAllAnimations()
			}
		})
	}
	
	public override func updateNavigationItems() {
		
		let itemsButton:BF_Button = .init(String(key: "monsters.items.button")) { _ in
			
			UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_ViewController()), animated: true)
		}
		itemsButton.style = .transparent
		itemsButton.isText = true
		itemsButton.image = UIImage(named: "items_icon")
		itemsButton.titleFont = Fonts.Navigation.Button
		itemsButton.configuration?.contentInsets = .zero
		itemsButton.configuration?.imagePadding = UI.Margins/2
		
		let shopButton:BF_Button = .init(String(key: "monsters.shop.button")) { _ in
			
			UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
		}
		shopButton.style = .transparent
		shopButton.isText = true
		shopButton.image = UIImage(named: "shop_icon")
		shopButton.titleFont = Fonts.Navigation.Button
		shopButton.configuration?.contentInsets = .zero
		shopButton.configuration?.imagePadding = UI.Margins/2
		
		navigationItem.leftBarButtonItems = [.init(customView: itemsButton),.init(customView: shopButton)]
		
		navigationItem.rightBarButtonItems = .init()
		
		if !(monsters?.isEmpty ?? true) {
			
			let settingsButton:BF_Button = .init(String(key: "monsters.actions.button"))
			settingsButton.showsMenuAsPrimaryAction = true
			settingsButton.menu = UIMenu(children: [
				
				sortMenu,
				UIAction(title:String(key:"monsters.actions.edit.button"), image: UIImage(systemName: "slider.horizontal.3"), handler: { [weak self] _ in
					
					self?.isEditing = !(self?.isEditing ?? false)
				})
			])
			settingsButton.style = .transparent
			settingsButton.isText = true
			settingsButton.image = UIImage(named: "settings_icon")
			settingsButton.titleFont = Fonts.Navigation.Button
			settingsButton.configuration?.contentInsets = .zero
			settingsButton.configuration?.imagePadding = UI.Margins/2
			navigationItem.rightBarButtonItems?.append(.init(customView: settingsButton))
		}
		
		let infosButton:BF_Button = .init(String(key: "Infos"))
		infosButton.showsMenuAsPrimaryAction = true
		infosButton.menu = UIMenu(children: [
			
			UIMenu(title: "", options: .displayInline, children: [
				UIAction(title:String(key:"monsters.actions.news"), image: UIImage(systemName: "newspaper.fill"), handler: { _ in
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_News_ViewController()), animated: true)
				})
			]),
			UIMenu(title: "", options: .displayInline, children: [
				UIAction(title:String(key:"monsters.actions.account"), image: UIImage(systemName: "person.crop.circle"), handler: { _ in
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Account_Infos_ViewController()), animated: true)
				})
			]),
			UIMenu(title: "", options: .displayInline, children: [
				UIAction(title:String(key:"monsters.actions.ranking"), image: UIImage(systemName: "list.number"), handler: { _ in
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Account_Ranking_ViewController()), animated: true)
				}),
				UIAction(title:String(key:"monsters.actions.fights"), image: UIImage(systemName: "figure.kickboxing"), handler: { _ in
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Account_Fights_ViewController()), animated: true)
				})
			]),
			UIMenu(title: "", options: .displayInline, children: [
				UIAction(title:String(key:"monsters.actions.list"), image: UIImage(systemName: "square.grid.3x3"), handler: { _ in
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Monsters_List_Products_ViewController()), animated: true)
				}),
				UIAction(title:String(key:"monsters.actions.map"), image: UIImage(systemName: "map"), handler: { _ in
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Monsters_Locations_ViewController()), animated: true)
				})
			])
		])
		infosButton.style = .transparent
		infosButton.isText = true
		infosButton.image = UIImage(named: "infos_icon")
		infosButton.titleFont = Fonts.Navigation.Button
		infosButton.configuration?.contentInsets = .zero
		infosButton.configuration?.imagePadding = UI.Margins/2
		navigationItem.rightBarButtonItems?.append(.init(customView: infosButton))
		
		NotificationCenter.add(.updateNews) { _ in
			
			BF_News.getUnreadCount { count in
				
				if count > 0 {
					
					infosButton.badge = "\(count)"
				}
			}
		}
		
		NotificationCenter.post(.updateNews)
	}
	
	private func launchRequest() {
		
		updateNavigationItems()
		
		view.showPlaceholder(.Loading)
		
		BF_User.get { [weak self] error in
			
			self?.view.dismissPlaceholder()
			
			if let error = error {
				
				self?.view.showPlaceholder(.Error,error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.launchRequest()
				}
			}
			else {
				
				NotificationCenter.post(.updateAccount)
				self?.monsters = BF_User.current?.monsters.sort(self?.sort ?? .Date)
			}
		}
	}
	
	private func updateEditButtons() {
		
		selectAllButton.title = String(key: "monsters.edit.selectAll.button")
		
		if !(monsters?.isEmpty ?? true) {
			
			selectAllButton.isEnabled = true
			selectAllButton.title = String(key: "monsters.edit.selectAll.button") + " (\(monsters?.count ?? 0))"
			selectAllButton.action = { [weak self] _ in
				
				self?.selectAllAction(true)
			}
		}
		
		deleteButton.isEnabled = false
		deleteButton.title = String(key: "monsters.edit.delete.button")
		
		let count = collectionView.indexPathsForSelectedItems?.count ?? 0
		
		if count != 0 {
			
			selectAllButton.isEnabled = true
			selectAllButton.title = String(key: "monsters.edit.selectNone.button") + " (\(count))"
			selectAllButton.action = { [weak self] _ in
				
				self?.selectAllAction(false)
			}
			
			deleteButton.isEnabled = true
			deleteButton.title = String(key: "monsters.edit.delete.button") + " (\(count))"
		}
	}
	
	private func selectAllAction(_ state:Bool) {
		
		var indexPaths:[IndexPath] = .init()
		
		for section in 0..<collectionView.numberOfSections {
			
			for item in 0..<collectionView.numberOfItems(inSection: section) {
				
				if item < monsters?.count ?? 0 {
					
					indexPaths.append(.init(item: item, section: section))
				}
			}
		}
		
		indexPaths.forEach({
			
			if state {
				
				collectionView.selectItem(at: $0, animated: true, scrollPosition: .centeredVertically)
			}
			else {
				
				collectionView.deselectItem(at: $0, animated: true)
			}
		})
		
		updateEditButtons()
	}
	
	private func deleteAction() {
		
		let selectedMonsters = collectionView.indexPathsForSelectedItems?.compactMap({ monsters?[$0.item] })
		if !(selectedMonsters?.isEmpty ?? true) {
			
			BF_Monsters_Delete_Alert_ViewController(selectedMonsters).present()
		}
	}
}

extension BF_Monsters_List_Home_ViewController {
	
	public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		return !collectionView.isEditing ? (BF_Firebase.shared.config.int(.MaxMonstersCount)
											+ (BF_User.current?.monstersPlaces ?? 0)
											+ (collectionView.isEditing ? 0 : 1)) : super.collectionView(collectionView, numberOfItemsInSection: section)
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
		if let cell = cell as? BF_Monsters_CollectionViewCell {
			
			isEditing ? cell.jiggle(isRepeat: true, duration: 0.15) : cell.layer.removeAllAnimations()
		}
	}
	
	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if !collectionView.isEditing {
		
			if indexPath.row < monsters?.count ?? 0 {
				
				let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
				isEditing ? cell.jiggle(isRepeat: true, duration: 0.15) : cell.layer.removeAllAnimations()
				return cell
			}
			else if indexPath.row < BF_Firebase.shared.config.int(.MaxMonstersCount) + (BF_User.current?.monstersPlaces ?? 0) {
				
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BF_Monsters_Empty_CollectionViewCell.identifier, for: indexPath) as! BF_Monsters_Empty_CollectionViewCell
				return cell
			}
			else {
				
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BF_Monsters_Add_CollectionViewCell.identifier, for: indexPath) as! BF_Monsters_Add_CollectionViewCell
				return cell
			}
		}
		
		return super.collectionView(collectionView, cellForItemAt: indexPath)
	}
	
	public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		if !collectionView.isEditing {
			
			if indexPath.row < monsters?.count ?? 0 {
				
				super.collectionView(collectionView, didSelectItemAt: indexPath)
			}
			else if indexPath.row < BF_Firebase.shared.config.int(.MaxMonstersCount) + (BF_User.current?.monstersPlaces ?? 0) {
				
				BF_Scan.scan()
			}
			else {
				
				UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
			}
		}
		else {
			
			UIApplication.feedBack(.On)
			
			updateEditButtons()
		}
	}
	
	public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		
		super.collectionView(collectionView, didDeselectItemAt: indexPath)
		
		if collectionView.isEditing {
			
			updateEditButtons()
		}
	}
}
