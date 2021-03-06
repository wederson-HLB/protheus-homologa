#Include "rwmake.ch"    

/*
Funcao      : 40FIN003
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Retorna dados do banco e do fornecedor.
Autor       : 
TDN         : 
Revis?o     : Jo?o Silva
Data/Hora   : 19/02/2014
M?dulo      : Financeiro.
*/                      

*------------------------------*
 User Function 40FIN003(nOpc)   
*------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
Local cModPag    := Posicione("SEA",1,xFilial("SEA")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA,"EA_MODELO")

//????????????????????????????????????????????????????Ŀ
//?Agencia Conta Favorecido    				   ?
//??????????????????????????????????????????????????????
If nOpc == 1 
    If SA2->A2_BANCO $ "341/409"       
        cRet := "0" + strzero(val(substr(SA2->A2_AGENCIA,1,4)),4) + space(1) + "000000" + STRZERO(VAL(SUBSTR(SA2->A2_NUMCON,1,Len(AllTrim(SA2->A2_NUMCON))-1)),6) + SPACE(1) + SUBSTR(SA2->A2_NUMCON,Len(AllTrim(SA2->A2_NUMCON)),1)
    Else
        cRet :=  strzero(val(substr(SA2->A2_AGENCIA,1,5)),5) + space(1) + STRZERO(VAL(SUBSTR(SA2->A2_NUMCON,1,Len(AllTrim(SA2->A2_NUMCON))-1)),12) +  SPACE(1) +  SUBSTR(SA2->A2_NUMCON,Len(AllTrim(SA2->A2_NUMCON)),1)
    Endif        
Endif
            

//????????????????????????????????????????????????????Ŀ
//?Dados de Identifica??o do Tributo    				   ?
//??????????????????????????????????????????????????????

If nOpc == 2
    If cModPag $ "17"   //  GPS   
        cRet := "01" + Alltrim(SE2->E2_CODRET) + STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4) + SUBSTR(SM0->M0_CGC,1,14)
        cRet += STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) +  "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14)
        cRet += STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + SPACE(08) + (SE2->E2_IDCNAB + SPACE(1)+ SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SPACE(26))+ SUBSTR(SM0->M0_NOME,1,30)
    Endif 
    If cModPag $ "16"  // DARF 
        cRet := "02" + SE2->E2_CODRET + "2" + SUBSTR(SM0->M0_CGC,1,14)+ STRTRAN(STRTRAN(DTOC(SE2->E2_EMISSAO),"/","",1,1),"/","")
        cRet += "00000000000000000" + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) 
        cRet +=  STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + SPACE(30) +   SUBSTR(SM0->M0_NOME,1,30)
    Endif
    If cModPag $ "18"  // DARF SIMPLES 
        cRet := "03" + SE2->E2_CODRET + "2" + SUBSTR(SM0->M0_CGC,1,14)+ STRTRAN(STRTRAN(DTOC(SE2->E2_EMISSAO),"/","",1,1),"/","")
        cRet += "000000000000000" + "00000" + SPACE(4) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) 
        cRet += STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + SPACE(30) +   SUBSTR(SM0->M0_NOME,1,30)
    Endif
    If cModPag $ "21"  // DARJ 
        cRet := "04" + SE2->E2_CODRET + "2" + SUBSTR(SM0->M0_CGC,1,14)+ SUBSTR(SM0->M0_INSC,1,8) +  SUBSTR(VAL(SUBSTR(SE2->E2_NUM,1,9)),16)
        cRet += SPACE(1) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14)       
        cRet += STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") 
        cRet += STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4) + SPACE(10) + SUBSTR(SM0->M0_NOME,1,30)   
    Endif
    If cModPag $ "22"  // GARE ? SP ICMS
        cRet := "05" + SE2->E2_CODRET + "2" + SUBSTR(SM0->M0_CGC,1,14)+ STRZERO(SUBSTR(SM0->M0_INSC,1,8),12) + REPL("0",13)
        cRet += STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4) + REPL("0",13)
        cRet += STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14)       
        cRet += STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") + SPACE(11) + SUBSTR(SM0->M0_NOME,1,30)
    Endif
    If cModPag $ "35"  // FGTS 
        cRet := "11" + SE2->E2_CODRET + "2" + SUBSTR(SM0->M0_CGC,1,14) + SE2->E2_CODBAR + REPL("0",27)
        cRet += SUBSTR(SM0->M0_NOME,1,30) + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","") 
        cRet += STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + SPACE(30)
    Endif
Endif    

//????????????????????????????????????????????????????Ŀ
//?Agencia Conta Favorecido - FUNCIONARIOS   		   ?
//??????????????????????????????????????????????????????
If nOpc == 3 
    If substr(SRA->RA_BCDEPSA,1,3) $ "341/409"       
        cRet := "0" + strzero(val(substr(SRA->RA_BCDEPSA,4,4)),4) + space(1) + "000000" + STRZERO(VAL(SUBSTR(SRA->RA_CTDEPSA,1,Len(AllTrim(SRA->RA_CTDEPSA))-1)),6) + SPACE(1) + SUBSTR(SRA->RA_CTDEPSA,Len(AllTrim(SRA->RA_CTDEPSA)),1)
    Else
        cRet :=  strzero(val(substr(SRA->RA_BCDEPSA,4,4)),5) + space(1) + STRZERO(VAL(SUBSTR(SRA->RA_CTDEPSA,1,Len(AllTrim(SRA->RA_CTDEPSA))-1)),12) +  SPACE(1) +  SUBSTR(SRA->RA_CTDEPSA,Len(AllTrim(SRA->RA_CTDEPSA)),1)
    Endif        
Endif

RestArea(aArea)
Return(cRet)