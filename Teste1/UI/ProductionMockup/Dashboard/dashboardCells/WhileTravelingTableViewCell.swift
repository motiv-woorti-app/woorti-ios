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
 * Dashboard table cell to show most frequent activities while travelling.
 */
class WhileTravelingTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var whileTRavelingLabel: UILabel!
    var other = "Other_Activities"
    var mostUsed = [("Listening To Music",25)]
    var sizeForCells = 44
    var maxElements = 3
    var totalTimeActivities = 0
    
    func reloadTopTextAndPercentage(_ spentPercentage: Int, _ activity: String) {
        let smallSize = 17
        let bigSize = 23
        
        let initialWhileTravellingString = String(format: NSLocalizedString("While_Traveling_Activities", comment: ""), "#", "#")
        
        var splitWhileTravellingString = initialWhileTravellingString.components(separatedBy: "#")
        
        var finalWhileTravellingString = MotivFont.getRegularText(text: splitWhileTravellingString[0], size: smallSize)
        finalWhileTravellingString.append(MotivFont.getBoldText(text: String(format: "%d%% ", spentPercentage), size: bigSize))
        finalWhileTravellingString.append(MotivFont.getRegularText(text: splitWhileTravellingString[1], size: smallSize))
        finalWhileTravellingString.append(MotivFont.getBoldText(text: String(format: "%@.", NSLocalizedString(activity, comment: "")), size: bigSize))
        
        
        MotivFont.motivAttributedFontFor(attributedText: finalWhileTravellingString, label: whileTRavelingLabel)
        
        whileTRavelingLabel.textColor = UIColor.white
        self.tableView.register(UINib(nibName: "ActivityPercentageTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivityPercentageTableViewCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableViewHeight.constant = CGFloat(sizeForCells * min(mostUsed.count,4))
    }
    
    func getTotalTimeActivities() -> Int {
        var totalTime = 0
        for (key,value) in self.mostUsed {
            totalTime += value
        }
        
        return totalTime
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let spentPercentage = 25
        let activity = "listening to music"
        
        reloadTopTextAndPercentage(spentPercentage, activity)
    }
    
    func getHighest() -> (String, Int) {
        return mostUsed.reduce(mostUsed[0], { (max, tuple) -> (String, Int) in
            return tuple.1 > max.1 ? tuple : max
        })
    }
    
    
    func cellLoad(di: DashInfo) {

        self.mostUsed = di.activitiesInfo.reduce([(String, Int)](), { (prev, curent) -> [(String, Int)] in
            var returnValue = prev
            returnValue.append((curent.key, Int(curent.value)))
            return returnValue
        })
        
        //sort
        self.mostUsed.sort { (v1, v2) -> Bool in
            v1.1 > v2.1
        }
        
        totalTimeActivities = getTotalTimeActivities()
        
        //reload
        self.reloadViews()
    }
    
    func reloadViews() {
        if Thread.isMainThread {
            if let first = mostUsed.first {
                tableViewHeight.constant = CGFloat(sizeForCells * min(mostUsed.count+1,5))
                
                reloadTopTextAndPercentage(Int((Float(first.1) / Float(totalTimeActivities)) * 100), first.0)
                self.tableView.reloadData()
            } else {
                tableViewHeight.constant = CGFloat(0)
                whileTRavelingLabel.isHidden = true
                self.tableView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.reloadViews()
            }
        }
    }
    
    func sortMotsUsed() {
         self.mostUsed = self.mostUsed.sorted { (a, b) -> Bool in
            a < b
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("while_travelling num cells \(min(mostUsed.count, 4))")
        return min(mostUsed.count, 4)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityPercentageTableViewCell") as! ActivityPercentageTableViewCell
        print("while_travelling cell \(indexPath.row)")
        if indexPath.row < 3 {
            let valueToLoad = mostUsed[indexPath.row]
            cell.cellLoad(text: NSLocalizedString(valueToLoad.0, comment: ""), value: Int((Float(valueToLoad.1) / Float(totalTimeActivities)) * 100))
        } else {
            let valueToLoad = (NSLocalizedString("Other_Activities", comment: ""), getOtherValue())
            cell.cellLoad(text: NSLocalizedString(valueToLoad.0, comment: ""), value: Int((Float(valueToLoad.1) / Float(totalTimeActivities)) * 100))
        }
        return cell
    }
    
    func getOtherValue() -> Int {
        var index = 3
        var otherTime = 0
        while index < mostUsed.count {
            otherTime += mostUsed[index].1
            index += 1
        }
        return otherTime
    }
    
    func getSizeForMe() -> CGFloat {
        if let first = mostUsed.first {
            return CGFloat(sizeForCells * min(mostUsed.count,4)) + CGFloat(20 + (4 * 30))
        }
        return CGFloat(0)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(sizeForCells)
    }
}
