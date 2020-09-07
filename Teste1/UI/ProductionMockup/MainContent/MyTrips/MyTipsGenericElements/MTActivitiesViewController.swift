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

class MTActivitiesViewController: MTGenericViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var ActivitiesTableView: UITableView!
    @IBOutlet weak var PickActivitiesView: UIView!
    @IBOutlet weak var ConfirmButton: UIButton!
    
    @IBOutlet weak var MainView: UIView!
    var fadeView: UIView?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var activitiesCollectionView: UICollectionView!
    var rated = false
    
    @IBOutlet weak var selecteOtherLabel: UITextField!
    var activitytype = ActivitySelect.type.productivity
//    let cellIds = ["SleepingNappingActivityCell","RelaxingDaydreamingDoingNothingActivityCell"]
    
    var selectedActivities = [String]()
    var selectedTypes = [Int]()
    var partsForPrinting = [FullTripPart?]()
    var OtherCellSelected: LegActivityCollectionViewCell?
    
    @IBOutlet weak var TabStackView: UIStackView!
    @IBOutlet weak var SelectProductivityActivitiesButton: UIButton!
    @IBOutlet weak var SelectMindActivitiesButton: UIButton!
    @IBOutlet weak var SelectBodyActivitiesButton: UIButton!
    
//    var selectedCell: LegActivityCollectionViewCell?
    
//    enum Images: String {
//        case baseline_adjust_black
//        case baseline_place_black
//    }
    
    enum cells: String {
        case Start
        case Tube
        case Arrival
        case Transfer
        case Option
    }
    
    enum callbacks: String {
        case MTChooseActivitiesStart
        case MTChooseActivitiesAddActivity
        case MTChooseActivitiesRemoveActivity
        case MTChooseActivitiesEnd
    }
    
    var printingCells = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ActivitiesTableView.delegate = self
        self.ActivitiesTableView.dataSource = self
        self.ActivitiesTableView.register( UINib(nibName: "TubeTableViewCell", bundle: nil), forCellReuseIdentifier: "TubeTableViewCell")
        self.ActivitiesTableView.register( UINib(nibName: "GenericLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "GenericLocationTableViewCell")
//        InitPrintingCells()
        PickActivitiesView.isHidden = true
        activitiesCollectionView.delegate = self
        activitiesCollectionView.dataSource = self
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(showActivitiesToFill), name: NSNotification.Name(rawValue: callbacks.MTChooseActivitiesStart.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HidesActivitiesToFill), name: NSNotification.Name(rawValue: callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
        
//        ConfirmButton.backgroundColor = UIColor(red: 0.88, green: 0.94, blue: 0.99, alpha: 1)
//        ConfirmButton.layer.cornerRadius = 9
//        ConfirmButton.layer.shadowOffset = CGSize(width: 0, height: 2)
//        ConfirmButton.layer.shadowColor = UIColor(red: 0, green: 0.03, blue: 0, alpha: 0.18).cgColor
//        ConfirmButton.layer.shadowOpacity = 1
//        ConfirmButton.layer.shadowRadius = 4
        
        GenericQuestionTableViewCell.loadStandardButton(button: self.ConfirmButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "CONFIRM ALL", disabled: false)
        GenericQuestionTableViewCell.loadStandardButton(button: self.doneButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "DONE", disabled: false)
        StopShowinOtherActivities()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        InitPrintingCells()
        //        DispatchQueue.main.async {
        //            self.SplitTableView.reloadData()
        //        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ShowOtherActivities() {
        self.selecteOtherLabel.isHidden = false
        self.activitiesCollectionView.isHidden = true
        self.TabStackView.isHidden = true
    }
    
    func StopShowinOtherActivities() {
        self.selecteOtherLabel.isHidden = true
        self.activitiesCollectionView.isHidden = false
        self.TabStackView.isHidden = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func EndEditingTextField(_ sender: Any) {
        self.resignFirstResponder()
    }
    
    func InitPrintingCells() {
        printingCells.removeAll()
        partsForPrinting.removeAll()
        if let parts = getFt()?.getTripPartsortedList() {
            let size = parts.count
            printingCells = [String]()
            if size > 0 {
                printingCells.append(cells.Start.rawValue)
                partsForPrinting.append(parts.first)
                printingCells.append(cells.Tube.rawValue)
                partsForPrinting.append(nil)
                var i = 0
                while i < size {
                    let part = parts[i]
                    if let leg = part as? Trip {
                        if leg.wrongLeg {
                            i = i + 1
                            continue
                        }
                    }
                    
                    if  i == 0 {
                        printingCells.append("\(cells.Option.rawValue)\(i)")
                        partsForPrinting.append(part)
                        printingCells.append(cells.Tube.rawValue)
                        partsForPrinting.append(nil)
                    } else if i == size - 1 {
                        printingCells.append("\(cells.Option.rawValue)\(i)")
                        partsForPrinting.append(part)
                        printingCells.append(cells.Tube.rawValue)
                        partsForPrinting.append(nil)
                    } else {
                        printingCells.append("\(cells.Option.rawValue)\(i)")
                        partsForPrinting.append(part)
                        printingCells.append(cells.Tube.rawValue)
                        partsForPrinting.append(nil)
//                        if leg.modeOfTransport == ActivityClassfier.WALKING || leg.modeOfTransport == ActivityClassfier.RUNNING {
//                            //                            printingCells.append("\(cells.Transfer.rawValue)\(i)")
//                            //                            printingCells.append(cells.Tube.rawValue)
//                            printingCells.append("\(cells.Option.rawValue)\(i)")
//                            //                            printingCells.append(cells.Tube.rawValue)
//                            //                            printingCells.append("\(cells.Transfer.rawValue)\(i)")
//                            printingCells.append(cells.Tube.rawValue)
//                        } else {
//
//                            printingCells.append("\(cells.Transfer.rawValue)\(i)")
//                            printingCells.append(cells.Tube.rawValue)
//                            printingCells.append("\(cells.Option.rawValue)\(i)")
//                            printingCells.append(cells.Tube.rawValue)
//                            printingCells.append("\(cells.Transfer.rawValue)\(i)")
//                            printingCells.append(cells.Tube.rawValue)
//                        }
                    }
                    i = i + 1
                }
                printingCells.append(cells.Arrival.rawValue)
                partsForPrinting.append(parts.last)
            }
        }
        if self.ActivitiesTableView != nil {
            self.ActivitiesTableView.reloadData()
        }
    }
    
    override func setFT(ft: FullTrip) {
        super.setFT(ft: ft)
        if self.ActivitiesTableView != nil {
            InitPrintingCells()
            self.ActivitiesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printingCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let returnCell: UITableViewCell
        switch printingCells[indexPath.row] {
        case cells.Start.rawValue:
            let cell = (ActivitiesTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell", for: indexPath) as? GenericLocationTableViewCell)!
            //            cell.setImage(value: GenericLocationTableViewCell.Images.Start)
            cell.loadCell(image: GenericLocationTableViewCell.Images.Start,text: "Starting Location", time: nil)
            returnCell = cell
        case cells.Tube.rawValue:
            let cell = (ActivitiesTableView.dequeueReusableCell(withIdentifier: "TubeTableViewCell", for: indexPath) as? TubeTableViewCell)!
            returnCell = cell
        case cells.Arrival.rawValue:
            let cell = (ActivitiesTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell", for: indexPath) as? GenericLocationTableViewCell)!
            cell.setImage(value: GenericLocationTableViewCell.Images.Arrival)
            cell.loadCell(image: GenericLocationTableViewCell.Images.Arrival,text: "Ending Location", time: self.partsForPrinting[indexPath.row]?.startDate ?? nil)
            returnCell = cell
        default:
            let row = printingCells[indexPath.row]
//            if row.contains(cells.Transfer.rawValue){
//                let rowChanged = row.replacingOccurrences(of: cells.Transfer.rawValue, with: "")
//                let legIdx = Int(rowChanged) ?? 0
//                let part = getFt()?.getTripPartsortedList()[legIdx]
//
//                var ChangeText = ""
//                switch part?.modeOfTransport ?? "" {
//                case ActivityClassfier.WALKING:
//                    ChangeText = "Walking"
//                    break
//                case ActivityClassfier.RUNNING:
//                    ChangeText = "Running"
//                    break
//                case ActivityClassfier.AUTOMOTIVE:
//                    ChangeText = "Parking Lot"
//                    break
//                case ActivityClassfier.CAR:
//                    ChangeText = "Parking Lot"
//                    break
//                case ActivityClassfier.CYCLING:
//                    ChangeText = "Cycling depot"
//                    break
//                case ActivityClassfier.STATIONARY:
//                    ChangeText = "train Station"
//                    break
//                case ActivityClassfier.BUS:
//                    ChangeText = "Bus station"
//                    break
//                case ActivityClassfier.TRAIN:
//                    ChangeText = "train Station"
//                    break
//                case ActivityClassfier.METRO:
//                    ChangeText = "Subway"
//                    break
//                case ActivityClassfier.TRAM:
//                    ChangeText = "Tram Station"
//                    break
//                case ActivityClassfier.FERRY:
//                    ChangeText = "Ferry Station"
//                    break
//                case ActivityClassfier.PLANE:
//                    ChangeText = "Airpoirt"
//                    break
//                case ActivityClassfier.UNKNOWN:
//                    ChangeText = ""
//                    break
//                default:
//                    //            coorrected = modesOfTransport.unknown.rawValue
//                    ChangeText = ""
//                }
//
//                let cell = (ActivitiesTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell", for: indexPath) as? GenericLocationTableViewCell)!
//                cell.setImage(value: GenericLocationTableViewCell.Images.change)
//                cell.loadCell(image: GenericLocationTableViewCell.Images.change,text: ChangeText)
//                returnCell = cell
//            } else {
                let rowChanged = row.replacingOccurrences(of: cells.Option.rawValue, with: "")
                
                let partIdx = Int(rowChanged) ?? 0
                let part = getFt()?.getTripPartsortedList()[partIdx]
                print("index \(partIdx), indexPath: \(indexPath.row) \(indexPath.section)")
                
                if part?.legUserActivities?.count ?? 0 > 0 {
                    let cell = (ActivitiesTableView.dequeueReusableCell(withIdentifier: "ActivitiesValidatedTableViewCell", for: indexPath) as? ActivitiesValidatedTableViewCell)!
                    cell.loadCell(part: part!)
                    returnCell = cell
                } else {
                    let cell = (ActivitiesTableView.dequeueReusableCell(withIdentifier: "ActivitiesUnvalidatedTableViewCell", for: indexPath) as? ActivitiesUnvalidatedTableViewCell)!
                    cell.loadCell(part: part!)
                    returnCell = cell
                }
            
                //                let cell = (ConfimrTableView.dequeueReusableCell(withIdentifier: "UnvalidatedConfirmModeTableViewCell") as? UnvalidatedConfirmModeTableViewCell)!
                ////                cell.loadCell(leg: leg!
                
//            }
        }
        return returnCell
    }
    
    //collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LegActivityCollectionViewCell
        if cell.cellIsSelected {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil, userInfo: ["activity": cell.activity?.text ?? "", "type" : self.activitytype.rawValue])
            cell.deselectCell()
            if let index = selectedActivities.index(of: cell.activity!.text) {
                self.selectedActivities.remove(at: index)
                self.selectedTypes.remove(at: index)
            }
        } else {
            if self.selectedActivities.count < 3 {
                if ActivitySelect.isOther(act: cell.activity!) {
                    self.ShowOtherActivities()
                    self.OtherCellSelected = cell
                } else {
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil, userInfo: ["activity": cell.activity?.text ?? "", "type" : self.activitytype.rawValue])
                    cell.SelectCell()
                    selectedActivities.append(cell.activity!.text)
                    selectedTypes.append(cell.activity!.type.rawValue)
                }
            }
        }
    }
    
    @objc func showActivitiesToFill(_ notification: NSNotification){
        if let activity = notification.userInfo?["activity"] as? [String] {
            self.selectedActivities = activity
        }
        if let activityTypes = notification.userInfo?["activityTypes"] as? [Int] {
            self.selectedTypes = activityTypes
        }
        if let type = notification.userInfo?["type"] as? ActivitySelect.type {
            self.activitytype = type
        }
        
        self.PickActivitiesView.layer.cornerRadius = self.PickActivitiesView.bounds.width * 0.05
        self.PickActivitiesView.layer.masksToBounds = true
        
        self.PickActivitiesView.isHidden = false
        self.activitiesCollectionView.reloadData()
        self.fadeTopViews()
        LoadActivityButtons()
    }
    
    func LoadActivityButtons() {
        switch self.activitytype {
        case .productivity:
            self.SelectProductivityActivitiesButton.setTitleColor(UIColor.white, for: .normal)
            self.SelectProductivityActivitiesButton.backgroundColor = MotivColors.WoortiOrange
            
            self.SelectBodyActivitiesButton.setTitleColor(MotivColors.WoortiGreen, for: .normal)
            self.SelectBodyActivitiesButton.backgroundColor = MotivColors.WoortiGreenT3
            
            self.SelectMindActivitiesButton.setTitleColor(MotivColors.WoortiBlue, for: .normal)
            self.SelectMindActivitiesButton.backgroundColor = MotivColors.WoortiBlueT3
        case .mind:
            self.SelectMindActivitiesButton.setTitleColor(UIColor.white, for: .normal)
            self.SelectMindActivitiesButton.backgroundColor = MotivColors.WoortiBlue
            
            self.SelectBodyActivitiesButton.setTitleColor(MotivColors.WoortiGreen, for: .normal)
            self.SelectBodyActivitiesButton.backgroundColor = MotivColors.WoortiGreenT3
            
            self.SelectProductivityActivitiesButton.setTitleColor(MotivColors.WoortiOrange, for: .normal)
            self.SelectProductivityActivitiesButton.backgroundColor = MotivColors.WoortiOrangeT3
        case .body:
            self.SelectBodyActivitiesButton.setTitleColor(UIColor.white, for: .normal)
            self.SelectBodyActivitiesButton.backgroundColor = MotivColors.WoortiGreen
            
            self.SelectMindActivitiesButton.setTitleColor(MotivColors.WoortiBlue, for: .normal)
            self.SelectMindActivitiesButton.backgroundColor = MotivColors.WoortiBlueT3
            
            self.SelectProductivityActivitiesButton.setTitleColor(MotivColors.WoortiOrange, for: .normal)
            self.SelectProductivityActivitiesButton.backgroundColor = MotivColors.WoortiOrangeT3
        }
        self.SelectProductivityActivitiesButton.layer.cornerRadius = self.SelectProductivityActivitiesButton.bounds.height * 0.1
        self.SelectMindActivitiesButton.layer.cornerRadius = self.SelectMindActivitiesButton.bounds.height * 0.1
        self.SelectBodyActivitiesButton.layer.cornerRadius = self.SelectBodyActivitiesButton.bounds.height * 0.1
    }
    
    @objc func HidesActivitiesToFill(){
        self.PickActivitiesView.isHidden = true
        self.unfadeTopViews()
    }
    
    @objc func notifyActivitiesSelectionEnd() {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
        
        DispatchQueue.main.async {
            self.ActivitiesTableView.reloadData()
        }
    }
    
    @IBAction func ActivitiseDone(_ sender: Any) {
//        HidesActivitiesToFill()
        if !self.selecteOtherLabel.isHidden
            &&
            (self.selecteOtherLabel.text ?? "").count > 0 {
            
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil, userInfo: ["activity": self.selecteOtherLabel.text ?? "", "type" : self.activitytype.rawValue])
            
            selectedActivities.append(LegActivities.ActivityCodeForOther)
            selectedTypes.append(self.activitytype.rawValue)
            
            if let cell = OtherCellSelected {
                cell.SelectCell()
            }
        } else {
            notifyActivitiesSelectionEnd()
        }
        StopShowinOtherActivities()
    }
    
    @IBAction func ClickConfirmAllOrNext(_ sender: Any) {
//        if rated {
            if  let ft = self.getFt() {
                
                for leg in ft.getTripOrderedList() {
                    if let user = MotivUser.getInstance(),
                        let mainText = leg.getMainTextFromRealMotCode(),
                        let code = user.getMotFromText(text: mainText) {
                        
                        user.setSecondaryasMain(mainCode: code.motCode)
                    }
                }
                
                ft.confirmTrip()
            }
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsConfirmTrip.rawValue), object: nil)
//        } else {
//            rated = true
//            DispatchQueue.main.async {
//                self.ActivitiesTableView.reloadData()
//            }
//        }
    }
    
    //LOAD COLECTION VIEW
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActivitySelect.getActivities(type: self.activitytype, modeOfTRansport: UserInfo.partToGiveFeedback!.getModeOftransport()).count
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LegActivityCollectionViewCell", for: indexPath) as! LegActivityCollectionViewCell
        let activities = ActivitySelect.getActivities(type: self.activitytype, modeOfTRansport: UserInfo.partToGiveFeedback!.getModeOftransport())
        
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
        
//        let hasActivity = activities.contains { (activitySelection) -> Bool in
//            selectedActivities.contains(where: { (act) -> Bool in
//                return activitySelection.text == act
//            })
//        }
        
        cell.loadCell(activity: activities[indexPath.item], cellIsSelected: hasActivity)
        
        return cell
//        let cell = activitiesCollectionView.dequeueReusableCell( withReuseIdentifier: cellIds[indexPath.item], for: indexPath)
//        cell.isSelected = selectedActivities.contains(cellIds[indexPath.item])
//        switch indexPath.item {
//        case 0:
//            if self.selectedActivities.contains(ActivitiesValidatedTableViewCell.Images.baseline_adjust_black.rawValue) {
//                cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
//            } else {
//                cell.backgroundColor = UIColor.white
//            }
//        default:
//            if self.selectedActivities.contains(ActivitiesValidatedTableViewCell.Images.baseline_place_black.rawValue) {
//                cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
//            } else {
//                cell.backgroundColor = UIColor.white
//            }
//        }
//        cell.tintColor = UIColor.black
//        return cell
    }
    
    //fading top view
    func fadeTopViews() {
        if let firstFrame = MainView?.bounds {
            fadeView = UIView(frame: firstFrame)
            fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            MainView?.addSubview(fadeView!)
            fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notifyActivitiesSelectionEnd)))
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func unfadeTopViews() {
        
        if fadeView != nil {
            fadeView?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func chooseProductivityActivities(_ sender: Any) {
        if self.activitytype != .productivity {
           self.activitytype = .productivity
            DispatchQueue.main.async {
               self.LoadActivityButtons()
                self.activitiesCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func chooseMindActivities(_ sender: Any) {
        if self.activitytype != .mind {
            self.activitytype = .mind
            DispatchQueue.main.async {
                self.LoadActivityButtons()
                self.activitiesCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func chooseBodyActivities(_ sender: Any) {
        if self.activitytype != .body {
            self.activitytype = .body
            DispatchQueue.main.async {
                self.LoadActivityButtons()
                self.activitiesCollectionView.reloadData()
            }
        }
    }
}
