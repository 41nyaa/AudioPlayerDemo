//
//  ViewController.swift
//  AudioStreamingDemo
//
//  Created by 41nyaa on 2021/10/02.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var urlText: UITextField?
    @IBOutlet var playButton: UIButton?
    @IBOutlet var pauseButton: UIButton?
    @IBOutlet var playProgress: UIProgressView?
    @IBOutlet var minTime: UILabel?
    @IBOutlet var maxTime: UILabel?
    @IBOutlet var status: UILabel?
    var audio: AVAudioPlayer!
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        urlText!.delegate = self
        urlText!.text = "https://***.mp3"
        
        playProgress!.progress = 0
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let url = URL(string: textField.text!)!
        status!.text = "loading..."
        let downloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
            do {
//                guard let _ = error else {
//                    self.status!.text = "load error!"
//                    return
//                }
//                if let httpResponse = response as? HTTPURLResponse {
//                    if !(200...299).contains(httpResponse.statusCode) {
//                        self.status!.text = "load error!"
//                        return
//                    }
//                }
                guard let data = data else {
                    self.status!.text = "load error!"
                    return
                }
                self.audio = try AVAudioPlayer(data: data)
                if self.audio != nil {
                    DispatchQueue.main.async {
                        self.minTime!.text = String(0)
                        self.maxTime!.text = String(Int(self.audio!.duration))
                        
                        self.playProgress!.progress = 0

                        self.status!.text = "loaded " + textField.text!
                        self.urlText!.text = ""
                    }
                }
            } catch {
                print("error!")
                print(error.localizedDescription)
            }
        }
        downloadTask.resume()
        return true
    }
    
    @IBAction func play() {
        if audio != nil {
            audio.play()
            startTimer()
        }
    }

    @IBAction func pause() {
        if audio != nil {
            audio.pause()
            cancelTimer()
        }
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: self.timeout)
    }

    func cancelTimer() {
        guard let timer = self.timer else {
            return
        }
        timer.invalidate()
        self.timer = nil
    }

    func timeout(timer: Timer) {
        if self.timer != timer {
            return
        }
        DispatchQueue.main.async {
            if self.audio != nil {
                self.playProgress!.setProgress(Float(self.audio.currentTime/self.audio.duration), animated: true)
            }
        }
    }

}

