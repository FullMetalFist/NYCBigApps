//
//  ChartsViewController.swift
//  Recyche
//
//  Created by Zel Marko on 20/09/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import UIKit
import CoreData
import Charts


class ChartsViewController: UIViewController {
    
    var products: [Product]!

    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLocalDatabase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
//        let unitsSold: [Double] = [20, 4, 6, 3, 12, 16]
//        
//        setChart(months, values: unitsSold)
    }
    
    @IBAction func segmentControlChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setChartData(.WeekOfYear)
        case 1:
            setChartData(.Month)
        case 2:
            setChartData(.Year)
        default:
            break
        }
    }
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Products Recycled")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = nil
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for code in dataPoints {
            colors.append(colorForCode(code))
        }
        
        pieChartDataSet.colors = colors

    }
    
    func setChartData(unit: NSCalendarUnit) {
        
        var chartData: [(code: String, amount: Int)] = []
        
        let calendar = NSCalendar.currentCalendar()
        let today = calendar.component(unit, fromDate: NSDate())
        
        for product in products { // Iterate over products in local database
            if calendar.component(unit, fromDate: product.dateadded!) == today { // Check for items matching this week/month/year
                print("fits week/month/year")
                var chartItem = (code: materialForCode(product.material!), amount: 1) // New chartItem because the item is in this week/month/year
                if chartData.contains( { $0.code == chartItem.code } ) { // Check if there are alredy existing products with same material
                    print("There's existing product with same code")
                    if let index = chartData.indexOf( { $0.code == chartItem.code } ) { // Check for index of the identical item
                        print("Found index, delete old item and put in a new one with incremented amount")
                        chartItem.amount += chartData[index].amount // Update value of the new item
                        chartData.removeAtIndex(index) // Remove the old item
                        chartData.append(chartItem) // Append new item with updated value
                    }
                }
                else {
                    // Append if there's no existing product in the personal database
                    chartData.append(chartItem)
                }
            }
            else {
                print("No items for this week/month/year")
            }
            
            print(chartData)
            var dataPoints: [String] = []
            var values: [Double] = []
            
            for e in chartData {
                dataPoints.append(e.code)
                values.append(Double(e.amount))
            }
            setChart(dataPoints, values: values)
        }
    }
    
    func fetchLocalDatabase() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Product")
        
        do {
            products = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Product]
            setChartData(.WeekOfYear)
        }
        catch {
            print("Error at fetch?")
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "statsToProductListSegue" {
            let productListViewController = segue.destinationViewController as! ListOfProductsViewController
            productListViewController.products = products
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
