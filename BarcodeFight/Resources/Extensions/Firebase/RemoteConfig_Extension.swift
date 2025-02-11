//
//  RemoteConfig_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import FirebaseRemoteConfig

extension RemoteConfig {
	
	public enum Keys : String {
		
		case LevelRewardScanNumber = "levelRewardScanNumber"
		case ExperienceMonsterScan = "experienceMonsterScan"
		case ExperienceMonsterEnrollment = "experienceMonsterEnrollment"
		case ExperienceFightVictory = "experienceFightVictory"
		case ExperienceFightDefeat = "experienceFightDefeat"
		case ExperienceFightDropout = "experienceFightDropout"
		case ExperienceFakeFightVictory = "experienceFakeFightVictory"
		case ExperienceFakeFightDefeat = "experienceFakeFightDefeat"
		case ExperienceFakeFightDropout = "experienceFakeFightDropout"
		case LevelRewardCoinsNumber = "levelRewardCoinsNumber"
		
		case RubiesFightCost = "rubiesFightCost"
		
		case FightMonstersCount = "fightMonstersCount"
		case MaxMonstersCount = "maxMonstersCount"
		case LiveOpponentDelay = "liveOpponentDelay"
	}
	
	public func int(_ key:Keys) -> Int {
		
		return configValue(forKey: key.rawValue).numberValue.intValue
	}
}
