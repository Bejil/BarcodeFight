//
//  BF_Audio.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 23/06/2022.
//

import Foundation
import SwiftySound

public class BF_Audio : NSObject {
	
	public static let shared:BF_Audio = .init()
	
	public var isSoundsEnabled:Bool {
		
		return BF_User.current?.isSoundsEnabled ?? true
	}
	
	public var isMusicEnabled:Bool {
		
		return BF_User.current?.isMusicEnabled ?? true
	}
	
	private func play(_ name:String, _ loop:Bool? = false) {
		
		DispatchQueue.global(qos: .userInitiated).async {
			
			Sound.play(file: name + ".mp3", numberOfLoops: loop ?? false ? -1 : 0 )
		}
	}
	
	public func stop() {
		
		Sound.stopAll()
	}
	
	public func playMain() {
		
		if isMusicEnabled {
			
			stop()
			play("Main", true)
		}
	}
	
	public func playBattle() {
		
		if isMusicEnabled {
			
			stop()
			play("Battle", true)
		}
	}
	
	public func playImpact() {
		
		if isSoundsEnabled {
			
			play("Impact_\(Int.random(in: 1 ..< 14))")
		}
	}
	
	public func playDeath() {
		
		if isSoundsEnabled {
			
			play("Death_\(Int.random(in: 0 ..< 7))")
		}
	}
	
	public func playDodge() {
		
		if isSoundsEnabled {
			
			play("Dodge_\(Int.random(in: 0 ..< 8))")
		}
	}
	
	public func playSuccess() {
		
		if isSoundsEnabled {
			
			play("Success")
		}
	}
	
	public func playError() {
		
		if isSoundsEnabled {
			
			play("Error")
		}
	}
	
	public func playOn() {
		
		if isSoundsEnabled {
			
			play("On")
		}
	}
}
