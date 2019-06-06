//
//  AIModel.swift
//  Babemo_iOS
//
//  Created by Jay on 07/12/2018.
//  Copyright © 2018 YamamotoKazunori. All rights reserved.
//

import Foundation
import CoreML
import Vision
import ImageIO
import UIKit

struct ClassifyCallback {
    var isBaby: Bool
    var data: Data
}

final class AiModel {
    
    func updateClassifications(for image: UIImage, data: Data, _ completion: @escaping(Result<ClassifyCallback, AiError>) -> Void) {
        print("Classifying .... \(image)")
        
        autoreleasepool(invoking: {
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self)f from \(image).") }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                let model = try VNCoreMLModel(for: KZBabyClassifier().model)
                let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, error, image, data, completion)
                })
            
            request.imageCropAndScaleOption = .centerCrop
            try handler.perform([request])
            } catch {
            /*                    completion(.failure(AiError.classificationError("catch Error")))
             This handler catches general image processing errors. The `classificationRequest`'s
             completion handler `processClassifications(_:error:)` catches errors specific
             to processing that request.
             */
            let errorDescription = "Failed to perform classification.\n\(error.localizedDescription)"
            print(errorDescription)
            completion(.failure(AiError.classificationError(errorDescription)))
            }
        })
    }
    
    private func processClassifications(for request: VNRequest, _ error: Error?, _ image: UIImage, _ data: Data, _ completion: @escaping(Result<ClassifyCallback, AiError>) -> Void) {
        guard let results = request.results else {
            print("Unable to classify image.\n\(error!.localizedDescription)")
            return
        }
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        let classifications = results as! [VNClassificationObservation]
        
        if classifications.isEmpty {
            let errorDescription = "Nothing recognized."
            print("Nothing recognized")
            completion(.failure(AiError.classificationError(errorDescription)))
        } else {
            // Display top classifications ranked by confidence in the UI.
            let topClassifications = classifications.prefix(2)
            let descriptions = topClassifications.map { classification in
                // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                return [classification.identifier: String(format: "%.2f", classification.confidence)] as NSDictionary
            }
            
        let firstValue = (descriptions[0].allValues[0] as! NSString)
        let secondValue = (descriptions[1].allValues[0] as! NSString)
        
        let result = firstValue.floatValue > secondValue.floatValue ? descriptions[0].allKeys[0] : descriptions[1].allKeys[0]
        let isBaby = ((result as! NSString) == "baby" ? true : false)
        
        completion(.success(ClassifyCallback(isBaby: isBaby, data: data)))
    }
    }
    
}
