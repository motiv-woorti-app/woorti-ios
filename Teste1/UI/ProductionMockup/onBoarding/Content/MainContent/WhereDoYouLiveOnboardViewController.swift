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
 * Onboarding view to select user's country and city.
 */
class WhereDoYouLiveOnboardViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contentPage: UIView!
    @IBOutlet weak var NatioTableView: UITableView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var heightForTV: NSLayoutConstraint!
    @IBOutlet weak var shadowContainer: UIView!
    
    let countries = [
        "Portugal": ["Lisbon","Porto","Other"],
        "Slovakia": ["Žilina", "Bratislava", "Trnava","Nitra","Trenčín", "Banská Bystrica","Košice","Prešov","Other"],
        "Suomi": ["Helsinki","Tampere","Turku","Oulu","Etelä-Suomi","Länsi-Suomi","Keski-Suomi", "Itä-Suomi","Pohjois-Suomi", "Other"],
        "España": ["Barcelona","Girona","Tarragona","Lleida","Other"],
        "Belgique/België/Belgien": ["Antwerp", "Brugge", "Brussels", "Gent", "Leuven","Other"],
        "Suisse/Svizzera/Schweiz": ["Lausanne","Genève","Montreux","Fribourg", "Bern", "Basel", "Zurich", "Neuchâtel", "Yverdon-les-Bains","Other"],
        "Italia": ["Milan","Other"],
        "France": ["Paris", "Lyon", "Grenoble", "Nevers", "Nantes","Bordeaux", "Toulouse", "Strasbourg", "Amiens", "Angers", "Lille", "Brest", "Marseille", "Saint Brieuc", "Montpellier", "Other"],
        "Norge": ["Oslo","Bergen","Trondheim","Stavager","Drammen","Fredrikstad","Porsgrunn","Skien", "Kristiansand","Ålesund","Tønsberg","Other"],
        "Hrvatska": ["Zagreb","Velika Gorica","Samobor", "Zaprešić", "Dugo selo", "Zagrebačka županija","Split","Rijeka","Osijek","Varaždin","Zadar","Other"],
        "Other": ["Other"]]
    

    
    var cities = ["Other"]
    
    var countryKeys = [
    "Portugal",
    "Slovakia",
    "Suomi",
    "España",
    "Belgique/België/Belgien",
    "Suisse/Svizzera/Schweiz",
    "Italia",
    "France",
    "Norge",
    "Hrvatska",
    "Other"]
    
    var otherCountries = [Languages]()
    
    var type = tvType.countries
    
    enum tvType {
        case countries
        case otherCountries
        case cities
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = MotivUser.getInstance()
        user?.country = ""
        user?.city = ""
        self.NatioTableView.delegate = self
        self.NatioTableView.dataSource = self
        
        self.view.backgroundColor = UIColor.clear
        
        MotivAuxiliaryFunctions.RoundView(view: self.contentPage)
        MotivFont.motivBoldFontFor(key: "Where_Do_You_Live", comment: "mesasge: Where do you live?", label: self.tittleLabel, size: 15)
        self.tittleLabel.textColor = MotivColors.WoortiOrange
        // Do any additional setup after loading the view.
        updateTVHeight()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .countries:
            return countries.count
        case .cities:
            return cities.count
        case .otherCountries:
            self.otherCountries = Languages.getOtherCountries()
            return otherCountries.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryNationTableViewCell") as! CountryNationTableViewCell
        var text = ""
        switch type {
        case .cities:
            text = self.cities[indexPath.row]
        case .countries:
            text = countryKeys[indexPath.row]
        case .otherCountries:
            text = self.otherCountries[indexPath.row].name
        }
        
        cell.loadText(text: text)
        return cell
    }
    
    func reloadTableView() {
        if Thread.isMainThread {
            self.NatioTableView.reloadData()
            self.updateTVHeight()
        } else {
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CountryNationTableViewCell
        let user = MotivUser.getInstance()
        
        switch type {
        case .cities:
            if cell.getText() == self.cities.last! {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeTochooseCoutryCityOther.rawValue), object: nil)
            } else {
                user?.city = cell.getText()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeTochooseCampaigns.rawValue), object: nil)
            }
        case .otherCountries:
            if let country = Languages.getCountriesForCountry(country: cell.getText()) {
                user?.country = country.woortiID
            } else {
                user?.country = cell.getText()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeTochooseCoutryCityOther.rawValue), object: nil)
        case .countries:
            if cell.getText() == countryKeys.last! {
                self.type = .otherCountries
                reloadTableView()
            } else {
                if let country = Languages.getCountriesForCountry(country: cell.getText()) {
                    user?.country = country.woortiID
                } else {
                    user?.country = cell.getText()
                }
                
                self.type = .cities
                self.cities = self.countries[cell.getText()]!
                reloadTableView()
            }
        }
    }
    
    func updateTVHeight() {
        let height = self.shadowContainer.bounds.height
        let position = self.NatioTableView.frame.minY
        
        let maxHeight = CGFloat((height - position) - 20) //20 = inset
        var allHeight = CGFloat(0)
        switch self.type {
        case .countries:
            allHeight = CGFloat(44 * countries.count)
        case .cities:
            allHeight = CGFloat(44 * cities.count)
        case .otherCountries:
            allHeight = CGFloat(44 * otherCountries.count)
        }
        
        heightForTV.constant = CGFloat(min(maxHeight, allHeight))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(44)
    }

}
