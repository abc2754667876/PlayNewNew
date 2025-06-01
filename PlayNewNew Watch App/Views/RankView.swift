import SwiftUI
import Combine

struct RankView: View {
    @StateObject private var socketClient = SocketClient()
    
    var body: some View {
        ZStack{
            Text("🐮")
                .font(.system(size: 150))
                .opacity(0.2)
                .blur(radius: 4)
            
            TabView{
                RealTimeRankView()
                DailyRankView()
                WeeklyRankView()
                MonthlyRankView()
            }
            .tabViewStyle(PageTabViewStyle())
        }
        .onDisappear{
            socketClient.stopConnection()
        }
        .environmentObject(socketClient)
    }
}

struct RealTimeRankView: View{
    @State private var isLoaded: Bool = false
    @EnvironmentObject var socketClient: SocketClient
    @State private var cancellable: AnyCancellable?
    
    @State private var spendData = ""
    @State private var countData = ""
    @State private var frequencyData = ""
    @State private var heartRateData = ""
    @State private var numData = ""
    
    @State private var spendParsedData: [(position: String, userName: String, data: String)] = []
    @State private var countParsedData: [(position: String, userName: String, data: String)] = []
    @State private var frequencyParsedData: [(position: String, userName: String, data: String)] = []
    @State private var heartRateParsedData: [(position: String, userName: String, data: String)] = []
    @State private var numParsedData: [(position: String, userName: String, data: String)] = []
    
    @State private var haveData: Bool = false
    
    var body: some View{
        ZStack{
            if isLoaded{
                ScrollView{
                    VStack{
                        Text("🕗实时榜")
                            .font(.custom("zixiaohunnaitangti_T", size:18))
                            .padding(.bottom, 1)
                        
                        Text("统计周期：过去一小时")
                            .opacity(0.6)
                            .font(.system(size: 12))
                            .padding(.bottom, 10)
                        
                        HStack{
                            Text("⏱用时榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(spendParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: formatTime(Int(entry.data) ?? 0))
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("👋摇动榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(countParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }

                        HStack{
                            Text("👌频率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(frequencyParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下/秒")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("💗心率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(heartRateParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data)
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("🤩次数榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(numParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "次")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                    }
                }
            }
            else{
                ProgressView("正在加载实时排行榜")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear{
            RequestRealTimeRank()
        }
        .onDisappear{
            
        }
    }
    
    private func RequestRealTimeRank(){
        let json_RequestRank = JSON_RequestRank(command: "RequestRank", type: "RealTime")
        let sendString = encodeToJSON(object: json_RequestRank)
        socketClient.sendMessage(sendString ?? "nil")
        
        cancellable = socketClient.messageReceived
            .sink { receivedMessage in
                if let parsedData = parseJSON(jsonString: receivedMessage){
                    let jsonDict = parsedData as? [String: Any]
                    //let command = jsonDict?["Command"] as? String
                    //let type = jsonDict?["Type"] as? String
                    
                    self.spendData = jsonDict?["Spend"] as? String ?? ""
                    self.countData = jsonDict?["Count"] as? String ?? ""
                    self.frequencyData = jsonDict?["Frequency"] as? String ?? ""
                    self.heartRateData = jsonDict?["HeartRate"] as? String ?? ""
                    self.numData = jsonDict?["Num"] as? String ?? ""
                    
                    self.spendParsedData = parseData(spendData)
                    self.countParsedData = parseData(countData)
                    self.frequencyParsedData = parseData(frequencyData)
                    self.heartRateParsedData = parseData(heartRateData)
                    self.numParsedData = parseData(numData)
                    
                    if spendParsedData.count == 0 {
                        haveData = false
                    }
                    else{
                        haveData = true
                    }
                    
                    self.isLoaded = true
                }
            }
    }
    
    private func parseData(_ data: String) ->
    [(position: String, userName: String, data: String)]{
        return data.split(separator: "|").compactMap{ entry in
            let fields = entry.split(separator: "*")
            if fields.count == 3{
                let userName = String(fields[0])
                let data = String(fields[1])
                let position = String(fields[2])
                return (position: position, userName: userName, data: data)
            }
            return nil
        }
    }
}

struct DailyRankView: View{
    @State private var isLoaded: Bool = false
    @EnvironmentObject var socketClient: SocketClient
    @State private var cancellable: AnyCancellable?
    
    @State private var spendData = ""
    @State private var countData = ""
    @State private var frequencyData = ""
    @State private var heartRateData = ""
    @State private var numData = ""
    
    @State private var spendParsedData: [(position: String, userName: String, data: String)] = []
    @State private var countParsedData: [(position: String, userName: String, data: String)] = []
    @State private var frequencyParsedData: [(position: String, userName: String, data: String)] = []
    @State private var heartRateParsedData: [(position: String, userName: String, data: String)] = []
    @State private var numParsedData: [(position: String, userName: String, data: String)] = []
    
    @State private var haveData: Bool = false
    
    var body: some View{
        ZStack{
            if isLoaded{
                ScrollView{
                    VStack{
                        Text("☀日榜")
                            .font(.custom("zixiaohunnaitangti_T", size:18))
                            .padding(.bottom, 1)
                        
                        Text("统计周期：过去24小时")
                            .opacity(0.6)
                            .font(.system(size: 12))
                            .padding(.bottom, 10)
                        
                        HStack{
                            Text("⏱用时榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(spendParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: formatTime(Int(entry.data) ?? 0))
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("👋摇动榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(countParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }

                        HStack{
                            Text("👌频率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(frequencyParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下/秒")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("💗心率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(heartRateParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data)
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("🤩次数榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(numParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "次")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                    }
                }
            }
            else{
                ProgressView("正在加载日排行榜")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear{
            RequestRealTimeRank()
        }
        .onDisappear{
            
        }
    }
    
    private func RequestRealTimeRank(){
        let json_RequestRank = JSON_RequestRank(command: "RequestRank", type: "Daily")
        let sendString = encodeToJSON(object: json_RequestRank)
        socketClient.sendMessage(sendString ?? "nil")
        
        cancellable = socketClient.messageReceived
            .sink { receivedMessage in
                if let parsedData = parseJSON(jsonString: receivedMessage){
                    let jsonDict = parsedData as? [String: Any]
                    //let command = jsonDict?["Command"] as? String
                    //let type = jsonDict?["Type"] as? String
                    
                    self.spendData = jsonDict?["Spend"] as? String ?? ""
                    self.countData = jsonDict?["Count"] as? String ?? ""
                    self.frequencyData = jsonDict?["Frequency"] as? String ?? ""
                    self.heartRateData = jsonDict?["HeartRate"] as? String ?? ""
                    self.numData = jsonDict?["Num"] as? String ?? ""
                    
                    self.spendParsedData = parseData(spendData)
                    self.countParsedData = parseData(countData)
                    self.frequencyParsedData = parseData(frequencyData)
                    self.heartRateParsedData = parseData(heartRateData)
                    self.numParsedData = parseData(numData)
                    
                    if spendParsedData.count == 0 {
                        haveData = false
                    }
                    else{
                        haveData = true
                    }
                    
                    self.isLoaded = true
                }
            }
    }
    
    private func parseData(_ data: String) ->
    [(position: String, userName: String, data: String)]{
        return data.split(separator: "|").compactMap{ entry in
            let fields = entry.split(separator: "*")
            if fields.count == 3{
                let userName = String(fields[0])
                let data = String(fields[1])
                let position = String(fields[2])
                return (position: position, userName: userName, data: data)
            }
            return nil
        }
    }
}

struct WeeklyRankView: View{
    @State private var isLoaded: Bool = false
    @EnvironmentObject var socketClient: SocketClient
    @State private var cancellable: AnyCancellable?
    
    @State private var spendData = ""
    @State private var countData = ""
    @State private var frequencyData = ""
    @State private var heartRateData = ""
    @State private var numData = ""
    
    @State private var spendParsedData: [(position: String, userName: String, data: String)] = []
    @State private var countParsedData: [(position: String, userName: String, data: String)] = []
    @State private var frequencyParsedData: [(position: String, userName: String, data: String)] = []
    @State private var heartRateParsedData: [(position: String, userName: String, data: String)] = []
    @State private var numParsedData: [(position: String, userName: String, data: String)] = []
    
    @State private var haveData: Bool = false
    
    var body: some View{
        ZStack{
            if isLoaded{
                ScrollView{
                    VStack{
                        Text("📅周榜")
                            .font(.custom("zixiaohunnaitangti_T", size:18))
                            .padding(.bottom, 1)
                        
                        Text("统计周期：过去7天")
                            .opacity(0.6)
                            .font(.system(size: 12))
                            .padding(.bottom, 10)
                        
                        HStack{
                            Text("⏱用时榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(spendParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: formatTime(Int(entry.data) ?? 0))
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("👋摇动榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(countParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }

                        HStack{
                            Text("👌频率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(frequencyParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下/秒")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("💗心率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(heartRateParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data)
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("🤩次数榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(numParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "次")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                    }
                }
            }
            else{
                ProgressView("正在加载周排行榜")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear{
            RequestRealTimeRank()
        }
        .onDisappear{
            
        }
    }
    
    private func RequestRealTimeRank(){
        let json_RequestRank = JSON_RequestRank(command: "RequestRank", type: "Weekly")
        let sendString = encodeToJSON(object: json_RequestRank)
        socketClient.sendMessage(sendString ?? "nil")
        
        cancellable = socketClient.messageReceived
            .sink { receivedMessage in
                if let parsedData = parseJSON(jsonString: receivedMessage){
                    let jsonDict = parsedData as? [String: Any]
                    //let command = jsonDict?["Command"] as? String
                    //let type = jsonDict?["Type"] as? String
                    
                    self.spendData = jsonDict?["Spend"] as? String ?? ""
                    self.countData = jsonDict?["Count"] as? String ?? ""
                    self.frequencyData = jsonDict?["Frequency"] as? String ?? ""
                    self.heartRateData = jsonDict?["HeartRate"] as? String ?? ""
                    self.numData = jsonDict?["Num"] as? String ?? ""
                    
                    self.spendParsedData = parseData(spendData)
                    self.countParsedData = parseData(countData)
                    self.frequencyParsedData = parseData(frequencyData)
                    self.heartRateParsedData = parseData(heartRateData)
                    self.numParsedData = parseData(numData)
                    
                    if spendParsedData.count == 0 {
                        haveData = false
                    }
                    else{
                        haveData = true
                    }
                    
                    self.isLoaded = true
                }
            }
    }
    
    private func parseData(_ data: String) ->
    [(position: String, userName: String, data: String)]{
        return data.split(separator: "|").compactMap{ entry in
            let fields = entry.split(separator: "*")
            if fields.count == 3{
                let userName = String(fields[0])
                let data = String(fields[1])
                let position = String(fields[2])
                return (position: position, userName: userName, data: data)
            }
            return nil
        }
    }
}

struct MonthlyRankView: View{
    @State private var isLoaded: Bool = false
    @EnvironmentObject var socketClient: SocketClient
    @State private var cancellable: AnyCancellable?
    
    @State private var spendData = ""
    @State private var countData = ""
    @State private var frequencyData = ""
    @State private var heartRateData = ""
    @State private var numData = ""
    
    @State private var spendParsedData: [(position: String, userName: String, data: String)] = []
    @State private var countParsedData: [(position: String, userName: String, data: String)] = []
    @State private var frequencyParsedData: [(position: String, userName: String, data: String)] = []
    @State private var heartRateParsedData: [(position: String, userName: String, data: String)] = []
    @State private var numParsedData: [(position: String, userName: String, data: String)] = []
    
    @State private var haveData: Bool = false
    
    var body: some View{
        ZStack{
            if isLoaded{
                ScrollView{
                    VStack{
                        Text("🌙月榜")
                            .font(.custom("zixiaohunnaitangti_T", size:18))
                            .padding(.bottom, 1)
                        
                        Text("统计周期：过去30天")
                            .opacity(0.6)
                            .font(.system(size: 12))
                            .padding(.bottom, 10)
                        
                        HStack{
                            Text("⏱用时榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(spendParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: formatTime(Int(entry.data) ?? 0))
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("👋摇动榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(countParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }

                        HStack{
                            Text("👌频率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(frequencyParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "下/秒")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("💗心率榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(heartRateParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data)
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                        
                        HStack{
                            Text("🤩次数榜")
                                .font(.custom("zixiaohunnaitangti_T", size:16))
                            Spacer()
                        }
                        if haveData == true {
                            ForEach(numParsedData, id: \.position){ entry in
                                RankView_RankList(position: entry.position, userName: entry.userName, data: entry.data + "次")
                            }
                            .padding(.bottom, 10)
                        }
                        else{
                            Text("暂时无人上榜")
                                .font(.custom("zixiaohunnaitangti_T", size:11))
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .opacity(0.5)
                        }
                    }
                }
            }
            else{
                ProgressView("正在加载月排行榜")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear{
            RequestRealTimeRank()
        }
        .onDisappear{
            
        }
    }
    
    private func RequestRealTimeRank(){
        let json_RequestRank = JSON_RequestRank(command: "RequestRank", type: "Monthly")
        let sendString = encodeToJSON(object: json_RequestRank)
        socketClient.sendMessage(sendString ?? "nil")
        
        cancellable = socketClient.messageReceived
            .sink { receivedMessage in
                if let parsedData = parseJSON(jsonString: receivedMessage){
                    let jsonDict = parsedData as? [String: Any]
                    //let command = jsonDict?["Command"] as? String
                    //let type = jsonDict?["Type"] as? String
                    
                    self.spendData = jsonDict?["Spend"] as? String ?? ""
                    self.countData = jsonDict?["Count"] as? String ?? ""
                    self.frequencyData = jsonDict?["Frequency"] as? String ?? ""
                    self.heartRateData = jsonDict?["HeartRate"] as? String ?? ""
                    self.numData = jsonDict?["Num"] as? String ?? ""
                    
                    self.spendParsedData = parseData(spendData)
                    self.countParsedData = parseData(countData)
                    self.frequencyParsedData = parseData(frequencyData)
                    self.heartRateParsedData = parseData(heartRateData)
                    self.numParsedData = parseData(numData)
                    
                    if spendParsedData.count == 0 {
                        haveData = false
                    }
                    else{
                        haveData = true
                    }
                    
                    self.isLoaded = true
                }
            }
    }
    
    private func parseData(_ data: String) ->
    [(position: String, userName: String, data: String)]{
        return data.split(separator: "|").compactMap{ entry in
            let fields = entry.split(separator: "*")
            if fields.count == 3{
                let userName = String(fields[0])
                let data = String(fields[1])
                let position = String(fields[2])
                return (position: position, userName: userName, data: data)
            }
            return nil
        }
    }
}

private func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let seconds = seconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

#Preview {
    RankView()
}
