#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
/*
Funcao      : GTGEN026
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Integra��o APDATA
Autor       : Jean Victor Rocha
Data/Hora   : 27/03/2014
*/
*----------------------*
User Function GTGEN026()
*----------------------*                                             
Return Processa({|| MainGT() },"Processando aguarde...")

*----------------------*
Static Function MainGT()
*----------------------*
Private oDlg
Private oLayer	:= FWLayer():new()
Private aSize 	:= MsAdvSize()

Private aLegenda := {{"BR_VERDE"	,"Integra��o Disponivel."},;
						{"BR_LARANJA"	,"Integra��o Disponivel com Alertas."},;
			   		  	{"BR_VERMELHO"	,"Integra��o Possui Erros, consulte o console."},;
						{"BR_BRANCO"	,"Sem dados para gera��o de Arquivo."},;
			   		  	{"BR_PRETO"		,"Integra��o Inativa."}}

Private oSelS	:= LoadBitmap( nil, "LBOK")
Private oSelN	:= LoadBitmap( nil, "LBNO") 
Private oStsok	:= LoadBitmap( nil, "BR_VERDE")
Private oStsAl	:= LoadBitmap( nil, "BR_LARANJA")
Private oStsEr	:= LoadBitmap( nil, "BR_VERMELHO")
Private oStsBr	:= LoadBitmap( nil, "BR_BRANCO")
Private oStsIn	:= LoadBitmap( nil, "BR_PRETO")

Private cDirArq := GETTEMPPATH()+"GPE2APDATA\"

Private aCodInt := {'41' ,'42' ,'43' ,'44' ,'45' ,'46' ,'47' ,'48' ,'49' ,'410',;
					'411','412','413','414','415','416','417','418','419','420',;
					'421','422','423','424','425','426','427','428','429'}
//Cria��o dos Arrays de Defini��es de layout
For i:=1 to Len(aCodInt)
	&("a"+aCodInt[i]) := GetCodInt(aCodInt[i])
Next i
//Cria��o das Variaveis de Console
For i:=1 to len(aCodInt)
	&("cCons"+aCodInt[i]) := ""
Next i

oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL - Integra��o APDATA",,,.F.,,,,,,.T.,,,.T. )

oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',25,.F.,'1')
oLayer:addCollumn('2',75,.F.,'1')

oLayer:addWindow('1','Win11','Menu'					,015,.F.,.T.,{||  },'1',{|| })
oLayer:addWindow('1','Win12','Tipos de Integra��es'	,085,.F.,.T.,{||  },'1',{|| })
oLayer:addWindow('2','Win21','Vizualiza��o'			,070,.T.,.F.,{|| RefreshSize()},'1',{|| })
oLayer:addWindow('2','Win22','Console'	   				,030,.T.,.F.,{|| RefreshSize()},'1',{|| })

//Defini��o das janelas para objeto.
oWin11 := oLayer:getWinPanel('1','Win11','1')
oWin12 := oLayer:getWinPanel('1','Win12','1')
oWin21 := oLayer:getWinPanel('2','Win21','1')
oWin22 := oLayer:getWinPanel('2','Win22','1')

//Menu -----------------------------------------------------------------------------
oBtn1 := TBtnBmp2():New(02,010,26,26,'FINAL'   	   		,,,,{|| oDlg:end()}			, oWin11,"Sair"					,,.T.)
oBtn2 := TBtnBmp2():New(02,052,26,26,'SELECTALL'  		,,,,{|| MarcaButton()}		, oWin11,"Marca Todos"			,,.T.)
oBtn3 := TBtnBmp2():New(02,094,26,26,'DEVOLNF'	  		,,,,{|| Processa({|| LoadDados() },"Processando aguarde...")}	, oWin11,"Reprocessa Marcados"	,,.T.)
oBtn6 := TBtnBmp2():New(02,0136,26,26,'OPEN'   	  		,,,,{|| GetDir()}  			, oWin11,"Diretorio" 			,,.T.)
oBtn7 := TBtnBmp2():New(02,0178,26,26,'AVGARMAZEM'		,,,,{|| GeraArqPasta()}		, oWin11,"Gerar Arquivos"		,,.T.)
oBtn8 := TBtnBmp2():New(02,0220,26,26,'UPDINFORMATION'	,,,,{|| IntHelp()}	  		, oWin11,"Ajuda"	 			,,.T.)

//Tipos de Integra��es -------------------------------------------------------------
aHeader := {}
aCols	:= {}

AADD(aHeader,{ TRIM("Sel.")			,"SEL","@BMP",02,0,"","","C","",""})
AADD(aHeader,{ TRIM("Sts.")			,"STS","@BMP",02,0,"","","C","",""})
AADD(aHeader,{ TRIM("Integra��o")	,"DES","@!  ",40,0,"","","C","",""})
AADD(aHeader,{ TRIM("Arq.Dest.")	,"ARQ","@!  ",30,0,"","","C","",""})

aAlter	:= {"SEL","STS"}

aAdd(aCols, {oSelN,oStsBr,"4.1  Bancos"									,"Bancos.txt"						,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.2  Ag�ncias Banc�rias"						,"AgenciasBanco.txt"				,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.3  CBO"										,"CBO.txt"							,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.4  Cargos"									,"Cargos.txt"						,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.5  Centros de Custo"							,"CentrosCusto.txt"				,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.6  Hor�rios"									,"Horarios.txt"					,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.7  Sindicato"			   						,"Sindicatos.txt"					,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.8  Verbas"			   	   					,"Verbas.txt"	   					,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.9  Meios de transportes"  					,"MeiosTransportes.txt"			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.10 Tipos de Beneficios"   					,"TiposBeneficios.txt"			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.11 Empresas de Beneficios"					,"EmpresasBeneficios.txt"		,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.12 Empresas de Institui��es de Ensino"	,"EmpresasEnsino.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.13 Empresas"			   						,"Empresas.txt"					,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.14 Locais"			   						,"Locais.txt"						,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.15 Contratados"			  					,"Contratados.txt"				,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.16 Dependentes"			   					,"ConDependentes.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.17 Hist�rico de Sal�rios" 					,"ConGradesSalarios.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.18 Hist�rico de Cargos"	   					,"ConGradesCargos.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.19 Hist�rico de Centros de Custo"	 		,"ConGradesCentrosCusto.txt"	,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.20 Hist�rico de F�rias"	   		  			,"ConPeriodosDescansos.txt"		,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.21 Hist�rico de Afastamentos"		  		,"ConAfastamentos.txt" 			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.22 Hist�rico de Contribui��es Sindicais"	,"ConSindicais.txt"	   			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.23 Hist�rico de Transfer�ncias"   			,"ConTransferencias.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.24 Pensionistas"				   				,"ConPensionistas.txt" 			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.25 Contratados - Vale Transporte" 			,"ConValesTransportes.txt"		,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.26 Contratados - Benef�cios"	   			,"ConBeneficios.txt"	   			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.27 Dependentes - Benef�cios"  	   			,"ConDependentesBeneficios.txt"	,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.28 Contratados - Estabilidades"   			,"ConEstabilidades.txt"	   		,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.29 Ficha Financeira"							,"ConFichaFinanceira.txt"		,.F.})

oGetDados := MsNewGetDados():New(01,01,(oWin12:NHEIGHT/2)-2,(oWin12:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAlter,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin12,aHeader, aCols, {|| MudaLinha()})

oGetDados:AddAction("SEL", {|| MudaStatus()})
oGetDados:AddAction("STS", {|| BrwLegenda("Tipos de Integra��es", "Legenda", aLegenda),;
							oGetDados:Obrowse:ColPos -= 1,;
							oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos+1] })
oGetDados:LCANEDITLINE	:= .F.//n�o possibilita troca de tipo de edi��o.
oGetDados:LEDITLINE		:= .F.//N�o abre linha de edi��o de linha quando clicar na linha.
oGetDados:ForceRefresh()

//Vizualiza��o -------------------------------------------------------------

oBtn4 := TBtnBmp2():New(02,008,26,26,'PGPREV' ,,,,{|| BRWLayout()}	, oWin21,"Ocultar"				,,.T.)
oBtn5 := TBtnBmp2():New(02,210,26,26,'VERNOTA',,,,{|| ViewArq()}	, oWin21,"Vizualizar arquivo"   ,,.T.)

aHLayout := {}
aCLayout := {}
aALayout := {}

AADD(aHLayout,{ TRIM("Campo")  		,"CAMPO","@!",25,0,"","","C","",""})
AADD(aHLayout,{ TRIM("For.")	  	,"FORMA","@!",01,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Tam.")		,"TAMAN","@!",03,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Conteudo")	,"CONTE","@!",50,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Observa��o")	,"OBSER","@!",60,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Obr.")		,"OBRIG","@!",03,0,"","","C","",""})

oLayout := MsNewGetDados():New(020,01,(oWin21:NHEIGHT/2)-2,(((oWin21:NRIGHT/2)-2)/4),GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aALayout,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin21,aHLayout, aCLayout)

oLayout:LCANEDITLINE	:= .F.//n�o possibilita troca de tipod e edi��o.
oLayout:LEDITLINE		:= .F.//N�o abre edi��o quando clicar na linha.
oLayout:ForceRefresh()

For i:=1 to Len(aCodInt)
	aAux := GetCodInt(aCodInt[i])
	&("aHArq"+aCodInt[i]) := {}
	&("aCArq"+aCodInt[i]) := {}
	&("aAArq"+aCodInt[i]) := {}

	For j:=1 to len(aAux)
		If aAux[j][3] == "A"
			cTipo := "C"
		Else
			cTipo := aAux[j][2]
		EndIf
		//AADD(&("aHArq"+aCodInt[i]),{TRIM(aAux[j][1]),ALLTRIM(STR(j)),"@!",IIF(AT("+",aAux[j][3])<>0,&(aAux[j][3]),VAL(aAux[j][3])),0,"","","C","",""})
		AADD(	&("aHArq"+aCodInt[i]),;
					{TRIM(aAux[j][1]),;
					"HEADER"+"_"+aCodInt[i]+"_"+ALLTRIM(STR(j)),;
					IIF(cTipo=="C","@!",""),;
					VAL(IIF(AT(",",aAux[j][3])<>0,SUBSTR(aAux[j][3],1					,AT(",",aAux[j][3])-1),aAux[j][3]	)),;
					VAL(IIF(AT(",",aAux[j][3])<>0,SUBSTR(aAux[j][3],AT(",",aAux[j][3])+1	,Len(aAux[j][3]   )),"0"		)),;
					"",;
					"",;
					cTipo,;
					"",;
					""})
	Next j

	//Inicia aCols com linha em branco
	aAdd(&("aCArq"+aCodInt[i]),Array(Len(&("aHArq"+aCodInt[i]))+1))
	&("aCArq"+aCodInt[i])[1][LEN(&("aCArq"+aCodInt[i])[1])] := .F.

	&("oArq"+aCodInt[i]):=MsNewGetDados():New(01,(((oWin21:NRIGHT/2))/4)+2,(oWin21:NHEIGHT/2)-2,(oWin21:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
										"", &("aAArq"+aCodInt[i]),,9999999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()",;
										oWin21,&("aHArq"+aCodInt[i]), &("aCArq"+aCodInt[i]))
	
	&("oArq"+aCodInt[i]):LCANEDITLINE	:= .F.//n�o possibilita troca de tipo de edi��o.
	&("oArq"+aCodInt[i]):LEDITLINE		:= .F.//N�o abre edi��o quando clicar na linha.

	&("oArq"+aCodInt[i]):OBROWSE:LVISIBLECONTROL := .F.
	&("oArq"+aCodInt[i]):ForceRefresh()

	cArqView := ""
	oArqView := tMultiget():New(01,(((oWin21:NRIGHT/2))/4)+2,{|u|if(Pcount()>0,cArqView:=u,cArqView)},;
				oWin21,(oWin21:NRIGHT/2)-2,(oWin21:NHEIGHT/2)-2,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
	oArqView:LVISIBLECONTROL := .F.

Next i

//Console ------------------------------------------------------------------
cConsole := ""
oConsole := tMultiget():New(01,01,{|u|if(Pcount()>0,cConsole:=u,cConsole)},oWin22,(oWin22:NRIGHT/2)-4,(oWin22:NHEIGHT/2)-2,,,,,,.T.)

//Carrega Informa��es
//LoadDados(.T.)

oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao	    : ViewArq
Parametros  : 
Retorno     : 
Objetivos   : Fun��o para Visualizar o arquivo como ira ficar.
Autor       : Jean Victor Rocha
Data/Hora   : 10/04/2014
*/
*-------------------------*
Static function ViewArq()
*-------------------------*
If oGetDados:ACOLS[oGetDados:NAT][2] <> oStsBr .and. !oArqView:LVISIBLECONTROL
	Processa({|| cArqView := GeraArquivo(&("oArq"+aCodInt[oGetDados:NAT]):ACOLS,.F.,oGetDados:aCols[oGetDados:NAT][4])  },"")
Else
	cArqView := "ATEN��O: N�o ser� gerado este arquivo, sem dados!"
EndIf

//Atualiza a Visualiza��o -----------------------------------------
EVAL(oArqView:BSETGET)
oArqView:SetFocus()

oArqView:LVISIBLECONTROL := !oArqView:LVISIBLECONTROL 
&("oArq"+aCodInt[oGetDados:NAT]):OBROWSE:LVISIBLECONTROL := !&("oArq"+aCodInt[oGetDados:NAT]):OBROWSE:LVISIBLECONTROL
Return .T.

/*
Funcao	    : GeraArqPasta()
Parametros  : 
Retorno     : 
Objetivos   : Gera arquivos Fisicos na pasta.
Autor       : Jean Victor Rocha
Data/Hora   : 10/04/2014
*/
*----------------------------*
Static function GeraArqPasta() 
*----------------------------*
Local i
Local lExec := .F.
Local lErro := .F.

For i:=1 to Len(oGetDados:aCols)
	If oGetDados:aCols[i][1] == oSelS
		lExec := .T.
	EndIf
	If oGetDados:aCols[i][2] == oStsIn	
		lErro := .T.
	EndIf
Next i

If !lExec
	Alert("Nenhuma integra��o selecionada!","HLB BRASIL")
	Return .T.
EndIf

If !lErro .and. !MsgYesNo("Existe integra��o Selecionada com erro, Deseja Continuar Assim Mesmo?","HLB BRASIL")
	Return .T.
EndIf

If !File(LEFT(cDirArq,LEN(cDirArq)-1))
	If cDirArq == GETTEMPPATH()+"GPE2APDATA\"
		MakeDir(LEFT(cDirArq,LEN(cDirArq)-1))
		If !File(LEFT(cDirArq,LEN(cDirArq)-1))
   			Alert("N�o Foi possivel criar o Diretorio padr�o '"+cDirArq+"', opera��o abortada!","HLB BRASIL")
	   		Return .T.
		EndIf
	Else
		Alert("Diretorio n�o encontrado '"+cDirArq+"', opera��o abortada!","HLB BRASIL")
		Return .T.
	EndIf
EndIf

For i:=1 to Len(oGetDados:aCols)
	If oGetDados:aCols[i][1] == oSelS
		//GeraArquivo(&("oArq"+aCodInt[i]):ACOLS,.T.,oGetDados:aCols[i][4])
		Processa({|| GeraArquivo(&("oArq"+aCodInt[i]):ACOLS,.T.,oGetDados:aCols[i][4])  },"")
	EndIf
Next i

If MsgYesNo("Arquivos gerados no diretorio selecionado: '"+cDirArq+"', Deseja Abrir a Pasta?","HLB BRASIL")
	winexec("explorer.exe "+cDirArq)
EndIf

Return .T.

/*
Funcao	    : GeraArquivo()
Parametros  : 
Retorno     : 
Objetivos   : Fun��o Responsavel pela gera�a� do arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 10/04/2014
*/
*----------------------------------------------------*
Static function GeraArquivo(aDados,lArqFisico,cArqTXT)
*----------------------------------------------------*
Local cRet := ""
Local cAux := ""
Local i,j
Local nPosInt	:= aScan(oGetDados:aCols,{|x| UPPER(ALLTRIM(x[4])) == UPPER(ALLTRIM(cArqTXT))  })
Local aAux		:= {}

Private nHdl

Default cArqTXT := ""

If oGetDados:aCols[nPosInt][2] == oStsBr
	Return cRet
EndIf

If lArqFisico
	If FILE(cDirArq+cArqTXT)
		FERASE(cDirArq+cArqTXT)
	EndIf
	If Len(aDados) <> 0
		nHdl := FCREATE(cDirArq+cArqTXT,0 )	//Cria��o do Arquivo .
		FWRITE(nHdl, cRet ) 	   			// Grava��o do seu Conteudo.
		fclose(nHdl)						// Fecha o Arquivo que foi Gerado	
	EndIf
EndIf

procRegua(IIF(!lArqFisico .And. Len(aDados)>5000,5000,Len(aDados)))

cRet := ""

For i:=1 to Len(aDados)
	IncProc(aCodInt[nPosInt]+" - Aguarde...")
	cAux := ""
	For j:=1 to Len(aDados[i])-1//nao executa para o deletado
		aAux := &("a"+aCodInt[nPosInt])
		
		IF AT(",",aAux[j][3]) <> 0
			nTam := VAL(SubStr(aAux[j][3],1,AT(",",aAux[j][3])-1))
			nDec := VAL(SubStr(aAux[j][3],AT(",",aAux[j][3])+1,50))
		Else
			nTam := VAL(aAux[j][3])
			nDec := 0
		EndIf

		If !EMPTY(aDados[i][j])
			If VALTYPE(aDados[i][j]) == "N"
				cAux += ALLTRIM(TRANSFORM(aDados[i][j], "@R 9999999999999999999999"))
			Else
				cAux += ALLTRIM(aDados[i][j])
			EndIf
		ElseIf nTam <> 0
			If aAux[j][2] == "A"
				cAux += '""'
			ElseIf aAux[j][2] == "D"
				cAux += '  /  /    '
			ElseIf aAux[j][2] == "N"
				cPic := "@R "+REPLICATE("9",nTam)
				If nDec <> 0
					cPic += ","+REPLICATE("9",nDec)
				EndIf
				cAux += TRANSFORM(REPLICATE("0",nTam+nDec), cPic)
			EndIf
		EndIf
		cAux += ";"		
	Next j
	cAux := LEFT(cAux,LEN(cAux)-1)//Retira ultimo ponto e virgula.
	cAux += CHR(13)+CHR(10)

	cRet += cAux
    If lArqFisico
		//Zera Variavel
		If Len(cRet) >= 500000
			cRet := GrvInfo(cRet,cDirArq,cArqTXT)
		EndIf 
	Else
		If Len(cRet) >= 500000
	    	Return cRet +CHR(13)+CHR(10) + "==============ARQUIVO MODELO ENCERRADO ANTECIPADAMENTE DEVIDO AO TAMANHO================="
	    EndIf
	EndIf
Next i

If !EMPTY(cRet)
	GrvInfo(cRet,cDirArq,cArqTXT)
EndIf

If !lArqFisico
	cArqView := cRet
EndIf

Return cRet

/*
Funcao	    : BRWLayout()
Parametros  : 
Retorno     : 
Objetivos   : Fun��o para tratamento de esconder e exibir o layout
Autor       : Jean Victor Rocha
Data/Hora   : 10/04/2014
*/
*-------------------------*
Static function BRWLayout()
*-------------------------*
Local i

If UPPER(LEFT(oBtn4:CTOOLTIP,3)) == "OCU"
	oBtn4:CTOOLTIP := "Exibe"
	oBtn4:LoadBitmaps("PGNEXT")

	oLayout:oBrowse:nRight := 072
	oLayout:ForceRefresh()
	
	oBtn5:NLEFT := 40
Else
	oBtn4:CTOOLTIP := "Ocultar"
	oBtn4:LoadBitmaps("PGPREV")
	
	oLayout:oBrowse:nRight := ((oWin21:NRIGHT/4)-2)
	oLayout:ForceRefresh()
	
	oBtn5:NLEFT := 210
EndIf

For i:=1 to Len(aCodInt)
	&("oArq"+aCodInt[i]):oBrowse:nLeft := oLayout:oBrowse:nRight+2
	&("oArq"+aCodInt[i]):oBrowse:nRight:= oWin21:NRIGHT-5
  	&("oArq"+aCodInt[i]):ForceRefresh()
Next i

//Atualiza a Visualiza��o do arquivo
oArqView:nLeft := &("oArq"+aCodInt[1]):oBrowse:nLeft
oArqView:nRight := &("oArq"+aCodInt[1]):oBrowse:nRight 
oArqView:nHeight := &("oArq"+aCodInt[1]):oBrowse:nHeight

Return .T.

/*
Funcao	    : LoadDados()
Parametros  : 
Retorno     : 
Objetivos   : Carrega as informa��es dos arquivos a serem exportadas, e executa valida��o.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static function LoadDados(lProcAll)
*---------------------------------*
Local i
Local aArqProc := {}
Local lMarcOK  := .F.

Default lProcAll := .F.

For i:=1 to Len(oGetDados:aCols)
	If oGetDados:aCols[i][1] == oSelS
		lMarcOK := .T.
	EndIf
Next i


If !lProcAll 
	If lMarcOK 
		If !MsgYesNo("Deseja Reprocessar as integra��es marcadas?","HLB BRASIL")
			Return .F.
		EndIf
	Else
		Alert("Necessario selecionar no minimo uma integra��o.","HLB BRASIL")
		Return .F.
	EndIf
EndIf

ProcRegua(Len(aCodInt))

For i:=1 to len(aCodInt)
	IncProc(oGetDados:aCols[i][3])
	If IIF(lProcAll,lProcAll,oGetDados:aCols[i][1] == oSelS)
		If oGetDados:aCols[i][2] == oStsIn
			&("cCons"+aCodInt[i]) := "[INATIVO] Integra��o Inativa, n�o ser� possivel a sele��o/gera��o de arquivo de exporta��o."
		Else
			aArqProc := GetInfoInt(aCodInt[i])
			
			If Len(aArqProc[1]) <> 0
				&("oArq" +aCodInt[i]):aCols	:= aArqProc[1]
				&("oArq" +aCodInt[i]):ForceRefresh()
			EndIf
			
			&("cCons"+aCodInt[i])	:= aArqProc[2]
			If AT("[ERRO]",&("cCons"+aCodInt[i])) <> 0
				oGetDados:aCols[i][2] := oStsEr
			ElseIf AT("[ALERTA]",&("cCons"+aCodInt[i])) <> 0
				oGetDados:aCols[i][2] := oStsAl
			Else
				oGetDados:aCols[i][2] := oStsok
			EndIf
			If Len(aArqProc[1])== 0
				oGetDados:aCols[i][2] := oStsBr
				&("cCons"+aCodInt[i]) += "[VAZIO] Arquivo sem dados a serem impressos."+CHR(13)+CHR(10)
			Endif
		EndIf
	EndIf
Next i

Return .T.

Return {aRet,cRet}

/*
Funcao	    : MarcaButton()
Parametros  : 
Retorno     : 
Objetivos   : Marca e Desmarca Todas as integra��es.
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
	If oGetDados:aCols[i][2] == oStsIn //Nunca seleciona a op��o Inativa.
		oGetDados:aCols[i][1] := oSelN
	Else
		oGetDados:aCols[i][1] := oSelBtn
	EndIf
Next i

oGetDados:ForceRefresh()

Return .T.

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

//Atualiza a Visualiza��o do Arquivo para n�o estar exibindo
oArqView:LVISIBLECONTROL := .F.

//Atualiza o Browse do Layout. -------------------------------
aCLayout		:= &("a"+aCodInt[oGetDados:NAT])
oLayout:aCols	:= &("a"+aCodInt[oGetDados:NAT])
oLayout:ForceRefresh()

//Troca o Browse de arquivos ---------------------------------
For i:=1 to len(aCodInt)
	&("oArq"+aCodInt[i]):OBROWSE:LVISIBLECONTROL := .F.
Next i
&("oArq"+aCodInt[oGetDados:NAT]):OBROWSE:LVISIBLECONTROL := .T.

//Atualiza o nome das Janelas --------------------------------
oLayer:setWinTitle('2','Win21','Visualiza��o - '+ALLTRIM(oGetDados:aCols[oGetDados:NAT][3]),'1')
oLayer:setWinTitle('2','Win22','Console - '+ALLTRIM(oGetDados:aCols[oGetDados:NAT][3]),'1')
                    
//Atualiza o Console -----------------------------------------
cConsole := &("cCons"+aCodInt[oGetDados:NAT])
EVAL(oConsole:BSETGET)
oConsole:SetFocus()

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
Local lRet := .T.

//Ajusta o Browse do Layout
oLayout:oBrowse:nHeight := (oWin21:NHEIGHT)-40
oLayout:ForceRefresh()

//Ajusta o Browse do Arquivo
For i:=1 to len(aCodInt)
	&("oArq"+aCodInt[i]):oBrowse:nHeight := (oWin21:NHEIGHT)-2
	&("oArq"+aCodInt[i]):ForceRefresh()
Next i

//Atualiza a Visualiza��o do arquivo
oArqView:nLeft := &("oArq"+aCodInt[1]):oBrowse:nLeft
oArqView:nRight := &("oArq"+aCodInt[1]):oBrowse:nRight 
oArqView:nHeight := &("oArq"+aCodInt[1]):oBrowse:nHeight

//Ajusta o Console
oConsole:nHeight := (oWin22:NHEIGHT)-2

Return .T.

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Fun��o para mudar a imagem do primeiro campo, para selecionado ou n�o selecionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*--------------------------*
Static Function MudaStatus()
*--------------------------*
Local cArqConte := oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]
Local aObrigat := {}//Array com as dependencias de integra��es.

aAdd(aObrigat,{'41'})
aAdd(aObrigat,{'42','41'})
aAdd(aObrigat,{'43'})
aAdd(aObrigat,{'44','43'})
aAdd(aObrigat,{'45'})
aAdd(aObrigat,{'46'})
aAdd(aObrigat,{'47'})
aAdd(aObrigat,{'48'})
aAdd(aObrigat,{'49'})
aAdd(aObrigat,{'410'})
aAdd(aObrigat,{'411'})
aAdd(aObrigat,{'412'})
aAdd(aObrigat,{'413'})
aAdd(aObrigat,{'414','413'})
aAdd(aObrigat,{'415','413','414','44','45','46','47','41','42'})
aAdd(aObrigat,{'416','415','413','414'})
aAdd(aObrigat,{'417','415','413','414'})
aAdd(aObrigat,{'418','415','413','414','44'})
aAdd(aObrigat,{'419','415','413','414','45'})
aAdd(aObrigat,{'420','415','413','414'})
aAdd(aObrigat,{'421','415','413','414'})
aAdd(aObrigat,{'422','415','413','414'})
aAdd(aObrigat,{'423','415','413','414'})
aAdd(aObrigat,{'424','415','413','414','41','42'})
aAdd(aObrigat,{'425'})
aAdd(aObrigat,{'426'})
aAdd(aObrigat,{'427'})
aAdd(aObrigat,{'428','415','413','414'})
aAdd(aObrigat,{'429','415','413','414','416'})

If oSelS == cArqConte
	cArqConte := oSelN
Else 
	If oGetDados:aCols[oGetDados:Obrowse:nAt][2] <> oStsIn //Nunca seleciona a op��o Inativa.
		cArqConte := oSelS
		//Marca as op��es dependentes da integra��o.
		cInt := STRTRAN(SUBSTR(oGetDados:aCols[oGetDados:Obrowse:nAt][3],1,AT(" ",oGetDados:aCols[oGetDados:Obrowse:nAt][3])-1),".","")
		nPosObrigat := aScan(aObrigat,{|x| x[1]==cInt})
		If Len(aObrigat[nPosObrigat]) > 1
			For i := 2 to Len(aObrigat[nPosObrigat])
				nPosInt := aScan(oGetDados:aCols,{|x| STRTRAN(SUBSTR(x[3],1,AT(" ",x[3])-1),".","") == aObrigat[nPosObrigat][i]  })
				If nPosInt <> 0
					oGetDados:aCols[nPosInt][1] := oSelS
				EndIf
			Next i
		EndIf
	Else
		cArqConte := oSelN
	EndIf
Endif

oGetDados:ForceRefresh()

Return(cArqConte)

/*
Funcao	    : GetInfoInt()
Parametros  : 
Retorno     : 
Objetivos   : Fun��o para processamento dos Arquivos de integra��es e valida��es.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*----------------------------------*
Static function GetInfoInt(cTipoInt) 
*----------------------------------*
Local aRet := {}
Local cRet := ""
Local cQuery := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  

Do Case
	Case cTipoInt == '41'  //Bancos"
		cQuery += " Select SUBSTRING(RA_BCDEPSA,1,3) AS BANCO
		cQuery += " From "+RETSQLNAME("SRA")
		cQuery += " Where D_E_L_E_T_ <> '*'
//		cQuery += " AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += " AND RA_DEMISSA <> '*'
		cQuery += " AND SUBSTRING(RA_BCDEPSA,1,3) <> ''
		cQuery += " Group By SUBSTRING(RA_BCDEPSA,1,3)
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

		QRY->(DbGoTop())
		While QRY->(!EOF())
			cName := GetNameBank("FULL",QRY->BANCO)
			aAdd(aRet, {ALLTRIM(TRANSFORM(QRY->BANCO, "@R 999999")),;//'CodBanco'
						cName,;//'Banco'
						GetNameBank("REDUCED",QRY->BANCO),;//'BancoRes'
					   	ALLTRIM(TRANSFORM(QRY->BANCO, "@R 999999")),;//'NuiOficial'
						.F.})//Deletado

			If EMPTY(cName)
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'Banco': N�o encontrado na Tabela FEBRABAN. Banco:'"+QRY->BANCO+"'"+CHR(13)+CHR(10))

			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '42'  //Ag�ncias Banc�rias"
  		cQuery += " Select SUBSTRING(RA_BCDEPSA,1,3) as BANCO,SUBSTRING(RA_BCDEPSA,4,99) as AGENCIA
		cQuery += " From "+RETSQLNAME("SRA")
		cQuery += " Where D_E_L_E_T_ <> '*'
//		cQuery += " AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += " AND RA_DEMISSA <> '*'
		cQuery += " AND SUBSTRING(RA_BCDEPSA,1,3) <> ''
		cQuery += " AND SUBSTRING(RA_BCDEPSA,4,99) <> ''
		cQuery += " Group By SUBSTRING(RA_BCDEPSA,1,3),SUBSTRING(RA_BCDEPSA,4,99)
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {ALLTRIM(TRANSFORM(QRY->AGENCIA, "@R 999999")),;	//'CodAgenciaBanco'
						ALLTRIM(TRANSFORM(QRY->BANCO, "@R 999999")),;		//'CodBanco'
						QRY->AGENCIA,;			   							//'AgenciaBanco'
						ALLTRIM(TRANSFORM(QRY->AGENCIA, "@R 999999")),;	//'NuiOficial'
						,;							   							//'AgenciaDigito'
						.F.})							  						//Deletado

			If aScan(oArq41:aCols, {|x| x[4] == ALLTRIM(TRANSFORM(QRY->BANCO, "@R 999999")) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodBanco': Referencia 4.1 n�o encontrada. Banco:'"+QRY->BANCO+"'"+CHR(13)+CHR(10))
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i]) .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '43'  //CBO"
  		cQuery += " Select SRJ.RJ_CODCBO
  		cQuery += " From "+RETSQLNAME("SRA")+" SRA
  		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRJ")+" Where D_E_L_E_T_ <> '*') AS SRJ On SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
  		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//  		cQuery += "	 AND SRA.RA_DEMISSA = ''
  		cQuery += "  AND SRJ.RJ_CODCBO <> ''
  		cQuery += " Group By SRJ.RJ_CODCBO
  		cQuery += " Union
  		cQuery += " Select SRJ.RJ_CODCBO
  		cQuery += " From "+RETSQLNAME("SR7")+" SR7
  		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRJ")+" Where D_E_L_E_T_ <> '*') AS SRJ On SR7.R7_FUNCAO = SRJ.RJ_FUNCAO
  		cQuery += " Where SR7.D_E_L_E_T_ <> '*'
  		cQuery += " 	AND SR7.R7_FUNCAO <> ''
  		cQuery += " 	AND SRJ.RJ_FUNCAO <> ''
  		cQuery += " 	AND SRJ.RJ_CODCBO <> ''
  		cQuery += " Group By SRJ.RJ_CODCBO

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
	
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RJ_CODCBO, "@R 999999"),;			//'CodCBO'
						TRANSFORM(QRY->RJ_CODCBO, "@R 9999-99"),;			//'CBO'
						GetCBO(TRANSFORM(QRY->RJ_CODCBO, "@R 999999")),;	//'DsCBO'
						.F.})						//Deletado

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '44'  //Cargos"           
		cQuery += " Select SRJ.RJ_FILIAL,SRJ.RJ_FUNCAO,SRJ.RJ_DESC,SRJ.RJ_CBO,SRJ.RJ_CODCBO
  		cQuery += " From "+RETSQLNAME("SRA")+" SRA
  		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRJ")+" Where D_E_L_E_T_ <> '*') AS SRJ On SRA.RA_CODFUNC = SRJ.RJ_FUNCAO
  		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//  		cQuery += "	 AND SRA.RA_DEMISSA = ''
  		cQuery += "  AND SRJ.RJ_CODCBO <> ''
  		cQuery += " Group By SRJ.RJ_FILIAL,SRJ.RJ_FUNCAO,SRJ.RJ_DESC,SRJ.RJ_CBO,SRJ.RJ_CODCBO
  		cQuery += " Union
  		cQuery += " Select SRJ.RJ_FILIAL,SRJ.RJ_FUNCAO,SRJ.RJ_DESC,SRJ.RJ_CBO,SRJ.RJ_CODCBO
  		cQuery += " From "+RETSQLNAME("SR7")+" SR7
  		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRJ")+" Where D_E_L_E_T_ <> '*') AS SRJ On SR7.R7_FUNCAO = SRJ.RJ_FUNCAO
  		cQuery += " Where SR7.D_E_L_E_T_ <> '*'
  		cQuery += " 	AND SR7.R7_FUNCAO <> ''
  		cQuery += " 	AND SRJ.RJ_FUNCAO <> ''
  		cQuery += " 	AND SRJ.RJ_CODCBO <> ''
  		cQuery += " Group By SRJ.RJ_FILIAL,SRJ.RJ_FUNCAO,SRJ.RJ_DESC,SRJ.RJ_CBO,SRJ.RJ_CODCBO

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)	
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RJ_FUNCAO, "@R 9999"),;	//'CodCargo'
						ALLTRIM(QRY->RJ_DESC),;						//'Cargo'
						SUBSTR(QRY->RJ_DESC,1,32),;					//'CargoRes'
						TRANSFORM(QRY->RJ_CODCBO, "@R 999999"),;	//'CodCBO'
						.F.})											//Deletado
			
			If (nPos := aScan(oArq43:aCols,{|x| x[1] == TRANSFORM(QRY->RJ_CODCBO, "@R 999999") })) == 0
				cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.3 n�o encontrada. Cargo:'"+TRANSFORM(QRY->RJ_FUNCAO, "@R 9999")+"'"+CHR(13)+CHR(10))
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
	
	Case cTipoInt == '45'  //Centros de Custo"
		cQuery += " Select SRE.RE_CCD AS CC,CTT.CTT_DESC01
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 																			AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " 	Left Outer Join (	Select * 
  		cQuery += " 						From "+RETSQLNAME("CTT")
  		cQuery += " 						Where D_E_L_E_T_ <> '*' 
//  		cQuery += "								AND CTT_FILIAL = '"+xFilial("CTT")+"'
  		cQuery += " 																) AS CTT On CTT.CTT_CUSTO = SRE.RE_CCD
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRE.RE_MATP <> ''
		cQuery += " 	AND CTT.CTT_DESC01 <> ''
		cQuery += " 	AND SRE.RE_CCD <> SRE.RE_CCP
		cQuery += " 	Group By SRE.RE_CCD,CTT.CTT_DESC01
//RRP - 31/10/2014 - Ajuste de registros duplicados.
//		cQuery += " Union All
		cQuery += " Union
		cQuery += " Select SRE.RE_CCP AS CC,CTT.CTT_DESC01
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 																			AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " 	Left Outer Join (	Select * 
  		cQuery += " 						From "+RETSQLNAME("CTT")
  		cQuery += " 						Where D_E_L_E_T_ <> '*' 
//  		cQuery += "  								AND CTT_FILIAL = '"+xFilial("CTT")+"'
  		cQuery += "																	) AS CTT On CTT.CTT_CUSTO = SRE.RE_CCP
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRE.RE_MATP <> ''
		cQuery += " 	AND SRE.RE_CCD <> SRE.RE_CCP
		cQuery += " 	AND CTT.CTT_DESC01 <> ''
		cQuery += " 	Group By SRE.RE_CCP,CTT.CTT_DESC01	
		//Adicionado o tratamento para considerar CC para funcionarios que n�o tiveram transferencias.
		cQuery += "	Union
		cQuery += " Select SRA.RA_CC AS CC,CTT.CTT_DESC01
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (	Select * 
		cQuery += "   						From "+RETSQLNAME("CTT")
		cQuery += "   						Where D_E_L_E_T_ <> '*' 
//  		cQuery += "												AND CTT_FILIAL = '"+xFilial("CTT")+"'
  		cQuery += "																		) AS CTT On CTT.CTT_CUSTO = SRA.RA_CC
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
		cQuery += " 	AND SRA.RA_CC <> ''
		cQuery += " 	AND CTT.CTT_DESC01 <> ''
		cQuery += " Group By SRA.RA_CC,CTT.CTT_DESC01

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->CC, "@R 999999999 "),;		//'CodCentroCusto'
						ALLTRIM(QRY->CTT_DESC01),;					//'CentroCusto'
						ALLTRIM(QRY->CTT_DESC01),;					//'CentroCustoRes'
						TransForm(LEN(aRet)+1,"@R 999"),;			//'Estrutura'
						.F.})											//Deletado

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
		
	
	Case cTipoInt == '46'  //Hor�rios"
		cQuery += " Select SRA.RA_TNOTRAB,SRA.RA_HRSEMAN,SR6.R6_FILIAL,SR6.R6_TURNO,SR6.R6_DESC,SR6.R6_HRNORMA/4 AS R6_HRNORMA, SPJ.*
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join(Select * From "+RETSQLNAME("SR6")+" Where D_E_L_E_T_ <> '*' ) as SR6 on SR6.R6_FILIAL = SRA.RA_FILIAL
		cQuery += " 																						AND SR6.R6_TURNO = SRA.RA_TNOTRAB
		cQuery += " 	Left outer Join (Select PJ_FILIAL,PJ_TURNO, SUM(PJ_HRTOTAL-PJ_HRSINT1-PJ_HRSINT2-PJ_HRSINT3) AS PJ_HRTOTAL
		cQuery += " 					 From "+RETSQLNAME("SPJ")
		cQuery += " 					 Where D_E_L_E_T_ <> '*'
		cQuery += " 					 Group By PJ_FILIAL,PJ_TURNO ) 
		cQuery += " 												as SPJ on	SR6.R6_FILIAL = SPJ.PJ_FILIAL
		cQuery += " 															AND SR6.R6_TURNO = SPJ.PJ_TURNO
		cQuery += " Where SRA.D_E_L_E_T_  <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRA.RA_TNOTRAB <> ''
//		cQuery += " 	AND SRA.RA_FILIAL = '"+xFilial("SRA")+"'
		//cQuery += " 	AND SR6.R6_TURNO <> ''
		cQuery += " Group By SRA.RA_TNOTRAB,SRA.RA_HRSEMAN,
		cQuery += " 		 SR6.R6_FILIAL,SR6.R6_TURNO,SR6.R6_DESC,SR6.R6_HRNORMA/4,
		cQuery += " 		 SPJ.PJ_FILIAL,SPJ.PJ_TURNO,SPJ.PJ_HRTOTAL

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

		QRY->(DbGoTop())
		While QRY->(!EOF())
		    If QRY->RA_HRSEMAN <> 0//Calculo do valor por semana.
		    	nHorSem := QRY->RA_HRSEMAN
		    ElseIf QRY->PJ_HRTOTAL <> 0
		    	nHorSem := QRY->PJ_HRTOTAL
		    Else
		    	nHorSem := QRY->R6_HRNORMA
		    EndIf
			nHorMen :=	INT(nHorSem*4)
			If Len(ALLTRIM(STR(Min2Hrs(Hrs2Min(nHorSem)/5)))) >2//Calculo de Qtde por dias e tratamento para Formato do layout.
				cHorDia := LEFT(STRZERO(VAL(STRTRAN(ALLTRIM(STR(Min2Hrs(Hrs2Min(nHorSem)/5))),".","")),4),2)+":"+;
							RIGHT(STRZERO(VAL(STRTRAN(ALLTRIM(STR(Min2Hrs(Hrs2Min(nHorSem)/5))),".","")),4),2)
			Else
				cHorDia := STRZERO(VAL(STRTRAN(ALLTRIM(STR(Min2Hrs(Hrs2Min(nHorSem)/5))),".","")),2)+":00"
			EndIf
			If nHorSem == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - QtiHorasSemanal: Valor de Horas semanais invalido! Turno:'"+QRY->R6_TURNO+"'"+CHR(13)+CHR(10))
				cRet := GrvErro(cRet+"            ->A Qtde de Horas atende a regra: Cadastro do Funcionario > Cadastro do Turno > Cadastro de Horarios."+CHR(13)+CHR(10))
			EndIf
			If aScan(aRet,{|x| x[1] == TRANSFORM(QRY->RA_TNOTRAB, "@R 999") }) <> 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - Horario: Turno Duplicado com um ja existente! Turno:'"+QRY->RA_TNOTRAB+"'"+CHR(13)+CHR(10))
				cRet := GrvErro(cRet+"            ->Verificar se para o mesmo turno possui Horarios diferentes."+CHR(13)+CHR(10))
				cRet := GrvErro(cRet+"            ->A Qtde de Horas atende a regra: Cadastro do Funcionario > Cadastro do Turno > Cadastro de Horarios."+CHR(13)+CHR(10))
			EndIf
			
			If !EMPTY(QRY->R6_DESC)
				cDesc := QRY->R6_DESC
			Else
				cDesc := "Horario "+TRANSFORM(QRY->RA_TNOTRAB, "@R 999")
			EndIf
			
			aAdd(aRet, {TRANSFORM(QRY->RA_TNOTRAB, "@R 999"),;//'CodHorario'
						cDesc,;									//'Horario'
						nHorSem,;		   	   						//'QtiHorasSemanal'
						nHorMen,;		  							//'QtiHorasMensais'
						cHorDia,;									//'QtiHorasDia'
						.F.})					   					//Deletado
	
			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
	 		
	Case cTipoInt == '47'  //Sindicato"
		cQuery += " Select * 
		cQuery += " From "+RETSQLNAME("RCE")+" RCE
		cQuery += " 	Left Outer Join (	Select RA_FILIAL,RA_SINDICA
		cQuery += " 						From "+RETSQLNAME("SRA")
//		cQuery += " 						Where RA_FILIAL = '"+xFilial("SRA")+"'
		cQuery += " 						GROUP By RA_FILIAL,RA_SINDICA) AS SRA On RCE.RCE_CODIGO = SRA.RA_SINDICA
		cQuery += " Where D_E_L_E_T_ <> '*'
//		cQuery += " AND SRA.RA_FILIAL = '"+xFilial("SRA")+"'
		cQuery += " AND SRA.RA_SINDICA <> ''

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RCE_CODIGO, "@R 99"),;		//'CodSindicato'
						ALLTRIM(QRY->RCE_DESCRI),;					//'Sindicato'
						,;						   						//'SindicatoResumo'
						VAL(QRY->RCE_MESDIS),;						//'MesDissidio'
						TipoEnd(QRY->RCE_ENDER),;					//'CodTipoEndereco'
						ALLTRIM(QRY->RCE_ENDER),;					//'EnderecoBase'
						ALLTRIM(QRY->RCE_NUMER),; 					//'EnderecoNumero'
						ALLTRIM(QRY->RCE_COMPLE),;					//'EnderecoComplto'
						ALLTRIM(QRY->RCE_BAIRRO),;					//'Bairro'
						TRANSFORM(QRY->RCE_CEP, "@R 99999-999"),;	//'Cep'
						ALLTRIM(QRY->RCE_MUNIC),;					//'Municipio'
						IdEst(QRY->RCE_UF),;							//'Estado'
						TRANSFORM(QRY->RCE_CGC, "@R 99.999.999/9999-99") ,;									//'CNPJ'
						TRANSFORM(IIF(!EMPTY(QRY->RCE_DDD),QRY->RCE_DDD,"00"), "@R 99"),;		  			//'DDDTelefone'
						TRANSFORM(IIF(!EMPTY(QRY->RCE_FONE),QRY->RCE_FONE,"00000000"), "@R 9999-9999"),;	//'Telefone'
						.F.})
			
			If aRet[LEN(aRet)][5] == 0
				cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - Tipo de Endere�o n�o definido."+CHR(13)+CHR(10))
			EndIf
			
			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i]) .and. !(ALLTRIM(STR(i)) $ "5/7/14/15" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '48'  //Verbas"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRV")+" SRV
		cQuery += " Where SRV.D_E_L_E_T_ <> '*'
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		nCount := 1
		QRY->(DbGoTop())
		While QRY->(!EOF())
			nCount++
			aAdd(aRet, {nCount,;				   				//'CodVerba'
						VAL(IIF(EMPTY(QRY->RV_TIPOCOD),"0",IIF(QRY->RV_TIPOCOD>"3","0",IIF(QRY->RV_TIPOCOD="3","7",QRY->RV_TIPOCOD)))),;//'CodNaturezaVerba'
						QRY->RV_COD+"-"+QRY->RV_DESC,;		//'Verba'
						,;		  								//'VerbaRes'
						0,;					   					//'CodTipoVerba'
						IIF(SRV->RV_INSS=="S",1,0),;		//'IncideINSS'
						IIF(SRV->RV_FGTS=="S",1,0),;		//'IncideFGTS'
						IIF(SRV->RV_IR  =="S",1,0),;			//'IncideIRRF'
						.F.})					   				//Deletado

			If aRet[LEN(aRet)][2] == 0
				cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodNaturezaVerba': Valor invalido! Verba:'"+QRY->RV_COD+"'"+CHR(13)+CHR(10))
			EndIf
			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i]) .and. !(ALLTRIM(STR(i)) $ "5/6/7/8" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf		

			QRY->(DbSkip())
		EndDo
	
	Case cTipoInt == '49'  //Meios de transportes" 
		//Sem Informa��es no Sistema

	Case cTipoInt == '410' //Tipos de Beneficios"
		//Sem Informa��es no Sistema

	Case cTipoInt == '411' //Empresas de Benneficios
		//Sem Informa��es no Sistema

	Case cTipoInt == '412' //Empresas de Institui��es de Ensino"
   		//Sem Informa��es no Sistema

	Case cTipoInt == '413' //Empresas"
		cQuery += " Select SRE.RE_EMPD as EMP,SRE.RE_FILIALD AS FIL
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 																			AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRE.RE_EMPD <> SRE.RE_EMPP
		cQuery += " Group By SRE.RE_EMPD,SRE.RE_FILIALD
		cQuery += " Union All
		cQuery += " Select SRE.RE_EMPP as EMP,SRE.RE_FILIALP AS FIL
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 																			AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRE.RE_EMPD <> SRE.RE_EMPP
		cQuery += " Group By SRE.RE_EMPP,SRE.RE_FILIALP
		cQuery += " Union All 
		cQuery += " Select '"+cEmpAnt+"' as EMP,SRA.RA_FILIAL AS FIL From "+RETSQLNAME("SRA")+" SRA 
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
		cQuery += " Group By SRA.RA_FILIAL

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {STRZERO(ASC(LEFT(QRY->EMP,1)),2)+STRZERO(ASC(RIGHT(QRY->EMP,1)),2)+ALLTRIM(STR(VAL(QRY->FIL))),;//'CodEmpresa'
						FWEmpName(QRY->EMP),;//'Empresa'
						.F.})					//Deletado

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
		
		If LEN(aRet) == 0
			aAdd(aRet, {STRZERO(ASC(LEFT(SM0->M0_CODIGO,1)),2)+STRZERO(ASC(RIGHT(SM0->M0_CODIGO,1)),2)+ALLTRIM(STR(VAL(SM0->M0_CODFIL))),;//'CodEmpresa'
						FWEmpName(SM0->M0_CODIGO),;//'Empresa'
						.F.})					//Deletado
			For i:=1 To Len(&("a"+cTipoInt))
				If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
					cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
				EndIf
			Next i
		EndIf

	Case cTipoInt == '414' //Locais"
		cQuery += " Select SRE.RE_EMPD as EMP,SRE.RE_FILIALD AS FIL
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 																			AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRE.RE_EMPD <> SRE.RE_EMPP
		cQuery += " Group By SRE.RE_EMPD,SRE.RE_FILIALD
		cQuery += " Union All
		cQuery += " Select SRE.RE_EMPP as EMP,SRE.RE_FILIALP AS FIL
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 																			AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRE.RE_EMPD <> SRE.RE_EMPP
		cQuery += " Group By SRE.RE_EMPP,SRE.RE_FILIALP
		cQuery += " Union All 
		cQuery += " Select '"+cEmpAnt+"' as EMP,SRA.RA_FILIAL AS FIL From "+RETSQLNAME("SRA")+" SRA 
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
		cQuery += " Group By SRA.RA_FILIAL

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		
		aOrd := SaveOrd("SM0")
		
		QRY->(DbGoTop())
		While QRY->(!EOF())
			
			If SM0->(DbSeek(QRY->EMP+QRY->FIL))
				nTpInsc := IIF(SM0->M0_TPINSC==2,1,IIF(SM0->M0_TPINSC==1,2,0))
				If nTpInsc <= 0 .or. nTpInsc >= 3
					cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'TipoInscricao': Tipo Diferente do Aceito pela APDATA."+CHR(13)+CHR(10))
				EndIf	
		
				aAdd(aRet, {STRZERO(ASC(LEFT(SM0->M0_CODIGO,1)),2)+STRZERO(ASC(RIGHT(SM0->M0_CODIGO,1)),2)+ALLTRIM(STR(VAL(SM0->M0_CODFIL))),;//'CodLocal'
							STRZERO(ASC(LEFT(SM0->M0_CODIGO,1)),2)+STRZERO(ASC(RIGHT(SM0->M0_CODIGO,1)),2)+ALLTRIM(STR(VAL(SM0->M0_CODFIL))),;	//'CodEmpresa'
							FWEmpName(SM0->M0_CODIGO),; 						//'Local'
							nTpInsc,; 												//'TipoInscricao'
							Transform(IIF(nTpInsc==1,SM0->M0_CGC,"00000000000000"),"@R 99.999.999/9999-99"),;	//'CNPJ'
							Transform(IIF(nTpInsc==2,SM0->M0_CEI,"000000000000"),"@R 999999999999"),;  			//'CEI'
							TipoEnd(SM0->M0_ENDCOB),;							//'CodTipoEndereco'
							ALLTRIM(SM0->M0_ENDCOB),;							//'EnderecoBase'
							,; 														//'EnderecoNumero'
							ALLTRIM(SM0->M0_COMPCOB),;							//'EnderecoComplto'
							ALLTRIM(SM0->M0_BAIRCOB),;							//'Bairro'
							ALLTRIM(SM0->M0_CIDCOB),;							//'Municipio'
							TRANSFORM(SM0->M0_CEPCOB, "@R 99999-999"),; 		//'NusCep'
							IdEst(SM0->M0_ESTCOB),;	   							//'CodEstado'
					   		LEFT(RIGHT(STRTRAN(SM0->M0_TEL,"-",""),10),2),;	//'TelefoneDDD'
							RIGHT(STRTRAN(SM0->M0_TEL,"-",""),8),; 			//'TelefoneNum'
							.F.})		
				
				If nTpInsc == 1 .and. EMPTY(SM0->M0_CGC)
					cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CNPJ' Invalido."+CHR(13)+CHR(10))
				ElseIf nTpInsc == 2 .and. EMPTY(SM0->M0_CEI)
					cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CEI' Invalido."+CHR(13)+CHR(10))
				EndIf
				If aRet[LEN(aRet)][7] == 0
					cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - Tipo de Endere�o n�o definido."+CHR(13)+CHR(10))
				EndIf
			
				//Verifica Campo Obrigatorio Preenchido.
				If Len(aRet) > 0
					For i:=1 To Len(&("a"+cTipoInt))
						If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i]) .and. !(ALLTRIM(STR(i)) $ "5/6/7/9" )
							cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
						EndIf
					Next i
				EndIf
			Else
				cRet := GrvErro(cRet+"[ALERTA]- Empresa '"+QRY->EMP+"' n�o encontrada no cadastro de empresas."+CHR(13)+CHR(10))
			EndIf
			QRY->(DbSkip())
		EndDo
		RestOrd(aOrd)

		If LEN(aRet) == 0
			nTpInsc := IIF(SM0->M0_TPINSC==2,1,IIF(SM0->M0_TPINSC==1,2,0))
			If nTpInsc <= 0 .or. nTpInsc >= 3
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'TipoInscricao': Tipo Diferente do Aceito pela APDATA."+CHR(13)+CHR(10))
			EndIf	
	
			aAdd(aRet, {STRZERO(ASC(LEFT(SM0->M0_CODIGO,1)),2)+STRZERO(ASC(RIGHT(SM0->M0_CODIGO,1)),2)+ALLTRIM(STR(VAL(SM0->M0_CODFIL))),;//'CodLocal'
						STRZERO(ASC(LEFT(SM0->M0_CODIGO,1)),2)+STRZERO(ASC(RIGHT(SM0->M0_CODIGO,1)),2)+ALLTRIM(STR(VAL(SM0->M0_CODFIL))),;	//'CodEmpresa'
						FWEmpName(SM0->M0_CODIGO),; 						//'Local'
						nTpInsc,; 												//'TipoInscricao'
						Transform(IIF(nTpInsc==1,SM0->M0_CGC,"00000000000000"),"@R 99.999.999/9999-99"),;	//'CNPJ'
						Transform(IIF(nTpInsc==2,SM0->M0_CEI,"000000000000"),"@R 999999999999"),;  			//'CEI'
						TipoEnd(SM0->M0_ENDCOB),;							//'CodTipoEndereco'
						ALLTRIM(SM0->M0_ENDCOB),;							//'EnderecoBase'
						,; 														//'EnderecoNumero'
						ALLTRIM(SM0->M0_COMPCOB),;							//'EnderecoComplto'
						ALLTRIM(SM0->M0_BAIRCOB),;							//'Bairro'
						ALLTRIM(SM0->M0_CIDCOB),;							//'Municipio'
						TRANSFORM(SM0->M0_CEPCOB, "@R 99999-999"),; 		//'NusCep'
						IdEst(SM0->M0_ESTCOB),;	   							//'CodEstado'
				   		LEFT(RIGHT(STRTRAN(SM0->M0_TEL,"-",""),10),2),;	//'TelefoneDDD'
						RIGHT(STRTRAN(SM0->M0_TEL,"-",""),8),; 			//'TelefoneNum'
						.F.})		
			
			If nTpInsc == 1 .and. EMPTY(SM0->M0_CGC)
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CNPJ' Invalido."+CHR(13)+CHR(10))
			ElseIf nTpInsc == 2 .and. EMPTY(SM0->M0_CEI)
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CEI' Invalido."+CHR(13)+CHR(10))
			EndIf
			If aRet[LEN(aRet)][7] == 0
				cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - Tipo de Endere�o n�o definido."+CHR(13)+CHR(10))
			EndIf
		
			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i]) .and. !(ALLTRIM(STR(i)) $ "5/6/7/9" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
		EndIf

	Case cTipoInt == '415' //Contratados"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " AND SRA.RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += " AND SRA.RA_DEMISSA = ''

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
			//Valida��es
			If aScan(oArq41:aCols,{|x| x[4] == ALLTRIM(TRANSFORM(SubStr(QRY->RA_BCDEPSA,1,3), "@R 999999")) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodBanco': Referencia 4.1 n�o encontrada. Banco:'"+TRANSFORM(SubStr(QRY->RA_BCDEPSA,1,3), "@R 999999")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq42:aCols,{|x| x[4] == ALLTRIM(TRANSFORM(SubStr(QRY->RA_BCDEPSA,4,99), "@R 999999")) })  == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodAgencia': Referencia 4.2 n�o encontrada. Ag:'"+TRANSFORM(SubStr(QRY->RA_BCDEPSA,4,99), "@R 999999")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq46:aCols,{|x| x[1] == TRANSFORM(QRY->RA_TNOTRAB, "@R 999") })  == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodHorario': Referencia 4.6 n�o encontrada. Turno:'"+TRANSFORM(QRY->RA_TNOTRAB, "@R 999")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq47:aCols,{|x| x[1] == TRANSFORM(QRY->RA_SINDICA, "@R 99") }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodSindicato': Referencia 4.7 n�o encontrada. Sind.:'"+TRANSFORM(QRY->RA_SINDICA, "@R 99")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq44:aCols,{|x| x[1] == TRANSFORM(QRY->RA_CODFUNC, "@R 9999") }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.4 n�o encontrada. Cargo:'"+TRANSFORM(QRY->RA_CODFUNC, "@R 9999")+"'"+CHR(13)+CHR(10))
			EndIf
			If (nTipoPgt := GetTpPag(QRY->RA_TIPOPGT)) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCategoria': Invalida!"+CHR(13)+CHR(10))
			EndIf
			If (nCodVinc := GetCodVinc(QRY->RA_TIPOADM)) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodVinculo': Invalido!"+CHR(13)+CHR(10))
			EndIf
			If (nTipoEmp := GetTpEmp(QRY->RA_TIPOADM)) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodTipoEmprego': Invalido!"+CHR(13)+CHR(10))
			EndIf			
			aAdd(aRet, {TRANSFORM(QRY->RA_MAT, "@R 999999"),;		//'CodMatricula'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(QRY->RA_FILIAL))),;//'CodEmpresa'	   			
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(QRY->RA_FILIAL))),;//'CodLocal'	   				
						ALLTRIM(QRY->RA_NOME),;						//'Nome'		   				
						ALLTRIM(QRY->RA_NOME),;						//'NomeCompleto'  			
						ALLTRIM(QRY->RA_APELIDO),;					//'Apelido'   	   			
						ALLTRIM(QRY->RA_PAI),;						//'NomePai'	   				
						ALLTRIM(QRY->RA_MAE),;						//'NomeMae'	   				
						IIF(QRY->RA_SEXO=="M",1,2),;				//'CodSexo'	   				
						DTOC(STOD(QRY->RA_ADMISSA)),;				//10'Admissao'	   				
						,;//'TipoAdmissaoESocial'		
						,;//'ModoAdmissaoESocial'		
						,;//'PrazosContrato'			
						,;												//'CNPJ EmpresaOrigem'		
						,;												//'MatriculaEmpresaOrigem'	
						,;												//'AdmissaoEmpresaOrigem'		
						TRANSFORM(QRY->RA_CC, "@R 999999999 "),;		  		//'CodCentroCusto'			
						TRANSFORM(QRY->RA_CODFUNC, "@R 9999"),;			//'CodCargo'	   				
						TRANSFORM(QRY->RA_TNOTRAB, "@R 999"),;	   		//'CodHorario'	  			
						TRANSFORM(QRY->RA_SINDICA, "@R 99"),;	  		//20'CodSindicato'				
						nTipoPgt,;										//'CodCategoria'				
						nCodVinc,;										//'CodVinculo'	   			
						ALLTRIM(QRY->RA_EMAIL),;						//'EMail'			  			
						,;												//'EMailPessoal'	  			
						TRANSFORM(QRY->RA_SALARIO, "@R 999999999.99"),;//'Salario'	   				
						IIF(QRY->RA_PGCTSIN=="P",2,4),;				//'CodSituacaoSindical'		
						nTipoEmp,;										//'CodTipoEmprego'	   		
						,;												//'Drt'			  			
						DTOC(STOD(QRY->RA_NASC)),;					//'Nascimento'				
						DTOC(STOD(QRY->RA_OPCAO)),;					//30'OpcaoFGTS'					
						QRY->RA_NACIONA,;								//'CodNacionalidade'  		
						IdEst(QRY->RA_NATURAL),;						//'CodEstado_Naturalidade'	
						IIF(SRA->(FieldPos("RA_MUNNASC"))<>0,ALLTRIM(QRY->RA_MUNNASC),),;//'NascimentoLocal'	   		
						QRY->RA_CODMUN,;							//'CodigoMunicipio'			
						GetInstru(QRY->RA_GRINRAI),;				//'CodGrauInstrucao'			
						GetEstado(QRY->RA_ESTCIVI),;				//'CodEstadoCivil'	  		
						QRY->RA_RACACOR,;								//'CodCorPele'				
						,;												//'ResidenciaPropria'			
						,;												//'AquisicaoImovel'			
						TipoEnd(QRY->RA_ENDEREC),;					//40'CodTipoEndereco'			
						ALLTRIM(QRY->RA_ENDEREC),;					//'EnderecoBase'	 			
						000,;											//'EnderecoNumero'	 		
						ALLTRIM(QRY->RA_COMPLEM),;					//'EnderecoComplto'			
						ALLTRIM(QRY->RA_BAIRRO),;					//'Bairro'					
						ALLTRIM(QRY->RA_MUNICIP),;					//'Municipio'					
						IdEst(QRY->RA_ESTADO),;						//'CodEstado_Resid'			
						TRANSFORM(QRY->RA_CEP, "@R 99999-999"),;	//'Cep'						
						,;												//'TelefoneDDD_Resid'			
						,;												//'TelefoneNumero_Resid'		
						,;												//50'TelefoneCelularDDD'		
						,;												//'TelefoneCelular'			
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumero'					
						TRANSFORM(QRY->RA_PIS, "@R 999.9999.999-9"),;//'NumeroPis'					
						,;//'EmisPis'					
						QRY->RA_NUMCP,;								//'NumeroCarProf'				
						QRY->RA_SERCP,;								//'SerieCarProf'				
						DTOC(STOD(QRY->RA_DTCPEXP)),;				//'EmisCartProf'				
						IdEst(QRY->RA_UFCP),;						//'CodEstado_CarProf'			
						ALLTRIM(QRY->RA_RG),;						//'NumeroRg'					
						DTOC(STOD(QRY->RA_DTRGEXP)),;				//60'EmisRG'					
						IdEst(QRY->RA_RGUF),;						//'CodEstado_OrgaoRg'			
						QRY->RA_RGEXP,;								//'OrgaoRg'
						,;												//'NumeroRIC'					
						,;												//'OrgaoEmissorRIC'			
						,;												//'EmissaoRIC'				
						QRY->RA_RESERVI,;								//'Reservista'				
						,;												//'NumeroIdentEstrangeiro'	
						,;												//'OrgaoEmissorIdentEstrang'	
						,;												//'DataExpedicaoIdentEstrang'	
						,;												//70'NumeroDocumentoClasse'		
						,;												//'OrgaoEmissorDocClasse'		
						,;												//'EmissaoDocClasse'			
						,;												//'ValidadeDocClasse'			
						QRY->RA_TITULOE,;								//'NumeroTitEleitor'			
						ALLTRIM(IIF(AT("/",QRY->RA_ZONASEC)<>0,SUBSTR(QRY->RA_ZONASEC,1,AT("/",QRY->RA_ZONASEC)-1),QRY->RA_ZONASEC)),;	//'SecaoTitEleitor'			
						ALLTRIM(IIF(AT("/",QRY->RA_ZONASEC)<>0,SUBSTR(QRY->RA_ZONASEC,AT("/",QRY->RA_ZONASEC),4),"")),;					//'ZonaTitEleitor'			
						,;												//'MunicipioTitEleitor'		
						,;//'CodEstadoTitEleitor'		
						,;												//'EmisTitEleitor'			
						,;												//80'CnhN�mero'					
						,;												//'CnhVencimento'				
						,;												//'CnhTipo'					
						,;												//'OrgaoEmissorCNH'			
						,;												//'Emiss�oCNH'				
						ALLTRIM(TRANSFORM(SubStr(QRY->RA_BCDEPSA,1,3), "@R 999999")),;	//'CodBanco'					
						ALLTRIM(TRANSFORM(SubStr(QRY->RA_BCDEPSA,4,99), "@R 999999")),;//'CodAgencia'				
						IIF(AT("-",QRY->RA_CTDEPSA)<>0,SUBSTR(QRY->RA_CTDEPSA,1,AT("-",QRY->RA_CTDEPSA)-1),QRY->RA_CTDEPSA),;//'PagamentoConta'			
						IIF(AT("-",QRY->RA_CTDEPSA)<>0,SUBSTR(QRY->RA_CTDEPSA,AT("-",QRY->RA_CTDEPSA)+1,99),""),;				//'PagamentoContaDigito'		
						,;												//'CodExposicaoAgenteNocivo'	
						,;												//'Insalubridade'		  		
						,;												//'Periculosidade'			
						IIF(!EMPTY(QRY->RA_DEPSF),VAL(QRY->RA_DEPSF),0),;//'DepSalFamilia'				
						IIF(!EMPTY(QRY->RA_DEPIR),VAL(QRY->RA_DEPIR),0),;//'DepImpRenda'				
						IIF(EMPTY(QRY->RA_DEMISSA),"A","D"),;		//'CodSituacao'				
						IIF(EMPTY(QRY->RA_DEMISSA),"",DTOC(STOD(QRY->RA_DEMISSA))),;//'Rescisao'					
						IIF(EMPTY(QRY->RA_DEMISSA),"",DTOC(STOD(GETDEMISSA("PGTO",QRY->RA_FILIAL,QRY->RA_MAT,QRY->RA_DEMISSA))) ),;//'RescisaoPagto'				
						IIF(EMPTY(QRY->RA_DEMISSA),"",GETDEMISSA("COD",QRY->RA_FILIAL,QRY->RA_MAT,QRY->RA_DEMISSA)),;//'CodDesligamento'			
						,;												//'Aposentado'				
						,;												//'Aposentadoria'				
						,;												//'CodTipoDeficiencia'		
						,;												//'Naturalizado'				
						,;												//'DataNaturalizacao'			
						,;												//'DtdChegadaPais'			
						,;												//'CosTipoVisto'				
						,;												//'NusRNE'					
						,;												//'CasadoBrasileira(o)'		
						,;												//'FilhosBrasileiro'			
						,;												//'EnderecoExterior'			
						,;												//'EnderecoExteriorNum'		
						,;												//'EnderecoExteriorCompl'		
						,;												//'EnderecoExteriorBai'		
						,;												//'EnderecoExteriorMunic'		
						,;												//'EnderecoExteriorEstado'	
						,;												//'EnderecoExteriorCEP'		
						,;												//'EnderecoExteriorPais'		
						,;												//'NivelEstagio'				
						,;												//'InstituicaoEnsino'			
						,;												//'ApoliceSeguro'				
						,;												//'AreaAtuacao'
						.F.})											//Deletado
					
			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i]) .and. !(ALLTRIM(STR(i)) $ "6/14/15/16/21" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
		
				
	Case cTipoInt == '416' //Dependentes"
		cQuery += " Select * 
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += "	Left Outer Join (Select * From "+RETSQLNAME("SRB")+" Where D_E_L_E_T_ <> '*') AS SRB on SRA.RA_FILIAL = SRB.RB_FILIAL
		cQuery += "		   																		   			AND SRA.RA_MAT = SRB.RB_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " AND SRA.RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += " AND SRA.RA_DEMISSA = ''
		cQuery += " AND SRB.RB_MAT <> ''

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
				nGrau := 15
				Do Case
					Case QRY->RB_GRAUPAR == "C"
						nGrau := 3
					Case QRY->RB_GRAUPAR == "F"
						nGrau := 1
					Case QRY->RB_GRAUPAR == "E"
						nGrau := 8
					Case QRY->RB_GRAUPAR == "P"
						nGrau := 5
				EndCase
				
				aAdd(aRet, {VAL(QRY->RB_COD),;						//'CodDependente'
							TRANSFORM(QRY->RB_MAT, "@R 999999"),;	//'CodMatricula'
							TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
							STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodEmpresa'
							STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
							ALLTRIM(QRY->RB_NOME),;					//'Nome'
							DTOC(STOD(QRY->RB_DTNASC)),;			//'Nascimento'
							nGrau,;									//'GrauParentesco'
							IIF(QRY->RB_SEXO=="M",1,2),;			//'CodSexo'
							,;											//'CodGrauInstrucao'
							1,;											//'CodSituacaoDependente'
							7,;											//'CodEstadoCivil'
							IIF(!EMPTY(QRY->RB_TIPSF),IIF(QRY->RB_TIPSF <>"3",1,0),0),;//'SalarioFamilia'
							IIF(!EMPTY(QRY->RB_TIPIR),IIF(QRY->RB_TIPIR <>"4",1,0),0),;//'ImpRenda'
							1,;											//'VaciniFreqEsc'
							ALLTRIM(QRY->RB_CARTORI),;				//'CartorioNome'
							ALLTRIM(QRY->RB_NREGCAR),;				//'CartorioRegNasc'
							ALLTRIM(QRY->RB_NUMLIVR),;				//'CartorioLivroReg'
							ALLTRIM(QRY->RB_NUMFOLH),;				//'CartorioFolhaReg'
							DTOC(STOD(QRY->RB_DTENTRA)),;			//'DtdCertidaoNasc'
							TRANSFORM(QRY->RB_CIC, "@R 999.9999.999-99"),;//'CPF Numero'
							0,;											//'CNS Numero'
							0,;											//'Companheiro'
							0,;											//'Cursando Escola T�cnica'
							0,;											//'Guarda Judicial'
							,;											//'Tipo Dependente eSocial'
							.F.})										//Deletado

			If (nPos := aScan(oArq415:aCols,{|x| x[1] == TRANSFORM(QRY->RB_MAT, "@R 999999") })) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.15 n�o encontrada. Cargo:'"+TRANSFORM(QRY->RB_MAT, "@R 999999")+"'"+CHR(13)+CHR(10))
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i]) .and. !(ALLTRIM(STR(i)) $ "12/13/22/23/24" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '417' //Hist�rico de Sal�rios" 
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += "	Left Outer Join (Select * From "+RETSQLNAME("SR3")+" Where D_E_L_E_T_ <> '*') AS SR3 on SRA.RA_FILIAL = SR3.R3_FILIAL
		cQuery += "																							AND SRA.RA_MAT = SR3.R3_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += "		AND SRA.RA_DEMISSA = ''
		cQuery += "	AND SR3.R3_MAT <> ''
		cQuery += " Order By SR3.R3_FILIAL,SR3.R3_MAT,SR3.R3_DATA,SR3.R3_SEQ

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
				nMotivo := 0
				Do Case
					Case QRY->R3_TIPO == "001"//SAlario Inicial
						nMotivo := 1141
					Case QRY->R3_TIPO == "002"//Antecipacao
						nMotivo := 1002
					Case QRY->R3_TIPO == "003"//Dissidio
						nMotivo := 1004
					Case QRY->R3_TIPO == "004"//Merito
						nMotivo := 1006
					Case QRY->R3_TIPO == "005"//Promocao
						nMotivo := 1007
					Case QRY->R3_TIPO == "006"//Mudanca
						nMotivo := 1150
					Case QRY->R3_TIPO == "007"//Isonomia
						nMotivo := 1206
					OtherWise
						nMotivo := 1175
				EndCase
					aAdd(aRet, {TRANSFORM(QRY->R3_MAT, "@R 999999"),;//'CodMatricula'
								TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
								STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodEmpresa'
								STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
								DTOC(STOD(QRY->R3_DATA)),;				//'Alteracao'
								nMotivo,;									//'Motivo'
								TRANSFORM(QRY->R3_VALOR, "@R 999999999.99"),;//'VlnSalario'
								.F.})										//Deletado

			If (nPos := aScan(oArq415:aCols,{|x| x[1] == TRANSFORM(QRY->R3_MAT, "@R 999999") })) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.15 n�o encontrada. Cargo:'"+TRANSFORM(QRY->R3_MAT, "@R 999999")+"'"+CHR(13)+CHR(10))
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+"- "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '418' //Hist�rico de Cargos"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SR7")+" Where D_E_L_E_T_ <> '*') AS SR7 On SRA.RA_FILIAL = SR7.R7_FILIAL
		cQuery += " 																							AND SRA.RA_MAT = SR7.R7_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SR7.R7_MAT <> ''
		
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
			nMotivo := 0
			Do Case
				Case QRY->R7_TIPO == "001"//Admiss�o
					nMotivo := 1141
				Case QRY->R7_TIPO == "002"//Antecipacao
					nMotivo := 1002
				Case QRY->R7_TIPO == "003"//Dissidio
					nMotivo := 1004
				Case QRY->R7_TIPO == "004"//Merito
					nMotivo := 1006
				Case QRY->R7_TIPO == "005"//Promocao
					nMotivo := 1007
				Case QRY->R7_TIPO == "006"//Mudanca
					nMotivo := 1150
				Case QRY->R7_TIPO == "007"//Isonomia
					nMotivo := 1206
				OtherWise
					nMotivo := 1175
			EndCase
			
			aAdd(aRet, {TRANSFORM(QRY->R7_MAT, "@R 999999"),;//'CodMatricula'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;//'CodEmpresa'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
						DTOC(STOD(QRY->R7_DATA)),;				//'Alteracao'
						nMotivo,;									//'Motivo'
						TRANSFORM(QRY->R7_FUNCAO, "@R 9999"),;	//'CodCargo'
						.F.})	   									//Deletado

			If (nPos := aScan(oArq44:aCols,{|x| x[1] == TRANSFORM(QRY->R7_FUNCAO, "@R 9999") })) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': N�o encontrado no arquivo 4.4; Cargo.-> '"+TRANSFORM(QRY->R7_FUNCAO, "@R 9999")+"'"+CHR(13)+CHR(10))
			EndIf
			If (nPos := aScan(oArq415:aCols,{|x| x[1] == TRANSFORM(QRY->R7_MAT, "@R 999999") })) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.15 n�o encontrada. Cargo:'"+TRANSFORM(QRY->R7_MAT, "@R 999999")+"'"+CHR(13)+CHR(10))
			EndIf	

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+"- "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '419' //Hist�rico de Centros de Custo"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 																							AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRE.RE_MATP <> ''
		cQuery += " 	AND SRE.RE_CCD <> SRE.RE_CCP
		
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RE_MATP, "@R 999999"),;	//'CodMatricula'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
						STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))),;	//'CodEmpresa'
						STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))),;	//'CodLocal'
						DTOC(STOD(QRY->RE_DATA)),;	//'Alteracao'
						,;								//'Motivo'
						TRANSFORM(QRY->RE_CCP, "@R 999999999 "),;					//'CodCentroCusto'
						.F.})							//Deletado

			If aScan(oArq45:aCols, {|x| x[1] == TRANSFORM(QRY->RE_CCP, "@R 9999 ") }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodCentroCusto: Referencia 4.5 n�o encontrada. CC='"+TRANSFORM(QRY->RE_CCP, "@R 9999 ")+"'"+CHR(13)+CHR(10)			)
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
	
	Case cTipoInt == '420' //Hist�rico de F�rias"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " Left Outer Join (Select * From "+RETSQLNAME("SRH")+" Where D_E_L_E_T_ <> '*') AS SRH on SRH.RH_FILIAL = SRA.RA_FILIAL
		cQuery += " 																				AND SRH.RH_MAT = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += "    		AND SRA.RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += "			AND SRA.RA_DEMISSA = ''
		cQuery += "			AND SRH.RH_MAT <> ''
			
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RH_MAT, "@R 999999"),;//'CodMatricula'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;//'CodEmpresa'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
						DTOC(STOD(QRY->RH_DATABAS)),;				//'PeriodoInicio'
				  		DTOC(STOD(QRY->RH_DBASEAT)),;				//'PeriodoFim'
						'02',;										//'StatusPeriodo'
						DTOC(STOD(QRY->RH_DATAINI)),;	   			//'SaidaFerias'
						DTOC(STOD(QRY->RH_DTRECIB)),;				//'PagtoFerias'
						DTOC(STOD(QRY->RH_DTAVISO)),;				//'AvisoFerias'
						QRY->RH_DFERIAS,;							//'DiasFerias'
						QRY->RH_DABONPE,;							//'DiasAbono'
						,;											//'Opl13Salario'
						,;											//'CodDescanso'
						.F.})										//Deletado

			If aScan(oArq415:aCols, {|x| x[1] == TRANSFORM(QRY->RH_MAT, "@R 999999")}) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 n�o encontrada. Matricula:'"+TRANSFORM(QRY->RH_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	
	Case cTipoInt == '421' //Hist�rico de Afastamentos"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " Left Outer Join (Select * From "+RETSQLNAME("SR8")+" Where D_E_L_E_T_ <> '*') AS SR8 on SR8.R8_FILIAL = SRA.RA_FILIAL
		cQuery += " 			   																			AND SR8.R8_MAT = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += "	AND SRA.RA_DEMISSA = ''
		cQuery += "	AND SR8.R8_TIPO <> 'F'

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->R8_MAT, "@R 999999"),;//'CodMatricula'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodEmpresa'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
						DTOC(STOD(QRY->R8_DATAINI)),;			//'AfastamentoInicio'
				  		DTOC(STOD(QRY->R8_DATAFIM)),;			//'AfastamentoFim'
						GetSitua(QRY->R8_TPEFD),;				//'CodSituacao'
						,;											//'MotivoSituacaoAcidente'
						,;											//'MotivoSituacaoDoenca'
						.F.})										//Deletado

			If aScan(oArq415:aCols, {|x| x[1] == TRANSFORM(QRY->R8_MAT, "@R 999999")}) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 n�o encontrada. Matricula:'"+TRANSFORM(QRY->R8_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
	
	Case cTipoInt == '422' //Hist�rico de Contribui��es Sindicais"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA 
		cQuery += " Left Outer Join (Select * From "+RETSQLNAME("SRD")+" Where D_E_L_E_T_ <> '*') AS SRD on SRD.RD_FILIAL = SRA.RA_FILIAL
		cQuery += " 																						AND SRD.RD_MAT = SRA.RA_MAT
		cQuery += " Left Outer Join (Select * From "+RETSQLNAME("SRV")+" Where D_E_L_E_T_ <> '*') AS SRV on SRD.RD_PD = SRV.RV_COD
		cQuery += " Where SRA.D_E_L_E_T_ <> '*' 
//		cQuery += " 	AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRD.RD_MAT <> ''
		cQuery += " 	AND SRV.RV_CODFOL = '"+STRZERO(68 ,TAMSX3("RV_CODFOL")[1])+"' 

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RD_MAT, "@R 999999"),;//'CodMatricula'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodEmpresa'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
						TRANSFORM(QRY->RA_SINDICA, "@R 99"),;	//'CodSindicato'
						DTOC(STOD(QRY->RD_DATPGT)),;//'DtContribuicao'
						TRANSFORM(QRY->RD_VALOR, "@R 9999.99"),;//'VlrContribuicao'
						.F.})		//Deletado

			If aScan(oArq415:aCols, {|x| x[1] == TRANSFORM(QRY->RD_MAT, "@R 999999")}) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 n�o encontrada. Matricula:'"+TRANSFORM(QRY->RD_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq415:aCols, {|x| x[1] == TRANSFORM(QRY->RD_MAT, "@R 999999")}) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodSindicato: Referencia 4.7 n�o encontrada. Sind.:'"+TRANSFORM(QRY->RA_SINDICA, "@R 99")+"'"+CHR(13)+CHR(10)			)
			EndIf
			
			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

	Case cTipoInt == '423' //Hist�rico de Transfer�ncias"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " 	Left Outer Join (Select * From "+RETSQLNAME("SRE")+" Where D_E_L_E_T_ <> '*') AS SRE on SRE.RE_FILIALP = SRA.RA_FILIAL
		cQuery += " 															   								AND SRE.RE_MATP = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
//		cQuery += " 	AND SRE.RE_EMPD <> SRE.RE_EMPP
		cQuery += "		AND SRE.RE_MATP <> ''
		
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RE_MATP, "@R 999999"),;		//'CodMatricula_Origem'
						STRZERO(ASC(LEFT(QRY->RE_EMPD,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPD,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALD))),;//'CodEmpresa_Origem'
						STRZERO(ASC(LEFT(QRY->RE_EMPD,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPD,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALD))),;//'CodLocal_Origem'
						DTOC(STOD(QRY->RE_DATA)),;			//'Transferencia'
						,;			//'CodMotivo'
						TRANSFORM(QRY->RE_MATP, "@R 999999"),;			//'CodMatricula_Destino'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc_Destino'
						STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))),;//'CodEmpresa_Destino'
						STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))),;//'CodLocal_Destino'
						.F.})												//Deletado

			If aScan(oArq413:aCols, {|x| x[1] == STRZERO(ASC(LEFT(QRY->RE_EMPD,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPD,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALD))) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodEmpresa_Origem: Referencia 4.13 n�o encontrada."+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq414:aCols, {|x| x[1] == STRZERO(ASC(LEFT(QRY->RE_EMPD,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPD,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALD))) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodLocal_Origem: Referencia 4.14 n�o encontrada."+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq413:aCols, {|x| x[1] == STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodEmpresa_Origem: Referencia 4.13 n�o encontrada."+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq414:aCols, {|x| x[1] == STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodLocal_Origem: Referencia 4.14 n�o encontrada."+CHR(13)+CHR(10)			)
			EndIf
			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
		
	Case cTipoInt == '424' //Pensionistas"
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA
		cQuery += " Left Outer Join (Select * From "+RETSQLNAME("SRQ")+" Where D_E_L_E_T_ <> '*'
		cQuery += "																	AND RQ_SEQUENC = '01') AS SRQ on SRQ.RQ_FILIAL = SRA.RA_FILIAL
		cQuery += " 																					   			AND SRQ.RQ_MAT = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
//		cQuery += " 	AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += "		AND SRA.RA_DEMISSA = ''
		cQuery += "	AND SRQ.RQ_MAT <> ''


		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aRet, {TRANSFORM(QRY->RQ_ORDEM, "@R 99"),;			//'CodPensionista'
						TRANSFORM(QRY->RQ_MAT, "@R 999999"),;			//'CodMatricula'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodEmpresa'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
						ALLTRIM(QRY->RQ_NOME),;							//'NomePensionaista'
						TRANSFORM("000000000000000", "@R 999999999999999"),;//'RG'
						TRANSFORM(QRY->RQ_CIC, "@R 999.999.999-99"),;//'CPF'
						,;													//'Nascimento'
						ALLTRIM(TRANSFORM(Substr(QRY->RQ_BCDEPBE,1,3), "@R 999")),;			//'CodBanco'
						ALLTRIM(TRANSFORM(Substr(QRY->RQ_BCDEPBE,4,99), "@R 99999999")),;	//'CodAgencia'
						IIF(AT("-",QRY->RQ_CTDEPBE)<>0,SUBSTR(QRY->RQ_CTDEPBE,1,AT("-",QRY->RQ_CTDEPBE)-1),QRY->RQ_CTDEPBE),;	//'ContaPagamento'			
						IIF(AT("-",QRY->RQ_CTDEPBE)<>0,SUBSTR(QRY->RQ_CTDEPBE,AT("-",QRY->RQ_CTDEPBE)+1,99),""),;				//'DigitoContaPagamento'
						,;													//'CodSexo'
						,;													//'CodTipoendereco'
						,;													//'EnderecoBase'
						,;													//'EnderecoNumero'
						,;													//'EnderecoCompl'
						,;													//'Bairro'
						,;													//'Municipio'
						,;													//'Estado'
						,;													//'Cep'
						,;													//'Telefne'
						.F.})												//Deletado

			If aScan(oArq415:aCols, {|x| x[1] == TRANSFORM(QRY->RQ_MAT, "@R 999999")}) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 n�o encontrada. Matricula:'"+TRANSFORM(QRY->RQ_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo
		
	Case cTipoInt == '425' //Contratados - Vale Transporte" 
		//Sem Informa��es no Sistema

	Case cTipoInt == '426' //Contratados - Benef�cios"
		//Sem Informa��es no Sistema

	Case cTipoInt == '427' //Dependentes - Benef�cios"  
		//Sem Informa��es no Sistema

	Case cTipoInt == '428' //Contratados - Estabilidades"   
		//Sem Informa��es no Sistema
	
	Case cTipoInt == '429' //Ficha Financeira"
	//SUBSTR(QRY->RA_CTDEPSA,1,AT("-",QRY->RA_CTDEPSA)-1)
		cQuery += " Select *
		cQuery += " From "+RETSQLNAME("SRA")+" SRA 
		cQuery += " Left Outer Join (Select * From "+RETSQLNAME("SRD")+" Where D_E_L_E_T_ <> '*') AS SRD on SRD.RD_FILIAL = SRA.RA_FILIAL
		cQuery += " 																						AND SRD.RD_MAT = SRA.RA_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*' 
//		cQuery += " 	AND RA_FILIAL = '"+xFilial("SRA")+"'
//		cQuery += " 	AND SRA.RA_DEMISSA = ''
		cQuery += " 	AND SRD.RD_MAT <> ''

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())

			nVerba := 0			
			If (nPosVerba:=aScan(oArq48:aCols, {|x| SUBSTR(x[3],1,AT("-",x[3])-1) == ALLTRIM(QRY->RD_PD) })) <> 0
				nVerba := oArq48:aCols[nPosVerba][1]
			Else
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodVerba: N�o encontrado referencia em 4.8 - Verba. ->'"+ALLTRIM(QRY->RD_PD)+"'"+CHR(13)+CHR(10))
			EndIf
			
			aAdd(aRet, {TRANSFORM(QRY->RD_MAT, "@R 999999"),;				//'CodMatricula'
						TRANSFORM(QRY->RA_CIC, "@R 999.999.999-99"),;//'CPFNumeroFunc'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodEmpresa'
						STRZERO(ASC(LEFT(cEmpAnt,1)),2)+STRZERO(ASC(RIGHT(cEmpAnt,1)),2)+ALLTRIM(STR(VAL(SRA->RA_FILIAL))),;	//'CodLocal'
						TRANSFORM(RIGHT(QRY->RD_DATARQ,2), "@R 99"),;		//'Mes'
						TRANSFORM(LEFT(QRY->RD_DATARQ,4), "@R 9999"),;	//'Ano'
						nVerba,;												//'CodVerba'
						TRANSFORM(QRY->RD_HORAS, "@R 9999.99"),;			//'QtdVerba'
						TRANSFORM(QRY->RD_VALOR, "@R 99999999999.99"),;	//'VlnVerba'
						DTOC(STOD(QRY->RD_DATPGT)),;						//'DtdVerba'
						,;														//'CodDependente'
						,;														//'CodTipoBeneficio'
						,;														//'CodEmpresaBeneficio'
						.F.})													//Deletado

			If aScan(oArq415:aCols, {|x| x[1] == TRANSFORM(QRY->RD_MAT, "@R 999999")}) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 n�o encontrada. Matricula:'"+TRANSFORM(QRY->RD_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
			EndIf

			//Verifica Campo Obrigatorio Preenchido.
			If Len(aRet) > 0
				For i:=1 To Len(&("a"+cTipoInt))
					If UPPER(&("a"+cTipoInt)[i][6]) == "SIM" .And. EMPTY(aRet[Len(aRet)][i])// .and. !(ALLTRIM(STR(i)) $ "5" )
						cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - "+&("a"+cTipoInt)[i][1]+": Campo obrigatorio em Branco. LINHA = '"+ALLTRIM(STR(Len(aRet)))+"'"+CHR(13)+CHR(10))
					EndIf
				Next i
			EndIf
			QRY->(DbSkip())
		EndDo

EndCase

Return {aRet,cRet}

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function GetDir()
*----------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := ALLTRIM(cDirArq)
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

If !MsgYesNo("Diretorio Atual esta como '"+cDirArq+"'. Deseja alterar mesmo assim?")
	Return .T.
EndIf

cDirArq := ALLTRIM(cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.))

MsgInfo("Diretorio selecionado: '"+cDirArq+"'","HLB BRASIL")

Return .T.

/*
Funcao      : IntHelp
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para Explica��o da Rotina.
Autor       : Jean Victor Rocha.
Data/Hora   : 10/04/2014
*/
*----------------------*
Static Function IntHelp() 
*----------------------*
oDlgHelp := MSDialog():New( aSize[7],200,aSize[6]-100,aSize[5]-200,"Ajuda - HLB BRASIL - Integra��o APDATA",,,.F.,,,,,,.T.,,,.T. )
oTree:= DBTree():New(008,008,((aSize[6]-100)/2)-008,((aSize[5]/2)-200)/4,oDlgHelp,{|| GetHelp()},,.T.)
	oTree:AddItem("Integra��o APDATA"	,"100","UPDINFORMATION" ,,,,1)    
	oTree:TreeSeek("100")     
		oTree:AddItem("Menu"				   				,"110", "SDUORDER",,,,2)
		oTree:TreeSeek("110")        
			oTree:AddItem("Sair"								,"111", "FINAL",,,,2)
			oTree:AddItem("Marca/Desmarca todos"				,"112", "SELECTALL",,,,2)
			oTree:AddItem("Reprocessa Marcados"					,"113", "DEVOLNF",,,,2)
			oTree:AddItem("Diretorio"							,"114", "OPEN",,,,2)
			oTree:AddItem("Gera Arquivos"						,"115", "AVGARMAZEM",,,,2)
			oTree:AddItem("Help"								,"116", "UPDINFORMATION",,,,2)

	oTree:TreeSeek("100")     
		oTree:AddItem("Tipos de Integra��es"				,"120", "SDUORDER",,,,2)
			oTree:TreeSeek("120")
			oTree:AddItem("Browse Integra��es"				  	,"121", "BMPTABLE",,,,2)
	
	oTree:TreeSeek("100")     
		oTree:AddItem("Visualiza��o "  						,"130", "SDUORDER",,,,2)	      
		oTree:TreeSeek("130")
			oTree:AddItem("Oculta"								,"131", "PGPREV",,,,2)
			oTree:AddItem("Vizualizar arquivo"					,"132", "VERNOTA",,,,2)
			oTree:AddItem("Browse Layout"				   		,"133", "BMPTABLE",,,,2)
			oTree:AddItem("Browse Arquivo"				  		,"134", "BMPTABLE",,,,2)
			oTree:AddItem("Visualizar Arquivo"					,"135", "SHORTCUTNEW",,,,2)

	oTree:TreeSeek("100")     
		oTree:AddItem("Console "	   						,"140", "SDUORDER",,,,2)
		oTree:TreeSeek("140")
			oTree:AddItem("Visualizar Console"					,"141", "SHORTCUTNEW",,,,2)	      

	oTree:TreeSeek("100") // Retorna ao primeiro n�vel

oTree:EndTree()

oBmp1 := TBitmap():New(008,(((oWin21:NRIGHT/2))/4)+2,(((aSize[5]/2)-200)/4)*3-016,040,;
						"fwlgn_byyou_slogan.png",,.T.,oDlgHelp,,,.F.,.T.,,"",.T.,,.T.,,.F. )


cHelp := ""
oHelp := tMultiget():New(050,(((oWin21:NRIGHT/2))/4)+2,{|u|if(Pcount()>0,cHelp:=u,cHelp)},;
			oDlgHelp,(((aSize[5]/2)-200)/4)*3-016,((aSize[6]-188)/2)-016,,,,,,.T.)
GetHelp()//Atualiza pela primeira vez

oDlgHelp:Activate(,,,.T.)

Return .T.

/*
Funcao      : GetHelp
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualiza a Descri��o do help
Autor       : Jean Victor Rocha.
Data/Hora   : 10/04/2014
*/
*-----------------------*
Static Function GetHelp()
*-----------------------*
Local cRet := ""
Local nPos := 0
Local aHelp := {}

aAdd(aHelp,{"100","Integra��o APDATA"+CHR(13)+CHR(10)+;
				  "A Equipe de Sistemas da HLB BRASIL desenvolveu a rotina de integra��o APDATA para facilitar a gera��o"+;
				  "de arquivos no padr�o da APDATA."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				  "Este Help foi disponibilizado a fim de auxiliar na correta utiliza��o e entendimento da rotina, caso n�o seja respondida as "+;
				  "duvidas, favor entrar em contato com a Equipe de HelpDesk para que possa ser auxiliado."})
aAdd(aHelp,{"110","Janela - Menu"+CHR(13)+CHR(10)+;
				  "A Janela de Menu possui os principais recursos de manuten��o da rotina."})
aAdd(aHelp,{"111","Sair"+CHR(13)+CHR(10)+;
				  "O Bot�o Sair ira encerrar a rotina de integra��o e retornar para o menu principal do sistema."})
aAdd(aHelp,{"112","Marca/Desmarca todos"+CHR(13)+CHR(10)+;
				  "O Bot�o Marca/Desmarca todos possibilita a sele��o de todas as integra��es com um unico clique."})
aAdd(aHelp,{"113","Reprocessa Marcados"+CHR(13)+CHR(10)+;
				  "O Bot�o Reprocessa Marcados possibilita recarregar as integra��es selecionadas."})
aAdd(aHelp,{"114","Diretorio"+CHR(13)+CHR(10)+;
				  "O Bot�o Diretorio possibilita definir o diretorio para gera��o dos arquivos da integra��o."+CHR(13)+CHR(10)+;
				  "Caso n�o seja informado, sera adotado como padr�o a cria��o de uma pasta no C: com o nome GPE2APDATA."})
aAdd(aHelp,{"115","Gera Arquivos"+CHR(13)+CHR(10)+;
				  "O Bot�o Gera Arquivos ira processar as integra��es selecionadas e gerar os arquivos na pasta informada."+CHR(13)+CHR(10)+;
				  "Em caso de erro na integra��o esta n�o permitira a execu��o da gera��o."})
aAdd(aHelp,{"116","Help"+CHR(13)+CHR(10)+;
				  "O Bot�o Help ir� apresentar as principais funcionalidades da rotina."})
aAdd(aHelp,{"120","Tipos de Integra��es"+CHR(13)+CHR(10)+;
				  "A Janela de possibilita a visualiza��o das integra��es disponiveis"})
aAdd(aHelp,{"121","Browse Integra��es"+CHR(13)+CHR(10)+;
				  "Apresenta as integra��es disponiveis no sistema com base no layout da APDATA."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				  "Op��o Marcar: Possibilita a sele��o* da integra��o."+CHR(13)+CHR(10)+;
				  "		*Caso a integra��o selecionada tenha como dependencia outras integra��es, o sistema ira seleciona-las."+CHR(13)+CHR(10)+;
				  "Status: Atraves das cores do status � possivel verificar as integra��es. Para maiores informa��es das cores"+CHR(13)+CHR(10)+;
				  "		Clicar duas vezes sobre qualquer status para ser aberta a janela de Legendas."+CHR(13)+CHR(10)+;
				  "Nome do Arquivo: � possivel verificar na linha da integra��o o Nome do Arquivo que ser� gerado."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				  "Obs: Ao posicionar o registro as telas de Visualiza��o e Console ser�o atualizadas com as informa��es da Integra��o Selecionada."})
aAdd(aHelp,{"130","Visualiza��o "+CHR(13)+CHR(10)+;
				  "A Janela de de Visualiza��o possibilita a analise das informa��es da integra��o selecionada"})	      
aAdd(aHelp,{"131","Oculta"+CHR(13)+CHR(10)+;
				  "Bot�o para Ocultar ou expandir o Browse de Layout."})
aAdd(aHelp,{"132","Vizualizar arquivo"+CHR(13)+CHR(10)+;
				  "Bot�o para troca de forma de visualiza��o para o mesmo formato que ir� ficar o arquivo."})
aAdd(aHelp,{"133","Browse Layout"+CHR(13)+CHR(10)+;
				  "Este browse apresenta o layout definido pela APDATA, possibilitando uma analise criteriosa dos dados."})
aAdd(aHelp,{"134","Browse Arquivo"+CHR(13)+CHR(10)+;
				  "Este Browse possibilita a analise dos dados que foram processados, em formato de tabela."})
aAdd(aHelp,{"135","Visualizar Arquivo"+CHR(13)+CHR(10)+;
				  "Esta visualiza��o possibilita a visualiza��o dos dados que foram processados no mesmo formado em que o arquivo ser� gerado."})
aAdd(aHelp,{"140","Console "+CHR(13)+CHR(10)+;
				  "A Janela de permite a analise de mensagens de processamento."})
aAdd(aHelp,{"141","Visualizar Console"+CHR(13)+CHR(10)+;
				  "Esta visualiza��o permite a analise dos erros gerados."})

If (nPos:=aScan(aHelp,{|x| x[1] == oTree:GetCargo() })) <> 0
	cRet := aHelp[nPos][2]
EndIf

cHelp := cRet
EVAL(oHelp:BSETGET)
oHelp:SetFocus()

Return .T.

/*
Funcao      : GetCodInt()
Parametros  : 
Retorno     : 
Objetivos   : Fun��o para retornar a configura��o de cada Integra��o.
Autor       : Jean Victor Rocha
Data/Hora   : 28/03/2014
*/
*---------------------------------*
Static Function GetCodInt(cTipoInt)
*---------------------------------*
Local aRet := {}

Do Case
	Case cTipoInt == '41' //Bancos"
		aAdd(aRet,{'CodBanco'			,'N','09','C�digo do Banco'								,''											,'Sim',.F.})
		aAdd(aRet,{'Banco'				,'A','32','Nome do Banco'								,''											,'Sim',.F.})
		aAdd(aRet,{'BancoRes'			,'A','16','Nome resumido do banco'						,''											,'N�o',.F.})
		aAdd(aRet,{'NuiOficial'			,'N','03','N�mero oficial do banco'						,''											,'Sim',.F.})
		
	Case cTipoInt == '42' //Ag�ncias Banc�rias"
		aAdd(aRet,{'CodAgenciaBanco'	,'N','09','C�digo da ag�ncia' 							,''											,'Sim',.F.})
		aAdd(aRet,{'CodBanco'			,'N','09','C�digo do Banco'	   							,'C�digo relacionado ao arquivo Bancos.txt'	,'Sim',.F.})
		aAdd(aRet,{'AgenciaBanco'		,'A','32','Descri��o da ag�ncia'						,''											,'Sim',.F.})
		aAdd(aRet,{'NuiOficial'			,'N','09','N�mero oficial da agencia'					,''											,'Sim',.F.})
		aAdd(aRet,{'AgenciaDigito'		,'A','02','D�gito da ag�ncia'		 					,''											,'Sim',.F.})

	Case cTipoInt == '43' //CBO"
		aAdd(aRet,{'CodCBO'				,'N','09' ,'C�digo Brasileiro de Ocupa��o'				,''											,'Sim',.F.})
		aAdd(aRet,{'CBO'				,'A','07' ,'Classifica��o Brasileira de Ocupa��es- CBO'	,'Ex.: 9999-99'								,'Sim',.F.})
		aAdd(aRet,{'DsCBO'				,'A','100','Descri��o do CBO'							,''											,'Sim',.F.})
		
	Case cTipoInt =='44' //Cargos"
		aAdd(aRet,{'CodCargo'			,'N','09','C�digo do Cargo'		   	 					,''									 		,'Sim',.F.})
		aAdd(aRet,{'Cargo'	   			,'A','70','Descri��o do Cargo'							,''									   		,'Sim',.F.})
		aAdd(aRet,{'CargoRes'  			,'A','32','Descri��o Resumo do Cargo'					,''									   		,'N�o',.F.})
		aAdd(aRet,{'CodCBO'	   			,'A','09','Codigo do CBO'								,'C�digo relacionado ao arquivoCBO.txt'		,'Sim',.F.})
		
	Case cTipoInt =='45' //Centros de Custo"
		aAdd(aRet,{'CodCentroCusto'		,'N','09','C�digo do Centro de Custo'	   	   			,''									   		,'Sim',.F.})
		aAdd(aRet,{'CentroCusto'		,'A','40','Descri��o do Centro de Custo'   				,''									   		,'Sim',.F.})
		aAdd(aRet,{'CentroCustoRes'		,'A','20','Descri��o Resumo do Centro de Custo'			,''									   		,'Sim',.F.})
		aAdd(aRet,{'Estrutura'			,'A','32','Estrutura do Centro de Custo'   				,''									   		,'Sim',.F.})
		
	Case cTipoInt =='46' //Hor�rios" 
		aAdd(aRet,{'CodHorario'			,'N','09','C�digo do Hor�rio'							,''									   		,'Sim',.F.})
		aAdd(aRet,{'Horario'			,'A','100','Descri��o do Hor�rio'						,''									   		,'Sim',.F.})
		aAdd(aRet,{'QtiHorasSemanal'	,'N','02','Qtde de Horas Semanais'						,''									   		,'Sim',.F.})
		aAdd(aRet,{'QtiHorasMensais'	,'N','03','Qtde de Horas Mensais'						,''									   		,'Sim',.F.})
		aAdd(aRet,{'QtiHorasDia'		,'C','05','Qtde de Horas Di�ria'						,'Exemplo: 07:33'							,'Sim',.F.})
		
	Case cTipoInt =='47' //Sindicato"
		aAdd(aRet,{'CodSindicato'		,'N','05','Codigo do Sindicato'							,''				 			   				,'Sim',.F.})
		aAdd(aRet,{'Sindicato'			,'A','70','Nome do Sindicato'							,''				 							,'Sim',.F.})
		aAdd(aRet,{'SindicatoResumo'	,'A','25','Nome Resumido do Sindicato'					,''				 							,'N�o',.F.})
		aAdd(aRet,{'MesDissidio'		,'N','02','M�s do diss�dio'								,''				 							,'Sim',.F.})
		aAdd(aRet,{'CodTipoEndereco'	,'N','03','C�digo do tipo de Endere�o'					,'Tab.De/Para'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endere�o Base'		   						,'Ex.: Durval Jose de Barros'				,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','N�mero do Endere�o'							,'Ex.: 162'									,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do Endere�o'						,'Ex.: Sala 1'								,'N�o',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''				 							,'Sim',.F.})
		aAdd(aRet,{'Cep'				,'N','09','Cep'				   							,'M�scara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Munic�pio'		   							,''				   							,'Sim',.F.})
		aAdd(aRet,{'Estado'		   		,'N','02','Id Estado'		  							,'Tab.De/Para'								,'Sim',.F.})
		aAdd(aRet,{'CNPJ'		   		,'N','18','CNPJ do Sindicato'							,'M�scara ##.###.###/####-##'				,'Sim',.F.})
		aAdd(aRet,{'DDDTelefone'   		,'N','2','DDD do Telefone contato'						,'Ex. 11'									,'N�o',.F.})
		aAdd(aRet,{'Telefone'	   		,'N','9','Telefone contato'								,'Ex. 1234-5678'							,'N�o',.F.})

	Case cTipoInt =='48' //Verbas" 
		aAdd(aRet,{'CodVerba'	   		,'N','09','C�digo da Verba'								,''			   								,'Sim',.F.})
		aAdd(aRet,{'CodNaturezaVerba'	,'N','02','C�digo da Natureza da Verba'					,'Tab. De/Para'								,'Sim',.F.})
		aAdd(aRet,{'Verba'	   	   		,'A','40','Descri��o da Verba'							,''			   								,'Sim',.F.})
		aAdd(aRet,{'VerbaRes'	   		,'A','16','Descri��o Resumo da Verba'					,''			   								,'N�o',.F.})
		aAdd(aRet,{'CodTipoVerba'  		,'N','02','Tipo de Verba'				 				,'Tab. De/Para'								,'Sim',.F.})
		aAdd(aRet,{'IncideINSS'	   		,'N','01','Incide INSS'				 					,'0 - N�o 1 - Sim'							,'Sim',.F.})
		aAdd(aRet,{'IncideFGTS'	   		,'N','01','Incide FGTS'				 			  		,'0 - N�o 1 - Sim'							,'Sim',.F.})
		aAdd(aRet,{'IncideIRRF'	   		,'N','01','Incide IRRF'							  		,'0 - N�o 1 - Sim'							,'Sim',.F.})
		
	Case cTipoInt =='49' //Meios de transportes" 
		aAdd(aRet,{'CodMeioTransporte'	,'N','09','C�digo do Meio de Transporte'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'Descricao'			,'A','70','Descri��o do Meio de Transporte'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'ValorTarifa'		,'N','09','Valor da Tarifa'								,'Ex. 2.30'			   						,'Sim',.F.})
		aAdd(aRet,{'DtdVigenciaTarifa'	,'D','10','Data Vigente da Tarifa'						,'Ex. "01/12/2009"'							,'Sim',.F.})
		aAdd(aRet,{'DescMeioMagnetico'	,'A','20','Descri��o do Meio Magn�tico'					,''			   								,'N�o',.F.})
		aAdd(aRet,{'DescOperadora'		,'A','20','Descri�a� da Operadora'						,''			   								,'N�o',.F.})
		aAdd(aRet,{'DescTipoBilhete'	,'A','20','Descri��o do Tipo de Bilheto'				,''			   								,'N�o',.F.})
 
	Case cTipoInt =='410' //Tipos de Beneficios"
		aAdd(aRet,{'CodTipoBeneficio'	,'N','09','C�digo do Tipo do Benef�cio Sim'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'Descricao'			,'A','50','Descri��o do Tipo do Benef�cio Sim'			,''			   								,'Sim',.F.})

	Case cTipoInt =='411' //Empresas de Benneficios
		aAdd(aRet,{'CodEmpresaBeneficio','N','05','C�digo da Empresa Benef�cio'					,''			   								,'Sim',.F.})
		aAdd(aRet,{'Nome'				,'A','50','Nome da Empresa Benef�cio'			  		,''			   								,'Sim',.F.})
		aAdd(aRet,{'CNPJ'				,'N','18','CNPJ do Local'								,'M�scara ##.###.###/####-##'				,'Sim',.F.})
		aAdd(aRet,{'TipoEndereco'		,'N','03','Id Tipo de Endere�o '						,'Tab DE/PARA'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endere�o Base'								,'Ex.: Durval de Barros'					,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','N�mero do endere�o'							,'Ex.: 26'									,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do endere�o'						,' Ex.: Fundos'								,'N�o',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''			   								,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Munic�pio'									,''			   								,'Sim',.F.})
		aAdd(aRet,{'Cep'   				,'N','09','CEP'											,'m�scara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'Estado'				,'N','02','Id do Estado'								,'Tab DE/PARA'				  				,'Sim',.F.})
		aAdd(aRet,{'TelefoneDDD'		,'N','02','DDD do telefone'								,'Ex. 11'									,'N�o',.F.})
		aAdd(aRet,{'TelefoneNum'		,'N','09','N�mero do telefone'							,' m�scara 9999-9999'						,'N�o',.F.})
		
	Case cTipoInt =='412' //Empresas de Institui��es de Ensino"
		aAdd(aRet,{'CodInstEnsino'		,'N','05','C�digo da Institui��o de Ensino'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'Nome'				,'A','50','Nome da Institui��o de Ensino'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'CNPJ'				,'N','18','CNPJ do Local'								,'M�scara ##.###.###/####-##'				,'Sim',.F.})
		aAdd(aRet,{'TipoEndereco'		,'N','03','Id Tipo de Endere�o'							,'Tab DE/PARA'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endere�o Base'								,'Ex.: Durval de Barros'					,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','N�mero do endere�o'							,'Ex.: 26'									,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do endere�o'						,' Ex.: Fundos'								,'N�o',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''			   								,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Munic�pio'									,''			   								,'Sim',.F.})
		aAdd(aRet,{'Cep'				,'N','09','CEP'											,'m�scara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'Estado'				,'N','02','Id do Estado'								,'Tab DE/PARA'				  				,'Sim',.F.})
		aAdd(aRet,{'TelefoneDDD'		,'N','02','DDD do telefone'								,'Ex. 11'				  					,'N�o',.F.})
		aAdd(aRet,{'TelefoneNum'		,'N','09','N�mero do telefone'							,' m�scara 9999-9999'						,'N�o',.F.})

	Case cTipoInt =='413' //Empresas"
		aAdd(aRet,{'CodEmpresa'			,'N','05','C�digo da empresa'							,''			   								,'Sim',.F.})
		aAdd(aRet,{'Empresa'			,'A','60','Nome da Empresa'								,''			   								,'Sim',.F.})
	
	Case cTipoInt =='414' //Locais"
		aAdd(aRet,{'CodLocal'  			,'N','05','C�digo do Local'								,'Matriz ou Filial'							,'Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			,'N','05','C�digo da Empresa'							,'C�d. relacionado ao arquivo Empresas.txt'	,'Sim',.F.})
		aAdd(aRet,{'Local'				,'A','32','Nome do Local'								,'Matriz ou Filial'					  		,'Sim',.F.})
		aAdd(aRet,{'TipoInscricao'		,'N','01','Id Tipo de Inscri��o'						,' 1 - CNPJ 2 - CEI'						,'Sim',.F.})
		aAdd(aRet,{'CNPJ'				,'N','18','CNPJ'										,'M�sc ##.###.###/####-##,Conforme campo TipoInscricao','Sim',.F.})
		aAdd(aRet,{'CEI'				,'A','12','N�mero da matricula CEI do Local'			,'Conforme campo TipoInscricao'				,'Sim',.F.})
		aAdd(aRet,{'CodTipoEndereco'	,'N','03','Id Tipo de Endere�o'							,'Tab DE/PARA'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endere�o Base'								,''			   								,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','N�mero do endere�o'							,''			   								,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do endere�o'						,''			   								,'N�o',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''			   								,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Munic�pio'									,''			   								,'Sim',.F.})
		aAdd(aRet,{'NusCep'				,'N','09','CEP'											,'m�scara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'CodEstado'			,'N','02','Id do Estado'								,'Tabela complementar - Estados'			,'Sim',.F.})
		aAdd(aRet,{'TelefoneDDD'		,'N','02','DDD do telefone'								,''			   								,'N�o',.F.})
		aAdd(aRet,{'TelefoneNum'		,'N','09','N�mero do telefone'							,'m�scara 9999-9999'						,'N�o',.F.})
		
	Case cTipoInt =='415' //Contratados"
		aAdd(aRet,{'CodMatricula'  				,'N','09','Matricula do Contratatdo','','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'	   				,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'	   				,'N','05','Local do Contratado','C�digo relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Nome'		   				,'A','30','Nome do Contratado','','Sim',.F.})
		aAdd(aRet,{'NomeCompleto'  				,'A','60','Nome completo do contratado','','Sim',.F.})
		aAdd(aRet,{'Apelido'   	   				,'A','20','Apelido do Contratado','','Sim',.F.})
		aAdd(aRet,{'NomePai'	   				,'A','60','Nome do Pai do Contratado','','Sim',.F.})
		aAdd(aRet,{'NomeMae'	   				,'A','60','Nome da M�e do Contratado','','Sim',.F.})
		aAdd(aRet,{'CodSexo'	   				,'N','01','Sexo do Contratado',' 1-M 2-F','Sim',.F.})
		aAdd(aRet,{'Admissao'	   				,'N','10','Data da Admiss�o do contratado','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'TipoAdmissaoESocial'		,'N','01','Tipo de Admiss�o eSocial','1 - Admiss�o. 2 - Transfer�ncia de Empresa do Mesmo Grupo Econ�mico.3 - Admiss�o por Sucess�o, Incorpora��o ou Fus�o.4 - Trabalhador Cedido.','Sim',.F.})
		aAdd(aRet,{'ModoAdmissaoESocial'		,'N','01','Modo de Admiss�o eSocial','1 - Normal 2 - Decorrente de A��o Fiscal 3 - Decorrente de Decis�o Judicial','sim',.F.})
		aAdd(aRet,{'PrazosContrato'				,'N','01','Prazos do Contrato','','Sim',.F.})
		aAdd(aRet,{'CNPJ EmpresaOrigem'			,'N','14','CNPJ Empresa Origem Formato 99.999.999/9999-99 Para admiss�o por sucess�o ou trantransfer�ncia d','Formato 99.999.999/9999-99 Para admiss�o por sucess�o ou trantransfer�ncia d','Sim',.F.})
		aAdd(aRet,{'MatriculaEmpresaOrigem'		,'A','20','Matr�cula Empresa Origem',' Idem CNPJ Empresa Origem.','Sim',.F.})
		aAdd(aRet,{'AdmissaoEmpresaOrigem'		,'D','10','Data Admiss�o Empresa Origem',' Idem CNPJ Empresa Origem.','Sim',.F.})
		aAdd(aRet,{'CodCentroCusto'				,'N','09','Centro de custo do contratado Relacionado ao CentrosCusto.txt',' Relacionado ao CentrosCusto.txt','Sim',.F.})
		aAdd(aRet,{'CodCargo'	   				,'N','09','Cargo do contratado','Relacionado ao arquivo Cargos.txt. Informar o cargo atual, o mesmo relativo','Sim',.F.})
		aAdd(aRet,{'CodHorario'	  				,'N','09','C�digo do Hor�rio',' Relacionado ao arquivo Horarios.txt','Sim',.F.})
		aAdd(aRet,{'CodSindicato'				,'N','09','C�digo do Sindicato','Relacionado ao arquivo Sindicatos.txt','Sim',.F.})
		aAdd(aRet,{'CodCategoria'				,'N','02','C�digo da Categoria',' Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'CodVinculo'	   				,'N','02','C�digo do V�nculo',' Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'EMail'			  			,'A','50','E-mail do contratado','','N�o',.F.})
		aAdd(aRet,{'EMailPessoal'	  			,'A','50','E-mail Pessoal do Contratado','','N�o',.F.})
		aAdd(aRet,{'Salario'	   				,'N','15','Valor do Sal�rio','M�scara ##########,## Informar o sal�rio atual, o mesmo relativo � �ltima altera��o do hist�rico de sal�rios','Sim',.F.})
		aAdd(aRet,{'CodSituacaoSindical'		,'N','01','Situa��o sindical do contatado',' 1 - Paga Particular 2 - J� Pagou no Ano 3 - N�o Pagou no Ano, DeDesconta no Pr�ximo M�s4 - N�o Pagou no Ano, Desconta no M�s','Sim',.F.})
		aAdd(aRet,{'CodTipoEmprego'	   			,'N','01','Tipo de emprego para o CAGED','1 - Primeiro Emprego 2 - Re-Emprego 4 - Reintegra��o em Meses Anteriores','Sim',.F.})
		aAdd(aRet,{'Drt'			  			,'N','09','N�mero do DRT do contratado','','N�o',.F.})
		aAdd(aRet,{'Nascimento'					,'D','10','Data de Nascimento',' Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'OpcaoFGTS'					,'D','10','Data da Op��o do FGTS','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodNacionalidade'  			,'N','02','C�digo da Nacionalidade',' Cod RAIS Ex.10-Brasileira','Sim',.F.})
		aAdd(aRet,{'CodEstado_Naturalidade'		,'N','02','C�digo do estado de nascimento','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'NascimentoLocal'	   		,'A','35','Munic�pio de Nascimento','','N�o',.F.})
		aAdd(aRet,{'CodigoMunicipio'			,'N','07','C�digo do Munic�pio de Nascimento',' Conforme tabela de Munic�pios do IBGE','Sim',.F.})
		aAdd(aRet,{'CodGrauInstrucao'			,'N','02','C�digo do grau de instru��o','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'CodEstadoCivil'	  			,'N','01','C�digo do estado civil','1 - Solteiro 2 - Casado 3 - Viuvo 4 - Desquitado 5 - Marital 6 - Divorciada 7-Outros','Sim',.F.})
		aAdd(aRet,{'CodCorPele'					,'N','01','C�digo da cor da pele',' 2 - Branca 4 - Negra 6 - Amarela 1 - Ind�gena 8 - Parda 9 - N�o informada','ada',.F.})
		aAdd(aRet,{'ResidenciaPropria'			,'N','01','Reside em resid�ncia pr�pria',' 0 - N�o 1 - Sim','N�o',.F.})
		aAdd(aRet,{'AquisicaoImovel'			,'N','01','Im�vel adquirido com recursos do FGTS.',' 0 - N�o 1 - Sim','N�o',.F.})
		aAdd(aRet,{'CodTipoEndereco'			,'N','02','C�digo do tipo de endere�o','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'EnderecoBase'	 			,'A','40','Endere�o base','','Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'	 			,'A','07','N�mero do endere�o','','Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'			,'A','20','Complemento do endere�o','','N�o',.F.})
		aAdd(aRet,{'Bairro'						,'A','25','Bairro','','Sim',.F.})
		aAdd(aRet,{'Municipio'					,'A','35','Munic�pio','','Sim',.F.})
		aAdd(aRet,{'CodEstado_Resid'			,'N','02','C�digo do estado','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'Cep'						,'N','09','N�mero do CEP','Formato 99999-999','Sim',.F.})
		aAdd(aRet,{'TelefoneDDD_Resid'			,'N','02','DDD do telefone residencial','','N�o',.F.})
		aAdd(aRet,{'TelefoneNumero_Resid'		,'N','09','N�mero do telefone residencial','Formato 9999-9999','N�o',.F.})
		aAdd(aRet,{'TelefoneCelularDDD'			,'N','02','DDD do telefone celular','','N�o',.F.})
		aAdd(aRet,{'TelefoneCelular'			,'N','09','N�mero do telefone celular','Formato 9999-9999','N�o',.F.})
		aAdd(aRet,{'CPFNumero'					,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'NumeroPis'					,'N','14','N�mero do PIS','Formato 999.9999.999-9','Sim',.F.})
		aAdd(aRet,{'EmisPis'					,'D','10','Emiss�o do PIS','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'NumeroCarProf'				,'A','08','N�mero da carteira profissional','','Sim',.F.})
		aAdd(aRet,{'SerieCarProf'				,'A','08','S�rie da carteira profissional','','Sim',.F.})
		aAdd(aRet,{'EmisCartProf'				,'D','10','Emiss�o da carteira profissional','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodEstado_CarProf'			,'N','02','C�digo do estado da CTPS','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'NumeroRg'					,'A','15','N�mero do RG','Formato 99.999.999-9','Sim',.F.})
		aAdd(aRet,{'EmisRG'						,'D','10','Data de emiss�o do RG','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodEstado_OrgaoRg'			,'N','02','C�digo do estado do RG','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'OrgaoRg'					,'A','06','Org�o emissor do RG','','Sim',.F.})
		aAdd(aRet,{'NumeroRIC'					,'N','12','N�mero do Registro de Identidade Civil','','N�o',.F.})
		aAdd(aRet,{'OrgaoEmissorRIC'			,'A','20','�rg�o Emissor do RIC','','N�o',.F.})
		aAdd(aRet,{'EmissaoRIC'					,'D','10','Data de Emiss�o do RIC',' formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'Reservista'					,'A','15','N�mero da Reservista','','N�o',.F.})
		aAdd(aRet,{'NumeroIdentEstrangeiro'		,'A','14','N�mero da Identidade de Estrang.','','N�o',.F.})
		aAdd(aRet,{'OrgaoEmissorIdentEstrang'	,'A','20','�rg�o Emissor Ident de Estrangeiro','','N�o',.F.})
		aAdd(aRet,{'DataExpedicaoIdentEstrang'	,'D','10','Data Expedi��o Ident de Estrang',' formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'NumeroDocumentoClasse'		,'A','20','N�mero Documento de Classe','','N�o',.F.})
		aAdd(aRet,{'OrgaoEmissorDocClasse'		,'A','20','�rg�o Emissor Doc. de Classe','','N�o',.F.})
		aAdd(aRet,{'EmissaoDocClasse'			,'D','10','Data de Emiss�o Doc. de Classe',' formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'ValidadeDocClasse'			,'D','10','Data Validade Doc. de Classe',' formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'NumeroTitEleitor'			,'A','13','N�mero do t�tulo de eleitor','','Sim',.F.})
		aAdd(aRet,{'SecaoTitEleitor'			,'N','04','Se��o do t�tulo de eleitor','','Sim',.F.})
		aAdd(aRet,{'ZonaTitEleitor'				,'N','04','Zona do t�tulo de eleitor','','Sim',.F.})
		aAdd(aRet,{'MunicipioTitEleitor'		,'A','35','Munic�pio do t�tulo de eleitor','','N�o',.F.})
		aAdd(aRet,{'CodEstadoTitEleitor'		,'N','02','C�digo do Estado do Titulo de Eleitor','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'EmisTitEleitor'				,'D','10','Data de emiss�o do titulo de eleitor',' Formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'CnhN�mero'					,'N','14','N�mero da CNH',' Formato 99.999.999.999','N�o',.F.})
		aAdd(aRet,{'CnhVencimento'				,'D','10','Data de vencmento da habilita��o','Formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'CnhTipo'					,'A','03','Tipo da habilita��o',' Ex.: A - Categoria Motos B - Categoria Ve�culos Leves','N�o',.F.})
		aAdd(aRet,{'OrgaoEmissorCNH'			,'A','20','�rg�o Emissor da CNH','','N�o',.F.})
		aAdd(aRet,{'Emiss�oCNH'					,'D','10','Data da Emiss�o da CNH','Formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'CodBanco'					,'N','09','C�digo do banco para pagamento do contratado. t','C�digo relacionado ao arquivo Bancos.tx','Sim',.F.})
		aAdd(aRet,{'CodAgencia'					,'N','09','C�digo da ag�ncia para credito do contratado.','C�digo relacionado ao arquivo Agencias .txt','Sim',.F.})
		aAdd(aRet,{'PagamentoConta'				,'A','30','N�mero da conta de pagamento do contratado','','Sim',.F.})
		aAdd(aRet,{'PagamentoContaDigito'		,'A','02','D�gito da conta de pgamento do contratado','','Sim',.F.})
		aAdd(aRet,{'CodExposicaoAgenteNocivo'	,'N','01','C�digo de exposi��o do agente nocivo',' Tab DE/PARA','N�o',.F.})
		aAdd(aRet,{'Insalubridade'		  		,'N','7,2','Percentual de insalubridade',' Formato 99999.99','N�o',.F.})
		aAdd(aRet,{'Periculosidade'				,'N','7,2','Percentual de periculosidade','Formato 99999.99','N�o',.F.})
		aAdd(aRet,{'DepSalFamilia'				,'N','02','N�mero de dependentes para SF','','Sim',.F.})
		aAdd(aRet,{'DepImpRenda'				,'N','02','N�mero de dependentes para IR','','Sim',.F.})
		aAdd(aRet,{'CodSituacao'				,'N','01','Situa��o do Contratado','A - Ativo D - Demitido','Sim',.F.})
		aAdd(aRet,{'Rescisao'					,'D','10','Data da rescis�o','Somento com situa��o do contratado for igual a D-Demitido, Fomato DD/MM/AAAA (*1)','Sim',.F.})
		aAdd(aRet,{'RescisaoPagto'				,'D','10','Data do pagamento da rescis�o','Somento com situa��o do contratado for igual a D-Demitido, Formato DD/MM/AAAA ( * 1 )','Sim',.F.})
		aAdd(aRet,{'CodDesligamento'			,'N','02','C�digo do desligamento',' Somento com situa��o do contratado for igual a D-Demitido, ( * 1 ) Tab De','Sim',.F.})
		aAdd(aRet,{'Aposentado'					,'N','01','Op��o de aposentado',' 0 - N�o 1 - Sim','N�o',.F.})
		aAdd(aRet,{'Aposentadoria'				,'D','10','Data da aposentadoria','Formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'CodTipoDeficiencia'			,'N','02','Tipos de Defici�ncia','Tab DE/PARA','N�o',.F.})
		aAdd(aRet,{'Naturalizado'				,'N','01','Op��o de naturalizado','( * 3 ), Tabela Complementar Tab DE/PARA','N�o',.F.})
		aAdd(aRet,{'DataNaturalizacao'			,'D','10','Data de Naturaliza��o','Formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'DtdChegadaPais'				,'D','10','Data de chegada no pa�s',' Formato DD/MM/AAAA ( * 3 )','N�o',.F.})
		aAdd(aRet,{'CosTipoVisto'				,'A','02','C�digo do tipo de visto','( * 3 )','N�o',.F.})
		aAdd(aRet,{'NusRNE'						,'A','13','N�mero do RNE',' ( * 3 )','N�o',.F.})
		aAdd(aRet,{'CasadoBrasileira(o)'		,'N','01','Op��o de casado com brasileiro(a) caso seja estrangeiro.',' 0 - N�o 1 - Sim','N�o',.F.})
		aAdd(aRet,{'FilhosBrasileiro'			,'N','01','Tem filho(s) brasileiro caso seja estrangeiro.',' 0 - N�o 1 - Sim','N�o',.F.})
		aAdd(aRet,{'EnderecoExterior'			,'A','80','Endere�o no Exterior','','N�o',.F.})
		aAdd(aRet,{'EnderecoExteriorNum'		,'A','10','N�mero do Endere�o no Exterior','','N�o',.F.})
		aAdd(aRet,{'EnderecoExteriorCompl'		,'A','20','Complemento Endere�o no Exterior','','N�o',.F.})
		aAdd(aRet,{'EnderecoExteriorBai'		,'A','30','Bairro do Endere�o no Exterior','','N�o',.F.})
		aAdd(aRet,{'EnderecoExteriorMunic'		,'A','30','Munic�pio do Endere�o no Exterior','','N�o',.F.})
		aAdd(aRet,{'EnderecoExteriorEstado'		,'A','40','Estado do Endere�o no Exterior','Estado ou Prov�ncia','N�o',.F.})
		aAdd(aRet,{'EnderecoExteriorCEP'		,'N','08','CEP do Endere�o no Exterior','formato 99999-999','N�o',.F.})
		aAdd(aRet,{'EnderecoExteriorPais'		,'N','05','Pa�s do Endere�o no Exterior','idem Nacionalidades','N�o',.F.})
		aAdd(aRet,{'NivelEstagio'				,'N','01','N�vel est�gio para estagi�rios','1 - Fundamental 2 - M�dio3 - Forma��o Profissional4 - Superior','N�o',.F.})
		aAdd(aRet,{'InstituicaoEnsino'			,'N','05','C�digo institui��o de ensino do estagi�rio','Relacionado a tabela EmpresasEnsino','N�o',.F.})
		aAdd(aRet,{'ApoliceSeguro'				,'A','30','Ap�lice de Seguro para estagi�rios','','N�o',.F.})
		aAdd(aRet,{'AreaAtuacao'				,'A','50','�rea de atua��o do estagi�rio','','N�o',.F.})
			
	Case cTipoInt =='416' //Dependentes"
		aAdd(aRet,{'CodDependente'				,'N','09','C�digo do Dependente','','Sim',.F.})
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','C�digo relacionado ao arquivoContratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do contratado','C�digo relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Nome'						,'A','60','Nome do dependente','','Sim',.F.})
		aAdd(aRet,{'Nascimento'		   			,'D','10','Data de Nascimento','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'GrauParentesco'				,'N','02','Grau de Parentesco','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodSexo'		   			,'N','01','C�digo do sexo','1 - M 2 - F','Sim',.F.})
		aAdd(aRet,{'CodGrauInstrucao'			,'N','02','Grau de instru��o do dependente','Tab DE/Para','N�o',.F.})
		aAdd(aRet,{'CodSituacaoDependente'		,'N','01','Situa��o do dependente','1 - Normal 2 - Inv�lido','Sim',.F.})
		aAdd(aRet,{'CodEstadoCivil'		  		,'N','01','C�digo do estado civil do dependente',' Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'SalarioFamilia'		  		,'N','01','Considerar dependente para Sal�rio Fam�lia','0 -N�o 1- Sim','Sim',.F.})
		aAdd(aRet,{'ImpRenda'		  			,'N','01','Considerar dependente para Imposto de Renda','0 -N�o 1- Sim','Sim',.F.})
		aAdd(aRet,{'VaciniFreqEsc'		  		,'N','01','Vacina��o e frequ�ncia escolar OK?','0 -N�o 1- Sim','Sim',.F.})
		aAdd(aRet,{'CartorioNome'		  		,'A','30','Nome do Cart�rio','','N�o',.F.})
		aAdd(aRet,{'CartorioRegNasc'			,'A','16','N� da Certid�o de Nascimento','','N�o',.F.})
		aAdd(aRet,{'CartorioLivroReg'			,'A','16','N� da livro de Registro','','N�o',.F.})
		aAdd(aRet,{'CartorioFolhaReg'			,'A','16','N� do folha de Registro','','N�o',.F.})
		aAdd(aRet,{'DtdCertidaoNasc'			,'D','10','Data da Certid�o de Nascimento','formato DD/MM/AAAA','N�o',.F.})
		aAdd(aRet,{'CPF Numero'		   			,'N','14','N�mero do CPF - obrigat�rio para maiores de 18 anos.','formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CNS Numero'		  			,'N','18','N�mero do Cart�o Nacional de Sa�de','','N�o',.F.})
		aAdd(aRet,{'Companheiro'		  		,'N','01','� companheiro n�o casado ha mais de cinco anos.','0 - N�o 1 - Sim','Sim',.F.})
		aAdd(aRet,{'Cursando Escola T�cnica'	,'N','01','� filho ou enteado Universit�rio(a) ou cursando escola t�cnica de 2o.grau, at� 24 anos.','0 - N�o 1 - Sim','Sim',.F.})
		aAdd(aRet,{'Guarda Judicial'			,'N','01','� irm�o, neto ou bisneto sem arrimo dos pais, do qual detenha a guarda judicial.','0 - N�o 1 - Sim','Sim',.F.})
		aAdd(aRet,{'Tipo Dependente eSocial'	,'N','01','Tipo de dependente para o eSocial','Tab DE/Para','N�o',.F.})

	Case cTipoInt =='417' //Hist�rico de Sal�rios" 
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do Contratado','Relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Alteracao'			 		,'D','10','Data da Altera��o','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'Motivo'			   			,'N','04','Motivo da Altera��o','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'VlnSalario'					,'N','12','Valor do Sal�rio','M�scara ##########.##','Sim',.F.})

	Case cTipoInt =='418' //Hist�rico de Cargos"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do Contratado','Relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Alteracao'					,'D','10','Data da Altera��o','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'Motivo'				   		,'N','09','Motivo da Altera��o','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodCargo'					,'N','09','C�digo do Cargo','C�digo relacionado ao arquivo cargos.txt','Sim',.F.})
	
	Case cTipoInt =='419' //Hist�rico de Centros de Custo"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Relacionado ao arquivo Contratados.txt','Sim',.F.})
	    aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do Contratado','Relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Alteracao'					,'D','10','Data da Altera��o','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'Motivo'						,'N','09','Motivo da Altera��o','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodCentroCusto'				,'N','09','C�digo do Centro de Custo','C�digo relacionado ao arquivo centroscusto.txt','Sim',.F.})

	Case cTipoInt =='420' //Hist�rico de F�rias"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratatdo.','C�digo relacionado ao arquivoContratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			   		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do Contratatdo.','C�digo relacionado ao arquivo locais.txt','Sim',.F.})
		aAdd(aRet,{'PeriodoInicio'				,'D','10','Data de inicio do per�odo aquisitivo','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'PeriodoFim'					,'D','10','Data fim do per�odo aquisitivo','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'StatusPeriodo'				,'N','02','Status do per�odo de f�rias','01 - Aberto 02 - Liquidado 03 - Anulado','Sim',.F.})
		aAdd(aRet,{'SaidaFerias'				,'D','10','Data do inicio do gozo das f�rias','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'PagtoFerias'				,'D','10','Data do pagamento das f�rias','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'AvisoFerias'				,'D','10','Data do aviso de f�rias','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'DiasFerias'					,'N','06','Qtde de dias gozados de f�rias Atribuir duas casas decimais','Ex.: 20.00','Sim',.F.})
		aAdd(aRet,{'DiasAbono'					,'N','06','Qtde de dias de abono pecuni�rio Atribuir duas casas decimais','Ex;: 10.00','Sim',.F.})
		aAdd(aRet,{'Opl13Salario'				,'N','01','Op��o de recebimento do 13o. sal�rio','0 - N�o 1 - Sim','Sim',.F.})
		aAdd(aRet,{'CodDescanso'				,'N','01','Qual o modo de descanso utilizado para gozo das f�rias','1 - Normal 2 - Coletiva 3 - Indenizada','Sim',.F.})

	Case cTipoInt =='421' //Hist�rico de Afastamentos"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do contratado','C�digo relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			  		,'N','05','Local do contratado','C�digo relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'AfastamentoInicio'			,'D','10','Data de inicio do afastamento','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'AfastamentoFim'				,'D','10','Data final do afastamento','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodSituacao'				,'N','02','C�digo do afastamento','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'MotivoSituacaoAcidente'		,'N','01','C�digo do Motivo','1 - Acidente do trabalho t�pico 2 - Acidente do trabalho de trajeto','N�o',.F.})
		aAdd(aRet,{'MotivoSituacaoDoenca'		,'N','01','C�digo do Motivo','1 - Doen�a Relacionada ao trabalho 2 - Doen�a N�o Relacionada ao trabalho','N�o',.F.})

	Case cTipoInt =='422' //Hist�rico de Contribui��es Sindicais"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do contratado','C�digo relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do contratado','C�digo relacionado ao arquivo Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodSindicato'				,'N','09','C�digo do Sindicato','C�digo relacionado ao cadastro de Sindicatos','Sim',.F.})
		aAdd(aRet,{'DtContribuicao'				,'D','10','Data da Contribui��o','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'VlrContribuicao'			,'N','09','Valor da Contribui��o','Formato: 999.99','Sim',.F.})

	Case cTipoInt =='423' //Hist�rico de Transfer�ncias"   
		aAdd(aRet,{'CodMatricula_Origem'		,'N','09','Matricula do Contratado','C�digo relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CodEmpresa_Origem'			,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal_Origem'			,'N','05','Local do Contratado','C�digo relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Transferencia'				,'D','10','Data da Transfer�ncia','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodMotivo'					,'N','03','Motivos para Transfer�ncia','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodMatricula_Destino'		,'N','09','Matricula do Contratado','C�digo relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc_Destino'		,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa_Destino'			,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal_Destino'			,'N','05','Local do Contratado','C�digo relacionado ao arquivo Locais.txt','Sim',.F.})

	Case cTipoInt =='424' //Pensionistas"
		aAdd(aRet,{'CodPensionista'				,'N','09','C�digo da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','C�digo relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			   		,'N','05','Local do Contratado','C�digo relacionado ao arquivo de Locais.txt','Sim',.F.})
		aAdd(aRet,{'NomePensionaista'			,'A','60','Nome da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'RG'			  				,'A','15','RG da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'CPF'			  			,'N','14','CPF da(o) Pensionista','Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'Nascimento'			 		,'D','10','Data de Nascimento da(o) Pensionista','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodBanco'			 		,'N','09','C�digo do Banco para pagamento','C�digo relacionado ao arquivo de Bancos.txt','N�o',.F.})
		aAdd(aRet,{'CodAgencia'			  		,'N','09','C�digo da Ag�ncia para pagamento','C�digo relacionado ao arquivo de Agencias.txt','N�o',.F.})
		aAdd(aRet,{'ContaPagamento'				,'A','30','Conta para pagamento','','N�o',.F.})
		aAdd(aRet,{'DigitoContaPagamento'		,'A','10','Digito da conta para pagamento','','N�o',.F.})
		aAdd(aRet,{'CodSexo'			  		,'N','02','C�digo do sexo','1 - M 2 - F','Sim',.F.})
		aAdd(aRet,{'CodTipoendereco'			,'N','02','C�digo do tipo de Endere�o','Tab DE/Para','N�o',.F.})
		aAdd(aRet,{'EnderecoBase'				,'A','40','Endere�o base da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'				,'A','07','Endere�o n�mero da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'EnderecoCompl'				,'A','20','Endere�o complemento da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'Bairro'			 			,'A','25','Bairro da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'Municipio'			 		,'A','08','Municipio da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'Estado'			 			,'A','04','Estado da(o) Pensionista','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'Cep'			  			,'A','08','Cep da(o) Pensionista','Formato 9999-999','Sim',.F.})
		aAdd(aRet,{'Telefne'			 		,'A','09','Telefone da(o) Pensionista','Formato 9999-9999','N�o',.F.})

	Case cTipoInt =='425' //Contratados - Vale Transporte" 
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','C�digo relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			 		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			   		,'N','05','Local do Contratado','C�digo relacionado ao arquivo de Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodMeioTransporte'			,'N','09','C�digo do Meio de Transporte','C�digo relacionado ao arquivo de MeiosTransporte.txt','Sim',.F.})
		aAdd(aRet,{'QtdPassesporDia'			,'N','02','Quantidade de passes utilizados por dia.','','Sim',.F.})
		aAdd(aRet,{'InicioVT'			   		,'D','10','Data de Inicio da utiliza��o do VT.','Formato DD/MM/AAAA','Sim',.F.})

	Case cTipoInt =='426' //Contratados - Benef�cios"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','C�digo relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do Contratado','C�digo relacionado ao arquivo de Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodTipoBeneficio'			,'N','09','C�digo do benef�cio','C�digo relacionado ao arquivo de TiposBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'CodEmpresaBeneficio'		,'N','05','Empresa do benef�cio','C�digo relacionado ao arquivo de EmpresasBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'Valor'			  			,'N','10','Valor referente ao benef�cio','Ex.: 99.99','Sim',.F.})
		aAdd(aRet,{'Inicio'			  			,'D','10','Data de Inicio do beneficio','Formato DD/MM/AAAA','Sim',.F.})

	Case cTipoInt =='427' //Dependentes - Benef�cios"  
		aAdd(aRet,{'CodDependente'				,'N','09','Dependente do Contratado','C�digo relacionado ao arquivo de Dependentes.txt','Sim',.F.})
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','C�digo relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			   		,'N','05','Local do Contratado','C�digo relacionado ao arquivo de Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodTipoBeneficio'	  		,'N','09','C�digo do benef�cio','C�digo relacionado ao arquivo de TiposBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'CodEmpresaBeneficio'		,'N','05','Empresa do benef�cio','C�digo relacionado ao arquivo de EmpresasBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'Valor'			  			,'N','10','Valor referente ao benef�cio','Ex.: 99.99','Sim',.F.})
		aAdd(aRet,{'Inicio'			   			,'D','10','Data de Inicio do beneficio','Formato DD/MM/AAAA','Sim',.F.})

	Case cTipoInt =='428' //Contratados - Estabilidades"   
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do contratado','C�digo relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			 		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do contratado','C�digo relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'EstabilidadeInicio'			,'D','10','Data de inicio da estabilidade','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'EstabilidadeFim'			,'D','10','Data final da estabilidade','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'TipoEstabilidade'			,'N','02','C�digo do tipo de estabilidade','Tab DE/Para','Sim',.F.})
	
	Case cTipoInt =='429' //Ficha Financeira"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do funcion�rio','C�digo relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','N�mero do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			 		,'N','05','Empresa do Contratado','C�digo relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do Contratado','C�digo relacionado ao arquivo de Locais.txt','Sim',.F.})
		aAdd(aRet,{'Mes'			  			,'N','02','M�s de refer�ncia','Formato: MM','Sim',.F.})
		aAdd(aRet,{'Ano'			   			,'N','04','Ano de refer�ncia','Formato: AAAA','Sim',.F.})
		aAdd(aRet,{'CodVerba'			 		,'N','04','C�digo da verba','C�digo relacionado ao arquivo de depara de verbas.','Sim',.F.})
		aAdd(aRet,{'QtdVerba'			  		,'N','8,2','Quantidade de Verbas','Ex.: 0030.00 (30 Dias) 0220.00 (220 Horas) 0047.30 (47 Horas e Meia)','Sim',.F.})
		aAdd(aRet,{'VlnVerba'			 		,'N','11,2','Valor da verba com 11 inteiros e 2 decimais','Formato: 99999.99','Sim',.F.})
		aAdd(aRet,{'DtdVerba'			  		,'D','10','Data de Pagamento','Formato DD/MM/AAAA Informe a data de pagamento, inclusive f�rias e rescis�o.','Sim',.F.})
		aAdd(aRet,{'CodDependente'				,'N','09','Dependente do Contratado (*1)','C�digo relacionado ao arquivo Dependentes.txt','N�o',.F.})
		aAdd(aRet,{'CodTipoBeneficio'			,'N','09','C�digo do Beneficio (*1)','C�digo relacionado ao arquivo TiposBeneficios.txt','N�o',.F.})
		aAdd(aRet,{'CodEmpresaBeneficio'		,'N','05','Empresa do Beneficio (*1)','C�digo relacionado ao arquivo EmpresasBeneficios.txt','N�o',.F.})
EndCase

Return aRet

/*
Funcao	     : GetSitua()
Parametros  : 
Retorno     : 
Objetivos   : Retorna o Codigo de Situa��o do Afastamento
Autor       : Jean Victor Rocha 
Data/Hora   : 23/05/2014 
Outros		  :
*/
*--------------------------------*
Static Function GetSitua(cCodSit)
*--------------------------------*
Local nRet		:= 0
Local aCodSit := {}
Local nCodSit := 0

If EMPTY(cCodSit)
	Return nRet
EndIf

nCodSit := VAL(cCodSit)

aAdd(aCodSit,{1 ,6 ,'Afastado por Acidente do Trabalho'})
aAdd(aCodSit,{2 ,26,'Reafastado por Acid. de Trabalho'})
aAdd(aCodSit,{3 ,7 ,'Afastado por Aux�lio-Doen�a'})
aAdd(aCodSit,{4 ,27,'Reafastado por Aux�lio-Doen�a'})                                            
aAdd(aCodSit,{5 ,23,'Afastado por Licen�a-Paternidade'})
aAdd(aCodSit,{6 ,5 ,'Afastado em Maternidade'})
aAdd(aCodSit,{7 ,25,'Afastado por Prorrog. Maternidade'})                                                                                                                  
aAdd(aCodSit,{8 ,38,'Afastado por Aborto N�o Criminoso'})                                                                                                             
aAdd(aCodSit,{9 ,8 ,'Afastado pelo Servi�o Militar'})                                                                                                        
aAdd(aCodSit,{10,61,'Afastado por Mandato Sindical'})                                                                                                   
aAdd(aCodSit,{11,4 ,'Afastado sem Remunera��o'})                                                                                                              
//aAdd(aCodSit,{12,,''})                                                                                                                 
//aAdd(aCodSit,{13,,''})                                                                                                                
aAdd(aCodSit,{14,51,'Afastado por Aposentadoria'})                                                                                                                       
//aAdd(aCodSit,{15,,''})                                                                                                                       
//aAdd(aCodSit,{16,,''})                                                                                                                       
aAdd(aCodSit,{17,13,'Cumprimento de Pena de Reclus�o'})
aAdd(aCodSit,{99,91,'Afastado por Outros Motivos com Remunera��o'})

//Busca Referencia
If (nPos := aScan(aCodSit,{|x| x[1] == nCodSit})) <> 0
	Return aCodSit[nPos][2]
EndIf

Return nRet

/*
Funcao	    : GetNameBank()
Parametros  : 
Retorno     : 
Objetivos   : Retorna as Informe��es da Rescis�o
Autor       : Jean Victor Rocha 
Data/Hora   : 04/07/2014 
Outros		:
*/
*----------------------------------------------------------*
Static function GETDEMISSA(cTipo,cFilFunc,cMatFunc,cDemissa)
*----------------------------------------------------------*
Local xRet
Local cQry := ""

Default cTipo		:= ""
Default cFilFunc	:= ""
Default cMatFunc	:= ""
Default cDemissa	:= ""

If Select("DEM") > 0
	DEM->(DbClosearea())
Endif  

cQry += " Select *
cQry += " From "+RETSQLNAME("SRG")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 	AND RG_FILIAL 	= '"+cFilFunc+"'
cQry += " 	AND RG_MAT 		= '"+cMatFunc+"'
cQry += " 	AND RG_DATADEM	= '"+cDemissa+"'
		
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"DEM",.F.,.T.)

DEM->(DbGoTop())
If DEM->(!EOF())
	Do Case
		Case cTipo == "PGTO"
			xRet := DEM->RG_DATAHOM
		Case cTipo == "COD"
			Do Case
				Case DEM->RG_TIPORES == "01"//Pedido de demissao
					xRet := 3// - Iniciativa Empregado sem Justa Causa
				Case DEM->RG_TIPORES == "02"//Dispensa s/ justa causa
					xRet := 1// - Iniciativa Empregador sem Justa Causa
				Case DEM->RG_TIPORES == "03"//Dispensa c/ justa causa - Q.C.Exp
					xRet := 2// - Iniciativa Empregador com Justa Causa
				Case DEM->RG_TIPORES == "04"//Termino contrato Experiencia
					xRet := 7// - T�rmino de Contrato - Prazo Determinado
				Case DEM->RG_TIPORES == "05"//Rescisao Pro Labore
					xRet := 23// - Outros
				OtherWise
					xRet := 23// - Outros
			EndCase
	EndCase
ElseIf cTipo == "COD"
	xRet := 23// - Transfer�ncia sem �nus p/ Cedente (sem Rescis�o)
ElseIf cTipo == "PGTO"
	xRet := cDemissa
EndIf

Return xRet

/*
Funcao	    : GetNameBank()
Parametros  : 
Retorno     : 
Objetivos   : Retorna o Nome do Banco de acordo com o Codigo, FEBREBAN
Autor       : Jean Victor Rocha 
Data/Hora   : 08/04/2014 
Outros		: http://www.febraban.org.br/bancos.asp
*/
*-----------------------------------------*
Static function GetNameBank(cTipo, cCodigo)
*-----------------------------------------*
Local cRet := ""
Local nPos := 0
Local aFebraban := {}

aAdd(aFebraban,{'001','Banco do Brasil S.A.',''})
aAdd(aFebraban,{'003','Banco da Amaz�nia S.A.',''})
aAdd(aFebraban,{'004','Banco do Nordeste do Brasil S.A.',''})
aAdd(aFebraban,{'012','Banco Standard de Investimentos S.A.',''})
aAdd(aFebraban,{'014','Natixis Brasil S.A. Banco M�ltiplo',''})
aAdd(aFebraban,{'018','Banco Tricury S.A.',''})
aAdd(aFebraban,{'019','Banco Azteca do Brasil S.A.',''})
aAdd(aFebraban,{'021','BANESTES S.A. Banco do Estado do Esp�rito Santo',''})
aAdd(aFebraban,{'024','Banco de Pernambuco S.A. - BANDEPE',''})
aAdd(aFebraban,{'025','Banco Alfa S.A.',''})
aAdd(aFebraban,{'029','Banco Banerj S.A.',''})
aAdd(aFebraban,{'031','Banco Beg S.A.',''})
aAdd(aFebraban,{'033','Banco Santander (Brasil) S.A.',''})
aAdd(aFebraban,{'036','Banco Bradesco BBI S.A.',''})
aAdd(aFebraban,{'037','Banco do Estado do Par� S.A.',''})
aAdd(aFebraban,{'039','Banco do Estado do Piau� S.A. - BEP',''})
aAdd(aFebraban,{'040','Banco Cargill S.A.',''})
aAdd(aFebraban,{'041','Banco do Estado do Rio Grande do Sul S.A.',''})
aAdd(aFebraban,{'044','Banco BVA S.A.',''})
aAdd(aFebraban,{'045','Banco Opportunity S.A.',''})
aAdd(aFebraban,{'047','Banco do Estado de Sergipe S.A.',''})
aAdd(aFebraban,{'062','Hipercard Banco M�ltiplo S.A.',''})
aAdd(aFebraban,{'063','Banco Ibi S.A. Banco M�ltiplo',''})
aAdd(aFebraban,{'064','Goldman Sachs do Brasil Banco M�ltiplo S.A.',''})
aAdd(aFebraban,{'065','Banco Bracce S.A.',''})
aAdd(aFebraban,{'066','Banco Morgan Stanley S.A.',''})
aAdd(aFebraban,{'069','BPN Brasil Banco M�ltiplo S.A.',''})
aAdd(aFebraban,{'070','BRB - Banco de Bras�lia S.A.',''})
aAdd(aFebraban,{'072','Banco Rural Mais S.A.',''})
aAdd(aFebraban,{'073','BB Banco Popular do Brasil S.A.',''})
aAdd(aFebraban,{'074','Banco J. Safra S.A.',''})
aAdd(aFebraban,{'075','Banco ABN AMRO S.A.',''})
aAdd(aFebraban,{'076','Banco KDB S.A.',''})
aAdd(aFebraban,{'078','BES Investimento do Brasil S.A.-Banco de Investimento',''})
aAdd(aFebraban,{'079','Banco Original do Agroneg�cio S.A.',''})
aAdd(aFebraban,{'084','Unicred Norte do Paran�',''})
aAdd(aFebraban,{'095','Banco Confidence de C�mbio S.A.',''})
aAdd(aFebraban,{'096','Banco BM&FBOVESPA de Servi�os de Liquida��o e Cust�dia S.A',''})
aAdd(aFebraban,{'104','Caixa Econ�mica Federal',''})
aAdd(aFebraban,{'107','Banco BBM S.A.',''})
aAdd(aFebraban,{'119','Banco Western Union do Brasil S.A.',''})
aAdd(aFebraban,{'125','Brasil Plural S.A. - Banco M�ltiplo',''})
aAdd(aFebraban,{'168','HSBC Finance (Brasil) S.A. - Banco M�ltiplo',''})
aAdd(aFebraban,{'184','Banco Ita� BBA S.A.',''})
aAdd(aFebraban,{'204','Banco Bradesco Cart�es S.A.',''})
aAdd(aFebraban,{'208','Banco BTG Pactual S.A.',''})
aAdd(aFebraban,{'212','Banco Original S.A.',''})
aAdd(aFebraban,{'213','Banco Arbi S.A.',''})
aAdd(aFebraban,{'214','Banco Dibens S.A.',''})
aAdd(aFebraban,{'215','Banco Comercial e de Investimento Sudameris S.A.',''})
aAdd(aFebraban,{'217','Banco John Deere S.A.',''})
aAdd(aFebraban,{'218','Banco Bonsucesso S.A.',''})
aAdd(aFebraban,{'222','Banco Credit Agricole Brasil S.A.',''})
aAdd(aFebraban,{'224','Banco Fibra S.A.',''})
aAdd(aFebraban,{'225','Banco Brascan S.A.',''})
aAdd(aFebraban,{'229','Banco Cruzeiro do Sul S.A.',''})
aAdd(aFebraban,{'230','Unicard Banco M�ltiplo S.A.',''})
aAdd(aFebraban,{'233','Banco Cifra S.A.',''})
aAdd(aFebraban,{'237','Banco Bradesco S.A.',''})
aAdd(aFebraban,{'241','Banco Cl�ssico S.A.',''})
aAdd(aFebraban,{'243','Banco M�xima S.A.',''})
aAdd(aFebraban,{'246','Banco ABC Brasil S.A.',''})
aAdd(aFebraban,{'248','Banco Boavista Interatl�ntico S.A.',''})
aAdd(aFebraban,{'249','Banco Investcred Unibanco S.A.',''})
aAdd(aFebraban,{'250','BCV - Banco de Cr�dito e Varejo S.A.',''})
aAdd(aFebraban,{'254','Paran� Banco S.A.',''})
aAdd(aFebraban,{'263','Banco Cacique S.A.',''})
aAdd(aFebraban,{'265','Banco Fator S.A.',''})
aAdd(aFebraban,{'266','Banco C�dula S.A.',''})
aAdd(aFebraban,{'300','Banco de La Nacion Argentina',''})
aAdd(aFebraban,{'318','Banco BMG S.A.',''})
aAdd(aFebraban,{'320','Banco Industrial e Comercial S.A.',''})
aAdd(aFebraban,{'341','Ita� Unibanco S.A.',''})
aAdd(aFebraban,{'356','Banco Real S.A.',''})
aAdd(aFebraban,{'366','Banco Soci�t� G�n�rale Brasil S.A.',''})
aAdd(aFebraban,{'370','Banco Mizuho do Brasil S.A.',''})
aAdd(aFebraban,{'376','Banco J. P. Morgan S.A.',''})
aAdd(aFebraban,{'389','Banco Mercantil do Brasil S.A.',''})
aAdd(aFebraban,{'394','Banco Bradesco Financiamentos S.A.',''})
aAdd(aFebraban,{'394','Banco Finasa BMC S.A.',''})
aAdd(aFebraban,{'399','HSBC Bank Brasil S.A. - Banco M�ltiplo',''})
aAdd(aFebraban,{'409','UNIBANCO - Uni�o de Bancos Brasileiros S.A.',''})
aAdd(aFebraban,{'412','Banco Capital S.A.',''})
aAdd(aFebraban,{'422','Banco Safra S.A.',''})
aAdd(aFebraban,{'453','Banco Rural S.A.',''})
aAdd(aFebraban,{'456','Banco de Tokyo-Mitsubishi UFJ Brasil S.A.',''})
aAdd(aFebraban,{'464','Banco Sumitomo Mitsui Brasileiro S.A.',''})
aAdd(aFebraban,{'473','Banco Caixa Geral - Brasil S.A.',''})
aAdd(aFebraban,{'477','Citibank S.A.',''})
aAdd(aFebraban,{'479','Banco Ita�Bank S.A',''})
aAdd(aFebraban,{'487','Deutsche Bank S.A. - Banco Alem�o',''})
aAdd(aFebraban,{'488','JPMorgan Chase Bank',''})
aAdd(aFebraban,{'492','ING Bank N.V.',''})
aAdd(aFebraban,{'494','Banco de La Republica Oriental del Uruguay',''})
aAdd(aFebraban,{'495','Banco de La Provincia de Buenos Aires',''})
aAdd(aFebraban,{'505','Banco Credit Suisse (Brasil) S.A.',''})
aAdd(aFebraban,{'600','Banco Luso Brasileiro S.A.',''})
aAdd(aFebraban,{'604','Banco Industrial do Brasil S.A.',''})
aAdd(aFebraban,{'610','Banco VR S.A.',''})
aAdd(aFebraban,{'611','Banco Paulista S.A.',''})
aAdd(aFebraban,{'612','Banco Guanabara S.A.',''})
aAdd(aFebraban,{'613','Banco Pec�nia S.A.',''})
aAdd(aFebraban,{'623','Banco Panamericano S.A.',''})
aAdd(aFebraban,{'626','Banco Ficsa S.A.',''})
aAdd(aFebraban,{'630','Banco Intercap S.A.',''})
aAdd(aFebraban,{'633','Banco Rendimento S.A.',''})
aAdd(aFebraban,{'634','Banco Tri�ngulo S.A.',''})
aAdd(aFebraban,{'637','Banco Sofisa S.A.',''})
aAdd(aFebraban,{'638','Banco Prosper S.A.',''})
aAdd(aFebraban,{'641','Banco Alvorada S.A.',''})
aAdd(aFebraban,{'643','Banco Pine S.A.',''})
aAdd(aFebraban,{'652','Ita� Unibanco Holding S.A.',''})
aAdd(aFebraban,{'653','Banco Indusval S.A.',''})
aAdd(aFebraban,{'654','Banco A.J.Renner S.A.',''})
aAdd(aFebraban,{'655','Banco Votorantim S.A.',''})
aAdd(aFebraban,{'707','Banco Daycoval S.A.',''})
aAdd(aFebraban,{'719','Banif-Banco Internacional do Funchal (Brasil)S.A.',''})
aAdd(aFebraban,{'721','Banco Credibel S.A.',''})
aAdd(aFebraban,{'724','Banco Porto Seguro S.A.',''})
aAdd(aFebraban,{'734','Banco Gerdau S.A.',''})
aAdd(aFebraban,{'735','Banco Pottencial S.A.',''})
aAdd(aFebraban,{'738','Banco Morada S.A.',''})
aAdd(aFebraban,{'739','Banco BGN S.A.',''})
aAdd(aFebraban,{'740','Banco Barclays S.A.',''})
aAdd(aFebraban,{'741','Banco Ribeir�o Preto S.A.',''})
aAdd(aFebraban,{'743','Banco Semear S.A.',''})
aAdd(aFebraban,{'744','BankBoston N.A.',''})
aAdd(aFebraban,{'745','Banco Citibank S.A.',''})
aAdd(aFebraban,{'746','Banco Modal S.A.',''})
aAdd(aFebraban,{'747','Banco Rabobank International Brasil S.A.',''})
aAdd(aFebraban,{'748','Banco Cooperativo Sicredi S.A.',''})
aAdd(aFebraban,{'749','Banco Simples S.A.',''})
aAdd(aFebraban,{'751','Scotiabank Brasil S.A. Banco M�ltiplo',''})
aAdd(aFebraban,{'752','Banco BNP Paribas Brasil S.A.',''})
aAdd(aFebraban,{'753','NBC Bank Brasil S.A. - Banco M�ltiplo',''})
aAdd(aFebraban,{'755','Bank of America Merrill Lynch Banco M�ltiplo S.A.',''})
aAdd(aFebraban,{'756','Banco Cooperativo do Brasil S.A. - BANCOOB',''})
aAdd(aFebraban,{'757','Banco KEB do Brasil S.A.',''})
aAdd(aFebraban,{'077','Banco Intermedium S.A.',''})
aAdd(aFebraban,{'081','Conc�rdia Banco S.A.',''})
aAdd(aFebraban,{'082','Banco Top�zio S.A.',''})
aAdd(aFebraban,{'083','Banco da China Brasil S.A.',''})
aAdd(aFebraban,{'085','Cooperativa Central de Cr�dito Urbano-CECRED',''})
aAdd(aFebraban,{'086','OBOE Cr�dito Financiamento e Investimento S.A.',''})
aAdd(aFebraban,{'087','Cooperativa Unicred Central Santa Catarina',''})
aAdd(aFebraban,{'088','Banco Randon S.A.',''})
aAdd(aFebraban,{'089','Cooperativa de Cr�dito Rural da Regi�o de Mogiana',''})
aAdd(aFebraban,{'090','Cooperativa Central de Economia e Cr�dito Mutuo das Unicreds',''})
aAdd(aFebraban,{'091','Unicred Central do Rio Grande do Sul',''})
aAdd(aFebraban,{'092','Brickell S.A. Cr�dito, financiamento e Investimento',''})
aAdd(aFebraban,{'094','Banco Petra S.A.',''})
aAdd(aFebraban,{'097','Cooperativa Central de Cr�dito Noroeste Brasileiro Ltda.',''})
aAdd(aFebraban,{'098','CREDIALIAN�A COOPERATIVA DE CR�DITO RURAL',''})
aAdd(aFebraban,{'099','Cooperativa Central de Economia e Credito Mutuo das Unicreds',''})
aAdd(aFebraban,{'114','Central das Coop. de Economia e Cr�dito Mutuo do Est. do ES',''})
aAdd(aFebraban,{'122','Banco BERJ S.A.',''})
aAdd(aFebraban,{'M03','Banco Fiat S.A.',''})
aAdd(aFebraban,{'M06','Banco de Lage Landen Brasil S.A.',''})
aAdd(aFebraban,{'M07','Banco GMAC S.A.',''})
aAdd(aFebraban,{'M08','Banco Citicard S.A.',''})
aAdd(aFebraban,{'M09','Banco Itaucred Financiamentos S.A.',''})
aAdd(aFebraban,{'M10','Banco Moneo S.A.',''})
aAdd(aFebraban,{'M11','Banco IBM S.A.',''})
aAdd(aFebraban,{'M12','Banco Maxinvest S.A.',''})
aAdd(aFebraban,{'M14','Banco Volkswagen S.A.',''})
aAdd(aFebraban,{'M15','Banco BRJ S.A.',''})
aAdd(aFebraban,{'M16','Banco Rodobens S.A.',''})
aAdd(aFebraban,{'M17','Banco Ourinvest S.A.',''})
aAdd(aFebraban,{'M18','Banco Ford S.A.',''})
aAdd(aFebraban,{'M19','Banco CNH Capital S.A.',''})
aAdd(aFebraban,{'M20','Banco Toyota do Brasil S.A.',''})
aAdd(aFebraban,{'M21','Banco Daimlerchrysler S.A.',''})
aAdd(aFebraban,{'M22','Banco Honda S.A.',''})
aAdd(aFebraban,{'M23','Banco Volvo (Brasil) S.A.',''})
aAdd(aFebraban,{'M24','Banco PSA Finance Brasil S.A.',''})

If (nPos:= aScan(aFebraban,{|x| x[1]==cCodigo})	) <> 0
	If cTipo == "FULL"
		cRet := aFebraban[nPos][2]
	ElseIf cTipo == "REDUCED"
		cRet := aFebraban[nPos][3]
	EndIf
EndIf

Return cRet

/*
Funcao      : TipoEnd
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna o tipo de Endere�o de acordo com o layout APDATA.
Autor       : Jean Victor Rocha.
Data/Hora   : 11/04/2014
*/
*--------------------------------*
Static Function TipoEnd(cEndereco)
*--------------------------------*
Local nRet := 0
Local aTipos := {}
Default cEndereco := ""

If AT(" ",cEndereco) <> 0
	cEndereco := SubStr(cEndereco,1,AT(" ",cEndereco)-1)
Else
	cEndereco := ALLTRIM(cEndereco)
EndIf

aAdd(aTipos,{0 ,'Nenhum'})
aAdd(aTipos,{1 ,'Al'})
aAdd(aTipos,{1 ,'Al.'})
aAdd(aTipos,{1 ,'Alameda'})
aAdd(aTipos,{2 ,'Av'})
aAdd(aTipos,{2 ,'Av.'})
aAdd(aTipos,{2 ,'Avenida'})
aAdd(aTipos,{3 ,'Estrada'})
aAdd(aTipos,{4 ,'Rodovia'})
aAdd(aTipos,{5 ,'Praca'})
aAdd(aTipos,{6 ,'R'})
aAdd(aTipos,{6 ,'R.'})
aAdd(aTipos,{6 ,'Rua'})
aAdd(aTipos,{7 ,'Viela'})
aAdd(aTipos,{8 ,'Travessa'})
aAdd(aTipos,{9 ,'Largo'})
aAdd(aTipos,{10,'Passagem'})
aAdd(aTipos,{11,'Ladeira'})
aAdd(aTipos,{12,'Esplanada'})
aAdd(aTipos,{13,'Viaduto'})
aAdd(aTipos,{14,'Quadra'})
aAdd(aTipos,{15,'Via'})
aAdd(aTipos,{16,'Praia'})
aAdd(aTipos,{17,'Caminho'})
aAdd(aTipos,{18,'Povoado'})
aAdd(aTipos,{19,'Ilha'})
aAdd(aTipos,{20,'Calcada'})
aAdd(aTipos,{21,'Marginal'})
aAdd(aTipos,{22,'Fazenda'})
aAdd(aTipos,{23,'Passagem'})
aAdd(aTipos,{24,'Acesso'})
aAdd(aTipos,{25,'Prolongamento'})
aAdd(aTipos,{26,'Parque'})
aAdd(aTipos,{27,'Trevo'})
aAdd(aTipos,{28,'Aeroporto'})
aAdd(aTipos,{29,'Area'})
aAdd(aTipos,{30,'Campo'})
aAdd(aTipos,{31,'Chacara'})
aAdd(aTipos,{32,'Colonia'})
aAdd(aTipos,{33,'Condom�nio'})
aAdd(aTipos,{34,'Conjunto'})
aAdd(aTipos,{35,'Distrito'})
aAdd(aTipos,{36,'Estacao'})
aAdd(aTipos,{37,'Favela'})
aAdd(aTipos,{38,'Feira'})
aAdd(aTipos,{39,'Jardim'})
aAdd(aTipos,{40,'Lago'})
aAdd(aTipos,{41,'Lagoa'})
aAdd(aTipos,{42,'Loteamento'})
aAdd(aTipos,{43,'Morro'})
aAdd(aTipos,{44,'Margem'})
aAdd(aTipos,{45,'Nucleo'})
aAdd(aTipos,{46,'Passarela'})
aAdd(aTipos,{47,'Patio'})
aAdd(aTipos,{48,'Recanto'})
aAdd(aTipos,{49,'Residencial'})
aAdd(aTipos,{50,'Setor'})
aAdd(aTipos,{51,'Sitio'})
aAdd(aTipos,{52,'Superquadra'})
aAdd(aTipos,{53,'Trecho'})
aAdd(aTipos,{54,'Vale'})
aAdd(aTipos,{55,'Vereda'})
aAdd(aTipos,{56,'Vila'})
aAdd(aTipos,{57,'Outros'})

//Busca Referencia
For i:=1 to Len(aTipos)
	If AT(UPPER(aTipos[i][2]),UPPER(cEndereco)) <> 0
		Return aTipos[i][1]
	EndIf
Next i

Return nRet

/*
Funcao      : GetInstru
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna Grau de Instru��o
Autor       : Jean Victor Rocha.
Data/Hora   : 17/04/2014
*/
*--------------------------------*
Static Function GetInstru(cGrau)
*--------------------------------*
Local nRet := 0
Local aGrau := {}

aAdd(aGrau,{1 ,'10','Analfabeto'})
aAdd(aGrau,{2 ,'20','Educa��o B�sica Incompleta'})
aAdd(aGrau,{3 ,'25','Educa��o B�sica Completa'})
aAdd(aGrau,{4 ,'30','Ensino Fundamental Incompleto'})
aAdd(aGrau,{5 ,'35','Ensino Fundamental Completo'})
aAdd(aGrau,{6 ,'40','Ensino M�dio Incompleto'})
aAdd(aGrau,{7 ,'45','Ensino M�dio Completo'})
aAdd(aGrau,{8 ,'50','Ensino Superior Incompleto'})
aAdd(aGrau,{9 ,'55','Ensino Superior Completo'})
aAdd(aGrau,{10,'85','P�s-Gradua��o'})
aAdd(aGrau,{11,'65','Mestrado'})
aAdd(aGrau,{12,'75','Doutorado'})

//Busca Referencia
For i:=1 to Len(aGrau)
	If AT(UPPER(aGrau[i][2]),UPPER(cGrau)) <> 0 .or. AT(UPPER(aGrau[i][3]),UPPER(cGrau)) <> 0
		Return aGrau[i][1]
	EndIf
Next i

Return nRet

/*
Funcao      : GetEstado
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna Estado Civil
Autor       : Jean Victor Rocha.
Data/Hora   : 17/04/2014
*/
*--------------------------------*
Static Function GetEstado(cEstado)
*--------------------------------*
Local nRet := 0
Local aEstado := {}

aAdd(aEstado,{2 ,'C','Casado(a)'})
aAdd(aEstado,{6 ,'D','Divorciado(a)'})
aAdd(aEstado,{5 ,'M','Unial Estavel'})
aAdd(aEstado,{7 ,'O','Outros'})
aAdd(aEstado,{4 ,'Q','Desquitado(a)'})
aAdd(aEstado,{1 ,'S','Solteiro(a)'})
aAdd(aEstado,{3 ,'V','Viuvo(a)'})

//Busca Referencia
For i:=1 to Len(aEstado)
	If AT(UPPER(aEstado[i][2]),UPPER(cEstado)) <> 0 .or. AT(UPPER(aEstado[i][3]),UPPER(cEstado)) <> 0
		Return aEstado[i][1]
	EndIf
Next i

Return nRet
  
/*
Funcao      : GetTpEmp
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna o Cod. Tipo Emprego
Autor       : Jean Victor Rocha.
Data/Hora   : 24/04/2014
*/
*--------------------------------*
Static Function GetTpEmp(cCodVinc)
*--------------------------------*
Local nRet := 0
Local aCodVinc := {}

If !(ASC(RIGHT(cCodVinc,1)) >= 48 .and. ASC(RIGHT(cCodVinc,1)) <= 57)
	Do Case
		Case RIGHT(cCodVinc,1) == "A"  //1 - Primeiro Emprego
			nRet := 1
		Case RIGHT(cCodVinc,1) == "B" //2 - Re-Emprego
			nRet := 2
	EndCase
EndIf          

Return nRet

/*
Funcao      : GetCodVinc
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna o Cod. do Vinculo
Autor       : Jean Victor Rocha.
Data/Hora   : 24/04/2014
*/
*----------------------------------*
Static Function GetCodVinc(cCodVinc)
*----------------------------------*
Local nRet := 0
Local aCodVinc := {}

If !(ASC(RIGHT(cCodVinc,1)) >= 48 .and. ASC(RIGHT(cCodVinc,1)) <= 57)
	cCodVinc := Left(cCodVinc,1)
EndIf

aAdd(aCodVinc,{1  ,'9','Empregado (CLT)'})
//aAdd(aCodVinc,{2  ,'','Diretoria'})
//aAdd(aCodVinc,{3  ,'','Prazo Determinado - Lei 9.601/98'})
//aAdd(aCodVinc,{4  ,'','Aut�nomo'})
aAdd(aCodVinc,{5  ,'3','Menor Aprendiz'})
//aAdd(aCodVinc,{6  ,'','Pessoa Jur�dica'})
//aAdd(aCodVinc,{7  ,'','Tarefeiro'})
//aAdd(aCodVinc,{8  ,'','Rur�cola'})
//aAdd(aCodVinc,{9  ,'','Estagi�rio'})
//aAdd(aCodVinc,{10 ,'','Pensionista'})
//aAdd(aCodVinc,{11 ,'','Funcion�rio P�blico'})
//aAdd(aCodVinc,{12 ,'','Terceirizado'})
//aAdd(aCodVinc,{13 ,'','Trabalhador Avulso'})
//aAdd(aCodVinc,{14 ,'','Trabalhador N�o Vinculado ao RGPS, Mas com FGTS'})
aAdd(aCodVinc,{15 ,'1','Diretor N�o Empregado com FGTS (Lei 8.036/90)'})
//aAdd(aCodVinc,{16 ,'','Empregado Dom�stico'})
//aAdd(aCodVinc,{17 ,'','Aut�nomo Contr S/Remuner /Cooperativa de Produ��o'})
//aAdd(aCodVinc,{18 ,'','Transp Aut Contr S/Remun /Cooperativa Trabalho'})
//aAdd(aCodVinc,{19 ,'','Transp Aut�nomo Contribui��o S/Sal�rio-Base'})
//aAdd(aCodVinc,{20 ,'','Transportador Cooperado Cooperativa de Trabalho'})
//aAdd(aCodVinc,{21 ,'','Tempo Parcial - Prazo Indeterminado'})
//aAdd(aCodVinc,{22 ,'','M�dico Residente'})
//aAdd(aCodVinc,{23 ,'','Aprendizagem - Lei 25.013'})
//aAdd(aCodVinc,{24 ,'','Tempo Indeterminado'})
//aAdd(aCodVinc,{25 ,'','Programa Nacional de Estagi�rios'})
//aAdd(aCodVinc,{26 ,'','Trabalho de Temporada'})
//aAdd(aCodVinc,{27 ,'','Trabalho Eventual'})
//aAdd(aCodVinc,{28 ,'','Trabalhador Agr�rio - Lei 24.248'})
//aAdd(aCodVinc,{29 ,'','Trabalhador da Constru��o - Lei22250'})
//aAdd(aCodVinc,{30 ,'','Transp Coop Pr Serv Ent Ben Isenta Cota Patronal'})
//aAdd(aCodVinc,{31 ,'','Transp Aut�nomo Prod Rural PF / Miss�o Diplom�tica'})
//aAdd(aCodVinc,{32 ,'','Coop que Presta Serv a Empr Contrat da Coop Trab'})
//aAdd(aCodVinc,{33 ,'','Coop que Pr Serv a Ent Ben Isenta Cota Patronal'})
//aAdd(aCodVinc,{34 ,'','Agente Pol�tico'})
//aAdd(aCodVinc,{35 ,'','Serv P�blico Cargo em Comiss�o / Cargo Tempor�rio'})
//aAdd(aCodVinc,{36 ,'','Serv P�bl Cargo Efet, Magistrado,Min P�bl/Tr Cont'})
//aAdd(aCodVinc,{37 ,'','Contr Indiv Miss�o Diplom�tica ou Dirig Sindical'})
//aAdd(aCodVinc,{38 ,'','Empregada(o) Dom�stica(o)'})

//Busca Referencia
For i:=1 to Len(aCodVinc)
	If AT(UPPER(aCodVinc[i][2]),UPPER(cCodVinc)) <> 0 .or. AT(UPPER(aCodVinc[i][3]),UPPER(cCodVinc)) <> 0
		Return aCodVinc[i][1]
	EndIf
Next i

Return nRet

/*
Funcao      : GetTpPag
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna o Cod. Tipo de Pagamento da Id.
Autor       : Jean Victor Rocha.
Data/Hora   : 17/04/2014
*/
*--------------------------------*
Static Function GetTpPag(cCodFunc)
*--------------------------------*
Local nRet := 0
Local aIdTpPag := {}

aAdd(aIdTpPag,{1  ,'M','Mensalista'})
aAdd(aIdTpPag,{3  ,'S','Semanalista'})
aAdd(aIdTpPag,{4  ,'D','Diarista'})
aAdd(aIdTpPag,{5  ,'H','Horista'})
aAdd(aIdTpPag,{6  ,'T','Tarefeiro'})
aAdd(aIdTpPag,{7  ,'E','Estagi�rio'})
aAdd(aIdTpPag,{8  ,'C','Comissionado'})
aAdd(aIdTpPag,{14 ,'C','Comissionado Externo'})
aAdd(aIdTpPag,{15 ,'A','Aut�nomo'})


//Busca Referencia
For i:=1 to Len(aIdTpPag)
	If AT(UPPER(aIdTpPag[i][2]),UPPER(cCodFunc)) <> 0 .or. AT(UPPER(aIdTpPag[i][3]),UPPER(cCodFunc)) <> 0
		Return aIdTpPag[i][1]
	EndIf
Next i

Return nRet


/*
Funcao      : IdEst
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna o ID do Estado de acordo com o layout APDATA.
Autor       : Jean Victor Rocha.
Data/Hora   : 11/04/2014
*/
*--------------------------------*
Static Function IdEst(cEstado)
*--------------------------------*
Local nRet := 0
Local aIdEst := {}
Default cEstado := ""
cEstado := ALLTRIM(cEstado)

aAdd(aIdEst,{0 ,'EX','Estrangeiro'})
aAdd(aIdEst,{1 ,'AC','Acre'})
aAdd(aIdEst,{2 ,'AL','Alagoas'})
aAdd(aIdEst,{3 ,'AM','Amazonas'})
aAdd(aIdEst,{4 ,'AP','Amapa'})
aAdd(aIdEst,{5 ,'BA','Bahia'})
aAdd(aIdEst,{6 ,'CE','Ceara'})
aAdd(aIdEst,{7 ,'DF','Distrito Federal'})
aAdd(aIdEst,{8 ,'ES','Espirito Santo'})
aAdd(aIdEst,{9 ,'GO','Goias'})
aAdd(aIdEst,{10,'MA','Maranhao'})
aAdd(aIdEst,{11,'MG','Minas Gerais'})
aAdd(aIdEst,{12,'MS','Mato Grosso do Sul'})
aAdd(aIdEst,{13,'MT','Mato Grosso'})
aAdd(aIdEst,{14,'PA','Para'})
aAdd(aIdEst,{15,'PB','Para�ba'})
aAdd(aIdEst,{16,'PE','Pernambuco'})
aAdd(aIdEst,{17,'PI','Piaui'})
aAdd(aIdEst,{18,'PR','Parana'})
aAdd(aIdEst,{19,'RJ','Rio de Janeiro'})
aAdd(aIdEst,{20,'RN','Rio Grande do Norte'})
aAdd(aIdEst,{21,'RO','Rondonia'})
aAdd(aIdEst,{22,'RR','Roraima'})
aAdd(aIdEst,{23,'RS','Rio Grande do Sul'})
aAdd(aIdEst,{24,'SC','Santa Catarina'})
aAdd(aIdEst,{25,'SE','Sergipe'})
aAdd(aIdEst,{26,'SP','Sao Paulo'})
aAdd(aIdEst,{27,'TO','Tocantins'})

//Busca Referencia
For i:=1 to Len(aIdEst)
	If AT(UPPER(aIdEst[i][2]),UPPER(cEstado)) <> 0 .or. AT(UPPER(aIdEst[i][3]),UPPER(cEstado)) <> 0
		Return aIdEst[i][1]
	EndIf
Next i

Return nRet

/*
Funcao      : GetCBO
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna o Nome padr�o da CBO de acordo com o  MTE
Obs			: http://www.mtecbo.gov.br/cbosite/pages/downloads.jsf;jsessionid=N7lt0KNG5rJxIAxoYTePhNUW.slave18:mte-234-cbo-01
Autor       : Jean Victor Rocha.
Data/Hora   : 15/04/2014
*/
*--------------------------------*
Static Function GetCBO(cCBO)
*--------------------------------*
Local cRet := ""
Local aCBO := {}
Local nPos := 0
Default cCBO := ""
cCBO := ALLTRIM(cCBO)

aAdd(aCBO,{'010115','Oficial general da marinha'})
aAdd(aCBO,{'010110','Oficial general do ex�rcito'})
aAdd(aCBO,{'010105','Oficial general da aeron�utica'})
aAdd(aCBO,{'010210','Oficial do ex�rcito'})
aAdd(aCBO,{'010215','Oficial da marinha'})
aAdd(aCBO,{'010205','Oficial da aeron�utica'})
aAdd(aCBO,{'010315','Pra�a da marinha'})
aAdd(aCBO,{'010310','Pra�a do ex�rcito'})
aAdd(aCBO,{'010305','Pra�a da aeron�utica'})
aAdd(aCBO,{'020105','Coronel da pol�cia militar'})
aAdd(aCBO,{'020110','Tenente-coronel da pol�cia militar'})
aAdd(aCBO,{'020115','Major da pol�cia militar'})
aAdd(aCBO,{'020205','Capit�o da pol�cia militar'})
aAdd(aCBO,{'020310','Segundo tenente de pol�cia militar'})
aAdd(aCBO,{'020305','Primeiro tenente de pol�cia militar'})
aAdd(aCBO,{'021105','Subtenente da policia militar'})
aAdd(aCBO,{'021110','Sargento da policia militar'})
aAdd(aCBO,{'021205','Cabo da pol�cia militar'})
aAdd(aCBO,{'021210','Soldado da pol�cia militar'})
aAdd(aCBO,{'030115','Tenente-coronel bombeiro militar'})
aAdd(aCBO,{'030105','Coronel bombeiro militar'})
aAdd(aCBO,{'030110','Major bombeiro militar'})
aAdd(aCBO,{'030205','Capit�o bombeiro militar'})
aAdd(aCBO,{'030305','Tenente do corpo de bombeiros militar'})
aAdd(aCBO,{'031110','Sargento bombeiro militar'})
aAdd(aCBO,{'031105','Subtenente bombeiro militar'})
aAdd(aCBO,{'031205','Cabo bombeiro militar'})
aAdd(aCBO,{'031210','Soldado bombeiro militar'})
aAdd(aCBO,{'111120','Vereador'})
aAdd(aCBO,{'111115','Deputado estadual e distrital'})
aAdd(aCBO,{'111110','Deputado federal'})
aAdd(aCBO,{'111105','Senador'})
aAdd(aCBO,{'111250','Prefeito'})
aAdd(aCBO,{'111255','Vice-prefeito'})
aAdd(aCBO,{'111245','Vice-governador do distrito federal'})
aAdd(aCBO,{'111240','Vice-governador de estado'})
aAdd(aCBO,{'111225','Membro superior do poder executivo'})
aAdd(aCBO,{'111230','Governador de estado'})
aAdd(aCBO,{'111235','Governador do distrito federal'})
aAdd(aCBO,{'111220','Secret�rio - executivo'})
aAdd(aCBO,{'111215','Ministro de estado'})
aAdd(aCBO,{'111210','Vice-presidente da rep�blica'})
aAdd(aCBO,{'111205','Presidente da rep�blica'})
aAdd(aCBO,{'111330','Juiz federal'})
aAdd(aCBO,{'111305','Ministro do supremo tribunal federal'})
aAdd(aCBO,{'111340','Juiz auditor estadual - justi�a militar'})
aAdd(aCBO,{'111345','Juiz do trabalho'})
aAdd(aCBO,{'111335','Juiz auditor federal - justi�a militar'})
aAdd(aCBO,{'111310','Ministro do superior tribunal de justi�a'})
aAdd(aCBO,{'111315','Ministro do superior tribunal militar'})
aAdd(aCBO,{'111320','Ministro do superior tribunal do trabalho'})
aAdd(aCBO,{'111325','Juiz de direito'})
aAdd(aCBO,{'111415','Dirigente do servi�o p�blico municipal'})
aAdd(aCBO,{'111410','Dirigente do servi�o p�blico estadual e distrital'})
aAdd(aCBO,{'111405','Dirigente do servi�o p�blico federal'})
aAdd(aCBO,{'111505','Especialista de pol�ticas p�blicas e gest�o governamental - eppgg'})
aAdd(aCBO,{'111510','Analista de planejamento e or�amento - apo'})
aAdd(aCBO,{'113010','L�der de comunidade cai�ara'})
aAdd(aCBO,{'113005','Cacique'})
aAdd(aCBO,{'113015','Membro de lideran�a quilombola'})
aAdd(aCBO,{'114105','Dirigente de partido pol�tico'})
aAdd(aCBO,{'114210','Dirigentes de entidades patronais'})
aAdd(aCBO,{'114205','Dirigentes de entidades de trabalhadores'})
aAdd(aCBO,{'114305','Dirigente e administrador de organiza��o religiosa'})
aAdd(aCBO,{'114405','Dirigente e administrador de organiza��o da sociedade civil sem fins lucrativos'})
aAdd(aCBO,{'121010','Diretor geral de empresa e organiza��es (exceto de interesse p�blico)'})
aAdd(aCBO,{'121005','Diretor de planejamento estrat�gico'})
aAdd(aCBO,{'122105','Diretor de produ��o e opera��es em empresa agropecu�ria'})
aAdd(aCBO,{'122110','Diretor de produ��o e opera��es em empresa aq��cola'})
aAdd(aCBO,{'122115','Diretor de produ��o e opera��es em empresa florestal'})
aAdd(aCBO,{'122120','Diretor de produ��o e opera��es em empresa pesqueira'})
aAdd(aCBO,{'122205','Diretor de produ��o e opera��es da ind�stria de transforma��o, extra��o mineral e utilidades'})
aAdd(aCBO,{'122305','Diretor de opera��es de obras p�blica e civil'})
aAdd(aCBO,{'122405','Diretor de opera��es comerciais (com�rcio atacadista e varejista)'})
aAdd(aCBO,{'122520','Turism�logo'})
aAdd(aCBO,{'122515','Diretor de produ��o e opera��es de turismo'})
aAdd(aCBO,{'122510','Diretor de produ��o e opera��es de hotel'})
aAdd(aCBO,{'122505','Diretor de produ��o e opera��es de alimenta��o'})
aAdd(aCBO,{'122605','Diretor de opera��es de correios'})
aAdd(aCBO,{'122620','Diretor de opera��es de servi�os de transporte'})
aAdd(aCBO,{'122615','Diretor de opera��es de servi�os de telecomunica��es'})
aAdd(aCBO,{'122610','Diretor de opera��es de servi�os de armazenamento'})
aAdd(aCBO,{'122720','Diretor de c�mbio e com�rcio exterior'})
aAdd(aCBO,{'122715','Diretor de cr�dito rural'})
aAdd(aCBO,{'122710','Diretor de produtos banc�rios'})
aAdd(aCBO,{'122705','Diretor comercial em opera��es de intermedia��o financeira'})
aAdd(aCBO,{'122740','Diretor de leasing'})
aAdd(aCBO,{'122745','Diretor de mercado de capitais'})
aAdd(aCBO,{'122750','Diretor de recupera��o de cr�ditos em opera��es de intermedia��o financeira'})
aAdd(aCBO,{'122755','Diretor de riscos de mercado'})
aAdd(aCBO,{'122725','Diretor de compliance'})
aAdd(aCBO,{'122735','Diretor de cr�dito imobili�rio'})
aAdd(aCBO,{'122730','Diretor de cr�dito (exceto cr�dito imobili�rio)'})
aAdd(aCBO,{'123115','Diretor financeiro'})
aAdd(aCBO,{'123105','Diretor administrativo'})
aAdd(aCBO,{'123110','Diretor administrativo e financeiro'})
aAdd(aCBO,{'123210','Diretor de rela��es de trabalho'})
aAdd(aCBO,{'123205','Diretor de recursos humanos'})
aAdd(aCBO,{'123310','Diretor de marketing'})
aAdd(aCBO,{'123305','Diretor comercial'})
aAdd(aCBO,{'123405','Diretor de suprimentos'})
aAdd(aCBO,{'123410','Diretor de suprimentos no servi�o p�blico'})
aAdd(aCBO,{'123605','Diretor de servi�os de inform�tica'})
aAdd(aCBO,{'123705','Diretor de pesquisa e desenvolvimento (p&d)'})
aAdd(aCBO,{'123805','Diretor de manuten��o'})
aAdd(aCBO,{'131105','Diretor de servi�os culturais'})
aAdd(aCBO,{'131110','Diretor de servi�os sociais'})
aAdd(aCBO,{'131115','Gerente de servi�os culturais'})
aAdd(aCBO,{'131120','Gerente de servi�os sociais'})
aAdd(aCBO,{'131205','Diretor de servi�os de sa�de'})
aAdd(aCBO,{'131215','Tecn�logo em gest�o hospitalar'})
aAdd(aCBO,{'131210','Gerente de servi�os de sa�de'})
aAdd(aCBO,{'131305','Diretor de institui��o educacional da �rea privada'})
aAdd(aCBO,{'131310','Diretor de institui��o educacional p�blica'})
aAdd(aCBO,{'131320','Gerente de servi�os educacionais da �rea p�blica'})
aAdd(aCBO,{'131315','Gerente de institui��o educacional da �rea privada'})
aAdd(aCBO,{'141105','Gerente de produ��o e opera��es aq��colas'})
aAdd(aCBO,{'141115','Gerente de produ��o e opera��es agropecu�rias'})
aAdd(aCBO,{'141110','Gerente de produ��o e opera��es florestais'})
aAdd(aCBO,{'141120','Gerente de produ��o e opera��es pesqueiras'})
aAdd(aCBO,{'141205','Gerente de produ��o e opera��es'})
aAdd(aCBO,{'141305','Gerente de produ��o e opera��es da constru��o civil e obras p�blicas'})
aAdd(aCBO,{'141420','Gerente de opera��es de servi�os de assist�ncia t�cnica'})
aAdd(aCBO,{'141415','Gerente de loja e supermercado'})
aAdd(aCBO,{'141410','Comerciante varejista'})
aAdd(aCBO,{'141405','Comerciante atacadista'})
aAdd(aCBO,{'141520','Gerente de pens�o'})
aAdd(aCBO,{'141525','Gerente de turismo'})
aAdd(aCBO,{'141510','Gerente de restaurante'})
aAdd(aCBO,{'141515','Gerente de bar'})
aAdd(aCBO,{'141505','Gerente de hotel'})
aAdd(aCBO,{'141605','Gerente de opera��es de transportes'})
aAdd(aCBO,{'141610','Gerente de opera��es de correios e telecomunica��es'})
aAdd(aCBO,{'141615','Gerente de log�stica (armazenagem e distribui��o)'})
aAdd(aCBO,{'141735','Gerente de recupera��o de cr�dito'})
aAdd(aCBO,{'141725','Gerente de cr�dito imobili�rio'})
aAdd(aCBO,{'141730','Gerente de cr�dito rural'})
aAdd(aCBO,{'141720','Gerente de cr�dito e cobran�a'})
aAdd(aCBO,{'141715','Gerente de c�mbio e com�rcio exterior'})
aAdd(aCBO,{'141710','Gerente de ag�ncia'})
aAdd(aCBO,{'141705','Gerente de produtos banc�rios'})
aAdd(aCBO,{'142105','Gerente administrativo'})
aAdd(aCBO,{'142110','Gerente de riscos'})
aAdd(aCBO,{'142115','Gerente financeiro'})
aAdd(aCBO,{'142120','Tecn�logo em gest�o administrativo- financeira'})
aAdd(aCBO,{'142205','Gerente de recursos humanos'})
aAdd(aCBO,{'142210','Gerente de departamento pessoal'})
aAdd(aCBO,{'142305','Gerente comercial'})
aAdd(aCBO,{'142310','Gerente de comunica��o'})
aAdd(aCBO,{'142315','Gerente de marketing'})
aAdd(aCBO,{'142320','Gerente de vendas'})
aAdd(aCBO,{'142325','Rela��es p�blicas'})
aAdd(aCBO,{'142330','Analista de neg�cios'})
aAdd(aCBO,{'142335','Analista de pesquisa de mercado'})
aAdd(aCBO,{'142340','Ouvidor'})
aAdd(aCBO,{'142405','Gerente de compras'})
aAdd(aCBO,{'142410','Gerente de suprimentos'})
aAdd(aCBO,{'142415','Gerente de almoxarifado'})
aAdd(aCBO,{'142505','Gerente de rede'})
aAdd(aCBO,{'142520','Gerente de projetos de tecnologia da informa��o'})
aAdd(aCBO,{'142515','Gerente de produ��o de tecnologia da informa��o'})
aAdd(aCBO,{'142525','Gerente de seguran�a de tecnologia da informa��o'})
aAdd(aCBO,{'142530','Gerente de suporte t�cnico de tecnologia da informa��o'})
aAdd(aCBO,{'142510','Gerente de desenvolvimento de sistemas'})
aAdd(aCBO,{'142535','Tecn�logo em gest�o da tecnologia da informa��o'})
aAdd(aCBO,{'142605','Gerente de pesquisa e desenvolvimento (p&d)'})
aAdd(aCBO,{'142610','Especialista em desenvolvimento de cigarros'})
aAdd(aCBO,{'142705','Gerente de projetos e servi�os de manuten��o'})
aAdd(aCBO,{'142710','Tecn�logo em sistemas biom�dicos'})
aAdd(aCBO,{'201105','Bioengenheiro'})
aAdd(aCBO,{'201110','Biotecnologista'})
aAdd(aCBO,{'201115','Geneticista'})
aAdd(aCBO,{'201220','Especialista em instrumenta��o metrol�gica'})
aAdd(aCBO,{'201215','Especialista em ensaios metrol�gicos'})
aAdd(aCBO,{'201210','Especialista em calibra��es metrol�gicas'})
aAdd(aCBO,{'201225','Especialista em materiais de refer�ncia metrol�gica'})
aAdd(aCBO,{'201205','Pesquisador em metrologia'})
aAdd(aCBO,{'202115','Tecn�logo em mecatr�nica'})
aAdd(aCBO,{'202120','Tecn�logo em automa��o industrial'})
aAdd(aCBO,{'202110','Engenheiro de controle e automa��o'})
aAdd(aCBO,{'202105','Engenheiro mecatr�nico'})
aAdd(aCBO,{'203005','Pesquisador em biologia ambiental'})
aAdd(aCBO,{'203010','Pesquisador em biologia animal'})
aAdd(aCBO,{'203015','Pesquisador em biologia de microorganismos e parasitas'})
aAdd(aCBO,{'203020','Pesquisador em biologia humana'})
aAdd(aCBO,{'203025','Pesquisador em biologia vegetal'})
aAdd(aCBO,{'203115','Pesquisador em f�sica'})
aAdd(aCBO,{'203110','Pesquisador em ci�ncias da terra e meio ambiente'})
aAdd(aCBO,{'203105','Pesquisador em ci�ncias da computa��o e inform�tica'})
aAdd(aCBO,{'203120','Pesquisador em matem�tica'})
aAdd(aCBO,{'203125','Pesquisador em qu�mica'})
aAdd(aCBO,{'203215','Pesquisador de engenharia el�trica e eletr�nica'})
aAdd(aCBO,{'203210','Pesquisador de engenharia e tecnologia (outras �reas da engenharia)'})
aAdd(aCBO,{'203205','Pesquisador de engenharia civil'})
aAdd(aCBO,{'203220','Pesquisador de engenharia mec�nica'})
aAdd(aCBO,{'203225','Pesquisador de engenharia metal�rgica, de minas e de materiais'})
aAdd(aCBO,{'203230','Pesquisador de engenharia qu�mica'})
aAdd(aCBO,{'203315','Pesquisador em medicina veterin�ria'})
aAdd(aCBO,{'203310','Pesquisador de medicina b�sica'})
aAdd(aCBO,{'203305','Pesquisador de cl�nica m�dica'})
aAdd(aCBO,{'203320','Pesquisador em sa�de coletiva'})
aAdd(aCBO,{'203405','Pesquisador em ci�ncias agron�micas'})
aAdd(aCBO,{'203410','Pesquisador em ci�ncias da pesca e aq�icultura'})
aAdd(aCBO,{'203415','Pesquisador em ci�ncias da zootecnia'})
aAdd(aCBO,{'203420','Pesquisador em ci�ncias florestais'})
aAdd(aCBO,{'203505','Pesquisador em ci�ncias sociais e humanas'})
aAdd(aCBO,{'203510','Pesquisador em economia'})
aAdd(aCBO,{'203515','Pesquisador em ci�ncias da educa��o'})
aAdd(aCBO,{'203520','Pesquisador em hist�ria'})
aAdd(aCBO,{'203525','Pesquisador em psicologia'})
aAdd(aCBO,{'204105','Perito criminal'})
aAdd(aCBO,{'211105','Atu�rio'})
aAdd(aCBO,{'211120','Matem�tico aplicado'})
aAdd(aCBO,{'211115','Matem�tico'})
aAdd(aCBO,{'211110','Especialista em pesquisa operacional'})
aAdd(aCBO,{'211210','Estat�stico (estat�stica aplicada)'})
aAdd(aCBO,{'211215','Estat�stico te�rico'})
aAdd(aCBO,{'211205','Estat�stico'})
aAdd(aCBO,{'212215','Engenheiros de sistemas operacionais em computa��o'})
aAdd(aCBO,{'212210','Engenheiro de equipamentos em computa��o'})
aAdd(aCBO,{'212205','Engenheiro de aplicativos em computa��o'})
aAdd(aCBO,{'212305','Administrador de banco de dados'})
aAdd(aCBO,{'212310','Administrador de redes'})
aAdd(aCBO,{'212320','Administrador em seguran�a da informa��o'})
aAdd(aCBO,{'212315','Administrador de sistemas operacionais'})
aAdd(aCBO,{'212410','Analista de redes e de comunica��o de dados'})
aAdd(aCBO,{'212415','Analista de sistemas de automa��o'})
aAdd(aCBO,{'212405','Analista de desenvolvimento de sistemas'})
aAdd(aCBO,{'212420','Analista de suporte computacional'})
aAdd(aCBO,{'213140','F�sico (mat�ria condensada)'})
aAdd(aCBO,{'213170','F�sico (plasma)'})
aAdd(aCBO,{'213175','F�sico (t�rmica)'})
aAdd(aCBO,{'213135','F�sico (instrumenta��o)'})
aAdd(aCBO,{'213130','F�sico (fluidos)'})
aAdd(aCBO,{'213120','F�sico (cosmologia)'})
aAdd(aCBO,{'213115','F�sico (at�mica e molecular)'})
aAdd(aCBO,{'213165','F�sico (part�culas e campos)'})
aAdd(aCBO,{'213160','F�sico (�ptica)'})
aAdd(aCBO,{'213155','F�sico (nuclear e reatores)'})
aAdd(aCBO,{'213150','F�sico (medicina)'})
aAdd(aCBO,{'213145','F�sico (materiais)'})
aAdd(aCBO,{'213125','F�sico (estat�stica e matem�tica)'})
aAdd(aCBO,{'213110','F�sico (ac�stica)'})
aAdd(aCBO,{'213105','F�sico'})
aAdd(aCBO,{'213205','Qu�mico'})
aAdd(aCBO,{'213210','Qu�mico industrial'})
aAdd(aCBO,{'213215','Tecn�logo em processos qu�micos'})
aAdd(aCBO,{'213315','Meteorologista'})
aAdd(aCBO,{'213305','Astr�nomo'})
aAdd(aCBO,{'213310','Geof�sico espacial'})
aAdd(aCBO,{'213405','Ge�logo'})
aAdd(aCBO,{'213410','Ge�logo de engenharia'})
aAdd(aCBO,{'213415','Geof�sico'})
aAdd(aCBO,{'213420','Geoqu�mico'})
aAdd(aCBO,{'213440','Ocean�grafo'})
aAdd(aCBO,{'213435','Petr�grafo'})
aAdd(aCBO,{'213425','Hidroge�logo'})
aAdd(aCBO,{'213430','Paleont�logo'})
aAdd(aCBO,{'214010','Tecn�logo em meio ambiente'})
aAdd(aCBO,{'214005','Engenheiro ambiental'})
aAdd(aCBO,{'214120','Arquiteto paisagista'})
aAdd(aCBO,{'214115','Arquiteto de patrim�nio'})
aAdd(aCBO,{'214110','Arquiteto de interiores'})
aAdd(aCBO,{'214130','Urbanista'})
aAdd(aCBO,{'214105','Arquiteto de edifica��es'})
aAdd(aCBO,{'214125','Arquiteto urbanista'})
aAdd(aCBO,{'214205','Engenheiro civil'})
aAdd(aCBO,{'214210','Engenheiro civil (aeroportos)'})
aAdd(aCBO,{'214215','Engenheiro civil (edifica��es)'})
aAdd(aCBO,{'214220','Engenheiro civil (estruturas met�licas)'})
aAdd(aCBO,{'214225','Engenheiro civil (ferrovias e metrovias)'})
aAdd(aCBO,{'214230','Engenheiro civil (geot�cnia)'})
aAdd(aCBO,{'214235','Engenheiro civil (hidrologia)'})
aAdd(aCBO,{'214240','Engenheiro civil (hidr�ulica)'})
aAdd(aCBO,{'214245','Engenheiro civil (pontes e viadutos)'})
aAdd(aCBO,{'214250','Engenheiro civil (portos e vias naveg�veis)'})
aAdd(aCBO,{'214255','Engenheiro civil (rodovias)'})
aAdd(aCBO,{'214260','Engenheiro civil (saneamento)'})
aAdd(aCBO,{'214265','Engenheiro civil (t�neis)'})
aAdd(aCBO,{'214270','Engenheiro civil (transportes e tr�nsito)'})
aAdd(aCBO,{'214280','Tecn�logo em constru��o civil'})
aAdd(aCBO,{'214335','Engenheiro de manuten��o de telecomunica��es'})
aAdd(aCBO,{'214365','Tecn�logo em eletr�nica'})
aAdd(aCBO,{'214340','Engenheiro de telecomunica��es'})
aAdd(aCBO,{'214345','Engenheiro projetista de telecomunica��es'})
aAdd(aCBO,{'214350','Engenheiro de redes de comunica��o'})
aAdd(aCBO,{'214360','Tecn�logo em eletricidade'})
aAdd(aCBO,{'214330','Engenheiro eletr�nico de projetos'})
aAdd(aCBO,{'214305','Engenheiro eletricista'})
aAdd(aCBO,{'214310','Engenheiro eletr�nico'})
aAdd(aCBO,{'214315','Engenheiro eletricista de manuten��o'})
aAdd(aCBO,{'214325','Engenheiro eletr�nico de manuten��o'})
aAdd(aCBO,{'214320','Engenheiro eletricista de projetos'})
aAdd(aCBO,{'214370','Tecn�logo em telecomunica��es'})
aAdd(aCBO,{'214410','Engenheiro mec�nico automotivo'})
aAdd(aCBO,{'214415','Engenheiro mec�nico (energia nuclear)'})
aAdd(aCBO,{'214420','Engenheiro mec�nico industrial'})
aAdd(aCBO,{'214425','Engenheiro aeron�utico'})
aAdd(aCBO,{'214430','Engenheiro naval'})
aAdd(aCBO,{'214435','Tecn�logo em fabrica��o mec�nica'})
aAdd(aCBO,{'214405','Engenheiro mec�nico'})
aAdd(aCBO,{'214535','Tecn�logo em produ��o sulcroalcooleira'})
aAdd(aCBO,{'214525','Engenheiro qu�mico (petr�leo e borracha)'})
aAdd(aCBO,{'214520','Engenheiro qu�mico (papel e celulose)'})
aAdd(aCBO,{'214515','Engenheiro qu�mico (minera��o, metalurgia, siderurgia, cimenteira e cer�mica)'})
aAdd(aCBO,{'214510','Engenheiro qu�mico (ind�stria qu�mica)'})
aAdd(aCBO,{'214505','Engenheiro qu�mico'})
aAdd(aCBO,{'214530','Engenheiro qu�mico (utilidades e meio ambiente)'})
aAdd(aCBO,{'214615','Tecn�logo em metalurgia'})
aAdd(aCBO,{'214610','Engenheiro metalurgista'})
aAdd(aCBO,{'214605','Engenheiro de materiais'})
aAdd(aCBO,{'214725','Engenheiro de minas (pesquisa mineral)'})
aAdd(aCBO,{'214730','Engenheiro de minas (planejamento)'})
aAdd(aCBO,{'214735','Engenheiro de minas (processo)'})
aAdd(aCBO,{'214740','Engenheiro de minas (projeto)'})
aAdd(aCBO,{'214745','Tecn�logo em petr�leo e g�s'})
aAdd(aCBO,{'214750','Tecn�logo em rochas ornamentais'})
aAdd(aCBO,{'214720','Engenheiro de minas (lavra subterr�nea)'})
aAdd(aCBO,{'214705','Engenheiro de minas'})
aAdd(aCBO,{'214710','Engenheiro de minas (beneficiamento)'})
aAdd(aCBO,{'214715','Engenheiro de minas (lavra a c�u aberto)'})
aAdd(aCBO,{'214805','Engenheiro agrimensor'})
aAdd(aCBO,{'214810','Engenheiro cart�grafo'})
aAdd(aCBO,{'214925','Engenheiro de tempos e movimentos'})
aAdd(aCBO,{'214915','Engenheiro de seguran�a do trabalho'})
aAdd(aCBO,{'214910','Engenheiro de controle de qualidade'})
aAdd(aCBO,{'214905','Engenheiro de produ��o'})
aAdd(aCBO,{'214930','Tecn�logo em produ��o industrial'})
aAdd(aCBO,{'214935','Tecn�logo em seguran�a do trabalho'})
aAdd(aCBO,{'214920','Engenheiro de riscos'})
aAdd(aCBO,{'215135','Inspetor naval'})
aAdd(aCBO,{'215130','Inspetor de terminal'})
aAdd(aCBO,{'215145','Pr�tico de portos da marinha mercante'})
aAdd(aCBO,{'215150','Vistoriador naval'})
aAdd(aCBO,{'215140','Oficial de quarto de navega��o da marinha mercante'})
aAdd(aCBO,{'215125','Imediato da marinha mercante'})
aAdd(aCBO,{'215120','Coordenador de opera��es de combate � polui��o no meio aquavi�rio'})
aAdd(aCBO,{'215115','Comandante da marinha mercante'})
aAdd(aCBO,{'215110','Capit�o de manobra da marinha mercante'})
aAdd(aCBO,{'215105','Agente de manobra e docagem'})
aAdd(aCBO,{'215220','Superintendente t�cnico no transporte aquavi�rio'})
aAdd(aCBO,{'215215','Segundo oficial de m�quinas da marinha mercante'})
aAdd(aCBO,{'215210','Primeiro oficial de m�quinas da marinha mercante'})
aAdd(aCBO,{'215205','Oficial superior de m�quinas da marinha mercante'})
aAdd(aCBO,{'215315','Instrutor de v�o'})
aAdd(aCBO,{'215310','Piloto de ensaios em v�o'})
aAdd(aCBO,{'215305','Piloto de aeronaves'})
aAdd(aCBO,{'221105','Bi�logo'})
aAdd(aCBO,{'221205','Biom�dico'})
aAdd(aCBO,{'222120','Engenheiro florestal'})
aAdd(aCBO,{'222115','Engenheiro de pesca'})
aAdd(aCBO,{'222110','Engenheiro agr�nomo'})
aAdd(aCBO,{'222105','Engenheiro agr�cola'})
aAdd(aCBO,{'222205','Engenheiro de alimentos'})
aAdd(aCBO,{'222215','Tecn�logo em alimentos'})
aAdd(aCBO,{'223293','Cirurgi�o-dentista da estrat�gia de sa�de da fam�lia'})
aAdd(aCBO,{'223288','Cirurgi�o dentista - odontologia para pacientes com necessidades especiais'})
aAdd(aCBO,{'223284','Cirurgi�o dentista - disfun��o temporomandibular e dor orofacial'})
aAdd(aCBO,{'223276','Cirurgi�o dentista - odontologia do trabalho'})
aAdd(aCBO,{'223280','Cirurgi�o dentista - dent�stica'})
aAdd(aCBO,{'223272','Cirurgi�o dentista de sa�de coletiva'})
aAdd(aCBO,{'223204','Cirurgi�o dentista - auditor'})
aAdd(aCBO,{'223208','Cirurgi�o dentista - cl�nico geral'})
aAdd(aCBO,{'223212','Cirurgi�o dentista - endodontista'})
aAdd(aCBO,{'223216','Cirurgi�o dentista - epidemiologista'})
aAdd(aCBO,{'223220','Cirurgi�o dentista - estomatologista'})
aAdd(aCBO,{'223224','Cirurgi�o dentista - implantodontista'})
aAdd(aCBO,{'223228','Cirurgi�o dentista - odontogeriatra'})
aAdd(aCBO,{'223232','Cirurgi�o dentista - odontologista legal'})
aAdd(aCBO,{'223236','Cirurgi�o dentista - odontopediatra'})
aAdd(aCBO,{'223240','Cirurgi�o dentista - ortopedista e ortodontista'})
aAdd(aCBO,{'223244','Cirurgi�o dentista - patologista bucal'})
aAdd(aCBO,{'223248','Cirurgi�o dentista - periodontista'})
aAdd(aCBO,{'223252','Cirurgi�o dentista - protesi�logo bucomaxilofacial'})
aAdd(aCBO,{'223256','Cirurgi�o dentista - protesista'})
aAdd(aCBO,{'223260','Cirurgi�o dentista - radiologista'})
aAdd(aCBO,{'223264','Cirurgi�o dentista - reabilitador oral'})
aAdd(aCBO,{'223268','Cirurgi�o dentista - traumatologista bucomaxilofacial'})
aAdd(aCBO,{'223305','M�dico veterin�rio'})
aAdd(aCBO,{'223310','Zootecnista'})
aAdd(aCBO,{'223445','Farmac�utico hospitalar e cl�nico'})
aAdd(aCBO,{'223420','Farmac�utico de alimentos'})
aAdd(aCBO,{'223405','Farmac�utico'})
aAdd(aCBO,{'223415','Farmac�utico analista cl�nico'})
aAdd(aCBO,{'223425','Farmac�utico pr�ticas integrativas e complementares'})
aAdd(aCBO,{'223430','Farmac�utico em sa�de p�blica'})
aAdd(aCBO,{'223435','Farmac�utico industrial'})
aAdd(aCBO,{'223440','Farmac�utico toxicologista'})
aAdd(aCBO,{'223515','Enfermeiro de bordo'})
aAdd(aCBO,{'223510','Enfermeiro auditor'})
aAdd(aCBO,{'223570','Perfusionista'})
aAdd(aCBO,{'223505','Enfermeiro'})
aAdd(aCBO,{'223520','Enfermeiro de centro cir�rgico'})
aAdd(aCBO,{'223525','Enfermeiro de terapia intensiva'})
aAdd(aCBO,{'223530','Enfermeiro do trabalho'})
aAdd(aCBO,{'223535','Enfermeiro nefrologista'})
aAdd(aCBO,{'223540','Enfermeiro neonatologista'})
aAdd(aCBO,{'223545','Enfermeiro obst�trico'})
aAdd(aCBO,{'223550','Enfermeiro psiqui�trico'})
aAdd(aCBO,{'223565','Enfermeiro da estrat�gia de sa�de da fam�lia'})
aAdd(aCBO,{'223560','Enfermeiro sanitarista'})
aAdd(aCBO,{'223555','Enfermeiro puericultor e pedi�trico'})
aAdd(aCBO,{'223660','Fisioterapeuta do trabalho'})
aAdd(aCBO,{'223655','Fisioterapeuta esportivo'})
aAdd(aCBO,{'223650','Fisioterapeuta acupunturista'})
aAdd(aCBO,{'223645','Fisioterapeuta quiropraxista'})
aAdd(aCBO,{'223605','Fisioterapeuta geral'})
aAdd(aCBO,{'223635','Fisioterapeuta traumato-ortop�dica funcional'})
aAdd(aCBO,{'223630','Fisioterapeuta neurofuncional'})
aAdd(aCBO,{'223625','Fisioterapeuta respirat�ria'})
aAdd(aCBO,{'223640','Fisioterapeuta osteopata'})
aAdd(aCBO,{'223705','Dietista'})
aAdd(aCBO,{'223710','Nutricionista'})
aAdd(aCBO,{'223840','Fonoaudi�logo em sa�de coletiva'})
aAdd(aCBO,{'223810','Fonoaudi�logo geral'})
aAdd(aCBO,{'223820','Fonoaudi�logo em audiologia'})
aAdd(aCBO,{'223815','Fonoaudi�logo educacional'})
aAdd(aCBO,{'223845','Fonoaudi�logo em voz'})
aAdd(aCBO,{'223835','Fonoaudi�logo em motricidade orofacial'})
aAdd(aCBO,{'223830','Fonoaudi�logo em linguagem'})
aAdd(aCBO,{'223825','Fonoaudi�logo em disfagia'})
aAdd(aCBO,{'223910','Ortoptista'})
aAdd(aCBO,{'223905','Terapeuta ocupacional'})
aAdd(aCBO,{'224105','Avaliador f�sico'})
aAdd(aCBO,{'224110','Ludomotricista'})
aAdd(aCBO,{'224115','Preparador de atleta'})
aAdd(aCBO,{'224135','Treinador profissional de futebol'})
aAdd(aCBO,{'224125','T�cnico de desporto individual e coletivo (exceto futebol)'})
aAdd(aCBO,{'224130','T�cnico de laborat�rio e fiscaliza��o desportiva'})
aAdd(aCBO,{'224120','Preparador f�sico'})
aAdd(aCBO,{'225195','M�dico homeopata'})
aAdd(aCBO,{'225142','M�dico da estrat�gia de sa�de da fam�lia'})
aAdd(aCBO,{'225180','M�dico geriatra'})
aAdd(aCBO,{'225175','M�dico geneticista'})
aAdd(aCBO,{'225170','M�dico generalista'})
aAdd(aCBO,{'225165','M�dico gastroenterologista'})
aAdd(aCBO,{'225160','M�dico fisiatra'})
aAdd(aCBO,{'225155','M�dico endocrinologista e metabologista'})
aAdd(aCBO,{'225151','M�dico anestesiologista'})
aAdd(aCBO,{'225150','M�dico em medicina intensiva'})
aAdd(aCBO,{'225148','M�dico anatomopatologista'})
aAdd(aCBO,{'225145','M�dico em medicina de tr�fego'})
aAdd(aCBO,{'225154','M�dico antropos�fico'})
aAdd(aCBO,{'225103','M�dico infectologista'})
aAdd(aCBO,{'225105','M�dico acupunturista'})
aAdd(aCBO,{'225106','M�dico legista'})
aAdd(aCBO,{'225109','M�dico nefrologista'})
aAdd(aCBO,{'225110','M�dico alergista e imunologista'})
aAdd(aCBO,{'225112','M�dico neurologista'})
aAdd(aCBO,{'225115','M�dico angiologista'})
aAdd(aCBO,{'225118','M�dico nutrologista'})
aAdd(aCBO,{'225120','M�dico cardiologista'})
aAdd(aCBO,{'225121','M�dico oncologista cl�nico'})
aAdd(aCBO,{'225122','M�dico cancerologista pedi�trico'})
aAdd(aCBO,{'225124','M�dico pediatra'})
aAdd(aCBO,{'225125','M�dico cl�nico'})
aAdd(aCBO,{'225127','M�dico pneumologista'})
aAdd(aCBO,{'225130','M�dico de fam�lia e comunidade'})
aAdd(aCBO,{'225133','M�dico psiquiatra'})
aAdd(aCBO,{'225135','M�dico dermatologista'})
aAdd(aCBO,{'225136','M�dico reumatologista'})
aAdd(aCBO,{'225139','M�dico sanitarista'})
aAdd(aCBO,{'225140','M�dico do trabalho'})
aAdd(aCBO,{'225185','M�dico hematologista'})
aAdd(aCBO,{'225295','M�dico cirurgi�o da m�o'})
aAdd(aCBO,{'225290','M�dico cancerologista cirurg�co'})
aAdd(aCBO,{'225285','M�dico urologista'})
aAdd(aCBO,{'225280','M�dico coloproctologista'})
aAdd(aCBO,{'225275','M�dico otorrinolaringologista'})
aAdd(aCBO,{'225270','M�dico ortopedista e traumatologista'})
aAdd(aCBO,{'225265','M�dico oftalmologista'})
aAdd(aCBO,{'225260','M�dico neurocirurgi�o'})
aAdd(aCBO,{'225255','M�dico mastologista'})
aAdd(aCBO,{'225250','M�dico ginecologista e obstetra'})
aAdd(aCBO,{'225230','M�dico cirurgi�o pedi�trico'})
aAdd(aCBO,{'225235','M�dico cirurgi�o pl�stico'})
aAdd(aCBO,{'225240','M�dico cirurgi�o tor�cico'})
aAdd(aCBO,{'225225','M�dico cirurgi�o geral'})
aAdd(aCBO,{'225220','M�dico cirurgi�o do aparelho digestivo'})
aAdd(aCBO,{'225215','M�dico cirurgi�o de cabe�a e pesco�o'})
aAdd(aCBO,{'225210','M�dico cirurgi�o cardiovascular'})
aAdd(aCBO,{'225203','M�dico em cirurgia vascular'})
aAdd(aCBO,{'225335','M�dico patologista cl�nico / medicina laboratorial'})
aAdd(aCBO,{'225340','M�dico hemoterapeuta'})
aAdd(aCBO,{'225345','M�dico hiperbarista'})
aAdd(aCBO,{'225350','M�dico neurofisiologista cl�nico'})
aAdd(aCBO,{'225305','M�dico citopatologista'})
aAdd(aCBO,{'225325','M�dico patologista'})
aAdd(aCBO,{'225320','M�dico em radiologia e diagn�stico por imagem'})
aAdd(aCBO,{'225315','M�dico em medicina nuclear'})
aAdd(aCBO,{'225310','M�dico em endoscopia'})
aAdd(aCBO,{'225330','M�dico radioterapeuta'})
aAdd(aCBO,{'226105','Quiropraxista'})
aAdd(aCBO,{'226110','Osteopata'})
aAdd(aCBO,{'226310','Arteterapeuta'})
aAdd(aCBO,{'226305','Musicoterapeuta'})
aAdd(aCBO,{'226315','Equoterapeuta'})
aAdd(aCBO,{'231110','Professor de n�vel superior na educa��o infantil (zero a tr�s anos)'})
aAdd(aCBO,{'231105','Professor de n�vel superior na educa��o infantil (quatro a seis anos)'})
aAdd(aCBO,{'231205','Professor da educa��o de jovens e adultos do ensino fundamental (primeira a quarta s�rie)'})
aAdd(aCBO,{'231210','Professor de n�vel superior do ensino fundamental (primeira a quarta s�rie)'})
aAdd(aCBO,{'231305','Professor de ci�ncias exatas e naturais do ensino fundamental'})
aAdd(aCBO,{'231310','Professor de educa��o art�stica do ensino fundamental'})
aAdd(aCBO,{'231315','Professor de educa��o f�sica do ensino fundamental'})
aAdd(aCBO,{'231340','Professor de matem�tica do ensino fundamental'})
aAdd(aCBO,{'231325','Professor de hist�ria do ensino fundamental'})
aAdd(aCBO,{'231330','Professor de l�ngua estrangeira moderna do ensino fundamental'})
aAdd(aCBO,{'231335','Professor de l�ngua portuguesa do ensino fundamental'})
aAdd(aCBO,{'231320','Professor de geografia do ensino fundamental'})
aAdd(aCBO,{'232140','Professor de hist�ria no ensino m�dio'})
aAdd(aCBO,{'232150','Professor de l�ngua estrangeira moderna no ensino m�dio'})
aAdd(aCBO,{'232160','Professor de psicologia no ensino m�dio'})
aAdd(aCBO,{'232165','Professor de qu�mica no ensino m�dio'})
aAdd(aCBO,{'232105','Professor de artes no ensino m�dio'})
aAdd(aCBO,{'232120','Professor de educa��o f�sica no ensino m�dio'})
aAdd(aCBO,{'232125','Professor de filosofia no ensino m�dio'})
aAdd(aCBO,{'232130','Professor de f�sica no ensino m�dio'})
aAdd(aCBO,{'232135','Professor de geografia no ensino m�dio'})
aAdd(aCBO,{'232145','Professor de l�ngua e literatura brasileira no ensino m�dio'})
aAdd(aCBO,{'232155','Professor de matem�tica no ensino m�dio'})
aAdd(aCBO,{'232170','Professor de sociologia no ensino m�dio'})
aAdd(aCBO,{'232110','Professor de biologia no ensino m�dio'})
aAdd(aCBO,{'232115','Professor de disciplinas pedag�gicas no ensino m�dio'})
aAdd(aCBO,{'233105','Professor da �rea de meio ambiente'})
aAdd(aCBO,{'233110','Professor de desenho t�cnico'})
aAdd(aCBO,{'233115','Professor de t�cnicas agr�colas'})
aAdd(aCBO,{'233120','Professor de t�cnicas comerciais e secretariais'})
aAdd(aCBO,{'233125','Professor de t�cnicas de enfermagem'})
aAdd(aCBO,{'233130','Professor de t�cnicas industriais'})
aAdd(aCBO,{'233135','Professor de tecnologia e c�lculo t�cnico'})
aAdd(aCBO,{'233205','Instrutor de aprendizagem e treinamento agropecu�rio'})
aAdd(aCBO,{'233210','Instrutor de aprendizagem e treinamento industrial'})
aAdd(aCBO,{'233215','Professor de aprendizagem e treinamento comercial'})
aAdd(aCBO,{'233220','Professor instrutor de ensino e aprendizagem agroflorestal'})
aAdd(aCBO,{'233225','Professor instrutor de ensino e aprendizagem em servi�os'})
aAdd(aCBO,{'234125','Professor de pesquisa operacional (no ensino superior)'})
aAdd(aCBO,{'234120','Professor de computa��o (no ensino superior)'})
aAdd(aCBO,{'234115','Professor de estat�stica (no ensino superior)'})
aAdd(aCBO,{'234110','Professor de matem�tica pura (no ensino superior)'})
aAdd(aCBO,{'234105','Professor de matem�tica aplicada (no ensino superior)'})
aAdd(aCBO,{'234205','Professor de f�sica (ensino superior)'})
aAdd(aCBO,{'234215','Professor de astronomia (ensino superior)'})
aAdd(aCBO,{'234210','Professor de qu�mica (ensino superior)'})
aAdd(aCBO,{'234305','Professor de arquitetura'})
aAdd(aCBO,{'234315','Professor de geof�sica'})
aAdd(aCBO,{'234310','Professor de engenharia'})
aAdd(aCBO,{'234320','Professor de geologia'})
aAdd(aCBO,{'234405','Professor de ci�ncias biol�gicas do ensino superior'})
aAdd(aCBO,{'234415','Professor de enfermagem do ensino superior'})
aAdd(aCBO,{'234460','Professor de zootecnia do ensino superior'})
aAdd(aCBO,{'234455','Professor de terapia ocupacional'})
aAdd(aCBO,{'234410','Professor de educa��o f�sica no ensino superior'})
aAdd(aCBO,{'234420','Professor de farm�cia e bioqu�mica'})
aAdd(aCBO,{'234425','Professor de fisioterapia'})
aAdd(aCBO,{'234430','Professor de fonoaudiologia'})
aAdd(aCBO,{'234435','Professor de medicina'})
aAdd(aCBO,{'234440','Professor de medicina veterin�ria'})
aAdd(aCBO,{'234445','Professor de nutri��o'})
aAdd(aCBO,{'234450','Professor de odontologia'})
aAdd(aCBO,{'234510','Professor de ensino superior na �rea de orienta��o educacional'})
aAdd(aCBO,{'234505','Professor de ensino superior na �rea de did�tica'})
aAdd(aCBO,{'234515','Professor de ensino superior na �rea de pesquisa educacional'})
aAdd(aCBO,{'234520','Professor de ensino superior na �rea de pr�tica de ensino'})
aAdd(aCBO,{'234660','Professor de literatura de l�nguas estrangeiras modernas'})
aAdd(aCBO,{'234664','Professor de outras l�nguas e literaturas'})
aAdd(aCBO,{'234632','Professor de literatura portuguesa'})
aAdd(aCBO,{'234628','Professor de literatura brasileira'})
aAdd(aCBO,{'234624','Professor de l�ngua portuguesa'})
aAdd(aCBO,{'234640','Professor de literatura comparada'})
aAdd(aCBO,{'234656','Professor de literatura italiana'})
aAdd(aCBO,{'234652','Professor de literatura inglesa'})
aAdd(aCBO,{'234648','Professor de literatura francesa'})
aAdd(aCBO,{'234644','Professor de literatura espanhola'})
aAdd(aCBO,{'234636','Professor de literatura alem�'})
aAdd(aCBO,{'234620','Professor de l�ngua espanhola'})
aAdd(aCBO,{'234616','Professor de l�ngua inglesa'})
aAdd(aCBO,{'234612','Professor de l�ngua francesa'})
aAdd(aCBO,{'234608','Professor de l�ngua italiana'})
aAdd(aCBO,{'234604','Professor de l�ngua alem�'})
aAdd(aCBO,{'234684','Professor de teoria da literatura'})
aAdd(aCBO,{'234680','Professor de semi�tica'})
aAdd(aCBO,{'234676','Professor de filologia e cr�tica textual'})
aAdd(aCBO,{'234668','Professor de l�nguas estrangeiras modernas'})
aAdd(aCBO,{'234672','Professor de ling��stica e ling��stica aplicada'})
aAdd(aCBO,{'234770','Professor de sociologia do ensino superior'})
aAdd(aCBO,{'234765','Professor de servi�o social do ensino superior'})
aAdd(aCBO,{'234760','Professor de psicologia do ensino superior'})
aAdd(aCBO,{'234755','Professor de museologia do ensino superior'})
aAdd(aCBO,{'234750','Professor de jornalismo'})
aAdd(aCBO,{'234745','Professor de hist�ria do ensino superior'})
aAdd(aCBO,{'234705','Professor de antropologia do ensino superior'})
aAdd(aCBO,{'234735','Professor de filosofia do ensino superior'})
aAdd(aCBO,{'234730','Professor de direito do ensino superior'})
aAdd(aCBO,{'234725','Professor de comunica��o social do ensino superior'})
aAdd(aCBO,{'234720','Professor de ci�ncia pol�tica do ensino superior'})
aAdd(aCBO,{'234715','Professor de biblioteconomia do ensino superior'})
aAdd(aCBO,{'234710','Professor de arquivologia do ensino superior'})
aAdd(aCBO,{'234740','Professor de geografia do ensino superior'})
aAdd(aCBO,{'234810','Professor de administra��o'})
aAdd(aCBO,{'234815','Professor de contabilidade'})
aAdd(aCBO,{'234805','Professor de economia'})
aAdd(aCBO,{'234905','Professor de artes do espet�culo no ensino superior'})
aAdd(aCBO,{'234915','Professor de m�sica no ensino superior'})
aAdd(aCBO,{'234910','Professor de artes visuais no ensino superior (artes pl�sticas e multim�dia)'})
aAdd(aCBO,{'239220','Professor de alunos com defici�ncia m�ltipla'})
aAdd(aCBO,{'239215','Professor de alunos com defici�ncia mental'})
aAdd(aCBO,{'239210','Professor de alunos com defici�ncia f�sica'})
aAdd(aCBO,{'239205','Professor de alunos com defici�ncia auditiva e surdos'})
aAdd(aCBO,{'239225','Professor de alunos com defici�ncia visual'})
aAdd(aCBO,{'239435','Designer educacional'})
aAdd(aCBO,{'239425','Psicopedagogo'})
aAdd(aCBO,{'239420','Professor de t�cnicas e recursos audiovisuais'})
aAdd(aCBO,{'239415','Pedagogo'})
aAdd(aCBO,{'239410','Orientador educacional'})
aAdd(aCBO,{'239405','Coordenador pedag�gico'})
aAdd(aCBO,{'239430','Supervisor de ensino'})
aAdd(aCBO,{'241005','Advogado'})
aAdd(aCBO,{'241010','Advogado de empresa'})
aAdd(aCBO,{'241040','Consultor jur�dico'})
aAdd(aCBO,{'241035','Advogado (direito do trabalho)'})
aAdd(aCBO,{'241030','Advogado (�reas especiais)'})
aAdd(aCBO,{'241025','Advogado (direito penal)'})
aAdd(aCBO,{'241020','Advogado (direito p�blico)'})
aAdd(aCBO,{'241015','Advogado (direito civil)'})
aAdd(aCBO,{'241225','Procurador do munic�pio'})
aAdd(aCBO,{'241230','Procurador federal'})
aAdd(aCBO,{'241235','Procurador fundacional'})
aAdd(aCBO,{'241220','Procurador do estado'})
aAdd(aCBO,{'241215','Procurador da fazenda nacional'})
aAdd(aCBO,{'241210','Procurador aut�rquico'})
aAdd(aCBO,{'241205','Advogado da uni�o'})
aAdd(aCBO,{'241315','Oficial do registro civil de pessoas naturais'})
aAdd(aCBO,{'241310','Oficial do registro civil de pessoas jur�dicas'})
aAdd(aCBO,{'241305','Oficial de registro de contratos mar�timos'})
aAdd(aCBO,{'241320','Oficial do registro de distribui��es'})
aAdd(aCBO,{'241325','Oficial do registro de im�veis'})
aAdd(aCBO,{'241330','Oficial do registro de t�tulos e documentos'})
aAdd(aCBO,{'241335','Tabeli�o de notas'})
aAdd(aCBO,{'241340','Tabeli�o de protestos'})
aAdd(aCBO,{'242245','Subprocurador-geral da rep�blica'})
aAdd(aCBO,{'242250','Subprocurador-geral do trabalho'})
aAdd(aCBO,{'242205','Procurador da rep�blica'})
aAdd(aCBO,{'242215','Procurador de justi�a militar'})
aAdd(aCBO,{'242220','Procurador do trabalho'})
aAdd(aCBO,{'242235','Promotor de justi�a'})
aAdd(aCBO,{'242210','Procurador de justi�a'})
aAdd(aCBO,{'242225','Procurador regional da rep�blica'})
aAdd(aCBO,{'242230','Procurador regional do trabalho'})
aAdd(aCBO,{'242240','Subprocurador de justi�a militar'})
aAdd(aCBO,{'242305','Delegado de pol�cia'})
aAdd(aCBO,{'242405','Defensor p�blico'})
aAdd(aCBO,{'242410','Procurador da assist�ncia judici�ria'})
aAdd(aCBO,{'242905','Oficial de intelig�ncia'})
aAdd(aCBO,{'242910','Oficial t�cnico de intelig�ncia'})
aAdd(aCBO,{'251105','Antrop�logo'})
aAdd(aCBO,{'251110','Arque�logo'})
aAdd(aCBO,{'251115','Cientista pol�tico'})
aAdd(aCBO,{'251120','Soci�logo'})
aAdd(aCBO,{'251205','Economista'})
aAdd(aCBO,{'251210','Economista agroindustrial'})
aAdd(aCBO,{'251215','Economista financeiro'})
aAdd(aCBO,{'251220','Economista industrial'})
aAdd(aCBO,{'251225','Economista do setor p�blico'})
aAdd(aCBO,{'251230','Economista ambiental'})
aAdd(aCBO,{'251235','Economista regional e urbano'})
aAdd(aCBO,{'251305','Ge�grafo'})
aAdd(aCBO,{'251405','Fil�sofo'})
aAdd(aCBO,{'251530','Psic�logo social'})
aAdd(aCBO,{'251510','Psic�logo cl�nico'})
aAdd(aCBO,{'251515','Psic�logo do esporte'})
aAdd(aCBO,{'251545','Neuropsic�logo'})
aAdd(aCBO,{'251540','Psic�logo do trabalho'})
aAdd(aCBO,{'251535','Psic�logo do tr�nsito'})
aAdd(aCBO,{'251505','Psic�logo educacional'})
aAdd(aCBO,{'251525','Psic�logo jur�dico'})
aAdd(aCBO,{'251550','Psicanalista'})
aAdd(aCBO,{'251555','Psic�logo acupunturista'})
aAdd(aCBO,{'251520','Psic�logo hospitalar'})
aAdd(aCBO,{'251610','Economista dom�stico'})
aAdd(aCBO,{'251605','Assistente social'})
aAdd(aCBO,{'252105','Administrador'})
aAdd(aCBO,{'252205','Auditor (contadores e afins)'})
aAdd(aCBO,{'252215','Perito cont�bil'})
aAdd(aCBO,{'252210','Contador'})
aAdd(aCBO,{'252310','Secret�rio bil�ng�e'})
aAdd(aCBO,{'252305','Secret�ria(o) executiva(o)'})
aAdd(aCBO,{'252315','Secret�ria tril�ng�e'})
aAdd(aCBO,{'252320','Tecn�logo em secretariado escolar'})
aAdd(aCBO,{'252405','Analista de recursos humanos'})
aAdd(aCBO,{'252535','Analista de leasing'})
aAdd(aCBO,{'252505','Administrador de fundos e carteiras de investimento'})
aAdd(aCBO,{'252525','Analista de cr�dito (institui��es financeiras)'})
aAdd(aCBO,{'252545','Analista financeiro (institui��es financeiras)'})
aAdd(aCBO,{'252510','Analista de c�mbio'})
aAdd(aCBO,{'252515','Analista de cobran�a (institui��es financeiras)'})
aAdd(aCBO,{'252540','Analista de produtos banc�rios'})
aAdd(aCBO,{'252530','Analista de cr�dito rural'})
aAdd(aCBO,{'252605','Gestor em seguran�a'})
aAdd(aCBO,{'253110','Redator de publicidade'})
aAdd(aCBO,{'253115','Publicit�rio'})
aAdd(aCBO,{'253130','Diretor de cria��o'})
aAdd(aCBO,{'253125','Diretor de arte (publicidade)'})
aAdd(aCBO,{'253120','Diretor de m�dia (publicidade)'})
aAdd(aCBO,{'253135','Diretor de contas (publicidade)'})
aAdd(aCBO,{'253140','Agenciador de propaganda'})
aAdd(aCBO,{'253205','Gerente de capta��o (fundos e investimentos institucionais)'})
aAdd(aCBO,{'253210','Gerente de clientes especiais (private)'})
aAdd(aCBO,{'253215','Gerente de contas - pessoa f�sica e jur�dica'})
aAdd(aCBO,{'253220','Gerente de grandes contas (corporate)'})
aAdd(aCBO,{'253225','Operador de neg�cios'})
aAdd(aCBO,{'253305','Corretor de valores, ativos financeiros, mercadorias e derivativos'})
aAdd(aCBO,{'254105','Auditor-fiscal da receita federal'})
aAdd(aCBO,{'254110','T�cnico da receita federal'})
aAdd(aCBO,{'254205','Auditor-fiscal da previd�ncia social'})
aAdd(aCBO,{'254305','Auditor-fiscal do trabalho'})
aAdd(aCBO,{'254310','Agente de higiene e seguran�a'})
aAdd(aCBO,{'254405','Fiscal de tributos estadual'})
aAdd(aCBO,{'254420','T�cnico de tributos municipal'})
aAdd(aCBO,{'254410','Fiscal de tributos municipal'})
aAdd(aCBO,{'254415','T�cnico de tributos estadual'})
aAdd(aCBO,{'261105','Arquivista pesquisador (jornalismo)'})
aAdd(aCBO,{'261110','Assessor de imprensa'})
aAdd(aCBO,{'261115','Diretor de reda��o'})
aAdd(aCBO,{'261120','Editor'})
aAdd(aCBO,{'261125','Jornalista'})
aAdd(aCBO,{'261130','Produtor de texto'})
aAdd(aCBO,{'261135','Rep�rter (exclusive r�dio e televis�o)'})
aAdd(aCBO,{'261140','Revisor de texto'})
aAdd(aCBO,{'261210','Documentalista'})
aAdd(aCBO,{'261215','Analista de informa��es (pesquisador de informa��es de rede)'})
aAdd(aCBO,{'261205','Bibliotec�rio'})
aAdd(aCBO,{'261305','Arquivista'})
aAdd(aCBO,{'261310','Muse�logo'})
aAdd(aCBO,{'261405','Fil�logo'})
aAdd(aCBO,{'261430','Audiodescritor'})
aAdd(aCBO,{'261425','Int�rprete de l�ngua de sinais'})
aAdd(aCBO,{'261420','Tradutor'})
aAdd(aCBO,{'261415','Ling�ista'})
aAdd(aCBO,{'261410','Int�rprete'})
aAdd(aCBO,{'261530','Redator de textos t�cnicos'})
aAdd(aCBO,{'261520','Escritor de n�o fic��o'})
aAdd(aCBO,{'261525','Poeta'})
aAdd(aCBO,{'261515','Escritor de fic��o'})
aAdd(aCBO,{'261510','Cr�tico'})
aAdd(aCBO,{'261505','Autor-roteirista'})
aAdd(aCBO,{'261605','Editor de jornal'})
aAdd(aCBO,{'261615','Editor de m�dia eletr�nica'})
aAdd(aCBO,{'261610','Editor de livro'})
aAdd(aCBO,{'261620','Editor de revista'})
aAdd(aCBO,{'261625','Editor de revista cient�fica'})
aAdd(aCBO,{'261705','�ncora de r�dio e televis�o'})
aAdd(aCBO,{'261715','Locutor de r�dio e televis�o'})
aAdd(aCBO,{'261710','Comentarista de r�dio e televis�o'})
aAdd(aCBO,{'261720','Locutor publicit�rio de r�dio e televis�o'})
aAdd(aCBO,{'261725','Narrador em programas de r�dio e televis�o'})
aAdd(aCBO,{'261730','Rep�rter de r�dio e televis�o'})
aAdd(aCBO,{'261805','Fot�grafo'})
aAdd(aCBO,{'261810','Fot�grafo publicit�rio'})
aAdd(aCBO,{'261815','Fot�grafo retratista'})
aAdd(aCBO,{'261820','Rep�rter fotogr�fico'})
aAdd(aCBO,{'262135','Tecn�logo em produ��o audiovisual'})
aAdd(aCBO,{'262130','Tecn�logo em produ��o fonogr�fica'})
aAdd(aCBO,{'262105','Produtor cultural'})
aAdd(aCBO,{'262120','Produtor de teatro'})
aAdd(aCBO,{'262125','Produtor de televis�o'})
aAdd(aCBO,{'262110','Produtor cinematogr�fico'})
aAdd(aCBO,{'262115','Produtor de r�dio'})
aAdd(aCBO,{'262220','Diretor teatral'})
aAdd(aCBO,{'262215','Diretor de programas de televis�o'})
aAdd(aCBO,{'262210','Diretor de programas de r�dio'})
aAdd(aCBO,{'262205','Diretor de cinema'})
aAdd(aCBO,{'262305','Cen�grafo carnavalesco e festas populares'})
aAdd(aCBO,{'262310','Cen�grafo de cinema'})
aAdd(aCBO,{'262315','Cen�grafo de eventos'})
aAdd(aCBO,{'262320','Cen�grafo de teatro'})
aAdd(aCBO,{'262325','Cen�grafo de tv'})
aAdd(aCBO,{'262330','Diretor de arte'})
aAdd(aCBO,{'262420','Desenhista industrial de produto (designer de produto)'})
aAdd(aCBO,{'262425','Desenhista industrial de produto de moda (designer de moda)'})
aAdd(aCBO,{'262405','Artista (artes visuais)'})
aAdd(aCBO,{'262415','Conservador-restaurador de bens culturais'})
aAdd(aCBO,{'262410','Desenhista industrial gr�fico (designer gr�fico)'})
aAdd(aCBO,{'262505','Ator'})
aAdd(aCBO,{'262605','Compositor'})
aAdd(aCBO,{'262610','M�sico arranjador'})
aAdd(aCBO,{'262615','M�sico regente'})
aAdd(aCBO,{'262620','Music�logo'})
aAdd(aCBO,{'262705','M�sico int�rprete cantor'})
aAdd(aCBO,{'262710','M�sico int�rprete instrumentista'})
aAdd(aCBO,{'262815','Core�grafo'})
aAdd(aCBO,{'262810','Bailarino (exceto dan�as populares)'})
aAdd(aCBO,{'262805','Assistente de coreografia'})
aAdd(aCBO,{'262820','Dramaturgo de dan�a'})
aAdd(aCBO,{'262830','Professor de dan�a'})
aAdd(aCBO,{'262825','Ensaiador de dan�a'})
aAdd(aCBO,{'262905','Decorador de interiores de n�vel superior'})
aAdd(aCBO,{'263110','Mission�rio'})
aAdd(aCBO,{'263105','Ministro de culto religioso'})
aAdd(aCBO,{'263115','Te�logo'})
aAdd(aCBO,{'271110','Tecn�logo em gastronomia'})
aAdd(aCBO,{'271105','Chefe de cozinha'})
aAdd(aCBO,{'300105','T�cnico em mecatr�nica - automa��o da manufatura'})
aAdd(aCBO,{'300110','T�cnico em mecatr�nica - rob�tica'})
aAdd(aCBO,{'300305','T�cnico em eletromec�nica'})
aAdd(aCBO,{'301105','T�cnico de laborat�rio industrial'})
aAdd(aCBO,{'301110','T�cnico de laborat�rio de an�lises f�sico-qu�micas (materiais de constru��o)'})
aAdd(aCBO,{'301115','T�cnico qu�mico de petr�leo'})
aAdd(aCBO,{'301205','T�cnico de apoio � bioengenharia'})
aAdd(aCBO,{'311110','T�cnico de celulose e papel'})
aAdd(aCBO,{'311115','T�cnico em curtimento'})
aAdd(aCBO,{'311105','T�cnico qu�mico'})
aAdd(aCBO,{'311205','T�cnico em petroqu�mica'})
aAdd(aCBO,{'311305','T�cnico em materiais, produtos cer�micos e vidros'})
aAdd(aCBO,{'311405','T�cnico em borracha'})
aAdd(aCBO,{'311410','T�cnico em pl�stico'})
aAdd(aCBO,{'311505','T�cnico de controle de meio ambiente'})
aAdd(aCBO,{'311510','T�cnico de meteorologia'})
aAdd(aCBO,{'311515','T�cnico de utilidade (produ��o e distribui��o de vapor, gases, �leos, combust�veis, energia)'})
aAdd(aCBO,{'311520','T�cnico em tratamento de efluentes'})
aAdd(aCBO,{'311605','T�cnico t�xtil'})
aAdd(aCBO,{'311625','T�cnico t�xtil de tecelagem'})
aAdd(aCBO,{'311620','T�cnico t�xtil de malharia'})
aAdd(aCBO,{'311615','T�cnico t�xtil de fia��o'})
aAdd(aCBO,{'311610','T�cnico t�xtil (tratamentos qu�micos)'})
aAdd(aCBO,{'311720','Preparador de tintas (f�brica de tecidos)'})
aAdd(aCBO,{'311715','Preparador de tintas'})
aAdd(aCBO,{'311710','Colorista t�xtil'})
aAdd(aCBO,{'311705','Colorista de papel'})
aAdd(aCBO,{'311725','Tingidor de couros e peles'})
aAdd(aCBO,{'312105','T�cnico de obras civis'})
aAdd(aCBO,{'312210','T�cnico de saneamento'})
aAdd(aCBO,{'312205','T�cnico de estradas'})
aAdd(aCBO,{'312315','T�cnico em hidrografia'})
aAdd(aCBO,{'312310','T�cnico em geod�sia e cartografia'})
aAdd(aCBO,{'312320','Top�grafo'})
aAdd(aCBO,{'312305','T�cnico em agrimensura'})
aAdd(aCBO,{'313130','T�cnico eletricista'})
aAdd(aCBO,{'313105','Eletrot�cnico'})
aAdd(aCBO,{'313110','Eletrot�cnico (produ��o de energia)'})
aAdd(aCBO,{'313125','T�cnico de manuten��o el�trica de m�quina'})
aAdd(aCBO,{'313120','T�cnico de manuten��o el�trica'})
aAdd(aCBO,{'313115','Eletrot�cnico na fabrica��o, montagem e instala��o de m�quinas e equipamentos'})
aAdd(aCBO,{'313220','T�cnico em manuten��o de equipamentos de inform�tica'})
aAdd(aCBO,{'313215','T�cnico eletr�nico'})
aAdd(aCBO,{'313205','T�cnico de manuten��o eletr�nica'})
aAdd(aCBO,{'313210','T�cnico de manuten��o eletr�nica (circuitos de m�quinas com comando num�rico)'})
aAdd(aCBO,{'313320','T�cnico de transmiss�o (telecomunica��es)'})
aAdd(aCBO,{'313315','T�cnico de telecomunica��es (telefonia)'})
aAdd(aCBO,{'313310','T�cnico de rede (telecomunica��es)'})
aAdd(aCBO,{'313305','T�cnico de comunica��o de dados'})
aAdd(aCBO,{'313415','Encarregado de manuten��o de instrumentos de controle, medi��o e similares'})
aAdd(aCBO,{'313405','T�cnico em calibra��o'})
aAdd(aCBO,{'313410','T�cnico em instrumenta��o'})
aAdd(aCBO,{'313505','T�cnico em fot�nica'})
aAdd(aCBO,{'314105','T�cnico em mec�nica de precis�o'})
aAdd(aCBO,{'314110','T�cnico mec�nico'})
aAdd(aCBO,{'314115','T�cnico mec�nico (calefa��o, ventila��o e refrigera��o)'})
aAdd(aCBO,{'314120','T�cnico mec�nico (m�quinas)'})
aAdd(aCBO,{'314125','T�cnico mec�nico (motores)'})
aAdd(aCBO,{'314205','T�cnico mec�nico na fabrica��o de ferramentas'})
aAdd(aCBO,{'314210','T�cnico mec�nico na manuten��o de ferramentas'})
aAdd(aCBO,{'314305','T�cnico em automobil�stica'})
aAdd(aCBO,{'314310','T�cnico mec�nico (aeronaves)'})
aAdd(aCBO,{'314315','T�cnico mec�nico (embarca��es)'})
aAdd(aCBO,{'314405','T�cnico de manuten��o de sistemas e instrumentos'})
aAdd(aCBO,{'314410','T�cnico em manuten��o de m�quinas'})
aAdd(aCBO,{'314605','Inspetor de soldagem'})
aAdd(aCBO,{'314620','T�cnico em soldagem'})
aAdd(aCBO,{'314615','T�cnico em estruturas met�licas'})
aAdd(aCBO,{'314610','T�cnico em caldeiraria'})
aAdd(aCBO,{'314725','T�cnico de redu��o na siderurgia (primeira fus�o)'})
aAdd(aCBO,{'314720','T�cnico de lamina��o em siderurgia'})
aAdd(aCBO,{'314715','T�cnico de fundi��o em siderurgia'})
aAdd(aCBO,{'314710','T�cnico de aciaria em siderurgia'})
aAdd(aCBO,{'314730','T�cnico de refrat�rio em siderurgia'})
aAdd(aCBO,{'314705','T�cnico de acabamento em siderurgia'})
aAdd(aCBO,{'316115','T�cnico em geoqu�mica'})
aAdd(aCBO,{'316110','T�cnico em geologia'})
aAdd(aCBO,{'316105','T�cnico em geof�sica'})
aAdd(aCBO,{'316120','T�cnico em geotecnia'})
aAdd(aCBO,{'316325','T�cnico de produ��o em refino de petr�leo'})
aAdd(aCBO,{'316330','T�cnico em planejamento de lavra de minas'})
aAdd(aCBO,{'316335','Desincrustador (po�os de petr�leo)'})
aAdd(aCBO,{'316320','T�cnico em pesquisa mineral'})
aAdd(aCBO,{'316315','T�cnico em processamento mineral (exceto petr�leo)'})
aAdd(aCBO,{'316340','Cimentador (po�os de petr�leo)'})
aAdd(aCBO,{'316305','T�cnico de minera��o'})
aAdd(aCBO,{'316310','T�cnico de minera��o (�leo e petr�leo)'})
aAdd(aCBO,{'317105','Programador de internet'})
aAdd(aCBO,{'317110','Programador de sistemas de informa��o'})
aAdd(aCBO,{'317115','Programador de m�quinas - ferramenta com comando num�rico'})
aAdd(aCBO,{'317120','Programador de multim�dia'})
aAdd(aCBO,{'317205','Operador de computador (inclusive microcomputador)'})
aAdd(aCBO,{'317210','T�cnico de apoio ao usu�rio de inform�tica (helpdesk)'})
aAdd(aCBO,{'318010','Desenhista copista'})
aAdd(aCBO,{'318005','Desenhista t�cnico'})
aAdd(aCBO,{'318015','Desenhista detalhista'})
aAdd(aCBO,{'318110','Desenhista t�cnico (cartografia)'})
aAdd(aCBO,{'318105','Desenhista t�cnico (arquitetura)'})
aAdd(aCBO,{'318115','Desenhista t�cnico (constru��o civil)'})
aAdd(aCBO,{'318120','Desenhista t�cnico (instala��es hidrossanit�rias)'})
aAdd(aCBO,{'318205','Desenhista t�cnico mec�nico'})
aAdd(aCBO,{'318210','Desenhista t�cnico aeron�utico'})
aAdd(aCBO,{'318215','Desenhista t�cnico naval'})
aAdd(aCBO,{'318305','Desenhista t�cnico (eletricidade e eletr�nica)'})
aAdd(aCBO,{'318310','Desenhista t�cnico (calefa��o, ventila��o e refrigera��o)'})
aAdd(aCBO,{'318405','Desenhista t�cnico (artes gr�ficas)'})
aAdd(aCBO,{'318410','Desenhista t�cnico (ilustra��es art�sticas)'})
aAdd(aCBO,{'318430','Desenhista t�cnico de embalagens, maquetes e leiautes'})
aAdd(aCBO,{'318425','Desenhista t�cnico (mobili�rio)'})
aAdd(aCBO,{'318420','Desenhista t�cnico (ind�stria t�xtil)'})
aAdd(aCBO,{'318415','Desenhista t�cnico (ilustra��es t�cnicas)'})
aAdd(aCBO,{'318505','Desenhista projetista de arquitetura'})
aAdd(aCBO,{'318510','Desenhista projetista de constru��o civil'})
aAdd(aCBO,{'318605','Desenhista projetista de m�quinas'})
aAdd(aCBO,{'318610','Desenhista projetista mec�nico'})
aAdd(aCBO,{'318705','Desenhista projetista de eletricidade'})
aAdd(aCBO,{'318710','Desenhista projetista eletr�nico'})
aAdd(aCBO,{'318805','Projetista de m�veis'})
aAdd(aCBO,{'318815','Modelista de cal�ados'})
aAdd(aCBO,{'318810','Modelista de roupas'})
aAdd(aCBO,{'319105','T�cnico em cal�ados e artefatos de couro'})
aAdd(aCBO,{'319110','T�cnico em confec��es do vestu�rio'})
aAdd(aCBO,{'319205','T�cnico do mobili�rio'})
aAdd(aCBO,{'320110','T�cnico em histologia'})
aAdd(aCBO,{'320105','T�cnico em bioterismo'})
aAdd(aCBO,{'321105','T�cnico agr�cola'})
aAdd(aCBO,{'321110','T�cnico agropecu�rio'})
aAdd(aCBO,{'321210','T�cnico florestal'})
aAdd(aCBO,{'321205','T�cnico em madeira'})
aAdd(aCBO,{'321305','T�cnico em piscicultura'})
aAdd(aCBO,{'321310','T�cnico em carcinicultura'})
aAdd(aCBO,{'321315','T�cnico em mitilicultura'})
aAdd(aCBO,{'321320','T�cnico em ranicultura'})
aAdd(aCBO,{'322135','Doula'})
aAdd(aCBO,{'322130','Esteticista'})
aAdd(aCBO,{'322125','Terapeuta hol�stico'})
aAdd(aCBO,{'322115','T�cnico em quiropraxia'})
aAdd(aCBO,{'322120','Massoterapeuta'})
aAdd(aCBO,{'322110','Pod�logo'})
aAdd(aCBO,{'322105','T�cnico em acupuntura'})
aAdd(aCBO,{'322210','T�cnico de enfermagem de terapia intensiva'})
aAdd(aCBO,{'322225','Instrumentador cir�rgico'})
aAdd(aCBO,{'322220','T�cnico de enfermagem psiqui�trica'})
aAdd(aCBO,{'322250','Auxiliar de enfermagem da estrat�gia de sa�de da fam�lia'})
aAdd(aCBO,{'322215','T�cnico de enfermagem do trabalho'})
aAdd(aCBO,{'322230','Auxiliar de enfermagem'})
aAdd(aCBO,{'322235','Auxiliar de enfermagem do trabalho'})
aAdd(aCBO,{'322240','Auxiliar de sa�de (navega��o mar�tima)'})
aAdd(aCBO,{'322245','T�cnico de enfermagem da estrat�gia de sa�de da fam�lia'})
aAdd(aCBO,{'322205','T�cnico de enfermagem'})
aAdd(aCBO,{'322305','T�cnico em �ptica e optometria'})
aAdd(aCBO,{'322430','Auxiliar em sa�de bucal da estrat�gia de sa�de da fam�lia'})
aAdd(aCBO,{'322425','T�cnico em sa�de bucal da estrat�gia de sa�de da fam�lia'})
aAdd(aCBO,{'322420','Auxiliar de pr�tese dent�ria'})
aAdd(aCBO,{'322405','T�cnico em sa�de bucal'})
aAdd(aCBO,{'322410','Prot�tico dent�rio'})
aAdd(aCBO,{'322415','Auxiliar em sa�de bucal'})
aAdd(aCBO,{'322505','T�cnico de ortopedia'})
aAdd(aCBO,{'322605','T�cnico de imobiliza��o ortop�dica'})
aAdd(aCBO,{'323105','T�cnico em pecu�ria'})
aAdd(aCBO,{'324125','Tecn�logo oft�lmico'})
aAdd(aCBO,{'324120','Tecn�logo em radiologia'})
aAdd(aCBO,{'324110','T�cnico em m�todos gr�ficos em cardiologia'})
aAdd(aCBO,{'324115','T�cnico em radiologia e imagenologia'})
aAdd(aCBO,{'324105','T�cnico em m�todos eletrogr�ficos em encefalografia'})
aAdd(aCBO,{'324205','T�cnico em patologia cl�nica'})
aAdd(aCBO,{'324215','Citot�cnico'})
aAdd(aCBO,{'324220','T�cnico em hemoterapia'})
aAdd(aCBO,{'325005','En�logo'})
aAdd(aCBO,{'325010','Aromista'})
aAdd(aCBO,{'325015','Perfumista'})
aAdd(aCBO,{'325105','Auxiliar t�cnico em laborat�rio de farm�cia'})
aAdd(aCBO,{'325115','T�cnico em farm�cia'})
aAdd(aCBO,{'325110','T�cnico em laborat�rio de farm�cia'})
aAdd(aCBO,{'325210','T�cnico em nutri��o e diet�tica'})
aAdd(aCBO,{'325205','T�cnico de alimentos'})
aAdd(aCBO,{'325310','T�cnico em imunobiol�gicos'})
aAdd(aCBO,{'325305','T�cnico em biotecnologia'})
aAdd(aCBO,{'328110','Taxidermista'})
aAdd(aCBO,{'328105','Embalsamador'})
aAdd(aCBO,{'331105','Professor de n�vel m�dio na educa��o infantil'})
aAdd(aCBO,{'331110','Auxiliar de desenvolvimento infantil'})
aAdd(aCBO,{'331205','Professor de n�vel m�dio no ensino fundamental'})
aAdd(aCBO,{'331305','Professor de n�vel m�dio no ensino profissionalizante'})
aAdd(aCBO,{'332105','Professor leigo no ensino fundamental'})
aAdd(aCBO,{'332205','Professor pr�tico no ensino profissionalizante'})
aAdd(aCBO,{'333115','Professores de cursos livres'})
aAdd(aCBO,{'333105','Instrutor de auto-escola'})
aAdd(aCBO,{'333110','Instrutor de cursos livres'})
aAdd(aCBO,{'334110','Inspetor de alunos de escola p�blica'})
aAdd(aCBO,{'334105','Inspetor de alunos de escola privada'})
aAdd(aCBO,{'334115','Monitor de transporte escolar'})
aAdd(aCBO,{'341120','Piloto agr�cola'})
aAdd(aCBO,{'341115','Mec�nico de v�o'})
aAdd(aCBO,{'341110','Piloto comercial de helic�ptero (exceto linhas a�reas)'})
aAdd(aCBO,{'341105','Piloto comercial (exceto linhas a�reas)'})
aAdd(aCBO,{'341225','Patr�o de pesca na navega��o interior'})
aAdd(aCBO,{'341230','Piloto fluvial'})
aAdd(aCBO,{'341220','Patr�o de pesca de alto-mar'})
aAdd(aCBO,{'341205','Contramestre de cabotagem'})
aAdd(aCBO,{'341210','Mestre de cabotagem'})
aAdd(aCBO,{'341215','Mestre fluvial'})
aAdd(aCBO,{'341305','Maquinista motorista fluvial'})
aAdd(aCBO,{'341310','Condutor de m�quinas'})
aAdd(aCBO,{'341315','Eletricista de bordo'})
aAdd(aCBO,{'342125','Tecn�logo em log�stica de transporte'})
aAdd(aCBO,{'342120','Afretador'})
aAdd(aCBO,{'342115','Controlador de servi�os de m�quinas e ve�culos'})
aAdd(aCBO,{'342105','Analista de transporte em com�rcio exterior'})
aAdd(aCBO,{'342110','Operador de transporte multimodal'})
aAdd(aCBO,{'342210','Despachante aduaneiro'})
aAdd(aCBO,{'342205','Ajudante de despachante aduaneiro'})
aAdd(aCBO,{'342315','Supervisor de carga e descarga'})
aAdd(aCBO,{'342310','Inspetor de servi�os de transportes rodovi�rios (passageiros e cargas)'})
aAdd(aCBO,{'342305','Chefe de servi�o de transporte rodovi�rio (passageiros e cargas)'})
aAdd(aCBO,{'342405','Agente de esta��o (ferrovia e metr�)'})
aAdd(aCBO,{'342410','Operador de centro de controle (ferrovia e metr�)'})
aAdd(aCBO,{'342550','Agente de prote��o de avia��o civil'})
aAdd(aCBO,{'342545','Supervisor de empresa a�rea em aeroportos'})
aAdd(aCBO,{'342505','Controlador de tr�fego a�reo'})
aAdd(aCBO,{'342510','Despachante operacional de v�o'})
aAdd(aCBO,{'342515','Fiscal de avia��o civil (fac)'})
aAdd(aCBO,{'342520','Gerente da administra��o de aeroportos'})
aAdd(aCBO,{'342525','Gerente de empresa a�rea em aeroportos'})
aAdd(aCBO,{'342530','Inspetor de avia��o civil'})
aAdd(aCBO,{'342540','Supervisor da administra��o de aeroportos'})
aAdd(aCBO,{'342535','Operador de atendimento aerovi�rio'})
aAdd(aCBO,{'342605','Chefe de esta��o portu�ria'})
aAdd(aCBO,{'342610','Supervisor de opera��es portu�rias'})
aAdd(aCBO,{'351115','Consultor cont�bil (t�cnico)'})
aAdd(aCBO,{'351105','T�cnico de contabilidade'})
aAdd(aCBO,{'351110','Chefe de contabilidade (t�cnico)'})
aAdd(aCBO,{'351310','T�cnico em administra��o de com�rcio exterior'})
aAdd(aCBO,{'351315','Agente de recrutamento e sele��o'})
aAdd(aCBO,{'351305','T�cnico em administra��o'})
aAdd(aCBO,{'351420','Escriv�o de pol�cia'})
aAdd(aCBO,{'351410','Escriv�o judicial'})
aAdd(aCBO,{'351405','Escrevente'})
aAdd(aCBO,{'351415','Escriv�o extra - judicial'})
aAdd(aCBO,{'351430','Auxiliar de servi�os jur�dicos'})
aAdd(aCBO,{'351425','Oficial de justi�a'})
aAdd(aCBO,{'351515','Estenotipista'})
aAdd(aCBO,{'351510','Taqu�grafo'})
aAdd(aCBO,{'351505','T�cnico em secretariado'})
aAdd(aCBO,{'351605','T�cnico em seguran�a do trabalho'})
aAdd(aCBO,{'351705','Analista de seguros (t�cnico)'})
aAdd(aCBO,{'351715','Assistente comercial de seguros'})
aAdd(aCBO,{'351720','Assistente t�cnico de seguros'})
aAdd(aCBO,{'351725','Inspetor de risco'})
aAdd(aCBO,{'351730','Inspetor de sinistros'})
aAdd(aCBO,{'351735','T�cnico de resseguros'})
aAdd(aCBO,{'351710','Analista de sinistros'})
aAdd(aCBO,{'351740','T�cnico de seguros'})
aAdd(aCBO,{'351815','Papiloscopista policial'})
aAdd(aCBO,{'351810','Investigador de pol�cia'})
aAdd(aCBO,{'351805','Detetive profissional'})
aAdd(aCBO,{'351910','Agente t�cnico de intelig�ncia'})
aAdd(aCBO,{'351905','Agente de intelig�ncia'})
aAdd(aCBO,{'352210','Agente de sa�de p�blica'})
aAdd(aCBO,{'352205','Agente de defesa ambiental'})
aAdd(aCBO,{'352310','Agente fiscal de qualidade'})
aAdd(aCBO,{'352315','Agente fiscal metrol�gico'})
aAdd(aCBO,{'352320','Agente fiscal t�xtil'})
aAdd(aCBO,{'352305','Metrologista'})
aAdd(aCBO,{'352420','T�cnico em direitos autorais'})
aAdd(aCBO,{'352405','Agente de direitos autorais'})
aAdd(aCBO,{'352410','Avaliador de produtos do meio de comunica��o'})
aAdd(aCBO,{'353230','Tesoureiro de banco'})
aAdd(aCBO,{'353225','T�cnico de opera��es e servi�os banc�rios - renda fixa e vari�vel'})
aAdd(aCBO,{'353220','T�cnico de opera��es e servi�os banc�rios - leasing'})
aAdd(aCBO,{'353215','T�cnico de opera��es e servi�os banc�rios - cr�dito rural'})
aAdd(aCBO,{'353210','T�cnico de opera��es e servi�os banc�rios - cr�dito imobili�rio'})
aAdd(aCBO,{'353205','T�cnico de opera��es e servi�os banc�rios - c�mbio'})
aAdd(aCBO,{'353235','Chefe de servi�os banc�rios'})
aAdd(aCBO,{'354120','Agente de vendas de servi�os'})
aAdd(aCBO,{'354125','Assistente de vendas'})
aAdd(aCBO,{'354130','Promotor de vendas especializado'})
aAdd(aCBO,{'354135','T�cnico de vendas'})
aAdd(aCBO,{'354150','Propagandista de produtos famac�uticos'})
aAdd(aCBO,{'354145','Vendedor pracista'})
aAdd(aCBO,{'354140','T�cnico em atendimento e vendas'})
aAdd(aCBO,{'354205','Comprador'})
aAdd(aCBO,{'354210','Supervisor de compras'})
aAdd(aCBO,{'354305','Analista de exporta��o e importa��o'})
aAdd(aCBO,{'354405','Leiloeiro'})
aAdd(aCBO,{'354410','Avaliador de im�veis'})
aAdd(aCBO,{'354415','Avaliador de bens m�veis'})
aAdd(aCBO,{'354505','Corretor de seguros'})
aAdd(aCBO,{'354605','Corretor de im�veis'})
aAdd(aCBO,{'354705','Representante comercial aut�nomo'})
aAdd(aCBO,{'354820','Organizador de evento'})
aAdd(aCBO,{'354815','Agente de viagem'})
aAdd(aCBO,{'354805','T�cnico em turismo'})
aAdd(aCBO,{'354810','Operador de turismo'})
aAdd(aCBO,{'371105','Auxiliar de biblioteca'})
aAdd(aCBO,{'371110','T�cnico em biblioteconomia'})
aAdd(aCBO,{'371205','Colecionador de selos e moedas'})
aAdd(aCBO,{'371210','T�cnico em museologia'})
aAdd(aCBO,{'371305','T�cnico em programa��o visual'})
aAdd(aCBO,{'371310','T�cnico gr�fico'})
aAdd(aCBO,{'371405','Recreador de acantonamento'})
aAdd(aCBO,{'371410','Recreador'})
aAdd(aCBO,{'372105','Diretor de fotografia'})
aAdd(aCBO,{'372115','Operador de c�mera de televis�o'})
aAdd(aCBO,{'372110','Iluminador (televis�o)'})
aAdd(aCBO,{'372205','Operador de rede de teleprocessamento'})
aAdd(aCBO,{'372210','Radiotelegrafista'})
aAdd(aCBO,{'373105','Operador de �udio de continuidade (r�dio)'})
aAdd(aCBO,{'373110','Operador de central de r�dio'})
aAdd(aCBO,{'373120','Operador de grava��o de r�dio'})
aAdd(aCBO,{'373115','Operador de externa (r�dio)'})
aAdd(aCBO,{'373125','Operador de transmissor de r�dio'})
aAdd(aCBO,{'373215','T�cnico em opera��o de equipamentos de transmiss�o/recep��o de televis�o'})
aAdd(aCBO,{'373220','Supervisor t�cnico operacional de sistemas de televis�o e produtoras de v�deo'})
aAdd(aCBO,{'373205','T�cnico em opera��o de equipamentos de produ��o para televis�o e produtoras de v�deo'})
aAdd(aCBO,{'373210','T�cnico em opera��o de equipamento de exibi��o de televis�o'})
aAdd(aCBO,{'374145','Dj (disc jockey)'})
aAdd(aCBO,{'374105','T�cnico em grava��o de �udio'})
aAdd(aCBO,{'374140','Microfonista'})
aAdd(aCBO,{'374135','Projetista de sistemas de �udio'})
aAdd(aCBO,{'374110','T�cnico em instala��o de equipamentos de �udio'})
aAdd(aCBO,{'374125','T�cnico em sonoriza��o'})
aAdd(aCBO,{'374120','Projetista de som'})
aAdd(aCBO,{'374115','T�cnico em masteriza��o de �udio'})
aAdd(aCBO,{'374130','T�cnico em mixagem de �udio'})
aAdd(aCBO,{'374215','Maquinista de teatro e espet�culos'})
aAdd(aCBO,{'374205','Cenot�cnico (cinema, v�deo, televis�o, teatro e espet�culos)'})
aAdd(aCBO,{'374210','Maquinista de cinema e v�deo'})
aAdd(aCBO,{'374310','Operador-mantenedor de projetor cinematogr�fico'})
aAdd(aCBO,{'374305','Operador de projetor cinematogr�fico'})
aAdd(aCBO,{'374405','Editor de tv e v�deo'})
aAdd(aCBO,{'374410','Finalizador de filmes'})
aAdd(aCBO,{'374415','Finalizador de v�deo'})
aAdd(aCBO,{'374420','Montador de filmes'})
aAdd(aCBO,{'375120','Decorador de eventos'})
aAdd(aCBO,{'375115','Visual merchandiser'})
aAdd(aCBO,{'375110','Designer de vitrines'})
aAdd(aCBO,{'375105','Designer de interiores'})
aAdd(aCBO,{'376105','Dan�arino tradicional'})
aAdd(aCBO,{'376110','Dan�arino popular'})
aAdd(aCBO,{'376215','Artista de circo (outros)'})
aAdd(aCBO,{'376210','Artista a�reo'})
aAdd(aCBO,{'376205','Acrobata'})
aAdd(aCBO,{'376225','Domador de animais (circense)'})
aAdd(aCBO,{'376230','Equilibrista'})
aAdd(aCBO,{'376235','M�gico'})
aAdd(aCBO,{'376240','Malabarista'})
aAdd(aCBO,{'376245','Palha�o'})
aAdd(aCBO,{'376220','Contorcionista'})
aAdd(aCBO,{'376255','Trapezista'})
aAdd(aCBO,{'376250','Titeriteiro'})
aAdd(aCBO,{'376305','Apresentador de eventos'})
aAdd(aCBO,{'376310','Apresentador de festas populares'})
aAdd(aCBO,{'376315','Apresentador de programas de r�dio'})
aAdd(aCBO,{'376320','Apresentador de programas de televis�o'})
aAdd(aCBO,{'376325','Apresentador de circo'})
aAdd(aCBO,{'376410','Modelo de modas'})
aAdd(aCBO,{'376415','Modelo publicit�rio'})
aAdd(aCBO,{'376405','Modelo art�stico'})
aAdd(aCBO,{'377140','Profissional de atletismo'})
aAdd(aCBO,{'377145','Pugilista'})
aAdd(aCBO,{'377135','Piloto de competi��o automobil�stica'})
aAdd(aCBO,{'377130','J�quei'})
aAdd(aCBO,{'377125','Atleta profissional de t�nis'})
aAdd(aCBO,{'377120','Atleta profissional de luta'})
aAdd(aCBO,{'377115','Atleta profissional de golfe'})
aAdd(aCBO,{'377110','Atleta profissional de futebol'})
aAdd(aCBO,{'377105','Atleta profissional (outras modalidades)'})
aAdd(aCBO,{'377205','�rbitro desportivo'})
aAdd(aCBO,{'377210','�rbitro de atletismo'})
aAdd(aCBO,{'377215','�rbitro de basquete'})
aAdd(aCBO,{'377220','�rbitro de futebol'})
aAdd(aCBO,{'377245','�rbitro de v�lei'})
aAdd(aCBO,{'377230','�rbitro de jud�'})
aAdd(aCBO,{'377235','�rbitro de karat�'})
aAdd(aCBO,{'377240','�rbitro de pol� aqu�tico'})
aAdd(aCBO,{'377225','�rbitro de futebol de sal�o'})
aAdd(aCBO,{'391105','Cronoanalista'})
aAdd(aCBO,{'391110','Cronometrista'})
aAdd(aCBO,{'391115','Controlador de entrada e sa�da'})
aAdd(aCBO,{'391120','Planejista'})
aAdd(aCBO,{'391125','T�cnico de planejamento de produ��o'})
aAdd(aCBO,{'391130','T�cnico de planejamento e programa��o da manuten��o'})
aAdd(aCBO,{'391135','T�cnico de mat�ria-prima e material'})
aAdd(aCBO,{'391205','Inspetor de qualidade'})
aAdd(aCBO,{'391230','T�cnico operacional de servi�os de correios'})
aAdd(aCBO,{'391210','T�cnico de garantia da qualidade'})
aAdd(aCBO,{'391215','Operador de inspe��o de qualidade'})
aAdd(aCBO,{'391220','T�cnico de painel de controle'})
aAdd(aCBO,{'391225','Escolhedor de papel'})
aAdd(aCBO,{'395105','T�cnico de apoio em pesquisa e desenvolvimento (exceto agropecu�rio e florestal)'})
aAdd(aCBO,{'395110','T�cnico de apoio em pesquisa e desenvolvimento agropecu�rio florestal'})
aAdd(aCBO,{'410105','Supervisor administrativo'})
aAdd(aCBO,{'410230','Supervisor de or�amento'})
aAdd(aCBO,{'410225','Supervisor de cr�dito e cobran�a'})
aAdd(aCBO,{'410220','Supervisor de controle patrimonial'})
aAdd(aCBO,{'410215','Supervisor de contas a pagar'})
aAdd(aCBO,{'410210','Supervisor de c�mbio'})
aAdd(aCBO,{'410205','Supervisor de almoxarifado'})
aAdd(aCBO,{'410235','Supervisor de tesouraria'})
aAdd(aCBO,{'411050','Agente de microcr�dito'})
aAdd(aCBO,{'411045','Auxiliar de servi�os de importa��o e exporta��o'})
aAdd(aCBO,{'411040','Auxiliar de seguros'})
aAdd(aCBO,{'411035','Auxiliar de estat�stica'})
aAdd(aCBO,{'411030','Auxiliar de pessoal'})
aAdd(aCBO,{'411025','Auxiliar de cart�rio'})
aAdd(aCBO,{'411005','Auxiliar de escrit�rio, em geral'})
aAdd(aCBO,{'411010','Assistente administrativo'})
aAdd(aCBO,{'411020','Auxiliar de judici�rio'})
aAdd(aCBO,{'411015','Atendente de judici�rio'})
aAdd(aCBO,{'412105','Datil�grafo'})
aAdd(aCBO,{'412110','Digitador'})
aAdd(aCBO,{'412115','Operador de mensagens de telecomunica��es (correios)'})
aAdd(aCBO,{'412120','Supervisor de digita��o e opera��o'})
aAdd(aCBO,{'412205','Cont�nuo'})
aAdd(aCBO,{'413105','Analista de folha de pagamento'})
aAdd(aCBO,{'413110','Auxiliar de contabilidade'})
aAdd(aCBO,{'413115','Auxiliar de faturamento'})
aAdd(aCBO,{'413220','Conferente de servi�os banc�rios'})
aAdd(aCBO,{'413215','Compensador de banco'})
aAdd(aCBO,{'413210','Caixa de banco'})
aAdd(aCBO,{'413205','Atendente de ag�ncia'})
aAdd(aCBO,{'413225','Escritur�rio de banco'})
aAdd(aCBO,{'413230','Operador de cobran�a banc�ria'})
aAdd(aCBO,{'414105','Almoxarife'})
aAdd(aCBO,{'414110','Armazenista'})
aAdd(aCBO,{'414115','Balanceiro'})
aAdd(aCBO,{'414205','Apontador de m�o-de-obra'})
aAdd(aCBO,{'414210','Apontador de produ��o'})
aAdd(aCBO,{'414215','Conferente de carga e descarga'})
aAdd(aCBO,{'415105','Arquivista de documentos'})
aAdd(aCBO,{'415130','Operador de m�quina copiadora (exceto operador de gr�fica r�pida)'})
aAdd(aCBO,{'415115','Codificador de dados'})
aAdd(aCBO,{'415120','Fitotec�rio'})
aAdd(aCBO,{'415125','Kardexista'})
aAdd(aCBO,{'415205','Carteiro'})
aAdd(aCBO,{'415210','Operador de triagem e transbordo'})
aAdd(aCBO,{'420105','Supervisor de caixas e bilheteiros (exceto caixa de banco)'})
aAdd(aCBO,{'420110','Supervisor de cobran�a'})
aAdd(aCBO,{'420135','Supervisor de telemarketing e atendimento'})
aAdd(aCBO,{'420130','Supervisor de telefonistas'})
aAdd(aCBO,{'420125','Supervisor de recepcionistas'})
aAdd(aCBO,{'420120','Supervisor de entrevistadores e recenseadores'})
aAdd(aCBO,{'420115','Supervisor de coletadores de apostas e de jogos'})
aAdd(aCBO,{'421125','Operador de caixa'})
aAdd(aCBO,{'421115','Bilheteiro no servi�o de divers�es'})
aAdd(aCBO,{'421120','Emissor de passagens'})
aAdd(aCBO,{'421105','Atendente comercial (ag�ncia postal)'})
aAdd(aCBO,{'421110','Bilheteiro de transportes coletivos'})
aAdd(aCBO,{'421205','Recebedor de apostas (loteria)'})
aAdd(aCBO,{'421210','Recebedor de apostas (turfe)'})
aAdd(aCBO,{'421305','Cobrador externo'})
aAdd(aCBO,{'421315','Localizador (cobrador)'})
aAdd(aCBO,{'421310','Cobrador interno'})
aAdd(aCBO,{'422120','Recepcionista de hotel'})
aAdd(aCBO,{'422125','Recepcionista de banco'})
aAdd(aCBO,{'422105','Recepcionista, em geral'})
aAdd(aCBO,{'422110','Recepcionista de consult�rio m�dico ou dent�rio'})
aAdd(aCBO,{'422115','Recepcionista de seguro sa�de'})
aAdd(aCBO,{'422205','Telefonista'})
aAdd(aCBO,{'422210','Teleoperador'})
aAdd(aCBO,{'422215','Monitor de teleatendimento'})
aAdd(aCBO,{'422220','Operador de r�dio-chamada'})
aAdd(aCBO,{'422310','Operador de telemarketing ativo e receptivo'})
aAdd(aCBO,{'422320','Operador de telemarketing t�cnico'})
aAdd(aCBO,{'422315','Operador de telemarketing receptivo'})
aAdd(aCBO,{'422305','Operador de telemarketing ativo'})
aAdd(aCBO,{'423110','Despachante de tr�nsito'})
aAdd(aCBO,{'423105','Despachante documentalista'})
aAdd(aCBO,{'424115','Entrevistador de pesquisas de mercado'})
aAdd(aCBO,{'424120','Entrevistador de pre�os'})
aAdd(aCBO,{'424105','Entrevistador censit�rio e de pesquisas amostrais'})
aAdd(aCBO,{'424125','Escritur�rio em estat�stica'})
aAdd(aCBO,{'424110','Entrevistador de pesquisa de opini�o e m�dia'})
aAdd(aCBO,{'510105','Supervisor de transportes'})
aAdd(aCBO,{'510135','Ma�tre'})
aAdd(aCBO,{'510130','Chefe de bar'})
aAdd(aCBO,{'510120','Chefe de portaria de hotel'})
aAdd(aCBO,{'510115','Supervisor de andar'})
aAdd(aCBO,{'510110','Administrador de edif�cios'})
aAdd(aCBO,{'510205','Supervisor de lavanderia'})
aAdd(aCBO,{'510310','Supervisor de vigilantes'})
aAdd(aCBO,{'510305','Supervisor de bombeiros'})
aAdd(aCBO,{'511105','Comiss�rio de v�o'})
aAdd(aCBO,{'511110','Comiss�rio de trem'})
aAdd(aCBO,{'511115','Taifeiro (exceto militares)'})
aAdd(aCBO,{'511220','Bilheteiro (esta��es de metr�, ferrovi�rias e assemelhadas)'})
aAdd(aCBO,{'511215','Cobrador de transportes coletivos (exceto trem)'})
aAdd(aCBO,{'511205','Fiscal de transportes coletivos (exceto trem)'})
aAdd(aCBO,{'511210','Despachante de transportes coletivos (exceto trem)'})
aAdd(aCBO,{'511405','Guia de turismo'})
aAdd(aCBO,{'512120','Empregado dom�stico diarista'})
aAdd(aCBO,{'512110','Empregado dom�stico arrumador'})
aAdd(aCBO,{'512105','Empregado dom�stico nos servi�os gerais'})
aAdd(aCBO,{'512115','Empregado dom�stico faxineiro'})
aAdd(aCBO,{'513115','Governanta de hotelaria'})
aAdd(aCBO,{'513110','Mordomo de hotelaria'})
aAdd(aCBO,{'513105','Mordomo de resid�ncia'})
aAdd(aCBO,{'513205','Cozinheiro geral'})
aAdd(aCBO,{'513210','Cozinheiro do servi�o dom�stico'})
aAdd(aCBO,{'513215','Cozinheiro industrial'})
aAdd(aCBO,{'513220','Cozinheiro de hospital'})
aAdd(aCBO,{'513225','Cozinheiro de embarca��es'})
aAdd(aCBO,{'513325','Guarda-roupeira de cinema'})
aAdd(aCBO,{'513305','Camareira de teatro'})
aAdd(aCBO,{'513310','Camareira de televis�o'})
aAdd(aCBO,{'513315','Camareiro de hotel'})
aAdd(aCBO,{'513320','Camareiro de embarca��es'})
aAdd(aCBO,{'513415','Cumim'})
aAdd(aCBO,{'513410','Gar�om (servi�os de vinhos)'})
aAdd(aCBO,{'513420','Barman'})
aAdd(aCBO,{'513425','Copeiro'})
aAdd(aCBO,{'513430','Copeiro de hospital'})
aAdd(aCBO,{'513405','Gar�om'})
aAdd(aCBO,{'513440','Barista'})
aAdd(aCBO,{'513435','Atendente de lanchonete'})
aAdd(aCBO,{'513505','Auxiliar nos servi�os de alimenta��o'})
aAdd(aCBO,{'513615','Sushiman'})
aAdd(aCBO,{'513610','Pizzaiolo'})
aAdd(aCBO,{'513605','Churrasqueiro'})
aAdd(aCBO,{'514115','Sacrist�o'})
aAdd(aCBO,{'514110','Garagista'})
aAdd(aCBO,{'514105','Ascensorista'})
aAdd(aCBO,{'514120','Zelador de edif�cio'})
aAdd(aCBO,{'514205','Coletor de lixo domiciliar'})
aAdd(aCBO,{'514230','Coletor de res�duos s�lidos de servi�os de sa�de'})
aAdd(aCBO,{'514225','Trabalhador de servi�os de limpeza e conserva��o de �reas p�blicas'})
aAdd(aCBO,{'514215','Varredor de rua'})
aAdd(aCBO,{'514315','Limpador de fachadas'})
aAdd(aCBO,{'514325','Trabalhador da manuten��o de edifica��es'})
aAdd(aCBO,{'514305','Limpador de vidros'})
aAdd(aCBO,{'514310','Auxiliar de manuten��o predial'})
aAdd(aCBO,{'514330','Limpador de piscinas'})
aAdd(aCBO,{'514320','Faxineiro'})
aAdd(aCBO,{'515130','Agente ind�gena de saneamento'})
aAdd(aCBO,{'515135','Socorrista (exceto m�dicos e enfermeiros)'})
aAdd(aCBO,{'515105','Agente comunit�rio de sa�de'})
aAdd(aCBO,{'515125','Agente ind�gena de sa�de'})
aAdd(aCBO,{'515115','Parteira leiga'})
aAdd(aCBO,{'515120','Visitador sanit�rio'})
aAdd(aCBO,{'515110','Atendente de enfermagem'})
aAdd(aCBO,{'515210','Auxiliar de farm�cia de manipula��o'})
aAdd(aCBO,{'515215','Auxiliar de laborat�rio de an�lises cl�nicas'})
aAdd(aCBO,{'515220','Auxiliar de laborat�rio de imunobiol�gicos'})
aAdd(aCBO,{'515225','Auxiliar de produ��o farmac�utica'})
aAdd(aCBO,{'515205','Auxiliar de banco de sangue'})
aAdd(aCBO,{'515305','Educador social'})
aAdd(aCBO,{'515310','Agente de a��o social'})
aAdd(aCBO,{'515315','Monitor de dependente qu�mico'})
aAdd(aCBO,{'515320','Conselheiro tutelar'})
aAdd(aCBO,{'515325','S�cioeducador'})
aAdd(aCBO,{'516140','Pedicure'})
aAdd(aCBO,{'516130','Maquiador de caracteriza��o'})
aAdd(aCBO,{'516125','Maquiador'})
aAdd(aCBO,{'516120','Manicure'})
aAdd(aCBO,{'516110','Cabeleireiro'})
aAdd(aCBO,{'516105','Barbeiro'})
aAdd(aCBO,{'516205','Bab�'})
aAdd(aCBO,{'516220','Cuidador em sa�de'})
aAdd(aCBO,{'516215','M�e social'})
aAdd(aCBO,{'516210','Cuidador de idosos'})
aAdd(aCBO,{'516325','Passador de roupas em geral'})
aAdd(aCBO,{'516320','Limpador a seco, � m�quina'})
aAdd(aCBO,{'516315','Lavador de artefatos de tape�aria'})
aAdd(aCBO,{'516310','Lavador de roupas a maquina'})
aAdd(aCBO,{'516305','Lavadeiro, em geral'})
aAdd(aCBO,{'516330','Tingidor de roupas'})
aAdd(aCBO,{'516345','Auxiliar de lavanderia'})
aAdd(aCBO,{'516340','Atendente de lavanderia'})
aAdd(aCBO,{'516335','Conferente-expedidor de roupas (lavanderias)'})
aAdd(aCBO,{'516410','Limpador de roupas a seco, � m�o'})
aAdd(aCBO,{'516405','Lavador de roupas'})
aAdd(aCBO,{'516415','Passador de roupas, � m�o'})
aAdd(aCBO,{'516505','Agente funer�rio'})
aAdd(aCBO,{'516605','Operador de forno (servi�os funer�rios)'})
aAdd(aCBO,{'516610','Sepultador'})
aAdd(aCBO,{'516710','Numer�logo'})
aAdd(aCBO,{'516705','Astr�logo'})
aAdd(aCBO,{'516805','Esot�rico'})
aAdd(aCBO,{'516810','Paranormal'})
aAdd(aCBO,{'517105','Bombeiro de aer�dromo'})
aAdd(aCBO,{'517110','Bombeiro civil'})
aAdd(aCBO,{'517115','Salva-vidas'})
aAdd(aCBO,{'517220','Agente de tr�nsito'})
aAdd(aCBO,{'517210','Policial rodovi�rio federal'})
aAdd(aCBO,{'517205','Agente de pol�cia federal'})
aAdd(aCBO,{'517215','Guarda-civil municipal'})
aAdd(aCBO,{'517330','Vigilante'})
aAdd(aCBO,{'517305','Agente de prote��o de aeroporto'})
aAdd(aCBO,{'517310','Agente de seguran�a'})
aAdd(aCBO,{'517335','Guarda portu�rio'})
aAdd(aCBO,{'517315','Agente de seguran�a penitenci�ria'})
aAdd(aCBO,{'517320','Vigia florestal'})
aAdd(aCBO,{'517325','Vigia portu�rio'})
aAdd(aCBO,{'517415','Porteiro de locais de divers�o'})
aAdd(aCBO,{'517425','Fiscal de loja'})
aAdd(aCBO,{'517405','Porteiro (hotel)'})
aAdd(aCBO,{'517410','Porteiro de edif�cios'})
aAdd(aCBO,{'517420','Vigia'})
aAdd(aCBO,{'519105','Ciclista mensageiro'})
aAdd(aCBO,{'519110','Motociclista no transporte de pessoas, documentos e pequenos volumes'})
aAdd(aCBO,{'519210','Selecionador de material recicl�vel'})
aAdd(aCBO,{'519215','Operador de prensa de material recicl�vel'})
aAdd(aCBO,{'519205','Catador de material recicl�vel'})
aAdd(aCBO,{'519315','Banhista de animais dom�sticos'})
aAdd(aCBO,{'519320','Tosador de animais dom�sticos'})
aAdd(aCBO,{'519310','Esteticista de animais dom�sticos'})
aAdd(aCBO,{'519305','Auxiliar de veterin�rio'})
aAdd(aCBO,{'519805','Profissional do sexo'})
aAdd(aCBO,{'519925','Guardador de ve�culos'})
aAdd(aCBO,{'519930','Lavador de garrafas, vidros e outros utens�lios'})
aAdd(aCBO,{'519935','Lavador de ve�culos'})
aAdd(aCBO,{'519945','Recepcionista de casas de espet�culos'})
aAdd(aCBO,{'519915','Engraxate'})
aAdd(aCBO,{'519910','Controlador de pragas'})
aAdd(aCBO,{'519905','Cartazeiro'})
aAdd(aCBO,{'519920','Gandula'})
aAdd(aCBO,{'519940','Leiturista'})
aAdd(aCBO,{'520105','Supervisor de vendas de servi�os'})
aAdd(aCBO,{'520110','Supervisor de vendas comercial'})
aAdd(aCBO,{'521130','Atendente de farm�cia - balconista'})
aAdd(aCBO,{'521135','Frentista'})
aAdd(aCBO,{'521125','Repositor de mercadorias'})
aAdd(aCBO,{'521120','Demonstrador de mercadorias'})
aAdd(aCBO,{'521115','Promotor de vendas'})
aAdd(aCBO,{'521110','Vendedor de com�rcio varejista'})
aAdd(aCBO,{'521105','Vendedor em com�rcio atacadista'})
aAdd(aCBO,{'521140','Atendente de lojas e mercados'})
aAdd(aCBO,{'523105','Instalador de cortinas e persianas, portas sanfonadas e boxe'})
aAdd(aCBO,{'523110','Instalador de som e acess�rios de ve�culos'})
aAdd(aCBO,{'523115','Chaveiro'})
aAdd(aCBO,{'524105','Vendedor em domic�lio'})
aAdd(aCBO,{'524210','Jornaleiro (em banca de jornal)'})
aAdd(aCBO,{'524215','Vendedor permission�rio'})
aAdd(aCBO,{'524205','Feirante'})
aAdd(aCBO,{'524310','Pipoqueiro ambulante'})
aAdd(aCBO,{'524305','Vendedor ambulante'})
aAdd(aCBO,{'611005','Produtor agropecu�rio, em geral'})
aAdd(aCBO,{'612005','Produtor agr�cola polivalente'})
aAdd(aCBO,{'612105','Produtor de arroz'})
aAdd(aCBO,{'612110','Produtor de cana-de-a��car'})
aAdd(aCBO,{'612115','Produtor de cereais de inverno'})
aAdd(aCBO,{'612125','Produtor de milho e sorgo'})
aAdd(aCBO,{'612120','Produtor de gram�neas forrageiras'})
aAdd(aCBO,{'612205','Produtor de algod�o'})
aAdd(aCBO,{'612210','Produtor de curau�'})
aAdd(aCBO,{'612215','Produtor de juta'})
aAdd(aCBO,{'612225','Produtor de sisal'})
aAdd(aCBO,{'612220','Produtor de rami'})
aAdd(aCBO,{'612320','Produtor na olericultura de frutos e sementes'})
aAdd(aCBO,{'612315','Produtor na olericultura de talos, folhas e flores'})
aAdd(aCBO,{'612310','Produtor na olericultura de ra�zes, bulbos e tub�rculos'})
aAdd(aCBO,{'612305','Produtor na olericultura de legumes'})
aAdd(aCBO,{'612415','Produtor de forra��es'})
aAdd(aCBO,{'612420','Produtor de plantas ornamentais'})
aAdd(aCBO,{'612410','Produtor de flores em vaso'})
aAdd(aCBO,{'612405','Produtor de flores de corte'})
aAdd(aCBO,{'612515','Produtor de esp�cies frut�feras trepadeiras'})
aAdd(aCBO,{'612510','Produtor de esp�cies frut�feras rasteiras'})
aAdd(aCBO,{'612505','Produtor de �rvores frut�feras'})
aAdd(aCBO,{'612625','Produtor de guaran�'})
aAdd(aCBO,{'612620','Produtor de fumo'})
aAdd(aCBO,{'612610','Produtor de cacau'})
aAdd(aCBO,{'612615','Produtor de erva-mate'})
aAdd(aCBO,{'612605','Cafeicultor'})
aAdd(aCBO,{'612730','Produtor da cultura de linho'})
aAdd(aCBO,{'612735','Produtor da cultura de mamona'})
aAdd(aCBO,{'612740','Produtor da cultura de soja'})
aAdd(aCBO,{'612705','Produtor da cultura de amendoim'})
aAdd(aCBO,{'612710','Produtor da cultura de canola'})
aAdd(aCBO,{'612715','Produtor da cultura de coco-da-baia'})
aAdd(aCBO,{'612725','Produtor da cultura de girassol'})
aAdd(aCBO,{'612720','Produtor da cultura de dend�'})
aAdd(aCBO,{'612810','Produtor de plantas arom�ticas e medicinais'})
aAdd(aCBO,{'612805','Produtor de especiarias'})
aAdd(aCBO,{'613010','Criador de animais dom�sticos'})
aAdd(aCBO,{'613005','Criador em pecu�ria polivalente'})
aAdd(aCBO,{'613120','Criador de bubalinos (corte)'})
aAdd(aCBO,{'613125','Criador de bubalinos (leite)'})
aAdd(aCBO,{'613115','Criador de bovinos (leite)'})
aAdd(aCBO,{'613110','Criador de bovinos (corte)'})
aAdd(aCBO,{'613105','Criador de asininos e muares'})
aAdd(aCBO,{'613130','Criador de eq��nos'})
aAdd(aCBO,{'613210','Criador de ovinos'})
aAdd(aCBO,{'613215','Criador de su�nos'})
aAdd(aCBO,{'613205','Criador de caprinos'})
aAdd(aCBO,{'613310','Cunicultor'})
aAdd(aCBO,{'613305','Avicultor'})
aAdd(aCBO,{'613415','Minhocultor'})
aAdd(aCBO,{'613420','Sericultor'})
aAdd(aCBO,{'613410','Criador de animais produtores de veneno'})
aAdd(aCBO,{'613405','Apicultor'})
aAdd(aCBO,{'620105','Supervisor de explora��o agr�cola'})
aAdd(aCBO,{'620110','Supervisor de explora��o agropecu�ria'})
aAdd(aCBO,{'620115','Supervisor de explora��o pecu�ria'})
aAdd(aCBO,{'621005','Trabalhador agropecu�rio em geral'})
aAdd(aCBO,{'622005','Caseiro (agricultura)'})
aAdd(aCBO,{'622010','Jardineiro'})
aAdd(aCBO,{'622020','Trabalhador volante da agricultura'})
aAdd(aCBO,{'622015','Trabalhador na produ��o de mudas e sementes'})
aAdd(aCBO,{'622105','Trabalhador da cultura de arroz'})
aAdd(aCBO,{'622115','Trabalhador da cultura de milho e sorgo'})
aAdd(aCBO,{'622110','Trabalhador da cultura de cana-de-a��car'})
aAdd(aCBO,{'622120','Trabalhador da cultura de trigo, aveia, cevada e triticale'})
aAdd(aCBO,{'622205','Trabalhador da cultura de algod�o'})
aAdd(aCBO,{'622210','Trabalhador da cultura de sisal'})
aAdd(aCBO,{'622215','Trabalhador da cultura do rami'})
aAdd(aCBO,{'622305','Trabalhador na olericultura (frutos e sementes)'})
aAdd(aCBO,{'622310','Trabalhador na olericultura (legumes)'})
aAdd(aCBO,{'622315','Trabalhador na olericultura (ra�zes, bulbos e tub�rculos)'})
aAdd(aCBO,{'622320','Trabalhador na olericultura (talos, folhas e flores)'})
aAdd(aCBO,{'622405','Trabalhador no cultivo de flores e folhagens de corte'})
aAdd(aCBO,{'622410','Trabalhador no cultivo de flores em vaso'})
aAdd(aCBO,{'622425','Trabalhador no cultivo de plantas ornamentais'})
aAdd(aCBO,{'622420','Trabalhador no cultivo de mudas'})
aAdd(aCBO,{'622415','Trabalhador no cultivo de forra��es'})
aAdd(aCBO,{'622505','Trabalhador no cultivo de �rvores frut�feras'})
aAdd(aCBO,{'622510','Trabalhador no cultivo de esp�cies frut�feras rasteiras'})
aAdd(aCBO,{'622515','Trabalhador no cultivo de trepadeiras frut�feras'})
aAdd(aCBO,{'622605','Trabalhador da cultura de cacau'})
aAdd(aCBO,{'622610','Trabalhador da cultura de caf�'})
aAdd(aCBO,{'622615','Trabalhador da cultura de erva-mate'})
aAdd(aCBO,{'622620','Trabalhador da cultura de fumo'})
aAdd(aCBO,{'622625','Trabalhador da cultura de guaran�'})
aAdd(aCBO,{'622740','Trabalhador na cultura do linho'})
aAdd(aCBO,{'622735','Trabalhador na cultura do girassol'})
aAdd(aCBO,{'622730','Trabalhador na cultura de soja'})
aAdd(aCBO,{'622725','Trabalhador na cultura de mamona'})
aAdd(aCBO,{'622720','Trabalhador na cultura de dend�'})
aAdd(aCBO,{'622715','Trabalhador na cultura de coco-da-ba�a'})
aAdd(aCBO,{'622710','Trabalhador na cultura de canola'})
aAdd(aCBO,{'622705','Trabalhador na cultura de amendoim'})
aAdd(aCBO,{'622805','Trabalhador da cultura de especiarias'})
aAdd(aCBO,{'622810','Trabalhador da cultura de plantas arom�ticas e medicinais'})
aAdd(aCBO,{'623005','Adestrador de animais'})
aAdd(aCBO,{'623015','Trabalhador de pecu�ria polivalente'})
aAdd(aCBO,{'623010','Inseminador'})
aAdd(aCBO,{'623020','Tratador de animais'})
aAdd(aCBO,{'623125','Trabalhador da pecu�ria (eq�inos)'})
aAdd(aCBO,{'623120','Trabalhador da pecu�ria (bubalinos)'})
aAdd(aCBO,{'623110','Trabalhador da pecu�ria (bovinos corte)'})
aAdd(aCBO,{'623105','Trabalhador da pecu�ria (asininos e muares)'})
aAdd(aCBO,{'623115','Trabalhador da pecu�ria (bovinos leite)'})
aAdd(aCBO,{'623210','Trabalhador da ovinocultura'})
aAdd(aCBO,{'623215','Trabalhador da suinocultura'})
aAdd(aCBO,{'623205','Trabalhador da caprinocultura'})
aAdd(aCBO,{'623320','Trabalhador da cunicultura'})
aAdd(aCBO,{'623315','Operador de incubadora'})
aAdd(aCBO,{'623310','Trabalhador da avicultura de postura'})
aAdd(aCBO,{'623305','Trabalhador da avicultura de corte'})
aAdd(aCBO,{'623325','Sexador'})
aAdd(aCBO,{'623405','Trabalhador em criat�rios de animais produtores de veneno'})
aAdd(aCBO,{'623415','Trabalhador na minhocultura'})
aAdd(aCBO,{'623420','Trabalhador na sericicultura'})
aAdd(aCBO,{'623410','Trabalhador na apicultura'})
aAdd(aCBO,{'630105','Supervisor da aq�icultura'})
aAdd(aCBO,{'630110','Supervisor da �rea florestal'})
aAdd(aCBO,{'631020','Pescador artesanal de peixes e camar�es'})
aAdd(aCBO,{'631015','Pescador artesanal de lagostas'})
aAdd(aCBO,{'631005','Catador de caranguejos e siris'})
aAdd(aCBO,{'631010','Catador de mariscos'})
aAdd(aCBO,{'631105','Pescador artesanal de �gua doce'})
aAdd(aCBO,{'631205','Pescador industrial'})
aAdd(aCBO,{'631210','Pescador profissional'})
aAdd(aCBO,{'631320','Criador de ostras'})
aAdd(aCBO,{'631315','Criador de mexilh�es'})
aAdd(aCBO,{'631310','Criador de jacar�s'})
aAdd(aCBO,{'631305','Criador de camar�es'})
aAdd(aCBO,{'631330','Criador de quel�nios'})
aAdd(aCBO,{'631325','Criador de peixes'})
aAdd(aCBO,{'631335','Criador de r�s'})
aAdd(aCBO,{'631405','Gelador industrial'})
aAdd(aCBO,{'631410','Gelador profissional'})
aAdd(aCBO,{'631415','Proeiro'})
aAdd(aCBO,{'631420','Redeiro (pesca)'})
aAdd(aCBO,{'632005','Guia florestal'})
aAdd(aCBO,{'632015','Viveirista florestal'})
aAdd(aCBO,{'632010','Raizeiro'})
aAdd(aCBO,{'632105','Classificador de toras'})
aAdd(aCBO,{'632125','Trabalhador de extra��o florestal, em geral'})
aAdd(aCBO,{'632120','Operador de motosserra'})
aAdd(aCBO,{'632115','Identificador florestal'})
aAdd(aCBO,{'632110','Cubador de madeira'})
aAdd(aCBO,{'632215','Trabalhador da explora��o de resinas'})
aAdd(aCBO,{'632210','Trabalhador da explora��o de esp�cies produtoras de gomas n�o el�sticas'})
aAdd(aCBO,{'632205','Seringueiro'})
aAdd(aCBO,{'632370','Trabalhador da explora��o de tucum'})
aAdd(aCBO,{'632365','Trabalhador da explora��o de pia�ava'})
aAdd(aCBO,{'632360','Trabalhador da explora��o de pequi'})
aAdd(aCBO,{'632355','Trabalhador da explora��o de ouricuri'})
aAdd(aCBO,{'632350','Trabalhador da explora��o de oiticica'})
aAdd(aCBO,{'632345','Trabalhador da explora��o de murumuru'})
aAdd(aCBO,{'632340','Trabalhador da explora��o de malva (p�ina)'})
aAdd(aCBO,{'632335','Trabalhador da explora��o de copa�ba'})
aAdd(aCBO,{'632330','Trabalhador da explora��o de coco-da-praia'})
aAdd(aCBO,{'632325','Trabalhador da explora��o de carna�ba'})
aAdd(aCBO,{'632320','Trabalhador da explora��o de buriti'})
aAdd(aCBO,{'632315','Trabalhador da explora��o de bacaba'})
aAdd(aCBO,{'632305','Trabalhador da explora��o de andiroba'})
aAdd(aCBO,{'632310','Trabalhador da explora��o de baba�u'})
aAdd(aCBO,{'632420','Trabalhador da explora��o de pupunha'})
aAdd(aCBO,{'632410','Trabalhador da explora��o de castanha'})
aAdd(aCBO,{'632415','Trabalhador da explora��o de pinh�o'})
aAdd(aCBO,{'632405','Trabalhador da explora��o de a�a�'})
aAdd(aCBO,{'632505','Trabalhador da explora��o de �rvores e arbustos produtores de subst�ncias arom�t., Medic. E t�xicas'})
aAdd(aCBO,{'632515','Trabalhador da explora��o de madeiras tanantes'})
aAdd(aCBO,{'632520','Trabalhador da explora��o de ra�zes produtoras de subst�ncias arom�ticas, medicinais e t�xicas'})
aAdd(aCBO,{'632525','Trabalhador da extra��o de subst�ncias arom�ticas, medicinais e t�xicas, em geral'})
aAdd(aCBO,{'632510','Trabalhador da explora��o de cip�s produtores de subst�ncias arom�ticas, medicinais e t�xicas'})
aAdd(aCBO,{'632605','Carvoeiro'})
aAdd(aCBO,{'632610','Carbonizador'})
aAdd(aCBO,{'632615','Ajudante de carvoaria'})
aAdd(aCBO,{'641010','Operador de m�quinas de beneficiamento de produtos agr�colas'})
aAdd(aCBO,{'641005','Operador de colheitadeira'})
aAdd(aCBO,{'641015','Tratorista agr�cola'})
aAdd(aCBO,{'642010','Operador de m�quinas florestais est�ticas'})
aAdd(aCBO,{'642005','Operador de colhedor florestal'})
aAdd(aCBO,{'642015','Operador de trator florestal'})
aAdd(aCBO,{'643005','Trabalhador na opera��o de sistema de irriga��o localizada (microaspers�o e gotejamento)'})
aAdd(aCBO,{'643010','Trabalhador na opera��o de sistema de irriga��o por aspers�o (piv� central)'})
aAdd(aCBO,{'643015','Trabalhador na opera��o de sistemas convencionais de irriga��o por aspers�o'})
aAdd(aCBO,{'643020','Trabalhador na opera��o de sistemas de irriga��o e aspers�o (alto propelido)'})
aAdd(aCBO,{'643025','Trabalhador na opera��o de sistemas de irriga��o por superf�cie e drenagem'})
aAdd(aCBO,{'710105','Supervisor de apoio operacional na minera��o'})
aAdd(aCBO,{'710110','Supervisor de extra��o de sal'})
aAdd(aCBO,{'710115','Supervisor de perfura��o e desmonte'})
aAdd(aCBO,{'710120','Supervisor de produ��o na minera��o'})
aAdd(aCBO,{'710125','Supervisor de transporte na minera��o'})
aAdd(aCBO,{'710205','Mestre (constru��o civil)'})
aAdd(aCBO,{'710210','Mestre de linhas (ferrovias)'})
aAdd(aCBO,{'710215','Inspetor de terraplenagem'})
aAdd(aCBO,{'710220','Supervisor de usina de concreto'})
aAdd(aCBO,{'710225','Fiscal de p�tio de usina de concreto'})
aAdd(aCBO,{'711125','Escorador de minas'})
aAdd(aCBO,{'711120','Detonador'})
aAdd(aCBO,{'711115','Destro�ador de pedra'})
aAdd(aCBO,{'711110','Canteiro'})
aAdd(aCBO,{'711105','Amostrador de min�rios'})
aAdd(aCBO,{'711130','Mineiro'})
aAdd(aCBO,{'711225','Operador de m�quina perfuradora (minas e pedreiras)'})
aAdd(aCBO,{'711220','Operador de m�quina de extra��o cont�nua (minas de carv�o)'})
aAdd(aCBO,{'711215','Operador de m�quina cortadora (minas e pedreiras)'})
aAdd(aCBO,{'711210','Operador de carregadeira'})
aAdd(aCBO,{'711205','Operador de caminh�o (minas e pedreiras)'})
aAdd(aCBO,{'711230','Operador de m�quina perfuratriz'})
aAdd(aCBO,{'711245','Operador de trator (minas e pedreiras)'})
aAdd(aCBO,{'711240','Operador de schutthecar'})
aAdd(aCBO,{'711235','Operador de motoniveladora (extra��o de minerais s�lidos)'})
aAdd(aCBO,{'711305','Operador de sonda de percuss�o'})
aAdd(aCBO,{'711310','Operador de sonda rotativa'})
aAdd(aCBO,{'711315','Sondador (po�os de petr�leo e g�s)'})
aAdd(aCBO,{'711320','Sondador de po�os (exceto de petr�leo e g�s)'})
aAdd(aCBO,{'711330','Torrista (petr�leo)'})
aAdd(aCBO,{'711325','Plataformista (petr�leo)'})
aAdd(aCBO,{'711405','Garimpeiro'})
aAdd(aCBO,{'711410','Operador de salina (sal marinho)'})
aAdd(aCBO,{'712105','Moleiro de min�rios'})
aAdd(aCBO,{'712110','Operador de aparelho de flota��o'})
aAdd(aCBO,{'712115','Operador de aparelho de precipita��o (minas de ouro ou prata)'})
aAdd(aCBO,{'712120','Operador de britador de mand�bulas'})
aAdd(aCBO,{'712125','Operador de espessador'})
aAdd(aCBO,{'712130','Operador de jig (minas)'})
aAdd(aCBO,{'712135','Operador de peneiras hidr�ulicas'})
aAdd(aCBO,{'712205','Cortador de pedras'})
aAdd(aCBO,{'712210','Gravador de inscri��es em pedra'})
aAdd(aCBO,{'712215','Gravador de relevos em pedra'})
aAdd(aCBO,{'712220','Polidor de pedras'})
aAdd(aCBO,{'712225','Torneiro (lavra de pedra)'})
aAdd(aCBO,{'712230','Tra�ador de pedras'})
aAdd(aCBO,{'715105','Operador de bate-estacas'})
aAdd(aCBO,{'715110','Operador de compactadora de solos'})
aAdd(aCBO,{'715115','Operador de escavadeira'})
aAdd(aCBO,{'715120','Operador de m�quina de abrir valas'})
aAdd(aCBO,{'715145','Operador de trator de l�mina'})
aAdd(aCBO,{'715130','Operador de motoniveladora'})
aAdd(aCBO,{'715135','Operador de p� carregadeira'})
aAdd(aCBO,{'715140','Operador de pavimentadora (asfalto, concreto e materiais similares)'})
aAdd(aCBO,{'715125','Operador de m�quinas de constru��o civil e minera��o'})
aAdd(aCBO,{'715205','Calceteiro'})
aAdd(aCBO,{'715210','Pedreiro'})
aAdd(aCBO,{'715230','Pedreiro de edifica��es'})
aAdd(aCBO,{'715225','Pedreiro (minera��o)'})
aAdd(aCBO,{'715220','Pedreiro (material refrat�rio)'})
aAdd(aCBO,{'715215','Pedreiro (chamin�s industriais)'})
aAdd(aCBO,{'715305','Armador de estrutura de concreto'})
aAdd(aCBO,{'715315','Armador de estrutura de concreto armado'})
aAdd(aCBO,{'715310','Moldador de corpos de prova em usinas de concreto'})
aAdd(aCBO,{'715410','Operador de bomba de concreto'})
aAdd(aCBO,{'715405','Operador de betoneira'})
aAdd(aCBO,{'715415','Operador de central de concreto'})
aAdd(aCBO,{'715505','Carpinteiro'})
aAdd(aCBO,{'715510','Carpinteiro (esquadrias)'})
aAdd(aCBO,{'715515','Carpinteiro (cen�rios)'})
aAdd(aCBO,{'715520','Carpinteiro (minera��o)'})
aAdd(aCBO,{'715525','Carpinteiro de obras'})
aAdd(aCBO,{'715530','Carpinteiro (telhados)'})
aAdd(aCBO,{'715535','Carpinteiro de f�rmas para concreto'})
aAdd(aCBO,{'715540','Carpinteiro de obras civis de arte (pontes, t�neis, barragens)'})
aAdd(aCBO,{'715545','Montador de andaimes (edifica��es)'})
aAdd(aCBO,{'715605','Eletricista de instala��es (cen�rios)'})
aAdd(aCBO,{'715610','Eletricista de instala��es (edif�cios)'})
aAdd(aCBO,{'715615','Eletricista de instala��es'})
aAdd(aCBO,{'715720','Instalador de isolantes t�rmicos de caldeira e tubula��es'})
aAdd(aCBO,{'715725','Instalador de material isolante, a m�o (edifica��es)'})
aAdd(aCBO,{'715705','Aplicador de asfalto impermeabilizante (coberturas)'})
aAdd(aCBO,{'715730','Instalador de material isolante, a m�quina (edifica��es)'})
aAdd(aCBO,{'715715','Instalador de isolantes t�rmicos (refrigera��o e climatiza��o)'})
aAdd(aCBO,{'715710','Instalador de isolantes ac�sticos'})
aAdd(aCBO,{'716105','Acabador de superf�cies de concreto'})
aAdd(aCBO,{'716110','Revestidor de superf�cies de concreto'})
aAdd(aCBO,{'716210','Telhador (telhas de cimento-amianto)'})
aAdd(aCBO,{'716220','Telhador (telhas pl�sticas)'})
aAdd(aCBO,{'716205','Telhador (telhas de argila e materiais similares)'})
aAdd(aCBO,{'716215','Telhador (telhas met�licas)'})
aAdd(aCBO,{'716305','Vidraceiro'})
aAdd(aCBO,{'716310','Vidraceiro (edifica��es)'})
aAdd(aCBO,{'716315','Vidraceiro (vitrais)'})
aAdd(aCBO,{'716405','Gesseiro'})
aAdd(aCBO,{'716535','Taqueiro'})
aAdd(aCBO,{'716530','Mosa�sta'})
aAdd(aCBO,{'716525','Marmorista (constru��o)'})
aAdd(aCBO,{'716520','Lustrador de piso'})
aAdd(aCBO,{'716515','Pastilheiro'})
aAdd(aCBO,{'716505','Assoalhador'})
aAdd(aCBO,{'716510','Ladrilheiro'})
aAdd(aCBO,{'716605','Calafetador'})
aAdd(aCBO,{'716615','Revestidor de interiores (papel, material pl�stico e emborrachados)'})
aAdd(aCBO,{'716610','Pintor de obras'})
aAdd(aCBO,{'717025','Vibradorista'})
aAdd(aCBO,{'717005','Demolidor de edifica��es'})
aAdd(aCBO,{'717010','Operador de martelete'})
aAdd(aCBO,{'717015','Poceiro (edifica��es)'})
aAdd(aCBO,{'717020','Servente de obras'})
aAdd(aCBO,{'720110','Mestre de caldeiraria'})
aAdd(aCBO,{'720105','Mestre (afiador de ferramentas)'})
aAdd(aCBO,{'720155','Mestre serralheiro'})
aAdd(aCBO,{'720140','Mestre de soldagem'})
aAdd(aCBO,{'720135','Mestre de pintura (tratamento de superf�cies)'})
aAdd(aCBO,{'720115','Mestre de ferramentaria'})
aAdd(aCBO,{'720125','Mestre de fundi��o'})
aAdd(aCBO,{'720130','Mestre de galvanoplastia'})
aAdd(aCBO,{'720145','Mestre de trefila��o de metais'})
aAdd(aCBO,{'720150','Mestre de usinagem'})
aAdd(aCBO,{'720160','Supervisor de controle de tratamento t�rmico'})
aAdd(aCBO,{'720120','Mestre de forjaria'})
aAdd(aCBO,{'720210','Mestre (ind�stria de automotores e material de transportes)'})
aAdd(aCBO,{'720205','Mestre (constru��o naval)'})
aAdd(aCBO,{'720215','Mestre (ind�stria de m�quinas e outros equipamentos mec�nicos)'})
aAdd(aCBO,{'720220','Mestre de constru��o de fornos'})
aAdd(aCBO,{'721110','Ferramenteiro de mandris, calibradores e outros dispositivos'})
aAdd(aCBO,{'721105','Ferramenteiro'})
aAdd(aCBO,{'721115','Modelador de metais (fundi��o)'})
aAdd(aCBO,{'721220','Operador de usinagem convencional por abras�o'})
aAdd(aCBO,{'721215','Operador de m�quinas-ferramenta convencionais'})
aAdd(aCBO,{'721210','Operador de m�quinas operatrizes'})
aAdd(aCBO,{'721205','Operador de m�quina de eletroeros�o'})
aAdd(aCBO,{'721225','Preparador de m�quinas-ferramenta'})
aAdd(aCBO,{'721320','Afiador de serras'})
aAdd(aCBO,{'721315','Afiador de ferramentas'})
aAdd(aCBO,{'721310','Afiador de cutelaria'})
aAdd(aCBO,{'721305','Afiador de cardas'})
aAdd(aCBO,{'721325','Polidor de metais'})
aAdd(aCBO,{'721405','Operador de centro de usinagem com comando num�rico'})
aAdd(aCBO,{'721410','Operador de fresadora com comando num�rico'})
aAdd(aCBO,{'721415','Operador de mandriladora com comando num�rico'})
aAdd(aCBO,{'721420','Operador de m�quina eletroeros�o, � fio, com comando num�rico'})
aAdd(aCBO,{'721425','Operador de retificadora com comando num�rico'})
aAdd(aCBO,{'721430','Operador de torno com comando num�rico'})
aAdd(aCBO,{'722105','Forjador'})
aAdd(aCBO,{'722110','Forjador a martelo'})
aAdd(aCBO,{'722115','Forjador prensista'})
aAdd(aCBO,{'722215','Operador de acabamento de pe�as fundidas'})
aAdd(aCBO,{'722220','Operador de m�quina centrifugadora de fundi��o'})
aAdd(aCBO,{'722225','Operador de m�quina de fundir sob press�o'})
aAdd(aCBO,{'722230','Operador de vazamento (lingotamento)'})
aAdd(aCBO,{'722235','Preparador de panelas (lingotamento)'})
aAdd(aCBO,{'722205','Fundidor de metais'})
aAdd(aCBO,{'722210','Lingotador'})
aAdd(aCBO,{'722305','Macheiro, a m�o'})
aAdd(aCBO,{'722310','Macheiro, a m�quina'})
aAdd(aCBO,{'722315','Moldador, a m�o'})
aAdd(aCBO,{'722320','Moldador, a m�quina'})
aAdd(aCBO,{'722325','Operador de equipamentos de prepara��o de areia'})
aAdd(aCBO,{'722330','Operador de m�quina de moldar automatizada'})
aAdd(aCBO,{'722405','Cableador'})
aAdd(aCBO,{'722410','Estirador de tubos de metal sem costura'})
aAdd(aCBO,{'722415','Trefilador de metais, � m�quina'})
aAdd(aCBO,{'723120','Operador de forno de tratamento t�rmico de metais'})
aAdd(aCBO,{'723115','Operador de equipamento para resfriamento'})
aAdd(aCBO,{'723110','Normalizador de metais e de comp�sitos'})
aAdd(aCBO,{'723105','Cementador de metais'})
aAdd(aCBO,{'723125','Temperador de metais e de comp�sitos'})
aAdd(aCBO,{'723220','Metalizador a pistola'})
aAdd(aCBO,{'723215','Galvanizador'})
aAdd(aCBO,{'723210','Fosfatizador'})
aAdd(aCBO,{'723205','Decapador'})
aAdd(aCBO,{'723225','Metalizador (banho quente)'})
aAdd(aCBO,{'723240','Oxidador'})
aAdd(aCBO,{'723235','Operador de zincagem (processo eletrol�tico)'})
aAdd(aCBO,{'723230','Operador de m�quina recobridora de arame'})
aAdd(aCBO,{'723305','Operador de equipamento de secagem de pintura'})
aAdd(aCBO,{'723310','Pintor a pincel e rolo (exceto obras e estruturas met�licas)'})
aAdd(aCBO,{'723325','Pintor por imers�o'})
aAdd(aCBO,{'723320','Pintor de ve�culos (fabrica��o)'})
aAdd(aCBO,{'723315','Pintor de estruturas met�licas'})
aAdd(aCBO,{'723330','Pintor, a pistola (exceto obras e estruturas met�licas)'})
aAdd(aCBO,{'724130','Instalador de tubula��es de g�s combust�vel (produ��o e distribui��o)'})
aAdd(aCBO,{'724125','Instalador de tubula��es (embarca��es)'})
aAdd(aCBO,{'724120','Instalador de tubula��es (aeronaves)'})
aAdd(aCBO,{'724115','Instalador de tubula��es'})
aAdd(aCBO,{'724110','Encanador'})
aAdd(aCBO,{'724105','Assentador de canaliza��o (edifica��es)'})
aAdd(aCBO,{'724135','Instalador de tubula��es de vapor (produ��o e distribui��o)'})
aAdd(aCBO,{'724210','Montador de estruturas met�licas de embarca��es'})
aAdd(aCBO,{'724230','Rebitador, a m�o'})
aAdd(aCBO,{'724225','Riscador de estruturas met�licas'})
aAdd(aCBO,{'724220','Preparador de estruturas met�licas'})
aAdd(aCBO,{'724215','Rebitador a martelo pneum�tico'})
aAdd(aCBO,{'724205','Montador de estruturas met�licas'})
aAdd(aCBO,{'724315','Soldador'})
aAdd(aCBO,{'724310','Oxicortador a m�o e a m�quina'})
aAdd(aCBO,{'724305','Brasador'})
aAdd(aCBO,{'724325','Soldador el�trico'})
aAdd(aCBO,{'724320','Soldador a oxig�s'})
aAdd(aCBO,{'724405','Caldeireiro (chapas de cobre)'})
aAdd(aCBO,{'724410','Caldeireiro (chapas de ferro e a�o)'})
aAdd(aCBO,{'724415','Chapeador'})
aAdd(aCBO,{'724430','Chapeador de aeronaves'})
aAdd(aCBO,{'724435','Funileiro industrial'})
aAdd(aCBO,{'724420','Chapeador de carrocerias met�licas (fabrica��o)'})
aAdd(aCBO,{'724440','Serralheiro'})
aAdd(aCBO,{'724425','Chapeador naval'})
aAdd(aCBO,{'724515','Prensista (operador de prensa)'})
aAdd(aCBO,{'724510','Operador de m�quina de dobrar chapas'})
aAdd(aCBO,{'724505','Operador de m�quina de cilindrar chapas'})
aAdd(aCBO,{'724605','Operador de la�os de cabos de a�o'})
aAdd(aCBO,{'724610','Tran�ador de cabos de a�o'})
aAdd(aCBO,{'725005','Ajustador ferramenteiro'})
aAdd(aCBO,{'725010','Ajustador mec�nico'})
aAdd(aCBO,{'725015','Ajustador mec�nico (usinagem em bancada e em m�quinas-ferramentas)'})
aAdd(aCBO,{'725020','Ajustador mec�nico em bancada'})
aAdd(aCBO,{'725025','Ajustador naval (reparo e constru��o)'})
aAdd(aCBO,{'725105','Montador de m�quinas, motores e acess�rios (montagem em s�rie)'})
aAdd(aCBO,{'725205','Montador de m�quinas'})
aAdd(aCBO,{'725210','Montador de m�quinas gr�ficas'})
aAdd(aCBO,{'725215','Montador de m�quinas operatrizes para madeira'})
aAdd(aCBO,{'725220','Montador de m�quinas t�xteis'})
aAdd(aCBO,{'725225','Montador de m�quinas-ferramentas (usinagem de metais)'})
aAdd(aCBO,{'725315','Montador de m�quinas de minas e pedreiras'})
aAdd(aCBO,{'725320','Montador de m�quinas de terraplenagem'})
aAdd(aCBO,{'725310','Montador de m�quinas agr�colas'})
aAdd(aCBO,{'725305','Montador de equipamento de levantamento'})
aAdd(aCBO,{'725405','Mec�nico montador de motores de aeronaves'})
aAdd(aCBO,{'725420','Mec�nico montador de turboalimentadores'})
aAdd(aCBO,{'725415','Mec�nico montador de motores de explos�o e diesel'})
aAdd(aCBO,{'725410','Mec�nico montador de motores de embarca��es'})
aAdd(aCBO,{'725505','Montador de ve�culos (linha de montagem)'})
aAdd(aCBO,{'725510','Operador de time de montagem'})
aAdd(aCBO,{'725605','Montador de estruturas de aeronaves'})
aAdd(aCBO,{'725610','Montador de sistemas de combust�vel de aeronaves'})
aAdd(aCBO,{'725705','Mec�nico de refrigera��o'})
aAdd(aCBO,{'730105','Supervisor de montagem e instala��o eletroeletr�nica'})
aAdd(aCBO,{'731115','Montador de equipamentos el�tricos (instrumentos de medi��o)'})
aAdd(aCBO,{'731120','Montador de equipamentos el�tricos (aparelhos eletrodom�sticos)'})
aAdd(aCBO,{'731125','Montador de equipamentos el�tricos (centrais el�tricas)'})
aAdd(aCBO,{'731130','Montador de equipamentos el�tricos (motores e d�namos)'})
aAdd(aCBO,{'731135','Montador de equipamentos el�tricos'})
aAdd(aCBO,{'731140','Montador de equipamentos eletr�nicos (instala��es de sinaliza��o)'})
aAdd(aCBO,{'731145','Montador de equipamentos eletr�nicos (m�quinas industriais)'})
aAdd(aCBO,{'731150','Montador de equipamentos eletr�nicos'})
aAdd(aCBO,{'731155','Montador de equipamentos el�tricos (elevadores e equipamentos similares)'})
aAdd(aCBO,{'731160','Montador de equipamentos el�tricos (transformadores)'})
aAdd(aCBO,{'731165','Bobinador eletricista, � m�o'})
aAdd(aCBO,{'731170','Bobinador eletricista, � m�quina'})
aAdd(aCBO,{'731175','Operador de linha de montagem (aparelhos el�tricos)'})
aAdd(aCBO,{'731180','Operador de linha de montagem (aparelhos eletr�nicos)'})
aAdd(aCBO,{'731105','Montador de equipamentos eletr�nicos (aparelhos m�dicos)'})
aAdd(aCBO,{'731110','Montador de equipamentos eletr�nicos (computadores e equipamentos auxiliares)'})
aAdd(aCBO,{'731205','Montador de equipamentos eletr�nicos (esta��o de r�dio, tv e equipamentos de radar)'})
aAdd(aCBO,{'731310','Instalador-reparador de equipamentos de energia em telefonia'})
aAdd(aCBO,{'731315','Instalador-reparador de equipamentos de transmiss�o em telefonia'})
aAdd(aCBO,{'731320','Instalador-reparador de linhas e aparelhos de telecomunica��es'})
aAdd(aCBO,{'731325','Instalador-reparador de redes e cabos telef�nicos'})
aAdd(aCBO,{'731305','Instalador-reparador de equipamentos de comuta��o em telefonia'})
aAdd(aCBO,{'731330','Reparador de aparelhos de telecomunica��es em laborat�rio'})
aAdd(aCBO,{'732105','Eletricista de manuten��o de linhas el�tricas, telef�nicas e de comunica��o de dados'})
aAdd(aCBO,{'732110','Emendador de cabos el�tricos e telef�nicos (a�reos e subterr�neos)'})
aAdd(aCBO,{'732115','Examinador de cabos, linhas el�tricas e telef�nicas'})
aAdd(aCBO,{'732120','Instalador de linhas el�tricas de alta e baixa - tens�o (rede a�rea e subterr�nea)'})
aAdd(aCBO,{'732125','Instalador eletricista (tra��o de ve�culos)'})
aAdd(aCBO,{'732130','Instalador-reparador de redes telef�nicas e de comunica��o de dados'})
aAdd(aCBO,{'732135','Ligador de linhas telef�nicas'})
aAdd(aCBO,{'740110','Supervisor de fabrica��o de instrumentos musicais'})
aAdd(aCBO,{'740105','Supervisor da mec�nica de precis�o'})
aAdd(aCBO,{'741125','Relojoeiro (repara��o)'})
aAdd(aCBO,{'741120','Relojoeiro (fabrica��o)'})
aAdd(aCBO,{'741115','Montador de instrumentos de precis�o'})
aAdd(aCBO,{'741110','Montador de instrumentos de �ptica'})
aAdd(aCBO,{'741105','Ajustador de instrumentos de precis�o'})
aAdd(aCBO,{'742135','Confeccionador de �rg�o'})
aAdd(aCBO,{'742130','Confeccionador de instrumentos de sopro (metal)'})
aAdd(aCBO,{'742125','Confeccionador de instrumentos de sopro (madeira)'})
aAdd(aCBO,{'742120','Confeccionador de instrumentos de percuss�o (pele, couro ou pl�stico)'})
aAdd(aCBO,{'742115','Confeccionador de instrumentos de corda'})
aAdd(aCBO,{'742110','Confeccionador de acorde�o'})
aAdd(aCBO,{'742140','Confeccionador de piano'})
aAdd(aCBO,{'742105','Afinador de instrumentos musicais'})
aAdd(aCBO,{'750105','Supervisor de joalheria'})
aAdd(aCBO,{'750205','Supervisor da ind�stria de minerais n�o met�licos (exceto os derivados de petr�leo e carv�o)'})
aAdd(aCBO,{'751005','Engastador (j�ias)'})
aAdd(aCBO,{'751010','Joalheiro'})
aAdd(aCBO,{'751015','Joalheiro (repara��es)'})
aAdd(aCBO,{'751020','Lapidador (j�ias)'})
aAdd(aCBO,{'751105','Bate-folha a m�quina'})
aAdd(aCBO,{'751110','Fundidor (joalheria e ourivesaria)'})
aAdd(aCBO,{'751130','Trefilador (joalheria e ourivesaria)'})
aAdd(aCBO,{'751125','Ourives'})
aAdd(aCBO,{'751120','Laminador de metais preciosos a m�o'})
aAdd(aCBO,{'751115','Gravador (joalheria e ourivesaria)'})
aAdd(aCBO,{'752110','Moldador (vidros)'})
aAdd(aCBO,{'752105','Artes�o modelador (vidros)'})
aAdd(aCBO,{'752115','Soprador de vidro'})
aAdd(aCBO,{'752120','Transformador de tubos de vidro'})
aAdd(aCBO,{'752205','Aplicador serigr�fico em vidros'})
aAdd(aCBO,{'752210','Cortador de vidro'})
aAdd(aCBO,{'752235','Surfassagista'})
aAdd(aCBO,{'752230','Lapidador de vidros e cristais'})
aAdd(aCBO,{'752225','Gravador de vidro a jato de areia'})
aAdd(aCBO,{'752220','Gravador de vidro a esmeril'})
aAdd(aCBO,{'752215','Gravador de vidro a �gua-forte'})
aAdd(aCBO,{'752305','Ceramista'})
aAdd(aCBO,{'752310','Ceramista (torno de pedal e motor)'})
aAdd(aCBO,{'752315','Ceramista (torno semi-autom�tico)'})
aAdd(aCBO,{'752320','Ceramista modelador'})
aAdd(aCBO,{'752325','Ceramista moldador'})
aAdd(aCBO,{'752330','Ceramista prensador'})
aAdd(aCBO,{'752425','Operador de espelhamento'})
aAdd(aCBO,{'752420','Operador de esmaltadeira'})
aAdd(aCBO,{'752415','Decorador de vidro � pincel'})
aAdd(aCBO,{'752410','Decorador de vidro'})
aAdd(aCBO,{'752405','Decorador de cer�mica'})
aAdd(aCBO,{'752430','Pintor de cer�mica, a pincel'})
aAdd(aCBO,{'760125','Mestre (ind�stria t�xtil e de confec��es)'})
aAdd(aCBO,{'760120','Contramestre de tecelagem (ind�stria t�xtil)'})
aAdd(aCBO,{'760115','Contramestre de malharia (ind�stria t�xtil)'})
aAdd(aCBO,{'760110','Contramestre de fia��o (ind�stria t�xtil)'})
aAdd(aCBO,{'760105','Contramestre de acabamento (ind�stria t�xtil)'})
aAdd(aCBO,{'760205','Supervisor de curtimento'})
aAdd(aCBO,{'760310','Encarregado de costura na confec��o do vestu�rio'})
aAdd(aCBO,{'760305','Encarregado de corte na confec��o do vestu�rio'})
aAdd(aCBO,{'760405','Supervisor (ind�stria de cal�ados e artefatos de couro)'})
aAdd(aCBO,{'760505','Supervisor da confec��o de artefatos de tecidos, couros e afins'})
aAdd(aCBO,{'760605','Supervisor das artes gr�ficas (ind�stria editorial e gr�fica)'})
aAdd(aCBO,{'761005','Operador polivalente da ind�stria t�xtil'})
aAdd(aCBO,{'761105','Classificador de fibras t�xteis'})
aAdd(aCBO,{'761110','Lavador de l�'})
aAdd(aCBO,{'761205','Operador de abertura (fia��o)'})
aAdd(aCBO,{'761220','Operador de cardas'})
aAdd(aCBO,{'761225','Operador de conicaleira'})
aAdd(aCBO,{'761230','Operador de filat�rio'})
aAdd(aCBO,{'761235','Operador de laminadeira e reunideira'})
aAdd(aCBO,{'761215','Operador de bobinadeira'})
aAdd(aCBO,{'761245','Operador de open-end'})
aAdd(aCBO,{'761250','Operador de passador (fia��o)'})
aAdd(aCBO,{'761255','Operador de penteadeira'})
aAdd(aCBO,{'761260','Operador de retorcedeira'})
aAdd(aCBO,{'761210','Operador de binadeira'})
aAdd(aCBO,{'761240','Operador de ma�aroqueira'})
aAdd(aCBO,{'761333','Tecel�o de malhas (m�quina retil�nea)'})
aAdd(aCBO,{'761348','Operador de engomadeira de urdume'})
aAdd(aCBO,{'761351','Operador de espuladeira'})
aAdd(aCBO,{'761357','Operador de urdideira'})
aAdd(aCBO,{'761360','Passamaneiro a m�quina'})
aAdd(aCBO,{'761363','Remetedor de fios'})
aAdd(aCBO,{'761303','Tecel�o (redes)'})
aAdd(aCBO,{'761306','Tecel�o (rendas e bordados)'})
aAdd(aCBO,{'761315','Tecel�o (tear mec�nico de maquineta)'})
aAdd(aCBO,{'761318','Tecel�o (tear mec�nico de xadrez)'})
aAdd(aCBO,{'761324','Tecel�o (tear mec�nico, exceto jacquard)'})
aAdd(aCBO,{'761327','Tecel�o de malhas, a m�quina'})
aAdd(aCBO,{'761336','Tecel�o de meias, a m�quina'})
aAdd(aCBO,{'761339','Tecel�o de meias (m�quina circular)'})
aAdd(aCBO,{'761342','Tecel�o de meias (m�quina retil�nea)'})
aAdd(aCBO,{'761345','Tecel�o de tapetes, a m�quina'})
aAdd(aCBO,{'761354','Operador de m�quina de cordoalha'})
aAdd(aCBO,{'761366','Picotador de cart�es jacquard'})
aAdd(aCBO,{'761309','Tecel�o (tear autom�tico)'})
aAdd(aCBO,{'761312','Tecel�o (tear jacquard)'})
aAdd(aCBO,{'761321','Tecel�o (tear mec�nico liso)'})
aAdd(aCBO,{'761330','Tecel�o de malhas (m�quina circular)'})
aAdd(aCBO,{'761405','Alvejador (tecidos)'})
aAdd(aCBO,{'761410','Estampador de tecido'})
aAdd(aCBO,{'761415','Operador de calandras (tecidos)'})
aAdd(aCBO,{'761420','Operador de chamuscadeira de tecidos'})
aAdd(aCBO,{'761425','Operador de impermeabilizador de tecidos'})
aAdd(aCBO,{'761430','Operador de m�quina de lavar fios e tecidos'})
aAdd(aCBO,{'761435','Operador de rameuse'})
aAdd(aCBO,{'761805','Inspetor de estamparia (produ��o t�xtil)'})
aAdd(aCBO,{'761810','Revisor de fios (produ��o t�xtil)'})
aAdd(aCBO,{'761815','Revisor de tecidos acabados'})
aAdd(aCBO,{'761820','Revisor de tecidos crus'})
aAdd(aCBO,{'762005','Trabalhador polivalente do curtimento de couros e peles'})
aAdd(aCBO,{'762105','Classificador de peles'})
aAdd(aCBO,{'762110','Descarnador de couros e peles, � maquina'})
aAdd(aCBO,{'762115','Estirador de couros e peles (prepara��o)'})
aAdd(aCBO,{'762120','Fuloneiro'})
aAdd(aCBO,{'762125','Rachador de couros e peles'})
aAdd(aCBO,{'762220','Rebaixador de couros'})
aAdd(aCBO,{'762215','Enxugador de couros'})
aAdd(aCBO,{'762210','Classificador de couros'})
aAdd(aCBO,{'762205','Curtidor (couros e peles)'})
aAdd(aCBO,{'762325','Operador de m�quinas do acabamento de couros e peles'})
aAdd(aCBO,{'762330','Prensador de couros e peles'})
aAdd(aCBO,{'762335','Palecionador de couros e peles'})
aAdd(aCBO,{'762340','Preparador de couros curtidos'})
aAdd(aCBO,{'762320','Matizador de couros e peles'})
aAdd(aCBO,{'762345','Vaqueador de couros e peles'})
aAdd(aCBO,{'762310','Fuloneiro no acabamento de couros e peles'})
aAdd(aCBO,{'762305','Estirador de couros e peles (acabamento)'})
aAdd(aCBO,{'762315','Lixador de couros e peles'})
aAdd(aCBO,{'763010','Costureira de pe�as sob encomenda'})
aAdd(aCBO,{'763005','Alfaiate'})
aAdd(aCBO,{'763020','Costureiro de roupa de couro e pele'})
aAdd(aCBO,{'763015','Costureira de repara��o de roupas'})
aAdd(aCBO,{'763105','Auxiliar de corte (prepara��o da confec��o de roupas)'})
aAdd(aCBO,{'763125','Ajudante de confec��o'})
aAdd(aCBO,{'763120','Riscador de roupas'})
aAdd(aCBO,{'763115','Enfestador de roupas'})
aAdd(aCBO,{'763110','Cortador de roupas'})
aAdd(aCBO,{'763205','Costureiro de roupas de couro e pele, a m�quina na confec��o em s�rie'})
aAdd(aCBO,{'763215','Costureiro, a m�quina na confec��o em s�rie'})
aAdd(aCBO,{'763210','Costureiro na confec��o em s�rie'})
aAdd(aCBO,{'763305','Arrematadeira'})
aAdd(aCBO,{'763325','Passadeira de pe�as confeccionadas'})
aAdd(aCBO,{'763320','Operador de m�quina de costura de acabamento'})
aAdd(aCBO,{'763315','Marcador de pe�as confeccionadas para bordar'})
aAdd(aCBO,{'763310','Bordador, � m�quina'})
aAdd(aCBO,{'764005','Trabalhador polivalente da confec��o de cal�ados'})
aAdd(aCBO,{'764110','Cortador de solas e palmilhas, a m�quina'})
aAdd(aCBO,{'764105','Cortador de cal�ados, a m�quina (exceto solas e palmilhas)'})
aAdd(aCBO,{'764115','Preparador de cal�ados'})
aAdd(aCBO,{'764120','Preparador de solas e palmilhas'})
aAdd(aCBO,{'764205','Costurador de cal�ados, a m�quina'})
aAdd(aCBO,{'764210','Montador de cal�ados'})
aAdd(aCBO,{'764305','Acabador de cal�ados'})
aAdd(aCBO,{'765005','Confeccionador de artefatos de couro (exceto sapatos)'})
aAdd(aCBO,{'765010','Chapeleiro de senhoras'})
aAdd(aCBO,{'765015','Boneleiro'})
aAdd(aCBO,{'765105','Cortador de artefatos de couro (exceto roupas e cal�ados)'})
aAdd(aCBO,{'765110','Cortador de tape�aria'})
aAdd(aCBO,{'765205','Colchoeiro (confec��o de colch�es)'})
aAdd(aCBO,{'765215','Confeccionador de brinquedos de pano'})
aAdd(aCBO,{'765235','Estofador de m�veis'})
aAdd(aCBO,{'765230','Estofador de avi�es'})
aAdd(aCBO,{'765225','Confeccionador de velas n�uticas, barracas e toldos'})
aAdd(aCBO,{'765310','Costurador de artefatos de couro, a m�quina (exceto roupas e cal�ados)'})
aAdd(aCBO,{'765315','Montador de artefatos de couro (exceto roupas e cal�ados)'})
aAdd(aCBO,{'765405','Trabalhador do acabamento de artefatos de tecidos e couros'})
aAdd(aCBO,{'766125','Montador de fotolito (anal�gico e digital)'})
aAdd(aCBO,{'766120','Editor de texto e imagem'})
aAdd(aCBO,{'766115','Gravador de matriz para flexografia (clicherista)'})
aAdd(aCBO,{'766105','Copiador de chapa'})
aAdd(aCBO,{'766155','Programador visual gr�fico'})
aAdd(aCBO,{'766135','Gravador de matriz calcogr�fica'})
aAdd(aCBO,{'766140','Gravador de matriz serigr�fica'})
aAdd(aCBO,{'766145','Operador de sistemas de prova (anal�gico e digital)'})
aAdd(aCBO,{'766150','Operador de processo de tratamento de imagem'})
aAdd(aCBO,{'766130','Gravador de matriz para rotogravura (eletromec�nico e qu�mico)'})
aAdd(aCBO,{'766220','Impressor de rotativa'})
aAdd(aCBO,{'766215','Impressor de ofsete (plano e rotativo)'})
aAdd(aCBO,{'766210','Impressor calcogr�fico'})
aAdd(aCBO,{'766205','Impressor (serigrafia)'})
aAdd(aCBO,{'766225','Impressor de rotogravura'})
aAdd(aCBO,{'766250','Impressor tipogr�fico'})
aAdd(aCBO,{'766245','Impressor tampogr�fico'})
aAdd(aCBO,{'766240','Impressor letterset'})
aAdd(aCBO,{'766235','Impressor flexogr�fico'})
aAdd(aCBO,{'766230','Impressor digital'})
aAdd(aCBO,{'766320','Operador de guilhotina (corte de papel)'})
aAdd(aCBO,{'766325','Preparador de matrizes de corte e vinco'})
aAdd(aCBO,{'766315','Operador de acabamento (ind�stria gr�fica)'})
aAdd(aCBO,{'766305','Acabador de embalagens (flex�veis e cartot�cnicas)'})
aAdd(aCBO,{'766310','Impressor de corte e vinco'})
aAdd(aCBO,{'766415','Revelador de filmes fotogr�ficos, em cores'})
aAdd(aCBO,{'766410','Revelador de filmes fotogr�ficos, em preto e branco'})
aAdd(aCBO,{'766405','Laboratorista fotogr�fico'})
aAdd(aCBO,{'766420','Auxiliar de radiologia (revela��o fotogr�fica)'})
aAdd(aCBO,{'768125','Chapeleiro (chap�us de palha)'})
aAdd(aCBO,{'768120','Redeiro'})
aAdd(aCBO,{'768115','Tricoteiro, � m�o'})
aAdd(aCBO,{'768110','Tecel�o de tapetes, a m�o'})
aAdd(aCBO,{'768105','Tecel�o (tear manual)'})
aAdd(aCBO,{'768130','Crocheteiro, a m�o'})
aAdd(aCBO,{'768205','Bordador, a m�o'})
aAdd(aCBO,{'768210','Cerzidor'})
aAdd(aCBO,{'768315','Costurador de artefatos de couro, a m�o (exceto roupas e cal�ados)'})
aAdd(aCBO,{'768320','Sapateiro (cal�ados sob medida)'})
aAdd(aCBO,{'768325','Seleiro'})
aAdd(aCBO,{'768305','Art�fice do couro'})
aAdd(aCBO,{'768310','Cortador de cal�ados, a m�o (exceto solas)'})
aAdd(aCBO,{'768605','Tip�grafo'})
aAdd(aCBO,{'768630','Confeccionador de carimbos de borracha'})
aAdd(aCBO,{'768625','Pintor de letreiros'})
aAdd(aCBO,{'768620','Paginador'})
aAdd(aCBO,{'768615','Monotipista'})
aAdd(aCBO,{'768610','Linotipista'})
aAdd(aCBO,{'768705','Gravador, � m�o (encaderna��o)'})
aAdd(aCBO,{'768710','Restaurador de livros'})
aAdd(aCBO,{'770110','Mestre carpinteiro'})
aAdd(aCBO,{'770105','Mestre (ind�stria de madeira e mobili�rio)'})
aAdd(aCBO,{'771110','Modelador de madeira'})
aAdd(aCBO,{'771105','Marceneiro'})
aAdd(aCBO,{'771115','Maquetista na marcenaria'})
aAdd(aCBO,{'771120','Tanoeiro'})
aAdd(aCBO,{'772115','Secador de madeira'})
aAdd(aCBO,{'772105','Classificador de madeira'})
aAdd(aCBO,{'772110','Impregnador de madeira'})
aAdd(aCBO,{'773120','Serrador de madeira'})
aAdd(aCBO,{'773125','Serrador de madeira (serra circular m�ltipla)'})
aAdd(aCBO,{'773130','Serrador de madeira (serra de fita m�ltipla)'})
aAdd(aCBO,{'773105','Cortador de laminados de madeira'})
aAdd(aCBO,{'773115','Serrador de bordas no desdobramento de madeira'})
aAdd(aCBO,{'773110','Operador de serras no desdobramento de madeira'})
aAdd(aCBO,{'773210','Prensista de aglomerados'})
aAdd(aCBO,{'773215','Prensista de compensados'})
aAdd(aCBO,{'773220','Preparador de aglomerantes'})
aAdd(aCBO,{'773205','Operador de m�quina intercaladora e placas (compensados)'})
aAdd(aCBO,{'773345','Operador de torno autom�tico (usinagem de madeira)'})
aAdd(aCBO,{'773350','Operador de tupia (usinagem de madeira)'})
aAdd(aCBO,{'773355','Torneiro na usinagem convencional de madeira'})
aAdd(aCBO,{'773315','Operador de fresadora (usinagem de madeira)'})
aAdd(aCBO,{'773330','Operador de molduradora (usinagem de madeira)'})
aAdd(aCBO,{'773340','Operador de serras (usinagem de madeira)'})
aAdd(aCBO,{'773335','Operador de plaina desengrossadeira'})
aAdd(aCBO,{'773325','Operador de m�quina de usinagem madeira, em geral'})
aAdd(aCBO,{'773320','Operador de lixadeira (usinagem de madeira)'})
aAdd(aCBO,{'773310','Operador de entalhadeira (usinagem de madeira)'})
aAdd(aCBO,{'773305','Operador de desempenadeira na usinagem convencional de madeira'})
aAdd(aCBO,{'773420','Operador de prensa de alta freq��ncia na usinagem de madeira'})
aAdd(aCBO,{'773415','Operador de m�quina de usinagem de madeira (produ��o em s�rie)'})
aAdd(aCBO,{'773410','Operador de m�quina de cortina d��gua (produ��o de m�veis)'})
aAdd(aCBO,{'773405','Operador de m�quina bordatriz'})
aAdd(aCBO,{'773510','Operador de m�quinas de usinar madeira (cnc)'})
aAdd(aCBO,{'773505','Operador de centro de usinagem de madeira (cnc)'})
aAdd(aCBO,{'774105','Montador de m�veis e artefatos de madeira'})
aAdd(aCBO,{'775110','Folheador de m�veis de madeira'})
aAdd(aCBO,{'775115','Lustrador de pe�as de madeira'})
aAdd(aCBO,{'775120','Marcheteiro'})
aAdd(aCBO,{'775105','Entalhador de madeira'})
aAdd(aCBO,{'776420','Confeccionador de m�veis de vime, junco e bambu'})
aAdd(aCBO,{'776405','Cesteiro'})
aAdd(aCBO,{'776410','Confeccionador de escovas, pinc�is e produtos similares (a m�o)'})
aAdd(aCBO,{'776415','Confeccionador de escovas, pinc�is e produtos similares (a m�quina)'})
aAdd(aCBO,{'776425','Esteireiro'})
aAdd(aCBO,{'776430','Vassoureiro'})
aAdd(aCBO,{'777105','Carpinteiro naval (constru��o de pequenas embarca��es)'})
aAdd(aCBO,{'777110','Carpinteiro naval (embarca��es)'})
aAdd(aCBO,{'777115','Carpinteiro naval (estaleiros)'})
aAdd(aCBO,{'777205','Carpinteiro de carretas'})
aAdd(aCBO,{'777210','Carpinteiro de carrocerias'})
aAdd(aCBO,{'780105','Supervisor de embalagem e etiquetagem'})
aAdd(aCBO,{'781110','Condutor de processos robotizados de soldagem'})
aAdd(aCBO,{'781105','Condutor de processos robotizados de pintura'})
aAdd(aCBO,{'781305','Operador de ve�culos subaqu�ticos controlados remotamente'})
aAdd(aCBO,{'781705','Mergulhador profissional (raso e profundo)'})
aAdd(aCBO,{'782125','Operador de monta-cargas (constru��o civil)'})
aAdd(aCBO,{'782130','Operador de ponte rolante'})
aAdd(aCBO,{'782120','Operador de m�quina rodoferrovi�ria'})
aAdd(aCBO,{'782115','Operador de guindaste m�vel'})
aAdd(aCBO,{'782110','Operador de guindaste (fixo)'})
aAdd(aCBO,{'782105','Operador de draga'})
aAdd(aCBO,{'782145','Sinaleiro (ponte-rolante)'})
aAdd(aCBO,{'782140','Operador de talha el�trica'})
aAdd(aCBO,{'782135','Operador de p�rtico rolante'})
aAdd(aCBO,{'782220','Operador de empilhadeira'})
aAdd(aCBO,{'782210','Operador de docagem'})
aAdd(aCBO,{'782205','Guincheiro (constru��o civil)'})
aAdd(aCBO,{'782315','Motorista de t�xi'})
aAdd(aCBO,{'782310','Motorista de furg�o ou ve�culo similar'})
aAdd(aCBO,{'782305','Motorista de carro de passeio'})
aAdd(aCBO,{'782410','Motorista de �nibus urbano'})
aAdd(aCBO,{'782415','Motorista de tr�lebus'})
aAdd(aCBO,{'782405','Motorista de �nibus rodovi�rio'})
aAdd(aCBO,{'782510','Motorista de caminh�o (rotas regionais e internacionais)'})
aAdd(aCBO,{'782505','Caminhoneiro aut�nomo (rotas regionais e internacionais)'})
aAdd(aCBO,{'782515','Motorista operacional de guincho'})
aAdd(aCBO,{'782620','Motorneiro'})
aAdd(aCBO,{'782630','Operador de telef�rico (passageiros)'})
aAdd(aCBO,{'782615','Maquinista de trem metropolitano'})
aAdd(aCBO,{'782610','Maquinista de trem'})
aAdd(aCBO,{'782605','Operador de trem de metr�'})
aAdd(aCBO,{'782625','Auxiliar de maquinista de trem'})
aAdd(aCBO,{'782720','Mo�o de m�quinas (mar�timo e fluvi�rio)'})
aAdd(aCBO,{'782725','Marinheiro de esporte e recreio'})
aAdd(aCBO,{'782715','Mo�o de conv�s (mar�timo e fluvi�rio)'})
aAdd(aCBO,{'782710','Marinheiro de m�quinas'})
aAdd(aCBO,{'782705','Marinheiro de conv�s (mar�timo e fluvi�rio)'})
aAdd(aCBO,{'782805','Condutor de ve�culos de tra��o animal (ruas e estradas)'})
aAdd(aCBO,{'782810','Tropeiro'})
aAdd(aCBO,{'782815','Boiadeiro'})
aAdd(aCBO,{'782820','Condutor de ve�culos a pedais'})
aAdd(aCBO,{'783110','Manobrador'})
aAdd(aCBO,{'783105','Agente de p�tio'})
aAdd(aCBO,{'783205','Carregador (aeronaves)'})
aAdd(aCBO,{'783225','Ajudante de motorista'})
aAdd(aCBO,{'783230','Bloqueiro (trabalhador portu�rio)'})
aAdd(aCBO,{'783220','Estivador'})
aAdd(aCBO,{'783215','Carregador (ve�culos de transportes terrestres)'})
aAdd(aCBO,{'783210','Carregador (armaz�m)'})
aAdd(aCBO,{'784125','Operador de prensa de enfardamento'})
aAdd(aCBO,{'784120','Operador de m�quina de envasar l�quidos'})
aAdd(aCBO,{'784115','Operador de m�quina de etiquetar'})
aAdd(aCBO,{'784110','Embalador, a m�quina'})
aAdd(aCBO,{'784105','Embalador, a m�o'})
aAdd(aCBO,{'784205','Alimentador de linha de produ��o'})
aAdd(aCBO,{'791105','Artes�o bordador'})
aAdd(aCBO,{'791110','Artes�o ceramista'})
aAdd(aCBO,{'791115','Artes�o com material recicl�vel'})
aAdd(aCBO,{'791120','Artes�o confeccionador de bioj�ias e ecoj�ias'})
aAdd(aCBO,{'791125','Artes�o do couro'})
aAdd(aCBO,{'791160','Artes�o rendeiro'})
aAdd(aCBO,{'791135','Artes�o moveleiro (exceto reciclado)'})
aAdd(aCBO,{'791140','Artes�o tecel�o'})
aAdd(aCBO,{'791145','Artes�o tran�ador'})
aAdd(aCBO,{'791150','Artes�o crocheteiro'})
aAdd(aCBO,{'791155','Artes�o tricoteiro'})
aAdd(aCBO,{'791130','Artes�o escultor'})
aAdd(aCBO,{'810110','Mestre de produ��o qu�mica'})
aAdd(aCBO,{'810105','Mestre (ind�stria petroqu�mica e carboqu�mica)'})
aAdd(aCBO,{'810205','Mestre (ind�stria de borracha e pl�stico)'})
aAdd(aCBO,{'810305','Mestre de produ��o farmac�utica'})
aAdd(aCBO,{'811005','Operador de processos qu�micos e petroqu�micos'})
aAdd(aCBO,{'811010','Operador de sala de controle de instala��es qu�micas, petroqu�micas e afins'})
aAdd(aCBO,{'811105','Moleiro (tratamentos qu�micos e afins)'})
aAdd(aCBO,{'811115','Operador de britadeira (tratamentos qu�micos e afins)'})
aAdd(aCBO,{'811120','Operador de concentra��o'})
aAdd(aCBO,{'811125','Trabalhador da fabrica��o de resinas e vernizes'})
aAdd(aCBO,{'811130','Trabalhador de fabrica��o de tintas'})
aAdd(aCBO,{'811110','Operador de m�quina misturadeira (tratamentos qu�micos e afins)'})
aAdd(aCBO,{'811215','Operador de tratamento qu�mico de materiais radioativos'})
aAdd(aCBO,{'811205','Operador de calcina��o (tratamento qu�mico e afins)'})
aAdd(aCBO,{'811330','Operador de filtro-prensa (tratamentos qu�micos e afins)'})
aAdd(aCBO,{'811335','Operador de filtros de parafina (tratamentos qu�micos e afins)'})
aAdd(aCBO,{'811325','Operador de filtro-esteira (minera��o)'})
aAdd(aCBO,{'811320','Operador de filtro de tambor rotativo (tratamentos qu�micos e afins)'})
aAdd(aCBO,{'811315','Operador de filtro de secagem (minera��o)'})
aAdd(aCBO,{'811310','Operador de explora��o de petr�leo'})
aAdd(aCBO,{'811305','Operador de centrifugadora (tratamentos qu�micos e afins)'})
aAdd(aCBO,{'811410','Destilador de produtos qu�micos (exceto petr�leo)'})
aAdd(aCBO,{'811405','Destilador de madeira'})
aAdd(aCBO,{'811415','Operador de alambique de funcionamento cont�nuo (produtos qu�micos, exceto petr�leo)'})
aAdd(aCBO,{'811420','Operador de aparelho de rea��o e convers�o (produtos qu�micos, exceto petr�leo)'})
aAdd(aCBO,{'811425','Operador de equipamento de destila��o de �lcool'})
aAdd(aCBO,{'811430','Operador de evaporador na destila��o'})
aAdd(aCBO,{'811505','Operador de painel de controle (refina��o de petr�leo)'})
aAdd(aCBO,{'811510','Operador de transfer�ncia e estocagem - na refina��o do petr�leo'})
aAdd(aCBO,{'811610','Operador de carro de apagamento e coque'})
aAdd(aCBO,{'811605','Operador de britador de coque'})
aAdd(aCBO,{'811615','Operador de destila��o e subprodutos de coque'})
aAdd(aCBO,{'811650','Operador de sistema de revers�o (coqueria)'})
aAdd(aCBO,{'811645','Operador de refrigera��o (coqueria)'})
aAdd(aCBO,{'811640','Operador de reator de coque de petr�leo'})
aAdd(aCBO,{'811635','Operador de preserva��o e controle t�rmico'})
aAdd(aCBO,{'811630','Operador de painel de controle'})
aAdd(aCBO,{'811625','Operador de exaustor (coqueria)'})
aAdd(aCBO,{'811620','Operador de enfornamento e desenfornamento de coque'})
aAdd(aCBO,{'811705','Bamburista'})
aAdd(aCBO,{'811710','Calandrista de borracha'})
aAdd(aCBO,{'811770','Moldador de pl�stico por inje��o'})
aAdd(aCBO,{'811775','Trefilador de borracha'})
aAdd(aCBO,{'811760','Moldador de pl�stico por compress�o'})
aAdd(aCBO,{'811725','Confeccionador de velas por imers�o'})
aAdd(aCBO,{'811735','Confeccionador de velas por moldagem'})
aAdd(aCBO,{'811745','Laminador de pl�stico'})
aAdd(aCBO,{'811750','Moldador de borracha por compress�o'})
aAdd(aCBO,{'811715','Confeccionador de pneum�ticos'})
aAdd(aCBO,{'811820','Operador de m�quina de fabrica��o de produtos de higiene e limpeza (sab�o, sabonete, detergente, ab'})
aAdd(aCBO,{'811815','Operador de m�quina de fabrica��o de cosm�ticos'})
aAdd(aCBO,{'811805','Operador de m�quina de produtos farmac�uticos'})
aAdd(aCBO,{'811810','Drageador (medicamentos)'})
aAdd(aCBO,{'812110','Trabalhador da fabrica��o de muni��o e explosivos'})
aAdd(aCBO,{'812105','Pirot�cnico'})
aAdd(aCBO,{'813120','Operador de processo (qu�mica, petroqu�mica e afins)'})
aAdd(aCBO,{'813110','Operador de calandra (qu�mica, petroqu�mica e afins)'})
aAdd(aCBO,{'813105','Cilindrista (petroqu�mica e afins)'})
aAdd(aCBO,{'813125','Operador de produ��o (qu�mica, petroqu�mica e afins)'})
aAdd(aCBO,{'813130','T�cnico de opera��o (qu�mica, petroqu�mica e afins)'})
aAdd(aCBO,{'813115','Operador de extrusora (qu�mica, petroqu�mica e afins)'})
aAdd(aCBO,{'818105','Assistente de laborat�rio industrial'})
aAdd(aCBO,{'818110','Auxiliar de laborat�rio de an�lises f�sico-qu�micas'})
aAdd(aCBO,{'820110','Mestre de aciaria'})
aAdd(aCBO,{'820115','Mestre de alto-forno'})
aAdd(aCBO,{'820120','Mestre de forno el�trico'})
aAdd(aCBO,{'820125','Mestre de lamina��o'})
aAdd(aCBO,{'820105','Mestre de siderurgia'})
aAdd(aCBO,{'820210','Supervisor de fabrica��o de produtos de vidro'})
aAdd(aCBO,{'820205','Supervisor de fabrica��o de produtos cer�micos, porcelanatos e afins'})
aAdd(aCBO,{'821105','Operador de centro de controle'})
aAdd(aCBO,{'821110','Operador de m�quina de sinterizar'})
aAdd(aCBO,{'821205','Forneiro e operador (alto-forno)'})
aAdd(aCBO,{'821215','Forneiro e operador (forno el�trico)'})
aAdd(aCBO,{'821225','Forneiro e operador de forno de redu��o direta'})
aAdd(aCBO,{'821220','Forneiro e operador (refino de metais n�o-ferrosos)'})
aAdd(aCBO,{'821210','Forneiro e operador (conversor a oxig�nio)'})
aAdd(aCBO,{'821255','Soprador de convertedor'})
aAdd(aCBO,{'821250','Operador de desgaseifica��o'})
aAdd(aCBO,{'821245','Operador de �rea de corrida'})
aAdd(aCBO,{'821240','Operador de aciaria (recebimento de gusa)'})
aAdd(aCBO,{'821235','Operador de aciaria (dessulfura��o de gusa)'})
aAdd(aCBO,{'821230','Operador de aciaria (basculamento de convertedor)'})
aAdd(aCBO,{'821325','Operador de laminador de tubos'})
aAdd(aCBO,{'821320','Operador de laminador de metais n�o-ferrosos'})
aAdd(aCBO,{'821315','Operador de laminador de barras a quente'})
aAdd(aCBO,{'821310','Operador de laminador de barras a frio'})
aAdd(aCBO,{'821305','Operador de laminador'})
aAdd(aCBO,{'821330','Operador de montagem de cilindros e mancais'})
aAdd(aCBO,{'821335','Recuperador de guias e cilindros'})
aAdd(aCBO,{'821440','Operador de tesoura mec�nica e m�quina de corte, no acabamento de chapas e metais'})
aAdd(aCBO,{'821435','Operador de jato abrasivo'})
aAdd(aCBO,{'821430','Operador de esc�ria e sucata'})
aAdd(aCBO,{'821425','Operador de cabine de lamina��o (fio-m�quina)'})
aAdd(aCBO,{'821420','Operador de bobinadeira de tiras a quente, no acabamento de chapas e metais'})
aAdd(aCBO,{'821415','Marcador de produtos (sider�rgico e metal�rgico)'})
aAdd(aCBO,{'821410','Escarfador'})
aAdd(aCBO,{'821405','Encarregado de acabamento de chapas e metais (t�mpera)'})
aAdd(aCBO,{'821445','Preparador de sucata e aparas'})
aAdd(aCBO,{'821450','Rebarbador de metal'})
aAdd(aCBO,{'822110','Forneiro de forno-po�o'})
aAdd(aCBO,{'822125','Forneiro de rev�rbero'})
aAdd(aCBO,{'822120','Forneiro de reaquecimento e tratamento t�rmico na metalurgia'})
aAdd(aCBO,{'822115','Forneiro de fundi��o (forno de redu��o)'})
aAdd(aCBO,{'822105','Forneiro de cubil�'})
aAdd(aCBO,{'823130','Preparador de aditivos'})
aAdd(aCBO,{'823125','Preparador de esmaltes (cer�mica)'})
aAdd(aCBO,{'823120','Preparador de barbotina'})
aAdd(aCBO,{'823115','Preparador de massa de argila'})
aAdd(aCBO,{'823110','Preparador de massa (fabrica��o de vidro)'})
aAdd(aCBO,{'823135','Operador de atomizador'})
aAdd(aCBO,{'823105','Preparador de massa (fabrica��o de abrasivos)'})
aAdd(aCBO,{'823215','Forneiro na fundi��o de vidro'})
aAdd(aCBO,{'823210','Extrusor de fios ou fibras de vidro'})
aAdd(aCBO,{'823220','Forneiro no recozimento de vidro'})
aAdd(aCBO,{'823265','Trabalhador na fabrica��o de produtos abrasivos'})
aAdd(aCBO,{'823255','Temperador de vidro'})
aAdd(aCBO,{'823250','Operador de prensa de moldar vidro'})
aAdd(aCBO,{'823245','Operador de m�quina extrusora de varetas e tubos de vidro'})
aAdd(aCBO,{'823240','Operador de m�quina de soprar vidro'})
aAdd(aCBO,{'823235','Operador de banho met�lico de vidro por flutua��o'})
aAdd(aCBO,{'823230','Moldador de abrasivos na fabrica��o de cer�mica, vidro e porcelana'})
aAdd(aCBO,{'823330','Trabalhador da fabrica��o de pedras artificiais'})
aAdd(aCBO,{'823325','Trabalhador da elabora��o de pr�-fabricados (concreto armado)'})
aAdd(aCBO,{'823320','Trabalhador da elabora��o de pr�-fabricados (cimento amianto)'})
aAdd(aCBO,{'823315','Forneiro (materiais de constru��o)'})
aAdd(aCBO,{'823305','Classificador e empilhador de tijolos refrat�rios'})
aAdd(aCBO,{'828105','Oleiro (fabrica��o de telhas)'})
aAdd(aCBO,{'828110','Oleiro (fabrica��o de tijolos)'})
aAdd(aCBO,{'830105','Mestre (ind�stria de celulose, papel e papel�o)'})
aAdd(aCBO,{'831120','Operador de lavagem e depura��o de pasta para fabrica��o de papel'})
aAdd(aCBO,{'831115','Operador de digestor de pasta para fabrica��o de papel'})
aAdd(aCBO,{'831110','Operador de branqueador de pasta para fabrica��o de papel'})
aAdd(aCBO,{'831105','Cilindreiro na prepara��o de pasta para fabrica��o de papel'})
aAdd(aCBO,{'831125','Operador de m�quina de secar celulose'})
aAdd(aCBO,{'832135','Operador de rebobinadeira na fabrica��o de papel e papel�o'})
aAdd(aCBO,{'832120','Operador de m�quina de fabricar papel (fase seca)'})
aAdd(aCBO,{'832115','Operador de m�quina de fabricar papel (fase �mida)'})
aAdd(aCBO,{'832110','Operador de cortadeira de papel'})
aAdd(aCBO,{'832105','Calandrista de papel'})
aAdd(aCBO,{'832125','Operador de m�quina de fabricar papel e papel�o'})
aAdd(aCBO,{'833110','Confeccionador de bolsas, sacos e sacolas e papel, a m�quina'})
aAdd(aCBO,{'833115','Confeccionador de sacos de celofane, a m�quina'})
aAdd(aCBO,{'833120','Operador de m�quina de cortar e dobrar papel�o'})
aAdd(aCBO,{'833125','Operador de prensa de embutir papel�o'})
aAdd(aCBO,{'833105','Cartonageiro, a m�quina'})
aAdd(aCBO,{'833205','Cartonageiro, a m�o (caixas de papel�o)'})
aAdd(aCBO,{'840110','Supervisor da ind�stria de bebidas'})
aAdd(aCBO,{'840105','Supervisor de produ��o da ind�stria aliment�cia'})
aAdd(aCBO,{'840115','Supervisor da ind�stria de fumo'})
aAdd(aCBO,{'840120','Chefe de confeitaria'})
aAdd(aCBO,{'841110','Moleiro de especiarias'})
aAdd(aCBO,{'841115','Operador de processo de moagem'})
aAdd(aCBO,{'841105','Moleiro de cereais (exceto arroz)'})
aAdd(aCBO,{'841205','Moedor de sal'})
aAdd(aCBO,{'841210','Refinador de sal'})
aAdd(aCBO,{'841305','Operador de cristaliza��o na refina��o de a�ucar'})
aAdd(aCBO,{'841310','Operador de equipamentos de refina��o de a��car (processo cont�nuo)'})
aAdd(aCBO,{'841315','Operador de moenda na fabrica��o de a��car'})
aAdd(aCBO,{'841320','Operador de tratamento de calda na refina��o de a��car'})
aAdd(aCBO,{'841484','Trabalhador de prepara��o de pescados (limpeza)'})
aAdd(aCBO,{'841476','Trabalhador de fabrica��o de margarina'})
aAdd(aCBO,{'841472','Refinador de �leo e gordura'})
aAdd(aCBO,{'841468','Preparador de ra��es'})
aAdd(aCBO,{'841464','Prensador de frutas (exceto oleaginosas)'})
aAdd(aCBO,{'841460','Operador de prepara��o de gr�os vegetais (�leos e gorduras)'})
aAdd(aCBO,{'841456','Operador de c�maras frias'})
aAdd(aCBO,{'841448','Lagareiro'})
aAdd(aCBO,{'841444','Hidrogenador de �leos e gorduras'})
aAdd(aCBO,{'841440','Esterilizador de alimentos'})
aAdd(aCBO,{'841432','Desidratador de alimentos'})
aAdd(aCBO,{'841428','Cozinhador de pescado'})
aAdd(aCBO,{'841420','Cozinhador de frutas e legumes'})
aAdd(aCBO,{'841416','Cozinhador de carnes'})
aAdd(aCBO,{'841408','Cozinhador (conserva��o de alimentos)'})
aAdd(aCBO,{'841505','Trabalhador de tratamento do leite e fabrica��o de latic�nios e afins'})
aAdd(aCBO,{'841605','Misturador de caf�'})
aAdd(aCBO,{'841610','Torrador de caf�'})
aAdd(aCBO,{'841615','Moedor de caf�'})
aAdd(aCBO,{'841620','Operador de extra��o de caf� sol�vel'})
aAdd(aCBO,{'841625','Torrador de cacau'})
aAdd(aCBO,{'841630','Misturador de ch� ou mate'})
aAdd(aCBO,{'841740','Vinagreiro'})
aAdd(aCBO,{'841745','Xaropeiro'})
aAdd(aCBO,{'841705','Alambiqueiro'})
aAdd(aCBO,{'841710','Filtrador de cerveja'})
aAdd(aCBO,{'841715','Fermentador'})
aAdd(aCBO,{'841720','Trabalhador de fabrica��o de vinhos'})
aAdd(aCBO,{'841725','Malteiro (germina��o)'})
aAdd(aCBO,{'841730','Cozinhador de malte'})
aAdd(aCBO,{'841735','Dessecador de malte'})
aAdd(aCBO,{'841805','Operador de forno (fabrica��o de p�es, biscoitos e similares)'})
aAdd(aCBO,{'841810','Operador de m�quinas de fabrica��o de doces, salgados e massas aliment�cias'})
aAdd(aCBO,{'841815','Operador de m�quinas de fabrica��o de chocolates e achocolatados'})
aAdd(aCBO,{'842125','Operador de m�quina (fabrica��o de cigarros)'})
aAdd(aCBO,{'842135','Operador de m�quina de prepara��o de mat�ria prima para produ��o de cigarros'})
aAdd(aCBO,{'842120','Auxiliar de processamento de fumo'})
aAdd(aCBO,{'842115','Classificador de fumo'})
aAdd(aCBO,{'842110','Processador de fumo'})
aAdd(aCBO,{'842105','Preparador de melado e ess�ncia de fumo'})
aAdd(aCBO,{'842230','Charuteiro a m�o'})
aAdd(aCBO,{'842225','Celofanista na fabrica��o de charutos'})
aAdd(aCBO,{'842235','Degustador de charutos'})
aAdd(aCBO,{'842205','Preparador de fumo na fabrica��o de charutos'})
aAdd(aCBO,{'842210','Operador de m�quina de fabricar charutos e cigarrilhas'})
aAdd(aCBO,{'842215','Classificador de charutos'})
aAdd(aCBO,{'842220','Cortador de charutos'})
aAdd(aCBO,{'848115','Salsicheiro (fabrica��o de ling�i�a, salsicha e produtos similares)'})
aAdd(aCBO,{'848110','Salgador de alimentos'})
aAdd(aCBO,{'848105','Defumador de carnes e pescados'})
aAdd(aCBO,{'848215','Manteigueiro na fabrica��o de latic�nio'})
aAdd(aCBO,{'848205','Pasteurizador'})
aAdd(aCBO,{'848210','Queijeiro na fabrica��o de latic�nio'})
aAdd(aCBO,{'848305','Padeiro'})
aAdd(aCBO,{'848310','Confeiteiro'})
aAdd(aCBO,{'848315','Masseiro (massas aliment�cias)'})
aAdd(aCBO,{'848325','Trabalhador de fabrica��o de sorvete'})
aAdd(aCBO,{'848405','Degustador de caf�'})
aAdd(aCBO,{'848410','Degustador de ch�'})
aAdd(aCBO,{'848425','Classificador de gr�os'})
aAdd(aCBO,{'848420','Degustador de vinhos ou licores'})
aAdd(aCBO,{'848415','Degustador de derivados de cacau'})
aAdd(aCBO,{'848525','Retalhador de carne'})
aAdd(aCBO,{'848520','Magarefe'})
aAdd(aCBO,{'848505','Abatedor'})
aAdd(aCBO,{'848510','A�ougueiro'})
aAdd(aCBO,{'848515','Desossador'})
aAdd(aCBO,{'848605','Trabalhador do beneficiamento de fumo'})
aAdd(aCBO,{'860105','Supervisor de manuten��o eletromec�nica (utilidades)'})
aAdd(aCBO,{'860115','Supervisor de opera��o el�trica (gera��o, transmiss�o e distribui��o de energia el�trica)'})
aAdd(aCBO,{'860110','Supervisor de opera��o de fluidos (distribui��o, capta��o, tratamento de �gua, gases, vapor)'})
aAdd(aCBO,{'861120','Operador de reator nuclear'})
aAdd(aCBO,{'861115','Operador de central termoel�trica'})
aAdd(aCBO,{'861110','Operador de quadro de distribui��o de energia el�trica'})
aAdd(aCBO,{'861105','Operador de central hidrel�trica'})
aAdd(aCBO,{'861205','Operador de subesta��o'})
aAdd(aCBO,{'862155','Operador de utilidade (produ��o e distribui��o de vapor, g�s, �leo, combust�vel, energia, oxig�nio)'})
aAdd(aCBO,{'862140','Operador de esta��o de bombeamento'})
aAdd(aCBO,{'862130','Operador de compressor de ar'})
aAdd(aCBO,{'862120','Operador de caldeira'})
aAdd(aCBO,{'862115','Operador de bateria de g�s de hulha'})
aAdd(aCBO,{'862110','Maquinista de embarca��es'})
aAdd(aCBO,{'862105','Foguista (locomotivas a vapor)'})
aAdd(aCBO,{'862150','Operador de m�quinas fixas, em geral'})
aAdd(aCBO,{'862205','Operador de esta��o de capta��o, tratamento e distribui��o de �gua'})
aAdd(aCBO,{'862305','Operador de esta��o de tratamento de �gua e efluentes'})
aAdd(aCBO,{'862310','Operador de forno de incinera��o no tratamento de �gua, efluentes e res�duos industriais'})
aAdd(aCBO,{'862405','Operador de instala��o de extra��o, processamento, envasamento e distribui��o de gases'})
aAdd(aCBO,{'862505','Operador de instala��o de refrigera��o'})
aAdd(aCBO,{'862510','Operador de refrigera��o com am�nia'})
aAdd(aCBO,{'862515','Operador de instala��o de ar-condicionado'})
aAdd(aCBO,{'910110','Supervisor de manuten��o de aparelhos t�rmicos, de climatiza��o e de refrigera��o'})
aAdd(aCBO,{'910130','Supervisor de manuten��o de m�quinas operatrizes e de usinagem'})
aAdd(aCBO,{'910125','Supervisor de manuten��o de m�quinas industriais t�xteis'})
aAdd(aCBO,{'910120','Supervisor de manuten��o de m�quinas gr�ficas'})
aAdd(aCBO,{'910105','Encarregado de manuten��o mec�nica de sistemas operacionais'})
aAdd(aCBO,{'910115','Supervisor de manuten��o de bombas, motores, compressores e equipamentos de transmiss�o'})
aAdd(aCBO,{'910205','Supervisor da manuten��o e repara��o de ve�culos leves'})
aAdd(aCBO,{'910210','Supervisor da manuten��o e repara��o de ve�culos pesados'})
aAdd(aCBO,{'910905','Supervisor de reparos linhas f�rreas'})
aAdd(aCBO,{'910910','Supervisor de manuten��o de vias f�rreas'})
aAdd(aCBO,{'911105','Mec�nico de manuten��o de bomba injetora (exceto de ve�culos automotores)'})
aAdd(aCBO,{'911135','Mec�nico de manuten��o de turbocompressores'})
aAdd(aCBO,{'911130','Mec�nico de manuten��o de turbinas (exceto de aeronaves)'})
aAdd(aCBO,{'911125','Mec�nico de manuten��o de redutores'})
aAdd(aCBO,{'911120','Mec�nico de manuten��o de motores diesel (exceto de ve�culos automotores)'})
aAdd(aCBO,{'911115','Mec�nico de manuten��o de compressores de ar'})
aAdd(aCBO,{'911110','Mec�nico de manuten��o de bombas'})
aAdd(aCBO,{'911205','Mec�nico de manuten��o e instala��o de aparelhos de climatiza��o e refrigera��o'})
aAdd(aCBO,{'911310','Mec�nico de manuten��o de m�quinas gr�ficas'})
aAdd(aCBO,{'911305','Mec�nico de manuten��o de m�quinas, em geral'})
aAdd(aCBO,{'911320','Mec�nico de manuten��o de m�quinas t�xteis'})
aAdd(aCBO,{'911315','Mec�nico de manuten��o de m�quinas operatrizes (lavra de madeira)'})
aAdd(aCBO,{'911325','Mec�nico de manuten��o de m�quinas-ferramentas (usinagem de metais)'})
aAdd(aCBO,{'913110','Mec�nico de manuten��o de equipamento de minera��o'})
aAdd(aCBO,{'913105','Mec�nico de manuten��o de aparelhos de levantamento'})
aAdd(aCBO,{'913115','Mec�nico de manuten��o de m�quinas agr�colas'})
aAdd(aCBO,{'913120','Mec�nico de manuten��o de m�quinas de constru��o e terraplenagem'})
aAdd(aCBO,{'914105','Mec�nico de manuten��o de aeronaves, em geral'})
aAdd(aCBO,{'914110','Mec�nico de manuten��o de sistema hidr�ulico de aeronaves (servi�os de pista e hangar)'})
aAdd(aCBO,{'914205','Mec�nico de manuten��o de motores e equipamentos navais'})
aAdd(aCBO,{'914305','Mec�nico de manuten��o de ve�culos ferrovi�rios'})
aAdd(aCBO,{'914420','Mec�nico de manuten��o de tratores'})
aAdd(aCBO,{'914415','Mec�nico de manuten��o de motocicletas'})
aAdd(aCBO,{'914410','Mec�nico de manuten��o de empilhadeiras e outros ve�culos de cargas leves'})
aAdd(aCBO,{'914425','Mec�nico de ve�culos automotores a diesel (exceto tratores)'})
aAdd(aCBO,{'914405','Mec�nico de manuten��o de autom�veis, motocicletas e ve�culos similares'})
aAdd(aCBO,{'915110','T�cnico em manuten��o de hidr�metros'})
aAdd(aCBO,{'915105','T�cnico em manuten��o de instrumentos de medi��o e precis�o'})
aAdd(aCBO,{'915115','T�cnico em manuten��o de balan�as'})
aAdd(aCBO,{'915205','Restaurador de instrumentos musicais (exceto cordas arcadas)'})
aAdd(aCBO,{'915210','Reparador de instrumentos musicais'})
aAdd(aCBO,{'915215','Luthier (restaura��o de cordas arcadas)'})
aAdd(aCBO,{'915305','T�cnico em manuten��o de equipamentos e instrumentos m�dico-hospitalares'})
aAdd(aCBO,{'915405','Reparador de equipamentos fotogr�ficos'})
aAdd(aCBO,{'919105','Lubrificador industrial'})
aAdd(aCBO,{'919115','Lubrificador de embarca��es'})
aAdd(aCBO,{'919110','Lubrificador de ve�culos automotores (exceto embarca��es)'})
aAdd(aCBO,{'919205','Mec�nico de manuten��o de m�quinas cortadoras de grama, ro�adeiras, motosserras e similares'})
aAdd(aCBO,{'919310','Mec�nico de manuten��o de bicicletas e ve�culos similares'})
aAdd(aCBO,{'919305','Mec�nico de manuten��o de aparelhos esportivos e de gin�stica'})
aAdd(aCBO,{'919315','Montador de bicicletas'})
aAdd(aCBO,{'950105','Supervisor de manuten��o el�trica de alta tens�o industrial'})
aAdd(aCBO,{'950110','Supervisor de manuten��o eletromec�nica industrial, comercial e predial'})
aAdd(aCBO,{'950205','Encarregado de manuten��o el�trica de ve�culos'})
aAdd(aCBO,{'950305','Supervisor de manuten��o eletromec�nica'})
aAdd(aCBO,{'951105','Eletricista de manuten��o eletroeletr�nica'})
aAdd(aCBO,{'951305','Instalador de sistemas eletroeletr�nicos de seguran�a'})
aAdd(aCBO,{'951310','Mantenedor de sistemas eletroeletr�nicos de seguran�a'})
aAdd(aCBO,{'953105','Eletricista de instala��es (aeronaves)'})
aAdd(aCBO,{'953110','Eletricista de instala��es (embarca��es)'})
aAdd(aCBO,{'953115','Eletricista de instala��es (ve�culos automotores e m�quinas operatrizes, exceto aeronaves e embarca'})
aAdd(aCBO,{'954105','Eletromec�nico de manuten��o de elevadores'})
aAdd(aCBO,{'954110','Eletromec�nico de manuten��o de escadas rolantes'})
aAdd(aCBO,{'954115','Eletromec�nico de manuten��o de portas autom�ticas'})
aAdd(aCBO,{'954120','Mec�nico de manuten��o de instala��es mec�nicas de edif�cios'})
aAdd(aCBO,{'954125','Operador eletromec�nico'})
aAdd(aCBO,{'954205','Reparador de aparelhos eletrodom�sticos (exceto imagem e som)'})
aAdd(aCBO,{'954210','Reparador de r�dio, tv e som'})
aAdd(aCBO,{'954305','Reparador de equipamentos de escrit�rio'})
aAdd(aCBO,{'991105','Conservador de via permanente (trilhos)'})
aAdd(aCBO,{'991110','Inspetor de via permanente (trilhos)'})
aAdd(aCBO,{'991115','Operador de m�quinas especiais em conserva��o de via permanente (trilhos)'})
aAdd(aCBO,{'991120','Soldador aluminot�rmico em conserva��o de trilhos'})
aAdd(aCBO,{'991205','Mantenedor de equipamentos de parques de divers�es e similares'})
aAdd(aCBO,{'991305','Funileiro de ve�culos (repara��o)'})
aAdd(aCBO,{'991310','Montador de ve�culos (repara��o)'})
aAdd(aCBO,{'991315','Pintor de ve�culos (repara��o)'})
aAdd(aCBO,{'992105','Alinhador de pneus'})
aAdd(aCBO,{'992120','Lavador de pe�as'})
aAdd(aCBO,{'992115','Borracheiro'})
aAdd(aCBO,{'992110','Balanceador'})
aAdd(aCBO,{'992205','Encarregado geral de opera��es de conserva��o de vias permanentes (exceto trilhos)'})
aAdd(aCBO,{'992220','Pedreiro de conserva��o de vias permanentes (exceto trilhos)'})
aAdd(aCBO,{'992215','Operador de ceifadeira na conserva��o de vias permanentes'})
aAdd(aCBO,{'992210','Encarregado de equipe de conserva��o de vias permanentes (exceto trilhos)'})
aAdd(aCBO,{'992225','Auxiliar geral de conserva��o de vias permanentes (exceto trilhos)'})

//Busca a CBO
If (nPos:=aScan(aCBO,{|x| x[1] == cCBO})) <> 0
	Return aCBO[nPos][2]
EndIf

Return cRet

/*
Funcao      : GrvInfo()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------*
Static Function GrvInfo(cMsg,cDest,cArq)
*--------------------------------------*
Local nHdl := Fopen(cDest+cArq)

FSeek(nHdl,0,2)
FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

/*
Funcao      : GrvErro()
Parametros  : 
Retorno     : 
Objetivos   : Valida se a variavel comporta o erro
Autor       : Jean Victor Rocha
Data/Hora   : 20/07/2015
*/
*----------------------------*
Static Function GrvErro(cErro)
*----------------------------*
Local cRet := ""
If Len(cErro) <= 1024000
	cRet := cErro
EndIf
Return cRet