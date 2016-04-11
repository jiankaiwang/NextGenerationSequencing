# -----------------------------------------
# Updated Date: 2014/03/24
# Input: The file generated by analysisGene.r.
# Output: The plot and table show the potential genes whose expression difference are statistically significant.
# Environemt: Linux or Windows
# Description: Use the distribution and trend to find out genes whose expression fit several user-defined thresholds. 
# -----------------------------------------

# combine data
# read rawCounts
rawCounts <- read.table("4_geneSummary.txt",row.names=1,header=T,sep="\t")

# read noiseq calculation
calNoiseq <- read.table("5_gene_Noiseq.txt",row.names=1,header=T,sep="\t")

# combine
total <- cbind(rawCounts,calNoiseq)

# writeTable
# write.table(total,"gene_reads_NOIseq.csv",sep=",",row.names = TRUE,col.names = TRUE)

# -----------------------------------
# get data normalized
getDetailData <- total
high_probability <- 0.70
getMoreItem <- total[which(total[,7] > high_probability),3:4]
getLessItem <- total[which(total[,7] < high_probability),3:4]

print(paste("More than",getMoreItem,":",length(getMoreItem[,1]),sep=" "))
print(paste("More less",getMoreItem,":",length(getLessItem[,1]),sep=" "))

plot(0, type='n', xlim=c(-1, max(getMoreItem[,1],getLessItem[,1]) + 1), 
ylim=c(-1, max(getMoreItem[,2],getLessItem[,2]) + 1), xlab="control normalization", 
ylab="treatment normalization")

for(i in 1:length(getLessItem[,1])) {
	points(x = getLessItem[i,1], y = getLessItem[i,2], type="p")
}

for(i in 1:length(getMoreItem[,1])) {
	points(x = getMoreItem[i,1], y = getMoreItem[i,2], type="p", col="red")
}

myline.fit <- lm(getLessItem[,2] ~ getLessItem[,1])

# add trend line
abline(myline.fit, col="blue")

# get line formula
getDetails <- summary(myline.fit)$coef
slope <- as.character(round(getDetails[2,1],digit=5))
intercept <- as.character(round(getDetails[1,1],digit=5))

newString <- paste("y = ",slope, sep="")

if(getDetails[1,1] < 0) {
	newString <- paste(newString, intercept, sep=" ")
} else {
	newString <- paste(newString, intercept, sep=" + ")
}

# add text of trend line
text(x=0, y=13000, "Trend line:", pos = 4, cex = 0.7, col="blue")
text(x=2000, y=13000, newString, pos = 4, cex = 0.7, col="blue")

# find > or less <
moreThen <- 2
lessThen <- 1 / moreThen

extractData <- function(line) {
	maxTmp <- max(line[1],line[2])
	minTmp <- min(line[1],line[2])
	if(maxTmp / minTmp >= moreThen) {
		return(1)
	}
	else {
		return(0)
	}
}

getMoreFold <- apply(getLessItem,1,extractData)
rawData <- cbind(getMoreFold,getLessItem)
rawData <- rawData[which(rawData[,1] == 1),]

for(i in 1:length(rawData[,1])) {
	points(x = rawData[i,2], y = rawData[i,3], type="p", col="green")
}

library("plotrix")
# add text of high probabilities
draw.circle(0,12500,radius=100,nv=100,border=NULL,col="red",lty=1,lwd=1)
text(x=0, y=12500, paste("High probability",high_probability,sep=":"), pos = 4, cex = 0.7, col="red")

# add text of high probabilities
draw.circle(0,12000,radius=100,nv=100,border=NULL,col="green",lty=1,lwd=1)
text(x=0, y=12000, paste("High fold: ",as.character(moreThen),sep=""), pos = 4, cex = 0.7, col="green")

# -----------------------------------------------------------------
# high potential
control_threshold <- 5000
treatment_threshold <- 5000

getHP <- total[which(total[,3] > control_threshold),]
getHP <- getHP[which(getHP[,4] > treatment_threshold),]

abline(v=control_threshold, col="red")
abline(h=treatment_threshold, col="green")
text(x=control_threshold, y=1000, paste("x = ",control_threshold, sep=""), pos = 4, cex = 0.7, col="red")
text(x=10000, y=treatment_threshold+500, paste("y = ",treatment_threshold, sep=""), pos = 4, cex = 0.7, col="green")

# comp
moreThen <- 1.2
lessThen <- 1 / moreThen

extractMoreData <- function(line) {
	maxTmp <- max(line[3],line[4])
	minTmp <- min(line[3],line[4])
	if(maxTmp / minTmp >= moreThen) {
		return(1)
	}
	else {
		return(0)
	}
}

getMHP <- apply(getHP,1,extractMoreData)
getMHP <- cbind(getMHP,getHP)
getMHP <- getMHP[which(getMHP[,1] > 0),]

# add more high significant
getMHPName <- row.names(getMHP)
tempStr <- ""
showLabel <- ""
for(i in 1:length(getMHP[,1])) {
	points(x = getMHP[i,4], y = getMHP[i,5], type="p", col="orange")
	tempStr <- paste("(prob:",as.character(round(getMHP[i,8],digits = 3)),")",sep="")
	showLabel <- paste("(",i,")",sep="")
	text(x=getMHP[i,4], y=getMHP[i,5], showLabel, pos = 4, cex = 0.7, col="orange")
	text(x=8000, y=4500-i*500, paste(showLabel,rownames(getMHP)[i],tempStr,sep=" "), pos = 4, cex = 0.7, col="orange")
	print(getMHP[i])
}

# add more potential point
draw.circle(0,11500,radius=100,nv=100,border=NULL,col="orange",lty=1,lwd=1)
text(x=0, y=11500, paste("More fold: ",as.character(moreThen),sep=""), pos = 4, cex = 0.7, col="orange")

# writeBothResultTable
write.table(getMHP[,-1][,-8],"6_gene_potential.csv",sep=",",row.names = TRUE,col.names = TRUE)