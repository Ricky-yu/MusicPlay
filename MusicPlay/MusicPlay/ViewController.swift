//
//  ViewController.swift
//  MusicPlay
//
//  Created by CHEN SINYU on 2020/10/22.
//  Copyright © 2020 CHEN SINYU. All rights reserved.
//

import UIKit
import MediaPlayer
import MarqueeLabel
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var songName: MarqueeLabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var currentSongTime: UILabel!
    @IBOutlet weak var totalSongTime: UILabel!
    @IBOutlet weak var rewardBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var musicListBtn: UIButton!
    let disposeBag = DisposeBag();
    let player = MPMusicPlayerController.applicationMusicPlayer
    private var viewModel: ViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModelInput = Input(
            rewardBtnTap: rewardBtn.rx.tap.asSignal(),
            playBtnTap: rewardBtn.rx.tap.asSignal(),
            forwardBtnTap: rewardBtn.rx.tap.asSignal(),
            musicListBtn: rewardBtn.rx.tap.asSignal(),
            timeSlider: rewardBtn.rx.tap.asSignal()
        )
        self.viewModel = ViewModel(input: viewModelInput)
        
        viewModel.state.subscribe(onNext: {[weak self] isPlaying in
            if isPlaying {
                self?.player.stop()
                self?.playBtn.rx.backgroundImage().onNext(UIImage(named: "playIcon"))
            } else {
                self?.player.play()
                self?.playBtn.rx.backgroundImage().onNext(UIImage(named: "pauseIcon"))
            }
        }).disposed(by: disposeBag)
        
        player.repeatMode = .all
        self.musicListBtn.rx.tap.bind{ [weak self] in
            self?.checkPermitUseMusic()
        }.disposed(by: disposeBag)
        
        self.playBtn.rx.tap.bind{ [weak self] in
            self?.viewModel?.state.accept(self?.player.playbackState == .playing)
        }.disposed(by: disposeBag)
        
        self.timeSlider.rx.value.asObservable()
        .subscribe(onNext: {
            self.player.currentPlaybackTime = TimeInterval($0)
            self.currentSongTime.text = self.viewModel.getCurrentSongTime(self.player.currentPlaybackTime)
        })
        .disposed(by: disposeBag)
        
        self.forwardBtn.rx.tap.bind{[weak self] in
            self?.player.currentPlaybackTime += 15
            self?.timeSlider.setValue(Float(self!.player.currentPlaybackTime), animated: true)
        }.disposed(by: disposeBag)
        
        self.rewardBtn.rx.tap.bind{[weak self] in
            self?.player.currentPlaybackTime -= 15
            self?.timeSlider.setValue(Float(self!.player.currentPlaybackTime), animated: true)
        }.disposed(by: disposeBag)
    }
    
    func setupSongNameAnimation() {
        self.songName.tag = 101
        self.songName.type = .continuous
        self.songName.animationCurve = .easeInOut
        self.songName.speed = .duration(8.0)
    }
}

extension ViewController: MPMediaPickerControllerDelegate {

    func checkPermitUseMusic(){
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            let picker = MPMediaPickerController(mediaTypes: MPMediaType.music)
            picker.delegate = self
            picker.allowsPickingMultipleItems = false
            picker.showsItemsWithProtectedAssets = false
            picker.showsCloudItems = false
            self.present(picker, animated: true, completion: nil)
        case .notDetermined:
            MPMediaLibrary.requestAuthorization() { status in
                if status == .authorized {
                    self.displayMPMediaPickerController()
                }
            }
        default: self.displayPermissionAlertFromViewController()
        }
    }
    
    func displayMPMediaPickerController(){
        let picker = MPMediaPickerController(mediaTypes: MPMediaType.music)
        picker.delegate = self
        picker.allowsPickingMultipleItems = true
        picker.showsItemsWithProtectedAssets = false
        picker.showsCloudItems = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func displayPermissionAlertFromViewController() {
        let alert = UIAlertController(title: "メディアライブラリのアクセス許可を設定しますか？", message: "音楽選択するため", preferredStyle:  UIAlertController.Style.alert)
        
        alert.popoverPresentationController?.sourceView = self.view
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "設定します", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(okAction)
        
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        present(alert, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        player.stop()
        player.setQueue(with: mediaItemCollection)
        if let mediaItem = mediaItemCollection.items.first {
            updateSongInformationUI(mediaItem : mediaItem)
            player.play()
            playBtn.setBackgroundImage(UIImage(named: "pauseIcon"), for: .normal)
            viewModel.rxTimer
             .subscribe { (count) -> Void in
                self.timeSlider.rx.base.value = Float(self.player.currentPlaybackTime)
                self.currentSongTime.text = self.viewModel.getCurrentSongTime(self.player.currentPlaybackTime)
            }
            .disposed(by: disposeBag)
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateSongInformationUI(mediaItem: MPMediaItem) {
        self.playBtn.isEnabled = true
        self.forwardBtn.isEnabled = true
        self.rewardBtn.isEnabled = true
        songName.text = mediaItem.title ?? "不明な曲"
        albumName.text = mediaItem.albumTitle ?? "不明なアルバム"
        if let artwork = mediaItem.artwork {
            let image = artwork.image(at: songImageView.bounds.size)
            songImageView.image = image
        }
        self.timeSlider.maximumValue = Float(mediaItem.playbackDuration )
        self.timeSlider.setValue(Float(self.player.currentPlaybackTime), animated: true)
        let MusicMaxValue = round(self.timeSlider.maximumValue)-1
        totalSongTime.text = self.viewModel.getCurrentSongTime(TimeInterval(MusicMaxValue))
    }
    
}

