//
//  PhasorProject+Transferable.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/19/25.
//

import CoreTransferable
import UniformTypeIdentifiers

extension PhasorProject : Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .phasorProject)
    }
}

extension UTType {
    static var phasorProject: UTType {
        UTType(exportedAs: "com.gyoge.phasor.phasorproject")
    }
}
