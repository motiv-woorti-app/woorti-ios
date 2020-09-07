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
import Firebase
import GoogleSignIn

class MotivUser {
    var email: String
    var age: Int
    var userid: String
    
    private static var user: MotivUser?
    
    private init(email: String, age: Int,userId: String){
        self.email=email
        self.age=age
        self.userid=userId
    }
    
    public static func getInstance() -> MotivUser? {
        return self.user
    }
    
    public static func LogIn(email: String, age: Int,userId: String) -> MotivUser {
        user = MotivUser(email: email, age: age, userId: userId)
        return user!
    }
    
    public func signOut(view: UIViewController){
        let firebaseAuth = Auth.auth()
        do {
            if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                GIDSignIn.sharedInstance().signOut()
            }
            try firebaseAuth.signOut()
            view.navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            //print ("Error signing out: %@", signOutError)
        }
        
        MotivUser.user = nil
    }
    
}
