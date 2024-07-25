//
//  String_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 18/03/2023.
//

import Foundation
import UIKit
import CryptoKit

extension String {
	
	init(key:String) {
		
		self = NSLocalizedString(key, comment:"localizable string")
	}
	
	public static var randomBarCode:String {
		
		return String(Int.random(in: 100000000000...999999999999))
	}
	
	public var isValidEmail: Bool {
		
		let string:String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	public var isValidPassword: Bool {
		
		return isValidPasswordMinCharacters && isValidPasswordLowercaseCharacter && isValidPasswordUppercaseCharacter && isValidPasswordSpecialCharacter && isValidPasswordNumericCharacter
	}
	
	public var isValidPasswordMinCharacters: Bool {
		
		return count >= 8 && count <= 40
	}
	
	public var isValidPasswordLowercaseCharacter: Bool {
		
		let string:String = ".*[a-z]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	public var isValidPasswordUppercaseCharacter: Bool {
		
		let string:String = ".*[A-Z]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	public var isValidPasswordSpecialCharacter: Bool {
		
		let string:String = ".*[-_!/@#$%^&*(),.?\":{}]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	public var isValidPasswordNumericCharacter: Bool {
		
		let string:String = ".*[0-9]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	static public var randomNonce:String {
		
		let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		var result = ""
		var remainingLength = 32
		
		while remainingLength > 0 {
			let randoms: [UInt8] = (0 ..< 16).map { _ in
				var random: UInt8 = 0
				let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
				if errorCode != errSecSuccess {
					fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
				}
				return random
			}
			
			randoms.forEach { random in
				if remainingLength == 0 {
					return
				}
				
				if random < charset.count {
					result.append(charset[Int(random)])
					remainingLength -= 1
				}
			}
		}
		
		return result
	}
	
	public var sha256:String {
		
		let inputData = Data(self.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString = hashedData.compactMap {
			return String(format: "%02x", $0)
		}.joined()
		
		return hashString
	}
	
	public var isValidDisplayName:Bool {
		
		return count >= 5
	}
	
	static var randomPassword:String {
		
		return String((0..<Int.random(in: 8...40)).compactMap{ _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!&^%$#@()/".randomElement() })
	}
}
