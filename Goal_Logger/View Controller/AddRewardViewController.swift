//
//  AddRewardViewController.swift
//  Goal_Logger
//
//  Created by Will Chew on 2019-12-31.
//  Copyright © 2019 Will Chew. All rights reserved.
//

import UIKit
import CoreData

class AddRewardViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var rewardNameTF: UITextField!
    @IBOutlet weak var costTF: UITextField!
    @IBOutlet weak var stockTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var addImageView: UIImageView!
    
    
    
    var managedContext: NSManagedObjectContext!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        costTF.delegate = self
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate?.persistentContainer.viewContext
        setupView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        view.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        let points = UserDefaults.standard.integer(forKey: "Points")
        
        pointsLabel.text = "Your Points: \(points)"
        
        let imageViewGesture = UITapGestureRecognizer(target: self, action: #selector(imagePressed(_:)))
        addImageView.addGestureRecognizer(imageViewGesture)
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func imagePressed(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = sourceType
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    @objc func dismissView(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Leave without Saving?", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == addView {
            return false
        }
        return true
    }
    
    func setupView() {
        addView.layer.cornerRadius = 8
        blurView.alpha = 0.8
        
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderWidth = 2
        saveButton.layer.borderColor = UIColor.black.cgColor
        saveButton.isEnabled = false
        
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor.black.cgColor
        
        addImageView.layer.borderWidth = 1
        addImageView.layer.borderColor = UIColor.black.cgColor
    }
    
    
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismissView(self)
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        //        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindAfterAddingRewardSegue" {
            addReward()
        }
    }
    
    
    
    
    
    
    
}

extension AddRewardViewController: UITextFieldDelegate {
    
    func addReward() {
        let reward = Reward(context: managedContext)
        
        var rewardName = ""
        
        if rewardNameTF.text == "" {
            rewardName = "Unnamed Reward"
        } else {
            rewardName = rewardNameTF.text!
        }
        reward.name = rewardName
        
        
        let cost = Int32(costTF.text!)!
        reward.cost = cost
        
        
        
        var stock : Int32 = 0
        if stockTF.text == "" {
            stock = 1
        } else {
            stock = Int32(stockTF.text!)!
            
        }
        reward.stock = stock
        reward.uuid = UUID()
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error Saving: \(error), \(error.userInfo)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if costTF.text != "" {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

extension AddRewardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addImageView.image = image
        } else {
            print("SOmething went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
