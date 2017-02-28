//
//  ListViewController.swift
//  MapsMod
//
//  Created by Yashasvi Makin on 24/02/17.
//  Copyright © 2017 Yashasvi Makin. All rights reserved.
//

import UIKit

class ListViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var MapsMod: UILabel!
    let items:[[String]]! = [["Item 1","Item 2","Item 1","Item 2","Item 1","Item 2"],["Item A","Item B","Item 1","Item 2","Item 1","Item 2"],]
    let subs:[[String]]! = [["sub 1","sub 2"],["sub A","sub B"]]
    let sections:[String]! = ["Number","Letter"]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        MapsMod.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(items[indexPath.section][indexPath.row])")
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! custumCell
        cell.label.text = items[indexPath.section][indexPath.row]
        //cell.imageView?.image = UIImage(named: "star")
        return cell
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
