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

typealias Input = (
    rewardBtnTap: Signal<Void>,
    playBtnTap: Signal<Void>,
    forwardBtnTap: Signal<Void>,
    musicListBtn: Signal<Void>,
    timeSlider: Signal<Void>
)

final class ViewModel {
    
    private let bag = DisposeBag()
    let start = PublishRelay<Bool>()
    let stop = PublishRelay<Bool>()
    let isPlayIng: Driver<Bool>
    
    let rxTimer = Observable<Int>
    .interval(1.0, scheduler: MainScheduler.instance)
    .shareReplay(1)

    init(input: Input) {
        isPlayIng = start.asDriver(onErrorDriveWith: .empty())
        
//        input.playBtnTap.emit(onNext: { [weak self] in
//
//        }).disposed(by: bag)
//
//        input.musicListBtn.emit(onNext: { [weak self] in
//
//        }).disposed(by: bag)
    }
    
    func startMusic() {}
    
    func stopMusic() {}
    
    

}
