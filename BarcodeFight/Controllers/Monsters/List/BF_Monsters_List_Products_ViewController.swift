//
//  BF_Monsters_List_Products_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/07/2024.
//

import Foundation
import UIKit

public class BF_Monsters_List_Products_ViewController : BF_Monsters_List_ViewController {
	
	public override var sortMenu:UIMenu {
		
		let lc_sortMenu = super.sortMenu
		
		var children = lc_sortMenu.children
		children.removeFirst()
		children.removeLast()
		children.removeLast()
		
		return .init(title: lc_sortMenu.title, image: lc_sortMenu.image, children: children)
	}
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "Liste des monstres")
		
		let buttonView:UIView = .init()
		buttonView.addLine(position: .bottom)
		
		let button:BF_Button = .init(String(key: "Géolocaliser")) { [weak self] _ in
			
			let viewController:BF_Monsters_Locations_ViewController = .init()
			viewController.monsters = self?.monsters?.filter({ $0.location != nil })
			UI.MainController.present(viewController, animated: true)
		}
		buttonView.addSubview(button)
		button.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		
		stackView.insertArrangedSubview(buttonView, at: 0)
		
		launchRequest()
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_Monster.getAllWithProduct { [weak self] monsters, error in
			
			self?.view.dismissPlaceholder()
			
			if let error {
				
				self?.view.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					
					self?.launchRequest()
				}
			}
			else {
				
				self?.sort = .Rank
				self?.monsters = monsters?.filter({ ($0.product?.name != nil || $0.product?.picture != nil) && $0.location != nil }).sort(.Rank)
				self?.sortBarButtonItem.menu = self?.sortMenu
			}
		}
	}
}
