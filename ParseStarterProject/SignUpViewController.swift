//
//  SignUpViewController.swift
//  ParseStarterProject
//
//  Created by VIMLAN.G on 8/1/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var interestedInWomen: UISwitch!
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        PFUser.currentUser()?["interestedInWomen"] = interestedInWomen.on
        PFUser.currentUser()?.save()
        
        self.performSegueWithIdentifier("signUpToSwipe",sender:self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me",parameters : ["fields":"id,name,gender,email"])
        graphRequest.startWithCompletionHandler({
            (connection,result,error) -> Void in
            
            if error != nil {
                print(error)
            }else if let result = result {
                PFUser.currentUser()?["gender"] = result["gender"]
                PFUser.currentUser()?["name"] = result["name"]
                PFUser.currentUser()?["email"] = result["email"]
                
                PFUser.currentUser()?.save()
                
                let userId = result["id"] as! String
                
                let facebookProfilePictureURL = "https://graph.facebook.com/" + userId + "/picture?type=large"
                
                if let fbPicUrl = NSURL(string: facebookProfilePictureURL) {
                    
                    if let data = NSData(contentsOfURL: fbPicUrl) {
                        
                        self.userImage.image = UIImage(data:data)
                        
                        let imageFile : PFFile = PFFile(data:data)
                        
                        PFUser.currentUser()?["image"] = imageFile
                        PFUser.currentUser()?.save()
                    }
                }
            }
            
        })
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
