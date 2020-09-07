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

/*
 * Controller with information about value of travel time (productivity, enjoyment, fitness)
 */
class ProdMindBodyScreensViewController: GenericViewController {

    @IBOutlet weak var titleImage: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    var option = options.productivity
    
    enum options {
        case productivity
        case mind
        case body
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Load content
        MotivAuxiliaryFunctions.RoundView(view: self.contentView)
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshView()
    }
    
    func refreshView() {
        var titleText = ""
        var descText = ""
        var buttonText = ""
        
        switch self.option {
        case .productivity:
            titleText = MotivStringsGen.getInstance().Productivity //"Productivity"
            descText = MotivStringsGen.getInstance().Productivity_Worthwhile_Description_Score
            buttonText = MotivStringsGen.getInstance().Proceed_To_Enjoyment
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGYellow.rawValue), object: nil)
            self.titleLabel.textColor = MotivColors.WoortiYellow
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiYellow)
            self.titleImage.image = UIImage(named: "Squirel_Productivity")!
            break
        case .mind:
            titleText = MotivStringsGen.getInstance().Enjoyment //"Enjoyment"
            descText = MotivStringsGen.getInstance().Enjoyment_Worthwhile_Description_Score
            buttonText = MotivStringsGen.getInstance().Proceed_To_Fitness
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGBlue.rawValue), object: nil)
            self.titleLabel.textColor = MotivColors.WoortiBlue
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiBlue)
            self.titleImage.image = UIImage(named: "Squirel_Enjoyment")!
            break
        case .body:
            titleText = MotivStringsGen.getInstance().Fitness //"Fitness"
            descText = MotivStringsGen.getInstance().Fitness_Worthwhile_Description_Score
            buttonText = MotivStringsGen.getInstance().Now_You
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGGreen.rawValue), object: nil)
            self.titleLabel.textColor = MotivColors.WoortiGreen
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiGreen)
            self.titleImage.image = UIImage(named: "Squirel_Fitness")!
            break
        }
        
        MotivFont.motivBoldFontFor(text: titleText, label: self.titleLabel, size: 17)
        MotivFont.motivRegularFontFor(text: descText, tv: self.descTextView, size: 15)
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: buttonText, boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
    }
    
    @IBAction func Next(_ sender: Any) {
        
        switch self.option {
        case .productivity:
            self.option = .mind
            self.refreshView()
            break
        case .mind:
            self.option = .body
            self.refreshView()
            break
        case .body:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGoToMeasureWorthwileness.rawValue), object: nil)
            break
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
