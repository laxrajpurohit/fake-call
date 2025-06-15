//
//  RingtoneVC.swift
//  Fake Call
//
//  Created by mac on 22/04/24.
//

import UIKit
import AVFAudio

class RingtoneVC: UIViewController {

    @IBOutlet weak var tbl_RingTone: UITableView!
    
    var arrRingTone:[[String]] = [["Vibration","Flash light"],["Import From Device"], ["Reflection","Arpeggio","Breaking","Canopy","Chalet","Chirp","Daybreak","Dollop","iPhone14","Kettle","Original-iPhone-ring-1","Redmi_note_6","Romantic_ringtone"]]
    var arrHeader = ["","Import Ringtones","Defaults Ringtones"]
    
    var arrRingToneUrl = [URL]()
    var selectedRingTone = String()
    var selectedRingToneUrl = URL(string: "")
    var audioPlayer: AVAudioPlayer?
    var arrFileAudio:[URL] = []
    var lastselectedUrl = URL(string: "")

    var tapIndex = 0
    var tapIndexFileAudio = -1
    var tapIndexSection0 = -1
    
    var selectionChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        
        if selectionChanged, Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
            AdMob.sharedInstance()?.loadInste()
        }
    }

}

extension RingtoneVC {
    
    // Set Up UI
    func setUpUI() {
        setNavigationBar()
        
        
//        arrRingToneUrl = retrieveDefaultsRingtonrURLsFromUserDefaults()
        
        for i in arrRingTone[2] {
            arrRingToneUrl.append(Bundle.main.url(forResource:i, withExtension: "wav")!)
        }

        
        
        if retrieveFileRingtonrURLsFromUserDefaults().count == 0 {
            if let audioURL1 = URL(string: "file:///path/to/audio1.mp3") {
                arrFileAudio.append(audioURL1)
            }
        }
        
        for i in retrieveFileRingtonrURLsFromUserDefaults() {
            arrFileAudio.append(i)
        }
        
        if retrieveAudioNamesFromUserDefaults().count != 0 {
            arrRingTone = retrieveAudioNamesFromUserDefaults()
        }
        
        
        for (index, audioUrl) in arrFileAudio.enumerated() {
            if audioUrl == Constants.USERDEFAULTS.url(forKey: "selectedRingToneUrl") {
                print(index)
                Constants.USERDEFAULTS.set(index, forKey: "SaveImportRingToneIndex")
            }
        }
        
        for (index, audioUrl) in arrRingToneUrl.enumerated() {
            if audioUrl == Constants.USERDEFAULTS.url(forKey: "selectedRingToneUrl") {
                Constants.USERDEFAULTS.set(index, forKey: "SaveIndexdefaultRingTone")
            }
        }
        
        
        tbl_RingTone.reloadData()
        
        
        
    }
    
    // Set Navigation Bar
    func setNavigationBar() {
        DispatchQueue.main.async { [self] in
            navigationController?.isNavigationBarHidden = false
            title = "Ringtones"
            navigationItem.hidesBackButton = true

            let backButton = UIButton(type: .custom)
            backButton.setImage(UIImage(named: "back"), for: .normal)
            backButton.setTitle("Back", for: .normal)
            backButton.setTitleColor(UIColor.link, for: .normal) // Set text color to the system link color
            backButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)

            // Adjust button size based on title and image
            backButton.sizeToFit()
            let buttonHeight = backButton.frame.height
            backButton.frame = CGRect(x: 0, y: 0, width: backButton.frame.width + 20, height: buttonHeight)

            // Adjust insets for better appearance
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)

            let customBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = customBarButtonItem
        }
    }

    // Get Ringtons Urls From Userdefault
    func retrieveRingTONEURLsFromUserDefaults() -> [URL] {
        var audioURLs: [URL] = []
        
        if let urlStrings = UserDefaults.standard.stringArray(forKey: "RingToneURLs") {
            // Convert array of URL strings back to array of URLs
            audioURLs = urlStrings.compactMap { URL(string: $0) }
        }
        
        return audioURLs
    }

    // Play Audio
    func playAudio(from url: URL) {
        DispatchQueue.main.async { [self] in
            
            let session = AVAudioSession.sharedInstance()

            do {
                try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try session.overrideOutputAudioPort(.speaker)
                try session.setActive(true)
            } catch {
                print("\(#file) - \(#function) error: \(error.localizedDescription)")
            }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 1.0
                audioPlayer?.play()

            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
            
        }
    }
    
    @objc func customButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // Importing Ringtone In File
    func importAudioFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Set to true if you want to allow selecting multiple files

        present(documentPicker, animated: true, completion: nil)
    }
    
    // Get Audio RingTone Name From Userdefault
    func retrieveAudioNamesFromUserDefaults() -> [[String]] {
        var audioNames: [[String]] = []

        if let savedArray = UserDefaults.standard.array(forKey: "audioRingToneName") as? [[Any]] {
            // Convert the array of Any back to [[String]]
            audioNames = savedArray.map { $0.compactMap { $0 as? String } }
        }

        return audioNames
    }
    
    // Get File Urls From Userdefault
    func retrieveFileRingtonrURLsFromUserDefaults() -> [URL] {
        var audioURLs: [URL] = []
        
        if let urlStrings = UserDefaults.standard.stringArray(forKey: "FileRingtoneURLs") {
            // Convert array of URL strings back to array of URLs
            audioURLs = urlStrings.compactMap { URL(string: $0) }
        }
        
        return audioURLs
    }
    
    // Get File Urls From Userdefault
    func retrieveDefaultsRingtonrURLsFromUserDefaults() -> [URL] {
        var audioURLs: [URL] = []
        
        if let urlStrings = UserDefaults.standard.stringArray(forKey: "RingToneUrl") {
            // Convert array of URL strings back to array of URLs
            audioURLs = urlStrings.compactMap { URL(string: $0) }
        }
        
        return audioURLs
    }
}

// Document Picker Delegate Method
extension RingtoneVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedUrl = urls.first else { return }
        var savedFileName = ""

        // Use the selectedUrl to access the chosen audio file
        print("Selected URL: \(selectedUrl)")
        
            CreateURL().convertFileURLToData(fileURL: selectedUrl) { data in
            // Do something with the data, for example, print the size
            print("Data size: \(data.count) bytes")
            let originalFilename = selectedUrl.lastPathComponent
            let AudioNameWithoutExtension = (originalFilename as NSString).deletingPathExtension

            savedFileName =  CreateURL().saveFile(data: data as Data, fileName: AudioNameWithoutExtension)!
           print(savedFileName)
            
    }
        
        let fileName = selectedUrl.lastPathComponent

        var sameUrl = false
        print(arrFileAudio)
        for Name in arrRingTone[1] {
            if Name == fileName {
                Utils().showAlert("This Ringtone Already Imported.")
                sameUrl = true
            }
        }
        
        if !sameUrl {
            
            let vidPath = CreateURL().documentsUrl().appendingPathComponent(savedFileName)
            let URL = URL(string: vidPath.absoluteString)
            
            arrFileAudio.append(URL!)
            let urlStrings = arrFileAudio.map { $0.absoluteString }
            
            // Save array of URL strings to UserDefaults
            Constants.USERDEFAULTS.set(urlStrings, forKey: "FileRingtoneURLs")
            UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
            
            print(arrFileAudio)
            
            let fileName = selectedUrl.lastPathComponent
            print("File Name: \(fileName)")
            
            arrRingTone[1].append(fileName)
            let arrayToSave = arrRingTone.map { $0.map { $0 as Any } }
            
            Constants.USERDEFAULTS.set(arrayToSave, forKey: "audioRingToneName")
            UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
            
            tbl_RingTone.reloadData()
            
            if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
                AdMob.sharedInstance()?.loadInste()
            }
        }
        
        // Here you can process the selected audio file, e.g., save it locally, play it, etc.
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled by the user.")
        // Handle cancellation if needed
    }
}


// Table View Delegate Method
extension RingtoneVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrRingTone.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRingTone[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_RingTone_Cell", for: indexPath) as! tbl_RingTone_Cell
        cell.selectionStyle = .none
        cell.img_Icon.image = UIImage(named: "")
        cell.switchs.isHidden = true
        
        //        DispatchQueue.main.async { [self] in
        if indexPath.section == 0 {
            
            cell.switchs.isHidden = false
            
            if indexPath.row == 0 {
                let isSwitchOn = Constants.USERDEFAULTS.bool(forKey: "Vibration")
                cell.switchs.isOn = isSwitchOn
                cell.switchs.addTarget(self, action: #selector(switchVibration(_:)), for: .valueChanged)
            } else {
                let isSwitchOn = Constants.USERDEFAULTS.bool(forKey: "Flashlight")
                cell.switchs.isOn = isSwitchOn
                cell.switchs.addTarget(self, action: #selector(switchFlashlight(_:)), for: .valueChanged)
            }
            

            } else {
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                //                    cell.img_Icon.isHidden = true
                cell.lblRingToneName.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
            } else {
                cell.img_Icon.isHidden = false
                cell.lblRingToneName.textColor = .label
                
                let index =  Constants.USERDEFAULTS.integer(forKey: "SaveImportRingToneIndex")
                if index == indexPath.row {
                    cell.img_Icon.image = UIImage(named: "right Tick")
                } else {
                    cell.img_Icon.image = UIImage(named: "")
                }
            }
        }
        
        
        if  indexPath.section == 2  {
            cell.lblRingToneName.textColor = .label

//            if !isPremium {
//                if indexPath.row > 6 {
//                    cell.img_Icon.image = UIImage(named: "Lock")
//                } else {
//                    let index = Constants.USERDEFAULTS.integer(forKey: "SaveIndexdefaultVoice")
//
//                    if index == indexPath.row {
//                        cell.img_Icon.image = UIImage(named: "right Tick")
//                    } else {
//                        cell.img_Icon.image = UIImage(named: "")
//                    }
//                }
//            } else {
            let index = Constants.USERDEFAULTS.integer(forKey: "SaveIndexdefaultRingTone")
            let isPremiumUser = Constants.USERDEFAULTS.value(forKey: "Premium") != nil
            let isSelectedRow = index == indexPath.row

            if !isPremiumUser && indexPath.row > 1 {
                cell.img_Icon.image = UIImage(named: "Lock")
            } else {
                if isSelectedRow {
                    cell.img_Icon.image = UIImage(named: "right Tick")
                } else {
                    cell.img_Icon.image = UIImage(named: "")
                }
            }

//            }
        }
        //        }
        
        cell.lblRingToneName.text = self.arrRingTone[indexPath.section][indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        // Create a horizontal stack view
        let stackView = UIStackView(frame: CGRect(x: 10, y: 10, width: headerView.bounds.width - 20, height: 50))
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        
        // Create label
        let label = UILabel()
        label.text = self.arrHeader[section]
        label.textColor = .init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
        headerView.addSubview(stackView)
        
        // Set constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Utils().IpadorIphone(value: 50)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioPlayer?.stop()

        if indexPath.section == 1 {
            if indexPath.row == 0 {
                importAudioFile()
            } else {
                selectedRingTone = arrRingTone[indexPath.section][indexPath.row]
                selectedRingToneUrl = arrFileAudio[indexPath.row]

//                getSectionIndex = indexPath.section
                tapIndex = -1
                tapIndexFileAudio = indexPath.row
                playAudio(from: arrFileAudio[indexPath.row])
                Constants.USERDEFAULTS.set(selectedRingToneUrl!, forKey: "selectedRingToneUrl")
                Constants.USERDEFAULTS.set(selectedRingTone, forKey: "selectedRingToneName")
                selectionChanged = true
            }
        }
        if indexPath.section == 2 {
            if indexPath.row == 0 || indexPath.row == 1 || Constants.USERDEFAULTS.value(forKey: "Premium") != nil {
                // Select and play the ringtone
                selectedRingTone = arrRingTone[indexPath.section][indexPath.row]
                selectedRingToneUrl = arrRingToneUrl[indexPath.row]
                print(selectedRingToneUrl!)
                playAudio(from: selectedRingToneUrl!)

                tapIndexFileAudio = -1
                tapIndex = indexPath.row
                Constants.USERDEFAULTS.set(selectedRingToneUrl!, forKey: "selectedRingToneUrl")
                Constants.USERDEFAULTS.set(selectedRingTone, forKey: "selectedRingToneName")
                selectionChanged = true

            } else {
                // Prompt user to upgrade to premium
                let premiumVC = self.storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
                premiumVC.modalPresentationStyle = .fullScreen
                present(premiumVC, animated: true)
            }
        }

        
        if indexPath.section != 0 {
                if indexPath.section != 1 && indexPath.row != 0 {

            }

        }
        
        
        if indexPath.section == 0 || indexPath.section == 1 && indexPath.row == 0 {
            
         print("No Selection")
            
        } else {
            Constants.USERDEFAULTS.set(tapIndex, forKey: "SaveIndexdefaultRingTone")
            Constants.USERDEFAULTS.set(tapIndexFileAudio, forKey: "SaveImportRingToneIndex")
        }

        tbl_RingTone.reloadData()

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row == 2 || indexPath.section == 1 && indexPath.row == 0 {
               // Disable editing for section 1, row 0
               return false
           }
                   
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .delete {
                arrFileAudio.remove(at: indexPath.row)
                arrRingTone[1].remove(at: indexPath.row)
                
                let urlStrings = arrFileAudio.map { $0.absoluteString }
                
                Constants.USERDEFAULTS.set(urlStrings, forKey: "FileRingtoneURLs")
                UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
                
                Constants.USERDEFAULTS.set(arrRingTone, forKey: "audioRingToneName")
                UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
                tableView.deleteRows(at: [indexPath], with: .fade)
                
//                Constants.USERDEFAULTS.set(arrRingToneUrl[0], forKey: "selectedRingToneUrl")
//                Constants.USERDEFAULTS.set("Reflaction", forKey: "selectedRingToneName")

                audioPlayer?.stop()
                            
                let importRingToneIndex = Constants.USERDEFAULTS.integer(forKey: "SaveImportRingToneIndex")
                let defaultRingToneIndex = Constants.USERDEFAULTS.integer(forKey: "SaveIndexdefaultRingTone")                
                
                if indexPath.section == 2 {
                    if defaultRingToneIndex == indexPath.row {
                        Constants.USERDEFAULTS.set(-1, forKey: "SaveIndexdefaultRingTone")
                        Constants.USERDEFAULTS.set(arrRingToneUrl[0], forKey: "selectedRingToneUrl")
                        Constants.USERDEFAULTS.set("Reflaction", forKey: "selectedRingToneName")

                    }
                        if defaultRingToneIndex != -1 {
                            if arrRingToneUrl.count == 0 {
                                
                                Constants.USERDEFAULTS.set(-1, forKey: "SaveIndexdefaultRingTone")
                                Constants.USERDEFAULTS.set(arrRingToneUrl[0], forKey: "selectedRingToneUrl")
                                Constants.USERDEFAULTS.set("Reflaction", forKey: "selectedRingToneName")
                            }
                        }
                }
                
                if indexPath.section == 1 {
                    if importRingToneIndex == indexPath.row {
                        Constants.USERDEFAULTS.set(-1, forKey: "SaveIndexdefaultRingTone")
                        Constants.USERDEFAULTS.set(arrRingToneUrl[0], forKey: "selectedRingToneUrl")
                        Constants.USERDEFAULTS.set("Reflaction", forKey: "selectedRingToneName")
                        Constants.USERDEFAULTS.set(-1, forKey: "SaveImportRingToneIndex")


                    }
                    
                    if importRingToneIndex != -1 {
                        if arrFileAudio.count == 1 {
                            
                            Constants.USERDEFAULTS.set(-1, forKey: "SaveImportRingToneIndex")
                            Constants.USERDEFAULTS.set(arrRingToneUrl[0], forKey: "selectedRingToneUrl")
                            Constants.USERDEFAULTS.set("Reflaction", forKey: "selectedRingToneName")
                            
                        }
                    }
                    
                }
//
//                if importRingToneIndex == -1 || defaultRingToneIndex == -1 {
//                    Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultRingTone")
//
//                }
            }
        }
        
    }
    
    @objc func switchVibration(_ sender: UISwitch) {
        let isSwitchOn = sender.isOn
        Constants.USERDEFAULTS.set(isSwitchOn, forKey: "Vibration")
        
    }
    
    @objc func switchFlashlight(_ sender: UISwitch) {
        let isSwitchOn = sender.isOn
        Constants.USERDEFAULTS.set(isSwitchOn, forKey: "Flashlight")
        
    }
    
}

// tbl_RingTone_Cell
class tbl_RingTone_Cell:UITableViewCell {
    @IBOutlet weak var lblRingToneName: UILabel!
    @IBOutlet weak var img_Icon: UIImageView!
    
    @IBOutlet weak var switchs: UISwitch!
}

