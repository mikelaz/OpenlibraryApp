//
//  BusquedaISBNViewController.swift
//  OpenlibraryApp
//
//  Created by Mikel Aguirre on 25/3/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class BusquedaISBNViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var entradaTexto: UITextField!
    @IBOutlet weak var tituloLibro: UITextView!
    @IBOutlet weak var autoresLibro: UITextView!
    @IBOutlet weak var portadaLibro: UIImageView!
    
    var libro = LiBroOpenLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //configurarTextField()
        entradaTexto.delegate=self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configurarTextField (){
        entradaTexto.placeholder = NSLocalizedString("Introduzca ISBN a buscar", comment: "")
        entradaTexto.returnKeyType = .Search
        entradaTexto.clearButtonMode = .Always
        entradaTexto.keyboardType = .NumbersAndPunctuation
        entradaTexto.spellCheckingType = .No
        entradaTexto.autocorrectionType = .No
    }
    
    func lanzarAlerta(titulo: String, mensaje: String){
        // Initialize Alert Controller
        let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .Alert)
        
        // Initialize Actions
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .Default) { (action) -> Void in
            print("Aceptado")
        }
        
        // Add Actions
        alertController.addAction(accionAceptar)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        
        //Lanzado al hacer click en buscar (finalizar edición)
        if (entradaTexto.text!.isEmpty){
            lanzarAlerta("Aviso", mensaje: "Introduzca un ISBN")
        }else{
            let resultado = libro.obtenerDatosDeISBN(entradaTexto.text!)
            if resultado == -1 {
                lanzarAlerta("Aviso", mensaje: "Error en la conexión con openlibrary.org")
            }else if resultado == -2 {
                lanzarAlerta("Aviso", mensaje: "ISBN no encontrado")
            }else if resultado == 0 {
                self.tituloLibro.text=libro.titulo
                //Borramos el contenido del cuadro de texto
                self.autoresLibro.text=""
                //Recorremos el array de autores y lo imprimimos con un salto de línea por cada autor
                for i in 0..<libro.autores.count{
                    self.autoresLibro.text = libro.autores[i] + "\r\n" + self.autoresLibro.text!
                }
                //Descargamos la imagen de la portada
                let imagen:NSData? = NSData(contentsOfURL: libro.portada!)
                //convertimos el objeto NSData descargado en objeto UIImage y se lo entregamos al contenedor Image View
                self.portadaLibro.image = UIImage(data: imagen!)
                self.portadaLibro.sizeToFit()
                //Hacemos visible el contenedor si es que estaba oculto
                self.portadaLibro.hidden = false
            }else if resultado == 1{
                self.tituloLibro.text=libro.titulo
                self.autoresLibro.text=""
                for i in 0..<libro.autores.count{
                    self.autoresLibro.text = libro.autores[i] + "\r\n" + self.autoresLibro.text!
                }
                //ocultamos el contenedor Image View en este caso ya que no existe portada
                self.portadaLibro.hidden = true
            }
        }
        //ocultar teclado tras pulsar Search
        sender.resignFirstResponder()
    }

/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using
        //segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 */
}
