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

class SplitMergeDeleteTripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static let TripDayTableViewCell = "TripDayTableViewCell"
    static let ShowSMDTripViewController = "ShowSMDTripViewController"
    
    var option = optionsEnum.merge
    var firstDone = 0
    
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mergeDoneButton: UIButton!
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var sectionLabel: UILabel!
    
    @IBOutlet weak var mergeButton: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var fts = [Date: [FullTrip]]()
    var ftsOrdered = [(Date, [FullTrip])]()
    var selectedTrips = [FullTrip]()
    
    enum optionsEnum {
        case merge, split, delete
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tv.reloadData()
        self.tableViewHeight.constant = self.getFullSizeOfTV()
        firstDone+=1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tv.reloadData()
        self.tableViewHeight.constant = self.getFullSizeOfTV()
        firstDone+=1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        self.tv.backgroundColor = MotivColors.WoortiBlackT3
        self.mergeDoneButton.isHidden = true
        // Do any additional setup after loading the view.
        let gr = UITapGestureRecognizer(target: self, action: #selector(close))
        closeImage.addGestureRecognizer(gr)
        
        closeImage.image = closeImage.image?.withAlignmentRectInsets(UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20))
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.mergeDoneButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Done", comment: "", boldText: true, size: 15, disabled: false)

        loadHeader()
        loadFTS()
        self.tv.register(UINib(nibName: SplitMergeDeleteTripsViewController.TripDayTableViewCell, bundle: nil), forCellReuseIdentifier: SplitMergeDeleteTripsViewController.TripDayTableViewCell)
        self.tv.dataSource = self
        self.tv.delegate = self
        self.tableViewHeight.constant = self.getFullSizeOfTV()
    }
    
    func reloadView() {
        loadFTS()
        DispatchQueue.main.async {
            self.tv.reloadData()
        }
    }
    
    func loadHeader() {
        switch option {
        case .merge:
            if firstDone > 1 {
                mergeDoneButton.isHidden = false
            } else {
                mergeDoneButton.isHidden = true
            }
            MotivFont.motivRegularFontFor(key: "merge", comment: "message: Merge", label: self.titleLabel, size: 15)
            self.titleLabel.textColor = UIColor.white
            MotivFont.motivRegularFontFor(key: "Select_Trips_To_Merge", comment: "message: Select trips from the list below to merge", label: self.sectionLabel, size: 15)
            self.sectionLabel.textColor = MotivColors.WoortiOrange
            self.mergeButton.isHidden = false
            self.mergeButton.isUserInteractionEnabled = true
            MotivAuxiliaryFunctions.loadStandardButton(button: self.mergeButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "Merge", boldText: true, size: 15, disabled: false)
        case .split:
            mergeDoneButton.isHidden = true
            MotivFont.motivRegularFontFor(key: "split", comment: "message: Split", label: self.titleLabel, size: 15)
            self.titleLabel.textColor = UIColor.white
            MotivFont.motivRegularFontFor(key: "Select_Trips_To_Split", comment: "message: Select trips from the list below to split", label: self.sectionLabel, size: 15)
            self.sectionLabel.textColor = MotivColors.WoortiOrange
            self.mergeButton.isHidden = true
            self.mergeButton.isUserInteractionEnabled = true
            MotivAuxiliaryFunctions.loadStandardButton(button: self.mergeButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "Merge", boldText: true, size: 15, disabled: false)
        case .delete:
            mergeDoneButton.isHidden = true
            MotivFont.motivRegularFontFor(key: "delete", comment: "message: Delete", label: self.titleLabel, size: 15)
            self.titleLabel.textColor = UIColor.white
            MotivFont.motivRegularFontFor(key: "Select_Trips_To_Delete", comment: "message: Select trips from the list below to delete", label: self.sectionLabel, size: 15)
            self.sectionLabel.textColor = MotivColors.WoortiOrange
            self.mergeButton.isHidden = false
            self.mergeButton.isUserInteractionEnabled = true
            MotivAuxiliaryFunctions.loadStandardButton(button: self.mergeButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "Delete", boldText: true, size: 15, disabled: false)
        }
    }
    
    @IBAction func doneClick(_ sender: Any) {
        close()
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectTrip(ft: FullTrip) {
        switch option {
        case .merge:
            if let ind = selectedTrips.index(of: ft) {
                selectedTrips.remove(at: ind)
            } else {
                selectedTrips.append(ft)
            }
        case .split:
            self.selectedTrips.append(ft)
            GoToSMDMap()
            break
        case .delete:
            if let ind = selectedTrips.index(of: ft) {
                selectedTrips.remove(at: ind)
            } else {
                selectedTrips.append(ft)
            }
        }
    }
    
    @IBAction func MergeDeleteButton(_ sender: Any) {
        GoToSMDMap()
    }
    
    func GoToSMDMap() {
        switch option {
        case .merge:
            if selectedAreContiguous() {
                self.performSegue(withIdentifier: SplitMergeDeleteTripsViewController.ShowSMDTripViewController, sender: self)
            } else {
                UiAlerts.getInstance().newView(view: self)
                UiAlerts.getInstance().showAlertMsg(title: "error when merging trips", message: "You must select contiguous Trips to merge")
            }
            break
        case .delete:
            self.performSegue(withIdentifier: SplitMergeDeleteTripsViewController.ShowSMDTripViewController, sender: self)
            break
        case .split:
            self.performSegue(withIdentifier: SplitMergeDeleteTripsViewController.ShowSMDTripViewController, sender: self)
            break
        }
    }
    
    func selectedAreContiguous() -> Bool {
        let fullTrips = UserInfo.getFullTrips().sorted(by: { (v1, v2) -> Bool in
            v1.startDate ?? Date() > v2.startDate ?? Date()
        })
        
        var indexList = self.selectedTrips.map { (ft) -> Int in
            return fullTrips.index(of: ft) ?? -2
        }
        
        indexList = indexList.sorted()
        
        for ind in 0...(indexList.count-2) {
            let diff = indexList[ind] - indexList[ind+1]
            if diff == 1 || diff == -1 {
               continue
            } else {
                return false
            }
        }
        
        return true
    }
    
    func loadFTS() {
        for ft in UserInfo.getFullTrips() {
            if ft.closed {
                let tripDay = UserInfo.getDateForTrips(ft: ft)
                if (self.fts.index(forKey: tripDay) == nil) {
                    self.fts[tripDay] = [ft]
                } else {
                    self.fts[tripDay]!.append(ft)
                }
            }
        }
        
        self.ftsOrdered = fts.sorted(by: { (v1, v2) -> Bool in
            v1.key>v2.key
        })
        
        self.ftsOrdered = self.ftsOrdered.map { (tuple) -> (Date,[FullTrip]) in
            return (tuple.0,
                    tuple.1.sorted(by: { (ft1, ft2) -> Bool in
                        ft1.startDate ?? Date() > ft2.startDate ?? Date()
                    })
            )
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SplitMergeDeleteTripsViewController.TripDayTableViewCell) as! TripDayTableViewCell
        
        cell.setTripsToShow(fts: ftsOrdered[indexPath.row].1, date: ftsOrdered[indexPath.row].0, selectable: !(option == .split), parent: self)
        
        return cell
    }
    
    func getFullSizeOfTV() -> CGFloat {
        var size = CGFloat(0)
        for ind in 0...(ftsOrdered.count-1) {
            size.add(calcSizeForRow(row: ind))
        }
        return size
    }
    
    func calcSizeForRow(row: Int) -> CGFloat {
        let fts = ftsOrdered[row].1
        let ftsSize = fts.count*109
        let fullSize = ftsSize+10+10+21
        return CGFloat(fullSize)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calcSizeForRow(row: indexPath.row)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let mapview as SMDTripViewController:
            var option = SMDTripViewController.optionEnum.merge
            if self.option == .delete {
                option = SMDTripViewController.optionEnum.delete
            } else if self.option == .split {
                option = SMDTripViewController.optionEnum.split
            }
            mapview.parentVC = self
            mapview.loadViewController(option: option, fts: self.selectedTrips)
        default:
            break
        }
        
    }
}


