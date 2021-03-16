#INCLUDE "PROTHEUS.CH"

User Function RetCep
Local cCep := ""

IIF(!EMPTY(SA1->A1_CEPC),cCep := SA1->A1_CEPC,cCep := SA1->A1_CEP ) 

cCep := StrZero(VAL(Replace(cCep,"-","")),8)

Return cCep