//
//  MyDiaryTableViewCell.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//

import UIKit

class MyDiaryTableViewCell: UITableViewCell {

    //MARK:- -- Outlets & Variable Declaration --
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var vwData: shadowView!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblDiaryTitle: UILabel!
    @IBOutlet weak var lblDiaryData: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    
    //MARK:- -- Object LifeCycle --
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnClose.layer.cornerRadius = btnClose.frame.size.height / 2
        btnClose.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
