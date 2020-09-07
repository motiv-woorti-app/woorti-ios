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

class ChoosePartForFeedBackViewController: MTGenericViewController, UITableViewDelegate, UITableViewDataSource {

    var printingCells = [String]()
    var partsForPrinting = [FullTripPart?]()
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    enum cells: String {
        case Start
        case Tube
        case Arrival
        case Transfer
        case Option
    }
    
    // table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printingCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let returnCell: UITableViewCell
        switch printingCells[indexPath.row] {
        case cells.Start.rawValue:
            let cell = (tableView.dequeueReusableCell(withIdentifier: "MytripsGenericMotTableViewCell") as? MytripsGenericMotTableViewCell)!

            cell.loadCell(image: MytripsGenericMotTableViewCell.Images.Start ,text: "\(getFt()?.startLocation ?? "")", time: nil)
            returnCell = cell
        case cells.Tube.rawValue:
            let cell = (tableView.dequeueReusableCell(withIdentifier: "MyTripsTubeTableViewCell") as? MyTripsTubeTableViewCell)!
            returnCell = cell
        case cells.Arrival.rawValue:
            let cell = (tableView.dequeueReusableCell(withIdentifier: "MytripsGenericMotTableViewCell") as? MytripsGenericMotTableViewCell)!

            cell.loadCell(image: MytripsGenericMotTableViewCell.Images.Arrival ,text: "\(getFt()?.startLocation ?? "")", time: getFt()?.endDate ?? Date())
            returnCell = cell
        case cells.Transfer.rawValue:
            
            let cell = (tableView.dequeueReusableCell(withIdentifier: "MytripsGenericMotTableViewCell") as? MytripsGenericMotTableViewCell)!

            let transfer = NSLocalizedString("Transfer", comment: "message: Transfer")
            cell.loadCell(image: MytripsGenericMotTableViewCell.Images.change ,text: transfer, time: partsForPrinting[indexPath.row]?.startDate ?? nil)
            cell.setBackgroundToWhite()
            returnCell = cell
            




        default:
            let row = printingCells[indexPath.row]
            let rowChanged = row.replacingOccurrences(of: cells.Option.rawValue, with: "")
            
            let partIdx = Int(rowChanged) ?? 0
            let part = getFt()?.getTripPartsortedList()[partIdx]
            let cell = (tableView.dequeueReusableCell(withIdentifier: "MytripsGenericMotTableViewCell") as? MytripsGenericMotTableViewCell)!

            cell.loadCell(part: part!)
            cell.setBackgroundToWhite()
            returnCell = cell
        }
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch printingCells[indexPath.row] {
        case cells.Tube.rawValue:
            return CGFloat(20)
        default:
            return CGFloat(50)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tv.cellForRow(at: indexPath) as? MytripsGenericMotTableViewCell,
            let part = cell.part {
            UserInfo.partToGiveFeedback = part
            GoToNextScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = MotivColors.WoortiOrangeT2
        // Do any additional setup after loading the view.
        InitPrintingCells()
        self.view.backgroundColor = MotivColors.WoortiOrangeT2
        MotivFont.motivBoldFontFor(key: "Select_Part_Of_Trip_Feedback", comment: "Select one part of your trip for further feedback", label: self.titleLabel, size: 15)
        titleLabel.textColor = MotivColors.WoortiOrange
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
//        GoToNextScreen()
    }
    
    //List management
    func InitPrintingCells() {
        printingCells.removeAll()
        partsForPrinting.removeAll()
        if let parts = getFt()?.getTripPartsortedList() {
            let size = parts.count
            printingCells = [String]()
            if size > 0 {
                printingCells.append(cells.Start.rawValue)
                partsForPrinting.append(parts[0])
                printingCells.append(cells.Tube.rawValue)
                partsForPrinting.append(parts[0])
                var i = 0
                while i < size {
                    if parts[i].isKind(of: Trip.self) {
                        if (parts[i] as! Trip).wrongLeg {
                            i = i + 1
                            continue
                        }
                        printingCells.append("\(cells.Option.rawValue)\(i)")
                        partsForPrinting.append(parts[i])
                        printingCells.append(cells.Tube.rawValue)
                        partsForPrinting.append(nil)
                    } else if parts[i].isKind(of: WaitingEvent.self) {
                        printingCells.append("\(cells.Option.rawValue)\(i)")
                        partsForPrinting.append(parts[i])
                        printingCells.append(cells.Tube.rawValue)
                        partsForPrinting.append(nil)
                        
//                        printingCells.append(cells.Transfer.rawValue)
//                        partsForPrinting.append(parts[i])
//                        printingCells.append(cells.Tube.rawValue)
//                        partsForPrinting.append(nil)
                    }
                    //                    }
                    i = i + 1
                }
                printingCells.append(cells.Arrival.rawValue)
                partsForPrinting.append(parts[i-1])
            }
        }
        if printingCells.count == 1 {
            if let part = getFt()!.getTripPartsortedList().first {
                UserInfo.partToGiveFeedback = part
                GoToNextScreen()
            }
        }
        if self.tv != nil {
            self.tv.reloadData()
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
    
    func GoToNextScreen() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.MyTripswastedTripPage.rawValue), object: nil)
    }
}
