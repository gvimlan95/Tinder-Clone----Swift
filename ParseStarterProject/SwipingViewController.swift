//
//  SwipingViewController.swift
//  ParseStarterProject
//
//  Created by VIMLAN.G on 8/1/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SwipingViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var displayedUserId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: "wasDragged:")
        self.userImage.addGestureRecognizer(gesture)
        
        self.userImage.userInteractionEnabled = true
        
        updateImage()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint:PFGeoPoint?,error:NSError?) -> Void in
            
            if let geoPoint = geoPoint {
                
                PFUser.currentUser()?["location"] = geoPoint
                PFUser.currentUser()?.save()
            }
        }
    }
    
    func updateImage(){
        
        let query = PFUser.query()
        
        var interestedIn = "female"
        
        if PFUser.currentUser()!["interestedInWomen"] as! Bool == false {
            
            interestedIn = "male"
        }
        
        var isFemale = true
        
        if PFUser.currentUser()!["gender"] as! String == "male" {
            
            isFemale = false
        }
        
//        if let latitude = PFUser.currentUser()?["location"]!.latitude {
//            
//            if let longitude = PFUser.currentUser()?["location"]!.longitude {
//                
//                print(latitude)
//                print(longitude)
//                
//                query!.whereKey("location",withinGeoBoxFromSouthwest: PFGeoPoint(latitude:latitude-1,longitude:longitude-1),toNortheast:PFGeoPoint(latitude:latitude+1,longitude: longitude+1))
//            }
//        }
        
        
        query!.whereKey("gender",equalTo:interestedIn)
        query!.whereKey("interestedInWomen",equalTo:isFemale)
        
        var ignoredUsers = [""]
        
        if let acceptedUser = PFUser.currentUser()!["accepted"] {
            
            ignoredUsers += acceptedUser as! Array
        }
        if let rejectedUser = PFUser.currentUser()!["rejected"] {
            
            ignoredUsers += rejectedUser as! Array
            
        }
        
        query!.whereKey("objectId",notContainedIn: ignoredUsers)

        query!.limit = 1
        
        query!.findObjectsInBackgroundWithBlock {
            (objects : [AnyObject]?, error : NSError? ) -> Void in
            if error != nil {
                print(error)
                
            }else if let objects = objects as? [PFObject] {
                for object in objects {
                    
                    self.displayedUserId = object.objectId!
                    
                    let imageFile = object["image"] as! PFFile
                    
                    imageFile.getDataInBackgroundWithBlock {
                        (data:NSData?, error:NSError?) -> Void in
                        
                        if error != nil {
                            
                            print(error)
                            
                        }else{
                            if let data = data {
                                
                                
                                self.userImage.image = UIImage(data:data)
                                
                            }
                            
                        }
                    }
                }
            }
        }

    }
    
    func wasDragged(gesture:UIPanGestureRecognizer){
        
        let translation = gesture.translationInView(self.view) //gives info on location
        let label = gesture.view!
        
        label.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        let scale = min(100 / abs(xFromCenter),1)
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter/200)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var acceptedOrRejected = ""
            
            if label.center.x < 100 {
                print("Not Chosen " + self.displayedUserId)
                acceptedOrRejected = "rejected"
                
            }else if label.center.x > self.view.bounds.width - 100 {
                
                print("Chosen " + self.displayedUserId)
                acceptedOrRejected = "accepted"
            }
            
            PFUser.currentUser()?.addUniqueObjectsFromArray([self.displayedUserId],forKey:acceptedOrRejected)
            PFUser.currentUser()?.save()
            
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1, 1)
            label.transform = stretch
            label.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height / 2)
            
            updateImage()
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 
        if segue.identifier == "logOut" {
            
            PFUser.logOut()
        }
    }

}
