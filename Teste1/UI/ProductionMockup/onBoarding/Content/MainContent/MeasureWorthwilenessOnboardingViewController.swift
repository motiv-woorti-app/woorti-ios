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
* Onboarding view related with the importance that the user gives to his travel time (productivity, relaxing, fitness)
* Contains sliders to choose a value between 0% and 100% for each factor
*/
class MeasureWorthwilenessOnboardingViewController: GenericViewController, UIScrollViewDelegate {

    @IBOutlet weak var ProductivitySlider: UIView!
    @IBOutlet weak var RelaxingSlider: UIView!
    @IBOutlet weak var ActivitySlider: UIView!
    
    @IBOutlet weak var titleLabelView: UIView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shadowContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var productivitySliderView: OnboardingPRAScalesView?
    var relaxingSliderView: OnboardingPRAScalesView?
    var activitySliderView: OnboardingPRAScalesView?
    
    @IBOutlet weak var NextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGOrange.rawValue), object: nil)
        
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = true
        
        MotivAuxiliaryFunctions.ShadowOnView(view: titleLabelView)
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "OnboardingPRAScalesView", bundle: bundle)
        
        if let productiveScaleView = nib.instantiate(withOwner: self, options: nil).first as? OnboardingPRAScalesView {
            
            productiveScaleView.frame = ProductivitySlider.bounds
            ProductivitySlider.addSubview(productiveScaleView)
            self.productivitySliderView = productiveScaleView
            
            productiveScaleView.LoadSliderViews(
                MotivStringsGen.getInstance().Productivity,
                MotivStringsGen.getInstance().Productivity_Worthwhile_Low_Score,
                MotivStringsGen.getInstance().Productivity_Worthwhile_High_Score,
                MotivStringsGen.getInstance().Productivity_Worthwhile_Description_Score)
        }
        
        if let RelaxingScaleView = nib.instantiate(withOwner: self, options: nil).first as? OnboardingPRAScalesView {
            
            RelaxingScaleView.frame = RelaxingSlider.bounds
            RelaxingSlider.addSubview(RelaxingScaleView)
            self.relaxingSliderView = RelaxingScaleView
            
            RelaxingScaleView.LoadSliderViews(MotivStringsGen.getInstance().Enjoyment, MotivStringsGen.getInstance().Enjoyment_Worthwhile_Low_Score, MotivStringsGen.getInstance().Enjoyment_Worthwhile_High_Score,MotivStringsGen.getInstance().Enjoyment_Worthwhile_Description_Score)
        }
        
        if let activityScaleView = nib.instantiate(withOwner: self, options: nil).first as? OnboardingPRAScalesView {
            
            activityScaleView.frame = ActivitySlider.bounds
            ActivitySlider.addSubview(activityScaleView)
            self.activitySliderView = activityScaleView
            
            activityScaleView.LoadSliderViews(MotivStringsGen.getInstance().Fitness, MotivStringsGen.getInstance().Fitness_Worthwhile_Low_Score, MotivStringsGen.getInstance().Fitness_Worthwhile_High_Score,MotivStringsGen.getInstance().Fitness_Worthwhile_Description_Score)
            
        }

        
        //load content
        MotivAuxiliaryFunctions.RoundView(view: self.shadowContentView)
        self.view.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        MotivFont.motivBoldFontFor(key: "Rate_Worthwhileness_Screen_Title", comment: "message: How important are the travel time worthwhileness elements for you, when you travel?", label: self.titleText, size: 15)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleText, color: MotivColors.WoortiOrange)
        MotivAuxiliaryFunctions.loadStandardButton(button: self.NextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Save information and proceed to next onboarding screen
     */
    @IBAction func Next(_ sender: Any) {
        MotivUser.addVariables(prodvalue: self.productivitySliderView?.getValue() ?? 0, relValue: self.relaxingSliderView?.getValue() ?? 0, actValue: self.activitySliderView?.getValue() ?? 0)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToRegularMOT.rawValue), object: nil)
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.x != 0){
            scrollView.setContentOffset( CGPoint(x: 0, y: scrollView.contentOffset.y), animated: false)
        }
    }
}
