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

class ChooseCDFactorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var values = ["Cleanliness inside","Seating availability (onboard)","Air quality","Temperature","Personal space (crowd level)","Privacy","Jerkiness/Motion Sickness","Design/Arquitecture","Maintenance (upkeep/repair)","Cleanliness Outside","Seating availability (outside)","Air Polution","Noise","Traffic (congestion)","Pleasentness (ambience)","Smoothness (pavement/floors)","Accessibility (ease to get to or through)"]
    
    var codes = ["CLEANLINESS_INSIDE", "SEATING_AVAILABILITY_INSIDE", "AIR_QUALITY", "TEMPERATURE", "PERSONAL_SPACE", "PRIVACY", "JERKINESS", "DESIGN", "MAINTENANCE", "CLEANLINESS_OUTSIDE", "SEATING_AVAILABILITY_OUTSIDE", "AIR_POLLUTION", "NOISE", "TRAFFIC", "PLEASANTNESS", "SMOOTHLESS", "ACCESSIBILITY"]
    
    var selectedValues = [String]()
    
    @IBOutlet weak var chooseTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var ContainedIn: ComfortAndDiscomfortFactorsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseTableView.delegate = self
        chooseTableView.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
        tableViewHeightConstraint.constant = CGFloat(50 * values.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCDTableViewCell") as! chooseCDTableViewCell
        let value = values[indexPath.row]
        let isSelected = selectedValues.contains(value)
        cell.loadCell(Text: value, selected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! chooseCDTableViewCell
        cell.toggleCell()
        let (selected, text) = cell.getCellSelected()
        if selected {
            selectedValues.append(text)
        } else if let ind = selectedValues.index(of: text) {
            selectedValues.remove(at: ind)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    @IBAction func clickDone(_ sender: Any) {
        if let parent = self.ContainedIn {
            parent.processDone(vc: self)
        }
    }
}
