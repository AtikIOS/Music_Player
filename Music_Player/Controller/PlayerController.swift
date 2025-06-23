//
//  PlayerController.swift
//  Music_Player
//
//  Created by Atik Hasan on 10/14/24.
//
import UIKit
import AVFoundation

class PlayerController: UIViewController {
    
    @IBOutlet weak var DisplayImgView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var DisplaySongTittle: UILabel!
    @IBOutlet weak var startringTimelbl: UILabel!
    @IBOutlet weak var endtimelbl: UILabel!
    @IBOutlet weak var PlayPauseImgview: UIImageView!
    @IBOutlet weak var vwSpeedNormal: UIView!
    @IBOutlet weak var vwSpeedOnePointTwoFive: UIView!
    @IBOutlet weak var vwSpeedOnePointFive: UIView!
    @IBOutlet weak var vwSpeedTwoZero: UIView!
    @IBOutlet weak var vwSpeed: UIView!
    @IBOutlet weak var vwEqalizer: UIView!
    @IBOutlet weak var cnstSpeedvwHeight: NSLayoutConstraint!
    @IBOutlet weak var cnstImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cnstDisplaySongTittleHeight: NSLayoutConstraint!
    @IBOutlet weak var cnstFooderView: NSLayoutConstraint!
    @IBOutlet weak var vwEqalizerBottom: NSLayoutConstraint!
    
    @IBOutlet var freqsSlides: [UISlider]!
    fileprivate var EQNode: AVAudioUnitEQ?
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate var audioFileBuffer: AVAudioPCMBuffer?
    
    var playerNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    var player: AVAudioPlayer!

    var songsArray: [songInfo] = []
    var currentSongIndex: Int = 0
    var audioManager: AudioManager?
    
    // Eqalizer
    let frequencies: [Int] = [32, 63, 125, 250, 500, 1000, 2000, 4000]
    var preSets: [[Float]] = [
        [0, 0, 0, 0, 0, 0, 0, 0], // My setting
        [4, 6, 5, 0, 1, 3, 5, 4.5], // Dance
        [4, 3, 2, 2.5, -1.5, -1.5, 0, 1], // Jazz
        [5, 4, 3.5, 3, 1, 0, 0, 0] // Base Main
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer(currentsongIndex: currentSongIndex)
      
        smallDevice()
        startTimer()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        setupSliderTap()
        view.isUserInteractionEnabled = true
        self.cnstSpeedvwHeight.constant -= 130
        self.vwEqalizerBottom.constant = -500
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    
    
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sliderForTimer), userInfo: nil, repeats: true)
    }
    
    func smallDevice() {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight <= 667 {
            cnstImageViewHeight.constant -= 50
            cnstDisplaySongTittleHeight.constant -= 50
            cnstFooderView.constant -= 20
        }
    }
    
    func setupPlayer(currentsongIndex: Int) {
        let currentSong = songsArray[currentsongIndex]
        DisplaySongTittle.text = currentSong.tittle
        DisplayImgView.image = UIImage(named: currentSong.img ?? "music.note")
        
        if let musicUrl = Bundle.main.url(forResource: currentSong.urlSting, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: musicUrl)
                player.delegate = self
                player.play()
              
                
                
                slider.maximumValue = Float(player.duration)
                endtimelbl.text = formatTime(time: player.duration)
                startringTimelbl.text = formatTime(time: 0)
                PlayPauseImgview.image = player.isPlaying ? UIImage(named: "pause") : UIImage(named: "play")
                
            } catch {
                print("Error initializing audio player: \(error)")
            }
        }
    }
    
    func formatTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func btnEqualizerTapped(_ : UIButton){
        UIView.animate(withDuration: 0.3) {
            self.vwEqalizerBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnPlayPauseAction() {
        if player.isPlaying {
            player.pause()
            PlayPauseImgview.image = UIImage(named: "play")
        } else {
            player.play()
            PlayPauseImgview.image = UIImage(named: "pause")
        }
    }
    
   
    @IBAction func btnBackAction() {
        player.stop()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SliderAction(_ sender: UISlider) {
        player.currentTime = TimeInterval(sender.value)
        if !player.isPlaying {
            player.prepareToPlay()
        }
    }
    
    @objc func sliderForTimer() {
        slider.value = Float(player.currentTime)
        startringTimelbl.text = formatTime(time: player.currentTime)
        
        let remainingTime = player.duration - player.currentTime
        endtimelbl.text = formatTime(time: remainingTime)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            print("tapped")
            self.cnstSpeedvwHeight.constant = -130
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnShuffleAction(_ sender: UIButton) {
        let randomIndex = Int.random(in: 0..<songsArray.count)
        player.stop()
        setupPlayer(currentsongIndex: randomIndex)
    }
    
    @IBAction func btnPreviousSongAction(_ sender: UIButton) {
        currentSongIndex = (currentSongIndex - 1 + songsArray.count) % songsArray.count
        player.stop()
        setupPlayer(currentsongIndex: currentSongIndex)
        PlayPauseImgview.image = UIImage(named: "pause")
    }
    
    @IBAction func btnNextSongAction(_ sender: UIButton) {
        currentSongIndex = (currentSongIndex + 1) % songsArray.count
        player.stop()
        setupPlayer(currentsongIndex: currentSongIndex)
        PlayPauseImgview.image = UIImage(named: "pause")
    }
    
    @IBAction func btnSpeedNormal(_ sender: UIButton) {
        setPlaybackRate(rate: 1.0, speedView: vwSpeedNormal)
    }
    
    @IBAction func btnSpeedOnePointTwoFive(_ sender: UIButton) {
        setPlaybackRate(rate: 1.25, speedView: vwSpeedOnePointTwoFive)
    }
    
    @IBAction func btnSpeedOnePointFive(_ sender: UIButton) {
        setPlaybackRate(rate: 1.5, speedView: vwSpeedOnePointFive)
    }
    
    @IBAction func btnSpeedTwoZero(_ sender: UIButton) {
        setPlaybackRate(rate: 2.0, speedView: vwSpeedTwoZero)
    }
    
    private func setPlaybackRate(rate: Float, speedView: UIView) {
        player.stop()
        player.enableRate = true
        player.rate = rate
        player.play()
        
        [vwSpeedNormal, vwSpeedOnePointTwoFive, vwSpeedOnePointFive, vwSpeedTwoZero].forEach {
            $0?.backgroundColor = UIColor.systemGray
        }
        speedView.backgroundColor = UIColor.systemBlue
        PlayPauseImgview.image = UIImage(named: "pause")
    }
    
    @IBAction func btnSpeedMeterAction() {
        UIView.animate(withDuration: 0.3) {
            self.cnstSpeedvwHeight.constant = 130
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnFastBackword(_ sender: UIButton) {
        player.currentTime = max(0, player.currentTime - 5.0)
    }
    
    @IBAction func btnFastForward(_ sender: UIButton) {
        player.currentTime = min(player.duration, player.currentTime + 5.0)
    }
    
    private func setupSliderTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSliderTap(_:)))
        slider.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleSliderTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: slider)
        let sliderWidth = slider.bounds.width
        let tapPercentage = Float(tapLocation.x / sliderWidth)
        let newTime = TimeInterval(tapPercentage) * player.duration
        
        player.currentTime = newTime
        slider.value = Float(newTime)
    }
}

extension PlayerController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        PlayPauseImgview.image = UIImage(named: "play")
        if flag {
            currentSongIndex = (currentSongIndex + 1) % songsArray.count
            setupPlayer(currentsongIndex: currentSongIndex)
        }
    }
}


// Eqalizer
extension PlayerController{
    
    @IBAction func btnEqualizerAction(_ : UIButton){
        UIView.animate(withDuration: 0.3) {
            self.vwEqalizerBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        if let segmentedControl = sender as? UISegmentedControl {
            print("segmentedControl is selected: ", segmentedControl.selectedSegmentIndex)
        }
        
    }
    
    @IBAction func btnAddAction(_ :UIButton){
        UIView.animate(withDuration: 0.3) {
            self.vwEqalizerBottom.constant = -500
            self.view.layoutIfNeeded()
        }
    }
    
    // UISlider
    @IBAction func sliderValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            print("slider of index:", slider.tag, "is changed to", slider.value)
            
            guard let audioManager = audioManager else {
                return
            }
            
            // Update equalizer values
            var preSet = audioManager.getEquailizerOptions()
            preSet[slider.tag] = slider.value
            audioManager.setEquailizerOptions(gains: preSet)
        }
    }
}


// MARK: - Equalizer code
//import UIKit
//import AVFoundation
//
//class PlayerController: UIViewController, AudioManagerDelegate {
//    func audioManager(didStart manager: AudioManager) {
//        print("music play")
//    }
//    
//    func audioManager(didStop manager: AudioManager) {
//        print("music stop")
//    }
//    
//    func audioManager(didPause manager: AudioManager) {
//        print("music pause")
//    }
//    
//    
//    @IBOutlet weak var DisplayImgView: UIImageView!
//    @IBOutlet weak var slider: UISlider!
//    @IBOutlet weak var DisplaySongTittle: UILabel!
//    @IBOutlet weak var startringTimelbl: UILabel!
//    @IBOutlet weak var endtimelbl: UILabel!
//    @IBOutlet weak var PlayPauseImgview: UIImageView!
//    @IBOutlet weak var vwSpeedNormal: UIView!
//    @IBOutlet weak var vwSpeedOnePointTwoFive: UIView!
//    @IBOutlet weak var vwSpeedOnePointFive: UIView!
//    @IBOutlet weak var vwSpeedTwoZero: UIView!
//    @IBOutlet weak var vwSpeed: UIView!
//    @IBOutlet weak var vwEqalizer: UIView!
//    @IBOutlet weak var cnstSpeedvwHeight: NSLayoutConstraint!
//    @IBOutlet weak var cnstImageViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var cnstDisplaySongTittleHeight: NSLayoutConstraint!
//    @IBOutlet weak var cnstFooderView: NSLayoutConstraint!
//    @IBOutlet weak var vwEqalizerBottom: NSLayoutConstraint!
//    
//    @IBOutlet var freqsSlides: [UISlider]!
//    fileprivate var EQNode: AVAudioUnitEQ?
//    fileprivate let audioEngine = AVAudioEngine()
//    fileprivate var audioFileBuffer: AVAudioPCMBuffer?
//    
//    var playerNode: AVAudioPlayerNode!
//    var audioFile: AVAudioFile!
//    var player: AVAudioPlayer!
//
//    var songsArray: [songInfo] = []
//    var currentSongIndex: Int = 0
//    var audioManager: AudioManager?
//    
//    // Eqalizer
//    let frequencies: [Int] = [32, 63, 125, 250, 500, 1000, 2000, 4000]
//    var preSets: [[Float]] = [
//        [0, 0, 0, 0, 0, 0, 0, 0], // My setting
//        [4, 6, 5, 0, 1, 3, 5, 4.5], // Dance
//        [4, 3, 2, 2.5, -1.5, -1.5, 0, 1], // Jazz
//        [5, 4, 3.5, 3, 1, 0, 0, 0] // Base Main
//    ]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupPlayer(currentsongIndex: currentSongIndex)
//        smallDevice()
//        startTimer()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        view.addGestureRecognizer(tap)
//        
//        setupSliderTap()
//        view.isUserInteractionEnabled = true
//        self.cnstSpeedvwHeight.constant -= 130
//        self.vwEqalizerBottom.constant = -500
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//       
//    }
//    
//    func setupAudioManager(){
//        audioManager = AudioManager(music: "bensound-energy", frequencies: frequencies)
//        
//        if let audioManager = audioManager {
//            //audioManager.delegate = self
//            audioManager.setEquailizerOptions(gains: preSets[0])
//            audioManager.engineStart()
//            audioManager.play()
//        }
//    }
//    
//    func startTimer() {
//        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sliderForTimer), userInfo: nil, repeats: true)
//    }
//    
//    func smallDevice() {
//        let screenHeight = UIScreen.main.bounds.height
//        if screenHeight <= 667 {
//            cnstImageViewHeight.constant -= 50
//            cnstDisplaySongTittleHeight.constant -= 50
//            cnstFooderView.constant -= 20
//        }
//    }
//    
//    func setupPlayer(currentsongIndex: Int) {
//        let currentSong = songsArray[currentsongIndex]
//        DisplaySongTittle.text = currentSong.tittle
//        DisplayImgView.image = UIImage(named: currentSong.img ?? "music.note")
//        
//        if let musicUrl = Bundle.main.url(forResource: currentSong.urlSting, withExtension: "mp3") {
//            do {
//                
//                
//                
//                
//                
//                audioManager = AudioManager(music: currentSong.urlSting, frequencies: frequencies)
//                
//                if let audioManager = audioManager {
//                    audioManager.delegate = self
//                    audioManager.setEquailizerOptions(gains: preSets[0])
//                    audioManager.engineStart()
//                    audioManager.play()
//                }
//                guard  let audio = audioManager else {
//                    return
//                }
//                audio.play()
//    
//                
//            
//                player = try AVAudioPlayer(contentsOf: musicUrl)
//                player.delegate = self
//                player.prepareToPlay()
//               // player.play()
//                slider.maximumValue = Float(player.duration)
//                endtimelbl.text = formatTime(time: player.duration)
//                startringTimelbl.text = formatTime(time: 0)
//                PlayPauseImgview.image = player.isPlaying ? UIImage(named: "pause") : UIImage(named: "play")
//                
//            } catch {
//                print("Error initializing audio player: \(error)")
//            }
//        }
//    }
//    
//    func formatTime(time: TimeInterval) -> String {
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//    
//    @IBAction func btnEqualizerTapped(_ : UIButton){
//        UIView.animate(withDuration: 0.3) {
//            self.vwEqalizerBottom.constant = 0
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func btnPlayPauseAction() {
//        if player.isPlaying {
//            player.pause()
//            PlayPauseImgview.image = UIImage(named: "play")
//        } else {
//            player.play()
//            PlayPauseImgview.image = UIImage(named: "pause")
//        }
//    }
//    
//   
//    @IBAction func btnBackAction() {
//        player.stop()
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func SliderAction(_ sender: UISlider) {
//        player.currentTime = TimeInterval(sender.value)
//        if !player.isPlaying {
//            player.prepareToPlay()
//        }
//    }
//    
//    @objc func sliderForTimer() {
//        slider.value = Float(player.currentTime)
//        startringTimelbl.text = formatTime(time: player.currentTime)
//        
//        let remainingTime = player.duration - player.currentTime
//        endtimelbl.text = formatTime(time: remainingTime)
//    }
//    
//    @objc func handleTap(_ sender: UITapGestureRecognizer) {
//        UIView.animate(withDuration: 0.3) {
//            print("tapped")
//            self.cnstSpeedvwHeight.constant = -130
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func btnShuffleAction(_ sender: UIButton) {
//        let randomIndex = Int.random(in: 0..<songsArray.count)
//        player.stop()
//        setupPlayer(currentsongIndex: randomIndex)
//    }
//    
//    @IBAction func btnPreviousSongAction(_ sender: UIButton) {
//        currentSongIndex = (currentSongIndex - 1 + songsArray.count) % songsArray.count
//        player.stop()
//        setupPlayer(currentsongIndex: currentSongIndex)
//        PlayPauseImgview.image = UIImage(named: "pause")
//    }
//    
//    @IBAction func btnNextSongAction(_ sender: UIButton) {
//        currentSongIndex = (currentSongIndex + 1) % songsArray.count
//        player.stop()
//        setupPlayer(currentsongIndex: currentSongIndex)
//        PlayPauseImgview.image = UIImage(named: "pause")
//    }
//    
//    @IBAction func btnSpeedNormal(_ sender: UIButton) {
//        setPlaybackRate(rate: 1.0, speedView: vwSpeedNormal)
//    }
//    
//    @IBAction func btnSpeedOnePointTwoFive(_ sender: UIButton) {
//        setPlaybackRate(rate: 1.25, speedView: vwSpeedOnePointTwoFive)
//    }
//    
//    @IBAction func btnSpeedOnePointFive(_ sender: UIButton) {
//        setPlaybackRate(rate: 1.5, speedView: vwSpeedOnePointFive)
//    }
//    
//    @IBAction func btnSpeedTwoZero(_ sender: UIButton) {
//        setPlaybackRate(rate: 2.0, speedView: vwSpeedTwoZero)
//    }
//    
//    private func setPlaybackRate(rate: Float, speedView: UIView) {
//        player.stop()
//        player.enableRate = true
//        player.rate = rate
//        player.play()
//        
//        [vwSpeedNormal, vwSpeedOnePointTwoFive, vwSpeedOnePointFive, vwSpeedTwoZero].forEach {
//            $0?.backgroundColor = UIColor.systemGray
//        }
//        speedView.backgroundColor = UIColor.systemBlue
//        PlayPauseImgview.image = UIImage(named: "pause")
//    }
//    
//    @IBAction func btnSpeedMeterAction() {
//        UIView.animate(withDuration: 0.3) {
//            self.cnstSpeedvwHeight.constant = 130
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func btnFastBackword(_ sender: UIButton) {
//        player.currentTime = max(0, player.currentTime - 5.0)
//    }
//    
//    @IBAction func btnFastForward(_ sender: UIButton) {
//        player.currentTime = min(player.duration, player.currentTime + 5.0)
//    }
//    
//    private func setupSliderTap() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSliderTap(_:)))
//        slider.addGestureRecognizer(tapGesture)
//    }
//    
//    @objc private func handleSliderTap(_ gesture: UITapGestureRecognizer) {
//        let tapLocation = gesture.location(in: slider)
//        let sliderWidth = slider.bounds.width
//        let tapPercentage = Float(tapLocation.x / sliderWidth)
//        let newTime = TimeInterval(tapPercentage) * player.duration
//        
//        player.currentTime = newTime
//        slider.value = Float(newTime)
//    }
//}
//
//extension PlayerController: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        PlayPauseImgview.image = UIImage(named: "play")
//        if flag {
//            currentSongIndex = (currentSongIndex + 1) % songsArray.count
//            setupPlayer(currentsongIndex: currentSongIndex)
//        }
//    }
//}
//
//
//// Eqalizer
//extension PlayerController{
//    
//    @IBAction func btnEqualizerAction(_ : UIButton){
//        UIView.animate(withDuration: 0.3) {
//            self.vwEqalizerBottom.constant = 0
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func segmentedControlValueChanged(_ sender: Any) {
//        if let segmentedControl = sender as? UISegmentedControl {
//            print("segmentedControl is selected: ", segmentedControl.selectedSegmentIndex)
//        }
//        
//    }
//    
//    @IBAction func btnAddAction(_ :UIButton){
//        UIView.animate(withDuration: 0.3) {
//            self.vwEqalizerBottom.constant = -500
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    // UISlider
//    @IBAction func sliderValueChanged(_ sender: Any) {
//        if let slider = sender as? UISlider {
//            print("slider of index:", slider.tag, "is changed to", slider.value)
//            
//            guard let audioManager = audioManager else {
//                return
//            }
//            
//            // Update equalizer values
//            var preSet = audioManager.getEquailizerOptions()
//            preSet[slider.tag] = slider.value
//            audioManager.setEquailizerOptions(gains: preSet)
//        }
//    }
//}
//
//
