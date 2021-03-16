/*
Funcao      : FA240LOTE
Parametros  : nOpc
Retorno     : cNroLote 
Objetivos   : Atualiza e retorno do numero do lote.
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/   
 

*------------------------------*
 USER FUNCTION FA240LOTE(nOpc)   
*------------------------------*

Local aArea			:= GetArea()
Local cNroLote      := ""   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza e retorno o numero do lote				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SEE")+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON+"003")
		RecLock("SEE",.F.)
		cNroLote			:= Soma1(Alltrim(SEE->EE_LOTECP),4)
		SEE->EE_LOTECP   	:= cNroLote
		MsUnLock()
	EndIf
Endif

If nOpc == 2
    dbSelectArea("SEE")
    dbSetOrder(1)
    dbGoTop()
    If dbSeek(xFilial("SEE")+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON+"003")
       	cNroLote			:= AllTrim(SEE->EE_LOTECP)
    Endif
Endif

RestArea(aArea)

RETURN(cNroLote)