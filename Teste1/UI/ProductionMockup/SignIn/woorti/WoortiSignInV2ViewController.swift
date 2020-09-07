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
import FBSDKLoginKit

/*
 * View with options to SignIn or Register.
 * Automatically log the user if there is a valid session
 */
class WoortiSignInV2ViewController: UIViewController, GenericSignInVC, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    
    @IBOutlet weak var WoortiLabel: UILabel!
    @IBOutlet weak var DescLabel: UILabel!
    
    @IBOutlet weak var startNowButton: UIButton!
    @IBOutlet weak var LogInButton: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var typeOSI = typeOfSignIn.signIn
    
    enum typeOfSignIn {
        case register
        case signIn
    }
    
    enum callbacks: String {
        case loggedIn = "SignInViewControllerGoTonext"
        case notLoggedIn = "SignInViewControllerstay"
        case notLoggedInOnStart = "SignInViewControllerstaynotLoggedInOnStart"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        MotivFont.motivBoldFontFor(text: "woorti", label: WoortiLabel, size: 40)
        WoortiLabel.textColor = UIColor.white
        MotivFont.motivBoldFontFor(text: "make your journey worthwhile.", label: DescLabel, size: 12)
        DescLabel.textColor = UIColor.white
   
        MotivAuxiliaryFunctions.loadStandardButton(button: startNowButton, bColor: UIColor.white, tColor: MotivColors.WoortiOrange, key: "Start_Now", comment: "splash screen start now button message", boldText: true, size: 15, disabled: false, CompleteRoundCorners: true)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.LogInButton, bColor: MotivColors.WoortiOrangeT1, tColor: UIColor.white, key: "Log_In", comment: "Log in button message", boldText: true, size: 15, disabled: false, border: true, borderColor: UIColor.white, CompleteRoundCorners: true)
        
        startNowButton.isHidden = true
        LogInButton.isHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    
    @objc func notLoggedIn() {
        if Thread.isMainThread {
            self.startNowButton.isHidden = false
            self.LogInButton.isHidden = false
        } else {
            DispatchQueue.main.async {
                self.notLoggedIn()
            }
        }
    }
    
    /// Login successfull, continue application flow.
    @objc func GoToMainMenu() {
        
        if(SignInManager.instance.goToOnboardingFromRegister){
            return
        }
        
        if Thread.isMainThread {
            if(!SignInManager.instance.checkGoToMainMenu()){
                return
            }
            
            if let user = MotivUser.getInstance() {
                if !(user.hasOnboardingFilledInfo)  {
                    print("Woorti SignIn V2 no onboarding")
                    if let presentedView = self.presentedViewController,
                        (presentedViewController as? OnboardingViewController) == nil {
                            presentedView.dismiss(animated: true, completion: nil)
                            print("Woorti SignIn V2 dismiss and go to onbording")
                            self.performSegue(withIdentifier: "GoToOnBoarding", sender: nil)
                            
                    } else {
                        self.performSegue(withIdentifier: "GoToOnBoarding", sender: nil)
                    }
                } else {
                    print("Woorti SignIn V2 has onboarding")
                    if !(user.hasOnboardingInfo) {
                        //Information stored locally, send to server
                        MotivRequestManager.getInstance().requestSaveUserSettings()
                    }
                    if let presentedView = self.presentedViewController,
                        (presentedViewController as? MainViewController) == nil {
                            self.performSegue(withIdentifier: "GoToMainMenu", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "GoToMainMenu", sender: nil)
                    }
                }
            }
            SignInManager.instance.availableMainMenu()
            notLoggedIn()
        } else {
            DispatchQueue.main.async {
                self.GoToMainMenu()
            }
        }
    }
    
    // start the onboarding
    @IBAction func startNowClick(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToOnBoarding", sender: nil)
    }
    
    // start the login screen
    @IBAction func logInClick(_ sender: Any) {
        
    }
    
    var activeUser:User!
    override func viewWillAppear(_ animated: Bool) {
        
        //get currently signed in user
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                if(SignInManager.instance.differentUser(user: user)) {
                    self.getToken(processToken: ProcessSendToken())
                }
            } else {
                self.getToken(processToken: ProcessSendToken())
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(GoToMainMenu), name: NSNotification.Name(rawValue: SignInViewController.goToNextScreen), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notLoggedIn), name: NSNotification.Name(rawValue: callbacks.notLoggedIn.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notLoggedIn), name: NSNotification.Name(rawValue: callbacks.notLoggedInOnStart.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func getToken(processToken: ProcessTokenResponse) {
        SignInManager.instance.getToken(view: self, processToken: processToken)
    }
    
    //Sign in vc stubs
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {

    }
    
    //Sign in vc stubs
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {

    } 

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? WoortiSignInOrRegisterViewController {
            print("removing SignInV2 Listener")
            Auth.auth().removeStateDidChangeListener(handle!)
            if typeOSI == .register {
                dest.regsiterNewUser()
            }
        }
        else if let dest = segue.destination as? OnboardingViewController {
            print("Going to Onboarding from SignInV2")
        }
    }
}
