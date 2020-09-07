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
import os.log

/*
 * View controller used during development. 
 */
class FullTripTableViewController: UITableViewController {
    
    var newIndexPath = IndexPath(row: UserInfo.getFullTrips().count, section: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your Full Trips"
        UiAlerts.getInstance().newView(view: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func UpdateBtnColor() {
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func addTableViewCell() {
        if Thread.isMainThread {
            self.tableView.reloadData()
        }else {
            DispatchQueue.main.sync{
                addTableViewCell()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserInfo.getFullTrips().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "FullTripViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? FullTripViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        //initialize the cell
        let fullTrip = UserInfo.getFullTrips().reversed()[indexPath.row]
        cell.fullTripLabel.text = fullTrip.printOnCell()
        cell.setTrip(trip: fullTrip)
        cell.setController(view: self)
        
        // Configure the cell...
        self.newIndexPath = IndexPath(row: UserInfo.getFullTrips().count, section: 0)
        if fullTrip.sentToServer {
            cell.backgroundColor = UIColor.green
        } else if fullTrip.confirmed {
            cell.backgroundColor = UIColor.yellow
        } else {
            cell.backgroundColor = UIColor.red
        }
        
        //set Long Click
        let gestureRecognizer = UILongPressGestureRecognizer(target: cell, action: #selector(cell.handleTap))
        cell.addGestureRecognizer(gestureRecognizer)
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ProcessLocationData.tVControler=self
        PowerManagementModule.ctrl_fullTripTableView=self
        UpdateBtnColor()
        UiAlerts.getInstance().newView(view: self)
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ProcessLocationData.tVControler=nil
        PowerManagementModule.ctrl_fullTripTableView=nil
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            //        case "AddItem":
            //            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        //
        case "ShowFullTrip":
            guard let mapViewControler = segue.destination as? ViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedFullTripCell = sender as? FullTripViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedFullTripCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            mapViewControler.fullTripToShow=UserInfo.getFullTrips().reversed()[indexPath.row]
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}
