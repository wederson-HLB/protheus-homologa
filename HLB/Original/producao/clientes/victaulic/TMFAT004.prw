#INCLUDE "RWMAKE.CH"
#include 'topconn.ch'    
#include 'colors.ch'
#include "TOTVS.CH"

/*
Funcao      : TMFAT004
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para desempenhar o pedidos selecionados.
Autor     	: Renato Rezende
Data     	: 25/06/2014
TDN         : 
Módulo      : Faturamento.
Empresa		: Victaulic
*/
*----------------------*
User Function TMFAT004() 
*----------------------*
Local aStruSC9 		:= {}
Local aCpos    		:= {}
Local aButtons 		:= {} 
Local aColors  		:= {}
Local lInverte		:= .F.  
Local aSizFrm 		:= {}

Private lRetMain	:= .F.
Private cMarca 		:= GetMark()
Private cPerg		:= ""

//Verificando se está na empresa Victaulic
If !(cEmpAnt) $ "TM"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
EndIf

cPerg := "TMFAT4"

If Select("TempSC9") > 0
	TempSC9->(DbCloseArea())	               
EndIf  

aadd(aColors,{"Alltrim(TempSC9->cStatus)=='Liberado'","BR_AMARELO"}) 
aadd(aColors,{"Alltrim(TempSC9->cStatus)=='Picking Gerado'","BR_VERMELHO"}) 
aadd(aColors,{"Alltrim(TempSC9->cStatus)=='Bloqueado'","BR_PRETO"})

Aadd(aCpos, {"cDESEMP"  ,"",})  
Aadd(aCpos, {"C9_PEDIDO"   ,"","Pedido",}) 
Aadd(aCpos, {"cStatus"  ,"","Status",}) 
Aadd(aCpos, {"C9_PRODUTO","","Produto",})
Aadd(aCpos, {"C9_QTDLIB" ,"","Quantidade", })
Aadd(aCpos, {"C9_PRCVEN"  ,"","Unit. R$",})
Aadd(aCpos, {"C9_VALOR","","Total",})
Aadd(aCpos, {"C9_LOTECTL"   ,"","Lote",})		
Aadd(aCpos, {"C9_DTVALID","","Data Validade",})   
Aadd(aCpos, {"C9_CLIENTE","","Cliente",}) 
Aadd(aCpos, {"C9_LOJA","","Loja",}) 
                 
Aadd(aStruSC9, {"C9_FILIAL"   ,"C",2  ,0})            
Aadd(aStruSC9, {"cDESEMP"     ,"C",2  ,0})
Aadd(aStruSC9, {"cStatus"     ,"C",14 ,0})
Aadd(aStruSC9, {"C9_PEDIDO"   ,"C",6  ,0}) 
Aadd(aStruSC9, {"C9_ITEM"     ,"C",2  ,0})   
Aadd(aStruSC9, {"C9_PRODUTO"  ,"C",15 ,0})
Aadd(aStruSC9, {"C9_QTDLIB"   ,"N",9  ,2})  
Aadd(aStruSC9, {"C9_PRCVEN"   ,"N",12 ,2})
Aadd(aStruSC9, {"C9_VALOR"    ,"N",12 ,2})
Aadd(aStruSC9, {"C9_LOTECTL"  ,"C",10 ,0}) 
Aadd(aStruSC9, {"C9_DTVALID"  ,"C",8  ,0})  
Aadd(aStruSC9, {"C9_CLIENTE"  ,"C",6  ,0})  
Aadd(aStruSC9, {"C9_LOJA"     ,"C",2  ,0})         
   
cNome := CriaTrab(aStruSC9, .T.)                   
DbUseArea(.T.,"DBFCDX",cNome,'TempSC9',.F.,.F.)       
 	
If Select("C9QRY") > 0
	C9QRY->(DbCloseArea())	               
EndIf
    
BeginSql Alias 'C9QRY'
	SELECT *
 	FROM %Table:SC9%
    WHERE %notDel%
	  AND (C9_BLEST  = ' ' OR C9_BLEST	= '02')
	  AND C9_NFISCAL = ' '
	  AND C9_FILIAL = %exp:xFilial("SC9")% 
	ORDER BY C9_PEDIDO   
EndSql

C9QRY->(DbGoTop())
If !(C9QRY->(!BOF() .and. !EOF()))
	MsgStop("Não existe pedidos para desempenhar","HLB BRASIL")
	Return .F.
EndIf
    	
C9QRY->(DbGoTop())
While C9QRY->(!EOF())
	//Valida se a Tes atualiza estoque
	SC6->(DbGoTop(2))
  	If SC6->(DbSeek(xFilial("SC6")+C9QRY->C9_PEDIDO+C9QRY->C9_ITEM))	
    	//Verfica somente os que atualizam estoque    		
    	SF4->(DbSetOrder(1))
      	If SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES)) 
        	If SF4->F4_ESTOQUE <> "S"  
          		C9QRY->(DbSkip())
         		loop
            EndIf
       EndIf
	EndIf  
                 	
	RecLock("TempSC9",.T.)
	TempSC9->C9_FILIAL  := C9QRY->C9_FILIAL            
	TempSC9->C9_PEDIDO  := C9QRY->C9_PEDIDO
	TempSC9->C9_CLIENTE := C9QRY->C9_CLIENTE
	TempSC9->C9_LOJA    := C9QRY->C9_LOJA   
	TempSC9->C9_ITEM    := C9QRY->C9_ITEM 
	If 	Alltrim(C9QRY->C9_P_PICK)=="S"
		TempSC9->cStatus   :="Picking Gerado"	
	ElseIf Alltrim(C9QRY->C9_P_PICK)=="N" .OR. Empty(Alltrim(C9QRY->C9_P_PICK))
		TempSC9->cStatus   :="Liberado"
	EndIf
	If Alltrim(C9QRY->C9_BLEST)="02" 
	 	TempSC9->cStatus   :="Bloqueado" 	
	EndIf	
	TempSC9->C9_PRODUTO:= C9QRY->C9_PRODUTO 
	TempSC9->C9_QTDLIB := C9QRY->C9_QTDLIB 
	TempSC9->C9_PRCVEN := C9QRY->C9_PRCVEN 
	TempSC9->C9_VALOR  := C9QRY->C9_QTDLIB * C9QRY->C9_PRCVEN  
	TempSC9->C9_LOTECTL:= C9QRY->C9_LOTECTL   
	TempSC9->C9_DTVALID:= C9QRY->C9_DTVALID  
	TempSC9->C9_CLIENTE:= C9QRY->C9_CLIENTE   
	TempSC9->C9_LOJA   := C9QRY->C9_LOJA     		 
	TempSC9->(MsUnlock())
	C9QRY->(DbSkip())
EndDo    

aAdd(aButtons,{"Marcar", {|| MarcaTds("TempSC9")},"Marca/Desmarca Todos ","Marca/Desmarca Todos",{|| .T.}})

//Filtro
SetKey(VK_F12,{|| Filtro()} )

// Faz o calculo automatico de dimensoes de objetos  
aSizFrm := MsAdvSize()

TempSC9->(DbGoTop())
DEFINE MSDIALOG oDlg TITLE "Pedidos Liberados" From aSizFrm[7],0 To aSizFrm[6],aSizFrm[5] of oMainWnd PIXEL
	@ 010, 006 TO 035,(aSizFrm[5]/2)-5 LABEL "" OF oDlg PIXEL 
	@ 020, 015 Say  "SELECIONE APENAS OS PRODUTOS QUE SERÃO RETIRADOS DE LIBERAÇÃO E CONFIRME." COLOR CLR_HBLUE,CLR_WHITE PIXEL SIZE 500,6 OF oDlg

	oMarkPrd:= MsSelect():New("TempSC9","cDESEMP",,aCpos,@lInverte,@cMarca,{40,6,(aSizFrm[6]/2)-15,(aSizFrm[5]/2)-5},,,oDlg,,aColors) 
	oMarkPrd:bMark:= {|| Disp()}  
     	   
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,	{||	Processa({|| Desempenha()}),If(lRetMain,oDlg:End(),TempSC9->(DbGoTop()))},;
													{|| oDlg:End()},,aButtons),oMarkPrd:oBrowse:Refresh()) CENTERED   	    	

Return

/*
Funcao      : Filtro
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Tratamento de filtro para MsSelect.
Autor       : Renato Rezende
Data/Hora   : 27/06/14
*/
*---------------------------*
 Static Function Filtro()
*---------------------------*
Local cFiltro := ""
//Criando Pergunte 
CriaPerg()

//Inicializa as variaveis de pergunta.
IF !(Pergunte(cPerg,.T.,"Filtro de exibição"))
	Return .F.
EndIf
//mv_par01 == 1 - Liberado
//mv_par01 == 2 - Bloqueado
//mv_par01 == 3 - Picking Gerado
//mv_par01 == 4 - Todos
If mv_par01 == 1
	cFiltro := "Liberado"
ElseIf mv_par01 == 2
	cFiltro := "Bloqueado"
ElseIf mv_par01 == 3
	cFiltro := "Picking Gerado"
ElseIf mv_par01 == 4
	cFiltro := ""	
EndIf

If !Empty(Alltrim(cFiltro))
	bCondicao := {|| Alltrim(TempSC9->cStatus) == cFiltro}
	cCondicao := "Alltrim(TempSC9->cStatus) == '"+cFiltro+"'"
	DbSelectArea("TempSC9")
	DbSetFilter(bCondicao,cCondicao)
Else
	DBClearAllFilter()	
EndIf

//Atualiza
oMarkPrd:oBrowse:Refresh()

Return

/*
Funcao      : Disp
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Marcar/Desmarcar itens da tela.
Autor     	: Renato Rezende
Data     	: 27/06/2014
*/
*--------------------*
Static Function Disp() 
*--------------------*
RecLock("TempSC9",.F.)
If Alltrim(TempSC9->cStatus) == "Liberado" .OR. Alltrim(TempSC9->cStatus) == "Bloqueado"
	If Marked("cDESEMP")        
       TempSC9->cDESEMP := cMarca
	Else        
       TempSC9->cDESEMP := ""
	Endif
Else
	TempSC9->cDESEMP := ""            
Endif  
TempSC9->(MsUnlock())
oMarkPrd:oBrowse:Refresh()

Return

/*
Funcao      : MarcaTds
Parametros  : PAlias
Retorno     : Nenhum
Objetivos   : Marcar/Desmarcar todos os itens da tela.
Autor     	: Renato Rezende
Data     	: 25/06/2014
*/
*------------------------------*
Static Function MarcaTds(PAlias)
*------------------------------* 
DbSelectArea(PAlias)   
(PAlias)->(DbGoTop())  
While (PAlias)->(!EOF())
	If Alltrim(TempSC9->cStatus) == "Liberado" .OR. Alltrim(TempSC9->cStatus) == "Bloqueado"
		RecLock(PAlias,.F.)     
		If (PAlias)->cDESEMP == cMarca     		
			(PAlias)->cDESEMP:=Space(02)         		
		Else
			(PAlias)->cDESEMP:= cMarca       
		EndIf 
		(PAlias)->(MsUnlock())
	EndIf
	(PAlias)->(DbSkip())
EndDo      
(PAlias)->(DbGoTop())      
      
Return

/*
Funcao      : Desempenha
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Desempenhar os produtos do pedido
Autor     	: Renato Rezende
Data     	: 25/06/2014
*/
*--------------------------*
Static Function Desempenha()
*--------------------------*    
Local lMarcado := .F.
Local aCabPed    	:= {}
Local aLinPed    	:= {}
Local aItemsPed		:= {}
Local nOpcao		:= 0 //1 - Grava / 2 - Proxima Linha sem Gravar 
Local nRecCount		:= 0

Private lMsErroAuto	:= .F.

TempSC9->(DbGoTop()) 
While TempSC9->(!EOF()) 
	//Checa se marcou pelo menos um item.
	If !Empty(Alltrim(TempSC9->cDESEMP))
		lMarcado:=.T.
		nRecCount++
	EndIf
	TempSC9->(DbSkip()) 
EndDo

ProcRegua(nRecCount)

If !lMarcado
	MsgStop("Não foi selecionado nenhum item","HLB BRASIL")
	lRetMain := .F.
	Return .F.
Else
	TempSC9->(DbGoTop())
	While TempSC9->(!EOF())
		IncProc("Processando...")
	    //Valida se está marcado o produto
		If !Empty(Alltrim(TempSC9->cDESEMP))
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+TempSC9->C9_PEDIDO))
				//Adicionando cabeçalho do pedido
				aAdd(aCabPed,{"C5_NUM"		,SC5->C5_NUM	 	,Nil} )
				aAdd(aCabPed,{"C5_TIPO"		,SC5->C5_TIPO	 	,Nil} )
				aAdd(aCabPed,{"C5_CLIENTE"	,SC5->C5_CLIENTE	,Nil} )
				aAdd(aCabPed,{"C5_LOJACLI"	,SC5->C5_LOJACLI	,Nil} )
				aAdd(aCabPed,{"C5_CONDPAG"	,SC5->C5_CONDPAG	,Nil} )
	   	   		
	   	   		SC6->(DbSetOrder(1))
	   	   		//If SC6->(DbSeek(xFilial("SC6")+TempSC9->C9_PEDIDO+TempSC9->C9_ITEM+TempSC9->C9_PRODUTO))				
	   	   		If SC6->(DbSeek(xFilial("SC6")+TempSC9->C9_PEDIDO))
	   	   			While SC6->(!EOF()) .and.;
	   	   				SC6->C6_FILIAL = xFilial("SC6") .and.;
	   	   				SC6->C6_NUM = TempSC9->C9_PEDIDO
					    
						aLinPed := {}
					   
						aadd(aLinPed,{"LINPOS"		,"C6_ITEM"			,SC6->C6_ITEM})
					    aAdd(aLinPed,{"AUTDELETA"	,"N"	 			,Nil})
						aAdd(aLinPed,{"C6_PRODUTO"	,SC6->C6_PRODUTO	,Nil})
						aAdd(aLinPed,{"C6_QTDVEN"	,SC6->C6_QTDVEN		,Nil})
						aAdd(aLinPed,{"C6_PRCVEN"	,SC6->C6_PRCVEN		,Nil})
						aAdd(aLinPed,{"C6_PRUNIT"	,SC6->C6_PRUNIT		,Nil})
						aAdd(aLinPed,{"C6_VALOR"	,SC6->C6_VALOR	 	,Nil})
						aAdd(aLinPed,{"C6_TES"		,SC6->C6_TES	 	,Nil})
				   		aAdd(aLinPed,{"C6_QTDEMP"	,0				 	,Nil})
						If SC6->C6_ITEM == TempSC9->C9_ITEM .and. SC6->C6_PRODUTO == TempSC9->C9_PRODUTO
					   		aAdd(aLinPed,{"C6_QTDLIB"	,0					,Nil})
					 	Else
					 		aAdd(aLinPed,{"C6_QTDLIB"	,SC6->C6_QTDEMP		,Nil})
					 	EndIf						
						aAdd( aItemsPed,aLinPed )
						SC6->(DbSkip())
					EndDo
				EndIf
			EndIf
			//aAdd( aItemsPed,aLinPed )
			nOpcao	:= 1
		EndIf
		If Empty(Alltrim(TempSC9->cDESEMP))
			nOpcao := 2
			TempSC9->(DbSkip())
		EndIf	
		If nOpcao == 1 
			//Alterando o pedido de venda.
			MsExecAuto({|x,y,z| MATA410(x,y,z)},aCabPed,aItemsPed,4)
			//Limpando o Array para o proximo pedido selecionado
			aCabPed    	:= {}
			aLinPed    	:= {}
			aItemsPed	:= {}
			nOpcao 		:= 0

			//Proxima linha
			TempSC9->(DbSkip())
		EndIf 
	EndDo
	If lMSErroAuto           
		MostraErro()
		lRetMain := .F.
		Return .F.
	Else
		MsgInfo("Retirada a liberação com Sucesso!","HLB BRASIL")
	EndIf 
EndIf

lRetMain := .T.
Return .T.

/*
Funcao      : CriaPerg
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria o Pergunte no SX1
Autor     	: Renato Rezende  	 	
Data     	: 27/06/2014
*/
*------------------------*
Static Function CriaPerg()
*------------------------*
U_PUTSX1(cPerg, "01", "Status ?",      "Status ?",         	"Status ?",       "mv_ch1","N",01,0,0, "C","","",	"","","mv_par01","Liberado","Liberado","Liberado","","Bloqueado","Bloqueado","Bloqueado","Picking Gerado","Picking Gerado","Picking Gerado","Todos","Todos","Todos","","","",{},{},{},"")
Return
