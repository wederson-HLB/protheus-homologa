#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*
Funcao      : TPFAT003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   :
Autor       : João Silva
Data/Hora   : 09/04/2015
Obs         :
Revisão     :
Data/Hora   :
Módulo      : Faturamento
Cliente     : Twitter
*/

*-----------------------------*
User Function TPFAT003()
*-----------------------------*

Local cCliente 	:= SubStr(Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),1,35)
Local cCidade  	:= Alltrim(Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MUN")) +"-"+ Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EST")
Local cPedido  	:= SC5->C5_NUM
Local cNF	   	:= AllTrim(SC5->C5_NOTA)+"/"+AllTrim(SC5->C5_SERIE)

Private nPo		:= AllTrim(SC5->C5_P_PO)+Space(150)
Private	oDlg,oCliente,oCidade,oPedido,oCidade,oPo,oFont

Define Font oFont Name 'Calibri' Size 0, -12

DEFINE MSDIALOG oDlg FROM 2,3 TO 220,370 TITLE 'Alteração de PO ' Pixel

//Objetos SAY - Texto
@005,005	Say "Pedido: " 		Font oFont 	Pixel of oDlg
@005,085	Say "Nota/Serie: "	Font oFont 	Pixel of oDlg
@025,005	Say "Cliente:" 		Font oFont 	Pixel of oDlg
@045,005	Say "Cidade:" 		Font oFont 	Pixel of oDlg
@065,005	Say "Numero P.O.:"	Font oFont 	Pixel of oDlg

//Objeto MSGET	- Captura de informação
@005,030	Msget 		oPedido 	Var cPedido		when .F. 	Size 040,010 Pixel of oDlg
@005,120	Msget 		oNF	 		Var cNF 		when .F. 	Size 040,010 Pixel of oDlg
@025,030	Msget 		oCliente	Var cCliente 	when .F. 	Size 130,010 Pixel of oDlg
@045,030	Msget 		oCidade		Var cCidade 	when .F. 	Size 085,010 Pixel of oDlg
@065,045	Msget 		oPo			Var nPo		 	when .T.	Size 115,010 Pixel of oDlg

//Objeto BUTTON - Botões de ação
@085,100 BUTTON OemToAnsi('Confirma') SIZE 30,15 ACTION (btOk(cPedido,cNF,cCliente,cCidade,nPo),oDlg:End()) OF oDlg PIXEL
@085,140 BUTTON OemToAnsi('Cancelar') SIZE 30,15 ACTION (oDlg:End()) OF oDlg PIXEL

Activate MsDialog oDlg Centered
Return

*--------------------------------------------------------------------------------------*
Static Function btOk(cPedido,cNF,cCliente,cCidade,nPo)
*--------------------------------------------------------------------------------------*

//	Grava o Volume Imputado pela TELA
GravaVolume(cPedido,nPo)

Return

*--------------------------------------------------*
Static Function GravaVolume(cPedido,nPo)
*--------------------------------------------------*

DbSelectArea("SC5")
SC5->(DBSetOrder(1))
If SC5->(DBSeek(xFilial("SC5")+cPedido))
	RecLock("SC5",.F.)
	SC5->C5_P_PO	:= nPo
	SC5->( MsUnlock() )
	MsgInfo("Numero de P.O. Alterado!","HLB BRASIL")
Else
	MsgStop("Falha ao gravar o P.O.!")
EndIf

Return nPo