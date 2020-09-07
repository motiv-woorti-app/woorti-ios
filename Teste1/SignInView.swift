// (C) 2017-2020 - The Woorti app is a research (non-commercial) application that was
// developed in the context of the European research project MoTiV (motivproject.eu). The
// code was developed by partner INESC-ID with contributions in graphics design by partner
// TIS. The Woorti app development was one of the outcomes of a Work Package of the MoTiV
// project.
 
// The Woorti app was originally intended as a tool to support data collection regarding
// mobility patterns from city and country-wide campaigns and provide the data and user
// management to campaign managers.
 
// The Woorti app development followed an agile approach taking into account ongoing
// feedback of partners and testing users while continuing under development. This has
// been carried out as an iterative process deploying new app versions. Along the 
// timeline, various previously unforeseen requirements were identified, some requirements
// Were revised, there were requests for modifications, extensions, or new aspects in
// functionality or interaction as found useful or interesting to campaign managers and
// other project partners. Most stemmed naturally from the very usage and ongoing testing
// of the Woorti app. Hence, code and data structures were successively revised in a
// way not only to accommodate this but, also importantly, to maintain compatibility with
// the functionality, data and data structures of previous versions of the app, as new
// version roll-out was never done from scratch.

// The code developed for the Woorti app is made available as open source, namely to
// contribute to further research in the area of the MoTiV project, and the app also makes
// use of open source components as detailed in the Woorti app license. 
 
// This project has received funding from the European Union’s Horizon 2020 research and
// innovation programme under grant agreement No. 770145.
 
// This file is part of the Woorti app referred to as SOFTWARE.
import Foundation
import UIKit
import Firebase
import GoogleSignIn

class SignInView: UIViewController, GIDSignInUIDelegate, GenericSignInVC {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //
    }
    
    
    var btnSignIn : GIDSignInButton!
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
//    @IBOutlet weak var btnSignOut: UIButton!
    @IBOutlet weak var btnSignInEmail: UIButton!
    @IBOutlet weak var btnRegisterEmail: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign In"
        GIDSignIn.sharedInstance().uiDelegate = self
        //        GIDSignIn.sharedInstance().signIn()
        
        btnSignIn = GIDSignInButton()
        btnSignIn.center = view.center
        btnSignIn.style = GIDSignInButtonStyle.standard
        view.addSubview(btnSignIn)
        
        toggleAuthUI()
        NotificationCenter.default.addObserver(self, selector: #selector(GoToMainMenu), name: NSNotification.Name(rawValue: SignInViewController.goToNextScreen), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UiAlerts.getInstance().newView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Auth_State_Did_Change on Sign In")
            self.toggleAuthUI()
            self.getToken(processToken: ProcessSendToken())
            UserInfo.fetchUserTrips()
            self.toggleAuthUI()
        }
        toggleAuthUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
//    @IBAction func btnSignOutClick(_ sender: Any) {
//        signOut()
//        toggleAuthUI()
//    }
    
    func toggleAuthUI() {
        if (Auth.auth().currentUser != nil){
            // Signed in
            txtEmail.isHidden = true
            txtPassword.isHidden = true
            btnSignInEmail.isHidden = true
            btnRegisterEmail.isHidden = true
            btnSignIn.isHidden = true
//            btnSignOut.isHidden = false
        } else {
            if (GIDSignIn.sharedInstance().hasAuthInKeychain()) {
                GIDSignIn.sharedInstance().signOut()
            }
            btnSignIn.isHidden = false
            txtEmail.isHidden = false
            txtPassword.isHidden = false
            btnSignInEmail.isHidden = false
            btnRegisterEmail.isHidden = false
//            btnSignOut.isHidden = true
        }
    }
    
    func getToken(processToken: ProcessTokenResponse) {
        print("getIdToken in SignInView")
        MotivUser.getIdToken(view: self, processToken: processToken)
//        if let currentUser = Auth.auth().currentUser {
//            UserInfo.authenticationToken = nil
//            currentUser.getIDTokenForcingRefresh(true) { idToken, error in
//                if let error = error as? NSError {
//                    // Handle error
//                    print("error: \(error)")
//                    MotivUser.LogIn(email: currentUser.email!, age: 0, userId: currentUser.uid, token: "")
//                    self.GoToMainMenu()
//                    return
//                }
//
//                if let idToken = idToken {
//                    processToken.processToken(tokenId: idToken)
//                    MotivUser.LogIn(email: currentUser.email!, age: 0, userId: currentUser.uid, token: idToken)
//                    self.GoToMainMenu()
//                }
//            }
//        }
    }
    
    
    @IBAction func btnSignInClick(_ sender: Any) {
        if emailPasswordFilled() {
            if  let email = txtEmail.text,
                let password = txtPassword.text {
                
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        UiAlerts.getInstance().showAlertMsg(error: error)
                        print("error: \(error)")
                    }
                    if let user = user?.user  {
                        UserInfo.email = user.email
                        //print("signed In User")
                        self.GoToMainMenu()
                        
                        self.getToken(processToken: ProcessSendToken())
                    }
                }
            }
        } else {
            UiAlerts.getInstance().showAlertMsg(title: "Sign In", message: "you must fill in both Email and Password fields")
        }
    }
    
    @IBAction func btnRegisterClick(_ sender: Any) {
        if emailPasswordFilled() {
            if  let email = txtEmail.text,
                let password = txtPassword.text {
                
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        UiAlerts.getInstance().showAlertMsg(error: error)
                        print("error: \(error)")
                    }
                    if let user = user?.user  {
                        UserInfo.email = user.email
                        //print("Created User")
                        self.GoToMainMenu()
                        
                        self.getToken(processToken: ProcessSendToken(true))
                    }
                }
            }
        } else {
//            self.GoToMainMenu()
//            UiAlerts.getInstance().showAlertMsg(title: "(Testing) Register", message: "Signing In without account. To upload Trips you must first log in with a valid account.")
        }
    }
    
    private func emailPasswordFilled() -> Bool {
        if  let email = txtEmail.text,
            let password = txtPassword.text {
            
            return (email.count > 0) && (password.count) > 0
        }
        return false
    }
    
    @objc func GoToMainMenu() {
//        self.present(MainMenuView(), animated: true, completion: {})
        let mainMenuView = storyboard?.instantiateViewController(withIdentifier: "MainMenuView") as! MainMenuView
        print("Pushing new MainMenuView")
        navigationController?.pushViewController(mainMenuView, animated: true)
    }
}
