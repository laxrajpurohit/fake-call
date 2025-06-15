//
//  VoiceVC.swift
//  Fake Call
//
//  Created by mac on 04/04/24.
//

import UIKit
import AVFoundation


class VoiceVC: UIViewController {
   
    
    @IBOutlet weak var tbl_ChooseVoice: UITableView!
    
    var tapIndex = -1
    var tapIndexSection1 = -1
    var tapIndexSection0 = -1

    var getSectionIndex = 2
    var audioPlayer: AVAudioPlayer?

    var isPremium = false
    var isFirstTime = true
    var isAddNewID = false
    var isFromHome = false
    var selectionChanged = false

    var selectedVoiceName = String()
    var selectedVoice = URL(string: "")
    var audioUrl = URL(string: "")
    var lastselectedUrl = URL(string: "")

    var arrVoice:[[String]] = [["Record Voice"],["Import voice from device"],["None","Elon Musk","Love","Love male","Unknown","Kylie Jen","Work","The Rock","Sarukh khan","Zenda","Angelina jolie","Donald Trump","Barack Obama","Cristiano Ronaldo"]]
    
    var arrVoiceName = ["None","Elon Musk","Love","Love male","Unknown","Kylie Jen","Work","The Rock","Sarukh khan","Zenda","Angelina jolie","Donald Trump","Barack Obama","Cristiano Ronaldo"]

    var arrFileAudio:[URL] = []
    var arrRecodedAudio:[URL] = []
    var arrAudio = [URL]()
    var contacts = CallerIds()
    var arrcallerids = [CallerId]()


   var isFirstOpationChangeVoice = false

    var arrHeader = ["Record Voice","Import Voice","Default Voice"]

    override func viewDidLoad() {
        super.viewDidLoad()
//        playMusic()
        navigationItem.title = "Voice"
        setUp()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSaveRecodingNotification(_:)), name: Notification.Name("SaveRecoding"), object: nil)


    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isFirstOpationChangeVoice {
            
            IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
                arrcallerids = Ids
            }
            
            let indexs = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")

            if selectedVoice == nil {
                selectedVoice = arrcallerids[indexs].voiceUrl
            }
            
            if selectedVoiceName == "" {
                selectedVoiceName = arrcallerids[indexs].voice!
            }

             contacts.VoiceUrl = selectedVoice
             contacts.voice = selectedVoiceName

            
            let timestamp = arrcallerids[indexs].timestamp
            contacts.timestamp = timestamp!
            
            let update = IMAGEDATA().updateVoice(context: self.context, CallerId: contacts)
            if update {
                
                IMAGEDATA().fetchImage(context: self.context) { Ids in
                   print(Ids)
                    
                }
            }
        }
        
        let saveIndexDefaultVoice = Constants.USERDEFAULTS.integer(forKey: "SaveIndexdefaultVoice")
           let saveImportVoiceIndex = Constants.USERDEFAULTS.integer(forKey: "SaveImportVoiceIndex")
           let saveRecordedVoiceIndex = Constants.USERDEFAULTS.integer(forKey: "SaveRecodedVoiceIndex")

           if saveIndexDefaultVoice == -1 && saveImportVoiceIndex == -1 && saveRecordedVoiceIndex == -1 {
               Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")
           }
        }

}

extension VoiceVC {
    
    // Set Up UI
    func setUp() {
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Voice"

        
        if retrieveAudioURLsFromUserDefaults().count == 0 {
            
            if let audioURL1 = URL(string: "file:///path/to/audio1.mp3") {
                arrFileAudio.append(audioURL1)
            }
        }
        
        if retrieveAudioNamesFromUserDefaults().count != 0 {
            arrVoice = retrieveAudioNamesFromUserDefaults()
        }
        
        for i in retrieveAudioURLsFromUserDefaults() {
            arrFileAudio.append(i)
        }
        
        arrRecodedAudio = retrieveRecodedAudioURLsFromUserDefaults()
        if let initialURL = URL(string: "https://www.None.com") {
            arrAudio.append(initialURL)
        }

        for i in arrVoiceName {
            // Safely unwrap the URL returned by Bundle.main.url(forResource:withExtension:)
            if let resourceURL = Bundle.main.url(forResource: i, withExtension: "wav") {
                arrAudio.append(resourceURL)
            } else {
                // Handle the case where the resource is not found
                print("Resource \(i).mp3 not found in the bundle")
            }
        }
        
        
        if  Constants.USERDEFAULTS.bool(forKey: "isAddNewIDForRightTick") {
            Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")
            Constants.USERDEFAULTS.set(-1, forKey: "SaveImportVoiceIndex")
            Constants.USERDEFAULTS.set(-1, forKey: "SaveRecodedVoiceIndex")
        } else {
            Constants.USERDEFAULTS.set(-1, forKey: "SaveIndexdefaultVoice")
            Constants.USERDEFAULTS.set(-1, forKey: "SaveImportVoiceIndex")
            Constants.USERDEFAULTS.set(-1, forKey: "SaveRecodedVoiceIndex")

        }
        
        
        if isFromHome {
            IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
                arrcallerids = Ids
                let index = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
                let selectedVoiceUrl = arrcallerids[index].voiceUrl
                
                Constants.USERDEFAULTS.set(-1, forKey: "SaveIndexdefaultVoice")
                Constants.USERDEFAULTS.set(-1, forKey: "SaveImportVoiceIndex")
                Constants.USERDEFAULTS.set(-1, forKey: "SaveRecodedVoiceIndex")
                
                for (index, audioUrl) in arrAudio.enumerated() {
                    if audioUrl == selectedVoiceUrl {
                        print(index)
                        self.audioUrl = audioUrl
                        Constants.USERDEFAULTS.set(index, forKey: "SaveIndexdefaultVoice")
                    }
                }
                
                for (index, audioUrl) in arrFileAudio.enumerated() {
                    if audioUrl == selectedVoiceUrl {
                        self.audioUrl = audioUrl
                        Constants.USERDEFAULTS.set(index, forKey: "SaveImportVoiceIndex")
                    }
                }
                
                for (index, audioUrl) in arrRecodedAudio.enumerated() {
                    if audioUrl == selectedVoiceUrl {
                        self.audioUrl = audioUrl
                        Constants.USERDEFAULTS.set(index, forKey: "SaveRecodedVoiceIndex")
                    }
                }
                
                if audioUrl == URL(string: "https://www.None.com") {
                    Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")
                }
                
                
            }
        } else {
            
            for (index, audioUrl) in arrAudio.enumerated() {
                if audioUrl == lastselectedUrl {
                    print(index)
                    self.audioUrl = audioUrl
                    Constants.USERDEFAULTS.set(index, forKey: "SaveIndexdefaultVoice")
                }
            }
            
            for (index, audioUrl) in arrFileAudio.enumerated() {
                if audioUrl == lastselectedUrl {
                    self.audioUrl = audioUrl
                    Constants.USERDEFAULTS.set(index, forKey: "SaveImportVoiceIndex")
                }
            }
            
            for (index, audioUrl) in arrRecodedAudio.enumerated() {
                if audioUrl == lastselectedUrl {
                    self.audioUrl = audioUrl
                    Constants.USERDEFAULTS.set(index, forKey: "SaveRecodedVoiceIndex")
                }
            }
            
        }
    
        tbl_ChooseVoice.reloadData()
    }
    
    // Importing Voice In File
    func importAudioFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Set to true if you want to allow selecting multiple files

        present(documentPicker, animated: true, completion: nil)
    }

    // Play Audio
    func playAudio(from url: URL) {
        print(url)
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
    
    func playMusic() {
          guard let path = Bundle.main.path(forResource: "Love male", ofType:"mp3") else {
              return }
          let url = URL(fileURLWithPath: path)
          do {
              audioPlayer = try AVAudioPlayer(contentsOf: url)
              audioPlayer?.numberOfLoops = -1
              audioPlayer?.prepareToPlay()
              audioPlayer?.volume = 0.1
              audioPlayer?.play()
          } catch let error {
              print(error.localizedDescription)
          }
      }
        
    // Retrieve Audio URLs From User Defaults
    func retrieveAudioURLsFromUserDefaults() -> [URL] {
        var audioURLs: [URL] = []
        
        if let urlStrings = UserDefaults.standard.stringArray(forKey: "audioURLs") {
            // Convert array of URL strings back to array of URLs
            audioURLs = urlStrings.compactMap { URL(string: $0) }
        }
        
        return audioURLs
    }
    
   // Retrieve Recoded Audio URLs From User Defaults
    func retrieveRecodedAudioURLsFromUserDefaults() -> [URL] {
        var audioURLs: [URL] = []
        
        if let urlStrings = UserDefaults.standard.stringArray(forKey: "audioRecodedURLs") {
            // Convert array of URL strings back to array of URLs
            audioURLs = urlStrings.compactMap { URL(string: $0) }
        }
        
        return audioURLs
    }
    
    // Retrieve  Audio Names From User Defaults
    func retrieveAudioNamesFromUserDefaults() -> [[String]] {
        var audioNames: [[String]] = []

        if let savedArray = UserDefaults.standard.array(forKey: "audioName") as? [[Any]] {
            // Convert the array of Any back to [[String]]
            audioNames = savedArray.map { $0.compactMap { $0 as? String } }
        }

        return audioNames
    }
    
    // Save Recoding Voice
    @objc func handleSaveRecodingNotification(_ notification: Notification) {
        var savedFileName = ""
        if let userInfo = notification.userInfo {
            if let text = userInfo["SaveRecoding"] as? String {
                // Access the value for key "SaveRecoding" (text)
                arrVoice[0].append(text)
                tbl_ChooseVoice.reloadData()
                
                let arrayToSave = arrVoice.map { $0.map { $0 as Any } }

                Constants.USERDEFAULTS.set(arrayToSave, forKey: "audioName")

            }
            
            if let fileURL = userInfo["URL"] as? URL {
                arrRecodedAudio.removeAll()
                
                if retrieveRecodedAudioURLsFromUserDefaults().count == 0 {
                    
                    if let audioURL1 = URL(string: "file:///path/to/audio1.mp3") {
                        arrRecodedAudio.append(audioURL1)
                    }
                }
                
                
                for i in retrieveRecodedAudioURLsFromUserDefaults() {
                    if isFirstTime {
                        if arrRecodedAudio.count > 0 {
                            arrRecodedAudio.removeAll()
                        }
                        isFirstTime = false
                    }
                    arrRecodedAudio.append(i)
                }
                
                
                CreateURL().convertFileURLToData(fileURL: fileURL) { data in
                    // Do something with the data, for example, print the size
                    print("Data size: \(data.count) bytes")
                    let originalFilename = fileURL.lastPathComponent
                    let AudioNameWithoutExtension = (originalFilename as NSString).deletingPathExtension
                    savedFileName =  CreateURL().saveFile(data: data as Data, fileName: AudioNameWithoutExtension)!
                    print(savedFileName)
                }
                
                let vidPath = CreateURL().documentsUrl().appendingPathComponent(savedFileName)
                let URL = URL(string: vidPath.absoluteString)
                
                arrRecodedAudio.append(URL!)
                
                let urlStrings = arrRecodedAudio.map { $0.absoluteString }
                
                // Save array of URL strings to UserDefaults
                Constants.USERDEFAULTS.set(urlStrings, forKey: "audioRecodedURLs")

            }
            
            if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
                AdMob.sharedInstance()?.loadInste()
            }
            
        }

    }
        
    func didSelectVoiceNames(_ voiceNames: [URL]) {
           // Handle received voice names here
           print("Received voice names: \(voiceNames)")
       }
    
    
}

// Document Picker Delegate
extension VoiceVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedUrl = urls.first else { return }
        var savedFileName = ""
        
        // Use the selectedUrl to access the chosen audio file
        print("Selected URL: \(selectedUrl)")
        

        var sameUrl = false
        let fileName = selectedUrl.lastPathComponent

        print(arrFileAudio)
        for Name in arrVoice[1] {
            if Name == fileName {
                Utils().showAlert("This Voice Already Imported.")
                sameUrl = true
            }
        }

           CreateURL().convertFileURLToData(fileURL: selectedUrl) { data in
                // Do something with the data, for example, print the size
                print("Data size: \(data.count) bytes")
                let originalFilename = selectedUrl.lastPathComponent
                let AudioNameWithoutExtension = (originalFilename as NSString).deletingPathExtension

                savedFileName =  CreateURL().saveFile(data: data as Data, fileName: AudioNameWithoutExtension)!
               print(savedFileName)
                
        }
        
        if !sameUrl {
          
            let vidPath = CreateURL().documentsUrl().appendingPathComponent(savedFileName)
            let URL = URL(string: vidPath.absoluteString)

            arrFileAudio.append(URL!)
            let urlStrings = arrFileAudio.map { $0.absoluteString }
            
            // Save array of URL strings to UserDefaults
            Constants.USERDEFAULTS.set(urlStrings, forKey: "audioURLs")
            UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
            
            print(arrFileAudio)
            
            let fileName = selectedUrl.lastPathComponent
            print("File Name: \(fileName)")
            
            
            //        if arrVoice.count > 2 {
            arrVoice[1].append(fileName)
            
            //        } else {
            //            let newSection = ["\(fileName)"]
            //            arrHeader.append("Imported voice from device")
            //            // Append the new section to arrVoice
            //            arrVoice.append(newSection)
            //
            //        }
            let arrayToSave = arrVoice.map { $0.map { $0 as Any } }
            
            Constants.USERDEFAULTS.set(arrayToSave, forKey: "audioName")
            UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
            
            tbl_ChooseVoice.reloadData()
            
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


// TableView Delegate
extension VoiceVC:UITableViewDelegate,UITableViewDataSource {
                                                                     
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrVoice.count
    }
                                                                     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrVoice[section].count
    }
                                                                     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_ChooseVoice_Cell", for: indexPath) as! tbl_ChooseVoice_Cell
        cell.selectionStyle = .none
        cell.img_Icon.image = UIImage(named: "")
        
//        DispatchQueue.main.async { [self] in
            if indexPath.section == 0 {
                if indexPath.row == 0 {
//                    cell.img_Icon.isHidden = true
                    cell.lblVoiceName.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
                } else {
                    cell.img_Icon.isHidden = false
                    cell.lblVoiceName.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)

                    let index =  Constants.USERDEFAULTS.integer(forKey: "SaveRecodedVoiceIndex")
                    if index == indexPath.row {
                        cell.img_Icon.image = UIImage(named: "right Tick")
                    } else {
                        cell.img_Icon.image = UIImage(named: "")
                    }
                }
            }

             if indexPath.section == 1 {
                if indexPath.row == 0 {
//                    cell.img_Icon.isHidden = true
                    cell.lblVoiceName.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
                } else {
                    cell.img_Icon.isHidden = false
                    cell.lblVoiceName.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
                    
                    let index =  Constants.USERDEFAULTS.integer(forKey: "SaveImportVoiceIndex")
                    if index == indexPath.row {
                        cell.img_Icon.image = UIImage(named: "right Tick")
                    } else {
                        cell.img_Icon.image = UIImage(named: "")
                    }
                }
            }
//
        if  indexPath.section == 2  {
            cell.lblVoiceName.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
            
        
                let index = Constants.USERDEFAULTS.integer(forKey: "SaveIndexdefaultVoice")
                
                if index == indexPath.row {
                    cell.img_Icon.image = UIImage(named: "right Tick")
                } else {
                    cell.img_Icon.image = UIImage(named: "")
            }
        }
//        }
        
        cell.lblVoiceName.text = self.arrVoice[indexPath.section][indexPath.row]
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
    return 35
       
    }
                                                                     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Utils().IpadorIphone(value: 50)
    }                                                         
                                                                     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioPlayer?.stop()
        
        Constants.USERDEFAULTS.set(false, forKey: "isAddNewIDForRightTick")
        selectionChanged = true
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                audioPlayer?.stop()
                let navigate = storyboard?.instantiateViewController(withIdentifier: "RecodingVoiceVC") as! RecodingVoiceVC
                navigationController?.pushViewController(navigate, animated: true)
            } else {
                tapIndexSection0 = indexPath.row
                tapIndex = -1
                tapIndexSection1 = -1
                selectedVoiceName = arrVoice[indexPath.section][indexPath.row]
                selectedVoice = arrRecodedAudio[indexPath.row]
                playAudio(from: arrRecodedAudio[indexPath.row])
                Constants.USERDEFAULTS.set(tapIndex, forKey: "SaveIndexdefaultVoice")
                Constants.USERDEFAULTS.set(tapIndexSection1, forKey: "SaveImportVoiceIndex")
                Constants.USERDEFAULTS.set(tapIndexSection0, forKey: "SaveRecodedVoiceIndex")

            }

        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                importAudioFile()
                audioPlayer?.stop()

            } else {
                
                selectedVoiceName = arrVoice[indexPath.section][indexPath.row]
                selectedVoice = arrFileAudio[indexPath.row]
                getSectionIndex = indexPath.section
                tapIndex = -1
                tapIndexSection0 = -1
                tapIndexSection1 = indexPath.row
                
                playAudio(from: arrFileAudio[indexPath.row])
                Constants.USERDEFAULTS.set(tapIndex, forKey: "SaveIndexdefaultVoice")
                Constants.USERDEFAULTS.set(tapIndexSection1, forKey: "SaveImportVoiceIndex")
                Constants.USERDEFAULTS.set(tapIndexSection0, forKey: "SaveRecodedVoiceIndex")

            }
            

        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                audioPlayer?.stop()
            }
            selectedVoiceName = arrVoice[indexPath.section][indexPath.row]
            selectedVoice = arrAudio[indexPath.row]
            getSectionIndex = indexPath.section
            tapIndexSection1 = -1
            tapIndexSection0 = -1
            tapIndex = indexPath.row
            playAudio(from: arrAudio[indexPath.row])
            Constants.USERDEFAULTS.set(tapIndex, forKey: "SaveIndexdefaultVoice")
            Constants.USERDEFAULTS.set(tapIndexSection1, forKey: "SaveImportVoiceIndex")
            Constants.USERDEFAULTS.set(tapIndexSection0, forKey: "SaveRecodedVoiceIndex")

        }
        

        tbl_ChooseVoice.reloadData()

        print(selectedVoiceName)
        print(tapIndexSection1)
        
        // Post a notification with the text data
        if indexPath.section == 0 && indexPath.row == 0 || indexPath.section == 1 && indexPath.row == 0 {
            
         print("No Selection")
            
        } else {
            if !isFirstOpationChangeVoice {
                let userInfo: [AnyHashable: Any] = ["selectedVoiceName": selectedVoiceName,"selectedVoice":selectedVoice as Any,"selectionChanged":selectionChanged]
                NotificationCenter.default.post(name: Notification.Name("selectedVoice"), object: nil, userInfo: userInfo)
            }
        }
        
    }
                                                                     
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 0 && indexPath.row == 0) || indexPath.section == 2 {
            // Disable editing for section 1, row 0 and section 0, row 0
            return false
        }
        
        return true
    }
                                                                     
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "Delete Voice?", message:  "Are you sure you want to delete this Voice? It will be removed from all Caller IDs where it is currently applied.", preferredStyle: .alert)
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            
        }
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] _ in
            // Update Url If User Delete Url
            IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
                
                print(Ids[0])
                
                for i in  0..<Ids.count {
                    if indexPath.section == 1 {
                        if self.arrFileAudio[indexPath.row] == Ids[i].voiceUrl {
                            print(Ids[i])
                            
                            let timestamp = Ids[i].timestamp
                            contacts.timestamp = timestamp!
                            contacts.voice = "None"
                            contacts.VoiceUrl = URL(string: "https://www.None.com")
                            
                            let update = IMAGEDATA().updateVoice(context: self.context, CallerId: contacts)
                            if update {
                                print("Yes")
                            }
                        }
                    }
                    if indexPath.section == 0 {
                        
                        if self.arrRecodedAudio[indexPath.row] == Ids[i].voiceUrl {
                            
                            let timestamp = Ids[i].timestamp
                            contacts.timestamp = timestamp!
                            contacts.voice = "None"
                            contacts.VoiceUrl = URL(string: "https://www.None.com")
                            
                            let update = IMAGEDATA().updateVoice(context: self.context, CallerId: contacts)
                            if update {
                                print("Yes")
                            }
                        }
                    }
                    
                }
            }
            
            
                if editingStyle == .delete {
                    audioPlayer?.stop()
                
                if indexPath.section == 1 {

                // Perform deletion from your data source
                arrFileAudio.remove(at: indexPath.row)
                arrVoice[1].remove(at: indexPath.row)
                
                
                let urlStrings = arrFileAudio.map { $0.absoluteString }
                
                Constants.USERDEFAULTS.set(urlStrings, forKey: "audioURLs")
                UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
                
                Constants.USERDEFAULTS.set(arrVoice, forKey: "audioName")
                UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                } else if indexPath.section == 0 {
                    arrRecodedAudio.remove(at: indexPath.row)
                    arrVoice[0].remove(at: indexPath.row)
                    
                    let urlStrings = arrRecodedAudio.map { $0.absoluteString }
                    
                    Constants.USERDEFAULTS.set(urlStrings, forKey: "audioRecodedURLs")
                    UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
                    
                    Constants.USERDEFAULTS.set(arrVoice, forKey: "audioName")
                    UserDefaults.standard.synchronize() // Optional: Manually synchronize UserDefaults
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)

                }
                    
                     let saveIndexDefaultVoice = Constants.USERDEFAULTS.integer(forKey: "SaveIndexdefaultVoice")
                       let saveImportVoiceIndex = Constants.USERDEFAULTS.integer(forKey: "SaveImportVoiceIndex")
                       let saveRecordedVoiceIndex = Constants.USERDEFAULTS.integer(forKey: "SaveRecodedVoiceIndex")

                    if indexPath.section == 2 {
    //                    if saveIndexDefaultVoice == tapIndex {
                            if saveImportVoiceIndex != -1 {
                                
                                Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")
                                selectedVoiceName = "None"
                                selectedVoice = URL(string: "https://www.None.com")
                                
                                let userInfo: [AnyHashable: Any] = ["selectedVoiceName": selectedVoiceName,"selectedVoice":selectedVoice as Any]
                                NotificationCenter.default.post(name: Notification.Name("selectedVoice"), object: nil, userInfo: userInfo)
                                
    //                                Constants.USERDEFAULTS.set(-1, forKey: "SaveImportVoiceIndex")
                            }
    //                    }
                    }
                    
                    if indexPath.section == 1 {
                        
                        if saveImportVoiceIndex == indexPath.row {
                            selectedVoiceName = "None"
                            selectedVoice =  URL(string: "https://www.None.com")
                            Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")

                            
                            let userInfo: [AnyHashable: Any] = ["selectedVoiceName": selectedVoiceName,"selectedVoice":selectedVoice as Any]
                            NotificationCenter.default.post(name: Notification.Name("selectedVoice"), object: nil, userInfo: userInfo)
                            Constants.USERDEFAULTS.set(-1, forKey: "SaveImportVoiceIndex")

                        }
                            if saveImportVoiceIndex != -1 {
                                
                                if arrFileAudio.count == 1  {
                                    selectedVoiceName = "None"
                                    selectedVoice =  URL(string: "https://www.None.com")
                                    Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")

                                    
                                    let userInfo: [AnyHashable: Any] = ["selectedVoiceName": selectedVoiceName,"selectedVoice":selectedVoice as Any]
                                    NotificationCenter.default.post(name: Notification.Name("selectedVoice"), object: nil, userInfo: userInfo)
                                    Constants.USERDEFAULTS.set(-1, forKey: "SaveImportVoiceIndex")
                            }
    //
                            }
                            
    //                    }
                        
                        
                        
                    }
                    if indexPath.section == 0 {
                        
                        
                        if saveRecordedVoiceIndex == tapIndexSection0 {
                            
                            selectedVoiceName = "None"
                            selectedVoice =  URL(string: "https://www.None.com")
                            Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")

                            
                            let userInfo: [AnyHashable: Any] = ["selectedVoiceName": selectedVoiceName,"selectedVoice":selectedVoice as Any]
                            NotificationCenter.default.post(name: Notification.Name("selectedVoice"), object: nil, userInfo: userInfo)
                            Constants.USERDEFAULTS.set(-1, forKey: "SaveImportVoiceIndex")
                        }
                            if saveRecordedVoiceIndex != -1 {
                                
                                if arrRecodedAudio.count == 1 {
                                    Constants.USERDEFAULTS.set(0, forKey: "SaveIndexdefaultVoice")
                                    selectedVoiceName = "None"
                                    selectedVoice =  URL(string: "https://www.None.com")
                                    let userInfo: [AnyHashable: Any] = ["selectedVoiceName": selectedVoiceName,"selectedVoice":selectedVoice as Any]
                                    NotificationCenter.default.post(name: Notification.Name("selectedVoice"), object: nil, userInfo: userInfo)
                                    Constants.USERDEFAULTS.set(-1, forKey: "SaveRecodedVoiceIndex")
                            }
                            }
                            
                        
                    }
                    
                    
                }

        }
   
            
            alertController.addAction(CancelAction)
            alertController.addAction(DeleteAction)
            
            // Present the alert
            if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                viewController.present(alertController, animated: true, completion: nil)
            }
        }
        
    }


// tbl ChooseVoice Cell
class tbl_ChooseVoice_Cell:UITableViewCell {
    
    @IBOutlet weak var lblVoiceName: UILabel!
    @IBOutlet weak var img_Icon: UIImageView!
}



