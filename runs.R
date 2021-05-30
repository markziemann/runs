x <- readLines("runs_pos_result.txt")

x<-x[grep("\\+",x)]

n <- as.numeric(sapply(strsplit(x," "),"[[",2))

hist.data = hist(n, plot=F)

hist.data$counts = log(hist.data$counts+001, 2)

plot(hist.data,ylab="log2(frequency)")
