//
//  ImageViewController.swift
//  textDemo
//
//  Created by ARTOONMM0024 on 07/09/21.
//

import UIKit
import AVFoundation
import Vision

@available(iOS 13.0, *)
class ImageViewController: UIViewController {

//    let textAnalyze = Analyze()         //create instance of Analyze Class
    let backgroundProcess = DispatchQueue.global()
    //var listNumber = UserDefaults.standard.integer(forKey: "startNumber")       //make the starting list number set to what was defined on startup
    var recognizedText: String!
    let computerName = UserDefaults.standard.string(forKey: "computerName")     //get the computer name
    
    var image: UIImage!
    var newImage: UIImage!
    
    
    var textRecognitionRequest = VNRecognizeTextRequest()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var screenCaptureBox: View!      //used to define where to screen capture
    @IBOutlet weak var analyzedTextLabel: UITextField!
    
    @IBOutlet weak var stackBottom: NSLayoutConstraint!     //bottom of stack view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = self.image
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewController.keyboardWillShow(sender:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewController.keyboardWillHide(sender:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func scaneAnotherPressed(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)     //dismiss back to the the camera
        
        
        
    }//end of scanANotherPressed
    
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        return request
    }()
    
    @IBAction func analyzeButtonPressed(_ sender: Any) {
        
        newImage = imageView.snapshot(of: screenCaptureBox.frame)           //make new screen capture of the defined area
        
        
        //use SwiftOCR to analyze the image and get text
        
        
        
//        recognizedText = textAnalyze.recognizeText(image: newImage!)
//
//        analyzedTextLabel.text = recognizedText
        
        let ciimage : CIImage = CIImage(cvPixelBuffer: screenCaptureBox.frame as! CVPixelBuffer)
        let theimage : UIImage = self.convert(cmage: ciimage)
        
        self.image = theimage
        processImage()
       
        
        
    }//end of analyzeButtonPressed
    
    
    func processImage()
    {
        DispatchQueue.main.async {
//            self.nameLabel.text = ""
//            self.setLabel.text = ""
//            self.numberLabel.text = ""
        }
        
        guard let image = image, let cgImage = image.cgImage else { return }
        
        let requests = [textDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    func convert(cmage:CIImage) -> UIImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?)
    {
        
        if let error = error {
            print(error.localizedDescription)
//            self.processing = false
            return
        }
        guard let results = request?.results, results.count > 0 else {
            print("No text was found.")
//            self.processing = false
            return
        }

        if let requestResults = request?.results as? [VNRecognizedTextObservation] {
            self.recognizedText = ""
            for observation in requestResults {
                guard let candidiate = observation.topCandidates(1).first else { return }
                self.recognizedText += candidiate.string
                self.recognizedText += " "
            }
            
//            var replaced = self.recognizedText.replacingOccurrences(of: "-", with: "")
//            replaced = String(replaced.filter { !"\n\t\r".contains($0) })
//            let replacedArr = replaced.components(separatedBy: " ")
//
//            for here in replacedArr
//            {
//                let final = here.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//
//                if (final.count == 10 || final.count == 13) && final.containsISBNnums  // validate barcode
//                {
//                    self.finalText += final
//                    print(final)
//                    self.captureSession.stopRunning()
//                    DispatchQueue.main.async {
//                        self.previewLayer.removeFromSuperlayer()
//                    }
//                    break
//                }
//            }

            DispatchQueue.main.async {
//                self.numberLabel.text = self.recognizedText
//                self.nameLabel.text = self.recognizedText
//                self.captureSession.stopRunning()
              
                self.analyzedTextLabel.text = self.recognizedText

            }
        }
        
//        self.processing = false
    }
    
    @IBAction func createCSVButtonPressed(_ sender: Any) {
        
        
        //createCSV2(from: MACdictionary)          //create the .csv file
        
        guard let CreateDictionary = UserDefaults.standard.object([String: String].self, with: "data") else {return}      //retrieve the dictionary from userDefaults
        
        
        for text in CreateDictionary {
            print("\(text.value)\n")
        }
        
        var csvString = "Name, MAC\n"
        for data in CreateDictionary {
            let line = "\(data.key),\(data.value)"
            let newLine = "\n"
            csvString.append(contentsOf: line)           //add each element to the .CSV file
            csvString.append(newLine)       //trying to add a new line here before adding in new numbers
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("CSVRec.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        } catch {
            print("error creating file")
        }
        
        UIDevice.vibrate()      //vibrate phone
        
        
    }//end of createCSV
    
    
    
    @IBAction func addToDictButtonPressed(_ sender: Any) {      //adds analyzed text to dictionary
        //forgot the get the new starting list number --- see if works
        
        guard var DataDictionary = UserDefaults.standard.object([String: String].self, with: "data") else {return}      //retrieve the dictionary from userDefaults
       
        
        var listNumber = UserDefaults.standard.integer(forKey: "startNumber")       //retrieve the new starting list number
        
        
        let listString:String = ((computerName)!+String(listNumber))        //add the int to the string
        
        
        DataDictionary[listString] = recognizedText      //append the recognized text to a new dictionary item
        
        
        listNumber += 1    //add one to the list number
        
        
        UserDefaults.standard.set(listNumber, forKey: "startNumber")        //re-save the starting number
        
        
        UserDefaults.standard.set(object: DataDictionary, forKey: "data")        //save the dictionary to userDefaults
        
        
        //testing purposes
        for data in DataDictionary {
            print(data.value)
        }
        
        UIDevice.vibrate()      //vibrate phone
        
        
    }//end of addToDict
    
    
    
    
    
    
    
    func createCSV(from recArray:[Int: String]) {     //function to create .CSV file
        var csvString = "Number, Mac\n"
        for (number, mac) in recArray {
            let data = "\(number),\(mac)\n"
            let newLine = "\n"
            csvString.append(contentsOf: data)           //add each element to the .CSV file
            csvString.append(newLine)       //trying to add a new line here before adding in new numbers
            
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("CSVRec.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        } catch {
            print("error creating file")
        }
        
        
        
    }//end of createCSV function
    
    
    
    //testing this function to see if works
    
    func createCSV2(from recArray:[Int: String]) {     //function to create .CSV file
        var csvString = "Number, Mac\n"
        for data in recArray {
            let line = "\(data.key),\(data.value)"
            let newLine = "\n"
            csvString.append(contentsOf: line)           //add each element to the .CSV file
            csvString.append(newLine)       //trying to add a new line here before adding in new numbers
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("CSVRec.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        } catch {
            print("error creating file")
        }
        
        
        
    }//end of createCSV function
    
    
    
    
    @objc func keyboardWillShow(sender: NSNotification) {           //called when keyboard appears
        UIView.animate(withDuration: 1, animations: {
                self.stackBottom.constant += 250 // Move stack view above the keyboard
            })
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {       //called when keyboard appears
        UIView.animate(withDuration: 1, animations: {
            self.stackBottom.constant -= 250 // Move stack view back down to regular spot
        })
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {         //dismiss the keyboard when clicked out
        
        self.view.endEditing(true)
        
    }//end of touchesBegan
    
    
    
}//end of class



extension UIImageView {
    
   
    
    func snapshot(of rect: CGRect? = nil) -> UIImage? {

        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
  
        
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
   
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
}


extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}



extension UIDevice {                //makes it easier to read and call the vibrate device function
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}


import UIKit

@IBDesignable
class View: UIView {
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {  //@IBInspectable allows to change in the storyboard
        
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
        
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
}


