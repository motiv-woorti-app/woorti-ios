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

class TopOnboardingViewController: UIViewController {

    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    
    private var hasloadded = false
    private var titleText = ""
    private var option = OnboardingTopAndContentViewController.options.language
    
    enum image: String {
        case close_black
        case ic_arrow_back
    }
    
    enum callbacks: String {
        case TopViewBGYellow
        case TopViewBGOrange
        case TopViewBGBlue
        case TopViewBGGreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(back))
        backImage.addGestureRecognizer(tapGesture)
//        self.TitleLabel.text = titleText
        hasloadded = true
        load(option: self.option, title: self.titleText)
        loadOrangeBackgroundCollor()
        
//        self.view.backgroundColor = MotivColors.WoortiOrange
        self.view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(loadYellowBackgroundCollor), name: NSNotification.Name(rawValue: callbacks.TopViewBGYellow.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadOrangeBackgroundCollor), name: NSNotification.Name(rawValue: callbacks.TopViewBGOrange.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadBlueBackgroundCollor), name: NSNotification.Name(rawValue: callbacks.TopViewBGBlue.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadGreenBackgroundCollor), name: NSNotification.Name(rawValue: callbacks.TopViewBGGreen.rawValue), object: nil)
    }
    
    @objc func loadOrangeBackgroundCollor() {
//        self.view.backgroundColor = MotivColors.WoortiOrange
    }
    
    @objc func loadYellowBackgroundCollor() {
//        self.view.backgroundColor = MotivColors.WoortiYellow
    }
    
    @objc func loadBlueBackgroundCollor() {
//        self.view.backgroundColor = MotivColors.WoortiBlue
    }
    
    @objc func loadGreenBackgroundCollor() {
//        self.view.backgroundColor = MotivColors.WoortiGreen
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(option: OnboardingTopAndContentViewController.options, title: String) {
        if Thread.isMainThread {
            if !hasloadded {
                self.titleText = title
                self.option = option
            } else {
                //            self.TitleLabel.text = title
                MotivFont.motivRegularFontFor(text: title, label: self.TitleLabel, size: 12)
                self.TitleLabel.textColor = MotivColors.WoortiOrangeT3
                self.option = option
                //            if option == .language {
                ////                backImage.image = UIImage(named: "Arrow_White")
                ////                backImage.tintColor = MotivColors.WoortiOrangeT3
                //                backImage.image = UIImage(named: "Arrow_White")!.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
                //            }
                backImage.image = UIImage(named: "Arrow_White")!.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
                self.backImage.tintColor = UIColor.white
            }
        } else {
            DispatchQueue.main.sync {
                self.load(option: option, title: title)
            }
        }
        
    }
    
    @objc func back() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVBack.rawValue), object: nil)
    }
}
