//
//  BoxOfficeCoreDataManager.swift
//  BoxOffice
//
//  Created by 리지, kokkilE on 2023/04/10.
//

import Foundation
import CoreData
import UIKit

class BoxOfficeCoreDataManager {
    static let shared = BoxOfficeCoreDataManager()
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.newBackgroundContext()
    
    private init() {}
    
    func create(date: String, and movies: [DailyBoxOffice.BoxOfficeResult.Movie]) {
        guard let context = self.context,
              let dailyBoxOfficeEntity = NSEntityDescription.entity(forEntityName: "DailyBoxOfficeData", in: context),
              let dailyBoxOfficeData = NSManagedObject(entity: dailyBoxOfficeEntity, insertInto: context) as? DailyBoxOfficeData else { return }
        
        setValue(at: dailyBoxOfficeData, date: date, and: movies)
        save()
    }
    
    func read(date: String) -> DailyBoxOfficeData? {
        fetchData(date: date)
    }
    
    func update(date: String, and movies: [DailyBoxOffice.BoxOfficeResult.Movie]) {
        guard let dailyBoxOfficeData = fetchData(date: date) else { return }
        
        setValue(at: dailyBoxOfficeData, date: date, and: movies)
        save()
    }
    
    func delete<T: NSManagedObject>(targetType: T.Type) {
        guard let context = self.context else { return }
        
        let request: NSFetchRequest<NSFetchRequestResult> = targetType.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setValue(at target: DailyBoxOfficeData, date: String, and movies: [DailyBoxOffice.BoxOfficeResult.Movie]) {
        var movieList = [Movie]()
        movies.forEach {
            let movie = Movie()
            
            movie.audienceAccumulation = $0.audienceAccumulation
            movie.screenCount = $0.screenCount
            movie.showCount = $0.showCount
            movie.rank = $0.rank
            movie.rankVariance = $0.rankVariance
            movie.rankOldAndNew = $0.rankOldAndNew
            movie.code = $0.code
            movie.name = $0.name
            movie.openDate = $0.openDate
            movie.salesAmount = $0.salesAmount
            movie.salesShare = $0.salesShare
            movie.salesVariance = $0.salesVariance
            movie.salesChange = $0.salesChange
            movie.salesAccumulation = $0.salesAccumulation
            movie.audienceCount = $0.audienceCount
            movie.audienceVariance = $0.audienceVariance
            movie.audienceChange = $0.audienceChange
            movie.order = $0.order
            
            movieList.append(movie)
        }
        
        let movieData = Movies(movieList: movieList)
        
        target.setValue(date, forKey: "selectedDate")
        target.setValue(movieData, forKey: "movies")
    }
    
    private func save() {
        guard let context = self.context else { return }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func filteredDataRequest(date: String) -> NSFetchRequest<DailyBoxOfficeData> {
        let fetchRequest = NSFetchRequest<DailyBoxOfficeData>(entityName: "DailyBoxOfficeData")
        fetchRequest.predicate = NSPredicate(format: "selectedDate == %@", date)
        return fetchRequest
    }
    
    private func fetchData(date: String) -> DailyBoxOfficeData? {
        guard let context = self.context else { return nil }
        
        let filter = filteredDataRequest(date: date)
        
        do {
            let data = try context.fetch(filter)
            return data.first
        } catch {
            return nil
        }
    }
}
