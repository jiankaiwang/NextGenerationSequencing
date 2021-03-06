# -----------------------------------------
# Updated Date: 2014/03/24
# Input: Files generated by gene_deep.r and combineTtl.r are inputs.
# Output: The same items whose expression difference are significant between the control and treatment on both gene level
#         and transcript level.
# Environemt: Linux or Windows
# Description: Matching processing is processed to check whether gene name is in the label of transcript name. If it is, 
#              a match was achieved and then was output.
# -----------------------------------------

# read gene
getGene <- read.table("6_gene_potential.csv",row.names=1,header=T,sep=",")
seqName <- c("gCtlRead","gTreRead","gCtlReadN","gTreReadN","gFold","gExDif","gProb")
colnames(getGene) <- seqName

# split function
getGeneName <- function(line) {
	getRes <- strsplit(line[1],"\\|")
	return(getRes[[1]][2])
}
getTranscriptName <- function(line) {
	getRes <- strsplit(line[1],"\\|")
	return(getRes[[1]][1])
}


# read transcript (origin)
getTranscript <- read.table("5_transcript.csv",row.names=1,header=T,sep=",")
totalName <- rownames(getTranscript)
getTranscript <- cbind(totalName,getTranscript)

geneName <- apply(getTranscript,1,getGeneName)
transcriptName <- apply(getTranscript,1,getTranscriptName)

getTranscript <- (cbind(geneName,transcriptName,getTranscript[,-9]))[,-3]
rownames(getTranscript) <- getTranscript[,2]
getTranscript <- getTranscript[,-2]
seqName <- c("geName","trCtlRead","trTreRead","trCtlReadN","trTreReadN","trFold","trExDif","trProb")
colnames(getTranscript) <- seqName

# find the same geneName
newData <- rownames(getGene)
newData2 <- getTranscript[,1]
multiData <- c()
for(i in 1:length(newData)) {
	for(j in 1:length(newData2)) {
		if(newData[i] == newData2[j]) {
			multiData <- c(multiData,newData[i])
		}
	}
}
multiData <- unique(multiData)

trName <- rownames(getTranscript)
getTranscript <- cbind(trName,getTranscript)

# combine gene and transcript
newCombine <- c()
newCombineData <- c()
for(i in 1:length(getTranscript[,1])) {
	for(j in 1:length(multiData)) {
		if(getTranscript[i,2] == multiData[j]) {
			getTranscriptData <- getTranscript[i,]
			getGeneData <- getGene[multiData[j],]
			newCombine <- cbind(getTranscriptData,getGeneData)
			newCombineData <- rbind(newCombineData, newCombine)
			break
		}
	}
}

newCombineData <- newCombineData[,-1]

# write table
write.table(newCombineData,"7_bothGeTr.csv",sep=",",row.names = TRUE,col.names = TRUE)




