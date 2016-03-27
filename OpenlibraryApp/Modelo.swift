//
//  Modelo.swift
//  ISBN-Info
//
//  Created by Mikel Aguirre on 18/3/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import Foundation

class LiBroOpenLibrary {
    
    var titulo = String()
    var autores = [String()]
    var portada = NSURL?()
    
    //Función creada para la primera versión
    func llamadaSincronaOpenLibrary (isbn: String)->String{
        
        var urlString = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        urlString = "\(urlString)\(isbn)"
        let url = NSURL (string: urlString)
        let datos:NSData? = NSData(contentsOfURL: url!)
        if datos != nil{
            let resultado = NSString(data:datos!, encoding: NSUTF8StringEncoding)
            if resultado == "{}"{
                return ("ISBN no encontrado")
            }else{
                return resultado! as String
            }
        }else{
            return ("Error en la conexión con openlibrary.org")
        }
        
    }
    
    func obtenerDatosDeISBN (isbn: String)->Int{
        /*Codigos:
        -1: Error en la conexión con openlibrary.org
        -2: ISBN no encontrado
        0: Libro con portada
        1: Libro sin portada
        */
        //ejemplo llamada con portada: https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:0486282147
        var codigoSalida = Int()
        let urlString = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
        let url = NSURL (string: urlString)
        //Descargamos la respuesta JSON
        let datos:NSData? = NSData(contentsOfURL: url!)
        //Si la descarga es nula, entendemos que ha habido un error en la comunicación con el servidor
        if datos != nil{
            let resultado = NSString(data:datos!, encoding: NSUTF8StringEncoding)
            //Si el resultado es un objeto JSON vacío, el ISBN con es correcto o no se encuentra en la BBDD
            if resultado == "{}"{
                return (-2)
            }else{
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    let dico1 = json as! NSDictionary
                    let dico2 = dico1["ISBN:\(isbn)"] as! NSDictionary
                    self.titulo = dico2["title"] as! String
                    //El apartado authors está construido como un array de diccionarios
                    let dico3 = dico2["authors"] as? [NSDictionary]
                    //Tras comprobar que hay libros sin el campo author registrado, comprobamos que no sea nulo
                    if dico3 != nil {
                        //Almacenamos los autores en un array de Strings
                        self.autores.reserveCapacity(dico3!.count)
                        for i in 0..<(dico3!.count){
                            self.autores[i] = (dico3![i]["name"] as! String)
                        }
                    }else{
                        self.autores[0]="Inf. No disponible"
                    }
                    //Comprobamos si tiene portada registrada y si la tiene, almacenamos su URL
                    let dico4 = dico2["cover"] as? NSDictionary
                    if dico4 != nil{
                        self.portada = NSURL(string: dico4!["medium"] as! String)
                        codigoSalida = 0
                    }else{
                        codigoSalida = 1
                    }
                }catch _ {
                
                }
                return (codigoSalida)
            }
        }else{
            return (-1)
        }
    }
    
}
