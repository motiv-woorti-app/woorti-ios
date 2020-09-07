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
 * Show this popup when a reward has been completed.
 */
class RewardCompletedPopup: GenericViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var HurrayLabel: UILabel!
    @IBOutlet weak var CompleteLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var PopupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ImageView.image = UIImage(named: "Squirel_Enjoyment")!
        
        MotivFont.motivBoldFontFor(text: NSLocalizedString("Hurray", comment: ""), label: HurrayLabel, size: 16)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: HurrayLabel, color: MotivColors.WoortiOrange)
        
        let rewardNames = buildRewardsName(nameList: RewardManager.instance.completedRewardsName)
        print("RewardNames= " + rewardNames)
        
        MotivFont.motivBoldFontFor(text: String(format: NSLocalizedString("You_Have_Completed_Your_Target", comment: ""), rewardNames), label: CompleteLabel, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: CompleteLabel, color: MotivColors.WoortiOrange)
        
        MotivFont.motivBoldFontFor(text: NSLocalizedString("Keep_Reporting_Your_Trips_Reward_Completed_Popup", comment: ""), label: MessageLabel, size: 14)
        
        
        
        DoneButton.layer.masksToBounds = true
        DoneButton.layer.cornerRadius = DoneButton.bounds.height * 0.5
        DoneButton.setTitleColor(UIColor.white, for: .normal)
        MotivFont.motivBoldFontFor(key: "Done", comment: "", button: DoneButton, size: 15)
        DoneButton.backgroundColor = MotivColors.WoortiOrange
        
        
        makeViewRound(view: PopupView)
        
        //Information was used, now we can reset it
        RewardManager.instance.resetRewardCompletionChecker()
        
        
        
    }
    
    //Build string with reward names separated by commas
    public func buildRewardsName(nameList: [String]) -> String {
        print("Building rewards completed string with count \(nameList.count)")
        var finalString = ""
        for name in nameList {
            finalString += name + ","
        }
        if finalString.count > 0 {
            finalString.removeLast()
        }
        
        
        return finalString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ClosePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  UseTripForViewController.oberserverOptions.goToNext.rawValue), object: nil)
    }
    
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    
}

