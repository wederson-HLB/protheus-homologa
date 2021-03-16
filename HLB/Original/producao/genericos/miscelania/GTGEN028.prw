#Include 'Protheus.ch'
#INCLUDE "FWBROWSE.CH"
#include 'fileio.ch'
/*
Funcao      : GTGEN028
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Manutenção de Menus.
Autor       : Jean Victor Rocha
Data/Hora   : 22/04/2014
*/
*----------------------*
User Function GTGEN028()
*----------------------*
Return Processa({|| MainGT() },"Processando aguarde...")

*----------------------*
Static Function MainGT()
*----------------------*
Private oDlg
Private oLayer	:= FWLayer():new()
Private aSize 	:= MsAdvSize()

Private oSelS	:= LoadBitmap( nil, "LBOK")
Private oSelN	:= LoadBitmap( nil, "LBNO")

oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL - Manutenção de Menus",,,.F.,,,,,,.T.,,,.T. )

oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',25,.F.,'1')
oLayer:addCollumn('3',10,.F.,'1')
oLayer:addCollumn('2',65,.F.,'1')

oLayer:addWindow('1','Win11','Opções'					,015,.F.,.T.,{||  },'1',{|| })
oLayer:addWindow('1','Win12','Menus'					,085,.F.,.T.,{||  },'1',{|| })

oLayer:addWindow('3','Win31','Tabelas'					,100,.F.,.T.,{||  },'1',{|| })

oLayer:addWindow('2','Win21','Menu:'					,070,.T.,.F.,{|| RefreshSize()},'1',{|| })
oLayer:addWindow('2','Win22','Console'	   				,030,.T.,.F.,{|| RefreshSize()},'1',{|| })

//Definição das janelas para objeto.
oWin11 := oLayer:getWinPanel('1','Win11','1')
oWin12 := oLayer:getWinPanel('1','Win12','1')

oWin31 := oLayer:getWinPanel('3','Win31','1')

oWin21 := oLayer:getWinPanel('2','Win21','1')
oWin22 := oLayer:getWinPanel('2','Win22','1')

//Opções
aItens1	:= {'1=Retirar Tags <Tables>'}
cCombo1	:= aItens1[1]

oBtn1 := TBtnBmp2():New(02,008,26,26,'FINAL'   	,,,,{|| oDlg:end()												}, oWin11,"Sair"			,,.T.)
oBtn2 := TBtnBmp2():New(02,050,26,26,'SELECTALL' ,,,,{|| MarcaButton()												}, oWin11,"Marca Todos"	,,.T.)
oBtn3 := TBtnBmp2():New(02,105,26,26,'ENGRENAGEM',,,,{|| Processa({|| IIF(MSGYESNO("Confirma a Execução?"),AtuMenu(),.F.)},"Aguarde...")}, oWin11,"Processa",,.T.)
oCombo1:= tComboBox():New(02,070,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItens1,70,20,oWin11,,{||},,,,.T.,,,,,,,,,'cCombo1')

//Menus
aHeader := {}
aCols	:= {}
AADD(aHeader,{ TRIM("Sel.")			,"SEL"	,"@BMP",02,0,"","","C","",""})
AADD(aHeader,{ TRIM("Menu")			,"MENU","@!  ",30,0,"","","C","",""})
aAlter	:= {"SEL"}
aArquivos := DIRECTORY("SYSTEM\*.XNU","D")//Adiciona o nome dos arquivos encontrados.
For i:=1 to len(aArquivos)
	aAdd(aCols, {oSelN,aArquivos[i][1],.F.})
Next i
oGetDados := MsNewGetDados():New(01,01,(oWin12:NHEIGHT/2)-2,(oWin12:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAlter,,999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin12,aHeader, aCols, {|| MudaLinha()})
oGetDados:AddAction("SEL", {|| MudaStatus(@oGetDados),;
									oGetDados:Obrowse:ColPos -= 1 })
oGetDados:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetDados:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetDados:ForceRefresh()

//Tabelas
aHeaderTab := {}
aColsTab	:= {}
AADD(aHeaderTab,{ TRIM("Sel.")			,"SEL"	,"@BMP",02,0,"","","C","",""})
AADD(aHeaderTab,{ TRIM("Menu")			,"MENU","@!  ",03,0,"","","C","",""})
aAlterTab	:= {"SEL"}

SX2->(DbSetOrder(1))
SX2->(DbGoTop())
While SX2->(!EOF())
	aAdd(aColsTab, {oSelN,SX2->X2_CHAVE,.F.})
	SX2->(DbSkip())
EndDo

oGetDadosTab := MsNewGetDados():New(01,01,(oWin31:NHEIGHT/2)-2,(oWin31:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAlterTab,,999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin31,aHeaderTab, aColsTab, {|| })
oGetDadosTab:AddAction("SEL", {|| MudaStatus(@oGetDadosTab),;
									oGetDadosTab:Obrowse:ColPos -= 1 })
oGetDadosTab:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetDadosTab:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetDadosTab:ForceRefresh()

//Vizualização -------------------------------------------------------------
cMenu := ""
oMenu := tMultiget():New(01,01,{|u|if(Pcount()>0,cMenu:=u,cMenu)},oWin21,(oWin21:NRIGHT/2)-4,(oWin21:NHEIGHT/2)-2,,,,,,.T.)

//Console ------------------------------------------------------------------
cConsole := ""
oConsole := tMultiget():New(01,01,{|u|if(Pcount()>0,cConsole:=u,cConsole)},oWin22,(oWin22:NRIGHT/2)-4,(oWin22:NHEIGHT/2)-2,,,,,,.T.)


oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao      : RefreshSize()
Parametros  : 
Retorno     : 
Objetivos   : Atualiza o tamanho dos itens dentro da janela de acordo com o tamanho da Window.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*---------------------------*
Static Function RefreshSize()
*---------------------------*
oMenu:nHeight		:= (oWin21:NHEIGHT)-2
oConsole:nHeight	:= (oWin22:NHEIGHT)-2
Return .T.

/*
Funcao	    : MarcaButton()
Parametros  : 
Retorno     : 
Objetivos   : Marca e Desmarca Todas as integrações.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*---------------------------*
Static function MarcaButton()
*---------------------------*
Local i
Local oSelBtn

If UPPER(LEFT(oBtn2:CTOOLTIP,3)) == "MAR"
	oBtn2:CTOOLTIP := "Desmarca Todos"
	oBtn2:LoadBitmaps("UNSELECTALL")
	oSelBtn := oSelS
Else
	oBtn2:CTOOLTIP := "Marca Todos"
	oBtn2:LoadBitmaps("SELECTALL")
	oSelBtn := oSelN
EndIf

For i:=1 to len(oGetDados:aCols) 
	oGetDados:aCols[i][1] := oSelBtn
Next i

oGetDados:ForceRefresh()

Return .T.

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*--------------------------*
Static Function MudaStatus(oGetDados)
*--------------------------*
Local cArqConte := oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]

If oSelS == cArqConte
	cArqConte := oSelN
Else 
	cArqConte := oSelS
Endif

oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos] := cArqConte
oGetDados:ForceRefresh()

Return(cArqConte)

/*
Funcao	    : MudaLinha()
Parametros  : 
Retorno     : 
Objetivos   : Atualiza o Browse de acordo com o Layout posicionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-------------------------*
Static function MudaLinha()
*-------------------------*
Local nHandle := 0
Local cArquivo := oGetDados:aCols[oGetDados:Obrowse:nAt][2]

If File(cArquivo)
	nHandle	:= fopen(cArquivo,FO_READWRITE)
	cMenu 		:= FReadStr(nHandle,999999)
	fclose(nHandle)	
Else
	cMenu		:=  "ARQUIVO '"+cArquivo+"' NAO ENCONTRADO!"
	cConsole	+= "[ERRO] ARQUIVO '"+cArquivo+"' NAO ENCONTRADO!"+CHR(13)+CHR(10)
EndIf

//Atualiza o Menu --------------------------------------------
EVAL(oMenu:BSETGET)
oMenu:SetFocus()

//Atualiza o Console -----------------------------------------
EVAL(oConsole:BSETGET)
oConsole:SetFocus()

Return .T.

/*
Funcao	    : AtuMenu()
Parametros  : 
Retorno     : 
Objetivos   : Atualiza os menus selecionados
Autor       : Jean Victor Rocha 
Data/Hora   : 23/04/2014
*/
*-----------------------*
Static function AtuMenu()
*-----------------------*
Local i
Local cArqOri := ""
Local cArqNew := ""
Local nHdlNew := 0
Local lOkMenu := .F. 
Local lOkTab := .F.

For i:=1 to Len(oGetDados:aCols)
	If oGetDados:aCols[i][1] == oSelS
		lOkMenu := .T.
		Exit
	EndIf
Next i            
If !lOkMenu
	MsgInfo("Não foi selecionado nenhum Menu!","HLB BRASIL")
	Return .T.
EndIf

For i:=1 to Len(oGetDadosTab:aCols) 
	If oGetDados:aCols[i][1] == oSelS
		lOkTab := .T.
		Exit
	EndIf
Next i
If !lOkMenu
	MsgInfo("Não foi selecionado nenhuma Tabela!","HLB BRASIL")
	Return .T.
EndIf  

ProcRegua(len(oGetDados:aCols)*2)

For i:=1 to len(oGetDados:aCols)
	IncProc("Atualizando Arquivo...")
	If oGetDados:aCols[i][1] == oSelS
		If File(oGetDados:aCols[i][2])
			//Cria o novo arquivo
			nHdlNew := FCREATE(oGetDados:aCols[i][2]+"_NEW",FC_NORMAL)
			
			//Atualiza o novo Arquivo
			FT_FUse(oGetDados:aCols[i][2]) // Abre o arquivo
			FT_FGOTOP()      // Posiciona no inicio do arquivo
			While !FT_FEof()
				cLinha	:= FT_FReadln()        // Le a linha
				cTag	:= ALLTRIM(UPPER( SubStr(aItens1[VAL(cCombo1)],AT("<",aItens1[VAL(cCombo1)]),50)))
				If !(AT(cTag,UPPER(cLinha)) <> 0 .and. AT("</"+SUBSTR(cTag,2,50),UPPER(cLinha)) <> 0)//Retira as tags na mesma linha
					FWRITE(nHdlNew, cLinha+CHR(13)+CHR(10))
				ElseIf aScan(oGetDadosTAB:aCols, {|x| ALLTRIM(UPPER(x[2])) == ALLTRIM(UPPER(SUBSTR(cLinha,AT(cTag,UPPER(cLinha))+8,3))) .and. x[1] == oSelS }) == 0
					FWRITE(nHdlNew, cLinha+CHR(13)+CHR(10))
				EndIf			
				FT_FSkip() // Proxima linha
	    	Enddo
	    	FT_FUse()
			fclose(nHdlNew)
	    	
	    	cArqBkp := oGetDados:aCols[i][2]+"_"+DTOS(Date())+"_"+STRTRAN(TIME(),":","")
	    	FRename(oGetDados:aCols[i][2],cArqBkp)//Renomeia o Arquivo Atual.
	    	FRename(oGetDados:aCols[i][2]+"_NEW",oGetDados:aCols[i][2])//Renomeia o Novo arquivo.
	    	
	    	//Cria Backup do Atual
	    	IncProc("Efetuando Backup...")
			compacta(cArqBkp,"BKP_XNU_GTGEN028.RAR")
			cConsole	+= "ARQUIVO '"+oGetDados:aCols[i][2]+"' Atualizado!"+CHR(13)+CHR(10)
		Else
			IncProc("Gravando Log...")
			cConsole	+= "[ERRO] ARQUIVO '"+oGetDados:aCols[i][2]+"' NAO ENCONTRADO PARA ATUALIZACAO!"+CHR(13)+CHR(10)
		EndIf
	Else
		IncProc("...")
	EndIf
Next i

MudaLinha()

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar o arquivo(boleto html)
Autor       : 
Data/Hora   : 
*/
*----------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*----------------------------------------*
Local lRet			:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+'\SYSTEM\'+cArqRar+'" "'+cRootPath+'\SYSTEM\'+cArquivo+'"'
Local lWait		:= .T.
Local cPath		:= "C:\Program Files (x86)\WinRAR\"

Return WaitRunSrv( cCommand , lWait , cPath )