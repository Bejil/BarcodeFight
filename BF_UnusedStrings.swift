//
//  FindUnusedLocalizedStrings.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/06/2024.
//

import Foundation

func keysUsedInCode(at path: String) -> Set<String> {
	
	var keys = Set<String>()
		// Example regex patterns to match common localization methods
	let patterns = [
		#"NSLocalizedString\("([^"]+)",\s*comment:"#,
		#"String\(key:\s*"([^"]+)"\)"#
	]
	
	do {
		let fileManager = FileManager.default
		let enumerator = fileManager.enumerator(atPath: path)
		
		while let element = enumerator?.nextObject() as? String {
			
			if element.hasSuffix(".swift") || element.hasSuffix(".m") || element.hasSuffix(".h") {
				
				let filePath = "\(path)/\(element)"
				let content = try String(contentsOfFile: filePath)
				
				for pattern in patterns {
					
					let regex = try NSRegularExpression(pattern: pattern, options: [])
					let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
					
					for match in matches {
						
						if let range = Range(match.range(at: 1), in: content) {
							
							let key = String(content[range])
							keys.insert(key)
						}
					}
				}
			}
		}
	} catch {
		
		print("Error: \(error)")
	}
	
	return keys
}

func keysInLocalizableStrings(at path: String) -> Set<String> {
	
	guard let stringsContent = try? String(contentsOfFile: path) else {
		
		return []
	}
	
	var keys = Set<String>()
	let lines = stringsContent.split(separator: "\n")
	
	lines.forEach({
		
		if let range = $0.range(of: "\"") {
			
			let parts = $0[range.upperBound...].split(separator: "\"")
			
			if !parts.isEmpty {
				
				keys.insert(String(parts[0]))
			}
		}
	})
	
	return keys
}

func main() {
	
	let projectPath = "/Users/mblin/Desktop/Git/BarcodeFight"
	let localizablePath = "/Users/mblin/Desktop/Git/BarcodeFight/BarcodeFight/Resources/Localizable.strings"
	
	let usedKeys = keysUsedInCode(at: projectPath)
	let allKeys = keysInLocalizableStrings(at: localizablePath)
	let unusedKeys = allKeys.subtracting(usedKeys).sorted(by: { $0 < $1 })
	
	if unusedKeys.isEmpty {
		
		print("\n#### NO UNUSED KEYS ####\n")
	}
	else {
		
		print("\n#### UNUSED KEYS ####\n\n\(unusedKeys.joined(separator: "\n"))")
	}
}

main()
