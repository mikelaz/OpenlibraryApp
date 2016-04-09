//
//  MasterViewController.swift
//  OpenlibraryApp
//
//  Created by Mikel Aguirre on 25/3/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertarNuevoLibro(sender: LiBroOpenLibrary) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(sender.titulo, forKey: "titulo")
        newManagedObject.setValue(sender.isbn, forKey: "isbn")
        newManagedObject.setValue(creaAutoresEntidad(sender.autores), forKey: "tieneAutores")
        if sender.portada != nil{
            //Descargamos la imagen de la portada
            let imagen:NSData? = NSData(contentsOfURL: sender.portada!)
            newManagedObject.setValue(imagen, forKey: "portada")
        }else{
            let noCover = UIImage(named: "sinPortada")
            newManagedObject.setValue(UIImagePNGRepresentation(noCover!), forKey: "portada")
        }
        
        // Save the context.
        do {
            try context.save()
        } catch {
            print("Error al almacenar el nuevo libro")
            abort()
        }
    }
    
    //Creamos una función que devuelva un Set de NSObjects con los autores del libro para utilizarlo en la relación "tieneAutores"
    func creaAutoresEntidad(autores: [String])-> Set<NSObject>{
        var entidades = Set<NSObject>()
        for autor in autores{
            let autorEntidad = NSEntityDescription.insertNewObjectForEntityForName("Autores", inManagedObjectContext: self.managedObjectContext!)
            autorEntidad.setValue(autor, forKey: "nombreAutor")
            entidades.insert(autorEntidad)
        }
        return entidades
    }
    
    //Creamos una función que utilice la Fetch Request "existeLibro" [select de todos los libros con isbn = $isbnConsulta] para comprobar si ya existe el libro
    func compruebaExisteLibro(isbnAComprobar: String)-> Int{
        //Devuelve 1 si existe, 0 si no existe y -1 en caso de error
        let resultado: Int
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let librosEntidad = NSEntityDescription.entityForName(entity.name!, inManagedObjectContext: context)
        print(entity.name!)
        let consulta = librosEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("existeLibro", substitutionVariables: ["isbnConsulta":isbnAComprobar])
        do{
            let resultadoConsulta = try self.managedObjectContext?.executeFetchRequest(consulta!)
            if resultadoConsulta?.count > 0{
                resultado = 1
            }else{
                resultado = 0
            }
        }catch{
            resultado = -1
        }
        return resultado
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let libro = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                //Enviamos el objeto seleccionado en la lista a la vista ViewDetail
                controller.detailItem = libro
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        self.configureCell(cell, withObject: object)
        //cell.textLabel?.text = self.libros[indexPath.row].titulo
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    @IBAction func cancelToBooksViewController(segue:UIStoryboardSegue) {
        print ("Se ha cancelado la búsqueda")
    }
    
    @IBAction func saveBookDetail(segue:UIStoryboardSegue) {
        if let busquedaISBNViewController = segue.sourceViewController as? BusquedaISBNViewController {
            //Comprobamos si existe el libro en la lista y de no ser así, lo almacenamos
            let libro = busquedaISBNViewController.libro
            if libro.titulo != "" {
                let consulta = compruebaExisteLibro(libro.isbn)
                if  consulta == 0{
                    insertarNuevoLibro(libro)
                }else if consulta == 1{
                    print("Repetido: El libro ya está en la lista")
                }else{
                    print("Error en la comprobación de existencia")
                }
            }else{
                print ("No se ha añadido ningún libro a la lista")
            }
        }
    
    }
    /*
    //Función para la versión sin CoreData
    @IBAction func saveBookDetail(segue:UIStoryboardSegue) {
        if let busquedaISBNViewController = segue.sourceViewController as? BusquedaISBNViewController {
            //añadir un nuevo libro al array
            let libro = busquedaISBNViewController.libro
            if libro.titulo != "" {
                 //Comprobamos si ya está en la lista
                 var existe = false
                 for i in 0..<libros.count{
                    if libros[i].titulo == libro.titulo{
                        existe = true
                    }
                 }
                 if existe{
                    print ("Ya existe el libro en la lista")
                 }else{
                    libros.append(libro)
                    //actualizar la vista de la tabla
                    let indexPath = NSIndexPath(forRow: libros.count-1, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                 }
            }else{
                print ("No se ha añadido ningún libro a la lista")
            }
        }
        
    }
 */


     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                print("Error al eliminar el elemento de la lista")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        cell.textLabel!.text = object.valueForKey("titulo")!.description
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "titulo", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             print("Error al realizar la búsqueda (select *)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    //Función para controlar secciones
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
            case .Move:
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
/*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }

 */

}

