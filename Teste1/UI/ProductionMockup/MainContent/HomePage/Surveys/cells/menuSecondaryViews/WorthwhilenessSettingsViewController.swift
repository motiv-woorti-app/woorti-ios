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

class WorthwhilenessSettingsViewController: GenericViewController {

    @IBOutlet weak var ProductivitySlider: UIView!
    @IBOutlet weak var RelaxingSlider: UIView!
    @IBOutlet weak var ActivitySlider: UIView!

    @IBOutlet weak var topview: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var productivitySliderView: OnboardingPRAScalesView?
    var relaxingSliderView: OnboardingPRAScalesView?
    var activitySliderView: OnboardingPRAScalesView?
    
    
    
    @IBOutlet weak var NextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "OnboardingPRAScalesView", bundle: bundle)
        
        makeViewRound(view: stackView)
        makeViewRound(view: scrollView)
        loadSaveButton()
        MotivAuxiliaryFunctions.ShadowOnView(view: topview)
        textview.textColor = MotivColors.WoortiOrange
        MotivFont.motivBoldFontFor(text: textview.text, tv: textview, size: 16)
        textview.textColor = MotivColors.WoortiOrange
        
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        let user = MotivUser.getInstance()
        
        
        if let productiveScaleView = nib.instantiate(withOwner: self, options: nil).first as? OnboardingPRAScalesView {
            
            productiveScaleView.frame = ProductivitySlider.bounds
            ProductivitySlider.addSubview(productiveScaleView)
            self.productivitySliderView = productiveScaleView
            
            productiveScaleView.LoadSliderViews(
                MotivStringsGen.getInstance().Productivity,
                MotivStringsGen.getInstance().Productivity_Worthwhile_Low_Score,
                MotivStringsGen.getInstance().Productivity_Worthwhile_High_Score,
                MotivStringsGen.getInstance().Productivity_Worthwhile_Description_Score)
            productiveScaleView.setSliderValue(value: Float(user?.prodValue ?? 0))
        }
        
        if let RelaxingScaleView = nib.instantiate(withOwner: self, options: nil).first as? OnboardingPRAScalesView {
            
            RelaxingScaleView.frame = RelaxingSlider.bounds
            RelaxingSlider.addSubview(RelaxingScaleView)
            self.relaxingSliderView = RelaxingScaleView
            
            RelaxingScaleView.LoadSliderViews(MotivStringsGen.getInstance().Enjoyment, MotivStringsGen.getInstance().Enjoyment_Worthwhile_Low_Score, MotivStringsGen.getInstance().Enjoyment_Worthwhile_High_Score,MotivStringsGen.getInstance().Enjoyment_Worthwhile_Description_Score)
            RelaxingScaleView.setSliderValue(value: Float(user?.relValue ?? 0))
        }
        
        if let activityScaleView = nib.instantiate(withOwner: self, options: nil).first as? OnboardingPRAScalesView {
            
            activityScaleView.frame = ActivitySlider.bounds
            ActivitySlider.addSubview(activityScaleView)
            self.activitySliderView = activityScaleView
            
            activityScaleView.LoadSliderViews(MotivStringsGen.getInstance().Fitness, MotivStringsGen.getInstance().Fitness_Worthwhile_Low_Score, MotivStringsGen.getInstance().Fitness_Worthwhile_High_Score,MotivStringsGen.getInstance().Fitness_Worthwhile_Description_Score)
            activityScaleView.setSliderValue(value: Float(user?.actValue ?? 0))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    @IBAction func Next(_ sender: Any) {
        let user = MotivUser.getInstance()!
        user.prodValue = self.productivitySliderView?.getValue() ?? 0
        user.relValue = self.relaxingSliderView?.getValue() ?? 0
        user.actValue = self.activitySliderView?.getValue() ?? 0
        
        UserInfo.appDelegate?.saveContext()
        MotivRequestManager.getInstance().requestSaveUserSettings()
        
        // go to next
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileWorthwhileMotList.rawValue), object: nil)
        
    }

    func loadSaveButton(){
        NextButton.layer.masksToBounds = true
        NextButton.layer.cornerRadius = NextButton.bounds.height * 0.5
        MotivFont.motivBoldFontFor(key: "Save", comment: "", label: NextButton.titleLabel!, size: 15)
//        NextButton.setTitle("SAVE", for: .normal)
        NextButton.setTitleColor(UIColor.white, for: .normal)
        NextButton.backgroundColor = MotivColors.WoortiGreen
    }

}
