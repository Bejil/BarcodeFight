//
//  BF_Monsters_Details_Add_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 11/08/2023.
//

import Foundation
import UIKit

public class BF_Monsters_Details_Add_ViewController : BF_Monsters_Details_ViewController {
	
	public override var monster: BF_Monster? {
		
		didSet {
			
			BF_User.current?.scanAvailable -= 1
			BF_User.current?.scanCount += 1
			BF_Challenge.increase(Challenges.Scans)
			
			if let monster = monster, !(BF_User.current?.monsters.contains(monster) ?? true) {
				
				BF_User.current?.updateAndAddExperience(BF_Firebase.shared.config.int(.ExperienceMonsterScan))
				
				button.isHidden = false
				
				UIApplication.wait {
					
					BF_Confettis.start()
				}
				
				UIApplication.wait(5.0) {
					
					BF_Confettis.stop()
				}
			}
			else {
				
				BF_User.current?.update(nil)
				
				BF_Toast_Manager.shared.addToast(title: String(key: "monsters.add.toast.title"), subtitle: String(key: "monsters.add.toast.subtitle"), style: .Warning)
			}
		}
	}
	private lazy var button:BF_Button = {
		
		$0.isHidden = true
		return $0
		
	}(BF_Button(String(key: "monsters.add.button")) { [weak self] button in
		
		self?.monster?.add({ [weak self] in
			
			self?.dismiss({
				
				BF_Authorizations.shared.askIfNeeded(.notifications, nil)
			})
		})
	})
	
	public override func loadView() {
		
		super.loadView()
		
		let buttonView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		buttonView.contentView.addSubview(button)
		button.snp.makeConstraints { make in
			make.edges.equalTo(buttonView.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		let stackView:UIStackView = .init(arrangedSubviews: [scrollView,buttonView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		BF_Confettis.stop()
	}
}
