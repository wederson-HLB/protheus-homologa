#Include "rwmake.ch"    

/*
Funcao      : SispagFun
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Retorna dados do banco e do fornecedor.
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function SispagFun(nOpc)   
*------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
//RSB - 01/02/2017 - Duplicidade de registros, o pocisione esta duplicando.
//Local cModPag    := Posicione("SEA",1,xFilial("SEA")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA,"EA_MODELO")
Local cModPag    := SEA->EA_MODELO 
Local cConta	 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agencia Conta Favorecido    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	//AOA - 31/08/2016 - Tratamento no campo de conta corrente para levar apenas números.                    
	cConta := STRTRAN(SA2->A2_NUMCON,"-","") 
    If SA2->A2_BANCO $ "341/409"      
        cRet := "0" + strzero(val(substr(SA2->A2_AGENCIA,1,4)),4) + space(1) + "000000" + STRZERO(VAL(SUBSTR(cConta,1,Len(AllTrim(cConta))-1)),6) + SPACE(1) + SUBSTR(cConta,Len(AllTrim(cConta)),1)
    Else
        cRet :=  strzero(val(substr(SA2->A2_AGENCIA,1,5)),5) + space(1) + STRZERO(VAL(SUBSTR(cConta,1,Len(AllTrim(cConta))-1)),12) +  SPACE(1) +  SUBSTR(cConta,Len(AllTrim(cConta)),1)
    Endif        
Endif
            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados de Identificação do Tributo    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 2
    If cModPag $ "17"   //  GPS   
        cRet := "01" + Alltrim(SE2->E2_CODRET) + STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4) + SUBSTR(SA2->A2_CGC,1,14)
        cRet += STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) +  "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14)
        cRet += STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","20") + SPACE(08) + (SE2->E2_IDCNAB + SPACE(1)+ SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SPACE(26))+ SUBSTR(SA2->A2_NOME,1,30)
    Endif 
    If cModPag $ "16"  // DARF 
        cRet := "02" + SE2->E2_CODRET + IIF(SA2->A2_TIPO="J","2","1") + SUBSTR(SA2->A2_CGC,1,14)+ STRTRAN(STRTRAN(DTOC(SE2->E2_EMISSAO),"/","",1,1),"/","20")
        cRet += "00000000000000000" + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) 
        cRet +=  STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","20") + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","20") + SPACE(30) +   SUBSTR(SA2->A2_NOME,1,30)
    Endif
    If cModPag $ "18"  // DARF SIMPLES 
        cRet := "03" + SE2->E2_CODRET + IIF(SA2->A2_TIPO="J","2","1") + SUBSTR(SA2->A2_CGC,1,14)+ STRTRAN(STRTRAN(DTOC(SE2->E2_EMISSAO),"/","",1,1),"/","20")
        cRet += "000000000000000" + "00000" + SPACE(4) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) 
        cRet += STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","20") + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","20") + SPACE(30) +   SUBSTR(SA2->A2_NOME,1,30)
    Endif
    If cModPag $ "21"  // DARJ 
        cRet := "04" + SE2->E2_CODRET + IIF(SA2->A2_TIPO="J","2","1") + SUBSTR(SA2->A2_CGC,1,14)+ SUBSTR(SA2->A2_INSCR,1,8) +  SUBSTR(VAL(SUBSTR(SE2->E2_NUM,1,9)),16)
        cRet += SPACE(1) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14) + "0000000000000000000000000000" +  STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,14)       
        cRet += STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","20") + STRTRAN(STRTRAN(DTOC(SE2->E2_VENCREA),"/","",1,1),"/","20") 
        cRet += STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4) + SPACE(10) + SUBSTR(SA2->A2_NOME,1,30)   
    Endif
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agencia Conta Favorecido - FUNCIONARIOS   		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 
    If substr(SRA->RA_BCDEPSA,1,3) $ "341/409"       
        cRet := "0" + strzero(val(substr(SRA->RA_BCDEPSA,4,4)),4) + space(1) + "000000" + STRZERO(VAL(SUBSTR(SRA->RA_CTDEPSA,1,Len(AllTrim(SRA->RA_CTDEPSA))-1)),6) + SPACE(1) + SUBSTR(SRA->RA_CTDEPSA,Len(AllTrim(SRA->RA_CTDEPSA)),1)
    Else
        cRet :=  strzero(val(substr(SRA->RA_BCDEPSA,4,4)),5) + space(1) + STRZERO(VAL(SUBSTR(SRA->RA_CTDEPSA,1,Len(AllTrim(SRA->RA_CTDEPSA))-1)),12) +  SPACE(1) +  SUBSTR(SRA->RA_CTDEPSA,Len(AllTrim(SRA->RA_CTDEPSA)),1)
    Endif        
Endif

RestArea(aArea)
Return(cRet)