//
//  LocalCastleServiceIntegrationTests.swift
//  JapanCastleBookTests
//
//  Created by Mu Yu on 1/11/24.
//

import XCTest
import JapanCastleBook

import Combine

final class LocalCastleServiceIntegrationTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()
    
    func test_load_throwsOnInvalidJSON() {
        let sut = LocalCastleService()
        let exp = expectation(description: "Wait for loading")
        
        sut.load()
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Expected to load items successfully, received \(error) instead")
                    exp.fulfill()
                }
            } receiveValue: { [weak self] items in
                guard let self else { return }
                XCTAssertEqual(items.count, 100)
                XCTAssertEqual(items[0], expectedItem(at: 0))
                XCTAssertEqual(items[1], expectedItem(at: 1))
                
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exp], timeout: 1.0)
    }
}

extension LocalCastleServiceIntegrationTests {
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalCastleService {
        let sut = LocalCastleService()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expectedItem(at index: Int) -> Castle {
        return Castle(
            id: id(at: index),
            name: name(at: index),
            reading: reading(at: index),
            area: area(at: index),
            address: address(at: index),
            phoneNumber: phoneNumber(at: index),
            openingHours: openingHours(at: index),
            accessGuide: accessGuide(at: index),
            parkingInfo: parkingInfo(at: index),
            stampLocation: stampLocation(at: index),
            overview: overview(at: index),
            imageURLs: imageURLs(at: index)
        )
    }
    
    private func id(at index: Int) -> Int {
        return [1, 2, 3, 4][index]
    }
    
    private func name(at index: Int) -> String {
        return [
            "根室半島チャシ跡群",
            "五稜郭"
        ][index]
    }
    
    private func reading(at index: Int) -> String {
        return [
            "ねむろはんとうちゃしあとぐん",
            "ごりょうかく"
        ][index]
    }
    
    private func area(at index: Int) -> CastleArea {
        return [.hokkaidoTohoku, .hokkaidoTohoku][index]
    }
    
    private func address(at index: Int) -> String {
        return [
            "〒087-0166　北海道根室市温根元59",
            "〒040-0001　北海道函館市五稜郭町44"
        ][index]
    }
    
    private func phoneNumber(at index: Int) -> String {
        return [
            "0153-25-3661（根室市歴史と自然の資料館）",
            "0138-21-3463（教育委員会生涯学習部文化財課）、0138-51-2548（市立函館博物館五稜郭分館）"
        ][index]
    }
    
    private func openingHours(at index: Int) -> String {
        return [
            "【根室半島チャシ跡群】根室市納沙布岬ほか24ヶ所 散策自由\n＜根室市歴史と自然の資料館＞\n開館時間：9:30～16:30\n休館日：月曜日、祝日、12月29日～1月3日\n＜根室市観光インフォメーションセンター（根室駅前）＞\n開館時間：9:00～17:00（6月～9月：8:00～17:00）\n休館日：12月31日～1月5日",
            "10:00～17:00"
        ][index]
    }
    
    private func accessGuide(at index: Int) -> String {
        return [
            "JR根室本線 根室駅から根室交通バス納沙布線で納沙布岬下車、湯根元漁港方面に徒歩約20分",
            "JR函館本線 函館駅下車。路面電車湯の川行きでは五稜郭公園前下車、徒歩10分。函館バス五稜郭行きでは五稜郭公園入口下車、徒歩約5〜10分。",
        ][index]
    }
    
    private func parkingInfo(at index: Int) -> String {
        return [
            "",
            "近隣有料駐車場利用"
        ][index]
    }
    
    private func stampLocation(at index: Int) -> String {
        return ["根室市歴史と自然の資料館\n根室市観光インフォメーションセンター（根室駅前）",
                "箱館奉行所付属建物「板庫（休憩所）」"
        ][index]
    }
    
    private func overview(at index: Int) -> String {
        return [
            "根室半島には一帯にわたり、チャシ跡が存在する。そのほとんどは海抜約５ｍから５０ｍの海岸断崖上の台地の平坦部にあり、海岸台地上に半円形又は四角形の壕を巡らせている。根室市内には30ヵ所※のチャシ跡の存在が確認されているが、保存状態が良好で、他地域と比較すると分布密度も濃いことで知られている。（※このうち24ヵ所が国指定史跡。チャシは一般的には「砦」と考えられているが、見張場や聖地、談判の場として多目的に使われたとされる。） ※スタンプ設置場所や営業時間は上記サイトなどで最新情報をご確認ください。設置場所の変更情報はこちらを参照ください。 ※地図のピン位置はシステムで自動取得しているため誤差が生じる場合があります。",
            "五稜郭は、函館山から約６km離れた函館市のほぼ中央となる場所にある｡この場所は、ちょうど浅いすり鉢の底のように低くなっている所。この五稜郭のある周辺は、今から約150年前の江戸時代終わり頃、箱館が開港された時はたくさんの「ネコヤナギ」が生えていたようで、このため別名「柳野（やなぎの）」と呼ばれていたように当時は至る所が水はけの悪い湿地だったようだ。 ※スタンプ設置場所や営業時間は上記サイトなどで最新情報をご確認ください。設置場所の変更情報はこちらを参照ください。 ※地図のピン位置はシステムで自動取得しているため誤差が生じる場合があります。"
        ][index]
    }
    
    private func imageURLs(at index: Int) -> [URL] {
        return [
            [
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2017/10/1-thasi-gunn-2012-07-01_122220-2-e1509455484591.jpg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2017/10/1-tyasi-gun-S1900020_SP0000-2-e1509455546813.jpg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2017/10/1-tyasi-gun-2012-07-01_1209372-e1509454666880.jpg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2017/10/1-tyasi-gun02012-07-01_1214242-e1509454443168.jpg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2017/10/1-tyasi-gun-2012-07-01_1205122-e1509454091449.jpg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2017/10/1-thasi-gunn-2012-07-01_122220-2-e1509455484591.jpg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2017/10/1-tyasi-gun-S1900020_SP0000-2-e1509455546813.jpg")!
            ],
            [
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/10/2023-09-25_09-36-49_794.jpeg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/10/2023-09-25_10-09-34_644.jpeg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/10/2023-09-25_08-38-58_153.jpeg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/10/2023-09-25_08-48-02_266.jpeg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/10/2023-09-25_09-11-21_838.jpeg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/10/2023-09-25_09-36-49_794.jpeg")!,
                URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/10/2023-09-25_10-09-34_644.jpeg")!
            ]
        ][index]
    }
}
