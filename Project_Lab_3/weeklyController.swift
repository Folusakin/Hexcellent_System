//This controller graphs the user data from their water intake

//  dailyController.swift
//  Project_Lab_3
//
//  Created by Folusakin Abiola on 11/9/21.
//

import Foundation

import SwiftUI

import UIKit
import Charts


class weeklyController: UIViewController, ChartViewDelegate{
    
    //Create a BarChartView object which allows access to different chart formats
    var barChart = BarChartView()
    //User credentials are assigned from the previous controller OptionsMenuController
    var UserCredentials:(Bool, String, String, Int)?
    //timePlot Array contains number 0 through 6
    let timePlot = Array(0...6)
    

    @IBOutlet weak var monthText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.delegate = self

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        
        async{
            //getWeeklyOz makes a call to databse to retrieve users' entries over the week using the authorization token and userId as parametres
            let userPlot = try await getWeeklyOz(usID: UserCredentials!.3, token: UserCredentials!.1)
            //The water intake array from userPlot is set to a constant Oz_Array
            let Oz_Array = userPlot.1
            
            //The size and position of the barchart is defined
            barChart.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            //The chart is centered
            barChart.center = view.center
            //The barchart is added to the view
            view.addSubview(barChart)
            
            //A barchart data entry object is created which contains the data array to be plotted as inputs
            var entries = [BarChartDataEntry]()
            for x in 0..<7{
                
                //Seven (7) entries are included in the variable "entries)
                //timePlot[x] + userPlot.2 uses the firstDay of the week returned from calling getWeeklyOz and generates the actual day of the month by adding a number from 0 to 6 to it and that is used for the x axis while the water intake data is used for the y axis.
                entries.append(BarChartDataEntry(x: Double(timePlot[x]+userPlot.2), y: Oz_Array[x]))
            }
            
            let set = BarChartDataSet(entries: entries)
            //The label of the BarChart is set here
            set.label = "User Water Consumption"
            
            set.colors = ChartColorTemplates.joyful()
            
            let data = BarChartData(dataSet: set)
            
            barChart.data = data
            //Ensures only 10 elements are visible at a time
            barChart.setVisibleXRangeMaximum(10)
        }
        //This gets the Month of the year an sets a label based on the received string
        let monthString = getMonth()
        monthText.text = monthString
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func getWeeklyOz(usID:Int,token:String) async throws -> (Array<Double>,Array<Double>,Int){
        //Below is the url string which concatenated with the userID to make the string that is converted to a URL.
        var urlString = "???"
        urlString = urlString+String(usID)
        let Url = URL(string: urlString)
        
        //The "Water_7_Array" stores the values of the water intake by the user for the last seven days. It is initialized to all 0's
        var Water_7_Array = [Double]()
        Water_7_Array = Array(repeating: 0, count: 7)
        
        //The "Calorie_7_Array" stores the values of the calorie intake by the user for the last seven days. It is initialized to all 0's
        var Calorie_7_Array = [Double]()
        Calorie_7_Array = Array(repeating: 0, count: 7)
        
        
        var arrayCalories = [Int]()
        var arrayOz = [Int]()
        
        var timeIndexArray = [Int]()
        
        var sumPlotOzArray = [Int]()
        
        var sumPlotCaloriesArray = [Int]()
        
        var timePlotArray = [Int]()
        
        var index:Int!
        //A
        var arrayIndex=Int(0)

        
        index = 0
        //A URL request is created from the URL
        var request = URLRequest(url: Url!)
        
        var tempOzStore = Int(0)
        var tempCalorieStore = Int(0)
        
        //A Date object is created along with a formatter object that returns dates in the form "yyyy-MM-dd"
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        //date_Result generates the date of the day
        let date_Result = formatter.string(from: date)

        //the .startofWeek and .endOfWeek methods are called and formatted into "yyyy-MM-dd" enabled by the extension of Date() in dailyController
        let startWeek = Date().startOfWeek
        let endWeek = Date().endOfWeek
        let WeekStart = formatter.string(from: startWeek!)
        let WeekEnd = formatter.string(from: endWeek!)
        
        
        //Below retrieves the indices for the day of the month from the "WeekStart" string above
        let BeginStartIndex = WeekStart.index(WeekStart.startIndex,offsetBy: 8)
        let BeginEndIndex = WeekStart.index(WeekStart.startIndex, offsetBy: 9)
        
        //The retrieved indices are then used to return the day of the month the week starts on
        let WeekDayStart = BeginStartIndex...BeginEndIndex
        
        var firstDay:Int
        firstDay = Int(WeekStart[WeekDayStart])!//"firstDay" stores the day of the month the week starts on as an integer.
        
        //Below retrieves the indices for the day of the month from the "WeekEnd" string above
        let FinishStartIndex = WeekEnd.index(WeekEnd.startIndex,offsetBy: 8)
        let FinishEndIndex = WeekEnd.index(WeekEnd.startIndex, offsetBy: 9)
        
        //The retrieved indices are then used to return the day of the month the week ends on
        let WeekDayEnd = FinishStartIndex...FinishEndIndex
        let lastDay = Int(WeekEnd[WeekDayEnd])
        //"lastDay" stores the day of the month the week ends on as an integer.
        
        
        //The method for the URL is designated as a "GET"
        request.httpMethod = "GET"
        //The authToken header is set to the retrieved authorization token
        request.setValue(token, forHTTPHeaderField: "authToken")
        
        //A task is created with URLSession, using the URL request which returns the data, response from the databse(status code) and any errors
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //"response as? HTTPURLResponse" allows the response to return the status code
            if let response = response as? HTTPURLResponse {
//                print(response.statusCode)
            }
            //The data is formatted as a string JSON
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            do{
                //Result is the decoded JSON to the "WeeklyResult" Dictionary format.
                let Results = try JSONDecoder().decode([WeeklyResult].self, from:data!)
                index = 0
                //The for loop below checks what databse entries were made in the present week
                
                for _ in Results{
                    let str = Results[index].entryDate
                    print(str)
                    
                    //manually determine offset required to get the day of the month
                    let DayStartIndex = str.index(str.startIndex,offsetBy: 8)
                    let DayEndIndex = str.index(str.startIndex, offsetBy: 9)
                    
                    let hour = DayStartIndex...DayEndIndex
                    //"newString" stores the hoursof the entry
                    let newString = Int(str[hour])
                
                    //This stores all the data into arrays arrayCalories and arrayOz. The data is matched to the date it was recorded on in timeIndexArray
                    if(newString!<=lastDay! && newString!>=firstDay){
                        arrayCalories.append(Results[index].calories)
                        arrayOz.append(Results[index].waterOz)
                        
                        //convert the time of the measurement to Integer and store
                        timeIndexArray.append(newString!)
                    }
                    print(Results[index].calories)
                    index+=1
                }

                //This for loop adds up all the data entries corresponding to different days.
                for time in timeIndexArray{
                    
                    //arrayIndex is used to check if the end of the timeIndexArray is about to be reached. Since all entries from any particular day follow one another, checking if the day in timeIndexArray at the ith position is equal to the ith+1 position allows for summation of all entries from the same day.
                    if(arrayIndex+1<timeIndexArray.count && timeIndexArray[arrayIndex] == timeIndexArray[arrayIndex+1])
                    {
                        //if the above conditions are satisfied i.e the timeIndexArray is not about to reach its end and the consectuive indices in the timeIndexArray are equal, add up the entries in arrayOz and arrayCalories and store in tempOzStore and tempCalorieStore respectively.
                        tempOzStore+=arrayOz[arrayIndex]
                        tempCalorieStore+=arrayCalories[arrayIndex]
                    }
                    
                    else{
                        //if there is only one entry from a day, that entry is stored in the sumPlotOzArray for water intake or sumPlotCaloriesArray for calorie intake. This condition is also fulfilled when the last entry for a day is reached which is just added to the temporary variable to complete that day. This is then stored in the sumPlotOzArray for water intake or sumPlotCaloriesArray for calorie intake
                        if(tempOzStore != arrayOz[arrayIndex]){
                            tempOzStore+=arrayOz[arrayIndex]
                            tempCalorieStore+=arrayCalories[arrayIndex]
                        }
                        sumPlotOzArray.append(tempOzStore)
                        sumPlotCaloriesArray.append(tempCalorieStore)
                        
                        //timePlotArray stores the day of the month that corresponds to the entry
                        timePlotArray.append(time)
                        //the temporary storage variable is initialized back to zero to start the sum for another day of the month
                        tempOzStore = Int(0)
                        tempCalorieStore = Int(0)
                        
                    }
                    //arrayIndex is incremented each time. Checking for one less than the out of range condition
                    arrayIndex+=1
                }
                //This for loop assigns the sumPlotOzArray values to an index between 0 and 6 representing the seven days of the week. The index is calculated by getting the difference between the day recorded for each entry in timePlotArray and the firstDay of the week.
                for x in 0..<timePlotArray.count{
                    var checkRepeat:Int
                    //This checks if any values have been assigned at a particular index in the Water_7_Array.
                    checkRepeat = Int(Water_7_Array[timePlotArray[x]-firstDay])
                    
                    //If it isn't empty, that means there are two entries for the same day. This is corrected by adding the previous entry and the current entry fot the same day
                    if(checkRepeat != 0 ){
                        Water_7_Array[timePlotArray[x]-firstDay] += Double(sumPlotOzArray[x])
                        Calorie_7_Array[timePlotArray[x]-firstDay] += Double(sumPlotCaloriesArray[x])
                    }
                    //If it is empty, the index at position "timePlotArray[x]-firstDay" is assigned to the entry corresponding to the day of the month
                    else{
                        Water_7_Array[timePlotArray[x]-firstDay] = Double(sumPlotOzArray[x])
                        Calorie_7_Array[timePlotArray[x]-firstDay] = Double(sumPlotCaloriesArray[x])
                    }
                }

//                }
                
            }catch{
                //if any of the above fails print error
                print(error.localizedDescription)
            }
            
        }
        //activate the task
        task.resume()
        do{
            sleep(1)
        }
        //return the array containing the entry for the water intake, calorie intake for the weeek with the firstDay of the Week
        return (Calorie_7_Array,Water_7_Array,firstDay)
        
        
    }
    
}

