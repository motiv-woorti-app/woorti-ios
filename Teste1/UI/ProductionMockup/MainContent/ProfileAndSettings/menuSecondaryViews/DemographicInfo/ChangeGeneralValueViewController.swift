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

class ChangeGeneralValueViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {

    var valuesToPrint = valueForEducationalBackgrounds()
    var requester: GeneralInfoViewController?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var clicked = false
    var queue = DispatchQueue(label: "handleClick")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up talbeview
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valuesToPrint.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAValueTableViewCell") as! ChooseAValueTableViewCell
        cell.loadCell(label: valuesToPrint.getText(forRow: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        queue.sync {
            if !clicked {
                clicked = true
                //send value to past view
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil, userInfo: ["returnValue":valuesToPrint.getText(forRow: indexPath.row)])
                
                //go back
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.ProfileBack.rawValue), object: nil)
            }
        }
    }
}

class valueForEducationalBackgrounds {
    
    let EducationalBackgrounds = ["Nursery school to 8th grade","Some high school, no diploma","High school graduate, diploma or the equivalent (for example: GED)","Some college credit, no degree","Trade/technical/vocational training","Bachelor’s degree","Master’s degree","Professional degree","Doctorate degree","Associate degree","No Instituitional Schooling"]
    
    func getTitle() -> String {
        return "Educational Background"
    }
    
    func getElementsCount() -> Int {
        return EducationalBackgrounds.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return EducationalBackgrounds[forRow]
        }
        return ""
    }
}

