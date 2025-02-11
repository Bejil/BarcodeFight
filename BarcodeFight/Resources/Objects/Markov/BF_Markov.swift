//
//  BF_Markov.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/06/2022.
//

import Foundation

public class BF_Markov {
	
	private var startBigrams = [Character: [Character]]()
	private var middleBigrams = [String: [Character]]()
	private var endBigrams = [String: [Character]]()
	private var names: [String] = []
	
	init() {
		
		loadNames()
		trainMarkovChain()
	}
	
	private func loadNames() {
		
		guard let path = Bundle.main.path(forResource: "BF_Markov", ofType: "txt") else {
			
			print("Failed to find the file")
			return
		}
		
		do {
			
			let content = try String(contentsOfFile: path, encoding: .utf8)
			names = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
		}
		catch {
			
			print("Failed to read the file")
		}
	}
	
	private func trainMarkovChain() {
		
		for name in names {
			
			let chars = Array(name.lowercased())
			if chars.count < 2 { continue }
			
			let startPair = chars[0]
			startBigrams[startPair, default: []].append(chars[1])
			
			for i in 0..<chars.count - 2 {
				
				let key = String(chars[i...i + 1])
				let nextChar = chars[i + 2]
				middleBigrams[key, default: []].append(nextChar)
			}
			
			let endKey = String(chars[chars.count - 2...chars.count - 1])
			endBigrams[endKey, default: []].append(chars.last!)
		}
	}
	
	public var randomName:String {
		
		var name = ""
		
		guard let start = startBigrams.keys.randomElement() else { return "" }
		name.append(start)
		guard let secondChar = startBigrams[start]?.randomElement() else { return String(start) }
		name.append(secondChar)
		
		while name.count < 8 {
			
			let lastTwoChars = String(name.suffix(2))
			
			if let nextChar = middleBigrams[lastTwoChars]?.randomElement() {
				
				name.append(nextChar)
				
				if name.count >= 4 {
					
					if Bool.random() && name.count > 4 { break }
				}
			}
			else {
				
				break
			}
		}
		
		return name.capitalized
	}
}
