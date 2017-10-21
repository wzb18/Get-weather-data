rm(list = ls());gc()
library(data.table)
library(dplyr)
library(jsonlite)
library(rvest)

month <- c(paste0("20160", c(1:9)), paste0("2016", c(10,11, 12)))

##get all city name match of the website
web <- read_html('http://www.tianqihoubao.com/lishi/', encoding = "gb2312")
city_use <- web %>% html_nodes(".citychk dd a") %>% html_text()
city_pinyin <- web %>% html_nodes(".citychk dd a") %>% html_attr("href")
ity_pinyin <- gsub("/lishi/", "", city_pinyin) 
ity_pinyin <- gsub(".html", "", city_pinyin)
full_city <- data.frame(city = city_use, city_name = city_pinyin)
# write.csv(full_city, "fullcity_tianqihoubao.csv", row.names = F, quote = F)
# city <- fread("fullcity_tianqihoubao.csv")



## Get weather data function
find_city_weather <- function(urli){
  webi <- read_html(urli, encoding = "gb2312")
  infoi <- webi %>% html_table(header = T) 
}

url_tmp <- "http://www.tianqihoubao.com/lishi/"

i = 1
result <- list()
t1 <- Sys.time()
for(i in 1:nrow(city)){
  cityi <- city$city_name[i]
  urli <- paste0(url_tmp, cityi, "/month/", month, '.html')
  data1 <- lapply(urli, find_city_weather)
  data2 <- lapply(data1, function(x) x[[1]])
  data2 <- rbindlist(data2)
  data2$city <- cityi
  result[[i]] <- data2
  print(i)
}
Sys.time() -t1

result_use <- rbindlist(result)
result_use$天气状况 <- str_replace_all(result_use$天气状况, "\\\r\\\n\\s+", "")
result_use$气温 <- str_replace_all(result_use$气温, "\\\r\\\n\\s+", "")
result_use$风力风向 <- str_replace_all(result_use$风力风向, "\\\r\\\n\\s+", "")
head(result_use)
result_use$城市 <- city$City[match(result_use$city, city$city_name)]
result_use$city <- NULL
write.csv(result_use, "result_use.csv", row.names = F)
