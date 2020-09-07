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

class SMDSplitViewController: MTGenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var SplitTableView: UITableView!
    var listToLoad = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SplitTableView.delegate = self
        self.SplitTableView.dataSource = self
        // Do any additional setup after loading the view.
        self.SplitTableView.register( UINib(nibName: "SMDStartTableViewCell", bundle: nil), forCellReuseIdentifier: "SMDStartTableViewCell")
        self.SplitTableView.register( UINib(nibName: "SMDSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "SMDSelectTableViewCell")
        self.SplitTableView.register( UINib(nibName: "TubeTableViewCell", bundle: nil), forCellReuseIdentifier: "TubeTableViewCell")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopSetTitle.rawValue), object: nil, userInfo: ["title" : "Split"])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopHideButton.rawValue), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadTable()
        DispatchQueue.main.async {
            self.SplitTableView.reloadData()
        }
    }
    
    func createTube() {
        let tube = (SplitTableView.dequeueReusableCell(withIdentifier: "TubeTableViewCell") as? TubeTableViewCell)!
        MotivAuxiliaryFunctions.RoundView(view: tube)
        self.listToLoad.append(tube)
    }
    
    func loadTable(){
        let list = (getFt()?.getTripPartsortedList() ?? [FullTripPart]()).filter { (part) -> Bool in
            if let leg = part as? Trip {
                return !leg.wrongLeg
            }
            return true
        }
        self.listToLoad.removeAll()
        
        self.createSTAcells(type: SMDStartTableViewCell.Images.Start, text: (getFt()?.getStartLocation() ?? "Start Location"), date: nil)
        createTube()
        for part in list {
            switch part {
            case let leg as Trip:
                if leg.wrongLeg {
                    continue
                }
                let cell = (SplitTableView.dequeueReusableCell(withIdentifier: "SMDSelectTableViewCell") as? SMDSelectTableViewCell)!
                cell.loadCell(leg: leg)
                MotivAuxiliaryFunctions.RoundView(view: cell)
                self.listToLoad.append(cell)
            case let we as WaitingEvent:
                let transfer = NSLocalizedString("Transfer", comment: "message: Transfer")
                self.createSTAcells(type: SMDStartTableViewCell.Images.change, text: transfer, date: we.startDate ?? nil)
            default:
                self.createSTAcells(type: SMDStartTableViewCell.Images.change, text: "Error!!", date: nil)
            }
            createTube()
        }
        self.createSTAcells(type: SMDStartTableViewCell.Images.Arrival, text: (getFt()?.getEndLocation() ?? "End Location"), date: list.last?.startDate ?? nil)
    }
    
    func createSTAcells(type: SMDStartTableViewCell.Images, text: String, date: Date?){
        let cell = (SplitTableView.dequeueReusableCell(withIdentifier: "SMDStartTableViewCell") as? SMDStartTableViewCell)!
        cell.loadCell(type: type, textLabel: text, date: date)
        MotivAuxiliaryFunctions.RoundView(view: cell)
        self.listToLoad.append(cell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToLoad.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.listToLoad[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SMDSelectTableViewCell {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MTViews.SMDMyTripsSplitMap.rawValue), object: nil, userInfo: ["parts": [cell.leg], "type": SplitMapViewViewController.mapType.split])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch listToLoad[indexPath.row] {
        case let _ as TubeTableViewCell:
            return CGFloat(20)
        default:
            return CGFloat(50)
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
