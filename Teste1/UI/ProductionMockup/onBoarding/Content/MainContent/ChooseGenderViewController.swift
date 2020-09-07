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
 * Onboarding view to select user's gender.
 */
class ChooseGenderViewController: GenericViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var genderTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var lblGender: UILabel!
    
    var genders = [MotivStringsGen.getInstance().Male, MotivStringsGen.getInstance().Female, MotivStringsGen.getInstance().Other]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderTableView.delegate = self
        genderTableView.dataSource = self
        self.view.backgroundColor = UIColor.clear
        
        MotivAuxiliaryFunctions.RoundView(view: boxView)
        MotivFont.motivBoldFontFor(key: "Gender", comment: "message: Gender", label: self.lblGender, size: 15)
        self.lblGender.textColor = MotivColors.WoortiOrange
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 15, disabled: false, CompleteRoundCorners: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseYourAgeTableViewCell") as! ChooseYourAgeTableViewCell
        let user = MotivUser.getInstance()
        cell.load(title: NSLocalizedString(genders[indexPath.row], value: "Gender", comment: "message: Gender"))
        if user?.gender == genders[indexPath.row] {
            //            self.selectedCell = cell
            cell.Toggle()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = MotivUser.getInstance()
        user?.gender = genders[indexPath.row]
        DispatchQueue.main.async {
            self.genderTableView.reloadData()
        }

    }
    
    @IBAction func nextClick(_ sender: Any) {
        let user = MotivUser.getInstance()
        
        if (user?.gender ?? "") != "" {
            MotivUser.getInstance()?.hasOnboardingFilledInfo = true
            UserInfo.appDelegate?.saveContext()
            MotivRequestManager.getInstance(token: user!.token).requestSaveUserSettings()
    
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToMain.rawValue), object: nil)
        }
    }
}
