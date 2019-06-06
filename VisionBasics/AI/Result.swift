//
//  AiResult.swift
//  Babemo_iOS
//
//  Created by Jay on 07/12/2018.
//  Copyright © 2018 YamamotoKazunori. All rights reserved.
//

public enum Result<T, Error : Swift.Error> {
    case success(T)
    case failure(Error)
    
    init(value: T){
        self = .success(value)
    }
    
    init(error: Error){
        self = .failure(error)
    }
}
