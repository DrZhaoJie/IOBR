# IOBR: Immune Oncology Bioinformatics Research

IOBR is a R package to perform Tumor microenvironment evaluation, signature estimation.

## 安装依赖包
IOBR依赖包较多，包括：tibble, survival, survminer, limma, limSolve, GSVA, e1071, preprocessCore, ggplot2, ggpubr;

```{r}
options("repos"= c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
options(BioC_mirror="http://mirrors.tuna.tsinghua.edu.cn/bioconductor/")

if (!requireNamespace("BiocManager", quietly = TRUE)) install("BiocManager")

depens<-c('tibble', 'survival', 'survminer', 'sva', 'limma', "DESeq2",
          'limSolve', 'GSVA', 'e1071', 'preprocessCore', 'ggplot2', 
          'ggpubr',"devtools")

for(i in 1:length(depens)){
  depen<-depens[i]
  if (!requireNamespace(depen, quietly = TRUE))
    BiocManager::install(depen)
}

if (!requireNamespace("EPIC", quietly = TRUE))
  devtools::install_github("GfellerLab/EPIC", build_vignettes=TRUE)

if (!requireNamespace("MCPcounter", quietly = TRUE))
  devtools::install_github("ebecht/MCPcounter",ref="master", subdir="Source")

if (!requireNamespace("estimate", quietly = TRUE)){
  rforge <- "http://r-forge.r-project.org"
  install.packages("estimate", repos=rforge, dependencies=TRUE)
}

```


The package is not yet on CRAN. You can install from Github:
```{r}
if (!requireNamespace("IOBR", quietly = TRUE))
  devtools::install_github("DongqiangZeng0808/IOBR",ref="master")
```



## IOBR简介

- 1.IOBR集合了8种已经发表的肿瘤微环境解析方法：`CIBERSORT`, `TIMER`, `xCell`, `MCPcounter`, `ESITMATE`, `EPIC`, `IPS`, `quanTIseq`; 
- 2.IOBR集合了共256个已经发表的Signature gene sets：包括肿瘤微环境相关的，肿瘤代谢相关、m6A, 外泌体相关的, 微卫星不稳定, 三级淋巴结评分等，可通过函数 `signatures_sci` 获取到signature的出处；通过 `signature_collection` 可以获取到每个signature gene;
- 3.IOBR集合了三种方法用于上述signature评分的计算，包括`PCA`,`z-score`,`ssGSEA`;
- 4.IOBR集合了多种方法用于变量转化和批量生存分析和统计学分析的方法；
- 5.IOBR集合了批量可视化分组特征的方法；


![](IOBR_pipeline.png)


加载包

```{r, warning=FALSE,message=FALSE}
library(IOBR) 
library(EPIC)
library(estimate) 
library(MCPcounter)
library(tidyverse)
Sys.setenv(LANGUAGE = "en") #显示英文报错信息
options(stringsAsFactors = FALSE) #禁止chr转成factor
```


## 解析肿瘤微环境

### 可选择的肿瘤微环境解析方法

```{r}
tme_deconvolution_methods
#每种方法所对应选择的参数
```

输入文件为100例TCGA-CAOD的RNAseq数据,已采用log2(TPM)进行标准化。

```{r}
# 查看数据
eset_crc[1:5,1:5]
```

查看函数具体的参数
```{r}
help(deconvo_tme)
```


方法1：使用CIBERSORT解析肿瘤微环境
```{r}
cibersort<-deconvo_tme(eset = eset_crc,method = "cibersort",arrays = FALSE,perm = 500 )
head(cibersort)
```
方法2：使用EPIC解析肿瘤微环境
```{r}
epic<-deconvo_tme(eset = eset_crc,method = "epic",arrays = FALSE)
head(epic)

```

方法3：使用EPIC解析肿瘤微环境
```{r}
mcp<-deconvo_tme(eset = eset_crc,method = "mcpcounter")
head(mcp)

```


方法4：使用xCell解析肿瘤微环境
```{r,message=FALSE}
xcell<-deconvo_tme(eset = eset_crc,method = "xcell",arrays = FALSE)
head(xcell)

```


方法5：使用ESTIMATE计算肿瘤纯度和免疫、间质评分
```{r}
estimate<-deconvo_tme(eset = eset_crc,method = "estimate")
head(estimate)

```



方法6：使用TIMER解析肿瘤微环境
```{r,message=FALSE, warning=FALSE}
timer<-deconvo_tme(eset = eset_crc,method = "timer",group_list = rep("coad",dim(eset_crc)[2]))
head(timer)

```

方法7：使用quanTIseq解析肿瘤微环境
```{r}
quantiseq<-deconvo_tme(eset = eset_crc, tumor = TRUE, arrays = FALSE, scale_mrna = TRUE,method = "quantiseq")
head(quantiseq)

```
方法8：使用IPS评估肿瘤免疫表型
```{r,message=FALSE}
ips<-deconvo_tme(eset = eset_crc,method = "ips",plot= FALSE)
head(ips)
```


合并所有的解析结果用于后续的分析
```{r}
tme_combine<-cibersort %>% 
  inner_join(.,mcp,by = "ID") %>% 
  inner_join(.,xcell,by = "ID") %>%
  inner_join(.,epic,by = "ID") %>% 
  inner_join(.,estimate,by = "ID") %>% 
  inner_join(.,timer,by = "ID") %>% 
  inner_join(.,quantiseq,by = "ID") %>% 
  inner_join(.,ips,by = "ID")
dim(tme_combine)
colnames(tme_combine)
```

## Signature score 的评估
IOBR集合了共256个已经发表的Signature gene sets：包括肿瘤微环境相关的，肿瘤代谢相关、m6A, 外泌体相关的, 微卫星不稳定, 三级淋巴结评分等，可通过函数'signatures_sci'获取到signature的出处；通过'signature_collection'可以获取到每个signature gene;


查看有哪些signature
```{r}
#微环境相关的signature
names(signature_tme)[1:20]
#代谢相关的signature
names(signature_metabolism)[1:20]
#与基础研究相关的signature: 比如m6A, 外泌体
names(signature_star)
#signature 集合
names(signature_collection)[1:20]

```


### 评估肿瘤微环境相关的signature-(使用PCA方法）
```{r}
sig_tme<-calculate_sig_score(pdata = NULL,eset = eset_crc,
                             signature = signature_tme,
                             method = "pca",
                             mini_gene_count = 2)
sig_tme[1:5,1:10]
```

### 评估肿瘤微环境相关的signature-（使用ssGSEA方法）
```{r,message=FALSE}
sig_tme<-calculate_sig_score(pdata = NULL,eset = eset_crc,
                                 signature = signature_tme,
                                 method = "ssgsea",
                                 mini_gene_count = 5)
sig_tme[1:5,1:10]
```


### 评估代谢相关的signature
```{r}
sig_meta<-calculate_sig_score(pdata = NULL,eset = eset_crc,
                                 signature = signature_metabolism,
                                 method = "pca",
                                 mini_gene_count = 2)
sig_meta[1:5,1:10]
```


### 计算所有收集的signature score（综合三种的方法： PCA, ssGSEA和z-score）
```{r,message=FALSE}
sig_res<-calculate_sig_score(pdata = NULL,eset = eset_crc,
                                 signature = signature_collection,
                                 method = "integration",
                                 mini_gene_count = 2)
sig_res[1:5,1:10]
```



### IOBR还集合了GO, KEGG, HALLMARK, REACTOME的signature gene sets

建议使用ssGSEA的方法进行评估,如果样本量比较大且signature比较多，运行时间会比较长，
```{r,message=FALSE}
sig_hallmark<-calculate_sig_score(pdata = NULL,
                             eset = eset_crc,
                             signature = hallmark ,
                             method = "ssgsea",
                             mini_gene_count = 2)
sig_hallmark[1:5,1:10]
```
