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

class WorthwhileTutorialPMBViewController: GenericViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    
    var currentType = type.prod
    
    enum type {
        case prod, mind, body
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        makeViewRound(view: mainView)
        loadSaveButton()
        loadInformation()
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
    
    func loadInformation() {
        switch currentType {
        case .prod:
            MotivFont.motivBoldFontFor(text: MotivStringsGen.getInstance().Productivity, label: self.HeaderLabel, size: 17)
            self.descriptionTextView.text = MotivStringsGen.getInstance().Productivity_Worthwhile_Description_Score
            self.nextButton.setTitle(MotivStringsGen.getInstance().Proceed_To_Enjoyment, for: .normal)
            self.image.image = UIImage(named: "Squirel_Productivity")
            break
        case .mind:
            MotivFont.motivBoldFontFor(text: MotivStringsGen.getInstance().Enjoyment, label: self.HeaderLabel, size: 17)
            self.descriptionTextView.text = MotivStringsGen.getInstance().Enjoyment_Worthwhile_Description_Score
            self.nextButton.setTitle(MotivStringsGen.getInstance().Proceed_To_Fitness, for: .normal)
            self.image.image = UIImage(named: "Squirel_Enjoyment")
            break
        case .body:
            MotivFont.motivBoldFontFor(text: MotivStringsGen.getInstance().Fitness, label: self.HeaderLabel, size: 17)
            self.descriptionTextView.text = MotivStringsGen.getInstance().Fitness_Worthwhile_Description_Score
            self.nextButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
            self.image.image = UIImage(named: "Squirel_Fitness")
            break
        }
    }
    
    func loadSaveButton() {
        nextButton.layer.masksToBounds = true
        nextButton.layer.cornerRadius = nextButton.bounds.height * 0.5
        MotivFont.motivBoldFontFor(text: MotivStringsGen.getInstance().Proceed_To_Productivity, button: nextButton, size: 15)
//        nextButton.setTitle("to Productivity", for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.backgroundColor = MotivColors.WoortiGreen
    }
    
    @IBAction func NextClick(_ sender: Any) {
        switch currentType {
        case .prod:
            currentType = .mind
        case .mind:
            currentType = .body
        case .body:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileBackToFirst.rawValue), object: nil)
            return
        }
        loadInformation()
    }
}
