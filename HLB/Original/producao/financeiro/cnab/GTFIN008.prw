#Include "rwmake.ch"    

/*
Funcao      : GTFIN008
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Retorna Dados de Identificação do Tributo.
Autor       : Anderson Arrais
TDN         : 
OBS			: Layout Citi de 240 posições Tax service contas a pagar	
Revisão     : Anderson Arrais
Data/Hora   : 29/10/2015
Módulo      : Financeiro.
*/                      

*------------------------------*
 User Function GTFIN008(nOpc)   
*------------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
Local cModPag    := Posicione("SEA",1,xFilial("SEA")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA,"EA_MODELO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados de Identificação do Tributo  				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 1 //Preenche a partir da posição 133 até a 230
    If cModPag $ "17"   //  GPS   
        cRet := "17" + STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15)
        cRet += SPACE(15) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15) + SPACE (45)
    Endif 
    If cModPag $ "16"  // DARF 
        cRet := "16" + GRAVADATA(SE2->E2_EMISSAO,.F.,5) + "00000000000000000" + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15)
        cRet += STRZERO(SE2->E2_MULTA*100,15) + STRZERO(SE2->E2_JUROS*100,15) + GRAVADATA(SE2->E2_VENCREA,.F.,5) + SPACE(18)
    Endif
    If cModPag $ "22"  // GARE 
        cRet := "22" + GRAVADATA(SE2->E2_VENCREA,.F.,5) + STRZERO(SM0->M0_INSC,12) + STRZERO(VAL(SUBSTR(SE2->E2_NUM,1,9)),13)
        cRet += STRZERO(MONTH(SE2->E2_EMISSAO,2),2)+ STRZERO(YEAR(SE2->E2_EMISSAO,4),4) + SPACE(13) + STRZERO(SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC)*100,15)
        cRet += STRZERO(SE2->E2_MULTA*100,14) + STRZERO(SE2->E2_JUROS*100,14) + SPACE(1)
    Endif
Endif    

RestArea(aArea)
Return(cRet)