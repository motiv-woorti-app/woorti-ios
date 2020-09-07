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

class ValueForYourTripViewController: MTGenericViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabelViewForPopUp: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var TitleLabelView: UIView!
    //Header
    @IBOutlet weak var noneLabel: UILabel!
    @IBOutlet weak var someLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    
    //PaidWork
    @IBOutlet weak var paidWorkLabel: UILabel!
    @IBOutlet weak var paidWorkSlider: UIView!
    var pwView: ValueSliderView?
    
    //PersonalTasks
    @IBOutlet weak var personalTasksLabel: UILabel!
    @IBOutlet weak var personalTasksSlider: UIView!
    var ptView: ValueSliderView?
    
    //Enjoyment
    @IBOutlet weak var enjoymentLabel: UILabel!
    @IBOutlet weak var enjoymentSlider: UIView!
    var eView: ValueSliderView?
    
    //Fitness
    @IBOutlet weak var fitnessLabel: UILabel!
    @IBOutlet weak var fitnessSlider: UIView!
    var fView: ValueSliderView?
    
    //bottom part
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipView: UIView!
    @IBOutlet weak var skipLabel: UILabel!
    
    //popup
    var fadeView: UIView?
    @IBOutlet weak var popOver: UIView!
    @IBOutlet weak var popUpTitle: UILabel!
    @IBOutlet weak var popUpDescLabel: UILabel!
    @IBOutlet weak var activitiesCollectionView: UICollectionView!
    @IBOutlet weak var popUpButton: UIButton!
//    @IBOutlet weak var selectOtherTextField: UITextField!
    @IBOutlet weak var selectOtherTextField: UITextView!
    
    var selectedActivities = [String]()
    var selectedTypes = [Int]()
    var OtherCellSelected: LegActivityCollectionViewCell?
    
    let eeGR = UITapGestureRecognizer(target: self, action: #selector(EndEditingTextField))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialization code
        MotivAuxiliaryFunctions.RoundView(view: contentView)
        
        self.view.backgroundColor = MotivColors.WoortiOrangeT2
        NotificationCenter.default.addObserver(self, selector: #selector(closePopup), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
        self.selectOtherTextField.delegate = self
        MotivFont.motivBoldFontFor(key: "What_Value_Take_From_Part", comment: "message: What value did you take from your time on this part of the Trip?", label: self.TitleLabel, size: 15)
        self.TitleLabel.textColor = MotivColors.WoortiOrange
        
        MotivAuxiliaryFunctions.ShadowOnView(view: TitleLabelView)
        MotivAuxiliaryFunctions.ShadowOnView(view: titleLabelViewForPopUp)
        
        MotivFont.motivBoldFontFor(key: "None", comment: "None", label: self.noneLabel, size: 11)
        MotivFont.motivBoldFontFor(key: "Some", comment: "Some", label: self.someLabel, size: 11)
        MotivFont.motivBoldFontFor(key: "High", comment: "High", label: self.highLabel, size: 11)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next", comment: "", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: true)
        
        MotivFont.motivRegularFontFor(key: "Skip", comment: "", label: self.skipLabel, size: 9, underlined: true, range: nil)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(skip))
        self.skipView.addGestureRecognizer(gr)
        
        // load views
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ValueSliderView", bundle: bundle)
        
        if let paidWSlider = nib.instantiate(withOwner: self, options: nil).first as? ValueSliderView {
            paidWSlider.frame = paidWorkSlider.bounds
            paidWorkSlider.addSubview(paidWSlider)
            self.pwView = paidWSlider
//            paidWSlider.imageForSelected = "activitySquirel"
            paidWSlider.loadIamge(image: "Productivity_Circular_Button", borderColor: MotivColors.WoortiOrange)
            MotivFont.motivBoldFontFor(key: "Paid_Work", comment: "Paid Work", label: self.paidWorkLabel, size: 10)
            
        }
        
        if let personalTSlider = nib.instantiate(withOwner: self, options: nil).first as? ValueSliderView {
            personalTSlider.frame = personalTasksSlider.bounds
            personalTasksSlider.addSubview(personalTSlider)
            self.ptView = personalTSlider
//            personalTSlider.imageForSelected = "activitySquirel"
            personalTSlider.loadIamge(image: "Productivity_Circular_Button", borderColor: MotivColors.WoortiOrange)
            MotivFont.motivBoldFontFor(key: "Personal_Tasks", comment: "Personal Tasks", label: self.personalTasksLabel, size: 10)
            
        }
        
        if let enjSlider = nib.instantiate(withOwner: self, options: nil).first as? ValueSliderView {
            enjSlider.frame = enjoymentSlider.bounds
            enjoymentSlider.addSubview(enjSlider)
            self.eView = enjSlider
//            enjSlider.imageForSelected = "activitySquirel"
            enjSlider.loadIamge(image: "Enjoyment_Circular_Button", borderColor: MotivColors.WoortiBlue)
            MotivFont.motivBoldFontFor(key: "Enjoyment", comment: "message: Enjoyment", label: self.enjoymentLabel, size: 10)
            
        }
        
        if let fitSlider = nib.instantiate(withOwner: self, options: nil).first as? ValueSliderView {
            fitSlider.frame = fitnessSlider.bounds
            fitnessSlider.addSubview(fitSlider)
            self.fView = fitSlider
//            fitSlider.imageForSelected = "activitySquirel"
            fitSlider.loadIamge(image: "Fitness_Circular_Button", borderColor: MotivColors.WoortiGreen)
            MotivFont.motivBoldFontFor(key: "Fitness", comment: "message: Fitness", label: self.fitnessLabel, size: 10)
            
        }
        
        //Load popup info
        MotivAuxiliaryFunctions.RoundView(view: popOver)
        
        MotivFont.motivBoldFontFor(key: "What_Did_You_Do_And_Value", comment: "What exactly did you do and value?", label: popUpTitle, size: 15)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.popUpTitle, color: MotivColors.WoortiOrange)
//        popUpTitle.textColor = MotivColors.WoortiOrange
        
        MotivFont.motivRegularFontFor(key: "Mark_All_That_Apply", comment: "message: Mark all that apply", label: popUpDescLabel, size: 15)
        
        activitiesCollectionView.delegate = self
        activitiesCollectionView.dataSource = self
        
        MotivAuxiliaryFunctions.loadStandardButton(button: popUpButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Save", comment: "", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: true)
        
        selectOtherTextField.backgroundColor = MotivColors.WoortiOrangeT3
        selectOtherTextField.textColor = MotivColors.WoortiOrange
        
//        @IBOutlet weak var popOver: UIView!
//        @IBOutlet weak var popUpTitle: UILabel!
//        @IBOutlet weak var popUpDescLabel: UILabel!
//        @IBOutlet weak var activitiesCollectionView: UICollectionView!
//        @IBOutlet weak var popUpButton: UIButton!
//        @IBOutlet weak var selectOtherTextField: UITextField!
        
    }
    
    
    
    @objc func EndEditingTextField() {
        self.selectOtherTextField.resignFirstResponder()
    }
    
    @IBAction func ClickNext(_ sender: Any) {
        if let part = UserInfo.partToGiveFeedback {
            let views = [self.pwView!, self.ptView!, self.eView!, self.fView!]
            part.valueFromTrip = views.map({ (view) -> ValueFromTrip in
                return ValueFromTrip(code: Double(views.index(of: view) ?? 0), value: Double(view.getValue()))
            })
            for vft in part.valueFromTrip ?? [ValueFromTrip]() {
                if vft.value != Double(0) {

                    self.popup()
                    return
                }
            }
            moveNext()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("resign first responder did end")
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("cahnged text")
        if text == "\n" {
            print("resign first responder break line")
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func nextOnDone(_ sender: Any) {
        if !self.selectOtherTextField.isHidden
            &&
            (self.selectOtherTextField.text ?? "").count > 0 {
            
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil, userInfo: ["activity": self.selectOtherTextField.text ?? "", "type" : ActivitySelect.type.productivity.rawValue])
            
            selectedActivities.append(LegActivities.ActivityCodeForOther)
            selectedTypes.append(ActivitySelect.type.productivity.rawValue)
            
            if let cell = OtherCellSelected {
                cell.SelectCell()
            }
        } else {

            var userInfo = [String: Int]()
            userInfo["addPoints"] = Int(Scored.getPossibleActivitiesPoints())
            switch UserInfo.partToGiveFeedback {
            case let we as WaitingEvent:
                we.answerActivities()
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
                break
            case let leg as Trip:
                leg.answerActivities()
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
                break
            default:
                break
            }
            closePopup()
            moveNext()
        }
        //set activities on part
        
        if let part = UserInfo.partToGiveFeedback {
            part.legUserActivities = self.selectedActivities
        }
        
        StopShowinOtherActivities()
//        closePopup()
//        moveNext()
    }
    
    func ShowOtherActivities() {
        self.selectOtherTextField.isHidden = false
        self.activitiesCollectionView.isHidden = true
        MotivFont.motivBoldFontFor(key: "Other", comment: "message: Other", label: popUpTitle, size: 15)
        self.popUpDescLabel.isHidden = true
//        self.TabStackView.isHidden = true
        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(eeGR)
    }
    
    func StopShowinOtherActivities() {
        self.selectOtherTextField.isHidden = true
        self.activitiesCollectionView.isHidden = false
        MotivFont.motivBoldFontFor(key: "What_Did_You_Do_And_Value", comment: "What exactly did you do and value?", label: popUpTitle, size: 15)
        self.popUpDescLabel.isHidden = false
//        self.TabStackView.isHidden = false
        self.topView.isUserInteractionEnabled = true
        self.topView.removeGestureRecognizer(eeGR)
    }
    
    //fading top view
    @objc func popup(){
        closePopup()
        self.StopShowinOtherActivities()
        // updarte selection
        if let part = UserInfo.partToGiveFeedback {
            self.selectedActivities = part.legUserActivities ?? [String]()
            self.selectedTypes = [Int](repeating: ActivitySelect.type.productivity.rawValue, count: self.selectedActivities.count)
        }
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
    
    @objc func skip() {
        moveNext()
    }
    
    func moveNext() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.MyTripsworthwhilenessFactors.rawValue), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.myTripsUseYourTrip.rawValue), object: nil)
    }

    //popup collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActivitySelect.getActivities(type: .productivity,modeOfTRansport: UserInfo.partToGiveFeedback!.getModeOftransport()).count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left +
                            flowLayout.sectionInset.right +
                            (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
    
    //create
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LegActivityCollectionViewCell", for: indexPath) as! LegActivityCollectionViewCell
        
            var activities = ActivitySelect.getActivities(type: .productivity, modeOfTRansport: UserInfo.partToGiveFeedback!.getModeOftransport())
        
            
            var hasActivity = false
            
            for act in selectedActivities {
                
                let index = selectedActivities.index(of: act)
                let type = self.selectedTypes[index!]
                if  activities[indexPath.item].type.rawValue == type
                    &&
                    activities[indexPath.item].text == act
                {
                    hasActivity = true
                    break
                }
            }
            
            cell.loadCell(activity: activities[indexPath.item], cellIsSelected: hasActivity)
            
            return cell
    }
    
    //select
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LegActivityCollectionViewCell
        if cell.cellIsSelected {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil, userInfo: ["activity": cell.activity?.text ?? "", "type" : ActivitySelect.type.productivity.rawValue])
            cell.deselectCell()
            if let index = selectedActivities.index(of: cell.activity!.text) {
                self.selectedActivities.remove(at: index)
                self.selectedTypes.remove(at: index)
            }
        } else {
//            if self.selectedActivities.count < 3 {
                if ActivitySelect.isOther(act: cell.activity!) {
                    self.ShowOtherActivities()
                    self.OtherCellSelected = cell
                } else {
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil, userInfo: ["activity": cell.activity?.text ?? "", "type" : ActivitySelect.type.productivity.rawValue])
                    cell.SelectCell()
                    selectedActivities.append(cell.activity!.text)
                    selectedTypes.append(cell.activity!.type.rawValue)
                }
//            }
        }
    }
    
}
