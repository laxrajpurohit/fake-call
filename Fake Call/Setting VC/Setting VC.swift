//
//  Setting VC.swift
//  Fake Call
//
//  Created by mac on 03/04/24.
//

import UIKit

class SettingVC: UIViewController {

    @IBOutlet weak var tblSetting: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
  
    var arrSetting:[[String]] = [[""],["Share App","Rate This App","Help"],[""],["Privacy Policy","Terms of Usege"]]
    var arrImage:[[String]] = [[""],["share","star","help"],[""],["insurance","google-docs"]]
    var arrHeader = ["","General","More App","Legal"]

}

// TableView Delegate Methods
extension SettingVC:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSetting.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSetting[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        DispatchQueue.main.async { [self] in
//            tblHeight.constant = tblSetting.contentSize.height
//            }
        
        if indexPath.row == 0  && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tblSettingPremiumbanner_Cell", for: indexPath) as! tblSettingPremiumbanner_Cell
            cell.selectionStyle = .none
            return cell

        }
        if indexPath.row == 0  && indexPath.section == 2 {
                   let cell = tableView.dequeueReusableCell(withIdentifier: "tblSettingApp_Cell", for: indexPath) as! tblSettingApp_Cell
                   cell.selectionStyle = .none
                   return cell
               } else {
                   let cell = tableView.dequeueReusableCell(withIdentifier: "tblSetting_Cell", for: indexPath) as! tblSetting_Cell
                   cell.selectionStyle = .none
                   cell.accessoryType = .disclosureIndicator
                   cell.lblName.text = self.arrSetting[indexPath.section][indexPath.row]
                   cell.imgIcon.image = UIImage(named: arrImage[indexPath.section][indexPath.row])
                   return cell
               }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        let label = UILabel(frame: CGRect(x: 10, y: -16, width: headerView.bounds.width, height: headerView.bounds.height))
        label.text = self.arrHeader[section]
        label.textColor = .init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        headerView.addSubview(label)
          return headerView
      }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Utils().IpadorIphone(value: 30)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section  == 0 {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 400
            } else {
                return 180
            }
        } else   if indexPath.section  == 2 {
            return Utils().IpadorIphone(value: 194)
        } else {
            return Utils().IpadorIphone(value: 50)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}


// tblSetting Cell
class tblSetting_Cell:UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
}

// tblSettingApp Cell
class tblSettingApp_Cell:UITableViewCell {
    
}

// tblSettingPremiumbanner Cell
class tblSettingPremiumbanner_Cell:UITableViewCell {
    
}
