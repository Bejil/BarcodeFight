//
//  BF_Monsters_Stats_StackView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 09/09/2024.
//

import Foundation
import UIKit

public class BF_Monsters_Stats_StackView : UIStackView {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			let hp = monster?.stats.hp ?? Int(BF_Monster.Stats.range.lowerBound)
			hpProgressView.progress = Float(hp)/Float(BF_Monster.Stats.range.upperBound)
			hpProgressView.value = String(hp)
			
			let mp = monster?.stats.mp ?? Int(BF_Monster.Stats.range.lowerBound)
			mpProgressView.progress = Float(mp)/Float(BF_Monster.Stats.range.upperBound)
			mpProgressView.value = String(mp)
			
			let atk = monster?.stats.atk ?? Int(BF_Monster.Stats.range.lowerBound)
			atkProgressView.progress = Float(atk)/Float(BF_Monster.Stats.range.upperBound)
			atkProgressView.value = String(atk)
			
			let def = monster?.stats.def ?? Int(BF_Monster.Stats.range.lowerBound)
			defProgressView.progress = Float(def)/Float(BF_Monster.Stats.range.upperBound)
			defProgressView.value = String(def)
			
			let luk = monster?.stats.luk ?? Int(BF_Monster.Stats.range.lowerBound)
			lukProgressView.progress = Float(luk)/Float(BF_Monster.Stats.range.upperBound)
			lukProgressView.value = String(luk)
		}
	}
	private lazy var hpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "heart")
		$0.color = Colors.Monsters.Stats.Hp
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var mpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "wand.and.stars")
		$0.color = Colors.Monsters.Stats.Mp
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var atkProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "figure.boxing")
		$0.color = Colors.Monsters.Stats.Atk
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var defProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "shield.checkered")
		$0.color = Colors.Monsters.Stats.Def
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var lukProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "dice.fill")
		$0.color = Colors.Monsters.Stats.Luk
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/3
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(horizontal: 2*UI.Margins)
		addArrangedSubview(hpProgressView)
		addArrangedSubview(mpProgressView)
		addArrangedSubview(atkProgressView)
		addArrangedSubview(defProgressView)
		addArrangedSubview(lukProgressView)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
