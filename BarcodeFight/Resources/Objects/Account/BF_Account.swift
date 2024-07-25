//
//  BF_Account.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 10/05/2023.
//

import Foundation
import Firebase
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import FirebaseStorage

public class BF_Account: NSObject {
	
	public enum SignInType : String {
		
		case Email = "password"
		case Apple = "apple.com"
		case Google = "google.com"
	}
	
	static public let shared:BF_Account = .init()
	public var user:User? {
		
		return Auth.auth().currentUser
	}
	public var isLoggedIn:Bool {
		
		return user != nil
	}
	private var addStateDidChangeListener:AuthStateDidChangeListenerHandle?
	public typealias Error_Completion = ((Error?) -> Void)?
	private var currentAppleSignInNonce:String?
	private var appleSignCompletion:((OAuthCredential?,Error?)->Void)?
	public var signInType:SignInType {
		
		if let providerId = user?.providerData.first?.providerID {
			
			return SignInType(rawValue: providerId) ?? .Email
		}
		
		return .Email
	}
	
	deinit {
		
		if let addStateDidChangeListener = addStateDidChangeListener {
			
			Auth.auth().removeStateDidChangeListener(addStateDidChangeListener)
		}
	}
	
	public func start() {
		
		addStateDidChangeListener = Auth.auth().addStateDidChangeListener { [weak self] auth, _ in
			
			self?.stateDidChange()
		}
	}
	
	private var items:[BF_Item]?
	
	public func stateDidChange() {
		
		if isLoggedIn {
			
			BF_User.get { error in
				
				let closure:(()->Void) = {
					
					NotificationCenter.post(.updateMonsters)
					NotificationCenter.post(.updateAccount)
					
					let dispatchGroup = DispatchGroup()
					
					var newScans:Int = 0
					dispatchGroup.enter()
					
					BF_Scan.shared.start { occurence in
						
						newScans = occurence
						dispatchGroup.leave()
					}
					
					var newrubies:Int = 0
					dispatchGroup.enter()
					
					BF_Ruby.shared.start { occurence in
						
						newrubies = occurence
						dispatchGroup.leave()
					}
					
					dispatchGroup.notify(queue: .main) { [weak self] in
						
						if newScans + newrubies > 0 {
							
							let alertController:BF_Alert_ViewController = .presentLoading()
							
							BF_Item.get { [weak self] items, error in
								
								alertController.close { [weak self] in
									
									self?.items = .init()
									
									if newScans > 0, let item = items?.first(where: { $0.uid == Items.Scan }) {
										
										for _ in 0..<newScans {
											
											self?.items?.append(item)
										}
									}
									
									if newrubies > 0, let item = items?.first(where: { $0.uid == Items.Rubies }) {
										
										for _ in 0..<newrubies {
											
											self?.items?.append(item)
										}
									}
									
									let alertController:BF_Alert_ViewController = .init()
									alertController.title = String(key: "account.rewards.off.alert.title")
									alertController.add(String(key: "account.rewards.off.alert.content"))
									
									let itemsTableView:BF_TableView = .init()
									itemsTableView.register(BF_Item_Object_TableViewCell.self, forCellReuseIdentifier: BF_Item_Object_TableViewCell.identifier)
									itemsTableView.delegate = self
									itemsTableView.dataSource = self
									itemsTableView.separatorInset = .zero
									itemsTableView.separatorColor = .white.withAlphaComponent(0.25)
									itemsTableView.isHeightDynamic = true
									itemsTableView.isUserInteractionEnabled = false
									alertController.add(itemsTableView)
									
									alertController.addDismissButton()
									alertController.dismissHandler = { [weak self] in
										
										self?.items = nil
										BF_Confettis.stop()
									}
									alertController.present {
										
										BF_Confettis.start()
									}
								}
							}
						}
					}
					
					BF_User.current?.lastConnexionDate = Date()
					BF_User.current?.update(nil)
					
					if BF_User.current?.displayName?.isEmpty ?? true {
						
						BF_Account_DisplayName_Alert_ViewController().present()
					}
					
					BF_Fight_Live.deleteActives(nil)
					BF_Fight_Live_Manager.shared.startListeningDemands()
					
					BF_Audio.shared.playMain()
				}
				
				if BF_User.current == nil {
					
					BF_User.create { error in
						
						if error == nil {
							
							BF_User.get { error in
								
								if error == nil {
									
									closure()
								}
							}
						}
					}
				}
				else {
					
					closure()
				}
			}
		}
		
		UI.MainController.dismiss(animated: true) { [weak self] in
		
			if !(self?.isLoggedIn ?? false) {
				
				UI.MainController.present(BF_NavigationController(rootViewController: BF_Onboarding_Account_ViewController()), animated: true)
			}
			else if UserDefaults.get(.onboarding) == nil {
				
				UserDefaults.set(true, .onboarding)
				
				UI.MainController.present(BF_NavigationController(rootViewController: BF_Onboarding_Game_Page_ViewController()), animated: true)
			}
			else {
				
				BF_Ads.shared.presentAppOpening()
			}
		}
	}
	
	public func createUser(with email:String?, and password:String?, _ completion:Error_Completion) {
		
		Auth.auth().createUser(withEmail: email ?? "", password: password ?? "") { _, error in
			
			completion?(error)
		}
	}
	
	public func signIn(with email:String?, and password:String?, _ completion:Error_Completion) {
		
		Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { _, error in
			
			completion?(error)
		}
	}
	
	private func signIn(with credential:AuthCredential, _ completion:Error_Completion) {
		
		Auth.auth().signIn(with: credential) { _, error in
			
			completion?(error)
		}
	}
	
	private func promptAppleSignIn() {
		
		let nonce = String.randomNonce
		currentAppleSignInNonce = nonce
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		request.nonce = nonce.sha256
		
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}
	
	public func signInWithApple(_ completion:Error_Completion) {
		
		promptAppleSignIn()
		
		appleSignCompletion = { [weak self] credential, error in
			
			if let error = error {
				
				completion?(error)
			}
			else if let credential = credential {
				
				self?.signIn(with: credential, completion)
			}
		}
	}
	
	public func reauthenticateWithApple(_ completion:Error_Completion) {
		
		promptAppleSignIn()
		
		appleSignCompletion = { [weak self] credential, error in
			
			if let error = error {
				
				completion?(error)
			}
			else if let credential = credential {
				
				self?.user?.reauthenticate(with: credential) { _, error in
					
					completion?(error)
				}
			}
		}
	}
	
	private func promptGoogleSignIn(_ completion:((GIDGoogleUser?,Error?)->Void)?) {
		
		if let clientID = FirebaseApp.app()?.options.clientID {
			
			let config = GIDConfiguration(clientID: clientID)
			GIDSignIn.sharedInstance.configuration = config
			
			GIDSignIn.sharedInstance.signIn(withPresenting: UI.MainController) { result, error in
				
				completion?(result?.user,error)
			}
		}
	}
	
	public func signInWithGoogle(_ completion:Error_Completion) {
		
		promptGoogleSignIn { [weak self] user, error in
			
			if let error = error {
				
				completion?(error)
			}
			else if let user = user, let idToken = user.idToken {
				
				let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
				
				self?.signIn(with: credential, completion)
			}
		}
	}
	
	public func reauthenticateWithGoogle(_ completion:Error_Completion) {
		
		promptGoogleSignIn { [weak self] user, error in
			
			if let error = error {
				
				completion?(error)
			}
			else if let user = user, let idToken = user.idToken {
				
				let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
				
				self?.user?.reauthenticate(with: credential) { _, error in
					
					completion?(error)
				}
			}
		}
	}
	
	public func sendPasswordReset(for email:String?, _ completion:Error_Completion) {
		
		Auth.auth().sendPasswordReset(withEmail: email ?? "", completion: completion)
	}
	
	public func signOut(_ completion:Error_Completion) {
		
		do {
			
			try Auth.auth().signOut()
			completion?(nil)
		}
		catch let error as NSError {
			
			completion?(error)
		}
	}
	
	public func reauthenticate(with password:String?, _ completion:Error_Completion) {
		
		let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: password ?? "")
		
		user?.reauthenticate(with: credential) { authDataResult, error in
			
			completion?(error)
		}
	}
	
	public func update(email:String?, _ completion:Error_Completion) {
		
		Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email ?? "", completion: { error in
			
			NotificationCenter.post(.updateAccount)
			completion?(error)
		})
	}
	
	public func update(password:String?, _ completion:Error_Completion) {
		
		Auth.auth().currentUser?.updatePassword(to: password ?? "") { error in
			
			NotificationCenter.post(.updateAccount)
			completion?(error)
		}
	}
	
	private func update(photoURL:URL, _ completion:Error_Completion) {
		
		let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
		changeRequest?.photoURL = photoURL
		changeRequest?.commitChanges(completion: completion)
	}
	
	public func delete(_ completion:Error_Completion) {
		
		let pictureRef = Storage.storage().reference().child("profile_pictures").child("\(BF_User.current?.uid ?? "").png")
		pictureRef.delete() { [weak self] error in
			
			Firestore.firestore().collection("users").whereField("uid", isEqualTo: BF_User.current?.uid ?? "").getDocuments { [weak self] querySnapshot, error in
				
				if let error = error {
					
					completion?(error)
				}
				else {
					
					querySnapshot?.documents.compactMap({ $0.reference }).first?.delete(completion: { error in
						
						if let error = error {
							
							completion?(error)
						}
						else {
							
							self?.user?.delete() { error in
								
								completion?(error)
							}
						}
					})
				}
			}
		}
	}
}

extension BF_Account: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
	
	public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		
		return UI.MainController.view.window!
	}
	
	public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		
		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential, let nonce = currentAppleSignInNonce, let appleIDToken = appleIDCredential.identityToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) {
			
			let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
			
			appleSignCompletion?(credential,nil)
		}
	}
	
	public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		
		appleSignCompletion?(nil,error)
	}
}

extension BF_Account : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var array:[BF_Item] = .init()
		items?.forEach({ item in
			
			if !array.contains(where: { $0.uid == item.uid }) {
				
				array.append(item)
			}
		})
		
		return array.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_Item_Object_TableViewCell.identifier, for: indexPath) as! BF_Item_Object_TableViewCell
		
		var array:[BF_Item] = .init()
		items?.forEach({ item in
			
			if !array.contains(where: { $0.uid == item.uid }) {
				
				array.append(item)
			}
		})
		
		let item = array[indexPath.row]
		cell.item = item
		cell.count = items?.compactMap({ $0 }).filter({ $0.uid == item.uid }).count
		
		return cell
	}
}
