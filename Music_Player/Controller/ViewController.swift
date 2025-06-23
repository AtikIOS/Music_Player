//
//  ViewController.swift
//  Music_Player
//
//  Created by Atik Hasan on 10/14/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var musicTableView: UITableView!{
        didSet{
            self.musicTableView.delegate = self
            self.musicTableView.dataSource = self
            musicTableView.register(UINib(nibName: "MusicListCell", bundle: nil), forCellReuseIdentifier: "MusicListCell")
        }
    }
    
    var array: [songInfo] = [
        songInfo(img: "jeena_sikhade_img", tittle: "SRIKANTH: JEENA SIKHA DE (Song) RAJKUMMAR RAO, ALAYA | ARIJIT SINGH, VED SHARMA, KUNAAL | BHUSHAN K", urlSting: "Jeena_Sikha_De"),
        songInfo(img: "kk", tittle: "Dil Ibadat Kar Raha Hai Full Song (Lyrics) || K.K || Tum Mile || Pritam, Sayeed Quadri || Emraan H", urlSting: "Dil_Ibaadat"),
        songInfo(img: "Let_Her_X_husn", tittle: "y2mate.com - Let Her Go X Husn Mashup ll Anuv Jain ll Ed Sheeran ll By Melody Waves.mp3", urlSting: "Let_Her_Go_X_Husn_Mashup"),
        songInfo(img: "despacito", tittle: "y2mate.com - Luis Fonsi  Despacito ft Daddy Yankee.mp3", urlSting: "Luis_Fonsi_Despacito")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.musicTableView.reloadData()
        self.musicTableView.isUserInteractionEnabled = true
    }
}

extension ViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicListCell", for: indexPath) as! MusicListCell
        cell.selectionStyle = .none
        cell.imgView.image = UIImage(named: array[indexPath.row].img ?? "music.note")
        cell.lblMusicTittle.text = array[indexPath.row].tittle
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerController") as? PlayerController {
                vc.songsArray = array
                vc.currentSongIndex = indexPath.row
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                print("PlayerController not found")
            }
    }
}

