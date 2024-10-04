//
//  PoseOverlayView.swift
//  poseDetection
//
//  Created by Luis Zendel Samperio on 04/10/24.
//

import UIKit
import MLKit
import MLKitPoseDetectionAccurate
import MLKitPoseDetectionCommon


class PoseOverlayView: UIView {
    
    var pose: Pose?
    
    // Dibujamos los puntos en la imagen
    override func draw(_ rect: CGRect) {
        guard let pose = pose else { return }
        
        // Configuración para el color y tamaño de los puntos
        let pointColor = UIColor.red
        let pointRadius: CGFloat = 5.0
        
        // Obtener el contexto gráfico
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Dibujar cada landmark detectado
        for landmark in pose.landmarks {
            let position = landmark.position
            let convertedPoint = convertLandmarkPositionToView(landmark.position, viewSize: rect.size)
            
            context.setFillColor(pointColor.cgColor)
            let pointRect = CGRect(x: convertedPoint.x - pointRadius, y: convertedPoint.y - pointRadius, width: pointRadius * 2, height: pointRadius * 2)
            context.fillEllipse(in: pointRect)
        }
    }
    
    // Función para convertir las coordenadas del landmark al tamaño de la vista de la cámara
    func convertLandmarkPositionToView(_ position: Vision3DPoint, viewSize: CGSize) -> CGPoint {
        let x = CGFloat(position.x) / 1000 * viewSize.width
        let y = CGFloat(position.y) / 1000 * viewSize.height
        return CGPoint(x: x, y: y)
    }
}
