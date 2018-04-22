//
//  QuizViewController.swift
//  Quiz App
//
//  Created by Adrianne Williams on 4/22/18.
//  Copyright © 2018 edu.self. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    //the json file url
    let QUIZ_URL = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json";
    
    //A string array to save all the names
    //var nameArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getJsonFromUrl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //this function is fetching the json from URL
    func getJsonFromUrl(){
        //creating a NSURL
        let url = NSURL(string: QUIZ_URL)
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                //printing the json in console
                print(jsonObj!.value(forKey: "questions")!)
                print(jsonObj?.value(forKey: "numberOfQuestions"))
            }}
    )}


//
//                //getting the avengers tag array from json and converting it to NSArray
//                if let heroeArray = jsonObj!.value(forKey: "avengers") as? NSArray {
//                    //looping through all the elements
//                    for heroe in heroeArray{
//
//                        //converting the element to a dictionary
//                        if let heroeDict = heroe as? NSDictionary {
//
//                            //getting the name from the dictionary
//                            if let name = heroeDict.value(forKey: "name") {
//
//                                //adding the name to the array
//                                self.nameArray.append((name as? String)!)
//                            }
//
//                        }
//                    }
//                }
//
//                OperationQueue.main.addOperation({
//                    //calling another function after fetching the json
//                    //it will show the names to label
//                    self.showNames()
//                })
//            }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
