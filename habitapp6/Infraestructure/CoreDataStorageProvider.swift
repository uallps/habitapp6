
import Foundation
import CoreData

@objc(HabitEntity)
class HabitEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var nombre: String
    @NSManaged var frecuencia: String
    @NSManaged var fechaCreacion: Date
    @NSManaged var activo: Bool
}

@objc(HabitInstanceEntity)
class HabitInstanceEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var habitID: UUID
    @NSManaged var fecha: Date
    @NSManaged var completado: Bool
}

class CoreDataStorageProvider: StorageProvider {
    static var shared: StorageProvider = CoreDataStorageProvider()
    
    private let container: NSPersistentContainer
    
    init() {
        let model = NSManagedObjectModel()
        
        let habitEntity = NSEntityDescription()
        habitEntity.name = "HabitEntity"
        habitEntity.managedObjectClassName = NSStringFromClass(HabitEntity.self)
        
        let habitIdAttr = NSAttributeDescription()
        habitIdAttr.name = "id"
        habitIdAttr.attributeType = .UUIDAttributeType
        
        let habitNombreAttr = NSAttributeDescription()
        habitNombreAttr.name = "nombre"
        habitNombreAttr.attributeType = .stringAttributeType
        
        let habitFrecuenciaAttr = NSAttributeDescription()
        habitFrecuenciaAttr.name = "frecuencia"
        habitFrecuenciaAttr.attributeType = .stringAttributeType
        
        let habitFechaAttr = NSAttributeDescription()
        habitFechaAttr.name = "fechaCreacion"
        habitFechaAttr.attributeType = .dateAttributeType
        
        let habitActivoAttr = NSAttributeDescription()
        habitActivoAttr.name = "activo"
        habitActivoAttr.attributeType = .booleanAttributeType
        
        habitEntity.properties = [habitIdAttr, habitNombreAttr, habitFrecuenciaAttr, habitFechaAttr, habitActivoAttr]
        
        let instanceEntity = NSEntityDescription()
        instanceEntity.name = "HabitInstanceEntity"
        instanceEntity.managedObjectClassName = NSStringFromClass(HabitInstanceEntity.self)
        
        let instanceIdAttr = NSAttributeDescription()
        instanceIdAttr.name = "id"
        instanceIdAttr.attributeType = .UUIDAttributeType
        
        let instanceHabitIDAttr = NSAttributeDescription()
        instanceHabitIDAttr.name = "habitID"
        instanceHabitIDAttr.attributeType = .UUIDAttributeType
        
        let instanceFechaAttr = NSAttributeDescription()
        instanceFechaAttr.name = "fecha"
        instanceFechaAttr.attributeType = .dateAttributeType
        
        let instanceCompletadoAttr = NSAttributeDescription()
        instanceCompletadoAttr.name = "completado"
        instanceCompletadoAttr.attributeType = .booleanAttributeType
        
        instanceEntity.properties = [instanceIdAttr, instanceHabitIDAttr, instanceFechaAttr, instanceCompletadoAttr]
        
        model.entities = [habitEntity, instanceEntity]
        
        container = NSPersistentContainer(name: "HabitTracker", managedObjectModel: model)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData error: \(error)")
            }
        }
    }
    
    func loadHabits() async throws -> [Habit] {
        let context = container.viewContext
        return await context.perform {
            let request = NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
            do {
                let entities = try context.fetch(request)
                return entities.map { entity in
                    Habit(
                        nombre: entity.nombre,
                        frecuencia: Frecuencia(rawValue: entity.frecuencia) ?? .diario,
                        fechaCreacion: entity.fechaCreacion,
                        activo: entity.activo
                    )
                }
            } catch {
                return []
            }
        }
    }
    
    func saveHabits(_ habits: [Habit]) async throws {
        let context = container.viewContext
        try await context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HabitEntity")
            let existing = try context.fetch(fetchRequest)
            for obj in existing {
                context.delete(obj)
            }
            
            for habit in habits {
                let entity = HabitEntity(context: context)
                entity.id = habit.id
                entity.nombre = habit.nombre
                entity.frecuencia = habit.frecuencia.rawValue
                entity.fechaCreacion = habit.fechaCreacion
                entity.activo = habit.activo
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    func loadInstances() async throws -> [HabitInstance] {
        let context = container.viewContext
        return await context.perform {
            let request = NSFetchRequest<HabitInstanceEntity>(entityName: "HabitInstanceEntity")
            do {
                let entities = try context.fetch(request)
                return entities.map { entity in
                    HabitInstance(habitID: entity.habitID, fecha: entity.fecha, completado: entity.completado)
                }
            } catch {
                return []
            }
        }
    }
    
    func saveInstances(_ instances: [HabitInstance]) async throws {
        let context = container.viewContext
        try await context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HabitInstanceEntity")
            let existing = try context.fetch(fetchRequest)
            for obj in existing {
                context.delete(obj)
            }
            
            for instance in instances {
                let entity = HabitInstanceEntity(context: context)
                entity.id = instance.id
                entity.habitID = instance.habitID
                entity.fecha = instance.fecha
                entity.completado = instance.completado
            }
            
            if context.hasChanges {
                try context.save()
            }
        }

        
    }
    
    func persistChanges() throws{
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
