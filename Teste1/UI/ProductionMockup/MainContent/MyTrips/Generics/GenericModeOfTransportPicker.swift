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

class GenericModeOfTransportPicker: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var PickerLabel: UILabel!
    @IBOutlet weak var PickerCollectionView: UICollectionView!
    @IBOutlet weak var PickerSaveButton: UIButton!
    @IBOutlet weak var PickerTextFieldForOtherButton: UITextField!
    
//    let mots = motToCell.getMotCells()
    let publicMots = motToCell.getPublicMOTCells()
    let activeMots = motToCell.getActiveMOTCells()
    let privateMots = motToCell.getPrivateMOTCells()
    
    var otherText = ""
    
    var selectedcell: GenericModeOfTransportPickerCollectionViewCell?
    var motGetter: MotGetter?
    var motSelected: motToCell?
    
    @IBOutlet weak var publicTransportButton: UIButton!
    @IBOutlet weak var activeTransportButton: UIButton!
    @IBOutlet weak var privateTransportButton: UIButton!
    
    @IBOutlet weak var changingView: UIView!
    
    var selectedmotType = papMots.publicMot
    
    enum papMots {
        case publicMot,privateMot,activeMot
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        PickerTextFieldForOtherButton.isHidden = true
        MotivFont.motivBoldFontFor(text: "How did you travel?", label: self.PickerLabel, size: 15)
        self.PickerLabel.textColor = MotivColors.WoortiOrange
        self.PickerCollectionView.register(UINib(nibName: "GenericModeOfTransportPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GenericModeOfTransportPickerCollectionViewCell")
        PickerCollectionView.collectionViewLayout = PickerCollectionViewFlowLayout(cv: PickerCollectionView)
        
        self.PickerCollectionView.delegate=self
        self.PickerCollectionView.dataSource=self
        
        GenericQuestionTableViewCell.loadStandardButton(button: self.PickerSaveButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "SAVE", disabled: false)
        
        self.PickerTextFieldForOtherButton.backgroundColor = MotivColors.WoortiOrangeT3
        self.PickerTextFieldForOtherButton.textColor = MotivColors.WoortiOrange
        
        reload()
    }
    
    func setMotGetter(getter: MotGetter){
        self.motGetter = getter
    }
    
    
    @IBAction func destinationDidEndOnExit(_ sender: Any) {
        self.otherText = self.PickerTextFieldForOtherButton.text ?? ""
        self.motSelected?.otherValue = self.otherText
        resignFirstResponder()
    }
    
    @IBAction func publicTransportOnClick(_ sender: Any) {
        if self.selectedmotType != .publicMot {
            self.selectedmotType = .publicMot
            self.reload()
        }
    }
    
    @IBAction func activeTransportOnClick(_ sender: Any) {
        if self.selectedmotType != .activeMot {
            self.selectedmotType = .activeMot
            self.reload()
        }
    }
    
    @IBAction func PrivateTransportOnClick(_ sender: Any) {
        if self.selectedmotType != .privateMot {
            self.selectedmotType = .privateMot
            self.reload()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.selectedmotType {
        case .publicMot:
            return self.publicMots.count
        case .activeMot:
            return self.activeMots.count
        case .privateMot:
            return self.privateMots.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenericModeOfTransportPickerCollectionViewCell", for: indexPath) as! GenericModeOfTransportPickerCollectionViewCell
        
        var Mot: motToCell?
        switch self.selectedmotType {
        case .publicMot:
            Mot = self.publicMots[indexPath.row]
        case .activeMot:
            Mot = self.activeMots[indexPath.row]
        case .privateMot:
            Mot = self.privateMots[indexPath.row]
        }
        
        cell.loadCell(mot: Mot!, motSelected: Mot!.text == motSelected?.text ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GenericModeOfTransportPickerCollectionViewCell {
            if let sCell = selectedcell {
                sCell.deselectIfSelected()
            }
            if let mot = cell.selecteMotIfDeselected() {
                motSelected = mot
                GenericQuestionTableViewCell.loadStandardButton(button: self.PickerSaveButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "SAVE", disabled: false)
            } else {
                motSelected = nil
                GenericQuestionTableViewCell.loadStandardButton(button: self.PickerSaveButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "SAVE", disabled: true)
            }
            selectedcell = cell
            if cell.mot?.text == motToCell.getOtherMotToCell().text {
                self.PickerTextFieldForOtherButton.isHidden = false
                self.changingView.isHidden = true
                self.PickerCollectionView.isHidden = true
            }
        }
    }
    
    func backOnMOTGetter() {
        if !self.PickerTextFieldForOtherButton.isHidden {
            self.PickerTextFieldForOtherButton.isHidden = true
            self.changingView.isHidden = false
            self.PickerCollectionView.isHidden = false
        }
    }
    
    func reload() {
        if Thread.isMainThread {
            if self.selectedmotType == .publicMot {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.publicTransportButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "Public Transport", boldText: false, size: 9, disabled: false)
            } else {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.publicTransportButton, bColor: MotivColors.WoortiOrangeT3, tColor: MotivColors.WoortiOrange, text: "Public Transport", boldText: false, size: 9, disabled: true)
            }
            
            if self.selectedmotType == .activeMot {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.activeTransportButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "Active/Semi-Active", boldText: false, size: 9, disabled: false)
            } else {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.activeTransportButton, bColor: MotivColors.WoortiOrangeT3, tColor: MotivColors.WoortiOrange, text: "Active/Semi-Active", boldText: false, size: 9, disabled: true)
            }
            
            if self.selectedmotType == .privateMot {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.privateTransportButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "Private Motorized", boldText: false, size: 9, disabled: false)
            } else {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.privateTransportButton, bColor: MotivColors.WoortiOrangeT3, tColor: MotivColors.WoortiOrange, text: "Private Motorized", boldText: false, size: 9, disabled: true)
            }
            self.PickerCollectionView.reloadData()
        } else {
            DispatchQueue.main.async {
                self.reload()
            }
        }
    }
    
    @IBAction func SaveMOT(_ sender: Any) {
        self.PickerTextFieldForOtherButton.isHidden = true
        self.changingView.isHidden = false
        self.PickerCollectionView.isHidden = false
        if let mot = self.motSelected {
            self.motGetter?.gotModeOftransport(mot: mot)
        }
    }
}

class PickerCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    init(cv: UICollectionView) {
        super.init()
        let cellSize = (cv.bounds.width / 3) - ((3+1)*10)
        self.itemSize = CGSize(width: cellSize, height: cellSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol MotGetter {
    func gotModeOftransport(mot: motToCell)
}
