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
import EzPopup

class UseTripForViewController: MTGenericViewController {
    
    
    var useTripFor = FullTrip.usetripMoreForEnum.None
    //Maincontent
    @IBOutlet weak var MainContentView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    
    //prodView
    @IBOutlet weak var prodView: UIView!
    @IBOutlet weak var prodImage: UIImageView!
    //    @IBOutlet weak var prodLabel: UILabel!
    
    //prodView
    @IBOutlet weak var enjView: UIView!
    @IBOutlet weak var enjImage: UIImageView!
    //    @IBOutlet weak var enjLabel: UILabel!
    
    //prodView
    @IBOutlet weak var fitView: UIView!
    @IBOutlet weak var fitImage: UIImageView!
    //    @IBOutlet weak var fitLabel: UILabel!
    
    //Bottom part
    @IBOutlet weak var anythingOtherToShareLabel: UILabel!
    @IBOutlet weak var OtherTextField: UITextField!
    @IBOutlet weak var endButton: UIButton!
    //    @IBOutlet weak var skipView: UIView!
    //    @IBOutlet weak var skipLabel: UILabel!
    
    var showingPopup = false
    
    enum oberserverOptions: String {
        case goToNext = "GoToNext"
        case moveToNext = "MoveToNext"
        case goToNextAfterPopup = "GoToNextAfterPopup"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MotivColors.WoortiOrangeT2
    
        
        // Do any additional setup after loading the view.
        loadPEFViews()
        MotivFont.motivBoldFontFor(key: "Thinking_About_Your_Trip_Title", comment: "Thinking about your trip as a whole, would you have liked to use your travel time for... ?", label: self.mainTitle, size: 15)
        mainTitle.textColor = MotivColors.WoortiOrange
        MotivFont.motivBoldFontFor(key: "Anything_Else_Like_To_Share", comment: "Anything else you’d like to share?", label: self.anythingOtherToShareLabel, size: 13)
        anythingOtherToShareLabel.textColor = MotivColors.WoortiOrange
        
        OtherTextField.backgroundColor = MotivColors.WoortiOrangeT3
        OtherTextField.placeholder = NSLocalizedString("Would_Like_To_Share", comment: "message: I would like to share...")
        OtherTextField.textColor = MotivColors.WoortiOrange
        
        MotivAuxiliaryFunctions.RoundView(view: MainContentView)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.endButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "End", comment: "message: End", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: true)
        
        //        let gr = UITapGestureRecognizer(target: self, action: #selector(skip))
        //        self.skipView.addGestureRecognizer(gr)
        
        let pGR = UITapGestureRecognizer(target: self, action: #selector(clickProd))
        self.prodView.addGestureRecognizer(pGR)
        self.prodView.isUserInteractionEnabled = true
        let eGR = UITapGestureRecognizer(target: self, action: #selector(clickEnj))
        self.enjView.addGestureRecognizer(eGR)
        self.enjView.isUserInteractionEnabled = true
        let fGR = UITapGestureRecognizer(target: self, action: #selector(clickFit))
        self.fitView.addGestureRecognizer(fGR)
        self.fitView.isUserInteractionEnabled = true
        
        //        MotivFont.motivRegularFontFor(text: "Skip", label: self.skipLabel, size: 9, underlined: true, range: nil)
        //        self.skipView.backgroundColor = MotivColors.WoortiOrangeT2
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToNext), name: NSNotification.Name(rawValue: oberserverOptions.goToNext.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveNext), name: NSNotification.Name(rawValue: oberserverOptions.moveToNext.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToNextAfterPopup), name: NSNotification.Name(rawValue: oberserverOptions.goToNextAfterPopup.rawValue), object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPEFViews() {
        loadPView()
        loadEView()
        loadFView()
    }
    
    func loadPView() {
        //        prodView.backgroundColor = MotivColors.WoortiOrangeT3
        MotivAuxiliaryFunctions.RoundView(view: prodView)
        //        MotivFont.motivBoldFontFor(text: "Productivity", label: self.prodLabel, size: 10)
        if useTripFor == .Productive {
            //            self.prodLabel.textColor = MotivColors.WoortiOrange
            self.prodImage.image = UIImage(named: "Productivity_Button")
        } else {
            //            self.prodLabel.textColor = MotivColors.WoortiBlackT1
            self.prodImage.image = UIImage(named: "Productivity_Button_Fade")
        }
    }
    
    func loadEView() {
        //        enjView.backgroundColor = MotivColors.WoortiBlueT3
        MotivAuxiliaryFunctions.RoundView(view: enjView)
        //        MotivFont.motivBoldFontFor(text: "Enjoyment", label: self.enjLabel, size: 10)
        if useTripFor == .Enjoyment {
            //            self.enjLabel.textColor = MotivColors.WoortiBlue
            self.enjImage.image = UIImage(named: "Enjoyment_Button")
        } else {
            //            self.enjLabel.textColor = MotivColors.WoortiBlackT1
            self.enjImage.image = UIImage(named: "Enjoyment_Button_Fade")
        }
    }
    
    func loadFView() {
        //        fitView.backgroundColor = MotivColors.WoortiGreenT3
        MotivAuxiliaryFunctions.RoundView(view: fitView)
        //        MotivFont.motivBoldFontFor(text: "Fitness", label: self.fitLabel, size: 10)
        if useTripFor == .Fitness {
            //            self.fitLabel.textColor = MotivColors.WoortiGreen
            self.fitImage.image = UIImage(named: "Fitness_Button")
        } else {
            //            self.fitLabel.textColor = MotivColors.WoortiBlackT1
            self.fitImage.image = UIImage(named: "Fitness_Button_Fade")
        }
    }
    
    @IBAction func didEndOnExitOtherTF(_ sender: Any) {
        resignFirstResponder()
    }
    
    @IBAction func confirmAll(_ sender: Any) {
        confirmAllGoTonext()
    }
    
    func confirmAllGoTonext() {
        if  let ft = self.getFt() {
            for leg in ft.getTripOrderedList() {
                if let user = MotivUser.getInstance(),
                    let mainText = leg.getMainTextFromRealMotCode(),
                    let code = user.getMotFromText(text: mainText) {
                    
                    user.setSecondaryasMain(mainCode: code.motCode)
                }
            }
            if self.useTripFor == .None  {
                ft.usetripMoreFor = Double(-1)
            }
            else {
                ft.usetripMoreFor = Double(useTripFor.rawValue)
                ft.answerCompleteAllInfo()
            }
            
            ft.shareInformation = self.OtherTextField.text ?? ""
            
            

            var userInfo = [String: Int]()
            userInfo["addPoints"] = Int(Scored.getPossibleAllInfoPoints())
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
            
            
            ft.confirmTrip()
            UiAlerts.getInstance().showTripBeinSentAlertMsg()
            
            
           
        }
        //moveNext()
    }
    
    @objc func clickProd() {
        if self.useTripFor != .Productive {
            self.useTripFor = .Productive
            self.loadPEFViews()
        }
    }
    
    @objc func clickEnj() {
        if self.useTripFor != .Enjoyment {
            self.useTripFor = .Enjoyment
            self.loadPEFViews()
        }
    }
    
    @objc func clickFit() {
        if self.useTripFor != .Fitness {
            self.useTripFor = .Fitness
            self.loadPEFViews()
        }
    }
    
    @objc func skip() {
        confirmAllGoTonext()
        //        moveNext()
    }
    
    @objc func goToNext() {
        if !showingPopup {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsConfirmTrip.rawValue), object: nil)

        }
    }
    
    @objc func goToNextAfterPopup() {
        showingPopup = false
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsConfirmTrip.rawValue), object: nil)
    }
    
    @objc func moveNext() {
        print("Move Next on last my trips screen")
        let rewardManager = RewardManager.instance
        
        let showPopup = (Int.random(in: 0...3) == 3)
        print("ProfilePopupProb: \(showPopup)")
        
        if rewardManager.atLeastOneRewardCompleted {
            showCompletedRewardPopup(names: rewardManager.completedRewardsName)
        } else if showPopup && !MotivUser.getInstance()!.dontShowTellUsMorePopup {
            showingPopup = true
            showProfilePopup()
        } else {
            print("Dismissing confirmation screen")
            if !showingPopup {
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsConfirmTrip.rawValue), object: nil)
            }
        }
       
        
    }
    
    func showProfilePopup(){
        print("Presenting profile popup")
        DispatchQueue.main.async {
            
            
            let popupVC = UIStoryboard(name: "MoTiVProduction", bundle: nil).instantiateViewController(withIdentifier: "PopupFillProfileController") as! PopupFillProfileController
            let width = popupVC.view.bounds.size.width
            let height = popupVC.view.bounds.size.height
            let popup = PopupViewController(contentController: popupVC, position: .bottom(5), popupWidth: width, popupHeight: height)
            popup.canTapOutsideToDismiss = true
            self.present(popup, animated: true, completion: nil)
            
        }
        
    }
    
    func showCompletedRewardPopup(names: [String]){
        
        DispatchQueue.main.async {
            
            
            let popupVC = UIStoryboard(name: "MoTiVProduction", bundle: nil).instantiateViewController(withIdentifier: "RewardCompletedPopup") as! RewardCompletedPopup
            let width = popupVC.view.bounds.size.width
            let height = popupVC.view.bounds.size.height
            let popup = PopupViewController(contentController: popupVC, position: .bottom(5), popupWidth: width, popupHeight: height)
            popup.canTapOutsideToDismiss = true
            self.present(popup, animated: true, completion: nil)
            
        }
        
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
