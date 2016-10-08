//
//  Models.swift
//  Loveq
//
//  Created by xayoung on 16/4/16.
//  Copyright © 2016年 xayoung. All rights reserved.
//
import Foundation
import ObjectMapper

class UserModels: Mappable {
    var error: Int?
    var message: String?
    var content: String?
    var js: String?
    var user1: user?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        message <- map["message"]
        content <- map["content"]
        js <- map["js"]
        user1 <- map["user"]
    }
}

class user: Mappable {
    var user_id: String?
    var email: String?
    var user_name: String?
    var password: String?
    var question: String?
    var answer: String?
    var sex: String?
    var birthday: String?
    var v_money: String?
    var user_money: String?
    var frozen_money: String?
    var pay_points: String?
    var rank_points: String?
    var address_id: String?
    var reg_time: String?
    var last_login: String?
    var last_time: String?
    var last_ip: String?
    var reg_ip: String?
    var visit_count: String?
    var user_rank: String?
    var is_special: String?
    var salt: String?
    var parent_id: String?
    var flag: String?
    var alias: String?
    var msn: String?
    var qq: String?
    var office_phone: String?
    var home_phone: String?
    var mobile_phone: String?
    var is_validated: String?
    var credit_line: String?
    var picture: String?
    var marry: String?
    var country: String?
    var province: String?
    var city: String?
    var district: String?
    var nickname: String?
    var brief: String?
    var viewnum: String?
    var credits: String?
    var special_start: String?
    var special_end: String?
    var time_month: String?
    var time_total: String?
    var visit_month: String?
    var new_msg: String?
    var new_msg_re: String?
    var new_cmt: String?
    var user_setting: String?
    var display_name: String?

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        user_id <- map["user_id"]
        email <- map["email"]
        user_name <- map["user_name"]
        password <- map["password"]
        question <- map["question"]
        answer <- map["answer"]
        sex <- map["sex"]
        birthday <- map["birthday"]
        v_money <- map["v_money"]
        user_money <- map["user_money"]
        frozen_money <- map["frozen_money"]
        pay_points <- map["pay_points"]
        rank_points <- map["rank_points"]
        address_id <- map["address_id"]
        reg_time <- map["reg_time"]
        last_login <- map["last_login"]
        last_time <- map["last_time"]
        last_ip <- map["last_ip"]
        reg_ip <- map["reg_ip"]
        visit_count <- map["visit_count"]
        user_rank <- map["user_rank"]
        is_special <- map["is_special"]
        salt <- map["salt"]
        parent_id <- map["parent_id"]
        flag <- map["flag"]
        alias <- map["alias"]
        msn <- map["msn"]
        qq <- map["qq"]
        office_phone <- map["office_phone"]
        home_phone <- map["home_phone"]
        mobile_phone <- map["mobile_phone"]
        is_validated <- map["is_validated"]
        credit_line <- map["credit_line"]
        picture <- map["picture"]
        marry <- map["marry"]
        country <- map["country"]
        province <- map["province"]
        city <- map["city"]
        district <- map["district"]
        nickname <- map["nickname"]
        brief <- map["brief"]
        viewnum <- map["viewnum"]
        credits <- map["credits"]
        special_start <- map["special_start"]
        special_end <- map["special_end"]
        time_month <- map["time_month"]
        time_total <- map["time_total"]
        visit_month <- map["visit_month"]
        new_msg <- map["new_msg"]
        new_msg_re <- map["new_msg_re"]
        new_cmt <- map["new_cmt"]
        user_setting <- map["user_setting"]
        display_name <- map["display_name"]
    }
}

class ProgrammerListModel: Mappable {
    var title: String?
    var type: String?
    var url: String?
    required init?(map: Map){

    }

    func mapping(map: Map) {
        title <- map["title"]
        type <- map["type"]
        url <- map["url"]

    }

}

