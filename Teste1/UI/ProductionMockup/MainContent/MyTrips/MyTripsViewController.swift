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
 * Main controller for my trips section. 
 */
class MyTripsViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var TripsTableView: UITableView!
    var dict = [TimeInterval: [FullTrip]]()
    var dictOrdered = [(TimeInterval, [FullTrip])]()
    
    @IBOutlet weak var CurrentTripButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var CurrentTripButton: UIButton!
    
    static let CHANGETOCONFIRMTRIP = "StartConfirmTrip"
    static let CHANGETOEDITTRIP = "ShowEditTripOptions"
    static let StartedOrFinishedTrip = "MyTripsViewControllerStartedOrFinishedTrip"
    var ftToGo: FullTrip?
    
    @IBOutlet weak var stopTripLabel: UILabel!
    @IBOutlet weak var startStopTripButton: UIButton!
    
    enum MyTipsObserver: String {
        case MTconfirmTrip
        case MTeditTrip = "MyTipsObserverMTeditTrip"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TripsTableView.dataSource = self
        TripsTableView.delegate = self
        TripsTableView.register(UINib.init(nibName: "DayTripTableViewCell", bundle: nil), forCellReuseIdentifier: "DayTripTableViewCell")
        self.TripsTableView.translatesAutoresizingMaskIntoConstraints = false
        processFulltripsForPresentation()
        MotivAuxiliaryFunctions.loadStandardButton(button: CurrentTripButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, text: "View current Trip", boldText: false, size: 15, disabled: false)
        refreashTripState()
        print("viewDidLoadMT")
        
        NotificationCenter.default.addObserver(self, selector: #selector(editTrip), name: NSNotification.Name(rawValue: MyTripsViewController.MyTipsObserver.MTeditTrip.rawValue), object: nil)
        
        self.view.backgroundColor = MotivColors.WoortiOrangeT2
        
    }
    
    @objc func editTrip() {
        self.performSegue(withIdentifier: MyTripsViewController.CHANGETOEDITTRIP, sender: self)
    }
    
    fileprivate func refreashTripState() {
        if Thread.isMainThread {
            if DetectLocationModule.processLocationData.state != ProcessLocationData.LocationStates.stoped {
                MotivFont.motivBoldFontFor(key: "Trip_Being_Recorded", comment: " message: A trip is being recorded now", label: self.stopTripLabel, size: 9)
                self.stopTripLabel.textColor = MotivColors.WoortiOrange
                MotivAuxiliaryFunctions.loadStandardButton(button: self.startStopTripButton, bColor: MotivColors.WoortiRed, tColor: UIColor.white, key: "End_Trip", comment: "message: End Trip", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                self.CurrentTripButtonHeight.constant = 0
            } else {
                MotivFont.motivBoldFontFor(text: "", label: self.stopTripLabel, size: 9)
                MotivAuxiliaryFunctions.loadStandardButton(button: self.startStopTripButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Start_Trip", comment: "message: Start trip", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.white, CompleteRoundCorners: true)
                self.CurrentTripButtonHeight.constant = 0
                
                processFulltripsForPresentation()
                
                DispatchQueue.main.async {
                    self.TripsTableView.reloadData()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.refreashTripState()
            }
        }
    }
    
    @objc func reload() {
        if self.presentedViewController == nil {
            processFulltripsForPresentation()
            DispatchQueue.main.async {
                self.TripsTableView.reloadData()
                self.refreashTripState()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reload()
        UiAlerts.getInstance().newView(view: self)
        print("viewFlow: did appear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.TripsTableView.reloadData()
        }
        print("viewFlow: appearing")
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editTrip), name: NSNotification.Name(rawValue: MyTripsViewController.MyTipsObserver.MTeditTrip.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewFlow: Disapearing")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewFlow: did Disapear")
    }
    
    @IBAction func seeCurrentTrip(_ sender: Any) {
        let currentFT = UserInfo.getFullTrips().last
        self.ftToGo = currentFT
        self.performSegue(withIdentifier: MyTripsViewController.CHANGETOCONFIRMTRIP, sender: nil)
    }
    
    func getDateFromDateTime(date: Date, dayDistance: Int = 0) -> Date{
        let calendar = NSCalendar.current
        var c = DateComponents()
        
        c.year = calendar.component( .year, from: date)
        c.month = calendar.component( .month, from: date)
        c.day = calendar.component( .day, from: date) + dayDistance
        c.hour = 12
        c.minute = 0
        c.second = 0
        
        // Get NSDate given the above date components
        return (NSCalendar.current.date(from: c))!
    }
    
    func getDateForTrips(ft: FullTrip) -> Date {
        return getDateFromDateTime(date: ft.startDate!)
    }
    
    func processFulltripsForPresentation() {
        if Thread.isMainThread {
            dict.removeAll()
            for ft in UserInfo.getFullTrips() {
                if ft.closed {
                    let date = getDateForTrips(ft: ft)
                    if dict[date.timeIntervalSince1970] == nil {
                       dict[date.timeIntervalSince1970] = [FullTrip]()
                    }
                    
                    dict[date.timeIntervalSince1970]?.append(ft)
                }
            }
            
            self.dictOrdered = dict.sorted(by: { (v1, v2) -> Bool in
                v1.key>v2.key
            })
            
            
            self.dictOrdered = self.dictOrdered.map { (tuple) -> (TimeInterval,[FullTrip]) in
                return (tuple.0,
                 tuple.1.sorted(by: { (ft1, ft2) -> Bool in
                    ft1.startDate ?? Date() > ft2.startDate ?? Date()
                 })
                )
            }
            
            if dictOrdered.count > 0{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowshowEdit.rawValue), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.ShowHideEdit.rawValue), object: nil)
            }
            
            self.TripsTableView.reloadData()
        } else {
            DispatchQueue.main.sync {
                processFulltripsForPresentation()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayTripTableViewCell", for: indexPath) as! DayTripTableViewCell
        
        //        let key = Array(self.dict.keys)[indexPath.row]
        //        let fts = self.dict[key]!
        let tuple = dictOrdered[indexPath.row]
        cell.loadcell(parent: self, fts: tuple.1, key: tuple.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getSizeForRow(ind: indexPath.row)
    }
    
    func getSizeForRow(ind: Int) -> CGFloat {
        let fts = dictOrdered[ind].1
        return CGFloat(21 + 21 + (fts.count * 119))
    }
    
    func updateParent() {
        UIView.animate(withDuration: 0.3) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func startStopClick(_ sender: Any) {
        StartStopRunningTRansportDetection()
    }
    
    func StartStopRunningTRansportDetection() {
        DispatchQueue.global(qos: .userInitiated).async {
            if DetectLocationModule.processLocationData.state != ProcessLocationData.LocationStates.stoped {
                DetectLocationModule.processLocationData.forceStopTripOnCurrentLocation(fromUI: true)
            } else {
                UserInfo.closeOpenedTrips()
                PowerManagementModule.startRunningTRansportDetection()
                DetectLocationModule.processLocationData.startFullTrip(fromUI: true) //force the start of a new Trip
            }
            self.refreashTripState()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == MyTripsViewController.CHANGETOCONFIRMTRIP {
            if let dest = segue.destination as? MyTripsGenericViewController {
                dest.ftToConfirm = self.ftToGo!
            }
        } else if segue.identifier == MyTripsViewController.CHANGETOEDITTRIP {
            if let dest = segue.destination as? OptionsMenuViewController {
                dest.Trip = true
            }
        }
    }
 
    
}
