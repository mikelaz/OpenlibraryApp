//
//  DetailViewController.swift
//  OpenlibraryApp
//
//  Created by Mikel Aguirre on 25/3/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var tituloLibro: UITextView!
    @IBOutlet weak var autoresLibro: UITextView!
    @IBOutlet weak var portadaLibro: UIImageView!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Configurar la Vista Detalle para mostrar la información del objeto recibido
        if let detail = self.detailItem{
            if let titulo = self.tituloLibro {
                titulo.text = detail.valueForKey("titulo") as! String
            }
            
            if let autores = self.autoresLibro {
                //Tomamos el Set de objetos "Autores" a través de la relación "tieneAutores"
                let autoresEntidad = detail.valueForKey("tieneAutores") as! Set<NSObject>
                for autoresEntidad2 in autoresEntidad{
                    //Recorremos el Set y tomamos el valor de la clave "nombreAutor"
                    let autor = autoresEntidad2.valueForKey("nombreAutor") as! String
                    autores.text = autor + "\r\n" + autores.text!
                }
            }
            
            if let portada = self.portadaLibro{
                portada.image = UIImage(data: detail.valueForKey("portada") as! NSData)
                portada.sizeToFit()
            }

        }
    }
    
    /*Función para la versión sin CoreData
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem as? LiBroOpenLibrary{
            if let titulo = self.tituloLibro {
                titulo.text = detail.titulo
            }
            if let autores = self.autoresLibro {
                //Recorremos el array de autores y lo imprimimos con un salto de línea por cada autor
                for i in 0..<detail.autores.count{
                    autores.text = detail.autores[i] + "\r\n" + autores.text!
                }
            }
            if let portada = self.portadaLibro {
                if detail.portada != nil{
                    //Descargamos la imagen de la portada
                    let imagen:NSData? = NSData(contentsOfURL: detail.portada!)
                    //convertimos el objeto NSData descargado en objeto UIImage y se lo entregamos al contenedor Image View
                    portada.image = UIImage(data: imagen!)
                    portada.sizeToFit()
                }else{
                    portada.image = UIImage(named: "sinPortada")
                    portada.sizeToFit()
                }
            }
        }
     }
     */

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

