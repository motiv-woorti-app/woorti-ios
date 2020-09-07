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
 * OnBoarding View to select age
 */
class ChooseYourAgeViewController: GenericViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var boxView: UIView!
//    var selectedCell: ChooseYourAgeTableViewCell?
    @IBOutlet weak var whatsYourAge: UILabel!
    
    var ages = ["16-19","20-24","25-29","30-39","40-49","50-64","65-74","75+"]
    var minAges = [16,20,25,30,40,50,65,75]
    var maxAges = [19,24,29,39,49,64,74,125]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.clear
        
        MotivAuxiliaryFunctions.RoundView(view: boxView)
        MotivFont.motivBoldFontFor(key: "What_Is_Your_Age", comment: "message: What is your age?", label: self.whatsYourAge, size: 15)
        self.whatsYourAge.textColor = MotivColors.WoortiOrange
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 15, disabled: true, CompleteRoundCorners: true)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseYourAgeTableViewCell") as! ChooseYourAgeTableViewCell
        
        let user = MotivUser.getInstance()
        cell.load(title: ages[indexPath.row])
        if user?.ageRange == ages[indexPath.row] {
            cell.Toggle()
        }
        return cell
    }
    
    /*
     * store age in MotivUser instance when row is selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = MotivUser.getInstance()
        
        if let userInstance = user {
            print("Instance available")
        }
        else {
            print("Instance not available")
        }
        user?.ageRange = ages[indexPath.row]
        user?.minAge = Double(minAges[indexPath.row])
        user?.maxAge = Double(maxAges[indexPath.row])
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 15, disabled: false)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @IBAction func nextClick(_ sender: Any) {
        if (MotivUser.getInstance()?.ageRange ?? "") != "" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeTochooseGender.rawValue), object: nil)
        }
    }
    
}
