//
//  Storage.swift
//  Navigation
//
//  Created by v.milchakova on 05.12.2020.
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import UIKit

struct Storage {
    
    static var favoritePosts = [StoragePost]()
    
    static var posts = [
        StoragePost(author: "Venom",
             title: "Вышедший в 2018 «Веном» с Томом Харди в главной роли смог порадовать фанатов, но оставил после себя немало вопросов о связи с франшизой «Человек-паук». Веном является одним из самых известных противников Человека-паука в комиксах, а история происхождения симбиота и его мотивы тесно связаны с Питером Паркером.",
             image: #imageLiteral(resourceName: "venom"),
             likes: 10,
             views: 15),
        StoragePost(author: "Thanos",
             title: "Танос является главным и величайшим злодеем «Саги бесконечности». Его полноценное появление в «Мстителях: Война бесконечности» прорабатывалось крайне долго, но оно того стоило. Значимость его роли в киновселенноф Marvel объясняет, почему для его образа было рассмотрено несколько вариантов. ",
             image: #imageLiteral(resourceName: "tanos"),
             likes: 20,
             views: 25),
        StoragePost(author: "Quicksilver",
             title: "Ртуть обладает сверхъестественной способностью передвигаться с запредельными скоростями; до недавнего времени он в пределах основной вселенной Marvel изображался человеком-мутантом[en], наделённым сверхъестественными способностями. Весьма часто персонаж появляется в связи с Людьми Икс, будучи впервые представлен как их противник; в более поздних публикациях он сам становится супергероем.",
             image: #imageLiteral(resourceName: "fast"),
             likes: 30,
             views: 35),
        StoragePost(author: "Batman",
             title: "Студия Warner Bros. будет активно использовать для создания экранизации комиксов \"Бэтмен\" те же технологии, что ранее применялись при работе над фантастическим сериалом \"Мандалорец\". Об этом рассказал один из руководителей знаменитой студии Industrial Light & Magic Роб Бредоу, которого цитирует издание The Hollywood Reporter.",
             image: #imageLiteral(resourceName: "batman"),
             likes: 40,
             views: 45)
    ]
}