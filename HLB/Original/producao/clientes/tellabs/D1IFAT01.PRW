#Include "rwmake.ch"

/*
Funcao      : D1IFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Importacao Pedidos de venda
Autor       : Wederson L. Santana
Data/Hora   : 01/06/2005      
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         : 
Módulo      : Faturamento.
*/

*-------------------------* 
 User Function D1IFAT01()   
*-------------------------*

If cEmpAnt $ "D1"
	If MsgYesNo("Inicia importacao de dados ?","A T E N C A O ")
   		Processa({|| fOkProc() },"Importacao Pedidos de venda ")
  	 Endif	
Else
   MsgInfo("Especifico Tellabs !!"," ATENCAO")
Endif             

Return

//---------------------------------------------

Static Function fOkProc()
If fAbreArq()
   DbSelectArea("XC5")
   DbGotop()
   ProcRegua(RecCount())
   nAchou := nNachou :=0
   Do While.Not.Eof()                                                             
	   IncProc( "Pedido :"+SubStr(C5_NUM,1,6) )
	   DbSelectArea("SC5")
	   DbSetOrder(1)
	   If! DbSeek(xFilial("SC5")+SubStr(XC5->C5_NUM,1,6))
	       DbSelectArea("SA1")
	       DbSetOrder(1)
	       If DbSeek(xFilial("SA1")+SubStr(XC5->C5_CLIENTE,1,6))
	           nAchou ++  
	           DbSelectArea("XC6")   
	           If DbSeek(XC5->C5_NUM)
	              SF4->(DbSetOrder(1))
	              SF4->(DbSeek(xFilial("SF4")+SubStr(XC6->C6_TES,1,3)))
	              SE4->(DbSetOrder(1))
	              SE4->(DbSeek(xFilial("SE4")+SubStr(XC5->C5_CONDPAG,1,3)))
	              
	              fGravaSc5()                     
	              
	              nItem :=1
	              While XC5->C5_NUM == XC6->C6_NUM
	                    SB1->(DbSetOrder(1))
	                    SB1->(DbSeek(xFilial("SB1")+SubStr(XC6->C6_PRODUTO,1,15)))
                       SC6->(DbSetOrder(1))
                       SC6->(DbSeek(xFilial("SC6")+SubStr(XC5->C5_NUM,1,6)+StrZero(nItem,2)))
	                    fGravaSc6()
	                    
	                    XC6->(DbSkip())
	                    nItem ++
	              End
	           Endif   
	       Endif
	   Endif
	   DbSelectArea("XC5")
	   DbSkip()	   
   EndDo
   MsgInfo("Pedidos importados       : "+StrZero(nAchou,9)+Chr(10)+Chr(13)+;
           "Clientes nao Cadastrados : "+StrZero(nNachou,9)+Chr(10)+Chr(13)+;
           "Processo Finalizado!!!"," OK")
Endif
Return

//---------------------------------------------

Static Function fGravaSc5()
Reclock("SC5",.T.)
Replace SC5->C5_FILIAL  With xFilial("SC5")
Replace SC5->C5_NUM     With SubStr(XC5->C5_NUM,1,6)
Replace SC5->C5_EMISSAO With XC5->C5_EMISSAO
Replace SC5->C5_CLIENTE With SA1->A1_COD
Replace SC5->C5_TIPO    With SubStr(Alltrim(XC5->C5_TIPO),1,1)
Replace SC5->C5_TIPOCLI With SA1->A1_TIPO
Replace SC5->C5_LOJACLI With SA1->A1_LOJA
SA1->(DbSeek(xFilial("SA1")+SubStr(XC5->C5_CLIENT,1,6)))
Replace SC5->C5_CLIENT  With SA1->A1_COD
Replace SC5->C5_LOJAENT With SA1->A1_LOJA
Replace SC5->C5_CONDPAG With SE4->E4_CODIGO
Replace SC5->C5_P_DTPCL With XC5->C5_P_DTPCL
//Replace SC5->C5_P_SITE  With SubStr(XC5->C5_P_SITE,1,30)
MsUnlock()
Return

//---------------------------------------------

Static Function fGravaSc6()
Reclock("SC6",.T.)
Replace SC6->C6_FILIAL  With xFilial("SC6")
Replace SC6->C6_ITEM    With StrZero(nItem,2)
Replace SC6->C6_NUM     With SubStr(XC5->C5_NUM,1,6)
Replace SC6->C6_UM      With SB1->B1_UM
Replace SC6->C6_PRODUTO With SB1->B1_COD
Replace SC6->C6_QTDVEN  With XC6->C6_QTDVEN
Replace SC6->C6_PRCVEN  With XC6->C6_PRCVEN
Replace SC6->C6_VALOR   With XC6->C6_VALOR
Replace SC6->C6_TES     With SF4->F4_CODIGO
Replace SC6->C6_P_PRJ   With SubStr(AllTrim(XC6->C6_P_PRJ),1,10)
Replace SC6->C6_LOCAL   With SubStr(AllTrim(XC6->C6_LOCAL),1,2)  
Replace SC6->C6_ENTREG  With XC6->C6_ENTREG
Replace SC6->C6_P_DTSCL With XC6->C6_P_DTSCL
Replace SC6->C6_P_COD   With SB1->B1_P_COD
Replace SC6->C6_DESCRI  With SB1->B1_DESC
Replace SC6->C6_CF      With If(SA1->A1_EST$"SP","5",If(SA1->A1_EST$"EX","7","6"))+SubStr(SF4->F4_CF,2,3)
MsUnlock()

Return

//---------------------------------------------

Static Function fAbreArq()
If Select("XC5") > 0
   DbSelectArea("XC5")
   DbCloseArea("XC5")
Endif
If Select("XC6") > 0
   DbSelectArea("XC6")
   DbCloseArea("XC6")
Endif
lRet :=.T.
DbUseArea(.T.,,"\UTIL\TELLABS\SC5_2","XC5",.T.,.F.)
Index On C5_NUM To SC5 	
DbUseArea(.T.,,"\UTIL\TELLABS\SC6_2","XC6",.T.,.F.)
Index On C6_NUM To SC6 	
If Select("XC5")=0
	MsgInfo("Nao foi possivel abrir o SC5 !!"," ATENCAO")  
	lRet:=.F.
Endif
If Select("XC6")=0
	MsgInfo("Nao foi possivel abrir o SC6 !!"," ATENCAO")  
	lRet:=.F.	
Endif
Return(lRet)