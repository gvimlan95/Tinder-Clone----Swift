//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func signInButtonPressed(sender: AnyObject) {
        
        let permissions = ["public_profile","email"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user:PFUser?,error:NSError?) -> Void in
            
            if let error = error {
                print(error)
            }else if let user = user {
                
                print(user)
                
                if let interestedInWomen = user["interestedInWomen"] {
                    
                    self.performSegueWithIdentifier("mainToLogin",sender:self)
                    
                }else {
                    
                    self.performSegueWithIdentifier("mainToSignUp",sender:self)
                }
                
            }
            
        }
        
    }
    
    override func viewDidAppear(animated:Bool){
        //PFUser.logOut()
        
        if let username = PFUser.currentUser()?.username {
            
            if let interestedInWomen = PFUser.currentUser()?["interestedInWomen"]{
                
                self.performSegueWithIdentifier("mainToLogin",sender:self)
                
            }else{
                self.performSegueWithIdentifier("mainToSignUp",sender:self)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

