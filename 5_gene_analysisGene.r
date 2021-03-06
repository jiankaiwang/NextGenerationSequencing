# -----------------------------------------
# Updated Date: 2014/03/24
# Input: The file generated by extractGene.r.
# Output: The data processed by NOISeq for statistical analyses.
# Environemt: Linux or Windows
# Description: Use the distribution plot and trend to find out the potential items whose expression level have significant 
#              difference between the control and the treatment on gene level.
# -----------------------------------------

# read data
getData <- read.table("4_geneSummary.txt",header=T)
seqName <- getData[,1]
getData <- getData[2:3]
rownames(getData) <- seqName

# NOISeq analysis
#source("http://bioconductor.org/biocLite.R")
#biocLite("NOISeq")
library("NOISeq")

mfactors <- matrix(c("control_read","treatment_read"),nrow = 2, ncol = 1, byrow = TRUE, 
dimnames = list(c("control","treatment"),c("ensembl_gene_id")))

mydata <- readData(data=getData, factors=mfactors)
getNOIseqRes <- noiseq(mydata, k = 0.1, norm = "uqua", replicates = "no", factor="ensembl_gene_id", pnr = 0.2, nss = 10)

write.table(getNOIseqRes@results[[1]], file="5_gene_Noiseq.txt", sep="\t", row.names=T, col.names=T, quote=F)