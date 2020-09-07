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

class WorthwhilenessTutorialFirstScreenViewController: GenericViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topTextView: UITextView!
    @IBOutlet weak var ProductiveLabel: UILabel!
    @IBOutlet weak var RelaxingLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        
        MotivFont.motivBoldFontFor(text: "Productivity", label: self.ProductiveLabel, size: 15)
        self.ProductiveLabel.textColor = MotivColors.WoortiYellow
        MotivFont.motivBoldFontFor(text: "Body & Health", label: self.healthLabel, size: 15)
        self.healthLabel.textColor = MotivColors.WoortiGreen
        MotivFont.motivBoldFontFor(text: "Mind & Pleasure", label: self.RelaxingLabel, size: 15)
        self.RelaxingLabel.textColor = MotivColors.WoortiBlue
        
        makeViewRound(view: mainView)
        loadSaveButton()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    func loadSaveButton(){
        nextButton.layer.masksToBounds = true
        nextButton.layer.cornerRadius = nextButton.bounds.height * 0.5
        MotivFont.motivBoldFontFor(text: "NEXT", label: nextButton.titleLabel!, size: 15)
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.backgroundColor = MotivColors.WoortiGreen
    }

    @IBAction func NextClick(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileWorthwhileTutorialSecond.rawValue), object: nil)
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
