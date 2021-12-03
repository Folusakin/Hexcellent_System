//
//  ViewController.swift
//  TestText
//
//  Created by Coby Kromis on 11/20/21.
//
import Foundation

import UIKit

class DummyController: UIViewController {

    @IBOutlet weak var heartLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
        //This allows the textfile containing the data to be read
        errno = 0
        if freopen("/Users/cobykromis/Documents/data.txt", "r", stdin) == nil {
            perror("/Users/cobykromis/Documents/data.txt")
        }
        //This timer executes the objective c  function every 75ms reading the text file that stores the user heartrate file
        _ = Timer.scheduledTimer(timeInterval: 0.075
                                         , target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    @objc func fire()
    {
        
        var heartStringtoInt: String
        var checkInt: String
        var intCheck2: String
        var convertInteger: Int
        var convertInteger2: Int
        
        heartStringtoInt = "---"
        let line:String
        //If a line does not exist readline has a default value of "--"
        line = readLine() ?? "--"
        //
        heartStringtoInt = line
        
        //Check the first three and two characters in each line
        checkInt = String(heartStringtoInt.prefix(3))
        intCheck2 = String(heartStringtoInt.prefix(2))
        
        //The characters are converted to integers. If the characters cannot be converted to integers
        //The give a value of 0
        convertInteger = Int(checkInt) ?? 0
        print("This is the integer: \(convertInteger)")
        convertInteger2 = Int(intCheck2) ?? 0
        //If the first three characters are greater than 200, with 200 being the maximum allowable human heartrate
        //The assumption is that the there was a repeat in the data sequence and only the first two characters are
        //displayed
        if(convertInteger > 200){
            heartLabel.text = intCheck2
        }
        //If the first three characters are less than 200, with 200 being the maximum allowable human heartrate and
        //greater than 100, the first three characters are displayed.
        else if(convertInteger<200 && convertInteger>100){
            heartLabel.text = checkInt
        }


    }

}
