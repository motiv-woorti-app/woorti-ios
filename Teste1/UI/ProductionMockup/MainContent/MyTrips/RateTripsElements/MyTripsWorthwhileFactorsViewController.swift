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

class MyTripsWorthwhileFactorsViewController: MTGenericViewController {

    //worthwhile factors
    @IBOutlet weak var worthWhileFactorsView: UIView!
    @IBOutlet weak var worthwhileTitleLabel: UILabel!
    @IBOutlet weak var worthwhileDescLabel: UILabel!
    @IBOutlet weak var descView: UIView!
    
    //firstView
    @IBOutlet weak var firstToggleView: UIView!
    @IBOutlet weak var firstToggleLabel: UILabel!
    @IBOutlet weak var firstToggleImage: UIImageView!
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var firstTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var firstContentView: UIView!
    var firstSelected = false
    var firstViewTableViewDelegate: WorthwhileFactorsTableViewHandler?
    
    //secondView
    @IBOutlet weak var secondToggleView: UIView!
    @IBOutlet weak var secondToggleLabel: UILabel!
    @IBOutlet weak var secondToggleImage: UIImageView!
    @IBOutlet weak var secondTableView: UITableView!
    @IBOutlet weak var secondTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var secondContentView: UIView!
    var secondSelected = false
    var secondViewTableViewDelegate: WorthwhileFactorsTableViewHandler?
    
    //thirdView
    @IBOutlet weak var thirdToggleView: UIView!
    @IBOutlet weak var thirdToggleLabel: UILabel!
    @IBOutlet weak var thirdToggleImage: UIImageView!
    @IBOutlet weak var thirdTableView: UITableView!
    @IBOutlet weak var thirdTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var thirdContentView: UIView!
    var thirdSelected = false
    var thirdViewTableViewDelegate: WorthwhileFactorsTableViewHandler?
    
    //thirdView
    @IBOutlet weak var fourthToggleView: UIView!
    @IBOutlet weak var fourthToggleLabel: UILabel!
    @IBOutlet weak var fourthToggleImage: UIImageView!
    @IBOutlet weak var fourthTableView: UITableView!
    @IBOutlet weak var fourthTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var fourthContentView: UIView!
    var fourthSelected = false
    var fourthViewTableViewDelegate: WorthwhileFactorsTableViewHandler?
    
    //other
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var otherTitleLabel: UILabel!
    @IBOutlet weak var otherTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipLabel: UILabel!
    @IBOutlet weak var skipView: UIView!
    
    var type = motToCell.getTypeFromCode(mode: UserInfo.partToGiveFeedback!.getModeOftransport())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MotivColors.WoortiOrangeT2
        // Do any additional setup after loading the view.
        firstViewTableViewDelegate = WorthwhileFactorsTableViewHandler(tv: firstTableView, type: WorthwhilenessFactorsManager.typeOfFactors.Getting_There, tableViewHeight: firstTableViewHeight)
        
        if type == .publicMot {
            //While You Ride Factors
            secondViewTableViewDelegate = WorthwhileFactorsTableViewHandler(tv: secondTableView, type: WorthwhilenessFactorsManager.typeOfFactors.While_You_Ride, tableViewHeight: secondTableViewHeight)
            
            //Comfort and Pleasantness Factors
            thirdViewTableViewDelegate = WorthwhileFactorsTableViewHandler(tv: thirdTableView, type: WorthwhilenessFactorsManager.typeOfFactors.Comfort_And_Pleasantness, tableViewHeight: thirdTableViewHeight)
            
            //Activities Factors
            fourthViewTableViewDelegate = WorthwhileFactorsTableViewHandler(tv: fourthTableView, type: WorthwhilenessFactorsManager.typeOfFactors.Activities, tableViewHeight: fourthTableViewHeight)
        } else {
            //Comfort and Pleasantness Factors
            secondViewTableViewDelegate = WorthwhileFactorsTableViewHandler(tv: secondTableView, type: WorthwhilenessFactorsManager.typeOfFactors.Comfort_And_Pleasantness, tableViewHeight: secondTableViewHeight)
            
            //Activities Factors
             thirdViewTableViewDelegate = WorthwhileFactorsTableViewHandler(tv: thirdTableView, type: WorthwhilenessFactorsManager.typeOfFactors.Activities, tableViewHeight: thirdTableViewHeight)
            fourthContentView.isHidden = true
            fourthContentView.addConstraint(NSLayoutConstraint(item: fourthContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
        }
        
        
        MotivAuxiliaryFunctions.RoundView(view: otherTextField)
       
        
        let fGR = UITapGestureRecognizer(target: self, action: #selector(toggleFirstView))
        firstToggleView.addGestureRecognizer(fGR)
        
        let sGR = UITapGestureRecognizer(target: self, action: #selector(toggleSecondView))
        secondToggleView.addGestureRecognizer(sGR)
        
        let tGR = UITapGestureRecognizer(target: self, action: #selector(toggleThirdView))
        thirdToggleView.addGestureRecognizer(tGR)
        
        let foGR = UITapGestureRecognizer(target: self, action: #selector(toggleFourthView))
        fourthToggleView.addGestureRecognizer(foGR)
        
        loadWorthwhilenessPart()
        loadBottomPart()
        
        let skGR = UITapGestureRecognizer(target: self, action: #selector(skipScreen))
        skipView.addGestureRecognizer(skGR)
        
//        MotivAuxiliaryFunctions.ShadowOnView(view: descView)
//        MotivAuxiliaryFunctions.gradientOnView(view: descView)
//        MotivAuxiliaryFunctions.ShadowOnView(view: firstContentView)
        MotivAuxiliaryFunctions.gradientOnView(view: firstToggleView)
//        MotivAuxiliaryFunctions.ShadowOnView(view: secondContentView)
        MotivAuxiliaryFunctions.gradientOnView(view: secondToggleView)
        MotivAuxiliaryFunctions.gradientOnView(view: thirdToggleView)
//        MotivAuxiliaryFunctions.ShadowOnView(view: thirdContentView)
        MotivAuxiliaryFunctions.gradientOnView(view: fourthToggleView)
    }
    
    @objc func toggleFirstView() {
        self.firstSelected = !self.firstSelected
        self.firstViewTableViewDelegate?.toggle()
        self.loadFirstToggleView()
    }
    
    @objc func toggleSecondView() {
        self.secondSelected = !self.secondSelected
        self.secondViewTableViewDelegate?.toggle()
        self.loadSecondToggleView()
    }
    
    @objc func toggleThirdView() {
        self.thirdSelected = !self.thirdSelected
        self.thirdViewTableViewDelegate?.toggle()
        self.loadThirdToggleView()
    }
    
    @objc func toggleFourthView() {
        self.fourthSelected = !self.fourthSelected
        self.fourthViewTableViewDelegate?.toggle()
        self.loadFourthToggleView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveNext() {
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.MyTripsValuePart.rawValue), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.myTripsUseYourTrip.rawValue), object: nil)
    }
    
    func loadBottomPart() {
        MotivFont.motivBoldFontFor(key: "Others_Comments", comment: "message: Other/Comments", label: self.otherTitleLabel, size: 15)
        self.otherTitleLabel.textColor = MotivColors.WoortiOrange
        
        self.otherTextField.accessibilityHint = NSLocalizedString("Correct_Exams", comment: "message: Correct exams")
        self.otherTextField.backgroundColor = MotivColors.WoortiOrangeT3
        self.otherTextField.textColor = MotivColors.WoortiOrange
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white,  key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: true)
        
        MotivFont.motivRegularFontFor(key: "Skip", comment: "message: Skip", label: self.skipLabel, size: 8, underlined: true, range: nil)
        
    }
    
    @IBAction func NextClick(_ sender: Any) {
        if let part = UserInfo.partToGiveFeedback {
            
            /* part.activitiesFactors = (firstViewTableViewDelegate?.getFactors() ?? [WorthWhilenessFactors]()).map { (factor) -> worthwhilenessFactors in
                return worthwhilenessFactors(code: factor.code, plus: factor.plus, minus: factor.minus)
            } */
            
            part.gettingThereFactors = (firstViewTableViewDelegate?.getFactors() ?? [WorthWhilenessFactors]()).map { (factor) -> worthwhilenessFactors in
                return worthwhilenessFactors(code: factor.code, plus: factor.plus, minus: factor.minus)
            }
            
            //Check Factors Order in Public Transport or Else
            //In public, third view is While u ride - fourth view is comfort and pleas
            if type == .publicMot {
                part.whileYouRideFactors = (secondViewTableViewDelegate?.getFactors() ?? [WorthWhilenessFactors]()).map { (factor) -> worthwhilenessFactors in
                    return worthwhilenessFactors(code: factor.code, plus: factor.plus, minus: factor.minus)
                }
                
                part.comfortAndPleasentFactors = (thirdViewTableViewDelegate?.getFactors() ?? [WorthWhilenessFactors]()).map { (factor) -> worthwhilenessFactors in
                    return worthwhilenessFactors(code: factor.code, plus: factor.plus, minus: factor.minus)
                }
                
                part.activitiesFactors = (fourthViewTableViewDelegate?.getFactors() ?? [WorthWhilenessFactors]()).map { (factor) -> worthwhilenessFactors in
                    return worthwhilenessFactors(code: factor.code, plus: factor.plus, minus: factor.minus)
                }
            }
            else {
                part.comfortAndPleasentFactors = (secondViewTableViewDelegate?.getFactors() ?? [WorthWhilenessFactors]()).map { (factor) -> worthwhilenessFactors in
                    return worthwhilenessFactors(code: factor.code, plus: factor.plus, minus: factor.minus)
                }
                
                part.activitiesFactors = (thirdViewTableViewDelegate?.getFactors() ?? [WorthWhilenessFactors]()).map { (factor) -> worthwhilenessFactors in
                    return worthwhilenessFactors(code: factor.code, plus: factor.plus, minus: factor.minus)
                }
            }
        
            
            part.otherFactor = self.otherTextField.text ?? ""
            
            var a = part.activitiesFactors ?? [worthwhilenessFactors]()
            a.append(contentsOf: part.gettingThereFactors ?? [worthwhilenessFactors]())
            a.append(contentsOf: part.whileYouRideFactors ?? [worthwhilenessFactors]())
            a.append(contentsOf: part.comfortAndPleasentFactors ?? [worthwhilenessFactors]())
    
            

            var userInfo = [String: Int]()
            userInfo["addPoints"] = Int(Scored.getPossibleWorthPoints())
            
            switch UserInfo.partToGiveFeedback {
            case let we as WaitingEvent:
                if a.count > 0 || part.otherFactor != "" {
                    we.answerWorthwileness()
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
                }
                break
            case let leg as Trip:
                if a.count > 0 || part.otherFactor != "" {
                    leg.answerWorthwileness()
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
                }
                break
            default:
                break
            }
            
            self.moveNext()
        }
    }
    
    @objc func skipScreen() {
        self.moveNext()
    }
    
    @IBAction func otherDidEndOnExit(_ sender: Any) {
        resignFirstResponder()
    }
    
    func loadWorthwhilenessPart() {
        MotivAuxiliaryFunctions.RoundView(view: self.worthWhileFactorsView)
        MotivFont.motivBoldFontFor(key: "Which_Factors_Most_Contributed", comment: "message: Which factor(s) most contributed to your time feeling Wasted (-) and/or Worthwhile (+)?", label: worthwhileTitleLabel, size: 15)
        worthwhileTitleLabel.textColor = MotivColors.WoortiOrange
        MotivFont.motivBoldFontFor(key: "Unfold_All_That_Apply", comment: "message: Unfold and mark all that apply", label: worthwhileDescLabel, size: 13)
        loadToggleViews()
    }
    
    func loadToggleViews() {
        loadFirstToggleView()
        loadSecondToggleView()
        loadThirdToggleView()
        loadFourthToggleView()
    }
    
    
    //First View is always Getting there
    func loadFirstToggleView() {
        
        if firstSelected {
            MotivFont.motivBoldFontFor(key: WorthwhilenessFactorsManager.typeOfFactors.Getting_There.rawValue, comment: "message: getting there ", label: firstToggleLabel, size: 15)
            firstToggleLabel.textColor = MotivColors.WoortiOrange
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.firstToggleLabel, color: MotivColors.WoortiOrange)
        } else {
            MotivFont.motivRegularFontFor(key: WorthwhilenessFactorsManager.typeOfFactors.Getting_There.rawValue, comment: "message: getting there", label: firstToggleLabel, size: 15)
//            firstToggleLabel.textColor = UIColor.black
        }
        
        firstToggleImage.image = firstToggleImage.image?.withRenderingMode(.alwaysTemplate)
        firstToggleImage.tintColor = MotivColors.WoortiOrange
    }
    
    //Second view
    //Public transports - While You Ride
    //Else - Comfort and Pleasantness
    func loadSecondToggleView() {
        var key = ""
        if type == .publicMot {
            key = WorthwhilenessFactorsManager.typeOfFactors.While_You_Ride.rawValue
        }else {
            key = WorthwhilenessFactorsManager.typeOfFactors.Comfort_And_Pleasantness.rawValue
        }
        
        if secondSelected {
            MotivFont.motivBoldFontFor(key: key, comment: "message: While You Ride", label: secondToggleLabel, size: 15)
            secondToggleLabel.textColor = MotivColors.WoortiOrange
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.secondToggleLabel, color: MotivColors.WoortiOrange)
        } else {
            MotivFont.motivRegularFontFor(key: key, comment: "message: While you Ride", label: secondToggleLabel, size: 15)
        }
        
       
        
        secondToggleImage.image = secondToggleImage.image?.withRenderingMode(.alwaysTemplate)
        secondToggleImage.tintColor = MotivColors.WoortiOrange
    }
    
    
    //ATTENTION
    //Public Transport - Comfort and Pleasantness
    //Else - Activities
    func loadThirdToggleView() {
        var key = ""
        
        if( type == .publicMot) {
            key = WorthwhilenessFactorsManager.typeOfFactors.Comfort_And_Pleasantness.rawValue
        } else {
            key = WorthwhilenessFactorsManager.typeOfFactors.Activities.rawValue
        }
        
        if thirdSelected {
            MotivFont.motivBoldFontFor(key: key, comment: "message:", label: thirdToggleLabel, size: 15)
            thirdToggleLabel.textColor = MotivColors.WoortiOrange
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.thirdToggleLabel, color: MotivColors.WoortiOrange)
        } else {
            MotivFont.motivRegularFontFor(key: key, comment: "message:", label: thirdToggleLabel, size: 15)
        }
        
        thirdToggleImage.image = thirdToggleImage.image?.withRenderingMode(.alwaysTemplate)
        thirdToggleImage.tintColor = MotivColors.WoortiOrange
    }
    
    func loadFourthToggleView() {
        
        if fourthSelected {
            MotivFont.motivBoldFontFor(key: WorthwhilenessFactorsManager.typeOfFactors.Activities.rawValue, comment: "message: Activities", label: fourthToggleLabel, size: 15)
            fourthToggleLabel.textColor = MotivColors.WoortiOrange
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.fourthToggleLabel, color: MotivColors.WoortiOrange)
        } else {
            MotivFont.motivRegularFontFor(key: WorthwhilenessFactorsManager.typeOfFactors.Activities.rawValue, comment: "message: Activities", label: fourthToggleLabel, size: 15)
//            fourthToggleLabel.textColor = UIColor.black
        }
        
        fourthToggleImage.image = fourthToggleImage.image?.withRenderingMode(.alwaysTemplate)
        fourthToggleImage.tintColor = MotivColors.WoortiOrange
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

class WorthwhileFactorsTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView
    let factorType: WorthwhilenessFactorsManager.typeOfFactors
    var factors = [WorthWhilenessFactors]()
    var tableViewHeight: NSLayoutConstraint?
    var selectedToView = false
    
    func toggle() {
        if Thread.isMainThread {
            self.selectedToView = !self.selectedToView
            tableViewHeight?.constant = CGFloat(selectedToView ? factors.count : 0) * 50
            self.tableView.reloadData()
        } else {
            DispatchQueue.main.async {
                self.toggle()
            }
        }
    }
    
    func getFactors() -> [WorthWhilenessFactors] {
        return self.factors
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedToView ? factors.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorthwhilenessPlusMinusTableViewCell") as! WorthwhilenessPlusMinusTableViewCell
        cell.loadCell(factor: self.factors[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    init(tv: UITableView, type: WorthwhilenessFactorsManager.typeOfFactors, tableViewHeight: NSLayoutConstraint) {
        self.tableView = tv
        self.factorType = type
        self.tableViewHeight = tableViewHeight
        let factorsForMode = WorthwhilenessFactorsManager.getInstance().getFactorsForMode(mode: UserInfo.partToGiveFeedback!.getModeOftransport())
        if let factors = factorsForMode[type] {
            self.factors = factors
        }
        
        super.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

    
//BIDIRECTIONAL MAP
struct BidiMap<F:Hashable,T:Hashable>
{
    private var _forward  : [F:T]? = nil
    private var _backward : [T:F]? = nil
    
    var forward:[F:T]
    {
        mutating get
        {
            _forward = _forward ?? [F:T](uniqueKeysWithValues:_backward?.map{($1,$0)} ?? [] )
            return _forward!
        }
        set { _forward = newValue; _backward = nil }
    }
    
    var backward:[T:F]
    {
        mutating get
        {
            _backward = _backward ?? [T:F](uniqueKeysWithValues:_forward?.map{($1,$0)} ?? [] )
            return _backward!
        }
        set { _backward = newValue; _forward = nil }
    }
    
    init(_ dict:[F:T] = [:])
    { forward = dict  }
    
    init(_ values:[(F,T)])
    { forward = [F:T](uniqueKeysWithValues:values) }
    
    subscript(_ key:T) -> F?
    { mutating get { return backward[key] } set{ backward[key] = newValue } }
    
    subscript(_ key:F) -> T?
    { mutating get { return forward[key]  } set{ forward[key]  = newValue } }
    
    subscript(to key:T) -> F?
    { mutating get { return backward[key] } set{ backward[key] = newValue } }
    
    subscript(from key:F) -> T?
    { mutating get { return forward[key]  } set{ forward[key]  = newValue } }
    
    var count:Int { return _forward?.count ?? _backward?.count ?? 0 }
}


class WorthwhilenessFactorsManager {
    static var instance: WorthwhilenessFactorsManager?
    
    var factors = [motToCell.typeOfMot:[typeOfFactors: [WorthWhilenessFactors]]]()
    
    enum typeOfFactors: String {
        case Activities
        case Getting_There
        case While_You_Ride
        case Comfort_And_Pleasantness
        case While_You_Are_There
    }
    
    var factorMap = BidiMap( [ 1001:"Ability_To_Do_What_I_Wanted",  //TODO Change String
        
                               1101:"Simplicity_Difficulty_Of_The_Route",
                               1102:"Schedule_Reliability",  //TODO Change String
                               1103:"Security_And_Safety",
                               1104:"Space_Onboard_For_Lugagge_Pram_Bicycle",   //TODO Change String
                               1105:"Ability_To_Take_Kids_Or_Pets_Along",
                               1106:"Payment_And_Tickets",
                               1107:"Convenient_Access_Lifts_Boarding",              //TODO Change String
                               1108:"Route_Planning_Navigation_Tools",
                               1109:"Information_And_Signs",
                               1110:"Checkin_Security_And_Boarding",
                               
                               1201:"Todays_Weather",
                               1202:"Crowdedness_Seating",
                               1203:"Internet_Connectivity",
                               1204:"Charging_Opportunity",
                               1205:"Tables",
                               1206:"Toilets",
                               1207:"Food_Drink_Allowed",
                               1208:"Food_Drink_Available",
                               1209:"Shopping_Retail",
                               1210:"Entertainment",
                               1211:"Car_Bike_Parking_At_Transfer_Point",
                               
                               1301:"Vehicle_Ride_Smoothness",
                               1302:"Seating_Quality_Personal_Space",
                               1303:"Other_People",
                               1304:"Privacy",
                               1305:"Noise_Level",
                               1306:"Air_Quality_Temperature",
                               1307:"Cleanliness",
                               1308:"General_Atmosphere_Design", //TODO Change String
                               1309:"Scenery",                   //TODO Change String
        
                               //2001:"Ability_To_Do_What_I_Wanted",
                               
                               //2101:"Simplicity_Difficulty_Of_The_Route",
                               2102:"Road_Path_Availability_And_Safety",                                //TODO Check string
                               2103:"Accessibility_Escalators_Lifts_Ramps_Stairs_Etc", //TODO Change String
                               2104:"Traffic_Signals_Crossings",
                               //2105:"Route_Planning_Navigation_Tools",
                               //2106:"Information_And_Signs",
                               2107:"Ability_To_Carry_Bags_Luggage_Etc",
                               //2108:"Ability_To_Take_Kids_Or_Pets_Along",
                               2109:"Crowding_Congestion",
                               2110:"Predictability_Of_Travel_Time",    //TODO Add String
                               2111:"Benches_Toilets_Etc",
                               2112:"Facilities_Shower_Lockers",
                               2113:"Parking_At_End_Points",
                               
                               //2201:"Todays_Weather",
                               2202:"Road_Path_Quality",   //TODO Check String
                               2203:"Road_Path_Directness",
                               //2204:"Noise_Level",
                               //2205:"Air_Quality_Temperature",  //TODO Check String
                               2206:"Lighting_Visibility",
                               2207:"Urban_Scenery_Atmosphere", //TODO Add String
                               //2208:"Scenery",                  //TODO Change String
                               //2209:"Other_People",
                               2210:"Cars_Other_Vehicles",
                               
                               //3001:"Ability_To_Do_What_I_Wanted",
                               
                               //3101:"Simplicity_Difficulty_Of_The_Route",
                               3102:"Traffic_Congestion_Delays",
                               3103:"Predictability_Of_Travel_Time",
                               //3104:"Security_And_Safety",
                               //3105:"Space_Onboard_For_Lugagge_Pram_Bicycle",
                               //3106:"Ability_To_Take_Kids_Or_Pets_Along",
                               //3107:"Route_Planning_Navigation_Tools",
                               //3108:"Information_And_Signs",
                               //3109:"Parking_At_End_Points",
                               
                               //3201:"Todays_Weather",
                               3202:"Road_Quality_Vehicle_Ride_Smoothness",
                               3203:"Vehicle_Quality",
                               //3204:"Charging_Opportunity",
                               //3205:"Privacy",
                               3206:"Seat_Comfort",
                               //3207:"Noise_Level",
                               //3208:"Air_Quality_Temperature",
                               //3209:"Urban_Scenery_Atmosphere", //TODO Add String
                               //3210:"Scenery",                  //TODO Change String
                               3211:"Other_Passengers",
                               3212:"Other_Cars_Vehicles"
        ]);
    
    
    //initialize all factors
    private init() {
        factors[motToCell.typeOfMot.publicMot] = getpublicFactors()
        factors[motToCell.typeOfMot.activeMot] = getActiveFactors()
        factors[motToCell.typeOfMot.privateMot] = getPrivateFactors()
    }
    
    //initializing functions
    //public
    private func getpublicFactors() -> [typeOfFactors: [WorthWhilenessFactors]] {
        var pfactors = [typeOfFactors: [WorthWhilenessFactors]]()
        pfactors[typeOfFactors.Activities] = getPublicActivitiesFactors()
        pfactors[typeOfFactors.Getting_There] = getPublicGettingThereFactors()
        pfactors[typeOfFactors.While_You_Ride] = getPublicWhileYouRideFactors()
        pfactors[typeOfFactors.Comfort_And_Pleasantness] = getPublicComfortAndPleasantnessFactors()
        return pfactors
    }
    
    
    private func getPublicActivitiesFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1001, text: factorMap[1001]!))
        return array
    }
    
    
    private func getPublicGettingThereFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1101, text: factorMap[1101]!))
        array.append(WorthWhilenessFactors(code: 1102, text: factorMap[1102]!))
        array.append(WorthWhilenessFactors(code: 1103, text: factorMap[1103]!))
        array.append(WorthWhilenessFactors(code: 1104, text: factorMap[1104]!))
        array.append(WorthWhilenessFactors(code: 1105, text: factorMap[1105]!))
        array.append(WorthWhilenessFactors(code: 1106, text: factorMap[1106]!))
        array.append(WorthWhilenessFactors(code: 1107, text: factorMap[1107]!))
        array.append(WorthWhilenessFactors(code: 1108, text: factorMap[1108]!))
        array.append(WorthWhilenessFactors(code: 1109, text: factorMap[1109]!))
        array.append(WorthWhilenessFactors(code: 1110, text: factorMap[1110]!))
        
        return array
    }
    
    private func getPublicWhileYouRideFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1201, text: factorMap[1201]!))
        array.append(WorthWhilenessFactors(code: 1202, text: factorMap[1202]!))
        array.append(WorthWhilenessFactors(code: 1203, text: factorMap[1203]!))
        array.append(WorthWhilenessFactors(code: 1204, text: factorMap[1204]!))
        array.append(WorthWhilenessFactors(code: 1205, text: factorMap[1205]!))
        array.append(WorthWhilenessFactors(code: 1206, text: factorMap[1206]!))
        array.append(WorthWhilenessFactors(code: 1207, text: factorMap[1207]!))
        array.append(WorthWhilenessFactors(code: 1208, text: factorMap[1208]!))
        array.append(WorthWhilenessFactors(code: 1209, text: factorMap[1209]!))
        array.append(WorthWhilenessFactors(code: 1210, text: factorMap[1210]!))
        array.append(WorthWhilenessFactors(code: 1211, text: factorMap[1211]!))
        
        return array
    }
    
    private func getPublicComfortAndPleasantnessFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1301, text: factorMap[1301]!))
        array.append(WorthWhilenessFactors(code: 1302, text: factorMap[1302]!))
        array.append(WorthWhilenessFactors(code: 1303, text: factorMap[1303]!))
        array.append(WorthWhilenessFactors(code: 1304, text: factorMap[1304]!))
        array.append(WorthWhilenessFactors(code: 1305, text: factorMap[1305]!))
        array.append(WorthWhilenessFactors(code: 1306, text: factorMap[1306]!))
        array.append(WorthWhilenessFactors(code: 1307, text: factorMap[1307]!))
        array.append(WorthWhilenessFactors(code: 1308, text: factorMap[1308]!))
        array.append(WorthWhilenessFactors(code: 1309, text: factorMap[1309]!))
        return array
    }
    
    // active
    private func getActiveFactors() -> [typeOfFactors: [WorthWhilenessFactors]] {
        var pfactors = [typeOfFactors: [WorthWhilenessFactors]]()
        pfactors[typeOfFactors.Activities] = getActiveActivitiesFactors()
        pfactors[typeOfFactors.Getting_There] = getActiveGettingThereFactors()
        pfactors[typeOfFactors.Comfort_And_Pleasantness] = getActiveComfortAndPleasantnessFactors()
        return pfactors
    }
    
    private func getActiveActivitiesFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1001, text: factorMap[1001]!))
        return array
    }
    
    private func getActiveGettingThereFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1101, text: factorMap[1101]!))
        array.append(WorthWhilenessFactors(code: 2102, text: factorMap[2102]!))
        array.append(WorthWhilenessFactors(code: 2103, text: factorMap[2103]!))
        array.append(WorthWhilenessFactors(code: 2104, text: factorMap[2104]!))
        array.append(WorthWhilenessFactors(code: 1108, text: factorMap[1108]!))
        array.append(WorthWhilenessFactors(code: 1109, text: factorMap[1109]!))
        array.append(WorthWhilenessFactors(code: 2107, text: factorMap[2107]!))
        array.append(WorthWhilenessFactors(code: 1105, text: factorMap[1105]!))
        array.append(WorthWhilenessFactors(code: 2109, text: factorMap[2109]!))
        array.append(WorthWhilenessFactors(code: 2110, text: factorMap[2110]!))
        array.append(WorthWhilenessFactors(code: 2111, text: factorMap[2111]!))
        array.append(WorthWhilenessFactors(code: 2112, text: factorMap[2112]!))
        array.append(WorthWhilenessFactors(code: 2113, text: factorMap[2113]!))
        
        return array
    }
    
    private func getActiveComfortAndPleasantnessFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1201, text: factorMap[1201]!))
        array.append(WorthWhilenessFactors(code: 2202, text: factorMap[2202]!))
        array.append(WorthWhilenessFactors(code: 2203, text: factorMap[2203]!))
        array.append(WorthWhilenessFactors(code: 1305, text: factorMap[1305]!))
        array.append(WorthWhilenessFactors(code: 1306, text: factorMap[1306]!))
        array.append(WorthWhilenessFactors(code: 2206, text: factorMap[2206]!))
        array.append(WorthWhilenessFactors(code: 2207, text: factorMap[2207]!))
        array.append(WorthWhilenessFactors(code: 1309, text: factorMap[1309]!))
        array.append(WorthWhilenessFactors(code: 1303, text: factorMap[1303]!))
        array.append(WorthWhilenessFactors(code: 2210, text: factorMap[2210]!))
        return array
    }
    
    private func getActiveWhileYouRideFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()/*
        array.append(WorthWhilenessFactors(text: "Todays_Weather"))
        array.append(WorthWhilenessFactors(text: "Road_Path_Quality"))
        array.append(WorthWhilenessFactors(text: "Road_Path_Directness"))
        array.append(WorthWhilenessFactors(text: "Ability_To_Do_The_Things_I_Want"))
        array.append(WorthWhilenessFactors(text: "Noise_Level"))
        array.append(WorthWhilenessFactors(text: "Air_Quality_Temperature"))
        array.append(WorthWhilenessFactors(text: "Lighting_Visibility"))
        array.append(WorthWhilenessFactors(text: "Scenery"))
        array.append(WorthWhilenessFactors(text: "Other_People"))
        array.append(WorthWhilenessFactors(text: "Cars_Other_Vehicles"))
 */
        return array
    }
    
    // private
    private func getPrivateFactors() -> [typeOfFactors: [WorthWhilenessFactors]] {
        var pfactors = [typeOfFactors: [WorthWhilenessFactors]]()
        pfactors[typeOfFactors.Activities] = getPrivateActivitiesFactors()
        pfactors[typeOfFactors.Getting_There] = getPrivateGettingThereFactors()
        pfactors[typeOfFactors.Comfort_And_Pleasantness] = getPrivateComfortAndPleasantnessFactors()
        return pfactors
    }
    
    private func getPrivateActivitiesFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1001, text: factorMap[1001]!))
        return array
    }
    
    private func getPrivateGettingThereFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1101, text: factorMap[1101]!))
        array.append(WorthWhilenessFactors(code: 3102, text: factorMap[3102]!))
        array.append(WorthWhilenessFactors(code: 3103, text: factorMap[3103]!))
        array.append(WorthWhilenessFactors(code: 1103, text: factorMap[1103]!))
        array.append(WorthWhilenessFactors(code: 1104, text: factorMap[1104]!))
        array.append(WorthWhilenessFactors(code: 1105, text: factorMap[1105]!))
        array.append(WorthWhilenessFactors(code: 1108, text: factorMap[1108]!))
        array.append(WorthWhilenessFactors(code: 1109, text: factorMap[1109]!))
        array.append(WorthWhilenessFactors(code: 2113, text: factorMap[2113]!))
        return array
    }
    
    private func getPrivateComfortAndPleasantnessFactors() -> [WorthWhilenessFactors] {
        var array = [WorthWhilenessFactors]()
        array.append(WorthWhilenessFactors(code: 1201, text: factorMap[1201]!))
        array.append(WorthWhilenessFactors(code: 3202, text: factorMap[3202]!))
        array.append(WorthWhilenessFactors(code: 3203, text: factorMap[3203]!))
        array.append(WorthWhilenessFactors(code: 1204, text: factorMap[1204]!))
        array.append(WorthWhilenessFactors(code: 1304, text: factorMap[1304]!))
        array.append(WorthWhilenessFactors(code: 3206, text: factorMap[3206]!))
        array.append(WorthWhilenessFactors(code: 1305, text: factorMap[1305]!))
        array.append(WorthWhilenessFactors(code: 1306, text: factorMap[1306]!))
        array.append(WorthWhilenessFactors(code: 2207, text: factorMap[2207]!))
        array.append(WorthWhilenessFactors(code: 1309, text: factorMap[1309]!))
        array.append(WorthWhilenessFactors(code: 3211, text: factorMap[3211]!))
        array.append(WorthWhilenessFactors(code: 3212, text: factorMap[3212]!))
        return array
    }
    
    //end initializing functions
    
    //getInstance
    static func getInstance() -> WorthwhilenessFactorsManager {
        if instance == nil {
            instance = WorthwhilenessFactorsManager()
        }
        return instance!
    }
    
    func getFactorsForMode(mode: Trip.modesOfTransport) -> [typeOfFactors: [WorthWhilenessFactors]] {
        let type = motToCell.getTypeFromCode(mode: mode)
        var fct = [typeOfFactors: [WorthWhilenessFactors]]()
        let papfactors = factors[type]!
        switch type {
        case .publicMot:
            fct[typeOfFactors.Activities] = publicActivitiesTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Activities]!)
            fct[typeOfFactors.Getting_There] = publicGettingThereTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Getting_There]!)
            fct[typeOfFactors.While_You_Ride] = publicWhileYouRideTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.While_You_Ride]!)
            fct[typeOfFactors.Comfort_And_Pleasantness] = publicComfortAndPleasureTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Comfort_And_Pleasantness]!)
            break
        case .activeMot:
            fct[typeOfFactors.Activities] = activeActivitiesTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Activities]!)
            fct[typeOfFactors.Getting_There] = activeGettingThereTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Getting_There]!)
            fct[typeOfFactors.Comfort_And_Pleasantness] = activeComfortAndPleasantnessTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Comfort_And_Pleasantness]!)
            break
        case .privateMot:
            fct[typeOfFactors.Activities] = privateActivitiesTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Activities]!)
            fct[typeOfFactors.Getting_There] = privateGettingThereTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Getting_There]!)
            fct[typeOfFactors.Comfort_And_Pleasantness] = privateComfortAndPleasantnessTrimmingFunciton(mode: mode, factors: papfactors[typeOfFactors.Comfort_And_Pleasantness]!)
            break
        }
        
        return fct
    }
    
    //trimming functions
    //public
    func publicActivitiesTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        return factors
    }
    
    func publicGettingThereTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        var fct = factors
        switch mode {
        case .Plane, .Ferry:
            fct.remove(at: 9)
        case .transfer:
            fct.remove(at: 9)
            fct.remove(at: 7)
            fct.remove(at: 5)
            fct.remove(at: 1)
            fct.remove(at: 0)
            fct.append(WorthWhilenessFactors(code: 2111, text: factorMap[2111]!))
            fct.append(WorthWhilenessFactors(code: 2112, text: factorMap[2112]!))
            
        default:
            break
        }
        return fct
    }
    
    func publicWhileYouRideTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        var fct = factors
        switch mode {
        case .Subway:
            fct.remove(at: 9)
            fct.remove(at: 8)
            fct.remove(at: 7)
            fct.remove(at: 5)
            fct.remove(at: 4)
        case .Tram, .Bus:
            fct.remove(at: 9)
            fct.remove(at: 8)
            fct.remove(at: 7)
            fct.remove(at: 5)
        case .busLongDistance, .Train:
            fct.remove(at: 7)
        case .intercityTrain, .highSpeedTrain, .Ferry, .Plane:
            fct.remove(at: 6)
        default:
            break
        }
        return fct
    }
    
    func publicComfortAndPleasureTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        var fct = factors
        switch mode {
        case .transfer:
            fct.remove(at: 0)
            fct.append(WorthWhilenessFactors(code: 2206, text: factorMap[2206]!))
            fct.append(WorthWhilenessFactors(code: 2207, text: factorMap[2207]!))
        default:
            break
        }
        return fct
    }
    
    //active
    func activeActivitiesTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        return factors
    }
    
    func activeGettingThereTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        var fct = factors
        switch mode {
        case .walking, .running, .wheelChair, .microScooter, .skate:
            fct.remove(at: 12)
        case .transfer:
            fct.remove(at: 12)
            fct.remove(at: 9)
            fct.remove(at: 8)
            fct.remove(at: 7)
            fct.remove(at: 6)
            fct.remove(at: 5)
            fct.remove(at: 4)
            fct.remove(at: 3)
            fct.remove(at: 2)
            fct.remove(at: 1)
            fct.remove(at: 0)
        default:
            break
        }
        return fct
    }
    
    func activeWhileYouRideTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        return factors
    }
    
    func activeComfortAndPleasantnessTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        var fct = factors
        switch mode {
        case .transfer:
            fct.remove(at: 0)
            fct.remove(at: 1)
            fct.remove(at: 2)
            fct.remove(at: 3)
            fct.remove(at: 4)
            fct.remove(at: 6)
            fct.remove(at: 7)
            fct.remove(at: 8)
        default:
            break
        }
        return fct
    }
    
    //private
    func privateActivitiesTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        return factors
    }
    
    func privateGettingThereTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        var fct = factors
        switch mode {
        case .carPassenger:
            fct.remove(at: 7)
        case .taxi, .rideHailing:
            fct.remove(at: 8)
            fct.remove(at: 7)
        case .carSharing:
            fct.remove(at: 7)
        default:
            break
        }
        return fct
    }
    
    func privateComfortAndPleasantnessTrimmingFunciton(mode: Trip.modesOfTransport, factors: [WorthWhilenessFactors]) -> [WorthWhilenessFactors] {
        var fct = factors
        switch mode {
        case .moped, .motorcycle, .electricWheelchair:
            fct.remove(at: 7)
        default:
            break
        }
        return fct
    }
}

class WorthWhilenessFactors {
    let code: Int
    let text: String
    var plus = false
    var minus = false
    
    
    init(code: Int, text: String) {
        self.code = code
        self.text = text
    }
    
//    static func getIeSFactors(mode: Trip.modesOfTransport) -> [WorthWhilenessFactors] {
//        var factors = [WorthWhilenessFactors]()
//        let type = motToCell.getTypeFromCode(mode: mode)
//
//        switch type {
//        case .publicMot:
//            //PUBLIC TRANSPORT / TRANSFERS
//            factors.append(WorthWhilenessFactors(code: 0, text: "Crowdedness_Seating_Availability"))
//            factors.append(WorthWhilenessFactors(code: 1, text: "Silent_Area"))
//            factors.append(WorthWhilenessFactors(code: 2, text: "Tables"))
//            factors.append(WorthWhilenessFactors(code: 12, text: "Toilets"))
//            factors.append(WorthWhilenessFactors(code: 3, text: "Wifi"))
//            factors.append(WorthWhilenessFactors(code: 4, text: "Power_Sockets_USB_Charging"))
//            factors.append(WorthWhilenessFactors(code: 5, text: "Food_Drink_Allowed"))
//            factors.append(WorthWhilenessFactors(code: 6, text: "Food_Drink_Available"))
//            factors.append(WorthWhilenessFactors(code: 7, text: "Shopping_Retail"))
//            factors.append(WorthWhilenessFactors(code: 8, text: "Entertainment"))
//
//            switch mode {
//            case .Subway, .Tram:
//                factors.remove(at: 9)
//                factors.remove(at: 8)
//                factors.remove(at: 7)
//                factors.remove(at: 3)
//                factors.remove(at: 2)
//                factors.remove(at: 1)
//            case .Bus:
//                factors.remove(at: 9)
//                factors.remove(at: 8)
//                factors.remove(at: 7)
//                factors.remove(at: 3)
//                factors.remove(at: 1)
//            case .busLongDistance:
//                factors.remove(at: 8)
//                factors.remove(at: 7)
//                factors.remove(at: 6)
//                factors.remove(at: 1)
//            case .Train:
//                factors.remove(at: 8)
//                factors.remove(at: 7)
//                factors.remove(at: 6)
//            case .intercityTrain, .highSpeedTrain:
//                factors.remove(at: 8)
//                factors.remove(at: 6)
//            case .Ferry:
//                factors.remove(at: 6)
//            case .Plane:
//                factors.remove(at: 6)
//                factors.remove(at: 1)
//                factors.remove(at: 0)
//            default:
//                break
//            }
//        case .activeMot:
//            //ACTIVE TRANSPORT
//            factors.append(WorthWhilenessFactors(code: 9, text: "Pavement_Road_Smoothness"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Lighting"))
//        case .privateMot:
//            //PRIVATE MOTORIZED
//            factors.append(WorthWhilenessFactors(code: 11, text: "Vehicle_Stability_Motion_Sickness"))
//        default:
//            break
//        }
//
//        return factors
//    }
//
//    static func getCePFactors(mode: Trip.modesOfTransport) -> [WorthWhilenessFactors]{
//        var factors = [WorthWhilenessFactors]()
//        let type = motToCell.getTypeFromCode(mode: mode)
//
//        switch type {
//        case .publicMot:
//            //PUBLIC TRANSPORT / TRANSFERS
//            factors.append(WorthWhilenessFactors(code: 0, text: "Vehicle_Stability_Motion_Sickness"))
//            factors.append(WorthWhilenessFactors(code: 1, text: "Seat_Comfort_Personal_Space"))
//            factors.append(WorthWhilenessFactors(code: 2, text: "Noise_Level"))
//            factors.append(WorthWhilenessFactors(code: 3, text: "Cleanliness"))
//            factors.append(WorthWhilenessFactors(code: 4, text: "Air_Ventilation_Smell_Temperature"))
//            factors.append(WorthWhilenessFactors(code: 5, text: "General_Ambiance_Design"))
//            factors.append(WorthWhilenessFactors(code: 6, text: "Scenery"))
//            factors.append(WorthWhilenessFactors(code: 7, text: "Fellow_Passengers"))
//            switch mode {
//            case .Subway, .Tram, .Bus:
//                factors.remove(at: 1)
//            default:
//                break
//            }
//        case .activeMot:
//            //ACTIVE TRANSPORT
//            factors.append(WorthWhilenessFactors(code: 8, text: "Todays_Weather"))
//            factors.append(WorthWhilenessFactors(code: 9, text: "Noise"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Air_Quality_Pollution"))
//            factors.append(WorthWhilenessFactors(code: 6, text: "Scenery"))
//
//        case .privateMot:
//            //PRIVATE MOTORIZED
//            factors.append(WorthWhilenessFactors(code: 10, text: "Audio_Radio_Music_Podcast"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Ability_To_Make_Phone_Calls"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Ability_Eat_Drink"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "USB_Charging"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Privacy"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "SeatComfort"))
//            factors.append(WorthWhilenessFactors(code: 9, text: "Noise"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Air_Quality_Pollution"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Climate_Control"))
//            factors.append(WorthWhilenessFactors(code: 6, text: "Scenery"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Fellow_Passengers"))
//            switch mode {
//            case .moped, .motorcycle, .electricWheelchair:
//                factors.remove(at: 8)
//            default:
//                break
//            }
//
//        default:
//            break
//        }
//        return factors
//    }
//
//    static func getGTFactors(mode: Trip.modesOfTransport) -> [WorthWhilenessFactors]{
//        var factors = [WorthWhilenessFactors]()
//        let type = motToCell.getTypeFromCode(mode: mode)
//
//        switch type {
//        case .publicMot:
//            //PUBLIC TRANSPORT / TRANSFERS
//            factors.append(WorthWhilenessFactors(code: 0, text: "Todays_Weather"))
//            factors.append(WorthWhilenessFactors(code: 1, text: "Vehicle_Parking_Origin"))
//            factors.append(WorthWhilenessFactors(code: 2, text: "Info_Signage_Finding"))
//            factors.append(WorthWhilenessFactors(code: 3, text: "Access_Infrastructures"))
//            factors.append(WorthWhilenessFactors(code: 4, text: "CheckIn_Process"))
//            factors.append(WorthWhilenessFactors(code: 5, text: "Security_And_Boarding_Process"))
//            factors.append(WorthWhilenessFactors(code: 6, text: "Space_Onboard_Bicycle_Wheelchair"))
//            factors.append(WorthWhilenessFactors(code: 7, text: "Ability_Transport_Stuff"))
//            factors.append(WorthWhilenessFactors(code: 8, text: "Arriving_On_Time"))
//
//            switch mode {
//            case .Subway, .Tram, .Bus, .busLongDistance, .Train, .intercityTrain, .highSpeedTrain:
//                factors.remove(at: 7)
//                factors.remove(at: 5)
//                factors.remove(at: 4)
//            case .Ferry:
//                factors.remove(at: 6)
//                factors.remove(at: 3)
//            case .Plane:
//                factors.remove(at: 7)
//                factors.remove(at: 6)
//                factors.remove(at: 3)
//            default:
//                break
//            }
//        case .activeMot:
//            //ACTIVE TRANSPORT
//            factors.append(WorthWhilenessFactors(code: 0, text: "Todays_Weather"))
//            factors.append(WorthWhilenessFactors(code: 7, text: "Ability_Transport_Stuff"))
//            factors.append(WorthWhilenessFactors(code: 9, text: "Ability_Take_Kids_Pets"))
//            factors.append(WorthWhilenessFactors(code: 10, text: "Floor_Road_Facilities"))
//            factors.append(WorthWhilenessFactors(code: 3, text: "Access_Infrastructures"))
//            factors.append(WorthWhilenessFactors(code: 11, text: "Roda_Signage_Layout_Design"))
//            factors.append(WorthWhilenessFactors(code: 12, text: "Traffic_Signals_Crossings"))
//            factors.append(WorthWhilenessFactors(code: 13, text: "Crowding_Congestion"))
//            factors.append(WorthWhilenessFactors(code: 22, text: "Predictability_Arrival_Time"))
//            factors.append(WorthWhilenessFactors(code: 15, text: "Parking_Destination"))
//            factors.append(WorthWhilenessFactors(code: 16, text: "Facilities_Destination_Showers_Lockers"))
//
//            switch mode {
//            case .walking, .running, .wheelChair, .microScooter, .skate:
//                factors.remove(at: 9)
//            default:
//                break
//            }
//        case .privateMot:
//            //PRIVATE MOTORIZED
//            factors.append(WorthWhilenessFactors(code: 0, text: "Todays_Weather"))
//            factors.append(WorthWhilenessFactors(code: 7, text: "Ability_Transport_Stuff"))
//            factors.append(WorthWhilenessFactors(code: 9, text: "Ability_Take_Kids_Pets"))
//            factors.append(WorthWhilenessFactors(code: 11, text: "Roda_Signage_Layout_Design"))
//            factors.append(WorthWhilenessFactors(code: 17, text: "Traffic_Signals"))
//            factors.append(WorthWhilenessFactors(code: 18, text: "Traffic_Congestion_Delays"))
//            factors.append(WorthWhilenessFactors(code: 14, text: "Predictability_Arrival_Time"))
//            factors.append(WorthWhilenessFactors(code: 19, text: "Parking_Destination"))
//            factors.append(WorthWhilenessFactors(code: 20, text: "Safety"))
//            factors.append(WorthWhilenessFactors(code: 21, text: "Security"))
//            switch mode {
//            case .Car:
//                factors.remove(at: 9)
//            case .carPassenger, .carSharingPassenger:
//                factors.remove(at: 9)
//                factors.remove(at: 7)
//                factors.remove(at: 4)
//                factors.remove(at: 3)
//                factors.remove(at: 2)
//            case .taxi, .rideHailing:
//                factors.remove(at: 7)
//                factors.remove(at: 4)
//                factors.remove(at: 3)
//            case .carSharing:
//                factors.remove(at: 9)
////                factors.remove(at: 2)
//            case .moped, .motorcycle:
//                factors.remove(at: 9)
//                factors.remove(at: 2)
//            case  .electricWheelchair:
//                factors.remove(at: 9)
//                factors.remove(at: 7)
//                factors.remove(at: 2)
//            default:
//                break
//            }
//
//        default:
//            break
//        }
//
//        return factors
//    }
}
