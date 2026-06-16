# SEM full model

## load data
source("Data cleaning script.R")
names(envatt)

## load packages
library(lavaan)
library(semPlot)
library(semptools)
library(semTools)

## factor analysis 
### CC scales 

hierF <- cbind(envatt$cc_eh_1,envatt$cc_eh_2,envatt$cc_eh_3,envatt$cc_eh_4,envatt$cc_eh_5,envatt$cc_eh_6,envatt$cc_eh_7)
hierF <- na.omit(hierF)

factHier <- factanal(x = hierF, factors = 1) #vars 2, 5, 7

egalF <- cbind(envatt$cc_eh_8,envatt$cc_eh_9,envatt$cc_eh_10,envatt$cc_eh_11,envatt$cc_eh_12,envatt$cc_eh_13,envatt$cc_eh_14)
egalF <- na.omit(egalF)

factEgal <- factanal(x = egalF, factors = 1) #vars 4, 6, 7  

indivF <- cbind(envatt$cc_ci_1,envatt$cc_ci_2,envatt$cc_ci_3,envatt$cc_ci_4,envatt$cc_ci_5,
                envatt$cc_ci_6,envatt$cc_ci_7,envatt$cc_ci_8,envatt$cc_ci_9,envatt$cc_ci_10,
                envatt$cc_ci_11,envatt$cc_ci_12)
indivF <- na.omit(indivF)

factIndiv <- factanal(x = indivF, factors = 1) #vars 2, 3, 12 

commF <- cbind(envatt$cc_ci_13,envatt$cc_ci_14,envatt$cc_ci_15,envatt$cc_ci_16,envatt$cc_ci_17)
commF <- na.omit(commF)

factComm <- factanal(x = commF, factors = 1) #vars 1, 2, 4 

### CNS 

cnsF <- cbind(envatt$cns1,envatt$cns2,envatt$cns3,envatt$cns4_r,envatt$cns5,
              envatt$cns6,envatt$cns7,envatt$cns8,envatt$cns9,envatt$cns10,
              envatt$cns12_r,envatt$cns11,envatt$cns13,envatt$cns14_r)

factCNS <- factanal(x = cnsF, factors = 1) #vars 2, 6, 7

### NEP 

nepF <- cbind(envatt$nep1,envatt$nep2_r,envatt$nep3,envatt$nep4_r,envatt$nep5,envatt$nep6_r,
              envatt$nep7,envatt$nep8_r,envatt$nep9,envatt$nep10_r,envatt$nep11,envatt$nep12_r,
              envatt$nep13,envatt$nep14_r,envatt$nep15)

factNEP <- factanal(x = nepF, factors = 1) #vars 5, 10, 15

### behaviors 

behaveF <- cbind(envatt$act.org,envatt$cand,envatt$money.org,envatt$cont.off,envatt$cont.bus,
                 envatt$petition,envatt$meeting,
                 envatt$product,envatt$water,envatt$buycott,envatt$recycle,envatt$energy,
                 envatt$stocks)

## SEM 
envatt$cc_eh_2 <- 5-envatt$cc_eh_2
envatt$cc_eh_5 <- 5-envatt$cc_eh_5
envatt$cc_eh_7 <- 5-envatt$cc_eh_7

envatt$cc_ci_2 <- 5-envatt$cc_ci_2
envatt$cc_ci_3 <- 5-envatt$cc_ci_3
envatt$cc_ci_12 <- 5-envatt$cc_ci_12

envatt$cns1 <- 6-envatt$cns1
envatt$cns2 <- 6-envatt$cns2
envatt$cns3 <- 6-envatt$cns3
envatt$cns4
envatt$cns5 <- 6-envatt$cns5
envatt$cns6 <- 6-envatt$cns6
envatt$cns7 <- 6-envatt$cns7
envatt$cns8 <- 6-envatt$cns8
envatt$cns9 <- 6-envatt$cns9
envatt$cns10 <- 6-envatt$cns10
envatt$cns11 <- 6-envatt$cns11
envatt$cns12
envatt$cns13 <- 6-envatt$cns13
envatt$cns14


envatt$nep5 <- 6-envatt$nep5 
envatt$nep15 <- 6-envatt$nep15 

# cns2+cns3+cns5+cns6+cns7+cns8+cns9+cns10

envatt$BEHAVE <- envatt$PEB

names(envatt)

envatt$product <- NA
envatt$product[which(q62x74_62==1)] <- 1
envatt$product[which(q62x74_62!=1)] <- 0

envatt$act.org <- NA
envatt$act.org[which(q62x74_63==1)] <- 1
envatt$act.org[which(q62x74_63!=1)] <- 0

envatt$cand <- NA
envatt$cand[which(q62x74_64==1)] <- 1
envatt$cand[which(q62x74_64!=1)] <- 0

envatt$money.org <- NA
envatt$money.org[which(q62x74_65==1)] <- 1
envatt$money.org[which(q62x74_65!=1)] <- 0

envatt$cont.off <- NA
envatt$cont.off[which(q62x74_66==1)] <- 1
envatt$cont.off[which(q62x74_66!=1)] <- 0

envatt$cont.bus <- NA
envatt$cont.bus[which(q62x74_67==1)] <- 1
envatt$cont.bus[which(q62x74_67!=1)] <- 0

envatt$petition <- NA
envatt$petition[which(q62x74_68==1)] <- 1
envatt$petition[which(q62x74_68!=1)] <- 0

envatt$meeting <- NA
envatt$meeting[which(q62x74_69==1)] <- 1
envatt$meeting[which(q62x74_69!=1)] <- 0

envatt$water <- NA
envatt$water[which(q62x74_70==1)] <- 1
envatt$water[which(q62x74_70!=1)] <- 0

envatt$buycott <- NA
envatt$buycott[which(q62x74_71==1)] <- 1
envatt$buycott[which(q62x74_71!=1)] <- 0

envatt$recycle 

envatt$energy

table(envatt$stocks)

semModelCNS <- '
HIER =~ cc_eh_2+cc_eh_5+cc_eh_7
EGAL =~ cc_eh_11+cc_eh_13+cc_eh_14
INDIV =~ cc_ci_2+cc_ci_3+cc_ci_12
COMM =~ cc_ci_13+cc_ci_14+cc_ci_16
CNS =~ cns2+cns6+cns7
CNS ~ HIER+EGAL+INDIV+COMM
BEHAVE ~ CNS+HIER+EGAL+INDIV+COMM
'

semModelNEP <- '
HIER =~ cc_eh_2+cc_eh_5+cc_eh_7
EGAL =~ cc_eh_11+cc_eh_13+cc_eh_14
INDIV =~ cc_ci_2+cc_ci_3+cc_ci_12
COMM =~ cc_ci_13+cc_ci_14+cc_ci_16
NEP =~ nep5+nep10+nep15
NEP ~ HIER+EGAL+INDIV+COMM
BEHAVE ~ NEP+HIER+EGAL+INDIV+COMM
'

fitSemModelCNS <- sem(semModelCNS, data = envatt)
fitSemModelNEP <- sem(semModelNEP, data = envatt)
summary(fitSemModelCNS, standardized=TRUE, fit.measures=TRUE)
summary(fitSemModelNEP, standardized=TRUE, fit.measures=TRUE)
compRelSEM(fitSemModelCNS)
compRelSEM(fitSemModelNEP)
AVE(fitSemModelCNS)
AVE(fitSemModelNEP)



summary(fitSemModelCNS, standardized=TRUE, fit.measures=TRUE)


semPaths(fitSemModelCNS, "std", edge.label.cex = 0.5, curvePivot = TRUE, 
         fade = FALSE)

mCNS <- matrix(c("h",   NA,  NA,
              "e",   NA,  NA, 
              NA,   "cns",  "PEB",
              "i",   NA,  NA, 
              "c",   NA,  NA), byrow = TRUE, 5, 3)

semCNS <- semPaths(fitSemModelCNS, whatLabels="std",
         sizeMan = 5,
         node.width = 1,
         edge.label.cex = .75,
         style = "ram",
         rotation = 2,
         mar = c(5, 5, 5, 5))
semCNS2 <- mark_sig(semCNS, fitSemModelCNS)
plot(semCNS2)

semNEP <- semPaths(fitSemModelNEP, whatLabels="std",
         sizeMan = 5,
         node.width = 1,
         edge.label.cex = .75,
         style = "ram",
         rotation = 2,
         mar = c(5, 5, 5, 5))
semNEP2 <- mark_sig(semNEP, fitSemModelNEP)
plot(semNEP2)


model <- ' # direct effect
             Y ~ c*X
           # mediator
             M ~ a*X
             Y ~ b*M
           # indirect effect (a*b)
             ab := a*b
           # total effect
             total := c + (a*b)
         '
fit <- sem(model, data = Data)
summary(fit)

semMedModelEgalCNS <- '
HIER =~ cc_eh_2+cc_eh_5+cc_eh_7
EGAL =~ cc_eh_11+cc_eh_13+cc_eh_14
INDIV =~ cc_ci_2+cc_ci_3+cc_ci_12
COMM =~ cc_ci_13+cc_ci_14+cc_ci_16
CNS =~ cns2+cns6+cns7
# direct effect 
BEHAVE ~ c*EGAL+HIER+INDIV+COMM
# mediator 
CNS ~ a*EGAL+HIER+INDIV+COMM
BEHAVE ~ b*CNS
# indirect effect (a*b)
ab := a*b
# total effect
total := c + (a*b)
'

semMedModelEgalCNSfit <- sem(semMedModelEgalCNS, data = envatt)
summary(semMedModelEgalCNSfit, standardized=TRUE)

semMedModelCommCNS <- '
HIER =~ cc_eh_2+cc_eh_5+cc_eh_7
EGAL =~ cc_eh_11+cc_eh_13+cc_eh_14
INDIV =~ cc_ci_2+cc_ci_3+cc_ci_12
COMM =~ cc_ci_13+cc_ci_14+cc_ci_16
CNS =~ cns2+cns6+cns7
# direct effect 
BEHAVE ~ c*COMM+EGAL+HIER+INDIV
# mediator 
CNS ~ a*COMM+EGAL+HIER+INDIV
BEHAVE ~ b*CNS
# indirect effect (a*b)
ab := a*b
# total effect
total := c + (a*b)
'

semMedModelCommCNSfit <- sem(semMedModelCommCNS, data = envatt)
summary(semMedModelCommCNSfit, standardized=TRUE)

semMedModelEgalNEP <- '
HIER =~ cc_eh_2+cc_eh_5+cc_eh_7
EGAL =~ cc_eh_11+cc_eh_13+cc_eh_14
INDIV =~ cc_ci_2+cc_ci_3+cc_ci_12
COMM =~ cc_ci_13+cc_ci_14+cc_ci_16
NEP =~ nep5+nep10+nep15
# direct effect 
BEHAVE ~ c*EGAL+HIER+INDIV+COMM
# mediator 
NEP ~ a*EGAL+HIER+INDIV+COMM
BEHAVE ~ b*NEP
# indirect effect (a*b)
ab := a*b
# total effect
total := c + (a*b)
'

semMedModelEgalNEPfit <- sem(semMedModelEgalNEP, data = envatt)
summary(semMedModelEgalNEPfit, standardized=TRUE)


anova(fitSemModelCNS, fitSemModelNEP)

## Confirmatory factor analysis (with lavaan) 
### CC scales (using short version of scales per @kahanCulturalCognitionConception2012)

### egal and hier
#HEmodelShort <- 'he =~ cc_eh_2+cc_eh_3+cc_eh_5+cc_eh_8+cc_eh_11+cc_eh_13'
#HEfit <- cfa(HEmodelShort, data = envatt)
#summary(HEfit, standardized = TRUE, fit.measures = TRUE)

envatt$cc_eh_8 <- 5-envatt$cc_eh_8
envatt$cc_eh_11 <- 5-envatt$cc_eh_11
envatt$cc_eh_13 <- 5-envatt$cc_eh_13

HmodelShort <- 'h =~ cc_eh_2+cc_eh_3+cc_eh_5'
EmodelShort <- 'e =~ cc_eh_8+cc_eh_11+cc_eh_13'

Hfit <- cfa(HmodelShort, data = envatt)
Efit <- cfa(EmodelShort, data = envatt)

summary(Hfit, standardized = TRUE)
summary(Efit, standardized = TRUE)

### comm and indiv scales 
#### one scale 
#ICmodelShort <- 'ic =~ cc_ci_4+cc_ci_8+cc_ci_10+cc_ci_13+cc_ci_14+cc_ci_16'
#ICfit <- cfa(ICmodelShort, data = envatt)
#summary(ICfit, standardized = TRUE)

#### separate scales
envatt$cc_ci_13 <- 5-envatt$cc_ci_13
envatt$cc_ci_14 <- 5-envatt$cc_ci_14
envatt$cc_ci_16 <- 5-envatt$cc_ci_16

ImodelShort <- 'i =~ cc_ci_4+cc_ci_8+cc_ci_10'
CmodelShort <- 'c =~ cc_ci_13+cc_ci_14+cc_ci_16'

Ifit <- cfa(ImodelShort, data = envatt)
Cfit <- cfa(CmodelShort, data = envatt)

summary(Ifit, standardized = TRUE)
summary(Cfit, standardized = TRUE)

### CNS 
CNSmodel <- 'cns =~ cns2+cns6+cns7'

CNSfit <- cfa(CNSmodel, data = envatt)

summary(CNSfit, standardized = TRUE, fit.measures = TRUE)

### NEP 

NEPmodel <- 'nep =~ nep5+nep10_r+nep15'

NEPfit <- cfa(NEPmodel, data = envatt)

summary(NEPfit, standardized = TRUE)

### SEM models 
semModel1 <- '
he =~ 1*cc_eh_2+cc_eh_3+cc_eh_5+cc_eh_8+cc_eh_11+cc_eh_13
ic =~ 1*cc_ci_4+cc_ci_8+cc_ci_10+cc_ci_13+cc_ci_14+cc_ci_16
cns =~ 1*cns1+cns2+cns3+cns4_r+cns5+cns6+cns7+cns8+cns9+cns10+cns12_r+cns11+cns13+cns14_r
nep =~ 1*nep1+nep2_r+nep3+nep4_r+nep5+nep6_r+nep7+nep8_r+nep9+nep10_r+nep11+nep12_r+nep13+nep14_r+nep15 
cns ~ nep
cns ~ he+ic
nep ~ he+ic
'

fitSemModel1 <- sem(semModel1, data = envatt)
summary(fitSemModel1, standardized=TRUE, fit.measures=TRUE)
semPaths(fitSemModel1, "par", edge.label.cex = 1.2, fade = FALSE)

semModel2 <- '
he =~ cc_eh_2+cc_eh_3+cc_eh_5+cc_eh_8+cc_eh_11+cc_eh_13
ic =~ cc_ci_4+cc_ci_8+cc_ci_10+cc_ci_13+cc_ci_14+cc_ci_16
cns =~ cns1+cns2+cns3+cns4_r+cns5+cns6+cns7+cns8+cns9+cns10+cns12_r+cns11+cns13+cns14_r
nep =~ nep1+nep2_r+nep3+nep4_r+nep5+nep6_r+nep7+nep8_r+nep9+nep10_r+nep11+nep12_r+nep13+nep14_r+nep15 
cns ~ 1+nep
publicL =~ act.org+cand+money.org+cont.off+cont.bus+petition+meeting
privateL =~ product+water+buycott+recycle+energy
publicL ~ 1+privateL
cns ~ he+ic
nep ~ 1+he+ic
publicL ~ he+ic+cns+nep
privateL ~ 1+he+ic+cns+nep
'

fitSemModel2 <- sem(semModel2, data = envatt)
summary(fitSemModel2, standardized=TRUE, fit.measures=TRUE)
semPaths(fitSemModel2, "par", edge.label.cex = 1.2, fade = FALSE)

#### CC scales as observed and separate

hierA <- psy::cronbach(data.frame(envatt$cc_eh_2, envatt$cc_eh_3, envatt$cc_eh_5))
egalA <- psy::cronbach(data.frame(envatt$cc_eh_8, envatt$cc_eh_11, envatt$cc_eh_13))
indivA <- psy::cronbach(data.frame(envatt$cc_ci_4,envatt$cc_ci_8,envatt$cc_ci_10))
commA <- psy::cronbach(data.frame(envatt$cc_ci_13,envatt$cc_ci_14,envatt$cc_ci_16))

## kitchen sink model 
names(envatt)


semModelX <- '
h =~ cc_eh_1+cc_eh_2+cc_eh_3+cc_eh_4+cc_eh_5+cc_eh_6+cc_eh_7
# e =~ cc_eh_8+cc_eh_11+cc_eh_13
# ic =~ cc_ci_4+cc_ci_8+cc_ci_10+cc_ci_13+cc_ci_14+cc_ci_16
cns =~ cns1+cns2+cns3+cns4_r+cns5+cns6+cns7+cns8+cns9+cns10+cns12_r+cns11+cns13+cns14_r
nep =~ nep1+nep2_r+nep3+nep4_r+nep5+nep6_r+nep7+nep8_r+nep9+nep10_r+nep11+nep12_r+nep13+nep14_r+nep15 
cns ~ nep
behave =~ act.org+cand+money.org+cont.off+cont.bus+petition+meeting+product+water+buycott+recycle+energy
cns ~ h
nep ~ h
behave ~ h+cns+nep
'

fitSemModelX <- sem(semModelX, data = envatt)
summary(fitSemModelX, standardized=TRUE, fit.measures=TRUE)
semPaths(fitSemModel2, "par", edge.label.cex = 1.2, fade = FALSE)

