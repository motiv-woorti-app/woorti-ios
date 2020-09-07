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

/*
 * Popup to give credits to external libraries.
 */
class ShowDependenciesPopup: GenericViewController {
    

    @IBOutlet var Container: UIView!
    
    @IBOutlet weak var DependenciesLabel: UILabel!
    
    @IBOutlet weak var Dismiss: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var text = "Dependencies Used:  \nCrashlytics\nEzPopup\nFirebase\nFirebaseAnalytics\nFirebaseAuth\nFirebaseCore\nFirebaseDatabase\nFirebaseFirestore\nFirebaseMessaging\nFirebaseStorage\nFirebaseUI\nGoogleAppMeasurement\nGoogleSignIn\nGoogleUtilities\ngRPC\ngRPC-Core\nMaterial\nMaterialComponents\nMotion\nMotionAnimator\nMotionInterchange\nMotionTransitioning\n ThirdPartyMailer"
        
        MotivFont.motivRegularFontFor(text: text, label: DependenciesLabel, size: 12)
        
        let clickDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        self.Dismiss.addGestureRecognizer(clickDismiss)
        
        Dismiss.layer.masksToBounds = true
        Dismiss.layer.cornerRadius = Dismiss.bounds.height * 0.5
        Dismiss.setTitleColor(UIColor.white, for: .normal)
        MotivFont.motivBoldFontFor(key: "Dismiss", comment: "", button: Dismiss, size: 15)
        Dismiss.backgroundColor = MotivColors.WoortiGreen
        
        makeViewRound(view: Container)
        
    }
    
    
    @objc func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    
}




