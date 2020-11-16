//
//  ViewController.swift
//  RuleEngine
//
//  Created by Afzal Hossain on 10/6/20.
//  Copyright © 2020 Afzal Hossain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var loadingView : LoadingView!
    
    @IBOutlet weak var labelEngineState: UILabel!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var buttonLoadData: UIButton!
    @IBOutlet weak var labelSystemLog: UILabel!
    @IBOutlet weak var buttonStartEngine: UIButton!
    @IBOutlet weak var buttonResetEngine: UIButton!
    @IBOutlet weak var buttonStopEngine: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("view controller did load...\(Date())")
        if RuleEngine.sharedInstance.state == EngineState.initial {
            updateUIForLoad()
        }
//        else if RuleEngine.sharedInstance.state == EngineState.active{
//            updateUIForStart()
//        }else if RuleEngine.sharedInstance.state == EngineState.inactive{
//            updateUIForStop()
//        }
        else{
            updateUIForReset()
        }
    }
    
    @IBAction func loadData(_ sender: Any) {
        Loader.sharedInstance.deleteStudies()
        Loader.sharedInstance.deleteAllConfigs()
        Loader.sharedInstance.deleteAllMappings()

        self.loadingView = LoadingView(uiView: self.view, message: "Loading Data")
        print("loading ......")
        
        DispatchQueue.global(qos: .background).async {
            Loader.sharedInstance.loadStudies(email: self.textEmail.text ?? "")
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {_ in
                    if let loaderView = self.loadingView{ // If loadingView already exists
                        self.loadingView.hide()
                    }
                    print("updating ui ....")
                    self.updateUIForLoad()
                })
            }
        }
    }
    private func updateUIForLoad(){
        DispatchQueue.main.async {
            self.labelEngineState.text = "Ready to Start"
            self.textEmail.isHidden = true
            self.buttonLoadData.isHidden = true
            self.labelSystemLog.text = "Data Loaded for the following studies:"
            self.buttonStartEngine.isHidden = false
            self.buttonResetEngine.isHidden = true
            self.buttonStopEngine.isHidden = true
            
            var studies:[Study] = Loader.sharedInstance.getAllStudies()
            for study in studies{
                self.labelSystemLog.text! += ("\n\t--\(study.name!)")
            }
        }
    }
    
    @IBAction func startEngine(_ sender: Any) {
        if RuleEngine.sharedInstance.loadData(){
            if  RuleEngine.sharedInstance.start(){
                updateUIForStart()
            }
        }
    }
    private func updateUIForStart(){
        labelEngineState.text = "Running"
        buttonStartEngine.isHidden = true
        buttonResetEngine.isHidden = true
        buttonStopEngine.isHidden = false
    }
    
    @IBAction func resetEngine(_ sender: Any) {
        if RuleEngine.sharedInstance.reset() {
            updateUIForReset()
        }
    }
    
    private func updateUIForReset(){
        labelEngineState.text = "Load Data to Start"
        buttonStartEngine.isHidden = true
        buttonResetEngine.isHidden = true
        buttonStopEngine.isHidden = true
        textEmail.isHidden = false
        buttonLoadData.isHidden = false
        labelSystemLog.text = ""
    }
    
    
    @IBAction func stopEngine(_ sender: Any) {
        if RuleEngine.sharedInstance.stop() {
            updateUIForStop()
        }
    }
    
    private func updateUIForStop(){
        labelEngineState.text = "Inactive"
        buttonStartEngine.isHidden = false
        buttonResetEngine.isHidden = false
        buttonStopEngine.isHidden = true
    }
}

