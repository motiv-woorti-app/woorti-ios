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

import UIKit

class SplitMergeDeleteTopViewController: UIViewController {

    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var DoneButton: UIButton!
    
    enum callbacks: String {
        case SMDTopSetTitle
        case SMDTopShowButton
        case SMDTopHideButton
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backbutton.tintColor = UIColor(displayP3Red: CGFloat(236)/CGFloat(255), green: CGFloat(192)/CGFloat(255), blue: CGFloat(138)/CGFloat(255), alpha: CGFloat(1))
        MotivAuxiliaryFunctions.loadStandardButton(button: self.DoneButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Done", comment: "", boldText: false, size: 15, disabled: false)
        
        MotivFont.motivRegularFontFor(key: "Split", comment: "", label: self.titleLabel, size: 17)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiOrangeT1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadTitleIntoSuperView), name: NSNotification.Name(rawValue: callbacks.SMDTopSetTitle.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showDoneButton), name: NSNotification.Name(rawValue: callbacks.SMDTopShowButton.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideDoneButton), name: NSNotification.Name(rawValue: callbacks.SMDTopHideButton.rawValue), object: nil)
        
        backbutton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
    }
    
    @objc func loadTitleIntoSuperView (_ notification: NSNotification) {
        if let title = notification.userInfo?["title"] as? String {
            MotivFont.motivRegularFontFor(key: title, comment: "Split Merge delete titles", label: self.titleLabel, size: 15)
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiOrangeT1)
        }
    }
    
    @objc func showDoneButton() {
        self.DoneButton.isHidden = false
    }
    
    @objc func hideDoneButton() {
        self.DoneButton.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func ClickBack(_ sender: Any) {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MTViews.SMDMyTripsBack.rawValue), object: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
