library(rvest)
library(data.table)
library(dplyr)

id<-1:5
url_increase_fast<-paste0(
        "http://www.amazon.cn/gp/movers-and-shakers/digital-text/ref=zg_bsms_digital-text_pg_",
        id,
        "?ie=UTF8&pg=",
        id)
url_newest<-paste0(
        "http://www.amazon.cn/gp/new-releases/digital-text/ref=zg_bsnr_digital-text_pg_",
        id,
        "?ie=UTF8&pg=",
        id)
url<-c(url_increase_fast,url_newest)

readdata<-function(i){
        web<-html(url[i],encoding="UTF-8")
        title<-web %>% html_nodes("div.zg_title") %>% html_text()
	title_short<-substr(title,1,20)
        price<-as.numeric(gsub("�� ","",web %>% html_nodes("span.price") %>% html_text()))
        ranking_movement<-web %>% html_nodes("span.zg_salesMovement") %>% html_text()
        rank_number<-as.numeric(gsub("\\.","",web %>% html_nodes("span.zg_rankNumber") %>% html_text()))
        if (length(ranking_movement)==0) {ranking_movement=rep(NA,20)
        rank_number=rep(NA,20)}
        link<-gsub("\\\n","",web %>% html_nodes("div.zg_title a") %>% html_attr("href"))
        ASIN<-sapply(strsplit(link,split = "/dp/"),function(e)e[2])
	img<-web %>% html_nodes("div.zg_itemImage_normal img")  %>% html_attr("src")
	img_link<-paste0("<img src='",img,"'>")
	title_link<-paste0("<a href='",link,"'>",title_short,"</a>")
        combine<-data.table(img_link,title_link,price,ranking_movement)
	setnames(combine,c("ͼ��","����","�۸�","���۱䶯"))
        Sys.sleep(5)
        combine
}


final<-data.table()
for (i in 1:10){
        final<-rbind(final,readdata(i))
        print(i)
}

final_top<-final %>% filter(�۸�<=1)
#�����дһ����������data.tableת��Ϊhtml_table
transfer_html_table<-function(rawdata){
        title<-paste0("<th>",names(rawdata),"</th>")
        content<-sapply(rawdata,function(e)paste0("<td>",e,"</td>"))
        content<-apply(content,1,function(e) paste0(e,collapse = ""))
        content<-paste0("<tr>",content,"</tr>")
        bbb<-c("<table border=1><tr>",title,"</tr>",content,"</table>")
        bbb
}
#����Ӧ��transfer_html_table�������Ѱ����Ϊhtml���
final_less1<-transfer_html_table(rawdata=final %>% filter(�۸�<=1))
write(final_less1,"~//Kindle-����1Ԫ�ؼ���.html")


final_1_2<-transfer_html_table(rawdata=final %>% filter(�۸�>1 & �۸�<=2))
write(final_1_2,"~//Kindle_1-2Ԫ�ؼ���.html")

final_2_5<-transfer_html_table(rawdata=final %>% filter(�۸�>2 & �۸�<=5))
write(final_2_5,"~//Kindle_2-5Ԫ�ؼ���.html")



