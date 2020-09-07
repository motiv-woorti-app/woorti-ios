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
 * Popup to request filling the user's profile
 */
class PopupFillProfileController: GenericViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var TellUsMoreLabel: UILabel!
    @IBOutlet weak var InfoLabel: UILabel!
    @IBOutlet weak var AnonymisedLabel: UILabel!
    @IBOutlet weak var ButtonLabel: UIButton!
    
    
    @IBOutlet weak var LaterLabel: UILabel!
    @IBOutlet weak var DontShowLabel: UILabel!
    
    @IBOutlet weak var Container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ImageView.image = UIImage(named: "Squirel_Enjoyment")!
        
        LaterLabel.isUserInteractionEnabled = true
        DontShowLabel.isUserInteractionEnabled = true
        
        MotivFont.motivBoldFontFor(text: NSLocalizedString("Tell_Us_More_About_Yourself", comment: ""), label: TellUsMoreLabel, size: 18)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TellUsMoreLabel, color: MotivColors.WoortiOrange)
        
        MotivFont.motivBoldFontFor(text: NSLocalizedString("Woorti_Gives_You_Points_For_Each_Info", comment: ""), label: InfoLabel, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: InfoLabel, color: MotivColors.WoortiBlack)
        
        MotivFont.motivRegularFontFor(text: NSLocalizedString("Keep_Reporting_Your_Trips_Reward_Completed_Popup", comment: ""), label: AnonymisedLabel, size: 12)
        
        ButtonLabel.layer.masksToBounds = true
        ButtonLabel.layer.cornerRadius = ButtonLabel.bounds.height * 0.5
        ButtonLabel.setTitleColor(UIColor.white, for: .normal)
        MotivFont.motivBoldFontFor(key: "Fill_In_Profile", comment: "", button: ButtonLabel, size: 15)
        ButtonLabel.backgroundColor = MotivColors.WoortiGreen
        
        MotivFont.motivRegularFontFor(text: NSLocalizedString("Your_Data_Is_Anonymised", comment: ""), label: AnonymisedLabel, size: 12)
        MotivFont.motivRegularFontFor(text: NSLocalizedString("Do_Not_Show_Again", comment: ""), label: DontShowLabel, size: 12, underlined: true)
        MotivFont.motivRegularFontFor(text: NSLocalizedString("Later", comment: ""), label: LaterLabel, size: 12, underlined: true)
        
        let clickFillProfile = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
        self.ButtonLabel.addGestureRecognizer(clickFillProfile)
        
        let clickLater = UITapGestureRecognizer(target: self, action: #selector(closePopup))
        self.LaterLabel.addGestureRecognizer(clickLater)
        
        let clickDoNotShow = UITapGestureRecognizer(target: self, action: #selector(closeAndDontShow))
        self.DontShowLabel.addGestureRecognizer(clickDoNotShow)
        
        
        
        makeViewRound(view: Container)
        
    }
    
    @objc func goToProfile() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowProfileAndSettingsDemographic.rawValue), object: nil)
    }
    
    
    /*
     * close and set flag to not show popup again
     */
    @objc func closeAndDontShow() {
        
        MotivUser.getInstance()?.dontShowTellUsMorePopup = true
        
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  UseTripForViewController.oberserverOptions.goToNextAfterPopup.rawValue), object: nil)
    }
    
    /*
     * close popup. It will continue appearing.
     */
    @objc func closePopup() {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  UseTripForViewController.oberserverOptions.goToNextAfterPopup.rawValue), object: nil)
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




