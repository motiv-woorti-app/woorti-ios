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

class MTTripObjectiveViewController: MTGenericViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var ObjectiveCollectionView: UICollectionView!
    @IBOutlet var RoundViews: [UIView]!
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var viewSubTitle: UILabel!
    
    @IBOutlet weak var titlesView: UIView!
    @IBOutlet weak var popOver: UIView!
    var fadeView: UIView?
    @IBOutlet weak var popUpTitle: UILabel!
    @IBOutlet weak var popupBackButton: UIImageView!
    @IBOutlet weak var popupTextfield: UITextField!
    @IBOutlet weak var popupSaveButton: UIButton!
    
    //secondview
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var secondViewNotSureLabel: UILabel!
    @IBOutlet weak var secondNotSureView: UIView!
    @IBOutlet weak var titleView: UIView!
    
    //thirdview
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var thirdTitleLabel: UILabel!
    @IBOutlet weak var regularlyButton: UIButton!
    @IBOutlet weak var occasionallyButton: UIButton!
    @IBOutlet weak var firstTimeButton: UIButton!
    @IBOutlet weak var thirdViewNotSureLabel: UILabel!
    @IBOutlet weak var thirdNotSureView: UIView!
    @IBOutlet weak var ThirdTitleLabelView: UIView!
    
    func LoadSecondViewContent() {
        if answeredFirst {
            secondNotSureView.backgroundColor = UIColor.white
            secondView.backgroundColor = UIColor.white
            titleView.backgroundColor = secondView.backgroundColor
            secondNotSureView.backgroundColor = secondView.backgroundColor
            MotivFont.motivBoldFontFor(key: "Arrive_At_Fixed_Time", comment: "message: Did you have to arrive at a fixed time?", label: self.secondTitleLabel, size: 17)
            self.secondTitleLabel.textColor = MotivColors.WoortiOrange
            
            if answeredSecond {
                let yesEnable = self.getFt()?.didYouHaveToArrive == Double(FullTrip.didYouHaveToArriveEnum.Yes.rawValue)
                let noEnable = self.getFt()?.didYouHaveToArrive == Double(FullTrip.didYouHaveToArriveEnum.No.rawValue)
                
                if yesEnable {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.yesButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Yes", comment: "Yes button", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                } else {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.yesButton, bColor: MotivColors.WoortiGreen.withAlphaComponent(CGFloat(0.5)), tColor: UIColor.white, key: "Yes", comment: "Yes button", boldText: true, size: 13, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                }
                if noEnable {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.noButton, bColor: MotivColors.WoortiRed, tColor: UIColor.white, key: "No", comment: "No button", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                } else {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.noButton, bColor: MotivColors.WoortiRed.withAlphaComponent(CGFloat(0.5)), tColor: UIColor.white, key: "No", comment: "No button", boldText: true, size: 13, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                }
            } else {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.yesButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Yes", comment: "Yes button", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                MotivAuxiliaryFunctions.loadStandardButton(button: self.noButton, bColor: MotivColors.WoortiRed, tColor: UIColor.white, key: "No", comment: "No button", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
            }
            
            MotivFont.motivRegularFontFor(key: "Not_Sure", comment: "message: Not Sure", label: secondViewNotSureLabel, size: 10, underlined: true, range: nil)
            secondViewNotSureLabel.textColor = UIColor.black
        } else {
            
            secondView.backgroundColor = MotivColors.WoortiOrangeT2
            titleView.backgroundColor = secondView.backgroundColor
            secondNotSureView.backgroundColor = secondView.backgroundColor
            MotivFont.motivBoldFontFor(key: "Arrive_At_Fixed_Time", comment: "message: Did you have to arrive at a fixed time?", label: self.secondTitleLabel, size: 15)
            self.secondTitleLabel.textColor = MotivColors.WoortiOrange
            
            let yesEnable = self.getFt()?.didYouHaveToArrive == Double(FullTrip.didYouHaveToArriveEnum.Yes.rawValue)
            let noEnable = self.getFt()?.didYouHaveToArrive == Double(FullTrip.didYouHaveToArriveEnum.No.rawValue)
            

                MotivAuxiliaryFunctions.loadStandardButton(button: self.yesButton, bColor: MotivColors.WoortiOrangeT3.withAlphaComponent(CGFloat(0.5)), tColor: UIColor.white, key: "Yes", comment: "Yes button", boldText: true, size: 13, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                MotivAuxiliaryFunctions.loadStandardButton(button: self.noButton, bColor: MotivColors.WoortiOrangeT3.withAlphaComponent(CGFloat(0.5)), tColor: UIColor.white, key: "No", comment: "No button", boldText: true, size: 13, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
            
            MotivFont.motivRegularFontFor(key: "Not_Sure", comment: "message: Not Sure", label: secondViewNotSureLabel, size: 10, underlined: true, range: nil)
            secondViewNotSureLabel.textColor = MotivColors.WoortiOrangeT1
            secondNotSureView.backgroundColor = MotivColors.WoortiOrangeT2
        }
    }
    
    func LoadThirdViewContent() {
        if answeredSecond {
            secondNotSureView.backgroundColor = UIColor.white
            thirdView.backgroundColor = UIColor.white
            ThirdTitleLabelView.backgroundColor = thirdView.backgroundColor
            thirdNotSureView.backgroundColor = thirdView.backgroundColor
            MotivFont.motivBoldFontFor(key: "How_Often_Make_This_Trip", comment: "message: How often do you make this trip?", label: self.thirdTitleLabel, size: 17)
            self.thirdTitleLabel.textColor = MotivColors.WoortiOrange
            
            if answeredThird {
                let regEnable = self.getFt()?.howOften == Double(FullTrip.howOftenEnum.Regular.rawValue)
                let ocaEnable = self.getFt()?.howOften == Double(FullTrip.howOftenEnum.Ocasional.rawValue)
                let ftEnable = self.getFt()?.howOften == Double(FullTrip.howOftenEnum.firstTime.rawValue)
                
                if regEnable {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.regularlyButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Regularly", comment: "message: Regularly", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                } else {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.regularlyButton, bColor: MotivColors.WoortiOrangeT3.withAlphaComponent(CGFloat(0.5)), tColor: MotivColors.WoortiOrange, key: "Regularly", comment: "message: Regularly", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                }
                
                if ocaEnable {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.occasionallyButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Occasionally", comment: "message: Ocasionally", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                } else {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.occasionallyButton, bColor: MotivColors.WoortiOrangeT3.withAlphaComponent(CGFloat(0.5)), tColor: MotivColors.WoortiOrange, key: "Occasionally", comment: "message: Ocasionally", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                }
                
                if ftEnable {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.firstTimeButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "First_Time", comment: "message: First Time", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                } else {
                    MotivAuxiliaryFunctions.loadStandardButton(button: self.firstTimeButton, bColor: MotivColors.WoortiOrangeT3.withAlphaComponent(CGFloat(0.5)), tColor: MotivColors.WoortiOrange, key: "First_Time", comment: "message: First Time", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                }
            } else {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.regularlyButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Regularly", comment: "message: Regularly", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                MotivAuxiliaryFunctions.loadStandardButton(button: self.occasionallyButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Occasionally", comment: "message: Ocasionally", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                MotivAuxiliaryFunctions.loadStandardButton(button: self.firstTimeButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "First_Time", comment: "message: First Time", boldText: true, size: 11, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
            }
            MotivFont.motivRegularFontFor(key: "Not_Sure", comment: "message: Not Sure", label: thirdViewNotSureLabel, size: 10, underlined: true, range: nil)
            thirdViewNotSureLabel.textColor = UIColor.black
        } else {
            thirdView.backgroundColor = MotivColors.WoortiOrangeT2
            ThirdTitleLabelView.backgroundColor = thirdView.backgroundColor
            thirdNotSureView.backgroundColor = thirdView.backgroundColor
            MotivFont.motivBoldFontFor(key: "How_Often_Make_This_Trip", comment: "message: How often do you make this trip?", label: self.thirdTitleLabel, size: 17)
            self.thirdTitleLabel.textColor = MotivColors.WoortiOrangeT1
            
            MotivAuxiliaryFunctions.loadStandardButton(button: self.regularlyButton, bColor: MotivColors.WoortiOrange.withAlphaComponent(CGFloat(0.5)), tColor: MotivColors.WoortiOrange, key: "Regularly", comment: "message: Regularly", boldText: true, size: 13, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
            MotivAuxiliaryFunctions.loadStandardButton(button: self.occasionallyButton, bColor: MotivColors.WoortiOrange.withAlphaComponent(CGFloat(0.5)), tColor: MotivColors.WoortiOrange, key: "Occasionally", comment: "message: Ocasionally", boldText: true, size: 13, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
            MotivAuxiliaryFunctions.loadStandardButton(button: self.firstTimeButton, bColor: MotivColors.WoortiOrange.withAlphaComponent(CGFloat(0.5)), tColor: MotivColors.WoortiOrange, key: "First_Time", comment: "message: First Time", boldText: true, size: 13, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
            
            MotivFont.motivRegularFontFor(key: "Not_Sure", comment: "message: Not Sure", label: thirdViewNotSureLabel, size: 10, underlined: true, range: nil)
            thirdViewNotSureLabel.textColor = MotivColors.WoortiOrangeT1
            secondNotSureView.backgroundColor = MotivColors.WoortiOrangeT2
        }
    }
    
    var answeredFirst = false
    var answeredSecond = false
    var answeredThird = false
    
    var selectedPurposes = [Int]()
    
    var OtherText: String?
    let Home = "Home"
    let Work = "Work"
    
    let cellIds = ["Home","Work","School_Education","Everyday_Shopping","Business_Trip","Leisure_Hobby","Pick_Up_Drop_Off","Personal_Tasks_Errands","Trip_Itself","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(closePopup), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
        self.ObjectiveCollectionView.delegate = self
        self.ObjectiveCollectionView.dataSource = self
        // Do any additional setup after loading the view.
        if self.getFt()?.objective == nil {
            self.getFt()?.objective = [String]()
        }
        MotivAuxiliaryFunctions.ShadowOnView(view: titlesView)
        
        let sGR = UITapGestureRecognizer(target: self, action: #selector(secondViewNotSureTap))
        secondNotSureView.addGestureRecognizer(sGR)
        
        let tGR = UITapGestureRecognizer(target: self, action: #selector(thirdViewNotSureTap))
        thirdNotSureView.addGestureRecognizer(tGR)
        
        for view in RoundViews {
            MotivAuxiliaryFunctions.RoundView(view: view)
        }
        
        MotivAuxiliaryFunctions.ShadowOnView(view: titleView)
        MotivAuxiliaryFunctions.ShadowOnView(view: ThirdTitleLabelView)
        
        MotivFont.motivBoldFontFor(key: "What_Was_Purpose", comment: "message: What was the objective of your trip?", label: self.viewTitle, size: 17)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: viewTitle, color: MotivColors.WoortiOrange)
        MotivFont.motivRegularFontFor(key: "Mark_All_That_Apply", comment: "message: Mark all that apply", label: self.viewSubTitle, size: 13)

//        @IBOutlet weak var viewTitle: UILabel!
//        @IBOutlet weak var viewSubTitle: UILabel!
        
        LoadSecondViewContent()
        LoadThirdViewContent()
    }
    
    @objc func secondViewNotSureTap() {
        if answeredFirst {
            self.getFt()?.didYouHaveToArrive = Double(FullTrip.didYouHaveToArriveEnum.NotSure.rawValue)
            self.answeredSecond = true
            
            LoadSecondViewContent()
            LoadThirdViewContent()
        }
    }
    
    @objc func thirdViewNotSureTap() {
        if answeredSecond {
            self.getFt()?.howOften = Double(FullTrip.howOftenEnum.NotSure.rawValue)
            LoadSecondViewContent()
            answeredThird = true
            LoadThirdViewContent()
            GoToNextScreen()
        }
    }
    
    @IBAction func thirdViewRegularlyClick(_ sender: Any) {
        if answeredSecond {
            self.getFt()?.howOften = Double(FullTrip.howOftenEnum.Regular.rawValue)
            LoadSecondViewContent()
            answeredThird = true
            LoadThirdViewContent()
            GoToNextScreen()
        }
    }
    
    @IBAction func thirdViewOcasionallyClick(_ sender: Any) {
        if answeredSecond {
            self.getFt()?.howOften = Double(FullTrip.howOftenEnum.Ocasional.rawValue)
            LoadSecondViewContent()
            answeredThird = true
            LoadThirdViewContent()
            GoToNextScreen()
        }
    }
    
    @IBAction func thirdViewFirstTimeClick(_ sender: Any) {
        if answeredSecond {
            self.getFt()?.howOften = Double(FullTrip.howOftenEnum.firstTime.rawValue)
            LoadSecondViewContent()
            answeredThird = true
            LoadThirdViewContent()
            GoToNextScreen()
        }
    }
    
    @IBAction func SecondViewYesClick(_ sender: Any) {
        if answeredFirst {
            self.getFt()?.didYouHaveToArrive = Double(FullTrip.didYouHaveToArriveEnum.Yes.rawValue)
            self.answeredSecond = true
            LoadSecondViewContent()
            LoadThirdViewContent()
        }
    }
    
    @IBAction func SecondViewNoClick(_ sender: Any) {
        if answeredFirst {
            self.getFt()?.didYouHaveToArrive = Double(FullTrip.didYouHaveToArriveEnum.No.rawValue)
            self.answeredSecond = true
            LoadSecondViewContent()
            LoadThirdViewContent()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.cellForItem(at: indexPath) as?
//        self.getFt()?.objective = cellIds[indexPath.row]
//        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsRateTrip.rawValue), object: nil)
        
        if let ind = selectedPurposes.index(of: indexPath.row) {
            selectedPurposes.remove(at: ind)
            self.getFt()?.objective?.remove(at: ind)
        } else {
            if indexPath.row == cellIds.count - 1 {
                self.loadPopup()
            } else {
                self.setHomeOrWork(ind: indexPath.row)
                selectedPurposes.append(indexPath.row)
                self.getFt()?.objective?.append(TripObjective.objectives[indexPath.row])
            }
        }
        if !answeredFirst {
            self.getFt()?.answerPurpose()
            

            var userInfo = [String: Int]()
            userInfo["addPoints"] = Int(Scored.getPossiblePurposePoints())
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
        }
        self.answeredFirst = true
        LoadSecondViewContent()
        collectionView.reloadData()
    }
    
    func setHomeOrWork(ind: Int) {
        if cellIds.count > ind,
            let user = MotivUser.getInstance() {
            let cell = cellIds[ind]
            if cell == Home && user.homeAddressPoint == nil && (user.homeAddress ?? "") == "" {
                UiAlerts.getInstance().newView(view: self)
                DispatchQueue.global().async {
                    if UiAlerts.getInstance().showSetHomeAlert() {
                        let location = UserLocation.getUserLocation(userLocation: self.getFt()!.getLastLocation()!, context: UserInfo.context!)!
                        user.homeAddressPoint = location
                        user.homeAddress = self.getFt()?.endLocation ?? ""
                    } else {
                        user.homeAddress = " "
                    }
                }
            } else if cell == Work && user.workAddressPoint == nil  && (user.workAddress ?? "") == ""{
                UiAlerts.getInstance().newView(view: self)
                DispatchQueue.global().async {
                    if UiAlerts.getInstance().showSetWorkAlert() {
                        let location = UserLocation.getUserLocation(userLocation: self.getFt()!.getLastLocation()!, context: UserInfo.context!)!
                        user.workAddressPoint = location
                        user.workAddress = self.getFt()?.endLocation ?? ""
                    } else {
                        user.workAddress = " "
                    }
                }
            }
        }
    }
    
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellIds.count
    }
    
    func GoToNextScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.MyTripsFeedBackChoice.rawValue), object: nil)
        }
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ObjectiveCollectionView.dequeueReusableCell( withReuseIdentifier: cellIds[indexPath.item], for: indexPath) as! MTObjectiveCollectionViewCell
        if selectedPurposes.contains(indexPath.row) {
            cell.backgroundColor = MotivColors.WoortiOrangeT3
        } else {
            cell.backgroundColor = UIColor.white
        }
        MotivAuxiliaryFunctions.RoundView(view: cell)
        cell.loadCell(key: cellIds[indexPath.item])
        
        return cell
    }
    
    func loadPopup() {
        MotivFont.motivBoldFontFor(key: "Other", comment: "message: Other", label: self.popUpTitle, size: 15)
        self.popUpTitle.textColor = MotivColors.WoortiOrange
        MotivAuxiliaryFunctions.RoundView(view: self.popOver)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(closePopup))
        self.popupBackButton.addGestureRecognizer(gr)
        self.popupBackButton.image = self.popupBackButton.image?.withRenderingMode(.alwaysTemplate)
        self.popupBackButton.tintColor = MotivColors.WoortiOrange
        
        self.popupTextfield.textColor = MotivColors.WoortiOrange
        self.popupTextfield.backgroundColor = MotivColors.WoortiOrangeT3
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.popupSaveButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Save", comment: "message: Save", boldText: true, size: 15, disabled: false)
        
        self.popup()
    }
    
    @objc func popup(){
        closePopup()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MTConfirmModesViewController.callbacks.MTChooseConfirmModeStartCarrousell.rawValue), object: nil)
        self.fadeView = UIView(frame: self.view.bounds)
        fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(fadeView!)
        fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))
        
        let pobounds = popOver.bounds
        popOver.bounds = CGRect(x: pobounds.minX, y: pobounds.minY, width: self.view.bounds.width - 20, height: self.view.bounds.height - 20)
        self.view.addSubview(self.popOver)
        self.popOver.center = self.view.center
    }
    
    @objc func closePopup() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MTConfirmModesViewController.callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil)
        self.fadeView?.removeFromSuperview()
        self.popOver?.removeFromSuperview()
    }
    
    @IBAction func popupSaveClick(_ sender: Any) {
        if let text = self.popupTextfield.text {
            selectedPurposes.append(cellIds.count-1)
            self.getFt()?.objective?.append(text)
            self.closePopup()
        }
    }
    
    @IBAction func PopUpTBEndEditing(_ sender: Any) {
        resignFirstResponder()
        self.popupTextfield.endEditing(true)
    }
    
    

//    @IBAction func didEndOnExit(_ sender: Any) {
//        resignFirstResponder()
//        self.getFt()?.objective?.append(OtherText ?? "")
//        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsRateTrip.rawValue), object: nil)
//    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
