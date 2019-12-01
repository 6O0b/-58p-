# install.packages("RSelenium")
library(RSelenium)

#### 웹 사이트 접속 ####

shell('docker run -d -p 4445:4444 selenium/standalone-chrome')
remDr <- remoteDriver(remoteServerAddr = 'localhost', 
                      port = 4445L, # 포트번호 입력 
                      browserName = "chrome")
remDr$open()

# 스팀/카카오, tpp/fpp, 솔로/듀오/스쿼드 선택 
remDr$navigate("https://pubg.op.gg/leaderboard/?platform=steam&mode=tpp&queue_size=1")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=steam&mode=tpp&queue_size=2")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=steam&mode=tpp&queue_size=4")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=steam&mode=fpp&queue_size=1")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=steam&mode=fpp&queue_size=2")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=steam&mode=fpp&queue_size=4")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=kakao&mode=tpp&queue_size=1")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=kakao&mode=tpp&queue_size=2")
#remDr$navigate("https://pubg.op.gg/leaderboard/?platform=kakao&mode=tpp&queue_size=4")


#### 데이터 정리 ####

result <- c() # 결과 테이블 저장 변수 선언 

# top3
# top3 정보를 모아둔 클래스 불러오기 
top3_item <- remDr$findElements(using = "class name", value = "leader-board-top3__item")

# top3 정보 정리 
for( i in 1:3 ) {
  top3 <- unlist(top3_item[[i]]$getElementText())
  index <- gregexpr("\n",top3)[[1]]
  
  ID <- substr(top3, 3, index[1]-1)
  SP <- substr(top3, index[1]+1, index[2]-1)
  Matches <- substr(top3, index[3]+1, index[4]-1)
  Wins <- substr(top3, index[5]+5, index[6]-2)
  Top10 <- substr(top3, index[6]+7, index[7]-2)
  KD <- substr(top3, index[7]+5, index[8]-1)
  Demage <- substr(top3, index[8]+8, index[9]-1)
  AvgRate <- substr(top3, index[12]+12, nchar(top3))
  
  result <- rbind(result,cbind(ID,SP,Matches,Wins,Top10,KD,Demage,AvgRate))
}

# (top3를 제외한) top(n)
n <- 500 # 수정 가능, 최대 500

# top3를 제외한 top500의 정보를 담은 table 불러오기 
table <- remDr$findElement(using = "id", value = "playerRankingTable")
# 함수 작성 편의를 위해 "\n" 추가 
table_text <- paste0(unlist(table$getElementText()),"\n")
# "\n"으로 구분되어 있음 
indexA <- gregexpr("\n", table_text)[[1]]

for( i in 0:(n-4) ) {
  ID <- substr(table_text, indexA[(i*9)+2]+1, indexA[(i*9)+3]-1)
  SP <- substr(table_text, indexA[(i*9)+3]+1, indexA[(i*9)+4]-1)
  Matches <- substr(table_text, indexA[(i*9)+4]+1, indexA[(i*9)+5]-1)
  Wins <- substr(table_text, indexA[(i*9)+5]+1, indexA[(i*9)+6]-2)
  Top10 <- substr(table_text, indexA[(i*9)+6]+1, indexA[(i*9)+7]-2)
  KD <- substr(table_text, indexA[(i*9)+7]+1, indexA[(i*9)+8]-1)
  Demage <- substr(table_text, indexA[(i*9)+8]+1, indexA[(i*9)+9]-1)
  AvgRate <- substr(table_text, indexA[(i*9)+9]+1, indexA[(i*9)+10]-1)
  
  result <- rbind(result,cbind(ID,SP,Matches,Wins,Top10,KD,Demage,AvgRate))
}
result <- gsub(",","",result)
BGData <- data.frame(result[,1],
                     as.numeric(result[,2]),
                     as.numeric(result[,3]),
                     as.numeric(result[,4]),
                     as.numeric(result[,5]),
                     as.numeric(result[,6]),
                     as.numeric(result[,7]),
                     as.numeric(result[,8]), 
                     stringsAsFactors = F)
colnames(BGData) <- colnames(result)
rownames(BGData) <- 1:n

BGData

remDr$close()
