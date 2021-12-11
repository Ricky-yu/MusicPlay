//
//  ViewModel.swift
//  MusicPlay
//
//  Created by CHEN SINYU on 2020/10/23.
//  Copyright © 2020 CHEN SINYU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MediaPlayer

final class ViewModel {
    
    let bag = DisposeBag()
    let state = PublishRelay<Bool>()
    let currentSongTime = PublishRelay<String>()
    let totalSongTime = PublishRelay<String>()
    let songItemState = PublishRelay<MPMediaItem>()
    let playbackTime =  PublishRelay<TimeInterval>()
    
    func setCurrentSongTime(_ currentPlaybackTime: TimeInterval) {
        currentSongTime.accept(self.changeTimeIntervalToTimeString(currentPlaybackTime))
    }
    
    func setTotalSongTime(_ currentPlaybackTime: TimeInterval) {
        totalSongTime.accept(self.changeTimeIntervalToTimeString(currentPlaybackTime))
    }
    
    private func changeTimeIntervalToTimeString(_ currentPlaybackTime: TimeInterval) -> String {
        if(currentPlaybackTime.truncatingRemainder(dividingBy: 60.0) < 10) {
            return  "\(Int(currentPlaybackTime/60)):0\(Int(currentPlaybackTime .truncatingRemainder(dividingBy: 60.0)))"
        } else {
            return "\(Int(currentPlaybackTime/60)):\(Int(currentPlaybackTime .truncatingRemainder(dividingBy: 60.0)))"
        }
    }
}
