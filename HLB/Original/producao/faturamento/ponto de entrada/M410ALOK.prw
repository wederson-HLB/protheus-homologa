#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : M410ALOK
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : P.E. Exclusão do Pedido de Venda. 
Autor       : Jean Victor Rocha
Data/Hora   : 01/07/2014     
Obs         : Executado antes de iniciar a alteração do pedido de venda
TDN         : http://tdn.totvs.com/pages/releaseview.action?pageId=6784143   
Modulo      : Faturamento
Cliente     : Haulotte e Victaulic


*/
*-----------------------*
User Function  M410ALOK() 
*-----------------------*    
Local lRet	:= .F.     
Local cQry	:= ""

Do Case
	/*
	Revisão     : Tiago Luiz Mendonça 
	Data/Hora   : 14/02/2012
	Cliente     : Haulotte 
	*/
	Case cEmpAnt $ "JN"
		_cAlias := Alias()
	   _nOrder := DbSetOrder()
	   _nRecno := Recno()
	   DbSelectArea("SZ1")
	   DbSetOrder(1)
	   If DbSeek(xFilial("SZ1")+SC5->C5_NUM)
	      Reclock("SZ1",.F.)
	      DbDelete()
	      MsUnlock()
	   EndIf             
	   DbSelectArea(_cAlias)
	   DbSetOrder(_nOrder)
	   DbGoto(_nRecno)
	   lRet := .T.
	
	/*
	Revisão     : Jean Victor Rocha
	Data/Hora   : 01/07/2014
	Cliente     : Victaulic
	Descrição	: Se não existir Pick-list gerado, possibilita alterar o Pedido de Venda.
	*/
	Case cEmpAnt $ "TM" 
		     
		
		If !(SC9->(FieldPos("C9_P_PICK")) > 0  .And. Alltrim(Funname())=="TMFAT004")
		
			aOrd := SaveOrd({"SC9","SC6","SC5"})
			SC9->(DbSetOrder(1))
			If SC9->(FieldPos("C9_P_PICK")) <> 0
				If Select("QRY") > 0
					QRY->(DbClosearea())
				EndIf  
				cQry := "Select COUNT(*) AS COUNT
				cQry += " From "+RETSQLNAME("SC9")
				cQry += " Where D_E_L_E_T_ <> '*'
				cQry += " 		AND C9_FILIAL = '"+SC5->C5_FILIAL+"'
				cQry += " 		AND C9_PEDIDO = '"+SC5->C5_NUM+"'
				cQry += " 		AND C9_P_PICK = 'S'
				dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
				QRY->(DbGoTop())
				If QRY->(!EOF())
					lRet := QRY->COUNT == 0
				EndIf
				QRY->(DbClosearea())
			Else
				lRet := .T.
			EndIf
	
			RestOrd(aOrd)
	
			If !lRet
				Alert("O pedido selecionado possui item(ns) com Pick-List gerado, não é permitido alterar o pedido!","HLB BRASIL")
			EndIf
		Else    
		
			lRet := .T.
			
	   	EndIf
	      
	  
	
	lRet := .T.
	
	OtherWise          
	
		lRet := .T.

EndCase

Return lRet