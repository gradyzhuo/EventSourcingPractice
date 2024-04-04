# EventSourcing Practice

這是一個實作 EventSourcing 的練習專案
共有兩種型式的 Repository 
- InMemory
使用記憶體的儲存區當 Repository

### 啟動：
```swift 
swift run InMemory
```

- EventStore DB
使用 EventStore 的 DB 當 Repository
需要先啟動 EventStore DB

### 啟動 EventStore DB
```shell
cd server
sudo docker compose up -d 
```

### 啟動:
```swift 
cd ..
swift run ESDB
```

