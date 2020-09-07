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

class RateTripViewController: MTGenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var rateTableView: UITableView!
    @IBOutlet weak var confirmAllButton: UIButton!
    var rated = false
    
    //variables to send to rate screen:
    var part: FullTripPart?
    var productive: Bool?
    
    enum Callback: String {
        case ShowCDFactorsRatings
    }
    
    enum cells: String {
        case Start
        case Tube
        case Arrival
        case Transfer
        case Option
    }
    var partsForPrinting = [FullTripPart?]()
    var printingCells = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rateTableView.delegate = self
        self.rateTableView.dataSource = self
        self.rateTableView.register( UINib(nibName: "TubeTableViewCell", bundle: nil), forCellReuseIdentifier: "TubeTableViewCell")
        self.rateTableView.register( UINib(nibName: "GenericLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "GenericLocationTableViewCell")
//        InitPrintingCells()
        
//        confirmAllButton.backgroundColor = UIColor(red: 0.88, green: 0.94, blue: 0.99, alpha: 1)
//        confirmAllButton.layer.cornerRadius = 9
//        confirmAllButton.layer.shadowOffset = CGSize(width: 0, height: 2)
//        confirmAllButton.layer.shadowColor = UIColor(red: 0, green: 0.03, blue: 0, alpha: 0.18).cgColor
//        confirmAllButton.layer.shadowOpacity = 1
//        confirmAllButton.layer.shadowRadius = 4
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCDScreens), name: NSNotification.Name(rawValue: RateTripViewController.Callback.ShowCDFactorsRatings.rawValue), object: nil)
        
        GenericQuestionTableViewCell.loadStandardButton(button: self.confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "CONFIRM ALL", disabled: false)
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "RelaxStarRating" {
//            if let relax = segue.destination as? StarRatingViewController {
//                self.RelaxingRating = relax
//                relax.loadView(text: "Relaxing")
//            }
//        } else if segue.identifier == "ProductivityStarRating" {
//            if let productivity = segue.destination as? StarRatingViewController {
//                self.Productivityrating = productivity
//                productivity.loadView(text: "Productivity")
//            }
//        }
//    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch printingCells[indexPath.row] {
        case cells.Start.rawValue, cells.Arrival.rawValue:
            return CGFloat(44)
        case cells.Tube.rawValue:
            return CGFloat(44)
            //            case cells.Option.rawValue:
        //                return CGFloat(121)
        default:
            if printingCells[indexPath.row].contains(cells.Transfer.rawValue) {
                return CGFloat(44)
            }
            if printingCells[indexPath.row].contains(cells.Option.rawValue) {
                let row = printingCells[indexPath.row]
                let rowChanged = row.replacingOccurrences(of: cells.Option.rawValue, with: "")
                let legIdx = Int(rowChanged) ?? 0
                let leg = getFt()?.getTripPartsortedList()[legIdx]
                if rated {
                    return CGFloat(82)
                } else {
                    return CGFloat(121)
                }
            }
            return CGFloat(121)
        }
    }
    
//    @IBOutlet weak var ConfimrTableView: UITableView!
    
    
    func InitPrintingCells() {
        printingCells.removeAll()
        partsForPrinting.removeAll()
        if let part = getFt()?.getTripPartsortedList() {
            let size = part.count
            printingCells = [String]()
            if size > 0 {
                printingCells.append(cells.Start.rawValue)
                partsForPrinting.append(part.first)
                printingCells.append(cells.Tube.rawValue)
                partsForPrinting.append(nil)
                var i = 0
                while i < size {
                    let part = part[i]
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
//                        if part.modeOfTransport == ActivityClassfier.WALKING || part.modeOfTransport == ActivityClassfier.RUNNING {
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
                partsForPrinting.append(part.last)
            }
        }
        if self.rateTableView != nil {
            self.rateTableView.reloadData()
        }
    }
    
    override func setFT(ft: FullTrip) {
        super.setFT(ft: ft)
        if self.rateTableView != nil {
            InitPrintingCells()
            self.rateTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printingCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let returnCell: UITableViewCell
        switch printingCells[indexPath.row] {
        case cells.Start.rawValue:
            let cell = (rateTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell", for: indexPath) as? GenericLocationTableViewCell)!
            //            cell.setImage(value: GenericLocationTableViewCell.Images.Start)
            cell.loadCell(image: GenericLocationTableViewCell.Images.Start,text: "Starting Location", time: nil)
            returnCell = cell
        case cells.Tube.rawValue:
            let cell = (rateTableView.dequeueReusableCell(withIdentifier: "TubeTableViewCell", for: indexPath) as? TubeTableViewCell)!
            returnCell = cell
        case cells.Arrival.rawValue:
            let cell = (rateTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell", for: indexPath) as? GenericLocationTableViewCell)!
            cell.setImage(value: GenericLocationTableViewCell.Images.Arrival)
            cell.loadCell(image: GenericLocationTableViewCell.Images.Arrival,text: "Ending Location", time: self.partsForPrinting[indexPath.row]?.startDate ?? nil)
            returnCell = cell
        default:
            let row = printingCells[indexPath.row]
//            if row.contains(cells.Transfer.rawValue){
//                let rowChanged = row.replacingOccurrences(of: cells.Transfer.rawValue, with: "")
//                let legIdx = Int(rowChanged) ?? 0
//                let leg = getFt()?.getTripOrderedList()[legIdx]
//
//                var ChangeText = ""
//                switch leg?.modeOfTransport ?? "" {
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
//                let cell = (rateTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell", for: indexPath) as? GenericLocationTableViewCell)!
//                cell.setImage(value: GenericLocationTableViewCell.Images.change)
//                cell.loadCell(image: GenericLocationTableViewCell.Images.change,text: ChangeText)
//                returnCell = cell
//            } else {
                let rowChanged = row.replacingOccurrences(of: cells.Option.rawValue, with: "")
                
                let partIdx = Int(rowChanged) ?? 0
                let part = getFt()?.getTripPartsortedList()[partIdx]
                print("index \(partIdx), indexPath: \(indexPath.row) \(indexPath.section)")
                
                if rated {
                    let cell = (rateTableView.dequeueReusableCell(withIdentifier: "RateValidatedTableViewCell", for: indexPath) as? RateValidatedTableViewCell)!
                    cell.loadCell(part: part!)
                    returnCell = cell
                } else {
                    let cell = (rateTableView.dequeueReusableCell(withIdentifier: "RateUnvalidatedTableViewCell", for: indexPath) as? RateUnvalidatedTableViewCell)!
                    cell.loadCell(part: part!)
                    returnCell = cell
                }
//            }
        }
        return returnCell
    }
    
    @IBAction func ClickConfirmAllOrNext(_ sender: Any) {
        if rated {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsActivitiesTrip.rawValue), object: nil)
        } else {
            rated = true
            DispatchQueue.main.async {
                self.confirmAllButton.setTitle("Next", for: .normal)
                self.rateTableView.reloadData()
            }
        }
    }
    
    @objc func showCDScreens(_ notification: NSNotification){
        if  let part = notification.userInfo?["part"] as? FullTripPart,
            let productive = notification.userInfo?["productive"] as? Bool {
//            self.selectedActivities = activity
            self.part = part
            self.productive = productive
        }
        self.performSegue(withIdentifier: "RateOne", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let cdFactors as ComfortAndDiscomfortFactorsViewController:
            if  let part = self.part,
                let productive = self.productive{
                
                cdFactors.load(part: part, productive: productive)
            }
        default:
            break
        }
    }
}
