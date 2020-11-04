//
//  ViewModel.swift
//  MusicPlay
//
//  Created by CHEN SINYU on 2020/10/23.
//  Copyright © 2020 CHEN SINYU. All rights reserved.
//

import UIKit
import RxSwift

final class ViewModel {
    
    private let bag = DisposeBag()

   let startTimer = PublishSubject<Void>()
   let stopTimer = PublishSubject<Void>()

   let rxTimer = Observable<Int>
    .interval(1.0, scheduler: MainScheduler.instance)
    .shareReplay(1)

    init() {
    
    }


}
