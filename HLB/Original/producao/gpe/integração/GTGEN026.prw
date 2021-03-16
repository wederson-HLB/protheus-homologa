#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
/*
Funcao      : GTGEN026
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Integração APDATA
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

Private aLegenda := {{"BR_VERDE"	,"Integração Disponivel."},;
						{"BR_LARANJA"	,"Integração Disponivel com Alertas."},;
			   		  	{"BR_VERMELHO"	,"Integração Possui Erros, consulte o console."},;
						{"BR_BRANCO"	,"Sem dados para geração de Arquivo."},;
			   		  	{"BR_PRETO"		,"Integração Inativa."}}

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
//Criação dos Arrays de Definições de layout
For i:=1 to Len(aCodInt)
	&("a"+aCodInt[i]) := GetCodInt(aCodInt[i])
Next i
//Criação das Variaveis de Console
For i:=1 to len(aCodInt)
	&("cCons"+aCodInt[i]) := ""
Next i

oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL - Integração APDATA",,,.F.,,,,,,.T.,,,.T. )

oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',25,.F.,'1')
oLayer:addCollumn('2',75,.F.,'1')

oLayer:addWindow('1','Win11','Menu'					,015,.F.,.T.,{||  },'1',{|| })
oLayer:addWindow('1','Win12','Tipos de Integrações'	,085,.F.,.T.,{||  },'1',{|| })
oLayer:addWindow('2','Win21','Vizualização'			,070,.T.,.F.,{|| RefreshSize()},'1',{|| })
oLayer:addWindow('2','Win22','Console'	   				,030,.T.,.F.,{|| RefreshSize()},'1',{|| })

//Definição das janelas para objeto.
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

//Tipos de Integrações -------------------------------------------------------------
aHeader := {}
aCols	:= {}

AADD(aHeader,{ TRIM("Sel.")			,"SEL","@BMP",02,0,"","","C","",""})
AADD(aHeader,{ TRIM("Sts.")			,"STS","@BMP",02,0,"","","C","",""})
AADD(aHeader,{ TRIM("Integração")	,"DES","@!  ",40,0,"","","C","",""})
AADD(aHeader,{ TRIM("Arq.Dest.")	,"ARQ","@!  ",30,0,"","","C","",""})

aAlter	:= {"SEL","STS"}

aAdd(aCols, {oSelN,oStsBr,"4.1  Bancos"									,"Bancos.txt"						,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.2  Agências Bancárias"						,"AgenciasBanco.txt"				,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.3  CBO"										,"CBO.txt"							,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.4  Cargos"									,"Cargos.txt"						,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.5  Centros de Custo"							,"CentrosCusto.txt"				,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.6  Horários"									,"Horarios.txt"					,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.7  Sindicato"			   						,"Sindicatos.txt"					,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.8  Verbas"			   	   					,"Verbas.txt"	   					,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.9  Meios de transportes"  					,"MeiosTransportes.txt"			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.10 Tipos de Beneficios"   					,"TiposBeneficios.txt"			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.11 Empresas de Beneficios"					,"EmpresasBeneficios.txt"		,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.12 Empresas de Instituições de Ensino"	,"EmpresasEnsino.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.13 Empresas"			   						,"Empresas.txt"					,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.14 Locais"			   						,"Locais.txt"						,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.15 Contratados"			  					,"Contratados.txt"				,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.16 Dependentes"			   					,"ConDependentes.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.17 Histórico de Salários" 					,"ConGradesSalarios.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.18 Histórico de Cargos"	   					,"ConGradesCargos.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.19 Histórico de Centros de Custo"	 		,"ConGradesCentrosCusto.txt"	,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.20 Histórico de Férias"	   		  			,"ConPeriodosDescansos.txt"		,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.21 Histórico de Afastamentos"		  		,"ConAfastamentos.txt" 			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.22 Histórico de Contribuições Sindicais"	,"ConSindicais.txt"	   			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.23 Histórico de Transferências"   			,"ConTransferencias.txt"			,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.24 Pensionistas"				   				,"ConPensionistas.txt" 			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.25 Contratados - Vale Transporte" 			,"ConValesTransportes.txt"		,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.26 Contratados - Benefícios"	   			,"ConBeneficios.txt"	   			,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.27 Dependentes - Benefícios"  	   			,"ConDependentesBeneficios.txt"	,.F.})
aAdd(aCols, {oSelN,oStsIn,"4.28 Contratados - Estabilidades"   			,"ConEstabilidades.txt"	   		,.F.})
aAdd(aCols, {oSelN,oStsBr,"4.29 Ficha Financeira"							,"ConFichaFinanceira.txt"		,.F.})

oGetDados := MsNewGetDados():New(01,01,(oWin12:NHEIGHT/2)-2,(oWin12:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAlter,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin12,aHeader, aCols, {|| MudaLinha()})

oGetDados:AddAction("SEL", {|| MudaStatus()})
oGetDados:AddAction("STS", {|| BrwLegenda("Tipos de Integrações", "Legenda", aLegenda),;
							oGetDados:Obrowse:ColPos -= 1,;
							oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos+1] })
oGetDados:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetDados:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetDados:ForceRefresh()

//Vizualização -------------------------------------------------------------

oBtn4 := TBtnBmp2():New(02,008,26,26,'PGPREV' ,,,,{|| BRWLayout()}	, oWin21,"Ocultar"				,,.T.)
oBtn5 := TBtnBmp2():New(02,210,26,26,'VERNOTA',,,,{|| ViewArq()}	, oWin21,"Vizualizar arquivo"   ,,.T.)

aHLayout := {}
aCLayout := {}
aALayout := {}

AADD(aHLayout,{ TRIM("Campo")  		,"CAMPO","@!",25,0,"","","C","",""})
AADD(aHLayout,{ TRIM("For.")	  	,"FORMA","@!",01,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Tam.")		,"TAMAN","@!",03,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Conteudo")	,"CONTE","@!",50,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Observação")	,"OBSER","@!",60,0,"","","C","",""})
AADD(aHLayout,{ TRIM("Obr.")		,"OBRIG","@!",03,0,"","","C","",""})

oLayout := MsNewGetDados():New(020,01,(oWin21:NHEIGHT/2)-2,(((oWin21:NRIGHT/2)-2)/4),GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aALayout,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin21,aHLayout, aCLayout)

oLayout:LCANEDITLINE	:= .F.//não possibilita troca de tipod e edição.
oLayout:LEDITLINE		:= .F.//Não abre edição quando clicar na linha.
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
	
	&("oArq"+aCodInt[i]):LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
	&("oArq"+aCodInt[i]):LEDITLINE		:= .F.//Não abre edição quando clicar na linha.

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

//Carrega Informações
//LoadDados(.T.)

oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao	    : ViewArq
Parametros  : 
Retorno     : 
Objetivos   : Função para Visualizar o arquivo como ira ficar.
Autor       : Jean Victor Rocha
Data/Hora   : 10/04/2014
*/
*-------------------------*
Static function ViewArq()
*-------------------------*
If oGetDados:ACOLS[oGetDados:NAT][2] <> oStsBr .and. !oArqView:LVISIBLECONTROL
	Processa({|| cArqView := GeraArquivo(&("oArq"+aCodInt[oGetDados:NAT]):ACOLS,.F.,oGetDados:aCols[oGetDados:NAT][4])  },"")
Else
	cArqView := "ATENÇÃO: Não será gerado este arquivo, sem dados!"
EndIf

//Atualiza a Visualização -----------------------------------------
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
	Alert("Nenhuma integração selecionada!","HLB BRASIL")
	Return .T.
EndIf

If !lErro .and. !MsgYesNo("Existe integração Selecionada com erro, Deseja Continuar Assim Mesmo?","HLB BRASIL")
	Return .T.
EndIf

If !File(LEFT(cDirArq,LEN(cDirArq)-1))
	If cDirArq == GETTEMPPATH()+"GPE2APDATA\"
		MakeDir(LEFT(cDirArq,LEN(cDirArq)-1))
		If !File(LEFT(cDirArq,LEN(cDirArq)-1))
   			Alert("Não Foi possivel criar o Diretorio padrão '"+cDirArq+"', operação abortada!","HLB BRASIL")
	   		Return .T.
		EndIf
	Else
		Alert("Diretorio não encontrado '"+cDirArq+"', operação abortada!","HLB BRASIL")
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
Objetivos   : Função Responsavel pela geraçaõ do arquivo
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
		nHdl := FCREATE(cDirArq+cArqTXT,0 )	//Criação do Arquivo .
		FWRITE(nHdl, cRet ) 	   			// Gravação do seu Conteudo.
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
Objetivos   : Função para tratamento de esconder e exibir o layout
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

//Atualiza a Visualização do arquivo
oArqView:nLeft := &("oArq"+aCodInt[1]):oBrowse:nLeft
oArqView:nRight := &("oArq"+aCodInt[1]):oBrowse:nRight 
oArqView:nHeight := &("oArq"+aCodInt[1]):oBrowse:nHeight

Return .T.

/*
Funcao	    : LoadDados()
Parametros  : 
Retorno     : 
Objetivos   : Carrega as informações dos arquivos a serem exportadas, e executa validação.
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
		If !MsgYesNo("Deseja Reprocessar as integrações marcadas?","HLB BRASIL")
			Return .F.
		EndIf
	Else
		Alert("Necessario selecionar no minimo uma integração.","HLB BRASIL")
		Return .F.
	EndIf
EndIf

ProcRegua(Len(aCodInt))

For i:=1 to len(aCodInt)
	IncProc(oGetDados:aCols[i][3])
	If IIF(lProcAll,lProcAll,oGetDados:aCols[i][1] == oSelS)
		If oGetDados:aCols[i][2] == oStsIn
			&("cCons"+aCodInt[i]) := "[INATIVO] Integração Inativa, não será possivel a seleção/geração de arquivo de exportação."
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
	If oGetDados:aCols[i][2] == oStsIn //Nunca seleciona a opção Inativa.
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

//Atualiza a Visualização do Arquivo para não estar exibindo
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
oLayer:setWinTitle('2','Win21','Visualização - '+ALLTRIM(oGetDados:aCols[oGetDados:NAT][3]),'1')
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

//Atualiza a Visualização do arquivo
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
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*--------------------------*
Static Function MudaStatus()
*--------------------------*
Local cArqConte := oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos]
Local aObrigat := {}//Array com as dependencias de integrações.

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
	If oGetDados:aCols[oGetDados:Obrowse:nAt][2] <> oStsIn //Nunca seleciona a opção Inativa.
		cArqConte := oSelS
		//Marca as opções dependentes da integração.
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
Objetivos   : Função para processamento dos Arquivos de integrações e validações.
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'Banco': Não encontrado na Tabela FEBRABAN. Banco:'"+QRY->BANCO+"'"+CHR(13)+CHR(10))

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

	Case cTipoInt == '42'  //Agências Bancárias"
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodBanco': Referencia 4.1 não encontrada. Banco:'"+QRY->BANCO+"'"+CHR(13)+CHR(10))
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
				cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.3 não encontrada. Cargo:'"+TRANSFORM(QRY->RJ_FUNCAO, "@R 9999")+"'"+CHR(13)+CHR(10))
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
		//Adicionado o tratamento para considerar CC para funcionarios que não tiveram transferencias.
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
		
	
	Case cTipoInt == '46'  //Horários"
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
				cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - Tipo de Endereço não definido."+CHR(13)+CHR(10))
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
		//Sem Informações no Sistema

	Case cTipoInt == '410' //Tipos de Beneficios"
		//Sem Informações no Sistema

	Case cTipoInt == '411' //Empresas de Benneficios
		//Sem Informações no Sistema

	Case cTipoInt == '412' //Empresas de Instituições de Ensino"
   		//Sem Informações no Sistema

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
					cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - Tipo de Endereço não definido."+CHR(13)+CHR(10))
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
				cRet := GrvErro(cRet+"[ALERTA]- Empresa '"+QRY->EMP+"' não encontrada no cadastro de empresas."+CHR(13)+CHR(10))
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
				cRet := GrvErro(cRet+"[ALERTA]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - Tipo de Endereço não definido."+CHR(13)+CHR(10))
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
			//Validações
			If aScan(oArq41:aCols,{|x| x[4] == ALLTRIM(TRANSFORM(SubStr(QRY->RA_BCDEPSA,1,3), "@R 999999")) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodBanco': Referencia 4.1 não encontrada. Banco:'"+TRANSFORM(SubStr(QRY->RA_BCDEPSA,1,3), "@R 999999")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq42:aCols,{|x| x[4] == ALLTRIM(TRANSFORM(SubStr(QRY->RA_BCDEPSA,4,99), "@R 999999")) })  == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodAgencia': Referencia 4.2 não encontrada. Ag:'"+TRANSFORM(SubStr(QRY->RA_BCDEPSA,4,99), "@R 999999")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq46:aCols,{|x| x[1] == TRANSFORM(QRY->RA_TNOTRAB, "@R 999") })  == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodHorario': Referencia 4.6 não encontrada. Turno:'"+TRANSFORM(QRY->RA_TNOTRAB, "@R 999")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq47:aCols,{|x| x[1] == TRANSFORM(QRY->RA_SINDICA, "@R 99") }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodSindicato': Referencia 4.7 não encontrada. Sind.:'"+TRANSFORM(QRY->RA_SINDICA, "@R 99")+"'"+CHR(13)+CHR(10))
			EndIf
			If aScan(oArq44:aCols,{|x| x[1] == TRANSFORM(QRY->RA_CODFUNC, "@R 9999") }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.4 não encontrada. Cargo:'"+TRANSFORM(QRY->RA_CODFUNC, "@R 9999")+"'"+CHR(13)+CHR(10))
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
						,;												//80'CnhNúmero'					
						,;												//'CnhVencimento'				
						,;												//'CnhTipo'					
						,;												//'OrgaoEmissorCNH'			
						,;												//'EmissãoCNH'				
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
							0,;											//'Cursando Escola Técnica'
							0,;											//'Guarda Judicial'
							,;											//'Tipo Dependente eSocial'
							.F.})										//Deletado

			If (nPos := aScan(oArq415:aCols,{|x| x[1] == TRANSFORM(QRY->RB_MAT, "@R 999999") })) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.15 não encontrada. Cargo:'"+TRANSFORM(QRY->RB_MAT, "@R 999999")+"'"+CHR(13)+CHR(10))
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

	Case cTipoInt == '417' //Histórico de Salários" 
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.15 não encontrada. Cargo:'"+TRANSFORM(QRY->R3_MAT, "@R 999999")+"'"+CHR(13)+CHR(10))
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

	Case cTipoInt == '418' //Histórico de Cargos"
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
				Case QRY->R7_TIPO == "001"//Admissão
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Não encontrado no arquivo 4.4; Cargo.-> '"+TRANSFORM(QRY->R7_FUNCAO, "@R 9999")+"'"+CHR(13)+CHR(10))
			EndIf
			If (nPos := aScan(oArq415:aCols,{|x| x[1] == TRANSFORM(QRY->R7_MAT, "@R 999999") })) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - 'CodCargo': Referencia 4.15 não encontrada. Cargo:'"+TRANSFORM(QRY->R7_MAT, "@R 999999")+"'"+CHR(13)+CHR(10))
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

	Case cTipoInt == '419' //Histórico de Centros de Custo"
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodCentroCusto: Referencia 4.5 não encontrada. CC='"+TRANSFORM(QRY->RE_CCP, "@R 9999 ")+"'"+CHR(13)+CHR(10)			)
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
	
	Case cTipoInt == '420' //Histórico de Férias"
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 não encontrada. Matricula:'"+TRANSFORM(QRY->RH_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
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

	
	Case cTipoInt == '421' //Histórico de Afastamentos"
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 não encontrada. Matricula:'"+TRANSFORM(QRY->R8_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
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
	
	Case cTipoInt == '422' //Histórico de Contribuições Sindicais"
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 não encontrada. Matricula:'"+TRANSFORM(QRY->RD_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq415:aCols, {|x| x[1] == TRANSFORM(QRY->RD_MAT, "@R 999999")}) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodSindicato: Referencia 4.7 não encontrada. Sind.:'"+TRANSFORM(QRY->RA_SINDICA, "@R 99")+"'"+CHR(13)+CHR(10)			)
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

	Case cTipoInt == '423' //Histórico de Transferências"
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodEmpresa_Origem: Referencia 4.13 não encontrada."+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq414:aCols, {|x| x[1] == STRZERO(ASC(LEFT(QRY->RE_EMPD,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPD,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALD))) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodLocal_Origem: Referencia 4.14 não encontrada."+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq413:aCols, {|x| x[1] == STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodEmpresa_Origem: Referencia 4.13 não encontrada."+CHR(13)+CHR(10)			)
			EndIf
			If aScan(oArq414:aCols, {|x| x[1] == STRZERO(ASC(LEFT(QRY->RE_EMPP,1)),2)+STRZERO(ASC(RIGHT(QRY->RE_EMPP,1)),2)+ALLTRIM(STR(VAL(QRY->RE_FILIALP))) }) == 0
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodLocal_Origem: Referencia 4.14 não encontrada."+CHR(13)+CHR(10)			)
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 não encontrada. Matricula:'"+TRANSFORM(QRY->RQ_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
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
		//Sem Informações no Sistema

	Case cTipoInt == '426' //Contratados - Benefícios"
		//Sem Informações no Sistema

	Case cTipoInt == '427' //Dependentes - Benefícios"  
		//Sem Informações no Sistema

	Case cTipoInt == '428' //Contratados - Estabilidades"   
		//Sem Informações no Sistema
	
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodVerba: Não encontrado referencia em 4.8 - Verba. ->'"+ALLTRIM(QRY->RD_PD)+"'"+CHR(13)+CHR(10))
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
				cRet := GrvErro(cRet+"[ERRO]- "+LEFT(cTipoInt,1)+"."+SUBSTR(cTipoInt,2,99)+" - CodMatricula: Referencia 4.15 não encontrada. Matricula:'"+TRANSFORM(QRY->RD_MAT, "@R 999999")+"'"+CHR(13)+CHR(10)			)
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
Objetivos   : Tela para Explicação da Rotina.
Autor       : Jean Victor Rocha.
Data/Hora   : 10/04/2014
*/
*----------------------*
Static Function IntHelp() 
*----------------------*
oDlgHelp := MSDialog():New( aSize[7],200,aSize[6]-100,aSize[5]-200,"Ajuda - HLB BRASIL - Integração APDATA",,,.F.,,,,,,.T.,,,.T. )
oTree:= DBTree():New(008,008,((aSize[6]-100)/2)-008,((aSize[5]/2)-200)/4,oDlgHelp,{|| GetHelp()},,.T.)
	oTree:AddItem("Integração APDATA"	,"100","UPDINFORMATION" ,,,,1)    
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
		oTree:AddItem("Tipos de Integrações"				,"120", "SDUORDER",,,,2)
			oTree:TreeSeek("120")
			oTree:AddItem("Browse Integrações"				  	,"121", "BMPTABLE",,,,2)
	
	oTree:TreeSeek("100")     
		oTree:AddItem("Visualização "  						,"130", "SDUORDER",,,,2)	      
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

	oTree:TreeSeek("100") // Retorna ao primeiro nível

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
Objetivos   : Atualiza a Descrição do help
Autor       : Jean Victor Rocha.
Data/Hora   : 10/04/2014
*/
*-----------------------*
Static Function GetHelp()
*-----------------------*
Local cRet := ""
Local nPos := 0
Local aHelp := {}

aAdd(aHelp,{"100","Integração APDATA"+CHR(13)+CHR(10)+;
				  "A Equipe de Sistemas da HLB BRASIL desenvolveu a rotina de integração APDATA para facilitar a geração"+;
				  "de arquivos no padrão da APDATA."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				  "Este Help foi disponibilizado a fim de auxiliar na correta utilização e entendimento da rotina, caso não seja respondida as "+;
				  "duvidas, favor entrar em contato com a Equipe de HelpDesk para que possa ser auxiliado."})
aAdd(aHelp,{"110","Janela - Menu"+CHR(13)+CHR(10)+;
				  "A Janela de Menu possui os principais recursos de manutenção da rotina."})
aAdd(aHelp,{"111","Sair"+CHR(13)+CHR(10)+;
				  "O Botão Sair ira encerrar a rotina de integração e retornar para o menu principal do sistema."})
aAdd(aHelp,{"112","Marca/Desmarca todos"+CHR(13)+CHR(10)+;
				  "O Botão Marca/Desmarca todos possibilita a seleção de todas as integrações com um unico clique."})
aAdd(aHelp,{"113","Reprocessa Marcados"+CHR(13)+CHR(10)+;
				  "O Botão Reprocessa Marcados possibilita recarregar as integrações selecionadas."})
aAdd(aHelp,{"114","Diretorio"+CHR(13)+CHR(10)+;
				  "O Botão Diretorio possibilita definir o diretorio para geração dos arquivos da integração."+CHR(13)+CHR(10)+;
				  "Caso não seja informado, sera adotado como padrão a criação de uma pasta no C: com o nome GPE2APDATA."})
aAdd(aHelp,{"115","Gera Arquivos"+CHR(13)+CHR(10)+;
				  "O Botão Gera Arquivos ira processar as integrações selecionadas e gerar os arquivos na pasta informada."+CHR(13)+CHR(10)+;
				  "Em caso de erro na integração esta não permitira a execução da geração."})
aAdd(aHelp,{"116","Help"+CHR(13)+CHR(10)+;
				  "O Botão Help irá apresentar as principais funcionalidades da rotina."})
aAdd(aHelp,{"120","Tipos de Integrações"+CHR(13)+CHR(10)+;
				  "A Janela de possibilita a visualização das integrações disponiveis"})
aAdd(aHelp,{"121","Browse Integrações"+CHR(13)+CHR(10)+;
				  "Apresenta as integrações disponiveis no sistema com base no layout da APDATA."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				  "Opção Marcar: Possibilita a seleção* da integração."+CHR(13)+CHR(10)+;
				  "		*Caso a integração selecionada tenha como dependencia outras integrações, o sistema ira seleciona-las."+CHR(13)+CHR(10)+;
				  "Status: Atraves das cores do status é possivel verificar as integrações. Para maiores informações das cores"+CHR(13)+CHR(10)+;
				  "		Clicar duas vezes sobre qualquer status para ser aberta a janela de Legendas."+CHR(13)+CHR(10)+;
				  "Nome do Arquivo: É possivel verificar na linha da integração o Nome do Arquivo que será gerado."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				  "Obs: Ao posicionar o registro as telas de Visualização e Console serão atualizadas com as informações da Integração Selecionada."})
aAdd(aHelp,{"130","Visualização "+CHR(13)+CHR(10)+;
				  "A Janela de de Visualização possibilita a analise das informações da integração selecionada"})	      
aAdd(aHelp,{"131","Oculta"+CHR(13)+CHR(10)+;
				  "Botão para Ocultar ou expandir o Browse de Layout."})
aAdd(aHelp,{"132","Vizualizar arquivo"+CHR(13)+CHR(10)+;
				  "Botão para troca de forma de visualização para o mesmo formato que irá ficar o arquivo."})
aAdd(aHelp,{"133","Browse Layout"+CHR(13)+CHR(10)+;
				  "Este browse apresenta o layout definido pela APDATA, possibilitando uma analise criteriosa dos dados."})
aAdd(aHelp,{"134","Browse Arquivo"+CHR(13)+CHR(10)+;
				  "Este Browse possibilita a analise dos dados que foram processados, em formato de tabela."})
aAdd(aHelp,{"135","Visualizar Arquivo"+CHR(13)+CHR(10)+;
				  "Esta visualização possibilita a visualização dos dados que foram processados no mesmo formado em que o arquivo será gerado."})
aAdd(aHelp,{"140","Console "+CHR(13)+CHR(10)+;
				  "A Janela de permite a analise de mensagens de processamento."})
aAdd(aHelp,{"141","Visualizar Console"+CHR(13)+CHR(10)+;
				  "Esta visualização permite a analise dos erros gerados."})

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
Objetivos   : Função para retornar a configuração de cada Integração.
Autor       : Jean Victor Rocha
Data/Hora   : 28/03/2014
*/
*---------------------------------*
Static Function GetCodInt(cTipoInt)
*---------------------------------*
Local aRet := {}

Do Case
	Case cTipoInt == '41' //Bancos"
		aAdd(aRet,{'CodBanco'			,'N','09','Código do Banco'								,''											,'Sim',.F.})
		aAdd(aRet,{'Banco'				,'A','32','Nome do Banco'								,''											,'Sim',.F.})
		aAdd(aRet,{'BancoRes'			,'A','16','Nome resumido do banco'						,''											,'Não',.F.})
		aAdd(aRet,{'NuiOficial'			,'N','03','Número oficial do banco'						,''											,'Sim',.F.})
		
	Case cTipoInt == '42' //Agências Bancárias"
		aAdd(aRet,{'CodAgenciaBanco'	,'N','09','Código da agência' 							,''											,'Sim',.F.})
		aAdd(aRet,{'CodBanco'			,'N','09','Código do Banco'	   							,'Código relacionado ao arquivo Bancos.txt'	,'Sim',.F.})
		aAdd(aRet,{'AgenciaBanco'		,'A','32','Descrição da agência'						,''											,'Sim',.F.})
		aAdd(aRet,{'NuiOficial'			,'N','09','Número oficial da agencia'					,''											,'Sim',.F.})
		aAdd(aRet,{'AgenciaDigito'		,'A','02','Dígito da agência'		 					,''											,'Sim',.F.})

	Case cTipoInt == '43' //CBO"
		aAdd(aRet,{'CodCBO'				,'N','09' ,'Código Brasileiro de Ocupação'				,''											,'Sim',.F.})
		aAdd(aRet,{'CBO'				,'A','07' ,'Classificação Brasileira de Ocupações- CBO'	,'Ex.: 9999-99'								,'Sim',.F.})
		aAdd(aRet,{'DsCBO'				,'A','100','Descrição do CBO'							,''											,'Sim',.F.})
		
	Case cTipoInt =='44' //Cargos"
		aAdd(aRet,{'CodCargo'			,'N','09','Código do Cargo'		   	 					,''									 		,'Sim',.F.})
		aAdd(aRet,{'Cargo'	   			,'A','70','Descrição do Cargo'							,''									   		,'Sim',.F.})
		aAdd(aRet,{'CargoRes'  			,'A','32','Descrição Resumo do Cargo'					,''									   		,'Não',.F.})
		aAdd(aRet,{'CodCBO'	   			,'A','09','Codigo do CBO'								,'Código relacionado ao arquivoCBO.txt'		,'Sim',.F.})
		
	Case cTipoInt =='45' //Centros de Custo"
		aAdd(aRet,{'CodCentroCusto'		,'N','09','Código do Centro de Custo'	   	   			,''									   		,'Sim',.F.})
		aAdd(aRet,{'CentroCusto'		,'A','40','Descrição do Centro de Custo'   				,''									   		,'Sim',.F.})
		aAdd(aRet,{'CentroCustoRes'		,'A','20','Descrição Resumo do Centro de Custo'			,''									   		,'Sim',.F.})
		aAdd(aRet,{'Estrutura'			,'A','32','Estrutura do Centro de Custo'   				,''									   		,'Sim',.F.})
		
	Case cTipoInt =='46' //Horários" 
		aAdd(aRet,{'CodHorario'			,'N','09','Código do Horário'							,''									   		,'Sim',.F.})
		aAdd(aRet,{'Horario'			,'A','100','Descrição do Horário'						,''									   		,'Sim',.F.})
		aAdd(aRet,{'QtiHorasSemanal'	,'N','02','Qtde de Horas Semanais'						,''									   		,'Sim',.F.})
		aAdd(aRet,{'QtiHorasMensais'	,'N','03','Qtde de Horas Mensais'						,''									   		,'Sim',.F.})
		aAdd(aRet,{'QtiHorasDia'		,'C','05','Qtde de Horas Diária'						,'Exemplo: 07:33'							,'Sim',.F.})
		
	Case cTipoInt =='47' //Sindicato"
		aAdd(aRet,{'CodSindicato'		,'N','05','Codigo do Sindicato'							,''				 			   				,'Sim',.F.})
		aAdd(aRet,{'Sindicato'			,'A','70','Nome do Sindicato'							,''				 							,'Sim',.F.})
		aAdd(aRet,{'SindicatoResumo'	,'A','25','Nome Resumido do Sindicato'					,''				 							,'Não',.F.})
		aAdd(aRet,{'MesDissidio'		,'N','02','Mês do dissídio'								,''				 							,'Sim',.F.})
		aAdd(aRet,{'CodTipoEndereco'	,'N','03','Código do tipo de Endereço'					,'Tab.De/Para'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endereço Base'		   						,'Ex.: Durval Jose de Barros'				,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','Número do Endereço'							,'Ex.: 162'									,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do Endereço'						,'Ex.: Sala 1'								,'Não',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''				 							,'Sim',.F.})
		aAdd(aRet,{'Cep'				,'N','09','Cep'				   							,'Máscara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Município'		   							,''				   							,'Sim',.F.})
		aAdd(aRet,{'Estado'		   		,'N','02','Id Estado'		  							,'Tab.De/Para'								,'Sim',.F.})
		aAdd(aRet,{'CNPJ'		   		,'N','18','CNPJ do Sindicato'							,'Máscara ##.###.###/####-##'				,'Sim',.F.})
		aAdd(aRet,{'DDDTelefone'   		,'N','2','DDD do Telefone contato'						,'Ex. 11'									,'Não',.F.})
		aAdd(aRet,{'Telefone'	   		,'N','9','Telefone contato'								,'Ex. 1234-5678'							,'Não',.F.})

	Case cTipoInt =='48' //Verbas" 
		aAdd(aRet,{'CodVerba'	   		,'N','09','Código da Verba'								,''			   								,'Sim',.F.})
		aAdd(aRet,{'CodNaturezaVerba'	,'N','02','Código da Natureza da Verba'					,'Tab. De/Para'								,'Sim',.F.})
		aAdd(aRet,{'Verba'	   	   		,'A','40','Descrição da Verba'							,''			   								,'Sim',.F.})
		aAdd(aRet,{'VerbaRes'	   		,'A','16','Descrição Resumo da Verba'					,''			   								,'Não',.F.})
		aAdd(aRet,{'CodTipoVerba'  		,'N','02','Tipo de Verba'				 				,'Tab. De/Para'								,'Sim',.F.})
		aAdd(aRet,{'IncideINSS'	   		,'N','01','Incide INSS'				 					,'0 - Não 1 - Sim'							,'Sim',.F.})
		aAdd(aRet,{'IncideFGTS'	   		,'N','01','Incide FGTS'				 			  		,'0 - Não 1 - Sim'							,'Sim',.F.})
		aAdd(aRet,{'IncideIRRF'	   		,'N','01','Incide IRRF'							  		,'0 - Não 1 - Sim'							,'Sim',.F.})
		
	Case cTipoInt =='49' //Meios de transportes" 
		aAdd(aRet,{'CodMeioTransporte'	,'N','09','Código do Meio de Transporte'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'Descricao'			,'A','70','Descrição do Meio de Transporte'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'ValorTarifa'		,'N','09','Valor da Tarifa'								,'Ex. 2.30'			   						,'Sim',.F.})
		aAdd(aRet,{'DtdVigenciaTarifa'	,'D','10','Data Vigente da Tarifa'						,'Ex. "01/12/2009"'							,'Sim',.F.})
		aAdd(aRet,{'DescMeioMagnetico'	,'A','20','Descrição do Meio Magnético'					,''			   								,'Não',.F.})
		aAdd(aRet,{'DescOperadora'		,'A','20','Descriçaõ da Operadora'						,''			   								,'Não',.F.})
		aAdd(aRet,{'DescTipoBilhete'	,'A','20','Descrição do Tipo de Bilheto'				,''			   								,'Não',.F.})
 
	Case cTipoInt =='410' //Tipos de Beneficios"
		aAdd(aRet,{'CodTipoBeneficio'	,'N','09','Código do Tipo do Benefício Sim'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'Descricao'			,'A','50','Descrição do Tipo do Benefício Sim'			,''			   								,'Sim',.F.})

	Case cTipoInt =='411' //Empresas de Benneficios
		aAdd(aRet,{'CodEmpresaBeneficio','N','05','Código da Empresa Benefício'					,''			   								,'Sim',.F.})
		aAdd(aRet,{'Nome'				,'A','50','Nome da Empresa Benefício'			  		,''			   								,'Sim',.F.})
		aAdd(aRet,{'CNPJ'				,'N','18','CNPJ do Local'								,'Máscara ##.###.###/####-##'				,'Sim',.F.})
		aAdd(aRet,{'TipoEndereco'		,'N','03','Id Tipo de Endereço '						,'Tab DE/PARA'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endereço Base'								,'Ex.: Durval de Barros'					,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','Número do endereço'							,'Ex.: 26'									,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do endereço'						,' Ex.: Fundos'								,'Não',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''			   								,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Município'									,''			   								,'Sim',.F.})
		aAdd(aRet,{'Cep'   				,'N','09','CEP'											,'máscara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'Estado'				,'N','02','Id do Estado'								,'Tab DE/PARA'				  				,'Sim',.F.})
		aAdd(aRet,{'TelefoneDDD'		,'N','02','DDD do telefone'								,'Ex. 11'									,'Nâo',.F.})
		aAdd(aRet,{'TelefoneNum'		,'N','09','Número do telefone'							,' máscara 9999-9999'						,'Nâo',.F.})
		
	Case cTipoInt =='412' //Empresas de Instituições de Ensino"
		aAdd(aRet,{'CodInstEnsino'		,'N','05','Código da Instituição de Ensino'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'Nome'				,'A','50','Nome da Instituição de Ensino'				,''			   								,'Sim',.F.})
		aAdd(aRet,{'CNPJ'				,'N','18','CNPJ do Local'								,'Máscara ##.###.###/####-##'				,'Sim',.F.})
		aAdd(aRet,{'TipoEndereco'		,'N','03','Id Tipo de Endereço'							,'Tab DE/PARA'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endereço Base'								,'Ex.: Durval de Barros'					,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','Número do endereço'							,'Ex.: 26'									,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do endereço'						,' Ex.: Fundos'								,'Não',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''			   								,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Município'									,''			   								,'Sim',.F.})
		aAdd(aRet,{'Cep'				,'N','09','CEP'											,'máscara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'Estado'				,'N','02','Id do Estado'								,'Tab DE/PARA'				  				,'Sim',.F.})
		aAdd(aRet,{'TelefoneDDD'		,'N','02','DDD do telefone'								,'Ex. 11'				  					,'Nâo',.F.})
		aAdd(aRet,{'TelefoneNum'		,'N','09','Número do telefone'							,' máscara 9999-9999'						,'Nâo',.F.})

	Case cTipoInt =='413' //Empresas"
		aAdd(aRet,{'CodEmpresa'			,'N','05','Código da empresa'							,''			   								,'Sim',.F.})
		aAdd(aRet,{'Empresa'			,'A','60','Nome da Empresa'								,''			   								,'Sim',.F.})
	
	Case cTipoInt =='414' //Locais"
		aAdd(aRet,{'CodLocal'  			,'N','05','Código do Local'								,'Matriz ou Filial'							,'Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			,'N','05','Código da Empresa'							,'Cód. relacionado ao arquivo Empresas.txt'	,'Sim',.F.})
		aAdd(aRet,{'Local'				,'A','32','Nome do Local'								,'Matriz ou Filial'					  		,'Sim',.F.})
		aAdd(aRet,{'TipoInscricao'		,'N','01','Id Tipo de Inscrição'						,' 1 - CNPJ 2 - CEI'						,'Sim',.F.})
		aAdd(aRet,{'CNPJ'				,'N','18','CNPJ'										,'Másc ##.###.###/####-##,Conforme campo TipoInscricao','Sim',.F.})
		aAdd(aRet,{'CEI'				,'A','12','Número da matricula CEI do Local'			,'Conforme campo TipoInscricao'				,'Sim',.F.})
		aAdd(aRet,{'CodTipoEndereco'	,'N','03','Id Tipo de Endereço'							,'Tab DE/PARA'								,'Sim',.F.})
		aAdd(aRet,{'EnderecoBase'		,'A','40','Endereço Base'								,''			   								,'Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'		,'A','07','Número do endereço'							,''			   								,'Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'	,'A','20','Complemento do endereço'						,''			   								,'Nâo',.F.})
		aAdd(aRet,{'Bairro'				,'A','25','Bairro'										,''			   								,'Sim',.F.})
		aAdd(aRet,{'Municipio'			,'A','25','Município'									,''			   								,'Sim',.F.})
		aAdd(aRet,{'NusCep'				,'N','09','CEP'											,'máscara 99999-999'						,'Sim',.F.})
		aAdd(aRet,{'CodEstado'			,'N','02','Id do Estado'								,'Tabela complementar - Estados'			,'Sim',.F.})
		aAdd(aRet,{'TelefoneDDD'		,'N','02','DDD do telefone'								,''			   								,'Não',.F.})
		aAdd(aRet,{'TelefoneNum'		,'N','09','Número do telefone'							,'máscara 9999-9999'						,'Não',.F.})
		
	Case cTipoInt =='415' //Contratados"
		aAdd(aRet,{'CodMatricula'  				,'N','09','Matricula do Contratatdo','','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'	   				,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'	   				,'N','05','Local do Contratado','Código relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Nome'		   				,'A','30','Nome do Contratado','','Sim',.F.})
		aAdd(aRet,{'NomeCompleto'  				,'A','60','Nome completo do contratado','','Sim',.F.})
		aAdd(aRet,{'Apelido'   	   				,'A','20','Apelido do Contratado','','Sim',.F.})
		aAdd(aRet,{'NomePai'	   				,'A','60','Nome do Pai do Contratado','','Sim',.F.})
		aAdd(aRet,{'NomeMae'	   				,'A','60','Nome da Mãe do Contratado','','Sim',.F.})
		aAdd(aRet,{'CodSexo'	   				,'N','01','Sexo do Contratado',' 1-M 2-F','Sim',.F.})
		aAdd(aRet,{'Admissao'	   				,'N','10','Data da Admissão do contratado','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'TipoAdmissaoESocial'		,'N','01','Tipo de Admissão eSocial','1 - Admissão. 2 - Transferência de Empresa do Mesmo Grupo Econômico.3 - Admissão por Sucessão, Incorporação ou Fusão.4 - Trabalhador Cedido.','Sim',.F.})
		aAdd(aRet,{'ModoAdmissaoESocial'		,'N','01','Modo de Admissão eSocial','1 - Normal 2 - Decorrente de Ação Fiscal 3 - Decorrente de Decisão Judicial','sim',.F.})
		aAdd(aRet,{'PrazosContrato'				,'N','01','Prazos do Contrato','','Sim',.F.})
		aAdd(aRet,{'CNPJ EmpresaOrigem'			,'N','14','CNPJ Empresa Origem Formato 99.999.999/9999-99 Para admissão por sucessão ou trantransferência d','Formato 99.999.999/9999-99 Para admissão por sucessão ou trantransferência d','Sim',.F.})
		aAdd(aRet,{'MatriculaEmpresaOrigem'		,'A','20','Matrícula Empresa Origem',' Idem CNPJ Empresa Origem.','Sim',.F.})
		aAdd(aRet,{'AdmissaoEmpresaOrigem'		,'D','10','Data Admissão Empresa Origem',' Idem CNPJ Empresa Origem.','Sim',.F.})
		aAdd(aRet,{'CodCentroCusto'				,'N','09','Centro de custo do contratado Relacionado ao CentrosCusto.txt',' Relacionado ao CentrosCusto.txt','Sim',.F.})
		aAdd(aRet,{'CodCargo'	   				,'N','09','Cargo do contratado','Relacionado ao arquivo Cargos.txt. Informar o cargo atual, o mesmo relativo','Sim',.F.})
		aAdd(aRet,{'CodHorario'	  				,'N','09','Código do Horário',' Relacionado ao arquivo Horarios.txt','Sim',.F.})
		aAdd(aRet,{'CodSindicato'				,'N','09','Código do Sindicato','Relacionado ao arquivo Sindicatos.txt','Sim',.F.})
		aAdd(aRet,{'CodCategoria'				,'N','02','Código da Categoria',' Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'CodVinculo'	   				,'N','02','Código do Vínculo',' Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'EMail'			  			,'A','50','E-mail do contratado','','Não',.F.})
		aAdd(aRet,{'EMailPessoal'	  			,'A','50','E-mail Pessoal do Contratado','','Não',.F.})
		aAdd(aRet,{'Salario'	   				,'N','15','Valor do Salário','Máscara ##########,## Informar o salário atual, o mesmo relativo à última alteração do histórico de salários','Sim',.F.})
		aAdd(aRet,{'CodSituacaoSindical'		,'N','01','Situação sindical do contatado',' 1 - Paga Particular 2 - Já Pagou no Ano 3 - Não Pagou no Ano, DeDesconta no Próximo Mês4 - Não Pagou no Ano, Desconta no Mês','Sim',.F.})
		aAdd(aRet,{'CodTipoEmprego'	   			,'N','01','Tipo de emprego para o CAGED','1 - Primeiro Emprego 2 - Re-Emprego 4 - Reintegração em Meses Anteriores','Sim',.F.})
		aAdd(aRet,{'Drt'			  			,'N','09','Número do DRT do contratado','','Não',.F.})
		aAdd(aRet,{'Nascimento'					,'D','10','Data de Nascimento',' Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'OpcaoFGTS'					,'D','10','Data da Opção do FGTS','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodNacionalidade'  			,'N','02','Código da Nacionalidade',' Cod RAIS Ex.10-Brasileira','Sim',.F.})
		aAdd(aRet,{'CodEstado_Naturalidade'		,'N','02','Código do estado de nascimento','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'NascimentoLocal'	   		,'A','35','Município de Nascimento','','Não',.F.})
		aAdd(aRet,{'CodigoMunicipio'			,'N','07','Código do Município de Nascimento',' Conforme tabela de Municípios do IBGE','Sim',.F.})
		aAdd(aRet,{'CodGrauInstrucao'			,'N','02','Código do grau de instrução','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'CodEstadoCivil'	  			,'N','01','Código do estado civil','1 - Solteiro 2 - Casado 3 - Viuvo 4 - Desquitado 5 - Marital 6 - Divorciada 7-Outros','Sim',.F.})
		aAdd(aRet,{'CodCorPele'					,'N','01','Código da cor da pele',' 2 - Branca 4 - Negra 6 - Amarela 1 - Indígena 8 - Parda 9 - Não informada','ada',.F.})
		aAdd(aRet,{'ResidenciaPropria'			,'N','01','Reside em residência própria',' 0 - Não 1 - Sim','Não',.F.})
		aAdd(aRet,{'AquisicaoImovel'			,'N','01','Imóvel adquirido com recursos do FGTS.',' 0 - Não 1 - Sim','Não',.F.})
		aAdd(aRet,{'CodTipoEndereco'			,'N','02','Código do tipo de endereço','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'EnderecoBase'	 			,'A','40','Endereço base','','Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'	 			,'A','07','Número do endereço','','Sim',.F.})
		aAdd(aRet,{'EnderecoComplto'			,'A','20','Complemento do endereço','','Não',.F.})
		aAdd(aRet,{'Bairro'						,'A','25','Bairro','','Sim',.F.})
		aAdd(aRet,{'Municipio'					,'A','35','Município','','Sim',.F.})
		aAdd(aRet,{'CodEstado_Resid'			,'N','02','Código do estado','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'Cep'						,'N','09','Número do CEP','Formato 99999-999','Sim',.F.})
		aAdd(aRet,{'TelefoneDDD_Resid'			,'N','02','DDD do telefone residencial','','Não',.F.})
		aAdd(aRet,{'TelefoneNumero_Resid'		,'N','09','Número do telefone residencial','Formato 9999-9999','Não',.F.})
		aAdd(aRet,{'TelefoneCelularDDD'			,'N','02','DDD do telefone celular','','Não',.F.})
		aAdd(aRet,{'TelefoneCelular'			,'N','09','Número do telefone celular','Formato 9999-9999','Não',.F.})
		aAdd(aRet,{'CPFNumero'					,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'NumeroPis'					,'N','14','Número do PIS','Formato 999.9999.999-9','Sim',.F.})
		aAdd(aRet,{'EmisPis'					,'D','10','Emissão do PIS','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'NumeroCarProf'				,'A','08','Número da carteira profissional','','Sim',.F.})
		aAdd(aRet,{'SerieCarProf'				,'A','08','Série da carteira profissional','','Sim',.F.})
		aAdd(aRet,{'EmisCartProf'				,'D','10','Emissão da carteira profissional','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodEstado_CarProf'			,'N','02','Código do estado da CTPS','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'NumeroRg'					,'A','15','Número do RG','Formato 99.999.999-9','Sim',.F.})
		aAdd(aRet,{'EmisRG'						,'D','10','Data de emissão do RG','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodEstado_OrgaoRg'			,'N','02','Código do estado do RG','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'OrgaoRg'					,'A','06','Orgão emissor do RG','','Sim',.F.})
		aAdd(aRet,{'NumeroRIC'					,'N','12','Número do Registro de Identidade Civil','','Não',.F.})
		aAdd(aRet,{'OrgaoEmissorRIC'			,'A','20','Órgão Emissor do RIC','','Não',.F.})
		aAdd(aRet,{'EmissaoRIC'					,'D','10','Data de Emissão do RIC',' formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'Reservista'					,'A','15','Número da Reservista','','Não',.F.})
		aAdd(aRet,{'NumeroIdentEstrangeiro'		,'A','14','Número da Identidade de Estrang.','','Não',.F.})
		aAdd(aRet,{'OrgaoEmissorIdentEstrang'	,'A','20','Órgão Emissor Ident de Estrangeiro','','Não',.F.})
		aAdd(aRet,{'DataExpedicaoIdentEstrang'	,'D','10','Data Expedição Ident de Estrang',' formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'NumeroDocumentoClasse'		,'A','20','Número Documento de Classe','','Não',.F.})
		aAdd(aRet,{'OrgaoEmissorDocClasse'		,'A','20','Órgão Emissor Doc. de Classe','','Não',.F.})
		aAdd(aRet,{'EmissaoDocClasse'			,'D','10','Data de Emissão Doc. de Classe',' formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'ValidadeDocClasse'			,'D','10','Data Validade Doc. de Classe',' formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'NumeroTitEleitor'			,'A','13','Número do título de eleitor','','Sim',.F.})
		aAdd(aRet,{'SecaoTitEleitor'			,'N','04','Seção do título de eleitor','','Sim',.F.})
		aAdd(aRet,{'ZonaTitEleitor'				,'N','04','Zona do título de eleitor','','Sim',.F.})
		aAdd(aRet,{'MunicipioTitEleitor'		,'A','35','Município do título de eleitor','','Não',.F.})
		aAdd(aRet,{'CodEstadoTitEleitor'		,'N','02','Código do Estado do Titulo de Eleitor','Tab DE/PARA','Sim',.F.})
		aAdd(aRet,{'EmisTitEleitor'				,'D','10','Data de emissão do titulo de eleitor',' Formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'CnhNúmero'					,'N','14','Número da CNH',' Formato 99.999.999.999','Não',.F.})
		aAdd(aRet,{'CnhVencimento'				,'D','10','Data de vencmento da habilitação','Formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'CnhTipo'					,'A','03','Tipo da habilitação',' Ex.: A - Categoria Motos B - Categoria Veículos Leves','Não',.F.})
		aAdd(aRet,{'OrgaoEmissorCNH'			,'A','20','Órgão Emissor da CNH','','Não',.F.})
		aAdd(aRet,{'EmissãoCNH'					,'D','10','Data da Emissão da CNH','Formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'CodBanco'					,'N','09','Código do banco para pagamento do contratado. t','Código relacionado ao arquivo Bancos.tx','Sim',.F.})
		aAdd(aRet,{'CodAgencia'					,'N','09','Código da agência para credito do contratado.','Código relacionado ao arquivo Agencias .txt','Sim',.F.})
		aAdd(aRet,{'PagamentoConta'				,'A','30','Número da conta de pagamento do contratado','','Sim',.F.})
		aAdd(aRet,{'PagamentoContaDigito'		,'A','02','Dígito da conta de pgamento do contratado','','Sim',.F.})
		aAdd(aRet,{'CodExposicaoAgenteNocivo'	,'N','01','Código de exposição do agente nocivo',' Tab DE/PARA','Não',.F.})
		aAdd(aRet,{'Insalubridade'		  		,'N','7,2','Percentual de insalubridade',' Formato 99999.99','Não',.F.})
		aAdd(aRet,{'Periculosidade'				,'N','7,2','Percentual de periculosidade','Formato 99999.99','Não',.F.})
		aAdd(aRet,{'DepSalFamilia'				,'N','02','Número de dependentes para SF','','Sim',.F.})
		aAdd(aRet,{'DepImpRenda'				,'N','02','Número de dependentes para IR','','Sim',.F.})
		aAdd(aRet,{'CodSituacao'				,'N','01','Situação do Contratado','A - Ativo D - Demitido','Sim',.F.})
		aAdd(aRet,{'Rescisao'					,'D','10','Data da rescisão','Somento com situação do contratado for igual a D-Demitido, Fomato DD/MM/AAAA (*1)','Sim',.F.})
		aAdd(aRet,{'RescisaoPagto'				,'D','10','Data do pagamento da rescisão','Somento com situação do contratado for igual a D-Demitido, Formato DD/MM/AAAA ( * 1 )','Sim',.F.})
		aAdd(aRet,{'CodDesligamento'			,'N','02','Código do desligamento',' Somento com situação do contratado for igual a D-Demitido, ( * 1 ) Tab De','Sim',.F.})
		aAdd(aRet,{'Aposentado'					,'N','01','Opção de aposentado',' 0 - Não 1 - Sim','Não',.F.})
		aAdd(aRet,{'Aposentadoria'				,'D','10','Data da aposentadoria','Formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'CodTipoDeficiencia'			,'N','02','Tipos de Deficiência','Tab DE/PARA','Não',.F.})
		aAdd(aRet,{'Naturalizado'				,'N','01','Opção de naturalizado','( * 3 ), Tabela Complementar Tab DE/PARA','Não',.F.})
		aAdd(aRet,{'DataNaturalizacao'			,'D','10','Data de Naturalização','Formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'DtdChegadaPais'				,'D','10','Data de chegada no país',' Formato DD/MM/AAAA ( * 3 )','Não',.F.})
		aAdd(aRet,{'CosTipoVisto'				,'A','02','Código do tipo de visto','( * 3 )','Não',.F.})
		aAdd(aRet,{'NusRNE'						,'A','13','Número do RNE',' ( * 3 )','Não',.F.})
		aAdd(aRet,{'CasadoBrasileira(o)'		,'N','01','Opção de casado com brasileiro(a) caso seja estrangeiro.',' 0 - Não 1 - Sim','Não',.F.})
		aAdd(aRet,{'FilhosBrasileiro'			,'N','01','Tem filho(s) brasileiro caso seja estrangeiro.',' 0 - Não 1 - Sim','Não',.F.})
		aAdd(aRet,{'EnderecoExterior'			,'A','80','Endereço no Exterior','','Não',.F.})
		aAdd(aRet,{'EnderecoExteriorNum'		,'A','10','Número do Endereço no Exterior','','Não',.F.})
		aAdd(aRet,{'EnderecoExteriorCompl'		,'A','20','Complemento Endereço no Exterior','','Não',.F.})
		aAdd(aRet,{'EnderecoExteriorBai'		,'A','30','Bairro do Endereço no Exterior','','Não',.F.})
		aAdd(aRet,{'EnderecoExteriorMunic'		,'A','30','Município do Endereço no Exterior','','Não',.F.})
		aAdd(aRet,{'EnderecoExteriorEstado'		,'A','40','Estado do Endereço no Exterior','Estado ou Província','Não',.F.})
		aAdd(aRet,{'EnderecoExteriorCEP'		,'N','08','CEP do Endereço no Exterior','formato 99999-999','Não',.F.})
		aAdd(aRet,{'EnderecoExteriorPais'		,'N','05','País do Endereço no Exterior','idem Nacionalidades','Não',.F.})
		aAdd(aRet,{'NivelEstagio'				,'N','01','Nível estágio para estagiários','1 - Fundamental 2 - Médio3 - Formação Profissional4 - Superior','Não',.F.})
		aAdd(aRet,{'InstituicaoEnsino'			,'N','05','Código instituição de ensino do estagiário','Relacionado a tabela EmpresasEnsino','Não',.F.})
		aAdd(aRet,{'ApoliceSeguro'				,'A','30','Apólice de Seguro para estagiários','','Não',.F.})
		aAdd(aRet,{'AreaAtuacao'				,'A','50','Área de atuação do estagiário','','Não',.F.})
			
	Case cTipoInt =='416' //Dependentes"
		aAdd(aRet,{'CodDependente'				,'N','09','Código do Dependente','','Sim',.F.})
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Código relacionado ao arquivoContratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do contratado','Código relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Nome'						,'A','60','Nome do dependente','','Sim',.F.})
		aAdd(aRet,{'Nascimento'		   			,'D','10','Data de Nascimento','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'GrauParentesco'				,'N','02','Grau de Parentesco','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodSexo'		   			,'N','01','Código do sexo','1 - M 2 - F','Sim',.F.})
		aAdd(aRet,{'CodGrauInstrucao'			,'N','02','Grau de instrução do dependente','Tab DE/Para','Não',.F.})
		aAdd(aRet,{'CodSituacaoDependente'		,'N','01','Situação do dependente','1 - Normal 2 - Inválido','Sim',.F.})
		aAdd(aRet,{'CodEstadoCivil'		  		,'N','01','Código do estado civil do dependente',' Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'SalarioFamilia'		  		,'N','01','Considerar dependente para Salário Família','0 -Não 1- Sim','Sim',.F.})
		aAdd(aRet,{'ImpRenda'		  			,'N','01','Considerar dependente para Imposto de Renda','0 -Não 1- Sim','Sim',.F.})
		aAdd(aRet,{'VaciniFreqEsc'		  		,'N','01','Vacinação e frequência escolar OK?','0 -Não 1- Sim','Sim',.F.})
		aAdd(aRet,{'CartorioNome'		  		,'A','30','Nome do Cartório','','Não',.F.})
		aAdd(aRet,{'CartorioRegNasc'			,'A','16','Nº da Certidão de Nascimento','','Não',.F.})
		aAdd(aRet,{'CartorioLivroReg'			,'A','16','Nº da livro de Registro','','Não',.F.})
		aAdd(aRet,{'CartorioFolhaReg'			,'A','16','Nº do folha de Registro','','Não',.F.})
		aAdd(aRet,{'DtdCertidaoNasc'			,'D','10','Data da Certidão de Nascimento','formato DD/MM/AAAA','Não',.F.})
		aAdd(aRet,{'CPF Numero'		   			,'N','14','Número do CPF - obrigatório para maiores de 18 anos.','formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CNS Numero'		  			,'N','18','Número do Cartão Nacional de Saúde','','Não',.F.})
		aAdd(aRet,{'Companheiro'		  		,'N','01','É companheiro não casado ha mais de cinco anos.','0 - Não 1 - Sim','Sim',.F.})
		aAdd(aRet,{'Cursando Escola Técnica'	,'N','01','É filho ou enteado Universitário(a) ou cursando escola técnica de 2o.grau, até 24 anos.','0 - Não 1 - Sim','Sim',.F.})
		aAdd(aRet,{'Guarda Judicial'			,'N','01','É irmão, neto ou bisneto sem arrimo dos pais, do qual detenha a guarda judicial.','0 - Não 1 - Sim','Sim',.F.})
		aAdd(aRet,{'Tipo Dependente eSocial'	,'N','01','Tipo de dependente para o eSocial','Tab DE/Para','Não',.F.})

	Case cTipoInt =='417' //Histórico de Salários" 
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do Contratado','Relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Alteracao'			 		,'D','10','Data da Alteração','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'Motivo'			   			,'N','04','Motivo da Alteração','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'VlnSalario'					,'N','12','Valor do Salário','Máscara ##########.##','Sim',.F.})

	Case cTipoInt =='418' //Histórico de Cargos"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do Contratado','Relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Alteracao'					,'D','10','Data da Alteração','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'Motivo'				   		,'N','09','Motivo da Alteração','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodCargo'					,'N','09','Código do Cargo','Código relacionado ao arquivo cargos.txt','Sim',.F.})
	
	Case cTipoInt =='419' //Histórico de Centros de Custo"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Relacionado ao arquivo Contratados.txt','Sim',.F.})
	    aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do Contratado','Relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Alteracao'					,'D','10','Data da Alteração','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'Motivo'						,'N','09','Motivo da Alteração','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodCentroCusto'				,'N','09','Código do Centro de Custo','Código relacionado ao arquivo centroscusto.txt','Sim',.F.})

	Case cTipoInt =='420' //Histórico de Férias"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratatdo.','Código relacionado ao arquivoContratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			   		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do Contratatdo.','Código relacionado ao arquivo locais.txt','Sim',.F.})
		aAdd(aRet,{'PeriodoInicio'				,'D','10','Data de inicio do período aquisitivo','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'PeriodoFim'					,'D','10','Data fim do período aquisitivo','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'StatusPeriodo'				,'N','02','Status do período de férias','01 - Aberto 02 - Liquidado 03 - Anulado','Sim',.F.})
		aAdd(aRet,{'SaidaFerias'				,'D','10','Data do inicio do gozo das férias','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'PagtoFerias'				,'D','10','Data do pagamento das férias','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'AvisoFerias'				,'D','10','Data do aviso de férias','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'DiasFerias'					,'N','06','Qtde de dias gozados de férias Atribuir duas casas decimais','Ex.: 20.00','Sim',.F.})
		aAdd(aRet,{'DiasAbono'					,'N','06','Qtde de dias de abono pecuniário Atribuir duas casas decimais','Ex;: 10.00','Sim',.F.})
		aAdd(aRet,{'Opl13Salario'				,'N','01','Opção de recebimento do 13o. salário','0 - Não 1 - Sim','Sim',.F.})
		aAdd(aRet,{'CodDescanso'				,'N','01','Qual o modo de descanso utilizado para gozo das férias','1 - Normal 2 - Coletiva 3 - Indenizada','Sim',.F.})

	Case cTipoInt =='421' //Histórico de Afastamentos"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do contratado','Código relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			  		,'N','05','Local do contratado','Código relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'AfastamentoInicio'			,'D','10','Data de inicio do afastamento','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'AfastamentoFim'				,'D','10','Data final do afastamento','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodSituacao'				,'N','02','Código do afastamento','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'MotivoSituacaoAcidente'		,'N','01','Código do Motivo','1 - Acidente do trabalho típico 2 - Acidente do trabalho de trajeto','Não',.F.})
		aAdd(aRet,{'MotivoSituacaoDoenca'		,'N','01','Código do Motivo','1 - Doença Relacionada ao trabalho 2 - Doença Não Relacionada ao trabalho','Não',.F.})

	Case cTipoInt =='422' //Histórico de Contribuições Sindicais"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do contratado','Código relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'					,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'					,'N','05','Local do contratado','Código relacionado ao arquivo Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodSindicato'				,'N','09','Código do Sindicato','Código relacionado ao cadastro de Sindicatos','Sim',.F.})
		aAdd(aRet,{'DtContribuicao'				,'D','10','Data da Contribuição','Formato: DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'VlrContribuicao'			,'N','09','Valor da Contribuição','Formato: 999.99','Sim',.F.})

	Case cTipoInt =='423' //Histórico de Transferências"   
		aAdd(aRet,{'CodMatricula_Origem'		,'N','09','Matricula do Contratado','Código relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CodEmpresa_Origem'			,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal_Origem'			,'N','05','Local do Contratado','Código relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'Transferencia'				,'D','10','Data da Transferência','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodMotivo'					,'N','03','Motivos para Transferência','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'CodMatricula_Destino'		,'N','09','Matricula do Contratado','Código relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc_Destino'		,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa_Destino'			,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal_Destino'			,'N','05','Local do Contratado','Código relacionado ao arquivo Locais.txt','Sim',.F.})

	Case cTipoInt =='424' //Pensionistas"
		aAdd(aRet,{'CodPensionista'				,'N','09','Código da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Código relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			   		,'N','05','Local do Contratado','Código relacionado ao arquivo de Locais.txt','Sim',.F.})
		aAdd(aRet,{'NomePensionaista'			,'A','60','Nome da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'RG'			  				,'A','15','RG da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'CPF'			  			,'N','14','CPF da(o) Pensionista','Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'Nascimento'			 		,'D','10','Data de Nascimento da(o) Pensionista','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'CodBanco'			 		,'N','09','Código do Banco para pagamento','Código relacionado ao arquivo de Bancos.txt','Não',.F.})
		aAdd(aRet,{'CodAgencia'			  		,'N','09','Código da Agência para pagamento','Código relacionado ao arquivo de Agencias.txt','Não',.F.})
		aAdd(aRet,{'ContaPagamento'				,'A','30','Conta para pagamento','','Não',.F.})
		aAdd(aRet,{'DigitoContaPagamento'		,'A','10','Digito da conta para pagamento','','Não',.F.})
		aAdd(aRet,{'CodSexo'			  		,'N','02','Código do sexo','1 - M 2 - F','Sim',.F.})
		aAdd(aRet,{'CodTipoendereco'			,'N','02','Código do tipo de Endereço','Tab DE/Para','Não',.F.})
		aAdd(aRet,{'EnderecoBase'				,'A','40','Endereço base da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'EnderecoNumero'				,'A','07','Endereço número da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'EnderecoCompl'				,'A','20','Endereço complemento da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'Bairro'			 			,'A','25','Bairro da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'Municipio'			 		,'A','08','Municipio da(o) Pensionista','','Sim',.F.})
		aAdd(aRet,{'Estado'			 			,'A','04','Estado da(o) Pensionista','Tab DE/Para','Sim',.F.})
		aAdd(aRet,{'Cep'			  			,'A','08','Cep da(o) Pensionista','Formato 9999-999','Sim',.F.})
		aAdd(aRet,{'Telefne'			 		,'A','09','Telefone da(o) Pensionista','Formato 9999-9999','Não',.F.})

	Case cTipoInt =='425' //Contratados - Vale Transporte" 
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Código relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			 		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			   		,'N','05','Local do Contratado','Código relacionado ao arquivo de Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodMeioTransporte'			,'N','09','Código do Meio de Transporte','Código relacionado ao arquivo de MeiosTransporte.txt','Sim',.F.})
		aAdd(aRet,{'QtdPassesporDia'			,'N','02','Quantidade de passes utilizados por dia.','','Sim',.F.})
		aAdd(aRet,{'InicioVT'			   		,'D','10','Data de Inicio da utilização do VT.','Formato DD/MM/AAAA','Sim',.F.})

	Case cTipoInt =='426' //Contratados - Benefícios"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Código relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do Contratado','Código relacionado ao arquivo de Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodTipoBeneficio'			,'N','09','Código do benefício','Código relacionado ao arquivo de TiposBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'CodEmpresaBeneficio'		,'N','05','Empresa do benefício','Código relacionado ao arquivo de EmpresasBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'Valor'			  			,'N','10','Valor referente ao benefício','Ex.: 99.99','Sim',.F.})
		aAdd(aRet,{'Inicio'			  			,'D','10','Data de Inicio do beneficio','Formato DD/MM/AAAA','Sim',.F.})

	Case cTipoInt =='427' //Dependentes - Benefícios"  
		aAdd(aRet,{'CodDependente'				,'N','09','Dependente do Contratado','Código relacionado ao arquivo de Dependentes.txt','Sim',.F.})
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do Contratado','Código relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			  		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			   		,'N','05','Local do Contratado','Código relacionado ao arquivo de Locias.txt','Sim',.F.})
		aAdd(aRet,{'CodTipoBeneficio'	  		,'N','09','Código do benefício','Código relacionado ao arquivo de TiposBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'CodEmpresaBeneficio'		,'N','05','Empresa do benefício','Código relacionado ao arquivo de EmpresasBeneficios.txt','Sim',.F.})
		aAdd(aRet,{'Valor'			  			,'N','10','Valor referente ao benefício','Ex.: 99.99','Sim',.F.})
		aAdd(aRet,{'Inicio'			   			,'D','10','Data de Inicio do beneficio','Formato DD/MM/AAAA','Sim',.F.})

	Case cTipoInt =='428' //Contratados - Estabilidades"   
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do contratado','Código relacionado ao arquivo Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			 		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do contratado','Código relacionado ao arquivo Locais.txt','Sim',.F.})
		aAdd(aRet,{'EstabilidadeInicio'			,'D','10','Data de inicio da estabilidade','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'EstabilidadeFim'			,'D','10','Data final da estabilidade','Formato DD/MM/AAAA','Sim',.F.})
		aAdd(aRet,{'TipoEstabilidade'			,'N','02','Código do tipo de estabilidade','Tab DE/Para','Sim',.F.})
	
	Case cTipoInt =='429' //Ficha Financeira"
		aAdd(aRet,{'CodMatricula'				,'N','09','Matricula do funcionário','Código relacionado ao arquivo de Contratados.txt','Sim',.F.})
		aAdd(aRet,{'CPFNumeroFunc'				,'N','14','Número do CPF',' Formato 999.999.999-99','Sim',.F.})
		aAdd(aRet,{'CodEmpresa'			 		,'N','05','Empresa do Contratado','Código relacionado ao arquivo Empresas.txt','Sim',.F.})
		aAdd(aRet,{'CodLocal'			 		,'N','05','Local do Contratado','Código relacionado ao arquivo de Locais.txt','Sim',.F.})
		aAdd(aRet,{'Mes'			  			,'N','02','Mês de referência','Formato: MM','Sim',.F.})
		aAdd(aRet,{'Ano'			   			,'N','04','Ano de referência','Formato: AAAA','Sim',.F.})
		aAdd(aRet,{'CodVerba'			 		,'N','04','Código da verba','Código relacionado ao arquivo de depara de verbas.','Sim',.F.})
		aAdd(aRet,{'QtdVerba'			  		,'N','8,2','Quantidade de Verbas','Ex.: 0030.00 (30 Dias) 0220.00 (220 Horas) 0047.30 (47 Horas e Meia)','Sim',.F.})
		aAdd(aRet,{'VlnVerba'			 		,'N','11,2','Valor da verba com 11 inteiros e 2 decimais','Formato: 99999.99','Sim',.F.})
		aAdd(aRet,{'DtdVerba'			  		,'D','10','Data de Pagamento','Formato DD/MM/AAAA Informe a data de pagamento, inclusive férias e rescisão.','Sim',.F.})
		aAdd(aRet,{'CodDependente'				,'N','09','Dependente do Contratado (*1)','Código relacionado ao arquivo Dependentes.txt','Não',.F.})
		aAdd(aRet,{'CodTipoBeneficio'			,'N','09','Código do Beneficio (*1)','Código relacionado ao arquivo TiposBeneficios.txt','Não',.F.})
		aAdd(aRet,{'CodEmpresaBeneficio'		,'N','05','Empresa do Beneficio (*1)','Código relacionado ao arquivo EmpresasBeneficios.txt','Não',.F.})
EndCase

Return aRet

/*
Funcao	     : GetSitua()
Parametros  : 
Retorno     : 
Objetivos   : Retorna o Codigo de Situação do Afastamento
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
aAdd(aCodSit,{3 ,7 ,'Afastado por Auxílio-Doença'})
aAdd(aCodSit,{4 ,27,'Reafastado por Auxílio-Doença'})                                            
aAdd(aCodSit,{5 ,23,'Afastado por Licença-Paternidade'})
aAdd(aCodSit,{6 ,5 ,'Afastado em Maternidade'})
aAdd(aCodSit,{7 ,25,'Afastado por Prorrog. Maternidade'})                                                                                                                  
aAdd(aCodSit,{8 ,38,'Afastado por Aborto Não Criminoso'})                                                                                                             
aAdd(aCodSit,{9 ,8 ,'Afastado pelo Serviço Militar'})                                                                                                        
aAdd(aCodSit,{10,61,'Afastado por Mandato Sindical'})                                                                                                   
aAdd(aCodSit,{11,4 ,'Afastado sem Remuneração'})                                                                                                              
//aAdd(aCodSit,{12,,''})                                                                                                                 
//aAdd(aCodSit,{13,,''})                                                                                                                
aAdd(aCodSit,{14,51,'Afastado por Aposentadoria'})                                                                                                                       
//aAdd(aCodSit,{15,,''})                                                                                                                       
//aAdd(aCodSit,{16,,''})                                                                                                                       
aAdd(aCodSit,{17,13,'Cumprimento de Pena de Reclusão'})
aAdd(aCodSit,{99,91,'Afastado por Outros Motivos com Remuneração'})

//Busca Referencia
If (nPos := aScan(aCodSit,{|x| x[1] == nCodSit})) <> 0
	Return aCodSit[nPos][2]
EndIf

Return nRet

/*
Funcao	    : GetNameBank()
Parametros  : 
Retorno     : 
Objetivos   : Retorna as Informeções da Rescisão
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
					xRet := 7// - Término de Contrato - Prazo Determinado
				Case DEM->RG_TIPORES == "05"//Rescisao Pro Labore
					xRet := 23// - Outros
				OtherWise
					xRet := 23// - Outros
			EndCase
	EndCase
ElseIf cTipo == "COD"
	xRet := 23// - Transferência sem Ônus p/ Cedente (sem Rescisão)
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
aAdd(aFebraban,{'003','Banco da Amazônia S.A.',''})
aAdd(aFebraban,{'004','Banco do Nordeste do Brasil S.A.',''})
aAdd(aFebraban,{'012','Banco Standard de Investimentos S.A.',''})
aAdd(aFebraban,{'014','Natixis Brasil S.A. Banco Múltiplo',''})
aAdd(aFebraban,{'018','Banco Tricury S.A.',''})
aAdd(aFebraban,{'019','Banco Azteca do Brasil S.A.',''})
aAdd(aFebraban,{'021','BANESTES S.A. Banco do Estado do Espírito Santo',''})
aAdd(aFebraban,{'024','Banco de Pernambuco S.A. - BANDEPE',''})
aAdd(aFebraban,{'025','Banco Alfa S.A.',''})
aAdd(aFebraban,{'029','Banco Banerj S.A.',''})
aAdd(aFebraban,{'031','Banco Beg S.A.',''})
aAdd(aFebraban,{'033','Banco Santander (Brasil) S.A.',''})
aAdd(aFebraban,{'036','Banco Bradesco BBI S.A.',''})
aAdd(aFebraban,{'037','Banco do Estado do Pará S.A.',''})
aAdd(aFebraban,{'039','Banco do Estado do Piauí S.A. - BEP',''})
aAdd(aFebraban,{'040','Banco Cargill S.A.',''})
aAdd(aFebraban,{'041','Banco do Estado do Rio Grande do Sul S.A.',''})
aAdd(aFebraban,{'044','Banco BVA S.A.',''})
aAdd(aFebraban,{'045','Banco Opportunity S.A.',''})
aAdd(aFebraban,{'047','Banco do Estado de Sergipe S.A.',''})
aAdd(aFebraban,{'062','Hipercard Banco Múltiplo S.A.',''})
aAdd(aFebraban,{'063','Banco Ibi S.A. Banco Múltiplo',''})
aAdd(aFebraban,{'064','Goldman Sachs do Brasil Banco Múltiplo S.A.',''})
aAdd(aFebraban,{'065','Banco Bracce S.A.',''})
aAdd(aFebraban,{'066','Banco Morgan Stanley S.A.',''})
aAdd(aFebraban,{'069','BPN Brasil Banco Múltiplo S.A.',''})
aAdd(aFebraban,{'070','BRB - Banco de Brasília S.A.',''})
aAdd(aFebraban,{'072','Banco Rural Mais S.A.',''})
aAdd(aFebraban,{'073','BB Banco Popular do Brasil S.A.',''})
aAdd(aFebraban,{'074','Banco J. Safra S.A.',''})
aAdd(aFebraban,{'075','Banco ABN AMRO S.A.',''})
aAdd(aFebraban,{'076','Banco KDB S.A.',''})
aAdd(aFebraban,{'078','BES Investimento do Brasil S.A.-Banco de Investimento',''})
aAdd(aFebraban,{'079','Banco Original do Agronegócio S.A.',''})
aAdd(aFebraban,{'084','Unicred Norte do Paraná',''})
aAdd(aFebraban,{'095','Banco Confidence de Câmbio S.A.',''})
aAdd(aFebraban,{'096','Banco BM&FBOVESPA de Serviços de Liquidação e Custódia S.A',''})
aAdd(aFebraban,{'104','Caixa Econômica Federal',''})
aAdd(aFebraban,{'107','Banco BBM S.A.',''})
aAdd(aFebraban,{'119','Banco Western Union do Brasil S.A.',''})
aAdd(aFebraban,{'125','Brasil Plural S.A. - Banco Múltiplo',''})
aAdd(aFebraban,{'168','HSBC Finance (Brasil) S.A. - Banco Múltiplo',''})
aAdd(aFebraban,{'184','Banco Itaú BBA S.A.',''})
aAdd(aFebraban,{'204','Banco Bradesco Cartões S.A.',''})
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
aAdd(aFebraban,{'230','Unicard Banco Múltiplo S.A.',''})
aAdd(aFebraban,{'233','Banco Cifra S.A.',''})
aAdd(aFebraban,{'237','Banco Bradesco S.A.',''})
aAdd(aFebraban,{'241','Banco Clássico S.A.',''})
aAdd(aFebraban,{'243','Banco Máxima S.A.',''})
aAdd(aFebraban,{'246','Banco ABC Brasil S.A.',''})
aAdd(aFebraban,{'248','Banco Boavista Interatlântico S.A.',''})
aAdd(aFebraban,{'249','Banco Investcred Unibanco S.A.',''})
aAdd(aFebraban,{'250','BCV - Banco de Crédito e Varejo S.A.',''})
aAdd(aFebraban,{'254','Paraná Banco S.A.',''})
aAdd(aFebraban,{'263','Banco Cacique S.A.',''})
aAdd(aFebraban,{'265','Banco Fator S.A.',''})
aAdd(aFebraban,{'266','Banco Cédula S.A.',''})
aAdd(aFebraban,{'300','Banco de La Nacion Argentina',''})
aAdd(aFebraban,{'318','Banco BMG S.A.',''})
aAdd(aFebraban,{'320','Banco Industrial e Comercial S.A.',''})
aAdd(aFebraban,{'341','Itaú Unibanco S.A.',''})
aAdd(aFebraban,{'356','Banco Real S.A.',''})
aAdd(aFebraban,{'366','Banco Société Générale Brasil S.A.',''})
aAdd(aFebraban,{'370','Banco Mizuho do Brasil S.A.',''})
aAdd(aFebraban,{'376','Banco J. P. Morgan S.A.',''})
aAdd(aFebraban,{'389','Banco Mercantil do Brasil S.A.',''})
aAdd(aFebraban,{'394','Banco Bradesco Financiamentos S.A.',''})
aAdd(aFebraban,{'394','Banco Finasa BMC S.A.',''})
aAdd(aFebraban,{'399','HSBC Bank Brasil S.A. - Banco Múltiplo',''})
aAdd(aFebraban,{'409','UNIBANCO - União de Bancos Brasileiros S.A.',''})
aAdd(aFebraban,{'412','Banco Capital S.A.',''})
aAdd(aFebraban,{'422','Banco Safra S.A.',''})
aAdd(aFebraban,{'453','Banco Rural S.A.',''})
aAdd(aFebraban,{'456','Banco de Tokyo-Mitsubishi UFJ Brasil S.A.',''})
aAdd(aFebraban,{'464','Banco Sumitomo Mitsui Brasileiro S.A.',''})
aAdd(aFebraban,{'473','Banco Caixa Geral - Brasil S.A.',''})
aAdd(aFebraban,{'477','Citibank S.A.',''})
aAdd(aFebraban,{'479','Banco ItaúBank S.A',''})
aAdd(aFebraban,{'487','Deutsche Bank S.A. - Banco Alemão',''})
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
aAdd(aFebraban,{'613','Banco Pecúnia S.A.',''})
aAdd(aFebraban,{'623','Banco Panamericano S.A.',''})
aAdd(aFebraban,{'626','Banco Ficsa S.A.',''})
aAdd(aFebraban,{'630','Banco Intercap S.A.',''})
aAdd(aFebraban,{'633','Banco Rendimento S.A.',''})
aAdd(aFebraban,{'634','Banco Triângulo S.A.',''})
aAdd(aFebraban,{'637','Banco Sofisa S.A.',''})
aAdd(aFebraban,{'638','Banco Prosper S.A.',''})
aAdd(aFebraban,{'641','Banco Alvorada S.A.',''})
aAdd(aFebraban,{'643','Banco Pine S.A.',''})
aAdd(aFebraban,{'652','Itaú Unibanco Holding S.A.',''})
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
aAdd(aFebraban,{'741','Banco Ribeirão Preto S.A.',''})
aAdd(aFebraban,{'743','Banco Semear S.A.',''})
aAdd(aFebraban,{'744','BankBoston N.A.',''})
aAdd(aFebraban,{'745','Banco Citibank S.A.',''})
aAdd(aFebraban,{'746','Banco Modal S.A.',''})
aAdd(aFebraban,{'747','Banco Rabobank International Brasil S.A.',''})
aAdd(aFebraban,{'748','Banco Cooperativo Sicredi S.A.',''})
aAdd(aFebraban,{'749','Banco Simples S.A.',''})
aAdd(aFebraban,{'751','Scotiabank Brasil S.A. Banco Múltiplo',''})
aAdd(aFebraban,{'752','Banco BNP Paribas Brasil S.A.',''})
aAdd(aFebraban,{'753','NBC Bank Brasil S.A. - Banco Múltiplo',''})
aAdd(aFebraban,{'755','Bank of America Merrill Lynch Banco Múltiplo S.A.',''})
aAdd(aFebraban,{'756','Banco Cooperativo do Brasil S.A. - BANCOOB',''})
aAdd(aFebraban,{'757','Banco KEB do Brasil S.A.',''})
aAdd(aFebraban,{'077','Banco Intermedium S.A.',''})
aAdd(aFebraban,{'081','Concórdia Banco S.A.',''})
aAdd(aFebraban,{'082','Banco Topázio S.A.',''})
aAdd(aFebraban,{'083','Banco da China Brasil S.A.',''})
aAdd(aFebraban,{'085','Cooperativa Central de Crédito Urbano-CECRED',''})
aAdd(aFebraban,{'086','OBOE Crédito Financiamento e Investimento S.A.',''})
aAdd(aFebraban,{'087','Cooperativa Unicred Central Santa Catarina',''})
aAdd(aFebraban,{'088','Banco Randon S.A.',''})
aAdd(aFebraban,{'089','Cooperativa de Crédito Rural da Região de Mogiana',''})
aAdd(aFebraban,{'090','Cooperativa Central de Economia e Crédito Mutuo das Unicreds',''})
aAdd(aFebraban,{'091','Unicred Central do Rio Grande do Sul',''})
aAdd(aFebraban,{'092','Brickell S.A. Crédito, financiamento e Investimento',''})
aAdd(aFebraban,{'094','Banco Petra S.A.',''})
aAdd(aFebraban,{'097','Cooperativa Central de Crédito Noroeste Brasileiro Ltda.',''})
aAdd(aFebraban,{'098','CREDIALIANÇA COOPERATIVA DE CRÉDITO RURAL',''})
aAdd(aFebraban,{'099','Cooperativa Central de Economia e Credito Mutuo das Unicreds',''})
aAdd(aFebraban,{'114','Central das Coop. de Economia e Crédito Mutuo do Est. do ES',''})
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
Objetivos   : Retorna o tipo de Endereço de acordo com o layout APDATA.
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
aAdd(aTipos,{33,'Condomínio'})
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
Objetivos   : Retorna Grau de Instrução
Autor       : Jean Victor Rocha.
Data/Hora   : 17/04/2014
*/
*--------------------------------*
Static Function GetInstru(cGrau)
*--------------------------------*
Local nRet := 0
Local aGrau := {}

aAdd(aGrau,{1 ,'10','Analfabeto'})
aAdd(aGrau,{2 ,'20','Educação Básica Incompleta'})
aAdd(aGrau,{3 ,'25','Educação Básica Completa'})
aAdd(aGrau,{4 ,'30','Ensino Fundamental Incompleto'})
aAdd(aGrau,{5 ,'35','Ensino Fundamental Completo'})
aAdd(aGrau,{6 ,'40','Ensino Médio Incompleto'})
aAdd(aGrau,{7 ,'45','Ensino Médio Completo'})
aAdd(aGrau,{8 ,'50','Ensino Superior Incompleto'})
aAdd(aGrau,{9 ,'55','Ensino Superior Completo'})
aAdd(aGrau,{10,'85','Pós-Graduação'})
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
//aAdd(aCodVinc,{4  ,'','Autônomo'})
aAdd(aCodVinc,{5  ,'3','Menor Aprendiz'})
//aAdd(aCodVinc,{6  ,'','Pessoa Jurídica'})
//aAdd(aCodVinc,{7  ,'','Tarefeiro'})
//aAdd(aCodVinc,{8  ,'','Rurícola'})
//aAdd(aCodVinc,{9  ,'','Estagiário'})
//aAdd(aCodVinc,{10 ,'','Pensionista'})
//aAdd(aCodVinc,{11 ,'','Funcionário Público'})
//aAdd(aCodVinc,{12 ,'','Terceirizado'})
//aAdd(aCodVinc,{13 ,'','Trabalhador Avulso'})
//aAdd(aCodVinc,{14 ,'','Trabalhador Não Vinculado ao RGPS, Mas com FGTS'})
aAdd(aCodVinc,{15 ,'1','Diretor Não Empregado com FGTS (Lei 8.036/90)'})
//aAdd(aCodVinc,{16 ,'','Empregado Doméstico'})
//aAdd(aCodVinc,{17 ,'','Autônomo Contr S/Remuner /Cooperativa de Produção'})
//aAdd(aCodVinc,{18 ,'','Transp Aut Contr S/Remun /Cooperativa Trabalho'})
//aAdd(aCodVinc,{19 ,'','Transp Autônomo Contribuição S/Salário-Base'})
//aAdd(aCodVinc,{20 ,'','Transportador Cooperado Cooperativa de Trabalho'})
//aAdd(aCodVinc,{21 ,'','Tempo Parcial - Prazo Indeterminado'})
//aAdd(aCodVinc,{22 ,'','Médico Residente'})
//aAdd(aCodVinc,{23 ,'','Aprendizagem - Lei 25.013'})
//aAdd(aCodVinc,{24 ,'','Tempo Indeterminado'})
//aAdd(aCodVinc,{25 ,'','Programa Nacional de Estagiários'})
//aAdd(aCodVinc,{26 ,'','Trabalho de Temporada'})
//aAdd(aCodVinc,{27 ,'','Trabalho Eventual'})
//aAdd(aCodVinc,{28 ,'','Trabalhador Agrário - Lei 24.248'})
//aAdd(aCodVinc,{29 ,'','Trabalhador da Construção - Lei22250'})
//aAdd(aCodVinc,{30 ,'','Transp Coop Pr Serv Ent Ben Isenta Cota Patronal'})
//aAdd(aCodVinc,{31 ,'','Transp Autônomo Prod Rural PF / Missão Diplomática'})
//aAdd(aCodVinc,{32 ,'','Coop que Presta Serv a Empr Contrat da Coop Trab'})
//aAdd(aCodVinc,{33 ,'','Coop que Pr Serv a Ent Ben Isenta Cota Patronal'})
//aAdd(aCodVinc,{34 ,'','Agente Político'})
//aAdd(aCodVinc,{35 ,'','Serv Público Cargo em Comissão / Cargo Temporário'})
//aAdd(aCodVinc,{36 ,'','Serv Públ Cargo Efet, Magistrado,Min Públ/Tr Cont'})
//aAdd(aCodVinc,{37 ,'','Contr Indiv Missão Diplomática ou Dirig Sindical'})
//aAdd(aCodVinc,{38 ,'','Empregada(o) Doméstica(o)'})

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
aAdd(aIdTpPag,{7  ,'E','Estagiário'})
aAdd(aIdTpPag,{8  ,'C','Comissionado'})
aAdd(aIdTpPag,{14 ,'C','Comissionado Externo'})
aAdd(aIdTpPag,{15 ,'A','Autônomo'})


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
aAdd(aIdEst,{15,'PB','Paraíba'})
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
Objetivos   : Retorna o Nome padrão da CBO de acordo com o  MTE
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
aAdd(aCBO,{'010110','Oficial general do exército'})
aAdd(aCBO,{'010105','Oficial general da aeronáutica'})
aAdd(aCBO,{'010210','Oficial do exército'})
aAdd(aCBO,{'010215','Oficial da marinha'})
aAdd(aCBO,{'010205','Oficial da aeronáutica'})
aAdd(aCBO,{'010315','Praça da marinha'})
aAdd(aCBO,{'010310','Praça do exército'})
aAdd(aCBO,{'010305','Praça da aeronáutica'})
aAdd(aCBO,{'020105','Coronel da polícia militar'})
aAdd(aCBO,{'020110','Tenente-coronel da polícia militar'})
aAdd(aCBO,{'020115','Major da polícia militar'})
aAdd(aCBO,{'020205','Capitão da polícia militar'})
aAdd(aCBO,{'020310','Segundo tenente de polícia militar'})
aAdd(aCBO,{'020305','Primeiro tenente de polícia militar'})
aAdd(aCBO,{'021105','Subtenente da policia militar'})
aAdd(aCBO,{'021110','Sargento da policia militar'})
aAdd(aCBO,{'021205','Cabo da polícia militar'})
aAdd(aCBO,{'021210','Soldado da polícia militar'})
aAdd(aCBO,{'030115','Tenente-coronel bombeiro militar'})
aAdd(aCBO,{'030105','Coronel bombeiro militar'})
aAdd(aCBO,{'030110','Major bombeiro militar'})
aAdd(aCBO,{'030205','Capitão bombeiro militar'})
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
aAdd(aCBO,{'111220','Secretário - executivo'})
aAdd(aCBO,{'111215','Ministro de estado'})
aAdd(aCBO,{'111210','Vice-presidente da república'})
aAdd(aCBO,{'111205','Presidente da república'})
aAdd(aCBO,{'111330','Juiz federal'})
aAdd(aCBO,{'111305','Ministro do supremo tribunal federal'})
aAdd(aCBO,{'111340','Juiz auditor estadual - justiça militar'})
aAdd(aCBO,{'111345','Juiz do trabalho'})
aAdd(aCBO,{'111335','Juiz auditor federal - justiça militar'})
aAdd(aCBO,{'111310','Ministro do superior tribunal de justiça'})
aAdd(aCBO,{'111315','Ministro do superior tribunal militar'})
aAdd(aCBO,{'111320','Ministro do superior tribunal do trabalho'})
aAdd(aCBO,{'111325','Juiz de direito'})
aAdd(aCBO,{'111415','Dirigente do serviço público municipal'})
aAdd(aCBO,{'111410','Dirigente do serviço público estadual e distrital'})
aAdd(aCBO,{'111405','Dirigente do serviço público federal'})
aAdd(aCBO,{'111505','Especialista de políticas públicas e gestão governamental - eppgg'})
aAdd(aCBO,{'111510','Analista de planejamento e orçamento - apo'})
aAdd(aCBO,{'113010','Líder de comunidade caiçara'})
aAdd(aCBO,{'113005','Cacique'})
aAdd(aCBO,{'113015','Membro de liderança quilombola'})
aAdd(aCBO,{'114105','Dirigente de partido político'})
aAdd(aCBO,{'114210','Dirigentes de entidades patronais'})
aAdd(aCBO,{'114205','Dirigentes de entidades de trabalhadores'})
aAdd(aCBO,{'114305','Dirigente e administrador de organização religiosa'})
aAdd(aCBO,{'114405','Dirigente e administrador de organização da sociedade civil sem fins lucrativos'})
aAdd(aCBO,{'121010','Diretor geral de empresa e organizações (exceto de interesse público)'})
aAdd(aCBO,{'121005','Diretor de planejamento estratégico'})
aAdd(aCBO,{'122105','Diretor de produção e operações em empresa agropecuária'})
aAdd(aCBO,{'122110','Diretor de produção e operações em empresa aqüícola'})
aAdd(aCBO,{'122115','Diretor de produção e operações em empresa florestal'})
aAdd(aCBO,{'122120','Diretor de produção e operações em empresa pesqueira'})
aAdd(aCBO,{'122205','Diretor de produção e operações da indústria de transformação, extração mineral e utilidades'})
aAdd(aCBO,{'122305','Diretor de operações de obras pública e civil'})
aAdd(aCBO,{'122405','Diretor de operações comerciais (comércio atacadista e varejista)'})
aAdd(aCBO,{'122520','Turismólogo'})
aAdd(aCBO,{'122515','Diretor de produção e operações de turismo'})
aAdd(aCBO,{'122510','Diretor de produção e operações de hotel'})
aAdd(aCBO,{'122505','Diretor de produção e operações de alimentação'})
aAdd(aCBO,{'122605','Diretor de operações de correios'})
aAdd(aCBO,{'122620','Diretor de operações de serviços de transporte'})
aAdd(aCBO,{'122615','Diretor de operações de serviços de telecomunicações'})
aAdd(aCBO,{'122610','Diretor de operações de serviços de armazenamento'})
aAdd(aCBO,{'122720','Diretor de câmbio e comércio exterior'})
aAdd(aCBO,{'122715','Diretor de crédito rural'})
aAdd(aCBO,{'122710','Diretor de produtos bancários'})
aAdd(aCBO,{'122705','Diretor comercial em operações de intermediação financeira'})
aAdd(aCBO,{'122740','Diretor de leasing'})
aAdd(aCBO,{'122745','Diretor de mercado de capitais'})
aAdd(aCBO,{'122750','Diretor de recuperação de créditos em operações de intermediação financeira'})
aAdd(aCBO,{'122755','Diretor de riscos de mercado'})
aAdd(aCBO,{'122725','Diretor de compliance'})
aAdd(aCBO,{'122735','Diretor de crédito imobiliário'})
aAdd(aCBO,{'122730','Diretor de crédito (exceto crédito imobiliário)'})
aAdd(aCBO,{'123115','Diretor financeiro'})
aAdd(aCBO,{'123105','Diretor administrativo'})
aAdd(aCBO,{'123110','Diretor administrativo e financeiro'})
aAdd(aCBO,{'123210','Diretor de relações de trabalho'})
aAdd(aCBO,{'123205','Diretor de recursos humanos'})
aAdd(aCBO,{'123310','Diretor de marketing'})
aAdd(aCBO,{'123305','Diretor comercial'})
aAdd(aCBO,{'123405','Diretor de suprimentos'})
aAdd(aCBO,{'123410','Diretor de suprimentos no serviço público'})
aAdd(aCBO,{'123605','Diretor de serviços de informática'})
aAdd(aCBO,{'123705','Diretor de pesquisa e desenvolvimento (p&d)'})
aAdd(aCBO,{'123805','Diretor de manutenção'})
aAdd(aCBO,{'131105','Diretor de serviços culturais'})
aAdd(aCBO,{'131110','Diretor de serviços sociais'})
aAdd(aCBO,{'131115','Gerente de serviços culturais'})
aAdd(aCBO,{'131120','Gerente de serviços sociais'})
aAdd(aCBO,{'131205','Diretor de serviços de saúde'})
aAdd(aCBO,{'131215','Tecnólogo em gestão hospitalar'})
aAdd(aCBO,{'131210','Gerente de serviços de saúde'})
aAdd(aCBO,{'131305','Diretor de instituição educacional da área privada'})
aAdd(aCBO,{'131310','Diretor de instituição educacional pública'})
aAdd(aCBO,{'131320','Gerente de serviços educacionais da área pública'})
aAdd(aCBO,{'131315','Gerente de instituição educacional da área privada'})
aAdd(aCBO,{'141105','Gerente de produção e operações aqüícolas'})
aAdd(aCBO,{'141115','Gerente de produção e operações agropecuárias'})
aAdd(aCBO,{'141110','Gerente de produção e operações florestais'})
aAdd(aCBO,{'141120','Gerente de produção e operações pesqueiras'})
aAdd(aCBO,{'141205','Gerente de produção e operações'})
aAdd(aCBO,{'141305','Gerente de produção e operações da construção civil e obras públicas'})
aAdd(aCBO,{'141420','Gerente de operações de serviços de assistência técnica'})
aAdd(aCBO,{'141415','Gerente de loja e supermercado'})
aAdd(aCBO,{'141410','Comerciante varejista'})
aAdd(aCBO,{'141405','Comerciante atacadista'})
aAdd(aCBO,{'141520','Gerente de pensão'})
aAdd(aCBO,{'141525','Gerente de turismo'})
aAdd(aCBO,{'141510','Gerente de restaurante'})
aAdd(aCBO,{'141515','Gerente de bar'})
aAdd(aCBO,{'141505','Gerente de hotel'})
aAdd(aCBO,{'141605','Gerente de operações de transportes'})
aAdd(aCBO,{'141610','Gerente de operações de correios e telecomunicações'})
aAdd(aCBO,{'141615','Gerente de logística (armazenagem e distribuição)'})
aAdd(aCBO,{'141735','Gerente de recuperação de crédito'})
aAdd(aCBO,{'141725','Gerente de crédito imobiliário'})
aAdd(aCBO,{'141730','Gerente de crédito rural'})
aAdd(aCBO,{'141720','Gerente de crédito e cobrança'})
aAdd(aCBO,{'141715','Gerente de câmbio e comércio exterior'})
aAdd(aCBO,{'141710','Gerente de agência'})
aAdd(aCBO,{'141705','Gerente de produtos bancários'})
aAdd(aCBO,{'142105','Gerente administrativo'})
aAdd(aCBO,{'142110','Gerente de riscos'})
aAdd(aCBO,{'142115','Gerente financeiro'})
aAdd(aCBO,{'142120','Tecnólogo em gestão administrativo- financeira'})
aAdd(aCBO,{'142205','Gerente de recursos humanos'})
aAdd(aCBO,{'142210','Gerente de departamento pessoal'})
aAdd(aCBO,{'142305','Gerente comercial'})
aAdd(aCBO,{'142310','Gerente de comunicação'})
aAdd(aCBO,{'142315','Gerente de marketing'})
aAdd(aCBO,{'142320','Gerente de vendas'})
aAdd(aCBO,{'142325','Relações públicas'})
aAdd(aCBO,{'142330','Analista de negócios'})
aAdd(aCBO,{'142335','Analista de pesquisa de mercado'})
aAdd(aCBO,{'142340','Ouvidor'})
aAdd(aCBO,{'142405','Gerente de compras'})
aAdd(aCBO,{'142410','Gerente de suprimentos'})
aAdd(aCBO,{'142415','Gerente de almoxarifado'})
aAdd(aCBO,{'142505','Gerente de rede'})
aAdd(aCBO,{'142520','Gerente de projetos de tecnologia da informação'})
aAdd(aCBO,{'142515','Gerente de produção de tecnologia da informação'})
aAdd(aCBO,{'142525','Gerente de segurança de tecnologia da informação'})
aAdd(aCBO,{'142530','Gerente de suporte técnico de tecnologia da informação'})
aAdd(aCBO,{'142510','Gerente de desenvolvimento de sistemas'})
aAdd(aCBO,{'142535','Tecnólogo em gestão da tecnologia da informação'})
aAdd(aCBO,{'142605','Gerente de pesquisa e desenvolvimento (p&d)'})
aAdd(aCBO,{'142610','Especialista em desenvolvimento de cigarros'})
aAdd(aCBO,{'142705','Gerente de projetos e serviços de manutenção'})
aAdd(aCBO,{'142710','Tecnólogo em sistemas biomédicos'})
aAdd(aCBO,{'201105','Bioengenheiro'})
aAdd(aCBO,{'201110','Biotecnologista'})
aAdd(aCBO,{'201115','Geneticista'})
aAdd(aCBO,{'201220','Especialista em instrumentação metrológica'})
aAdd(aCBO,{'201215','Especialista em ensaios metrológicos'})
aAdd(aCBO,{'201210','Especialista em calibrações metrológicas'})
aAdd(aCBO,{'201225','Especialista em materiais de referência metrológica'})
aAdd(aCBO,{'201205','Pesquisador em metrologia'})
aAdd(aCBO,{'202115','Tecnólogo em mecatrônica'})
aAdd(aCBO,{'202120','Tecnólogo em automação industrial'})
aAdd(aCBO,{'202110','Engenheiro de controle e automação'})
aAdd(aCBO,{'202105','Engenheiro mecatrônico'})
aAdd(aCBO,{'203005','Pesquisador em biologia ambiental'})
aAdd(aCBO,{'203010','Pesquisador em biologia animal'})
aAdd(aCBO,{'203015','Pesquisador em biologia de microorganismos e parasitas'})
aAdd(aCBO,{'203020','Pesquisador em biologia humana'})
aAdd(aCBO,{'203025','Pesquisador em biologia vegetal'})
aAdd(aCBO,{'203115','Pesquisador em física'})
aAdd(aCBO,{'203110','Pesquisador em ciências da terra e meio ambiente'})
aAdd(aCBO,{'203105','Pesquisador em ciências da computação e informática'})
aAdd(aCBO,{'203120','Pesquisador em matemática'})
aAdd(aCBO,{'203125','Pesquisador em química'})
aAdd(aCBO,{'203215','Pesquisador de engenharia elétrica e eletrônica'})
aAdd(aCBO,{'203210','Pesquisador de engenharia e tecnologia (outras áreas da engenharia)'})
aAdd(aCBO,{'203205','Pesquisador de engenharia civil'})
aAdd(aCBO,{'203220','Pesquisador de engenharia mecânica'})
aAdd(aCBO,{'203225','Pesquisador de engenharia metalúrgica, de minas e de materiais'})
aAdd(aCBO,{'203230','Pesquisador de engenharia química'})
aAdd(aCBO,{'203315','Pesquisador em medicina veterinária'})
aAdd(aCBO,{'203310','Pesquisador de medicina básica'})
aAdd(aCBO,{'203305','Pesquisador de clínica médica'})
aAdd(aCBO,{'203320','Pesquisador em saúde coletiva'})
aAdd(aCBO,{'203405','Pesquisador em ciências agronômicas'})
aAdd(aCBO,{'203410','Pesquisador em ciências da pesca e aqüicultura'})
aAdd(aCBO,{'203415','Pesquisador em ciências da zootecnia'})
aAdd(aCBO,{'203420','Pesquisador em ciências florestais'})
aAdd(aCBO,{'203505','Pesquisador em ciências sociais e humanas'})
aAdd(aCBO,{'203510','Pesquisador em economia'})
aAdd(aCBO,{'203515','Pesquisador em ciências da educação'})
aAdd(aCBO,{'203520','Pesquisador em história'})
aAdd(aCBO,{'203525','Pesquisador em psicologia'})
aAdd(aCBO,{'204105','Perito criminal'})
aAdd(aCBO,{'211105','Atuário'})
aAdd(aCBO,{'211120','Matemático aplicado'})
aAdd(aCBO,{'211115','Matemático'})
aAdd(aCBO,{'211110','Especialista em pesquisa operacional'})
aAdd(aCBO,{'211210','Estatístico (estatística aplicada)'})
aAdd(aCBO,{'211215','Estatístico teórico'})
aAdd(aCBO,{'211205','Estatístico'})
aAdd(aCBO,{'212215','Engenheiros de sistemas operacionais em computação'})
aAdd(aCBO,{'212210','Engenheiro de equipamentos em computação'})
aAdd(aCBO,{'212205','Engenheiro de aplicativos em computação'})
aAdd(aCBO,{'212305','Administrador de banco de dados'})
aAdd(aCBO,{'212310','Administrador de redes'})
aAdd(aCBO,{'212320','Administrador em segurança da informação'})
aAdd(aCBO,{'212315','Administrador de sistemas operacionais'})
aAdd(aCBO,{'212410','Analista de redes e de comunicação de dados'})
aAdd(aCBO,{'212415','Analista de sistemas de automação'})
aAdd(aCBO,{'212405','Analista de desenvolvimento de sistemas'})
aAdd(aCBO,{'212420','Analista de suporte computacional'})
aAdd(aCBO,{'213140','Físico (matéria condensada)'})
aAdd(aCBO,{'213170','Físico (plasma)'})
aAdd(aCBO,{'213175','Físico (térmica)'})
aAdd(aCBO,{'213135','Físico (instrumentação)'})
aAdd(aCBO,{'213130','Físico (fluidos)'})
aAdd(aCBO,{'213120','Físico (cosmologia)'})
aAdd(aCBO,{'213115','Físico (atômica e molecular)'})
aAdd(aCBO,{'213165','Físico (partículas e campos)'})
aAdd(aCBO,{'213160','Físico (óptica)'})
aAdd(aCBO,{'213155','Físico (nuclear e reatores)'})
aAdd(aCBO,{'213150','Físico (medicina)'})
aAdd(aCBO,{'213145','Físico (materiais)'})
aAdd(aCBO,{'213125','Físico (estatística e matemática)'})
aAdd(aCBO,{'213110','Físico (acústica)'})
aAdd(aCBO,{'213105','Físico'})
aAdd(aCBO,{'213205','Químico'})
aAdd(aCBO,{'213210','Químico industrial'})
aAdd(aCBO,{'213215','Tecnólogo em processos químicos'})
aAdd(aCBO,{'213315','Meteorologista'})
aAdd(aCBO,{'213305','Astrônomo'})
aAdd(aCBO,{'213310','Geofísico espacial'})
aAdd(aCBO,{'213405','Geólogo'})
aAdd(aCBO,{'213410','Geólogo de engenharia'})
aAdd(aCBO,{'213415','Geofísico'})
aAdd(aCBO,{'213420','Geoquímico'})
aAdd(aCBO,{'213440','Oceanógrafo'})
aAdd(aCBO,{'213435','Petrógrafo'})
aAdd(aCBO,{'213425','Hidrogeólogo'})
aAdd(aCBO,{'213430','Paleontólogo'})
aAdd(aCBO,{'214010','Tecnólogo em meio ambiente'})
aAdd(aCBO,{'214005','Engenheiro ambiental'})
aAdd(aCBO,{'214120','Arquiteto paisagista'})
aAdd(aCBO,{'214115','Arquiteto de patrimônio'})
aAdd(aCBO,{'214110','Arquiteto de interiores'})
aAdd(aCBO,{'214130','Urbanista'})
aAdd(aCBO,{'214105','Arquiteto de edificações'})
aAdd(aCBO,{'214125','Arquiteto urbanista'})
aAdd(aCBO,{'214205','Engenheiro civil'})
aAdd(aCBO,{'214210','Engenheiro civil (aeroportos)'})
aAdd(aCBO,{'214215','Engenheiro civil (edificações)'})
aAdd(aCBO,{'214220','Engenheiro civil (estruturas metálicas)'})
aAdd(aCBO,{'214225','Engenheiro civil (ferrovias e metrovias)'})
aAdd(aCBO,{'214230','Engenheiro civil (geotécnia)'})
aAdd(aCBO,{'214235','Engenheiro civil (hidrologia)'})
aAdd(aCBO,{'214240','Engenheiro civil (hidráulica)'})
aAdd(aCBO,{'214245','Engenheiro civil (pontes e viadutos)'})
aAdd(aCBO,{'214250','Engenheiro civil (portos e vias navegáveis)'})
aAdd(aCBO,{'214255','Engenheiro civil (rodovias)'})
aAdd(aCBO,{'214260','Engenheiro civil (saneamento)'})
aAdd(aCBO,{'214265','Engenheiro civil (túneis)'})
aAdd(aCBO,{'214270','Engenheiro civil (transportes e trânsito)'})
aAdd(aCBO,{'214280','Tecnólogo em construção civil'})
aAdd(aCBO,{'214335','Engenheiro de manutenção de telecomunicações'})
aAdd(aCBO,{'214365','Tecnólogo em eletrônica'})
aAdd(aCBO,{'214340','Engenheiro de telecomunicações'})
aAdd(aCBO,{'214345','Engenheiro projetista de telecomunicações'})
aAdd(aCBO,{'214350','Engenheiro de redes de comunicação'})
aAdd(aCBO,{'214360','Tecnólogo em eletricidade'})
aAdd(aCBO,{'214330','Engenheiro eletrônico de projetos'})
aAdd(aCBO,{'214305','Engenheiro eletricista'})
aAdd(aCBO,{'214310','Engenheiro eletrônico'})
aAdd(aCBO,{'214315','Engenheiro eletricista de manutenção'})
aAdd(aCBO,{'214325','Engenheiro eletrônico de manutenção'})
aAdd(aCBO,{'214320','Engenheiro eletricista de projetos'})
aAdd(aCBO,{'214370','Tecnólogo em telecomunicações'})
aAdd(aCBO,{'214410','Engenheiro mecânico automotivo'})
aAdd(aCBO,{'214415','Engenheiro mecânico (energia nuclear)'})
aAdd(aCBO,{'214420','Engenheiro mecânico industrial'})
aAdd(aCBO,{'214425','Engenheiro aeronáutico'})
aAdd(aCBO,{'214430','Engenheiro naval'})
aAdd(aCBO,{'214435','Tecnólogo em fabricação mecânica'})
aAdd(aCBO,{'214405','Engenheiro mecânico'})
aAdd(aCBO,{'214535','Tecnólogo em produção sulcroalcooleira'})
aAdd(aCBO,{'214525','Engenheiro químico (petróleo e borracha)'})
aAdd(aCBO,{'214520','Engenheiro químico (papel e celulose)'})
aAdd(aCBO,{'214515','Engenheiro químico (mineração, metalurgia, siderurgia, cimenteira e cerâmica)'})
aAdd(aCBO,{'214510','Engenheiro químico (indústria química)'})
aAdd(aCBO,{'214505','Engenheiro químico'})
aAdd(aCBO,{'214530','Engenheiro químico (utilidades e meio ambiente)'})
aAdd(aCBO,{'214615','Tecnólogo em metalurgia'})
aAdd(aCBO,{'214610','Engenheiro metalurgista'})
aAdd(aCBO,{'214605','Engenheiro de materiais'})
aAdd(aCBO,{'214725','Engenheiro de minas (pesquisa mineral)'})
aAdd(aCBO,{'214730','Engenheiro de minas (planejamento)'})
aAdd(aCBO,{'214735','Engenheiro de minas (processo)'})
aAdd(aCBO,{'214740','Engenheiro de minas (projeto)'})
aAdd(aCBO,{'214745','Tecnólogo em petróleo e gás'})
aAdd(aCBO,{'214750','Tecnólogo em rochas ornamentais'})
aAdd(aCBO,{'214720','Engenheiro de minas (lavra subterrânea)'})
aAdd(aCBO,{'214705','Engenheiro de minas'})
aAdd(aCBO,{'214710','Engenheiro de minas (beneficiamento)'})
aAdd(aCBO,{'214715','Engenheiro de minas (lavra a céu aberto)'})
aAdd(aCBO,{'214805','Engenheiro agrimensor'})
aAdd(aCBO,{'214810','Engenheiro cartógrafo'})
aAdd(aCBO,{'214925','Engenheiro de tempos e movimentos'})
aAdd(aCBO,{'214915','Engenheiro de segurança do trabalho'})
aAdd(aCBO,{'214910','Engenheiro de controle de qualidade'})
aAdd(aCBO,{'214905','Engenheiro de produção'})
aAdd(aCBO,{'214930','Tecnólogo em produção industrial'})
aAdd(aCBO,{'214935','Tecnólogo em segurança do trabalho'})
aAdd(aCBO,{'214920','Engenheiro de riscos'})
aAdd(aCBO,{'215135','Inspetor naval'})
aAdd(aCBO,{'215130','Inspetor de terminal'})
aAdd(aCBO,{'215145','Prático de portos da marinha mercante'})
aAdd(aCBO,{'215150','Vistoriador naval'})
aAdd(aCBO,{'215140','Oficial de quarto de navegação da marinha mercante'})
aAdd(aCBO,{'215125','Imediato da marinha mercante'})
aAdd(aCBO,{'215120','Coordenador de operações de combate à poluição no meio aquaviário'})
aAdd(aCBO,{'215115','Comandante da marinha mercante'})
aAdd(aCBO,{'215110','Capitão de manobra da marinha mercante'})
aAdd(aCBO,{'215105','Agente de manobra e docagem'})
aAdd(aCBO,{'215220','Superintendente técnico no transporte aquaviário'})
aAdd(aCBO,{'215215','Segundo oficial de máquinas da marinha mercante'})
aAdd(aCBO,{'215210','Primeiro oficial de máquinas da marinha mercante'})
aAdd(aCBO,{'215205','Oficial superior de máquinas da marinha mercante'})
aAdd(aCBO,{'215315','Instrutor de vôo'})
aAdd(aCBO,{'215310','Piloto de ensaios em vôo'})
aAdd(aCBO,{'215305','Piloto de aeronaves'})
aAdd(aCBO,{'221105','Biólogo'})
aAdd(aCBO,{'221205','Biomédico'})
aAdd(aCBO,{'222120','Engenheiro florestal'})
aAdd(aCBO,{'222115','Engenheiro de pesca'})
aAdd(aCBO,{'222110','Engenheiro agrônomo'})
aAdd(aCBO,{'222105','Engenheiro agrícola'})
aAdd(aCBO,{'222205','Engenheiro de alimentos'})
aAdd(aCBO,{'222215','Tecnólogo em alimentos'})
aAdd(aCBO,{'223293','Cirurgião-dentista da estratégia de saúde da família'})
aAdd(aCBO,{'223288','Cirurgião dentista - odontologia para pacientes com necessidades especiais'})
aAdd(aCBO,{'223284','Cirurgião dentista - disfunção temporomandibular e dor orofacial'})
aAdd(aCBO,{'223276','Cirurgião dentista - odontologia do trabalho'})
aAdd(aCBO,{'223280','Cirurgião dentista - dentística'})
aAdd(aCBO,{'223272','Cirurgião dentista de saúde coletiva'})
aAdd(aCBO,{'223204','Cirurgião dentista - auditor'})
aAdd(aCBO,{'223208','Cirurgião dentista - clínico geral'})
aAdd(aCBO,{'223212','Cirurgião dentista - endodontista'})
aAdd(aCBO,{'223216','Cirurgião dentista - epidemiologista'})
aAdd(aCBO,{'223220','Cirurgião dentista - estomatologista'})
aAdd(aCBO,{'223224','Cirurgião dentista - implantodontista'})
aAdd(aCBO,{'223228','Cirurgião dentista - odontogeriatra'})
aAdd(aCBO,{'223232','Cirurgião dentista - odontologista legal'})
aAdd(aCBO,{'223236','Cirurgião dentista - odontopediatra'})
aAdd(aCBO,{'223240','Cirurgião dentista - ortopedista e ortodontista'})
aAdd(aCBO,{'223244','Cirurgião dentista - patologista bucal'})
aAdd(aCBO,{'223248','Cirurgião dentista - periodontista'})
aAdd(aCBO,{'223252','Cirurgião dentista - protesiólogo bucomaxilofacial'})
aAdd(aCBO,{'223256','Cirurgião dentista - protesista'})
aAdd(aCBO,{'223260','Cirurgião dentista - radiologista'})
aAdd(aCBO,{'223264','Cirurgião dentista - reabilitador oral'})
aAdd(aCBO,{'223268','Cirurgião dentista - traumatologista bucomaxilofacial'})
aAdd(aCBO,{'223305','Médico veterinário'})
aAdd(aCBO,{'223310','Zootecnista'})
aAdd(aCBO,{'223445','Farmacêutico hospitalar e clínico'})
aAdd(aCBO,{'223420','Farmacêutico de alimentos'})
aAdd(aCBO,{'223405','Farmacêutico'})
aAdd(aCBO,{'223415','Farmacêutico analista clínico'})
aAdd(aCBO,{'223425','Farmacêutico práticas integrativas e complementares'})
aAdd(aCBO,{'223430','Farmacêutico em saúde pública'})
aAdd(aCBO,{'223435','Farmacêutico industrial'})
aAdd(aCBO,{'223440','Farmacêutico toxicologista'})
aAdd(aCBO,{'223515','Enfermeiro de bordo'})
aAdd(aCBO,{'223510','Enfermeiro auditor'})
aAdd(aCBO,{'223570','Perfusionista'})
aAdd(aCBO,{'223505','Enfermeiro'})
aAdd(aCBO,{'223520','Enfermeiro de centro cirúrgico'})
aAdd(aCBO,{'223525','Enfermeiro de terapia intensiva'})
aAdd(aCBO,{'223530','Enfermeiro do trabalho'})
aAdd(aCBO,{'223535','Enfermeiro nefrologista'})
aAdd(aCBO,{'223540','Enfermeiro neonatologista'})
aAdd(aCBO,{'223545','Enfermeiro obstétrico'})
aAdd(aCBO,{'223550','Enfermeiro psiquiátrico'})
aAdd(aCBO,{'223565','Enfermeiro da estratégia de saúde da família'})
aAdd(aCBO,{'223560','Enfermeiro sanitarista'})
aAdd(aCBO,{'223555','Enfermeiro puericultor e pediátrico'})
aAdd(aCBO,{'223660','Fisioterapeuta do trabalho'})
aAdd(aCBO,{'223655','Fisioterapeuta esportivo'})
aAdd(aCBO,{'223650','Fisioterapeuta acupunturista'})
aAdd(aCBO,{'223645','Fisioterapeuta quiropraxista'})
aAdd(aCBO,{'223605','Fisioterapeuta geral'})
aAdd(aCBO,{'223635','Fisioterapeuta traumato-ortopédica funcional'})
aAdd(aCBO,{'223630','Fisioterapeuta neurofuncional'})
aAdd(aCBO,{'223625','Fisioterapeuta respiratória'})
aAdd(aCBO,{'223640','Fisioterapeuta osteopata'})
aAdd(aCBO,{'223705','Dietista'})
aAdd(aCBO,{'223710','Nutricionista'})
aAdd(aCBO,{'223840','Fonoaudiólogo em saúde coletiva'})
aAdd(aCBO,{'223810','Fonoaudiólogo geral'})
aAdd(aCBO,{'223820','Fonoaudiólogo em audiologia'})
aAdd(aCBO,{'223815','Fonoaudiólogo educacional'})
aAdd(aCBO,{'223845','Fonoaudiólogo em voz'})
aAdd(aCBO,{'223835','Fonoaudiólogo em motricidade orofacial'})
aAdd(aCBO,{'223830','Fonoaudiólogo em linguagem'})
aAdd(aCBO,{'223825','Fonoaudiólogo em disfagia'})
aAdd(aCBO,{'223910','Ortoptista'})
aAdd(aCBO,{'223905','Terapeuta ocupacional'})
aAdd(aCBO,{'224105','Avaliador físico'})
aAdd(aCBO,{'224110','Ludomotricista'})
aAdd(aCBO,{'224115','Preparador de atleta'})
aAdd(aCBO,{'224135','Treinador profissional de futebol'})
aAdd(aCBO,{'224125','Técnico de desporto individual e coletivo (exceto futebol)'})
aAdd(aCBO,{'224130','Técnico de laboratório e fiscalização desportiva'})
aAdd(aCBO,{'224120','Preparador físico'})
aAdd(aCBO,{'225195','Médico homeopata'})
aAdd(aCBO,{'225142','Médico da estratégia de saúde da família'})
aAdd(aCBO,{'225180','Médico geriatra'})
aAdd(aCBO,{'225175','Médico geneticista'})
aAdd(aCBO,{'225170','Médico generalista'})
aAdd(aCBO,{'225165','Médico gastroenterologista'})
aAdd(aCBO,{'225160','Médico fisiatra'})
aAdd(aCBO,{'225155','Médico endocrinologista e metabologista'})
aAdd(aCBO,{'225151','Médico anestesiologista'})
aAdd(aCBO,{'225150','Médico em medicina intensiva'})
aAdd(aCBO,{'225148','Médico anatomopatologista'})
aAdd(aCBO,{'225145','Médico em medicina de tráfego'})
aAdd(aCBO,{'225154','Médico antroposófico'})
aAdd(aCBO,{'225103','Médico infectologista'})
aAdd(aCBO,{'225105','Médico acupunturista'})
aAdd(aCBO,{'225106','Médico legista'})
aAdd(aCBO,{'225109','Médico nefrologista'})
aAdd(aCBO,{'225110','Médico alergista e imunologista'})
aAdd(aCBO,{'225112','Médico neurologista'})
aAdd(aCBO,{'225115','Médico angiologista'})
aAdd(aCBO,{'225118','Médico nutrologista'})
aAdd(aCBO,{'225120','Médico cardiologista'})
aAdd(aCBO,{'225121','Médico oncologista clínico'})
aAdd(aCBO,{'225122','Médico cancerologista pediátrico'})
aAdd(aCBO,{'225124','Médico pediatra'})
aAdd(aCBO,{'225125','Médico clínico'})
aAdd(aCBO,{'225127','Médico pneumologista'})
aAdd(aCBO,{'225130','Médico de família e comunidade'})
aAdd(aCBO,{'225133','Médico psiquiatra'})
aAdd(aCBO,{'225135','Médico dermatologista'})
aAdd(aCBO,{'225136','Médico reumatologista'})
aAdd(aCBO,{'225139','Médico sanitarista'})
aAdd(aCBO,{'225140','Médico do trabalho'})
aAdd(aCBO,{'225185','Médico hematologista'})
aAdd(aCBO,{'225295','Médico cirurgião da mão'})
aAdd(aCBO,{'225290','Médico cancerologista cirurgíco'})
aAdd(aCBO,{'225285','Médico urologista'})
aAdd(aCBO,{'225280','Médico coloproctologista'})
aAdd(aCBO,{'225275','Médico otorrinolaringologista'})
aAdd(aCBO,{'225270','Médico ortopedista e traumatologista'})
aAdd(aCBO,{'225265','Médico oftalmologista'})
aAdd(aCBO,{'225260','Médico neurocirurgião'})
aAdd(aCBO,{'225255','Médico mastologista'})
aAdd(aCBO,{'225250','Médico ginecologista e obstetra'})
aAdd(aCBO,{'225230','Médico cirurgião pediátrico'})
aAdd(aCBO,{'225235','Médico cirurgião plástico'})
aAdd(aCBO,{'225240','Médico cirurgião torácico'})
aAdd(aCBO,{'225225','Médico cirurgião geral'})
aAdd(aCBO,{'225220','Médico cirurgião do aparelho digestivo'})
aAdd(aCBO,{'225215','Médico cirurgião de cabeça e pescoço'})
aAdd(aCBO,{'225210','Médico cirurgião cardiovascular'})
aAdd(aCBO,{'225203','Médico em cirurgia vascular'})
aAdd(aCBO,{'225335','Médico patologista clínico / medicina laboratorial'})
aAdd(aCBO,{'225340','Médico hemoterapeuta'})
aAdd(aCBO,{'225345','Médico hiperbarista'})
aAdd(aCBO,{'225350','Médico neurofisiologista clínico'})
aAdd(aCBO,{'225305','Médico citopatologista'})
aAdd(aCBO,{'225325','Médico patologista'})
aAdd(aCBO,{'225320','Médico em radiologia e diagnóstico por imagem'})
aAdd(aCBO,{'225315','Médico em medicina nuclear'})
aAdd(aCBO,{'225310','Médico em endoscopia'})
aAdd(aCBO,{'225330','Médico radioterapeuta'})
aAdd(aCBO,{'226105','Quiropraxista'})
aAdd(aCBO,{'226110','Osteopata'})
aAdd(aCBO,{'226310','Arteterapeuta'})
aAdd(aCBO,{'226305','Musicoterapeuta'})
aAdd(aCBO,{'226315','Equoterapeuta'})
aAdd(aCBO,{'231110','Professor de nível superior na educação infantil (zero a três anos)'})
aAdd(aCBO,{'231105','Professor de nível superior na educação infantil (quatro a seis anos)'})
aAdd(aCBO,{'231205','Professor da educação de jovens e adultos do ensino fundamental (primeira a quarta série)'})
aAdd(aCBO,{'231210','Professor de nível superior do ensino fundamental (primeira a quarta série)'})
aAdd(aCBO,{'231305','Professor de ciências exatas e naturais do ensino fundamental'})
aAdd(aCBO,{'231310','Professor de educação artística do ensino fundamental'})
aAdd(aCBO,{'231315','Professor de educação física do ensino fundamental'})
aAdd(aCBO,{'231340','Professor de matemática do ensino fundamental'})
aAdd(aCBO,{'231325','Professor de história do ensino fundamental'})
aAdd(aCBO,{'231330','Professor de língua estrangeira moderna do ensino fundamental'})
aAdd(aCBO,{'231335','Professor de língua portuguesa do ensino fundamental'})
aAdd(aCBO,{'231320','Professor de geografia do ensino fundamental'})
aAdd(aCBO,{'232140','Professor de história no ensino médio'})
aAdd(aCBO,{'232150','Professor de língua estrangeira moderna no ensino médio'})
aAdd(aCBO,{'232160','Professor de psicologia no ensino médio'})
aAdd(aCBO,{'232165','Professor de química no ensino médio'})
aAdd(aCBO,{'232105','Professor de artes no ensino médio'})
aAdd(aCBO,{'232120','Professor de educação física no ensino médio'})
aAdd(aCBO,{'232125','Professor de filosofia no ensino médio'})
aAdd(aCBO,{'232130','Professor de física no ensino médio'})
aAdd(aCBO,{'232135','Professor de geografia no ensino médio'})
aAdd(aCBO,{'232145','Professor de língua e literatura brasileira no ensino médio'})
aAdd(aCBO,{'232155','Professor de matemática no ensino médio'})
aAdd(aCBO,{'232170','Professor de sociologia no ensino médio'})
aAdd(aCBO,{'232110','Professor de biologia no ensino médio'})
aAdd(aCBO,{'232115','Professor de disciplinas pedagógicas no ensino médio'})
aAdd(aCBO,{'233105','Professor da área de meio ambiente'})
aAdd(aCBO,{'233110','Professor de desenho técnico'})
aAdd(aCBO,{'233115','Professor de técnicas agrícolas'})
aAdd(aCBO,{'233120','Professor de técnicas comerciais e secretariais'})
aAdd(aCBO,{'233125','Professor de técnicas de enfermagem'})
aAdd(aCBO,{'233130','Professor de técnicas industriais'})
aAdd(aCBO,{'233135','Professor de tecnologia e cálculo técnico'})
aAdd(aCBO,{'233205','Instrutor de aprendizagem e treinamento agropecuário'})
aAdd(aCBO,{'233210','Instrutor de aprendizagem e treinamento industrial'})
aAdd(aCBO,{'233215','Professor de aprendizagem e treinamento comercial'})
aAdd(aCBO,{'233220','Professor instrutor de ensino e aprendizagem agroflorestal'})
aAdd(aCBO,{'233225','Professor instrutor de ensino e aprendizagem em serviços'})
aAdd(aCBO,{'234125','Professor de pesquisa operacional (no ensino superior)'})
aAdd(aCBO,{'234120','Professor de computação (no ensino superior)'})
aAdd(aCBO,{'234115','Professor de estatística (no ensino superior)'})
aAdd(aCBO,{'234110','Professor de matemática pura (no ensino superior)'})
aAdd(aCBO,{'234105','Professor de matemática aplicada (no ensino superior)'})
aAdd(aCBO,{'234205','Professor de física (ensino superior)'})
aAdd(aCBO,{'234215','Professor de astronomia (ensino superior)'})
aAdd(aCBO,{'234210','Professor de química (ensino superior)'})
aAdd(aCBO,{'234305','Professor de arquitetura'})
aAdd(aCBO,{'234315','Professor de geofísica'})
aAdd(aCBO,{'234310','Professor de engenharia'})
aAdd(aCBO,{'234320','Professor de geologia'})
aAdd(aCBO,{'234405','Professor de ciências biológicas do ensino superior'})
aAdd(aCBO,{'234415','Professor de enfermagem do ensino superior'})
aAdd(aCBO,{'234460','Professor de zootecnia do ensino superior'})
aAdd(aCBO,{'234455','Professor de terapia ocupacional'})
aAdd(aCBO,{'234410','Professor de educação física no ensino superior'})
aAdd(aCBO,{'234420','Professor de farmácia e bioquímica'})
aAdd(aCBO,{'234425','Professor de fisioterapia'})
aAdd(aCBO,{'234430','Professor de fonoaudiologia'})
aAdd(aCBO,{'234435','Professor de medicina'})
aAdd(aCBO,{'234440','Professor de medicina veterinária'})
aAdd(aCBO,{'234445','Professor de nutrição'})
aAdd(aCBO,{'234450','Professor de odontologia'})
aAdd(aCBO,{'234510','Professor de ensino superior na área de orientação educacional'})
aAdd(aCBO,{'234505','Professor de ensino superior na área de didática'})
aAdd(aCBO,{'234515','Professor de ensino superior na área de pesquisa educacional'})
aAdd(aCBO,{'234520','Professor de ensino superior na área de prática de ensino'})
aAdd(aCBO,{'234660','Professor de literatura de línguas estrangeiras modernas'})
aAdd(aCBO,{'234664','Professor de outras línguas e literaturas'})
aAdd(aCBO,{'234632','Professor de literatura portuguesa'})
aAdd(aCBO,{'234628','Professor de literatura brasileira'})
aAdd(aCBO,{'234624','Professor de língua portuguesa'})
aAdd(aCBO,{'234640','Professor de literatura comparada'})
aAdd(aCBO,{'234656','Professor de literatura italiana'})
aAdd(aCBO,{'234652','Professor de literatura inglesa'})
aAdd(aCBO,{'234648','Professor de literatura francesa'})
aAdd(aCBO,{'234644','Professor de literatura espanhola'})
aAdd(aCBO,{'234636','Professor de literatura alemã'})
aAdd(aCBO,{'234620','Professor de língua espanhola'})
aAdd(aCBO,{'234616','Professor de língua inglesa'})
aAdd(aCBO,{'234612','Professor de língua francesa'})
aAdd(aCBO,{'234608','Professor de língua italiana'})
aAdd(aCBO,{'234604','Professor de língua alemã'})
aAdd(aCBO,{'234684','Professor de teoria da literatura'})
aAdd(aCBO,{'234680','Professor de semiótica'})
aAdd(aCBO,{'234676','Professor de filologia e crítica textual'})
aAdd(aCBO,{'234668','Professor de línguas estrangeiras modernas'})
aAdd(aCBO,{'234672','Professor de lingüística e lingüística aplicada'})
aAdd(aCBO,{'234770','Professor de sociologia do ensino superior'})
aAdd(aCBO,{'234765','Professor de serviço social do ensino superior'})
aAdd(aCBO,{'234760','Professor de psicologia do ensino superior'})
aAdd(aCBO,{'234755','Professor de museologia do ensino superior'})
aAdd(aCBO,{'234750','Professor de jornalismo'})
aAdd(aCBO,{'234745','Professor de história do ensino superior'})
aAdd(aCBO,{'234705','Professor de antropologia do ensino superior'})
aAdd(aCBO,{'234735','Professor de filosofia do ensino superior'})
aAdd(aCBO,{'234730','Professor de direito do ensino superior'})
aAdd(aCBO,{'234725','Professor de comunicação social do ensino superior'})
aAdd(aCBO,{'234720','Professor de ciência política do ensino superior'})
aAdd(aCBO,{'234715','Professor de biblioteconomia do ensino superior'})
aAdd(aCBO,{'234710','Professor de arquivologia do ensino superior'})
aAdd(aCBO,{'234740','Professor de geografia do ensino superior'})
aAdd(aCBO,{'234810','Professor de administração'})
aAdd(aCBO,{'234815','Professor de contabilidade'})
aAdd(aCBO,{'234805','Professor de economia'})
aAdd(aCBO,{'234905','Professor de artes do espetáculo no ensino superior'})
aAdd(aCBO,{'234915','Professor de música no ensino superior'})
aAdd(aCBO,{'234910','Professor de artes visuais no ensino superior (artes plásticas e multimídia)'})
aAdd(aCBO,{'239220','Professor de alunos com deficiência múltipla'})
aAdd(aCBO,{'239215','Professor de alunos com deficiência mental'})
aAdd(aCBO,{'239210','Professor de alunos com deficiência física'})
aAdd(aCBO,{'239205','Professor de alunos com deficiência auditiva e surdos'})
aAdd(aCBO,{'239225','Professor de alunos com deficiência visual'})
aAdd(aCBO,{'239435','Designer educacional'})
aAdd(aCBO,{'239425','Psicopedagogo'})
aAdd(aCBO,{'239420','Professor de técnicas e recursos audiovisuais'})
aAdd(aCBO,{'239415','Pedagogo'})
aAdd(aCBO,{'239410','Orientador educacional'})
aAdd(aCBO,{'239405','Coordenador pedagógico'})
aAdd(aCBO,{'239430','Supervisor de ensino'})
aAdd(aCBO,{'241005','Advogado'})
aAdd(aCBO,{'241010','Advogado de empresa'})
aAdd(aCBO,{'241040','Consultor jurídico'})
aAdd(aCBO,{'241035','Advogado (direito do trabalho)'})
aAdd(aCBO,{'241030','Advogado (áreas especiais)'})
aAdd(aCBO,{'241025','Advogado (direito penal)'})
aAdd(aCBO,{'241020','Advogado (direito público)'})
aAdd(aCBO,{'241015','Advogado (direito civil)'})
aAdd(aCBO,{'241225','Procurador do município'})
aAdd(aCBO,{'241230','Procurador federal'})
aAdd(aCBO,{'241235','Procurador fundacional'})
aAdd(aCBO,{'241220','Procurador do estado'})
aAdd(aCBO,{'241215','Procurador da fazenda nacional'})
aAdd(aCBO,{'241210','Procurador autárquico'})
aAdd(aCBO,{'241205','Advogado da união'})
aAdd(aCBO,{'241315','Oficial do registro civil de pessoas naturais'})
aAdd(aCBO,{'241310','Oficial do registro civil de pessoas jurídicas'})
aAdd(aCBO,{'241305','Oficial de registro de contratos marítimos'})
aAdd(aCBO,{'241320','Oficial do registro de distribuições'})
aAdd(aCBO,{'241325','Oficial do registro de imóveis'})
aAdd(aCBO,{'241330','Oficial do registro de títulos e documentos'})
aAdd(aCBO,{'241335','Tabelião de notas'})
aAdd(aCBO,{'241340','Tabelião de protestos'})
aAdd(aCBO,{'242245','Subprocurador-geral da república'})
aAdd(aCBO,{'242250','Subprocurador-geral do trabalho'})
aAdd(aCBO,{'242205','Procurador da república'})
aAdd(aCBO,{'242215','Procurador de justiça militar'})
aAdd(aCBO,{'242220','Procurador do trabalho'})
aAdd(aCBO,{'242235','Promotor de justiça'})
aAdd(aCBO,{'242210','Procurador de justiça'})
aAdd(aCBO,{'242225','Procurador regional da república'})
aAdd(aCBO,{'242230','Procurador regional do trabalho'})
aAdd(aCBO,{'242240','Subprocurador de justiça militar'})
aAdd(aCBO,{'242305','Delegado de polícia'})
aAdd(aCBO,{'242405','Defensor público'})
aAdd(aCBO,{'242410','Procurador da assistência judiciária'})
aAdd(aCBO,{'242905','Oficial de inteligência'})
aAdd(aCBO,{'242910','Oficial técnico de inteligência'})
aAdd(aCBO,{'251105','Antropólogo'})
aAdd(aCBO,{'251110','Arqueólogo'})
aAdd(aCBO,{'251115','Cientista político'})
aAdd(aCBO,{'251120','Sociólogo'})
aAdd(aCBO,{'251205','Economista'})
aAdd(aCBO,{'251210','Economista agroindustrial'})
aAdd(aCBO,{'251215','Economista financeiro'})
aAdd(aCBO,{'251220','Economista industrial'})
aAdd(aCBO,{'251225','Economista do setor público'})
aAdd(aCBO,{'251230','Economista ambiental'})
aAdd(aCBO,{'251235','Economista regional e urbano'})
aAdd(aCBO,{'251305','Geógrafo'})
aAdd(aCBO,{'251405','Filósofo'})
aAdd(aCBO,{'251530','Psicólogo social'})
aAdd(aCBO,{'251510','Psicólogo clínico'})
aAdd(aCBO,{'251515','Psicólogo do esporte'})
aAdd(aCBO,{'251545','Neuropsicólogo'})
aAdd(aCBO,{'251540','Psicólogo do trabalho'})
aAdd(aCBO,{'251535','Psicólogo do trânsito'})
aAdd(aCBO,{'251505','Psicólogo educacional'})
aAdd(aCBO,{'251525','Psicólogo jurídico'})
aAdd(aCBO,{'251550','Psicanalista'})
aAdd(aCBO,{'251555','Psicólogo acupunturista'})
aAdd(aCBO,{'251520','Psicólogo hospitalar'})
aAdd(aCBO,{'251610','Economista doméstico'})
aAdd(aCBO,{'251605','Assistente social'})
aAdd(aCBO,{'252105','Administrador'})
aAdd(aCBO,{'252205','Auditor (contadores e afins)'})
aAdd(aCBO,{'252215','Perito contábil'})
aAdd(aCBO,{'252210','Contador'})
aAdd(aCBO,{'252310','Secretário bilíngüe'})
aAdd(aCBO,{'252305','Secretária(o) executiva(o)'})
aAdd(aCBO,{'252315','Secretária trilíngüe'})
aAdd(aCBO,{'252320','Tecnólogo em secretariado escolar'})
aAdd(aCBO,{'252405','Analista de recursos humanos'})
aAdd(aCBO,{'252535','Analista de leasing'})
aAdd(aCBO,{'252505','Administrador de fundos e carteiras de investimento'})
aAdd(aCBO,{'252525','Analista de crédito (instituições financeiras)'})
aAdd(aCBO,{'252545','Analista financeiro (instituições financeiras)'})
aAdd(aCBO,{'252510','Analista de câmbio'})
aAdd(aCBO,{'252515','Analista de cobrança (instituições financeiras)'})
aAdd(aCBO,{'252540','Analista de produtos bancários'})
aAdd(aCBO,{'252530','Analista de crédito rural'})
aAdd(aCBO,{'252605','Gestor em segurança'})
aAdd(aCBO,{'253110','Redator de publicidade'})
aAdd(aCBO,{'253115','Publicitário'})
aAdd(aCBO,{'253130','Diretor de criação'})
aAdd(aCBO,{'253125','Diretor de arte (publicidade)'})
aAdd(aCBO,{'253120','Diretor de mídia (publicidade)'})
aAdd(aCBO,{'253135','Diretor de contas (publicidade)'})
aAdd(aCBO,{'253140','Agenciador de propaganda'})
aAdd(aCBO,{'253205','Gerente de captação (fundos e investimentos institucionais)'})
aAdd(aCBO,{'253210','Gerente de clientes especiais (private)'})
aAdd(aCBO,{'253215','Gerente de contas - pessoa física e jurídica'})
aAdd(aCBO,{'253220','Gerente de grandes contas (corporate)'})
aAdd(aCBO,{'253225','Operador de negócios'})
aAdd(aCBO,{'253305','Corretor de valores, ativos financeiros, mercadorias e derivativos'})
aAdd(aCBO,{'254105','Auditor-fiscal da receita federal'})
aAdd(aCBO,{'254110','Técnico da receita federal'})
aAdd(aCBO,{'254205','Auditor-fiscal da previdência social'})
aAdd(aCBO,{'254305','Auditor-fiscal do trabalho'})
aAdd(aCBO,{'254310','Agente de higiene e segurança'})
aAdd(aCBO,{'254405','Fiscal de tributos estadual'})
aAdd(aCBO,{'254420','Técnico de tributos municipal'})
aAdd(aCBO,{'254410','Fiscal de tributos municipal'})
aAdd(aCBO,{'254415','Técnico de tributos estadual'})
aAdd(aCBO,{'261105','Arquivista pesquisador (jornalismo)'})
aAdd(aCBO,{'261110','Assessor de imprensa'})
aAdd(aCBO,{'261115','Diretor de redação'})
aAdd(aCBO,{'261120','Editor'})
aAdd(aCBO,{'261125','Jornalista'})
aAdd(aCBO,{'261130','Produtor de texto'})
aAdd(aCBO,{'261135','Repórter (exclusive rádio e televisão)'})
aAdd(aCBO,{'261140','Revisor de texto'})
aAdd(aCBO,{'261210','Documentalista'})
aAdd(aCBO,{'261215','Analista de informações (pesquisador de informações de rede)'})
aAdd(aCBO,{'261205','Bibliotecário'})
aAdd(aCBO,{'261305','Arquivista'})
aAdd(aCBO,{'261310','Museólogo'})
aAdd(aCBO,{'261405','Filólogo'})
aAdd(aCBO,{'261430','Audiodescritor'})
aAdd(aCBO,{'261425','Intérprete de língua de sinais'})
aAdd(aCBO,{'261420','Tradutor'})
aAdd(aCBO,{'261415','Lingüista'})
aAdd(aCBO,{'261410','Intérprete'})
aAdd(aCBO,{'261530','Redator de textos técnicos'})
aAdd(aCBO,{'261520','Escritor de não ficção'})
aAdd(aCBO,{'261525','Poeta'})
aAdd(aCBO,{'261515','Escritor de ficção'})
aAdd(aCBO,{'261510','Crítico'})
aAdd(aCBO,{'261505','Autor-roteirista'})
aAdd(aCBO,{'261605','Editor de jornal'})
aAdd(aCBO,{'261615','Editor de mídia eletrônica'})
aAdd(aCBO,{'261610','Editor de livro'})
aAdd(aCBO,{'261620','Editor de revista'})
aAdd(aCBO,{'261625','Editor de revista científica'})
aAdd(aCBO,{'261705','Âncora de rádio e televisão'})
aAdd(aCBO,{'261715','Locutor de rádio e televisão'})
aAdd(aCBO,{'261710','Comentarista de rádio e televisão'})
aAdd(aCBO,{'261720','Locutor publicitário de rádio e televisão'})
aAdd(aCBO,{'261725','Narrador em programas de rádio e televisão'})
aAdd(aCBO,{'261730','Repórter de rádio e televisão'})
aAdd(aCBO,{'261805','Fotógrafo'})
aAdd(aCBO,{'261810','Fotógrafo publicitário'})
aAdd(aCBO,{'261815','Fotógrafo retratista'})
aAdd(aCBO,{'261820','Repórter fotográfico'})
aAdd(aCBO,{'262135','Tecnólogo em produção audiovisual'})
aAdd(aCBO,{'262130','Tecnólogo em produção fonográfica'})
aAdd(aCBO,{'262105','Produtor cultural'})
aAdd(aCBO,{'262120','Produtor de teatro'})
aAdd(aCBO,{'262125','Produtor de televisão'})
aAdd(aCBO,{'262110','Produtor cinematográfico'})
aAdd(aCBO,{'262115','Produtor de rádio'})
aAdd(aCBO,{'262220','Diretor teatral'})
aAdd(aCBO,{'262215','Diretor de programas de televisão'})
aAdd(aCBO,{'262210','Diretor de programas de rádio'})
aAdd(aCBO,{'262205','Diretor de cinema'})
aAdd(aCBO,{'262305','Cenógrafo carnavalesco e festas populares'})
aAdd(aCBO,{'262310','Cenógrafo de cinema'})
aAdd(aCBO,{'262315','Cenógrafo de eventos'})
aAdd(aCBO,{'262320','Cenógrafo de teatro'})
aAdd(aCBO,{'262325','Cenógrafo de tv'})
aAdd(aCBO,{'262330','Diretor de arte'})
aAdd(aCBO,{'262420','Desenhista industrial de produto (designer de produto)'})
aAdd(aCBO,{'262425','Desenhista industrial de produto de moda (designer de moda)'})
aAdd(aCBO,{'262405','Artista (artes visuais)'})
aAdd(aCBO,{'262415','Conservador-restaurador de bens culturais'})
aAdd(aCBO,{'262410','Desenhista industrial gráfico (designer gráfico)'})
aAdd(aCBO,{'262505','Ator'})
aAdd(aCBO,{'262605','Compositor'})
aAdd(aCBO,{'262610','Músico arranjador'})
aAdd(aCBO,{'262615','Músico regente'})
aAdd(aCBO,{'262620','Musicólogo'})
aAdd(aCBO,{'262705','Músico intérprete cantor'})
aAdd(aCBO,{'262710','Músico intérprete instrumentista'})
aAdd(aCBO,{'262815','Coreógrafo'})
aAdd(aCBO,{'262810','Bailarino (exceto danças populares)'})
aAdd(aCBO,{'262805','Assistente de coreografia'})
aAdd(aCBO,{'262820','Dramaturgo de dança'})
aAdd(aCBO,{'262830','Professor de dança'})
aAdd(aCBO,{'262825','Ensaiador de dança'})
aAdd(aCBO,{'262905','Decorador de interiores de nível superior'})
aAdd(aCBO,{'263110','Missionário'})
aAdd(aCBO,{'263105','Ministro de culto religioso'})
aAdd(aCBO,{'263115','Teólogo'})
aAdd(aCBO,{'271110','Tecnólogo em gastronomia'})
aAdd(aCBO,{'271105','Chefe de cozinha'})
aAdd(aCBO,{'300105','Técnico em mecatrônica - automação da manufatura'})
aAdd(aCBO,{'300110','Técnico em mecatrônica - robótica'})
aAdd(aCBO,{'300305','Técnico em eletromecânica'})
aAdd(aCBO,{'301105','Técnico de laboratório industrial'})
aAdd(aCBO,{'301110','Técnico de laboratório de análises físico-químicas (materiais de construção)'})
aAdd(aCBO,{'301115','Técnico químico de petróleo'})
aAdd(aCBO,{'301205','Técnico de apoio à bioengenharia'})
aAdd(aCBO,{'311110','Técnico de celulose e papel'})
aAdd(aCBO,{'311115','Técnico em curtimento'})
aAdd(aCBO,{'311105','Técnico químico'})
aAdd(aCBO,{'311205','Técnico em petroquímica'})
aAdd(aCBO,{'311305','Técnico em materiais, produtos cerâmicos e vidros'})
aAdd(aCBO,{'311405','Técnico em borracha'})
aAdd(aCBO,{'311410','Técnico em plástico'})
aAdd(aCBO,{'311505','Técnico de controle de meio ambiente'})
aAdd(aCBO,{'311510','Técnico de meteorologia'})
aAdd(aCBO,{'311515','Técnico de utilidade (produção e distribuição de vapor, gases, óleos, combustíveis, energia)'})
aAdd(aCBO,{'311520','Técnico em tratamento de efluentes'})
aAdd(aCBO,{'311605','Técnico têxtil'})
aAdd(aCBO,{'311625','Técnico têxtil de tecelagem'})
aAdd(aCBO,{'311620','Técnico têxtil de malharia'})
aAdd(aCBO,{'311615','Técnico têxtil de fiação'})
aAdd(aCBO,{'311610','Técnico têxtil (tratamentos químicos)'})
aAdd(aCBO,{'311720','Preparador de tintas (fábrica de tecidos)'})
aAdd(aCBO,{'311715','Preparador de tintas'})
aAdd(aCBO,{'311710','Colorista têxtil'})
aAdd(aCBO,{'311705','Colorista de papel'})
aAdd(aCBO,{'311725','Tingidor de couros e peles'})
aAdd(aCBO,{'312105','Técnico de obras civis'})
aAdd(aCBO,{'312210','Técnico de saneamento'})
aAdd(aCBO,{'312205','Técnico de estradas'})
aAdd(aCBO,{'312315','Técnico em hidrografia'})
aAdd(aCBO,{'312310','Técnico em geodésia e cartografia'})
aAdd(aCBO,{'312320','Topógrafo'})
aAdd(aCBO,{'312305','Técnico em agrimensura'})
aAdd(aCBO,{'313130','Técnico eletricista'})
aAdd(aCBO,{'313105','Eletrotécnico'})
aAdd(aCBO,{'313110','Eletrotécnico (produção de energia)'})
aAdd(aCBO,{'313125','Técnico de manutenção elétrica de máquina'})
aAdd(aCBO,{'313120','Técnico de manutenção elétrica'})
aAdd(aCBO,{'313115','Eletrotécnico na fabricação, montagem e instalação de máquinas e equipamentos'})
aAdd(aCBO,{'313220','Técnico em manutenção de equipamentos de informática'})
aAdd(aCBO,{'313215','Técnico eletrônico'})
aAdd(aCBO,{'313205','Técnico de manutenção eletrônica'})
aAdd(aCBO,{'313210','Técnico de manutenção eletrônica (circuitos de máquinas com comando numérico)'})
aAdd(aCBO,{'313320','Técnico de transmissão (telecomunicações)'})
aAdd(aCBO,{'313315','Técnico de telecomunicações (telefonia)'})
aAdd(aCBO,{'313310','Técnico de rede (telecomunicações)'})
aAdd(aCBO,{'313305','Técnico de comunicação de dados'})
aAdd(aCBO,{'313415','Encarregado de manutenção de instrumentos de controle, medição e similares'})
aAdd(aCBO,{'313405','Técnico em calibração'})
aAdd(aCBO,{'313410','Técnico em instrumentação'})
aAdd(aCBO,{'313505','Técnico em fotônica'})
aAdd(aCBO,{'314105','Técnico em mecânica de precisão'})
aAdd(aCBO,{'314110','Técnico mecânico'})
aAdd(aCBO,{'314115','Técnico mecânico (calefação, ventilação e refrigeração)'})
aAdd(aCBO,{'314120','Técnico mecânico (máquinas)'})
aAdd(aCBO,{'314125','Técnico mecânico (motores)'})
aAdd(aCBO,{'314205','Técnico mecânico na fabricação de ferramentas'})
aAdd(aCBO,{'314210','Técnico mecânico na manutenção de ferramentas'})
aAdd(aCBO,{'314305','Técnico em automobilística'})
aAdd(aCBO,{'314310','Técnico mecânico (aeronaves)'})
aAdd(aCBO,{'314315','Técnico mecânico (embarcações)'})
aAdd(aCBO,{'314405','Técnico de manutenção de sistemas e instrumentos'})
aAdd(aCBO,{'314410','Técnico em manutenção de máquinas'})
aAdd(aCBO,{'314605','Inspetor de soldagem'})
aAdd(aCBO,{'314620','Técnico em soldagem'})
aAdd(aCBO,{'314615','Técnico em estruturas metálicas'})
aAdd(aCBO,{'314610','Técnico em caldeiraria'})
aAdd(aCBO,{'314725','Técnico de redução na siderurgia (primeira fusão)'})
aAdd(aCBO,{'314720','Técnico de laminação em siderurgia'})
aAdd(aCBO,{'314715','Técnico de fundição em siderurgia'})
aAdd(aCBO,{'314710','Técnico de aciaria em siderurgia'})
aAdd(aCBO,{'314730','Técnico de refratário em siderurgia'})
aAdd(aCBO,{'314705','Técnico de acabamento em siderurgia'})
aAdd(aCBO,{'316115','Técnico em geoquímica'})
aAdd(aCBO,{'316110','Técnico em geologia'})
aAdd(aCBO,{'316105','Técnico em geofísica'})
aAdd(aCBO,{'316120','Técnico em geotecnia'})
aAdd(aCBO,{'316325','Técnico de produção em refino de petróleo'})
aAdd(aCBO,{'316330','Técnico em planejamento de lavra de minas'})
aAdd(aCBO,{'316335','Desincrustador (poços de petróleo)'})
aAdd(aCBO,{'316320','Técnico em pesquisa mineral'})
aAdd(aCBO,{'316315','Técnico em processamento mineral (exceto petróleo)'})
aAdd(aCBO,{'316340','Cimentador (poços de petróleo)'})
aAdd(aCBO,{'316305','Técnico de mineração'})
aAdd(aCBO,{'316310','Técnico de mineração (óleo e petróleo)'})
aAdd(aCBO,{'317105','Programador de internet'})
aAdd(aCBO,{'317110','Programador de sistemas de informação'})
aAdd(aCBO,{'317115','Programador de máquinas - ferramenta com comando numérico'})
aAdd(aCBO,{'317120','Programador de multimídia'})
aAdd(aCBO,{'317205','Operador de computador (inclusive microcomputador)'})
aAdd(aCBO,{'317210','Técnico de apoio ao usuário de informática (helpdesk)'})
aAdd(aCBO,{'318010','Desenhista copista'})
aAdd(aCBO,{'318005','Desenhista técnico'})
aAdd(aCBO,{'318015','Desenhista detalhista'})
aAdd(aCBO,{'318110','Desenhista técnico (cartografia)'})
aAdd(aCBO,{'318105','Desenhista técnico (arquitetura)'})
aAdd(aCBO,{'318115','Desenhista técnico (construção civil)'})
aAdd(aCBO,{'318120','Desenhista técnico (instalações hidrossanitárias)'})
aAdd(aCBO,{'318205','Desenhista técnico mecânico'})
aAdd(aCBO,{'318210','Desenhista técnico aeronáutico'})
aAdd(aCBO,{'318215','Desenhista técnico naval'})
aAdd(aCBO,{'318305','Desenhista técnico (eletricidade e eletrônica)'})
aAdd(aCBO,{'318310','Desenhista técnico (calefação, ventilação e refrigeração)'})
aAdd(aCBO,{'318405','Desenhista técnico (artes gráficas)'})
aAdd(aCBO,{'318410','Desenhista técnico (ilustrações artísticas)'})
aAdd(aCBO,{'318430','Desenhista técnico de embalagens, maquetes e leiautes'})
aAdd(aCBO,{'318425','Desenhista técnico (mobiliário)'})
aAdd(aCBO,{'318420','Desenhista técnico (indústria têxtil)'})
aAdd(aCBO,{'318415','Desenhista técnico (ilustrações técnicas)'})
aAdd(aCBO,{'318505','Desenhista projetista de arquitetura'})
aAdd(aCBO,{'318510','Desenhista projetista de construção civil'})
aAdd(aCBO,{'318605','Desenhista projetista de máquinas'})
aAdd(aCBO,{'318610','Desenhista projetista mecânico'})
aAdd(aCBO,{'318705','Desenhista projetista de eletricidade'})
aAdd(aCBO,{'318710','Desenhista projetista eletrônico'})
aAdd(aCBO,{'318805','Projetista de móveis'})
aAdd(aCBO,{'318815','Modelista de calçados'})
aAdd(aCBO,{'318810','Modelista de roupas'})
aAdd(aCBO,{'319105','Técnico em calçados e artefatos de couro'})
aAdd(aCBO,{'319110','Técnico em confecções do vestuário'})
aAdd(aCBO,{'319205','Técnico do mobiliário'})
aAdd(aCBO,{'320110','Técnico em histologia'})
aAdd(aCBO,{'320105','Técnico em bioterismo'})
aAdd(aCBO,{'321105','Técnico agrícola'})
aAdd(aCBO,{'321110','Técnico agropecuário'})
aAdd(aCBO,{'321210','Técnico florestal'})
aAdd(aCBO,{'321205','Técnico em madeira'})
aAdd(aCBO,{'321305','Técnico em piscicultura'})
aAdd(aCBO,{'321310','Técnico em carcinicultura'})
aAdd(aCBO,{'321315','Técnico em mitilicultura'})
aAdd(aCBO,{'321320','Técnico em ranicultura'})
aAdd(aCBO,{'322135','Doula'})
aAdd(aCBO,{'322130','Esteticista'})
aAdd(aCBO,{'322125','Terapeuta holístico'})
aAdd(aCBO,{'322115','Técnico em quiropraxia'})
aAdd(aCBO,{'322120','Massoterapeuta'})
aAdd(aCBO,{'322110','Podólogo'})
aAdd(aCBO,{'322105','Técnico em acupuntura'})
aAdd(aCBO,{'322210','Técnico de enfermagem de terapia intensiva'})
aAdd(aCBO,{'322225','Instrumentador cirúrgico'})
aAdd(aCBO,{'322220','Técnico de enfermagem psiquiátrica'})
aAdd(aCBO,{'322250','Auxiliar de enfermagem da estratégia de saúde da família'})
aAdd(aCBO,{'322215','Técnico de enfermagem do trabalho'})
aAdd(aCBO,{'322230','Auxiliar de enfermagem'})
aAdd(aCBO,{'322235','Auxiliar de enfermagem do trabalho'})
aAdd(aCBO,{'322240','Auxiliar de saúde (navegação marítima)'})
aAdd(aCBO,{'322245','Técnico de enfermagem da estratégia de saúde da família'})
aAdd(aCBO,{'322205','Técnico de enfermagem'})
aAdd(aCBO,{'322305','Técnico em óptica e optometria'})
aAdd(aCBO,{'322430','Auxiliar em saúde bucal da estratégia de saúde da família'})
aAdd(aCBO,{'322425','Técnico em saúde bucal da estratégia de saúde da família'})
aAdd(aCBO,{'322420','Auxiliar de prótese dentária'})
aAdd(aCBO,{'322405','Técnico em saúde bucal'})
aAdd(aCBO,{'322410','Protético dentário'})
aAdd(aCBO,{'322415','Auxiliar em saúde bucal'})
aAdd(aCBO,{'322505','Técnico de ortopedia'})
aAdd(aCBO,{'322605','Técnico de imobilização ortopédica'})
aAdd(aCBO,{'323105','Técnico em pecuária'})
aAdd(aCBO,{'324125','Tecnólogo oftálmico'})
aAdd(aCBO,{'324120','Tecnólogo em radiologia'})
aAdd(aCBO,{'324110','Técnico em métodos gráficos em cardiologia'})
aAdd(aCBO,{'324115','Técnico em radiologia e imagenologia'})
aAdd(aCBO,{'324105','Técnico em métodos eletrográficos em encefalografia'})
aAdd(aCBO,{'324205','Técnico em patologia clínica'})
aAdd(aCBO,{'324215','Citotécnico'})
aAdd(aCBO,{'324220','Técnico em hemoterapia'})
aAdd(aCBO,{'325005','Enólogo'})
aAdd(aCBO,{'325010','Aromista'})
aAdd(aCBO,{'325015','Perfumista'})
aAdd(aCBO,{'325105','Auxiliar técnico em laboratório de farmácia'})
aAdd(aCBO,{'325115','Técnico em farmácia'})
aAdd(aCBO,{'325110','Técnico em laboratório de farmácia'})
aAdd(aCBO,{'325210','Técnico em nutrição e dietética'})
aAdd(aCBO,{'325205','Técnico de alimentos'})
aAdd(aCBO,{'325310','Técnico em imunobiológicos'})
aAdd(aCBO,{'325305','Técnico em biotecnologia'})
aAdd(aCBO,{'328110','Taxidermista'})
aAdd(aCBO,{'328105','Embalsamador'})
aAdd(aCBO,{'331105','Professor de nível médio na educação infantil'})
aAdd(aCBO,{'331110','Auxiliar de desenvolvimento infantil'})
aAdd(aCBO,{'331205','Professor de nível médio no ensino fundamental'})
aAdd(aCBO,{'331305','Professor de nível médio no ensino profissionalizante'})
aAdd(aCBO,{'332105','Professor leigo no ensino fundamental'})
aAdd(aCBO,{'332205','Professor prático no ensino profissionalizante'})
aAdd(aCBO,{'333115','Professores de cursos livres'})
aAdd(aCBO,{'333105','Instrutor de auto-escola'})
aAdd(aCBO,{'333110','Instrutor de cursos livres'})
aAdd(aCBO,{'334110','Inspetor de alunos de escola pública'})
aAdd(aCBO,{'334105','Inspetor de alunos de escola privada'})
aAdd(aCBO,{'334115','Monitor de transporte escolar'})
aAdd(aCBO,{'341120','Piloto agrícola'})
aAdd(aCBO,{'341115','Mecânico de vôo'})
aAdd(aCBO,{'341110','Piloto comercial de helicóptero (exceto linhas aéreas)'})
aAdd(aCBO,{'341105','Piloto comercial (exceto linhas aéreas)'})
aAdd(aCBO,{'341225','Patrão de pesca na navegação interior'})
aAdd(aCBO,{'341230','Piloto fluvial'})
aAdd(aCBO,{'341220','Patrão de pesca de alto-mar'})
aAdd(aCBO,{'341205','Contramestre de cabotagem'})
aAdd(aCBO,{'341210','Mestre de cabotagem'})
aAdd(aCBO,{'341215','Mestre fluvial'})
aAdd(aCBO,{'341305','Maquinista motorista fluvial'})
aAdd(aCBO,{'341310','Condutor de máquinas'})
aAdd(aCBO,{'341315','Eletricista de bordo'})
aAdd(aCBO,{'342125','Tecnólogo em logística de transporte'})
aAdd(aCBO,{'342120','Afretador'})
aAdd(aCBO,{'342115','Controlador de serviços de máquinas e veículos'})
aAdd(aCBO,{'342105','Analista de transporte em comércio exterior'})
aAdd(aCBO,{'342110','Operador de transporte multimodal'})
aAdd(aCBO,{'342210','Despachante aduaneiro'})
aAdd(aCBO,{'342205','Ajudante de despachante aduaneiro'})
aAdd(aCBO,{'342315','Supervisor de carga e descarga'})
aAdd(aCBO,{'342310','Inspetor de serviços de transportes rodoviários (passageiros e cargas)'})
aAdd(aCBO,{'342305','Chefe de serviço de transporte rodoviário (passageiros e cargas)'})
aAdd(aCBO,{'342405','Agente de estação (ferrovia e metrô)'})
aAdd(aCBO,{'342410','Operador de centro de controle (ferrovia e metrô)'})
aAdd(aCBO,{'342550','Agente de proteção de aviação civil'})
aAdd(aCBO,{'342545','Supervisor de empresa aérea em aeroportos'})
aAdd(aCBO,{'342505','Controlador de tráfego aéreo'})
aAdd(aCBO,{'342510','Despachante operacional de vôo'})
aAdd(aCBO,{'342515','Fiscal de aviação civil (fac)'})
aAdd(aCBO,{'342520','Gerente da administração de aeroportos'})
aAdd(aCBO,{'342525','Gerente de empresa aérea em aeroportos'})
aAdd(aCBO,{'342530','Inspetor de aviação civil'})
aAdd(aCBO,{'342540','Supervisor da administração de aeroportos'})
aAdd(aCBO,{'342535','Operador de atendimento aeroviário'})
aAdd(aCBO,{'342605','Chefe de estação portuária'})
aAdd(aCBO,{'342610','Supervisor de operações portuárias'})
aAdd(aCBO,{'351115','Consultor contábil (técnico)'})
aAdd(aCBO,{'351105','Técnico de contabilidade'})
aAdd(aCBO,{'351110','Chefe de contabilidade (técnico)'})
aAdd(aCBO,{'351310','Técnico em administração de comércio exterior'})
aAdd(aCBO,{'351315','Agente de recrutamento e seleção'})
aAdd(aCBO,{'351305','Técnico em administração'})
aAdd(aCBO,{'351420','Escrivão de polícia'})
aAdd(aCBO,{'351410','Escrivão judicial'})
aAdd(aCBO,{'351405','Escrevente'})
aAdd(aCBO,{'351415','Escrivão extra - judicial'})
aAdd(aCBO,{'351430','Auxiliar de serviços jurídicos'})
aAdd(aCBO,{'351425','Oficial de justiça'})
aAdd(aCBO,{'351515','Estenotipista'})
aAdd(aCBO,{'351510','Taquígrafo'})
aAdd(aCBO,{'351505','Técnico em secretariado'})
aAdd(aCBO,{'351605','Técnico em segurança do trabalho'})
aAdd(aCBO,{'351705','Analista de seguros (técnico)'})
aAdd(aCBO,{'351715','Assistente comercial de seguros'})
aAdd(aCBO,{'351720','Assistente técnico de seguros'})
aAdd(aCBO,{'351725','Inspetor de risco'})
aAdd(aCBO,{'351730','Inspetor de sinistros'})
aAdd(aCBO,{'351735','Técnico de resseguros'})
aAdd(aCBO,{'351710','Analista de sinistros'})
aAdd(aCBO,{'351740','Técnico de seguros'})
aAdd(aCBO,{'351815','Papiloscopista policial'})
aAdd(aCBO,{'351810','Investigador de polícia'})
aAdd(aCBO,{'351805','Detetive profissional'})
aAdd(aCBO,{'351910','Agente técnico de inteligência'})
aAdd(aCBO,{'351905','Agente de inteligência'})
aAdd(aCBO,{'352210','Agente de saúde pública'})
aAdd(aCBO,{'352205','Agente de defesa ambiental'})
aAdd(aCBO,{'352310','Agente fiscal de qualidade'})
aAdd(aCBO,{'352315','Agente fiscal metrológico'})
aAdd(aCBO,{'352320','Agente fiscal têxtil'})
aAdd(aCBO,{'352305','Metrologista'})
aAdd(aCBO,{'352420','Técnico em direitos autorais'})
aAdd(aCBO,{'352405','Agente de direitos autorais'})
aAdd(aCBO,{'352410','Avaliador de produtos do meio de comunicação'})
aAdd(aCBO,{'353230','Tesoureiro de banco'})
aAdd(aCBO,{'353225','Técnico de operações e serviços bancários - renda fixa e variável'})
aAdd(aCBO,{'353220','Técnico de operações e serviços bancários - leasing'})
aAdd(aCBO,{'353215','Técnico de operações e serviços bancários - crédito rural'})
aAdd(aCBO,{'353210','Técnico de operações e serviços bancários - crédito imobiliário'})
aAdd(aCBO,{'353205','Técnico de operações e serviços bancários - câmbio'})
aAdd(aCBO,{'353235','Chefe de serviços bancários'})
aAdd(aCBO,{'354120','Agente de vendas de serviços'})
aAdd(aCBO,{'354125','Assistente de vendas'})
aAdd(aCBO,{'354130','Promotor de vendas especializado'})
aAdd(aCBO,{'354135','Técnico de vendas'})
aAdd(aCBO,{'354150','Propagandista de produtos famacêuticos'})
aAdd(aCBO,{'354145','Vendedor pracista'})
aAdd(aCBO,{'354140','Técnico em atendimento e vendas'})
aAdd(aCBO,{'354205','Comprador'})
aAdd(aCBO,{'354210','Supervisor de compras'})
aAdd(aCBO,{'354305','Analista de exportação e importação'})
aAdd(aCBO,{'354405','Leiloeiro'})
aAdd(aCBO,{'354410','Avaliador de imóveis'})
aAdd(aCBO,{'354415','Avaliador de bens móveis'})
aAdd(aCBO,{'354505','Corretor de seguros'})
aAdd(aCBO,{'354605','Corretor de imóveis'})
aAdd(aCBO,{'354705','Representante comercial autônomo'})
aAdd(aCBO,{'354820','Organizador de evento'})
aAdd(aCBO,{'354815','Agente de viagem'})
aAdd(aCBO,{'354805','Técnico em turismo'})
aAdd(aCBO,{'354810','Operador de turismo'})
aAdd(aCBO,{'371105','Auxiliar de biblioteca'})
aAdd(aCBO,{'371110','Técnico em biblioteconomia'})
aAdd(aCBO,{'371205','Colecionador de selos e moedas'})
aAdd(aCBO,{'371210','Técnico em museologia'})
aAdd(aCBO,{'371305','Técnico em programação visual'})
aAdd(aCBO,{'371310','Técnico gráfico'})
aAdd(aCBO,{'371405','Recreador de acantonamento'})
aAdd(aCBO,{'371410','Recreador'})
aAdd(aCBO,{'372105','Diretor de fotografia'})
aAdd(aCBO,{'372115','Operador de câmera de televisão'})
aAdd(aCBO,{'372110','Iluminador (televisão)'})
aAdd(aCBO,{'372205','Operador de rede de teleprocessamento'})
aAdd(aCBO,{'372210','Radiotelegrafista'})
aAdd(aCBO,{'373105','Operador de áudio de continuidade (rádio)'})
aAdd(aCBO,{'373110','Operador de central de rádio'})
aAdd(aCBO,{'373120','Operador de gravação de rádio'})
aAdd(aCBO,{'373115','Operador de externa (rádio)'})
aAdd(aCBO,{'373125','Operador de transmissor de rádio'})
aAdd(aCBO,{'373215','Técnico em operação de equipamentos de transmissão/recepção de televisão'})
aAdd(aCBO,{'373220','Supervisor técnico operacional de sistemas de televisão e produtoras de vídeo'})
aAdd(aCBO,{'373205','Técnico em operação de equipamentos de produção para televisão e produtoras de vídeo'})
aAdd(aCBO,{'373210','Técnico em operação de equipamento de exibição de televisão'})
aAdd(aCBO,{'374145','Dj (disc jockey)'})
aAdd(aCBO,{'374105','Técnico em gravação de áudio'})
aAdd(aCBO,{'374140','Microfonista'})
aAdd(aCBO,{'374135','Projetista de sistemas de áudio'})
aAdd(aCBO,{'374110','Técnico em instalação de equipamentos de áudio'})
aAdd(aCBO,{'374125','Técnico em sonorização'})
aAdd(aCBO,{'374120','Projetista de som'})
aAdd(aCBO,{'374115','Técnico em masterização de áudio'})
aAdd(aCBO,{'374130','Técnico em mixagem de áudio'})
aAdd(aCBO,{'374215','Maquinista de teatro e espetáculos'})
aAdd(aCBO,{'374205','Cenotécnico (cinema, vídeo, televisão, teatro e espetáculos)'})
aAdd(aCBO,{'374210','Maquinista de cinema e vídeo'})
aAdd(aCBO,{'374310','Operador-mantenedor de projetor cinematográfico'})
aAdd(aCBO,{'374305','Operador de projetor cinematográfico'})
aAdd(aCBO,{'374405','Editor de tv e vídeo'})
aAdd(aCBO,{'374410','Finalizador de filmes'})
aAdd(aCBO,{'374415','Finalizador de vídeo'})
aAdd(aCBO,{'374420','Montador de filmes'})
aAdd(aCBO,{'375120','Decorador de eventos'})
aAdd(aCBO,{'375115','Visual merchandiser'})
aAdd(aCBO,{'375110','Designer de vitrines'})
aAdd(aCBO,{'375105','Designer de interiores'})
aAdd(aCBO,{'376105','Dançarino tradicional'})
aAdd(aCBO,{'376110','Dançarino popular'})
aAdd(aCBO,{'376215','Artista de circo (outros)'})
aAdd(aCBO,{'376210','Artista aéreo'})
aAdd(aCBO,{'376205','Acrobata'})
aAdd(aCBO,{'376225','Domador de animais (circense)'})
aAdd(aCBO,{'376230','Equilibrista'})
aAdd(aCBO,{'376235','Mágico'})
aAdd(aCBO,{'376240','Malabarista'})
aAdd(aCBO,{'376245','Palhaço'})
aAdd(aCBO,{'376220','Contorcionista'})
aAdd(aCBO,{'376255','Trapezista'})
aAdd(aCBO,{'376250','Titeriteiro'})
aAdd(aCBO,{'376305','Apresentador de eventos'})
aAdd(aCBO,{'376310','Apresentador de festas populares'})
aAdd(aCBO,{'376315','Apresentador de programas de rádio'})
aAdd(aCBO,{'376320','Apresentador de programas de televisão'})
aAdd(aCBO,{'376325','Apresentador de circo'})
aAdd(aCBO,{'376410','Modelo de modas'})
aAdd(aCBO,{'376415','Modelo publicitário'})
aAdd(aCBO,{'376405','Modelo artístico'})
aAdd(aCBO,{'377140','Profissional de atletismo'})
aAdd(aCBO,{'377145','Pugilista'})
aAdd(aCBO,{'377135','Piloto de competição automobilística'})
aAdd(aCBO,{'377130','Jóquei'})
aAdd(aCBO,{'377125','Atleta profissional de tênis'})
aAdd(aCBO,{'377120','Atleta profissional de luta'})
aAdd(aCBO,{'377115','Atleta profissional de golfe'})
aAdd(aCBO,{'377110','Atleta profissional de futebol'})
aAdd(aCBO,{'377105','Atleta profissional (outras modalidades)'})
aAdd(aCBO,{'377205','Árbitro desportivo'})
aAdd(aCBO,{'377210','Árbitro de atletismo'})
aAdd(aCBO,{'377215','Árbitro de basquete'})
aAdd(aCBO,{'377220','Árbitro de futebol'})
aAdd(aCBO,{'377245','Árbitro de vôlei'})
aAdd(aCBO,{'377230','Árbitro de judô'})
aAdd(aCBO,{'377235','Árbitro de karatê'})
aAdd(aCBO,{'377240','Árbitro de poló aquático'})
aAdd(aCBO,{'377225','Árbitro de futebol de salão'})
aAdd(aCBO,{'391105','Cronoanalista'})
aAdd(aCBO,{'391110','Cronometrista'})
aAdd(aCBO,{'391115','Controlador de entrada e saída'})
aAdd(aCBO,{'391120','Planejista'})
aAdd(aCBO,{'391125','Técnico de planejamento de produção'})
aAdd(aCBO,{'391130','Técnico de planejamento e programação da manutenção'})
aAdd(aCBO,{'391135','Técnico de matéria-prima e material'})
aAdd(aCBO,{'391205','Inspetor de qualidade'})
aAdd(aCBO,{'391230','Técnico operacional de serviços de correios'})
aAdd(aCBO,{'391210','Técnico de garantia da qualidade'})
aAdd(aCBO,{'391215','Operador de inspeção de qualidade'})
aAdd(aCBO,{'391220','Técnico de painel de controle'})
aAdd(aCBO,{'391225','Escolhedor de papel'})
aAdd(aCBO,{'395105','Técnico de apoio em pesquisa e desenvolvimento (exceto agropecuário e florestal)'})
aAdd(aCBO,{'395110','Técnico de apoio em pesquisa e desenvolvimento agropecuário florestal'})
aAdd(aCBO,{'410105','Supervisor administrativo'})
aAdd(aCBO,{'410230','Supervisor de orçamento'})
aAdd(aCBO,{'410225','Supervisor de crédito e cobrança'})
aAdd(aCBO,{'410220','Supervisor de controle patrimonial'})
aAdd(aCBO,{'410215','Supervisor de contas a pagar'})
aAdd(aCBO,{'410210','Supervisor de câmbio'})
aAdd(aCBO,{'410205','Supervisor de almoxarifado'})
aAdd(aCBO,{'410235','Supervisor de tesouraria'})
aAdd(aCBO,{'411050','Agente de microcrédito'})
aAdd(aCBO,{'411045','Auxiliar de serviços de importação e exportação'})
aAdd(aCBO,{'411040','Auxiliar de seguros'})
aAdd(aCBO,{'411035','Auxiliar de estatística'})
aAdd(aCBO,{'411030','Auxiliar de pessoal'})
aAdd(aCBO,{'411025','Auxiliar de cartório'})
aAdd(aCBO,{'411005','Auxiliar de escritório, em geral'})
aAdd(aCBO,{'411010','Assistente administrativo'})
aAdd(aCBO,{'411020','Auxiliar de judiciário'})
aAdd(aCBO,{'411015','Atendente de judiciário'})
aAdd(aCBO,{'412105','Datilógrafo'})
aAdd(aCBO,{'412110','Digitador'})
aAdd(aCBO,{'412115','Operador de mensagens de telecomunicações (correios)'})
aAdd(aCBO,{'412120','Supervisor de digitação e operação'})
aAdd(aCBO,{'412205','Contínuo'})
aAdd(aCBO,{'413105','Analista de folha de pagamento'})
aAdd(aCBO,{'413110','Auxiliar de contabilidade'})
aAdd(aCBO,{'413115','Auxiliar de faturamento'})
aAdd(aCBO,{'413220','Conferente de serviços bancários'})
aAdd(aCBO,{'413215','Compensador de banco'})
aAdd(aCBO,{'413210','Caixa de banco'})
aAdd(aCBO,{'413205','Atendente de agência'})
aAdd(aCBO,{'413225','Escriturário de banco'})
aAdd(aCBO,{'413230','Operador de cobrança bancária'})
aAdd(aCBO,{'414105','Almoxarife'})
aAdd(aCBO,{'414110','Armazenista'})
aAdd(aCBO,{'414115','Balanceiro'})
aAdd(aCBO,{'414205','Apontador de mão-de-obra'})
aAdd(aCBO,{'414210','Apontador de produção'})
aAdd(aCBO,{'414215','Conferente de carga e descarga'})
aAdd(aCBO,{'415105','Arquivista de documentos'})
aAdd(aCBO,{'415130','Operador de máquina copiadora (exceto operador de gráfica rápida)'})
aAdd(aCBO,{'415115','Codificador de dados'})
aAdd(aCBO,{'415120','Fitotecário'})
aAdd(aCBO,{'415125','Kardexista'})
aAdd(aCBO,{'415205','Carteiro'})
aAdd(aCBO,{'415210','Operador de triagem e transbordo'})
aAdd(aCBO,{'420105','Supervisor de caixas e bilheteiros (exceto caixa de banco)'})
aAdd(aCBO,{'420110','Supervisor de cobrança'})
aAdd(aCBO,{'420135','Supervisor de telemarketing e atendimento'})
aAdd(aCBO,{'420130','Supervisor de telefonistas'})
aAdd(aCBO,{'420125','Supervisor de recepcionistas'})
aAdd(aCBO,{'420120','Supervisor de entrevistadores e recenseadores'})
aAdd(aCBO,{'420115','Supervisor de coletadores de apostas e de jogos'})
aAdd(aCBO,{'421125','Operador de caixa'})
aAdd(aCBO,{'421115','Bilheteiro no serviço de diversões'})
aAdd(aCBO,{'421120','Emissor de passagens'})
aAdd(aCBO,{'421105','Atendente comercial (agência postal)'})
aAdd(aCBO,{'421110','Bilheteiro de transportes coletivos'})
aAdd(aCBO,{'421205','Recebedor de apostas (loteria)'})
aAdd(aCBO,{'421210','Recebedor de apostas (turfe)'})
aAdd(aCBO,{'421305','Cobrador externo'})
aAdd(aCBO,{'421315','Localizador (cobrador)'})
aAdd(aCBO,{'421310','Cobrador interno'})
aAdd(aCBO,{'422120','Recepcionista de hotel'})
aAdd(aCBO,{'422125','Recepcionista de banco'})
aAdd(aCBO,{'422105','Recepcionista, em geral'})
aAdd(aCBO,{'422110','Recepcionista de consultório médico ou dentário'})
aAdd(aCBO,{'422115','Recepcionista de seguro saúde'})
aAdd(aCBO,{'422205','Telefonista'})
aAdd(aCBO,{'422210','Teleoperador'})
aAdd(aCBO,{'422215','Monitor de teleatendimento'})
aAdd(aCBO,{'422220','Operador de rádio-chamada'})
aAdd(aCBO,{'422310','Operador de telemarketing ativo e receptivo'})
aAdd(aCBO,{'422320','Operador de telemarketing técnico'})
aAdd(aCBO,{'422315','Operador de telemarketing receptivo'})
aAdd(aCBO,{'422305','Operador de telemarketing ativo'})
aAdd(aCBO,{'423110','Despachante de trânsito'})
aAdd(aCBO,{'423105','Despachante documentalista'})
aAdd(aCBO,{'424115','Entrevistador de pesquisas de mercado'})
aAdd(aCBO,{'424120','Entrevistador de preços'})
aAdd(aCBO,{'424105','Entrevistador censitário e de pesquisas amostrais'})
aAdd(aCBO,{'424125','Escriturário em estatística'})
aAdd(aCBO,{'424110','Entrevistador de pesquisa de opinião e mídia'})
aAdd(aCBO,{'510105','Supervisor de transportes'})
aAdd(aCBO,{'510135','Maître'})
aAdd(aCBO,{'510130','Chefe de bar'})
aAdd(aCBO,{'510120','Chefe de portaria de hotel'})
aAdd(aCBO,{'510115','Supervisor de andar'})
aAdd(aCBO,{'510110','Administrador de edifícios'})
aAdd(aCBO,{'510205','Supervisor de lavanderia'})
aAdd(aCBO,{'510310','Supervisor de vigilantes'})
aAdd(aCBO,{'510305','Supervisor de bombeiros'})
aAdd(aCBO,{'511105','Comissário de vôo'})
aAdd(aCBO,{'511110','Comissário de trem'})
aAdd(aCBO,{'511115','Taifeiro (exceto militares)'})
aAdd(aCBO,{'511220','Bilheteiro (estações de metrô, ferroviárias e assemelhadas)'})
aAdd(aCBO,{'511215','Cobrador de transportes coletivos (exceto trem)'})
aAdd(aCBO,{'511205','Fiscal de transportes coletivos (exceto trem)'})
aAdd(aCBO,{'511210','Despachante de transportes coletivos (exceto trem)'})
aAdd(aCBO,{'511405','Guia de turismo'})
aAdd(aCBO,{'512120','Empregado doméstico diarista'})
aAdd(aCBO,{'512110','Empregado doméstico arrumador'})
aAdd(aCBO,{'512105','Empregado doméstico nos serviços gerais'})
aAdd(aCBO,{'512115','Empregado doméstico faxineiro'})
aAdd(aCBO,{'513115','Governanta de hotelaria'})
aAdd(aCBO,{'513110','Mordomo de hotelaria'})
aAdd(aCBO,{'513105','Mordomo de residência'})
aAdd(aCBO,{'513205','Cozinheiro geral'})
aAdd(aCBO,{'513210','Cozinheiro do serviço doméstico'})
aAdd(aCBO,{'513215','Cozinheiro industrial'})
aAdd(aCBO,{'513220','Cozinheiro de hospital'})
aAdd(aCBO,{'513225','Cozinheiro de embarcações'})
aAdd(aCBO,{'513325','Guarda-roupeira de cinema'})
aAdd(aCBO,{'513305','Camareira de teatro'})
aAdd(aCBO,{'513310','Camareira de televisão'})
aAdd(aCBO,{'513315','Camareiro de hotel'})
aAdd(aCBO,{'513320','Camareiro de embarcações'})
aAdd(aCBO,{'513415','Cumim'})
aAdd(aCBO,{'513410','Garçom (serviços de vinhos)'})
aAdd(aCBO,{'513420','Barman'})
aAdd(aCBO,{'513425','Copeiro'})
aAdd(aCBO,{'513430','Copeiro de hospital'})
aAdd(aCBO,{'513405','Garçom'})
aAdd(aCBO,{'513440','Barista'})
aAdd(aCBO,{'513435','Atendente de lanchonete'})
aAdd(aCBO,{'513505','Auxiliar nos serviços de alimentação'})
aAdd(aCBO,{'513615','Sushiman'})
aAdd(aCBO,{'513610','Pizzaiolo'})
aAdd(aCBO,{'513605','Churrasqueiro'})
aAdd(aCBO,{'514115','Sacristão'})
aAdd(aCBO,{'514110','Garagista'})
aAdd(aCBO,{'514105','Ascensorista'})
aAdd(aCBO,{'514120','Zelador de edifício'})
aAdd(aCBO,{'514205','Coletor de lixo domiciliar'})
aAdd(aCBO,{'514230','Coletor de resíduos sólidos de serviços de saúde'})
aAdd(aCBO,{'514225','Trabalhador de serviços de limpeza e conservação de áreas públicas'})
aAdd(aCBO,{'514215','Varredor de rua'})
aAdd(aCBO,{'514315','Limpador de fachadas'})
aAdd(aCBO,{'514325','Trabalhador da manutenção de edificações'})
aAdd(aCBO,{'514305','Limpador de vidros'})
aAdd(aCBO,{'514310','Auxiliar de manutenção predial'})
aAdd(aCBO,{'514330','Limpador de piscinas'})
aAdd(aCBO,{'514320','Faxineiro'})
aAdd(aCBO,{'515130','Agente indígena de saneamento'})
aAdd(aCBO,{'515135','Socorrista (exceto médicos e enfermeiros)'})
aAdd(aCBO,{'515105','Agente comunitário de saúde'})
aAdd(aCBO,{'515125','Agente indígena de saúde'})
aAdd(aCBO,{'515115','Parteira leiga'})
aAdd(aCBO,{'515120','Visitador sanitário'})
aAdd(aCBO,{'515110','Atendente de enfermagem'})
aAdd(aCBO,{'515210','Auxiliar de farmácia de manipulação'})
aAdd(aCBO,{'515215','Auxiliar de laboratório de análises clínicas'})
aAdd(aCBO,{'515220','Auxiliar de laboratório de imunobiológicos'})
aAdd(aCBO,{'515225','Auxiliar de produção farmacêutica'})
aAdd(aCBO,{'515205','Auxiliar de banco de sangue'})
aAdd(aCBO,{'515305','Educador social'})
aAdd(aCBO,{'515310','Agente de ação social'})
aAdd(aCBO,{'515315','Monitor de dependente químico'})
aAdd(aCBO,{'515320','Conselheiro tutelar'})
aAdd(aCBO,{'515325','Sócioeducador'})
aAdd(aCBO,{'516140','Pedicure'})
aAdd(aCBO,{'516130','Maquiador de caracterização'})
aAdd(aCBO,{'516125','Maquiador'})
aAdd(aCBO,{'516120','Manicure'})
aAdd(aCBO,{'516110','Cabeleireiro'})
aAdd(aCBO,{'516105','Barbeiro'})
aAdd(aCBO,{'516205','Babá'})
aAdd(aCBO,{'516220','Cuidador em saúde'})
aAdd(aCBO,{'516215','Mãe social'})
aAdd(aCBO,{'516210','Cuidador de idosos'})
aAdd(aCBO,{'516325','Passador de roupas em geral'})
aAdd(aCBO,{'516320','Limpador a seco, à máquina'})
aAdd(aCBO,{'516315','Lavador de artefatos de tapeçaria'})
aAdd(aCBO,{'516310','Lavador de roupas a maquina'})
aAdd(aCBO,{'516305','Lavadeiro, em geral'})
aAdd(aCBO,{'516330','Tingidor de roupas'})
aAdd(aCBO,{'516345','Auxiliar de lavanderia'})
aAdd(aCBO,{'516340','Atendente de lavanderia'})
aAdd(aCBO,{'516335','Conferente-expedidor de roupas (lavanderias)'})
aAdd(aCBO,{'516410','Limpador de roupas a seco, à mão'})
aAdd(aCBO,{'516405','Lavador de roupas'})
aAdd(aCBO,{'516415','Passador de roupas, à mão'})
aAdd(aCBO,{'516505','Agente funerário'})
aAdd(aCBO,{'516605','Operador de forno (serviços funerários)'})
aAdd(aCBO,{'516610','Sepultador'})
aAdd(aCBO,{'516710','Numerólogo'})
aAdd(aCBO,{'516705','Astrólogo'})
aAdd(aCBO,{'516805','Esotérico'})
aAdd(aCBO,{'516810','Paranormal'})
aAdd(aCBO,{'517105','Bombeiro de aeródromo'})
aAdd(aCBO,{'517110','Bombeiro civil'})
aAdd(aCBO,{'517115','Salva-vidas'})
aAdd(aCBO,{'517220','Agente de trânsito'})
aAdd(aCBO,{'517210','Policial rodoviário federal'})
aAdd(aCBO,{'517205','Agente de polícia federal'})
aAdd(aCBO,{'517215','Guarda-civil municipal'})
aAdd(aCBO,{'517330','Vigilante'})
aAdd(aCBO,{'517305','Agente de proteção de aeroporto'})
aAdd(aCBO,{'517310','Agente de segurança'})
aAdd(aCBO,{'517335','Guarda portuário'})
aAdd(aCBO,{'517315','Agente de segurança penitenciária'})
aAdd(aCBO,{'517320','Vigia florestal'})
aAdd(aCBO,{'517325','Vigia portuário'})
aAdd(aCBO,{'517415','Porteiro de locais de diversão'})
aAdd(aCBO,{'517425','Fiscal de loja'})
aAdd(aCBO,{'517405','Porteiro (hotel)'})
aAdd(aCBO,{'517410','Porteiro de edifícios'})
aAdd(aCBO,{'517420','Vigia'})
aAdd(aCBO,{'519105','Ciclista mensageiro'})
aAdd(aCBO,{'519110','Motociclista no transporte de pessoas, documentos e pequenos volumes'})
aAdd(aCBO,{'519210','Selecionador de material reciclável'})
aAdd(aCBO,{'519215','Operador de prensa de material reciclável'})
aAdd(aCBO,{'519205','Catador de material reciclável'})
aAdd(aCBO,{'519315','Banhista de animais domésticos'})
aAdd(aCBO,{'519320','Tosador de animais domésticos'})
aAdd(aCBO,{'519310','Esteticista de animais domésticos'})
aAdd(aCBO,{'519305','Auxiliar de veterinário'})
aAdd(aCBO,{'519805','Profissional do sexo'})
aAdd(aCBO,{'519925','Guardador de veículos'})
aAdd(aCBO,{'519930','Lavador de garrafas, vidros e outros utensílios'})
aAdd(aCBO,{'519935','Lavador de veículos'})
aAdd(aCBO,{'519945','Recepcionista de casas de espetáculos'})
aAdd(aCBO,{'519915','Engraxate'})
aAdd(aCBO,{'519910','Controlador de pragas'})
aAdd(aCBO,{'519905','Cartazeiro'})
aAdd(aCBO,{'519920','Gandula'})
aAdd(aCBO,{'519940','Leiturista'})
aAdd(aCBO,{'520105','Supervisor de vendas de serviços'})
aAdd(aCBO,{'520110','Supervisor de vendas comercial'})
aAdd(aCBO,{'521130','Atendente de farmácia - balconista'})
aAdd(aCBO,{'521135','Frentista'})
aAdd(aCBO,{'521125','Repositor de mercadorias'})
aAdd(aCBO,{'521120','Demonstrador de mercadorias'})
aAdd(aCBO,{'521115','Promotor de vendas'})
aAdd(aCBO,{'521110','Vendedor de comércio varejista'})
aAdd(aCBO,{'521105','Vendedor em comércio atacadista'})
aAdd(aCBO,{'521140','Atendente de lojas e mercados'})
aAdd(aCBO,{'523105','Instalador de cortinas e persianas, portas sanfonadas e boxe'})
aAdd(aCBO,{'523110','Instalador de som e acessórios de veículos'})
aAdd(aCBO,{'523115','Chaveiro'})
aAdd(aCBO,{'524105','Vendedor em domicílio'})
aAdd(aCBO,{'524210','Jornaleiro (em banca de jornal)'})
aAdd(aCBO,{'524215','Vendedor permissionário'})
aAdd(aCBO,{'524205','Feirante'})
aAdd(aCBO,{'524310','Pipoqueiro ambulante'})
aAdd(aCBO,{'524305','Vendedor ambulante'})
aAdd(aCBO,{'611005','Produtor agropecuário, em geral'})
aAdd(aCBO,{'612005','Produtor agrícola polivalente'})
aAdd(aCBO,{'612105','Produtor de arroz'})
aAdd(aCBO,{'612110','Produtor de cana-de-açúcar'})
aAdd(aCBO,{'612115','Produtor de cereais de inverno'})
aAdd(aCBO,{'612125','Produtor de milho e sorgo'})
aAdd(aCBO,{'612120','Produtor de gramíneas forrageiras'})
aAdd(aCBO,{'612205','Produtor de algodão'})
aAdd(aCBO,{'612210','Produtor de curauá'})
aAdd(aCBO,{'612215','Produtor de juta'})
aAdd(aCBO,{'612225','Produtor de sisal'})
aAdd(aCBO,{'612220','Produtor de rami'})
aAdd(aCBO,{'612320','Produtor na olericultura de frutos e sementes'})
aAdd(aCBO,{'612315','Produtor na olericultura de talos, folhas e flores'})
aAdd(aCBO,{'612310','Produtor na olericultura de raízes, bulbos e tubérculos'})
aAdd(aCBO,{'612305','Produtor na olericultura de legumes'})
aAdd(aCBO,{'612415','Produtor de forrações'})
aAdd(aCBO,{'612420','Produtor de plantas ornamentais'})
aAdd(aCBO,{'612410','Produtor de flores em vaso'})
aAdd(aCBO,{'612405','Produtor de flores de corte'})
aAdd(aCBO,{'612515','Produtor de espécies frutíferas trepadeiras'})
aAdd(aCBO,{'612510','Produtor de espécies frutíferas rasteiras'})
aAdd(aCBO,{'612505','Produtor de árvores frutíferas'})
aAdd(aCBO,{'612625','Produtor de guaraná'})
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
aAdd(aCBO,{'612720','Produtor da cultura de dendê'})
aAdd(aCBO,{'612810','Produtor de plantas aromáticas e medicinais'})
aAdd(aCBO,{'612805','Produtor de especiarias'})
aAdd(aCBO,{'613010','Criador de animais domésticos'})
aAdd(aCBO,{'613005','Criador em pecuária polivalente'})
aAdd(aCBO,{'613120','Criador de bubalinos (corte)'})
aAdd(aCBO,{'613125','Criador de bubalinos (leite)'})
aAdd(aCBO,{'613115','Criador de bovinos (leite)'})
aAdd(aCBO,{'613110','Criador de bovinos (corte)'})
aAdd(aCBO,{'613105','Criador de asininos e muares'})
aAdd(aCBO,{'613130','Criador de eqüínos'})
aAdd(aCBO,{'613210','Criador de ovinos'})
aAdd(aCBO,{'613215','Criador de suínos'})
aAdd(aCBO,{'613205','Criador de caprinos'})
aAdd(aCBO,{'613310','Cunicultor'})
aAdd(aCBO,{'613305','Avicultor'})
aAdd(aCBO,{'613415','Minhocultor'})
aAdd(aCBO,{'613420','Sericultor'})
aAdd(aCBO,{'613410','Criador de animais produtores de veneno'})
aAdd(aCBO,{'613405','Apicultor'})
aAdd(aCBO,{'620105','Supervisor de exploração agrícola'})
aAdd(aCBO,{'620110','Supervisor de exploração agropecuária'})
aAdd(aCBO,{'620115','Supervisor de exploração pecuária'})
aAdd(aCBO,{'621005','Trabalhador agropecuário em geral'})
aAdd(aCBO,{'622005','Caseiro (agricultura)'})
aAdd(aCBO,{'622010','Jardineiro'})
aAdd(aCBO,{'622020','Trabalhador volante da agricultura'})
aAdd(aCBO,{'622015','Trabalhador na produção de mudas e sementes'})
aAdd(aCBO,{'622105','Trabalhador da cultura de arroz'})
aAdd(aCBO,{'622115','Trabalhador da cultura de milho e sorgo'})
aAdd(aCBO,{'622110','Trabalhador da cultura de cana-de-açúcar'})
aAdd(aCBO,{'622120','Trabalhador da cultura de trigo, aveia, cevada e triticale'})
aAdd(aCBO,{'622205','Trabalhador da cultura de algodão'})
aAdd(aCBO,{'622210','Trabalhador da cultura de sisal'})
aAdd(aCBO,{'622215','Trabalhador da cultura do rami'})
aAdd(aCBO,{'622305','Trabalhador na olericultura (frutos e sementes)'})
aAdd(aCBO,{'622310','Trabalhador na olericultura (legumes)'})
aAdd(aCBO,{'622315','Trabalhador na olericultura (raízes, bulbos e tubérculos)'})
aAdd(aCBO,{'622320','Trabalhador na olericultura (talos, folhas e flores)'})
aAdd(aCBO,{'622405','Trabalhador no cultivo de flores e folhagens de corte'})
aAdd(aCBO,{'622410','Trabalhador no cultivo de flores em vaso'})
aAdd(aCBO,{'622425','Trabalhador no cultivo de plantas ornamentais'})
aAdd(aCBO,{'622420','Trabalhador no cultivo de mudas'})
aAdd(aCBO,{'622415','Trabalhador no cultivo de forrações'})
aAdd(aCBO,{'622505','Trabalhador no cultivo de árvores frutíferas'})
aAdd(aCBO,{'622510','Trabalhador no cultivo de espécies frutíferas rasteiras'})
aAdd(aCBO,{'622515','Trabalhador no cultivo de trepadeiras frutíferas'})
aAdd(aCBO,{'622605','Trabalhador da cultura de cacau'})
aAdd(aCBO,{'622610','Trabalhador da cultura de café'})
aAdd(aCBO,{'622615','Trabalhador da cultura de erva-mate'})
aAdd(aCBO,{'622620','Trabalhador da cultura de fumo'})
aAdd(aCBO,{'622625','Trabalhador da cultura de guaraná'})
aAdd(aCBO,{'622740','Trabalhador na cultura do linho'})
aAdd(aCBO,{'622735','Trabalhador na cultura do girassol'})
aAdd(aCBO,{'622730','Trabalhador na cultura de soja'})
aAdd(aCBO,{'622725','Trabalhador na cultura de mamona'})
aAdd(aCBO,{'622720','Trabalhador na cultura de dendê'})
aAdd(aCBO,{'622715','Trabalhador na cultura de coco-da-baía'})
aAdd(aCBO,{'622710','Trabalhador na cultura de canola'})
aAdd(aCBO,{'622705','Trabalhador na cultura de amendoim'})
aAdd(aCBO,{'622805','Trabalhador da cultura de especiarias'})
aAdd(aCBO,{'622810','Trabalhador da cultura de plantas aromáticas e medicinais'})
aAdd(aCBO,{'623005','Adestrador de animais'})
aAdd(aCBO,{'623015','Trabalhador de pecuária polivalente'})
aAdd(aCBO,{'623010','Inseminador'})
aAdd(aCBO,{'623020','Tratador de animais'})
aAdd(aCBO,{'623125','Trabalhador da pecuária (eqüinos)'})
aAdd(aCBO,{'623120','Trabalhador da pecuária (bubalinos)'})
aAdd(aCBO,{'623110','Trabalhador da pecuária (bovinos corte)'})
aAdd(aCBO,{'623105','Trabalhador da pecuária (asininos e muares)'})
aAdd(aCBO,{'623115','Trabalhador da pecuária (bovinos leite)'})
aAdd(aCBO,{'623210','Trabalhador da ovinocultura'})
aAdd(aCBO,{'623215','Trabalhador da suinocultura'})
aAdd(aCBO,{'623205','Trabalhador da caprinocultura'})
aAdd(aCBO,{'623320','Trabalhador da cunicultura'})
aAdd(aCBO,{'623315','Operador de incubadora'})
aAdd(aCBO,{'623310','Trabalhador da avicultura de postura'})
aAdd(aCBO,{'623305','Trabalhador da avicultura de corte'})
aAdd(aCBO,{'623325','Sexador'})
aAdd(aCBO,{'623405','Trabalhador em criatórios de animais produtores de veneno'})
aAdd(aCBO,{'623415','Trabalhador na minhocultura'})
aAdd(aCBO,{'623420','Trabalhador na sericicultura'})
aAdd(aCBO,{'623410','Trabalhador na apicultura'})
aAdd(aCBO,{'630105','Supervisor da aqüicultura'})
aAdd(aCBO,{'630110','Supervisor da área florestal'})
aAdd(aCBO,{'631020','Pescador artesanal de peixes e camarões'})
aAdd(aCBO,{'631015','Pescador artesanal de lagostas'})
aAdd(aCBO,{'631005','Catador de caranguejos e siris'})
aAdd(aCBO,{'631010','Catador de mariscos'})
aAdd(aCBO,{'631105','Pescador artesanal de água doce'})
aAdd(aCBO,{'631205','Pescador industrial'})
aAdd(aCBO,{'631210','Pescador profissional'})
aAdd(aCBO,{'631320','Criador de ostras'})
aAdd(aCBO,{'631315','Criador de mexilhões'})
aAdd(aCBO,{'631310','Criador de jacarés'})
aAdd(aCBO,{'631305','Criador de camarões'})
aAdd(aCBO,{'631330','Criador de quelônios'})
aAdd(aCBO,{'631325','Criador de peixes'})
aAdd(aCBO,{'631335','Criador de rãs'})
aAdd(aCBO,{'631405','Gelador industrial'})
aAdd(aCBO,{'631410','Gelador profissional'})
aAdd(aCBO,{'631415','Proeiro'})
aAdd(aCBO,{'631420','Redeiro (pesca)'})
aAdd(aCBO,{'632005','Guia florestal'})
aAdd(aCBO,{'632015','Viveirista florestal'})
aAdd(aCBO,{'632010','Raizeiro'})
aAdd(aCBO,{'632105','Classificador de toras'})
aAdd(aCBO,{'632125','Trabalhador de extração florestal, em geral'})
aAdd(aCBO,{'632120','Operador de motosserra'})
aAdd(aCBO,{'632115','Identificador florestal'})
aAdd(aCBO,{'632110','Cubador de madeira'})
aAdd(aCBO,{'632215','Trabalhador da exploração de resinas'})
aAdd(aCBO,{'632210','Trabalhador da exploração de espécies produtoras de gomas não elásticas'})
aAdd(aCBO,{'632205','Seringueiro'})
aAdd(aCBO,{'632370','Trabalhador da exploração de tucum'})
aAdd(aCBO,{'632365','Trabalhador da exploração de piaçava'})
aAdd(aCBO,{'632360','Trabalhador da exploração de pequi'})
aAdd(aCBO,{'632355','Trabalhador da exploração de ouricuri'})
aAdd(aCBO,{'632350','Trabalhador da exploração de oiticica'})
aAdd(aCBO,{'632345','Trabalhador da exploração de murumuru'})
aAdd(aCBO,{'632340','Trabalhador da exploração de malva (pãina)'})
aAdd(aCBO,{'632335','Trabalhador da exploração de copaíba'})
aAdd(aCBO,{'632330','Trabalhador da exploração de coco-da-praia'})
aAdd(aCBO,{'632325','Trabalhador da exploração de carnaúba'})
aAdd(aCBO,{'632320','Trabalhador da exploração de buriti'})
aAdd(aCBO,{'632315','Trabalhador da exploração de bacaba'})
aAdd(aCBO,{'632305','Trabalhador da exploração de andiroba'})
aAdd(aCBO,{'632310','Trabalhador da exploração de babaçu'})
aAdd(aCBO,{'632420','Trabalhador da exploração de pupunha'})
aAdd(aCBO,{'632410','Trabalhador da exploração de castanha'})
aAdd(aCBO,{'632415','Trabalhador da exploração de pinhão'})
aAdd(aCBO,{'632405','Trabalhador da exploração de açaí'})
aAdd(aCBO,{'632505','Trabalhador da exploração de árvores e arbustos produtores de substâncias aromát., Medic. E tóxicas'})
aAdd(aCBO,{'632515','Trabalhador da exploração de madeiras tanantes'})
aAdd(aCBO,{'632520','Trabalhador da exploração de raízes produtoras de substâncias aromáticas, medicinais e tóxicas'})
aAdd(aCBO,{'632525','Trabalhador da extração de substâncias aromáticas, medicinais e tóxicas, em geral'})
aAdd(aCBO,{'632510','Trabalhador da exploração de cipós produtores de substâncias aromáticas, medicinais e tóxicas'})
aAdd(aCBO,{'632605','Carvoeiro'})
aAdd(aCBO,{'632610','Carbonizador'})
aAdd(aCBO,{'632615','Ajudante de carvoaria'})
aAdd(aCBO,{'641010','Operador de máquinas de beneficiamento de produtos agrícolas'})
aAdd(aCBO,{'641005','Operador de colheitadeira'})
aAdd(aCBO,{'641015','Tratorista agrícola'})
aAdd(aCBO,{'642010','Operador de máquinas florestais estáticas'})
aAdd(aCBO,{'642005','Operador de colhedor florestal'})
aAdd(aCBO,{'642015','Operador de trator florestal'})
aAdd(aCBO,{'643005','Trabalhador na operação de sistema de irrigação localizada (microaspersão e gotejamento)'})
aAdd(aCBO,{'643010','Trabalhador na operação de sistema de irrigação por aspersão (pivô central)'})
aAdd(aCBO,{'643015','Trabalhador na operação de sistemas convencionais de irrigação por aspersão'})
aAdd(aCBO,{'643020','Trabalhador na operação de sistemas de irrigação e aspersão (alto propelido)'})
aAdd(aCBO,{'643025','Trabalhador na operação de sistemas de irrigação por superfície e drenagem'})
aAdd(aCBO,{'710105','Supervisor de apoio operacional na mineração'})
aAdd(aCBO,{'710110','Supervisor de extração de sal'})
aAdd(aCBO,{'710115','Supervisor de perfuração e desmonte'})
aAdd(aCBO,{'710120','Supervisor de produção na mineração'})
aAdd(aCBO,{'710125','Supervisor de transporte na mineração'})
aAdd(aCBO,{'710205','Mestre (construção civil)'})
aAdd(aCBO,{'710210','Mestre de linhas (ferrovias)'})
aAdd(aCBO,{'710215','Inspetor de terraplenagem'})
aAdd(aCBO,{'710220','Supervisor de usina de concreto'})
aAdd(aCBO,{'710225','Fiscal de pátio de usina de concreto'})
aAdd(aCBO,{'711125','Escorador de minas'})
aAdd(aCBO,{'711120','Detonador'})
aAdd(aCBO,{'711115','Destroçador de pedra'})
aAdd(aCBO,{'711110','Canteiro'})
aAdd(aCBO,{'711105','Amostrador de minérios'})
aAdd(aCBO,{'711130','Mineiro'})
aAdd(aCBO,{'711225','Operador de máquina perfuradora (minas e pedreiras)'})
aAdd(aCBO,{'711220','Operador de máquina de extração contínua (minas de carvão)'})
aAdd(aCBO,{'711215','Operador de máquina cortadora (minas e pedreiras)'})
aAdd(aCBO,{'711210','Operador de carregadeira'})
aAdd(aCBO,{'711205','Operador de caminhão (minas e pedreiras)'})
aAdd(aCBO,{'711230','Operador de máquina perfuratriz'})
aAdd(aCBO,{'711245','Operador de trator (minas e pedreiras)'})
aAdd(aCBO,{'711240','Operador de schutthecar'})
aAdd(aCBO,{'711235','Operador de motoniveladora (extração de minerais sólidos)'})
aAdd(aCBO,{'711305','Operador de sonda de percussão'})
aAdd(aCBO,{'711310','Operador de sonda rotativa'})
aAdd(aCBO,{'711315','Sondador (poços de petróleo e gás)'})
aAdd(aCBO,{'711320','Sondador de poços (exceto de petróleo e gás)'})
aAdd(aCBO,{'711330','Torrista (petróleo)'})
aAdd(aCBO,{'711325','Plataformista (petróleo)'})
aAdd(aCBO,{'711405','Garimpeiro'})
aAdd(aCBO,{'711410','Operador de salina (sal marinho)'})
aAdd(aCBO,{'712105','Moleiro de minérios'})
aAdd(aCBO,{'712110','Operador de aparelho de flotação'})
aAdd(aCBO,{'712115','Operador de aparelho de precipitação (minas de ouro ou prata)'})
aAdd(aCBO,{'712120','Operador de britador de mandíbulas'})
aAdd(aCBO,{'712125','Operador de espessador'})
aAdd(aCBO,{'712130','Operador de jig (minas)'})
aAdd(aCBO,{'712135','Operador de peneiras hidráulicas'})
aAdd(aCBO,{'712205','Cortador de pedras'})
aAdd(aCBO,{'712210','Gravador de inscrições em pedra'})
aAdd(aCBO,{'712215','Gravador de relevos em pedra'})
aAdd(aCBO,{'712220','Polidor de pedras'})
aAdd(aCBO,{'712225','Torneiro (lavra de pedra)'})
aAdd(aCBO,{'712230','Traçador de pedras'})
aAdd(aCBO,{'715105','Operador de bate-estacas'})
aAdd(aCBO,{'715110','Operador de compactadora de solos'})
aAdd(aCBO,{'715115','Operador de escavadeira'})
aAdd(aCBO,{'715120','Operador de máquina de abrir valas'})
aAdd(aCBO,{'715145','Operador de trator de lâmina'})
aAdd(aCBO,{'715130','Operador de motoniveladora'})
aAdd(aCBO,{'715135','Operador de pá carregadeira'})
aAdd(aCBO,{'715140','Operador de pavimentadora (asfalto, concreto e materiais similares)'})
aAdd(aCBO,{'715125','Operador de máquinas de construção civil e mineração'})
aAdd(aCBO,{'715205','Calceteiro'})
aAdd(aCBO,{'715210','Pedreiro'})
aAdd(aCBO,{'715230','Pedreiro de edificações'})
aAdd(aCBO,{'715225','Pedreiro (mineração)'})
aAdd(aCBO,{'715220','Pedreiro (material refratário)'})
aAdd(aCBO,{'715215','Pedreiro (chaminés industriais)'})
aAdd(aCBO,{'715305','Armador de estrutura de concreto'})
aAdd(aCBO,{'715315','Armador de estrutura de concreto armado'})
aAdd(aCBO,{'715310','Moldador de corpos de prova em usinas de concreto'})
aAdd(aCBO,{'715410','Operador de bomba de concreto'})
aAdd(aCBO,{'715405','Operador de betoneira'})
aAdd(aCBO,{'715415','Operador de central de concreto'})
aAdd(aCBO,{'715505','Carpinteiro'})
aAdd(aCBO,{'715510','Carpinteiro (esquadrias)'})
aAdd(aCBO,{'715515','Carpinteiro (cenários)'})
aAdd(aCBO,{'715520','Carpinteiro (mineração)'})
aAdd(aCBO,{'715525','Carpinteiro de obras'})
aAdd(aCBO,{'715530','Carpinteiro (telhados)'})
aAdd(aCBO,{'715535','Carpinteiro de fôrmas para concreto'})
aAdd(aCBO,{'715540','Carpinteiro de obras civis de arte (pontes, túneis, barragens)'})
aAdd(aCBO,{'715545','Montador de andaimes (edificações)'})
aAdd(aCBO,{'715605','Eletricista de instalações (cenários)'})
aAdd(aCBO,{'715610','Eletricista de instalações (edifícios)'})
aAdd(aCBO,{'715615','Eletricista de instalações'})
aAdd(aCBO,{'715720','Instalador de isolantes térmicos de caldeira e tubulações'})
aAdd(aCBO,{'715725','Instalador de material isolante, a mão (edificações)'})
aAdd(aCBO,{'715705','Aplicador de asfalto impermeabilizante (coberturas)'})
aAdd(aCBO,{'715730','Instalador de material isolante, a máquina (edificações)'})
aAdd(aCBO,{'715715','Instalador de isolantes térmicos (refrigeração e climatização)'})
aAdd(aCBO,{'715710','Instalador de isolantes acústicos'})
aAdd(aCBO,{'716105','Acabador de superfícies de concreto'})
aAdd(aCBO,{'716110','Revestidor de superfícies de concreto'})
aAdd(aCBO,{'716210','Telhador (telhas de cimento-amianto)'})
aAdd(aCBO,{'716220','Telhador (telhas plásticas)'})
aAdd(aCBO,{'716205','Telhador (telhas de argila e materiais similares)'})
aAdd(aCBO,{'716215','Telhador (telhas metálicas)'})
aAdd(aCBO,{'716305','Vidraceiro'})
aAdd(aCBO,{'716310','Vidraceiro (edificações)'})
aAdd(aCBO,{'716315','Vidraceiro (vitrais)'})
aAdd(aCBO,{'716405','Gesseiro'})
aAdd(aCBO,{'716535','Taqueiro'})
aAdd(aCBO,{'716530','Mosaísta'})
aAdd(aCBO,{'716525','Marmorista (construção)'})
aAdd(aCBO,{'716520','Lustrador de piso'})
aAdd(aCBO,{'716515','Pastilheiro'})
aAdd(aCBO,{'716505','Assoalhador'})
aAdd(aCBO,{'716510','Ladrilheiro'})
aAdd(aCBO,{'716605','Calafetador'})
aAdd(aCBO,{'716615','Revestidor de interiores (papel, material plástico e emborrachados)'})
aAdd(aCBO,{'716610','Pintor de obras'})
aAdd(aCBO,{'717025','Vibradorista'})
aAdd(aCBO,{'717005','Demolidor de edificações'})
aAdd(aCBO,{'717010','Operador de martelete'})
aAdd(aCBO,{'717015','Poceiro (edificações)'})
aAdd(aCBO,{'717020','Servente de obras'})
aAdd(aCBO,{'720110','Mestre de caldeiraria'})
aAdd(aCBO,{'720105','Mestre (afiador de ferramentas)'})
aAdd(aCBO,{'720155','Mestre serralheiro'})
aAdd(aCBO,{'720140','Mestre de soldagem'})
aAdd(aCBO,{'720135','Mestre de pintura (tratamento de superfícies)'})
aAdd(aCBO,{'720115','Mestre de ferramentaria'})
aAdd(aCBO,{'720125','Mestre de fundição'})
aAdd(aCBO,{'720130','Mestre de galvanoplastia'})
aAdd(aCBO,{'720145','Mestre de trefilação de metais'})
aAdd(aCBO,{'720150','Mestre de usinagem'})
aAdd(aCBO,{'720160','Supervisor de controle de tratamento térmico'})
aAdd(aCBO,{'720120','Mestre de forjaria'})
aAdd(aCBO,{'720210','Mestre (indústria de automotores e material de transportes)'})
aAdd(aCBO,{'720205','Mestre (construção naval)'})
aAdd(aCBO,{'720215','Mestre (indústria de máquinas e outros equipamentos mecânicos)'})
aAdd(aCBO,{'720220','Mestre de construção de fornos'})
aAdd(aCBO,{'721110','Ferramenteiro de mandris, calibradores e outros dispositivos'})
aAdd(aCBO,{'721105','Ferramenteiro'})
aAdd(aCBO,{'721115','Modelador de metais (fundição)'})
aAdd(aCBO,{'721220','Operador de usinagem convencional por abrasão'})
aAdd(aCBO,{'721215','Operador de máquinas-ferramenta convencionais'})
aAdd(aCBO,{'721210','Operador de máquinas operatrizes'})
aAdd(aCBO,{'721205','Operador de máquina de eletroerosão'})
aAdd(aCBO,{'721225','Preparador de máquinas-ferramenta'})
aAdd(aCBO,{'721320','Afiador de serras'})
aAdd(aCBO,{'721315','Afiador de ferramentas'})
aAdd(aCBO,{'721310','Afiador de cutelaria'})
aAdd(aCBO,{'721305','Afiador de cardas'})
aAdd(aCBO,{'721325','Polidor de metais'})
aAdd(aCBO,{'721405','Operador de centro de usinagem com comando numérico'})
aAdd(aCBO,{'721410','Operador de fresadora com comando numérico'})
aAdd(aCBO,{'721415','Operador de mandriladora com comando numérico'})
aAdd(aCBO,{'721420','Operador de máquina eletroerosão, à fio, com comando numérico'})
aAdd(aCBO,{'721425','Operador de retificadora com comando numérico'})
aAdd(aCBO,{'721430','Operador de torno com comando numérico'})
aAdd(aCBO,{'722105','Forjador'})
aAdd(aCBO,{'722110','Forjador a martelo'})
aAdd(aCBO,{'722115','Forjador prensista'})
aAdd(aCBO,{'722215','Operador de acabamento de peças fundidas'})
aAdd(aCBO,{'722220','Operador de máquina centrifugadora de fundição'})
aAdd(aCBO,{'722225','Operador de máquina de fundir sob pressão'})
aAdd(aCBO,{'722230','Operador de vazamento (lingotamento)'})
aAdd(aCBO,{'722235','Preparador de panelas (lingotamento)'})
aAdd(aCBO,{'722205','Fundidor de metais'})
aAdd(aCBO,{'722210','Lingotador'})
aAdd(aCBO,{'722305','Macheiro, a mão'})
aAdd(aCBO,{'722310','Macheiro, a máquina'})
aAdd(aCBO,{'722315','Moldador, a mão'})
aAdd(aCBO,{'722320','Moldador, a máquina'})
aAdd(aCBO,{'722325','Operador de equipamentos de preparação de areia'})
aAdd(aCBO,{'722330','Operador de máquina de moldar automatizada'})
aAdd(aCBO,{'722405','Cableador'})
aAdd(aCBO,{'722410','Estirador de tubos de metal sem costura'})
aAdd(aCBO,{'722415','Trefilador de metais, à máquina'})
aAdd(aCBO,{'723120','Operador de forno de tratamento térmico de metais'})
aAdd(aCBO,{'723115','Operador de equipamento para resfriamento'})
aAdd(aCBO,{'723110','Normalizador de metais e de compósitos'})
aAdd(aCBO,{'723105','Cementador de metais'})
aAdd(aCBO,{'723125','Temperador de metais e de compósitos'})
aAdd(aCBO,{'723220','Metalizador a pistola'})
aAdd(aCBO,{'723215','Galvanizador'})
aAdd(aCBO,{'723210','Fosfatizador'})
aAdd(aCBO,{'723205','Decapador'})
aAdd(aCBO,{'723225','Metalizador (banho quente)'})
aAdd(aCBO,{'723240','Oxidador'})
aAdd(aCBO,{'723235','Operador de zincagem (processo eletrolítico)'})
aAdd(aCBO,{'723230','Operador de máquina recobridora de arame'})
aAdd(aCBO,{'723305','Operador de equipamento de secagem de pintura'})
aAdd(aCBO,{'723310','Pintor a pincel e rolo (exceto obras e estruturas metálicas)'})
aAdd(aCBO,{'723325','Pintor por imersão'})
aAdd(aCBO,{'723320','Pintor de veículos (fabricação)'})
aAdd(aCBO,{'723315','Pintor de estruturas metálicas'})
aAdd(aCBO,{'723330','Pintor, a pistola (exceto obras e estruturas metálicas)'})
aAdd(aCBO,{'724130','Instalador de tubulações de gás combustível (produção e distribuição)'})
aAdd(aCBO,{'724125','Instalador de tubulações (embarcações)'})
aAdd(aCBO,{'724120','Instalador de tubulações (aeronaves)'})
aAdd(aCBO,{'724115','Instalador de tubulações'})
aAdd(aCBO,{'724110','Encanador'})
aAdd(aCBO,{'724105','Assentador de canalização (edificações)'})
aAdd(aCBO,{'724135','Instalador de tubulações de vapor (produção e distribuição)'})
aAdd(aCBO,{'724210','Montador de estruturas metálicas de embarcações'})
aAdd(aCBO,{'724230','Rebitador, a mão'})
aAdd(aCBO,{'724225','Riscador de estruturas metálicas'})
aAdd(aCBO,{'724220','Preparador de estruturas metálicas'})
aAdd(aCBO,{'724215','Rebitador a martelo pneumático'})
aAdd(aCBO,{'724205','Montador de estruturas metálicas'})
aAdd(aCBO,{'724315','Soldador'})
aAdd(aCBO,{'724310','Oxicortador a mão e a máquina'})
aAdd(aCBO,{'724305','Brasador'})
aAdd(aCBO,{'724325','Soldador elétrico'})
aAdd(aCBO,{'724320','Soldador a oxigás'})
aAdd(aCBO,{'724405','Caldeireiro (chapas de cobre)'})
aAdd(aCBO,{'724410','Caldeireiro (chapas de ferro e aço)'})
aAdd(aCBO,{'724415','Chapeador'})
aAdd(aCBO,{'724430','Chapeador de aeronaves'})
aAdd(aCBO,{'724435','Funileiro industrial'})
aAdd(aCBO,{'724420','Chapeador de carrocerias metálicas (fabricação)'})
aAdd(aCBO,{'724440','Serralheiro'})
aAdd(aCBO,{'724425','Chapeador naval'})
aAdd(aCBO,{'724515','Prensista (operador de prensa)'})
aAdd(aCBO,{'724510','Operador de máquina de dobrar chapas'})
aAdd(aCBO,{'724505','Operador de máquina de cilindrar chapas'})
aAdd(aCBO,{'724605','Operador de laços de cabos de aço'})
aAdd(aCBO,{'724610','Trançador de cabos de aço'})
aAdd(aCBO,{'725005','Ajustador ferramenteiro'})
aAdd(aCBO,{'725010','Ajustador mecânico'})
aAdd(aCBO,{'725015','Ajustador mecânico (usinagem em bancada e em máquinas-ferramentas)'})
aAdd(aCBO,{'725020','Ajustador mecânico em bancada'})
aAdd(aCBO,{'725025','Ajustador naval (reparo e construção)'})
aAdd(aCBO,{'725105','Montador de máquinas, motores e acessórios (montagem em série)'})
aAdd(aCBO,{'725205','Montador de máquinas'})
aAdd(aCBO,{'725210','Montador de máquinas gráficas'})
aAdd(aCBO,{'725215','Montador de máquinas operatrizes para madeira'})
aAdd(aCBO,{'725220','Montador de máquinas têxteis'})
aAdd(aCBO,{'725225','Montador de máquinas-ferramentas (usinagem de metais)'})
aAdd(aCBO,{'725315','Montador de máquinas de minas e pedreiras'})
aAdd(aCBO,{'725320','Montador de máquinas de terraplenagem'})
aAdd(aCBO,{'725310','Montador de máquinas agrícolas'})
aAdd(aCBO,{'725305','Montador de equipamento de levantamento'})
aAdd(aCBO,{'725405','Mecânico montador de motores de aeronaves'})
aAdd(aCBO,{'725420','Mecânico montador de turboalimentadores'})
aAdd(aCBO,{'725415','Mecânico montador de motores de explosão e diesel'})
aAdd(aCBO,{'725410','Mecânico montador de motores de embarcações'})
aAdd(aCBO,{'725505','Montador de veículos (linha de montagem)'})
aAdd(aCBO,{'725510','Operador de time de montagem'})
aAdd(aCBO,{'725605','Montador de estruturas de aeronaves'})
aAdd(aCBO,{'725610','Montador de sistemas de combustível de aeronaves'})
aAdd(aCBO,{'725705','Mecânico de refrigeração'})
aAdd(aCBO,{'730105','Supervisor de montagem e instalação eletroeletrônica'})
aAdd(aCBO,{'731115','Montador de equipamentos elétricos (instrumentos de medição)'})
aAdd(aCBO,{'731120','Montador de equipamentos elétricos (aparelhos eletrodomésticos)'})
aAdd(aCBO,{'731125','Montador de equipamentos elétricos (centrais elétricas)'})
aAdd(aCBO,{'731130','Montador de equipamentos elétricos (motores e dínamos)'})
aAdd(aCBO,{'731135','Montador de equipamentos elétricos'})
aAdd(aCBO,{'731140','Montador de equipamentos eletrônicos (instalações de sinalização)'})
aAdd(aCBO,{'731145','Montador de equipamentos eletrônicos (máquinas industriais)'})
aAdd(aCBO,{'731150','Montador de equipamentos eletrônicos'})
aAdd(aCBO,{'731155','Montador de equipamentos elétricos (elevadores e equipamentos similares)'})
aAdd(aCBO,{'731160','Montador de equipamentos elétricos (transformadores)'})
aAdd(aCBO,{'731165','Bobinador eletricista, à mão'})
aAdd(aCBO,{'731170','Bobinador eletricista, à máquina'})
aAdd(aCBO,{'731175','Operador de linha de montagem (aparelhos elétricos)'})
aAdd(aCBO,{'731180','Operador de linha de montagem (aparelhos eletrônicos)'})
aAdd(aCBO,{'731105','Montador de equipamentos eletrônicos (aparelhos médicos)'})
aAdd(aCBO,{'731110','Montador de equipamentos eletrônicos (computadores e equipamentos auxiliares)'})
aAdd(aCBO,{'731205','Montador de equipamentos eletrônicos (estação de rádio, tv e equipamentos de radar)'})
aAdd(aCBO,{'731310','Instalador-reparador de equipamentos de energia em telefonia'})
aAdd(aCBO,{'731315','Instalador-reparador de equipamentos de transmissão em telefonia'})
aAdd(aCBO,{'731320','Instalador-reparador de linhas e aparelhos de telecomunicações'})
aAdd(aCBO,{'731325','Instalador-reparador de redes e cabos telefônicos'})
aAdd(aCBO,{'731305','Instalador-reparador de equipamentos de comutação em telefonia'})
aAdd(aCBO,{'731330','Reparador de aparelhos de telecomunicações em laboratório'})
aAdd(aCBO,{'732105','Eletricista de manutenção de linhas elétricas, telefônicas e de comunicação de dados'})
aAdd(aCBO,{'732110','Emendador de cabos elétricos e telefônicos (aéreos e subterrâneos)'})
aAdd(aCBO,{'732115','Examinador de cabos, linhas elétricas e telefônicas'})
aAdd(aCBO,{'732120','Instalador de linhas elétricas de alta e baixa - tensão (rede aérea e subterrânea)'})
aAdd(aCBO,{'732125','Instalador eletricista (tração de veículos)'})
aAdd(aCBO,{'732130','Instalador-reparador de redes telefônicas e de comunicação de dados'})
aAdd(aCBO,{'732135','Ligador de linhas telefônicas'})
aAdd(aCBO,{'740110','Supervisor de fabricação de instrumentos musicais'})
aAdd(aCBO,{'740105','Supervisor da mecânica de precisão'})
aAdd(aCBO,{'741125','Relojoeiro (reparação)'})
aAdd(aCBO,{'741120','Relojoeiro (fabricação)'})
aAdd(aCBO,{'741115','Montador de instrumentos de precisão'})
aAdd(aCBO,{'741110','Montador de instrumentos de óptica'})
aAdd(aCBO,{'741105','Ajustador de instrumentos de precisão'})
aAdd(aCBO,{'742135','Confeccionador de órgão'})
aAdd(aCBO,{'742130','Confeccionador de instrumentos de sopro (metal)'})
aAdd(aCBO,{'742125','Confeccionador de instrumentos de sopro (madeira)'})
aAdd(aCBO,{'742120','Confeccionador de instrumentos de percussão (pele, couro ou plástico)'})
aAdd(aCBO,{'742115','Confeccionador de instrumentos de corda'})
aAdd(aCBO,{'742110','Confeccionador de acordeão'})
aAdd(aCBO,{'742140','Confeccionador de piano'})
aAdd(aCBO,{'742105','Afinador de instrumentos musicais'})
aAdd(aCBO,{'750105','Supervisor de joalheria'})
aAdd(aCBO,{'750205','Supervisor da indústria de minerais não metálicos (exceto os derivados de petróleo e carvão)'})
aAdd(aCBO,{'751005','Engastador (jóias)'})
aAdd(aCBO,{'751010','Joalheiro'})
aAdd(aCBO,{'751015','Joalheiro (reparações)'})
aAdd(aCBO,{'751020','Lapidador (jóias)'})
aAdd(aCBO,{'751105','Bate-folha a máquina'})
aAdd(aCBO,{'751110','Fundidor (joalheria e ourivesaria)'})
aAdd(aCBO,{'751130','Trefilador (joalheria e ourivesaria)'})
aAdd(aCBO,{'751125','Ourives'})
aAdd(aCBO,{'751120','Laminador de metais preciosos a mão'})
aAdd(aCBO,{'751115','Gravador (joalheria e ourivesaria)'})
aAdd(aCBO,{'752110','Moldador (vidros)'})
aAdd(aCBO,{'752105','Artesão modelador (vidros)'})
aAdd(aCBO,{'752115','Soprador de vidro'})
aAdd(aCBO,{'752120','Transformador de tubos de vidro'})
aAdd(aCBO,{'752205','Aplicador serigráfico em vidros'})
aAdd(aCBO,{'752210','Cortador de vidro'})
aAdd(aCBO,{'752235','Surfassagista'})
aAdd(aCBO,{'752230','Lapidador de vidros e cristais'})
aAdd(aCBO,{'752225','Gravador de vidro a jato de areia'})
aAdd(aCBO,{'752220','Gravador de vidro a esmeril'})
aAdd(aCBO,{'752215','Gravador de vidro a água-forte'})
aAdd(aCBO,{'752305','Ceramista'})
aAdd(aCBO,{'752310','Ceramista (torno de pedal e motor)'})
aAdd(aCBO,{'752315','Ceramista (torno semi-automático)'})
aAdd(aCBO,{'752320','Ceramista modelador'})
aAdd(aCBO,{'752325','Ceramista moldador'})
aAdd(aCBO,{'752330','Ceramista prensador'})
aAdd(aCBO,{'752425','Operador de espelhamento'})
aAdd(aCBO,{'752420','Operador de esmaltadeira'})
aAdd(aCBO,{'752415','Decorador de vidro à pincel'})
aAdd(aCBO,{'752410','Decorador de vidro'})
aAdd(aCBO,{'752405','Decorador de cerâmica'})
aAdd(aCBO,{'752430','Pintor de cerâmica, a pincel'})
aAdd(aCBO,{'760125','Mestre (indústria têxtil e de confecções)'})
aAdd(aCBO,{'760120','Contramestre de tecelagem (indústria têxtil)'})
aAdd(aCBO,{'760115','Contramestre de malharia (indústria têxtil)'})
aAdd(aCBO,{'760110','Contramestre de fiação (indústria têxtil)'})
aAdd(aCBO,{'760105','Contramestre de acabamento (indústria têxtil)'})
aAdd(aCBO,{'760205','Supervisor de curtimento'})
aAdd(aCBO,{'760310','Encarregado de costura na confecção do vestuário'})
aAdd(aCBO,{'760305','Encarregado de corte na confecção do vestuário'})
aAdd(aCBO,{'760405','Supervisor (indústria de calçados e artefatos de couro)'})
aAdd(aCBO,{'760505','Supervisor da confecção de artefatos de tecidos, couros e afins'})
aAdd(aCBO,{'760605','Supervisor das artes gráficas (indústria editorial e gráfica)'})
aAdd(aCBO,{'761005','Operador polivalente da indústria têxtil'})
aAdd(aCBO,{'761105','Classificador de fibras têxteis'})
aAdd(aCBO,{'761110','Lavador de lã'})
aAdd(aCBO,{'761205','Operador de abertura (fiação)'})
aAdd(aCBO,{'761220','Operador de cardas'})
aAdd(aCBO,{'761225','Operador de conicaleira'})
aAdd(aCBO,{'761230','Operador de filatório'})
aAdd(aCBO,{'761235','Operador de laminadeira e reunideira'})
aAdd(aCBO,{'761215','Operador de bobinadeira'})
aAdd(aCBO,{'761245','Operador de open-end'})
aAdd(aCBO,{'761250','Operador de passador (fiação)'})
aAdd(aCBO,{'761255','Operador de penteadeira'})
aAdd(aCBO,{'761260','Operador de retorcedeira'})
aAdd(aCBO,{'761210','Operador de binadeira'})
aAdd(aCBO,{'761240','Operador de maçaroqueira'})
aAdd(aCBO,{'761333','Tecelão de malhas (máquina retilínea)'})
aAdd(aCBO,{'761348','Operador de engomadeira de urdume'})
aAdd(aCBO,{'761351','Operador de espuladeira'})
aAdd(aCBO,{'761357','Operador de urdideira'})
aAdd(aCBO,{'761360','Passamaneiro a máquina'})
aAdd(aCBO,{'761363','Remetedor de fios'})
aAdd(aCBO,{'761303','Tecelão (redes)'})
aAdd(aCBO,{'761306','Tecelão (rendas e bordados)'})
aAdd(aCBO,{'761315','Tecelão (tear mecânico de maquineta)'})
aAdd(aCBO,{'761318','Tecelão (tear mecânico de xadrez)'})
aAdd(aCBO,{'761324','Tecelão (tear mecânico, exceto jacquard)'})
aAdd(aCBO,{'761327','Tecelão de malhas, a máquina'})
aAdd(aCBO,{'761336','Tecelão de meias, a máquina'})
aAdd(aCBO,{'761339','Tecelão de meias (máquina circular)'})
aAdd(aCBO,{'761342','Tecelão de meias (máquina retilínea)'})
aAdd(aCBO,{'761345','Tecelão de tapetes, a máquina'})
aAdd(aCBO,{'761354','Operador de máquina de cordoalha'})
aAdd(aCBO,{'761366','Picotador de cartões jacquard'})
aAdd(aCBO,{'761309','Tecelão (tear automático)'})
aAdd(aCBO,{'761312','Tecelão (tear jacquard)'})
aAdd(aCBO,{'761321','Tecelão (tear mecânico liso)'})
aAdd(aCBO,{'761330','Tecelão de malhas (máquina circular)'})
aAdd(aCBO,{'761405','Alvejador (tecidos)'})
aAdd(aCBO,{'761410','Estampador de tecido'})
aAdd(aCBO,{'761415','Operador de calandras (tecidos)'})
aAdd(aCBO,{'761420','Operador de chamuscadeira de tecidos'})
aAdd(aCBO,{'761425','Operador de impermeabilizador de tecidos'})
aAdd(aCBO,{'761430','Operador de máquina de lavar fios e tecidos'})
aAdd(aCBO,{'761435','Operador de rameuse'})
aAdd(aCBO,{'761805','Inspetor de estamparia (produção têxtil)'})
aAdd(aCBO,{'761810','Revisor de fios (produção têxtil)'})
aAdd(aCBO,{'761815','Revisor de tecidos acabados'})
aAdd(aCBO,{'761820','Revisor de tecidos crus'})
aAdd(aCBO,{'762005','Trabalhador polivalente do curtimento de couros e peles'})
aAdd(aCBO,{'762105','Classificador de peles'})
aAdd(aCBO,{'762110','Descarnador de couros e peles, à maquina'})
aAdd(aCBO,{'762115','Estirador de couros e peles (preparação)'})
aAdd(aCBO,{'762120','Fuloneiro'})
aAdd(aCBO,{'762125','Rachador de couros e peles'})
aAdd(aCBO,{'762220','Rebaixador de couros'})
aAdd(aCBO,{'762215','Enxugador de couros'})
aAdd(aCBO,{'762210','Classificador de couros'})
aAdd(aCBO,{'762205','Curtidor (couros e peles)'})
aAdd(aCBO,{'762325','Operador de máquinas do acabamento de couros e peles'})
aAdd(aCBO,{'762330','Prensador de couros e peles'})
aAdd(aCBO,{'762335','Palecionador de couros e peles'})
aAdd(aCBO,{'762340','Preparador de couros curtidos'})
aAdd(aCBO,{'762320','Matizador de couros e peles'})
aAdd(aCBO,{'762345','Vaqueador de couros e peles'})
aAdd(aCBO,{'762310','Fuloneiro no acabamento de couros e peles'})
aAdd(aCBO,{'762305','Estirador de couros e peles (acabamento)'})
aAdd(aCBO,{'762315','Lixador de couros e peles'})
aAdd(aCBO,{'763010','Costureira de peças sob encomenda'})
aAdd(aCBO,{'763005','Alfaiate'})
aAdd(aCBO,{'763020','Costureiro de roupa de couro e pele'})
aAdd(aCBO,{'763015','Costureira de reparação de roupas'})
aAdd(aCBO,{'763105','Auxiliar de corte (preparação da confecção de roupas)'})
aAdd(aCBO,{'763125','Ajudante de confecção'})
aAdd(aCBO,{'763120','Riscador de roupas'})
aAdd(aCBO,{'763115','Enfestador de roupas'})
aAdd(aCBO,{'763110','Cortador de roupas'})
aAdd(aCBO,{'763205','Costureiro de roupas de couro e pele, a máquina na confecção em série'})
aAdd(aCBO,{'763215','Costureiro, a máquina na confecção em série'})
aAdd(aCBO,{'763210','Costureiro na confecção em série'})
aAdd(aCBO,{'763305','Arrematadeira'})
aAdd(aCBO,{'763325','Passadeira de peças confeccionadas'})
aAdd(aCBO,{'763320','Operador de máquina de costura de acabamento'})
aAdd(aCBO,{'763315','Marcador de peças confeccionadas para bordar'})
aAdd(aCBO,{'763310','Bordador, à máquina'})
aAdd(aCBO,{'764005','Trabalhador polivalente da confecção de calçados'})
aAdd(aCBO,{'764110','Cortador de solas e palmilhas, a máquina'})
aAdd(aCBO,{'764105','Cortador de calçados, a máquina (exceto solas e palmilhas)'})
aAdd(aCBO,{'764115','Preparador de calçados'})
aAdd(aCBO,{'764120','Preparador de solas e palmilhas'})
aAdd(aCBO,{'764205','Costurador de calçados, a máquina'})
aAdd(aCBO,{'764210','Montador de calçados'})
aAdd(aCBO,{'764305','Acabador de calçados'})
aAdd(aCBO,{'765005','Confeccionador de artefatos de couro (exceto sapatos)'})
aAdd(aCBO,{'765010','Chapeleiro de senhoras'})
aAdd(aCBO,{'765015','Boneleiro'})
aAdd(aCBO,{'765105','Cortador de artefatos de couro (exceto roupas e calçados)'})
aAdd(aCBO,{'765110','Cortador de tapeçaria'})
aAdd(aCBO,{'765205','Colchoeiro (confecção de colchões)'})
aAdd(aCBO,{'765215','Confeccionador de brinquedos de pano'})
aAdd(aCBO,{'765235','Estofador de móveis'})
aAdd(aCBO,{'765230','Estofador de aviões'})
aAdd(aCBO,{'765225','Confeccionador de velas náuticas, barracas e toldos'})
aAdd(aCBO,{'765310','Costurador de artefatos de couro, a máquina (exceto roupas e calçados)'})
aAdd(aCBO,{'765315','Montador de artefatos de couro (exceto roupas e calçados)'})
aAdd(aCBO,{'765405','Trabalhador do acabamento de artefatos de tecidos e couros'})
aAdd(aCBO,{'766125','Montador de fotolito (analógico e digital)'})
aAdd(aCBO,{'766120','Editor de texto e imagem'})
aAdd(aCBO,{'766115','Gravador de matriz para flexografia (clicherista)'})
aAdd(aCBO,{'766105','Copiador de chapa'})
aAdd(aCBO,{'766155','Programador visual gráfico'})
aAdd(aCBO,{'766135','Gravador de matriz calcográfica'})
aAdd(aCBO,{'766140','Gravador de matriz serigráfica'})
aAdd(aCBO,{'766145','Operador de sistemas de prova (analógico e digital)'})
aAdd(aCBO,{'766150','Operador de processo de tratamento de imagem'})
aAdd(aCBO,{'766130','Gravador de matriz para rotogravura (eletromecânico e químico)'})
aAdd(aCBO,{'766220','Impressor de rotativa'})
aAdd(aCBO,{'766215','Impressor de ofsete (plano e rotativo)'})
aAdd(aCBO,{'766210','Impressor calcográfico'})
aAdd(aCBO,{'766205','Impressor (serigrafia)'})
aAdd(aCBO,{'766225','Impressor de rotogravura'})
aAdd(aCBO,{'766250','Impressor tipográfico'})
aAdd(aCBO,{'766245','Impressor tampográfico'})
aAdd(aCBO,{'766240','Impressor letterset'})
aAdd(aCBO,{'766235','Impressor flexográfico'})
aAdd(aCBO,{'766230','Impressor digital'})
aAdd(aCBO,{'766320','Operador de guilhotina (corte de papel)'})
aAdd(aCBO,{'766325','Preparador de matrizes de corte e vinco'})
aAdd(aCBO,{'766315','Operador de acabamento (indústria gráfica)'})
aAdd(aCBO,{'766305','Acabador de embalagens (flexíveis e cartotécnicas)'})
aAdd(aCBO,{'766310','Impressor de corte e vinco'})
aAdd(aCBO,{'766415','Revelador de filmes fotográficos, em cores'})
aAdd(aCBO,{'766410','Revelador de filmes fotográficos, em preto e branco'})
aAdd(aCBO,{'766405','Laboratorista fotográfico'})
aAdd(aCBO,{'766420','Auxiliar de radiologia (revelação fotográfica)'})
aAdd(aCBO,{'768125','Chapeleiro (chapéus de palha)'})
aAdd(aCBO,{'768120','Redeiro'})
aAdd(aCBO,{'768115','Tricoteiro, à mão'})
aAdd(aCBO,{'768110','Tecelão de tapetes, a mão'})
aAdd(aCBO,{'768105','Tecelão (tear manual)'})
aAdd(aCBO,{'768130','Crocheteiro, a mão'})
aAdd(aCBO,{'768205','Bordador, a mão'})
aAdd(aCBO,{'768210','Cerzidor'})
aAdd(aCBO,{'768315','Costurador de artefatos de couro, a mão (exceto roupas e calçados)'})
aAdd(aCBO,{'768320','Sapateiro (calçados sob medida)'})
aAdd(aCBO,{'768325','Seleiro'})
aAdd(aCBO,{'768305','Artífice do couro'})
aAdd(aCBO,{'768310','Cortador de calçados, a mão (exceto solas)'})
aAdd(aCBO,{'768605','Tipógrafo'})
aAdd(aCBO,{'768630','Confeccionador de carimbos de borracha'})
aAdd(aCBO,{'768625','Pintor de letreiros'})
aAdd(aCBO,{'768620','Paginador'})
aAdd(aCBO,{'768615','Monotipista'})
aAdd(aCBO,{'768610','Linotipista'})
aAdd(aCBO,{'768705','Gravador, à mão (encadernação)'})
aAdd(aCBO,{'768710','Restaurador de livros'})
aAdd(aCBO,{'770110','Mestre carpinteiro'})
aAdd(aCBO,{'770105','Mestre (indústria de madeira e mobiliário)'})
aAdd(aCBO,{'771110','Modelador de madeira'})
aAdd(aCBO,{'771105','Marceneiro'})
aAdd(aCBO,{'771115','Maquetista na marcenaria'})
aAdd(aCBO,{'771120','Tanoeiro'})
aAdd(aCBO,{'772115','Secador de madeira'})
aAdd(aCBO,{'772105','Classificador de madeira'})
aAdd(aCBO,{'772110','Impregnador de madeira'})
aAdd(aCBO,{'773120','Serrador de madeira'})
aAdd(aCBO,{'773125','Serrador de madeira (serra circular múltipla)'})
aAdd(aCBO,{'773130','Serrador de madeira (serra de fita múltipla)'})
aAdd(aCBO,{'773105','Cortador de laminados de madeira'})
aAdd(aCBO,{'773115','Serrador de bordas no desdobramento de madeira'})
aAdd(aCBO,{'773110','Operador de serras no desdobramento de madeira'})
aAdd(aCBO,{'773210','Prensista de aglomerados'})
aAdd(aCBO,{'773215','Prensista de compensados'})
aAdd(aCBO,{'773220','Preparador de aglomerantes'})
aAdd(aCBO,{'773205','Operador de máquina intercaladora e placas (compensados)'})
aAdd(aCBO,{'773345','Operador de torno automático (usinagem de madeira)'})
aAdd(aCBO,{'773350','Operador de tupia (usinagem de madeira)'})
aAdd(aCBO,{'773355','Torneiro na usinagem convencional de madeira'})
aAdd(aCBO,{'773315','Operador de fresadora (usinagem de madeira)'})
aAdd(aCBO,{'773330','Operador de molduradora (usinagem de madeira)'})
aAdd(aCBO,{'773340','Operador de serras (usinagem de madeira)'})
aAdd(aCBO,{'773335','Operador de plaina desengrossadeira'})
aAdd(aCBO,{'773325','Operador de máquina de usinagem madeira, em geral'})
aAdd(aCBO,{'773320','Operador de lixadeira (usinagem de madeira)'})
aAdd(aCBO,{'773310','Operador de entalhadeira (usinagem de madeira)'})
aAdd(aCBO,{'773305','Operador de desempenadeira na usinagem convencional de madeira'})
aAdd(aCBO,{'773420','Operador de prensa de alta freqüência na usinagem de madeira'})
aAdd(aCBO,{'773415','Operador de máquina de usinagem de madeira (produção em série)'})
aAdd(aCBO,{'773410','Operador de máquina de cortina d´água (produção de móveis)'})
aAdd(aCBO,{'773405','Operador de máquina bordatriz'})
aAdd(aCBO,{'773510','Operador de máquinas de usinar madeira (cnc)'})
aAdd(aCBO,{'773505','Operador de centro de usinagem de madeira (cnc)'})
aAdd(aCBO,{'774105','Montador de móveis e artefatos de madeira'})
aAdd(aCBO,{'775110','Folheador de móveis de madeira'})
aAdd(aCBO,{'775115','Lustrador de peças de madeira'})
aAdd(aCBO,{'775120','Marcheteiro'})
aAdd(aCBO,{'775105','Entalhador de madeira'})
aAdd(aCBO,{'776420','Confeccionador de móveis de vime, junco e bambu'})
aAdd(aCBO,{'776405','Cesteiro'})
aAdd(aCBO,{'776410','Confeccionador de escovas, pincéis e produtos similares (a mão)'})
aAdd(aCBO,{'776415','Confeccionador de escovas, pincéis e produtos similares (a máquina)'})
aAdd(aCBO,{'776425','Esteireiro'})
aAdd(aCBO,{'776430','Vassoureiro'})
aAdd(aCBO,{'777105','Carpinteiro naval (construção de pequenas embarcações)'})
aAdd(aCBO,{'777110','Carpinteiro naval (embarcações)'})
aAdd(aCBO,{'777115','Carpinteiro naval (estaleiros)'})
aAdd(aCBO,{'777205','Carpinteiro de carretas'})
aAdd(aCBO,{'777210','Carpinteiro de carrocerias'})
aAdd(aCBO,{'780105','Supervisor de embalagem e etiquetagem'})
aAdd(aCBO,{'781110','Condutor de processos robotizados de soldagem'})
aAdd(aCBO,{'781105','Condutor de processos robotizados de pintura'})
aAdd(aCBO,{'781305','Operador de veículos subaquáticos controlados remotamente'})
aAdd(aCBO,{'781705','Mergulhador profissional (raso e profundo)'})
aAdd(aCBO,{'782125','Operador de monta-cargas (construção civil)'})
aAdd(aCBO,{'782130','Operador de ponte rolante'})
aAdd(aCBO,{'782120','Operador de máquina rodoferroviária'})
aAdd(aCBO,{'782115','Operador de guindaste móvel'})
aAdd(aCBO,{'782110','Operador de guindaste (fixo)'})
aAdd(aCBO,{'782105','Operador de draga'})
aAdd(aCBO,{'782145','Sinaleiro (ponte-rolante)'})
aAdd(aCBO,{'782140','Operador de talha elétrica'})
aAdd(aCBO,{'782135','Operador de pórtico rolante'})
aAdd(aCBO,{'782220','Operador de empilhadeira'})
aAdd(aCBO,{'782210','Operador de docagem'})
aAdd(aCBO,{'782205','Guincheiro (construção civil)'})
aAdd(aCBO,{'782315','Motorista de táxi'})
aAdd(aCBO,{'782310','Motorista de furgão ou veículo similar'})
aAdd(aCBO,{'782305','Motorista de carro de passeio'})
aAdd(aCBO,{'782410','Motorista de ônibus urbano'})
aAdd(aCBO,{'782415','Motorista de trólebus'})
aAdd(aCBO,{'782405','Motorista de ônibus rodoviário'})
aAdd(aCBO,{'782510','Motorista de caminhão (rotas regionais e internacionais)'})
aAdd(aCBO,{'782505','Caminhoneiro autônomo (rotas regionais e internacionais)'})
aAdd(aCBO,{'782515','Motorista operacional de guincho'})
aAdd(aCBO,{'782620','Motorneiro'})
aAdd(aCBO,{'782630','Operador de teleférico (passageiros)'})
aAdd(aCBO,{'782615','Maquinista de trem metropolitano'})
aAdd(aCBO,{'782610','Maquinista de trem'})
aAdd(aCBO,{'782605','Operador de trem de metrô'})
aAdd(aCBO,{'782625','Auxiliar de maquinista de trem'})
aAdd(aCBO,{'782720','Moço de máquinas (marítimo e fluviário)'})
aAdd(aCBO,{'782725','Marinheiro de esporte e recreio'})
aAdd(aCBO,{'782715','Moço de convés (marítimo e fluviário)'})
aAdd(aCBO,{'782710','Marinheiro de máquinas'})
aAdd(aCBO,{'782705','Marinheiro de convés (marítimo e fluviário)'})
aAdd(aCBO,{'782805','Condutor de veículos de tração animal (ruas e estradas)'})
aAdd(aCBO,{'782810','Tropeiro'})
aAdd(aCBO,{'782815','Boiadeiro'})
aAdd(aCBO,{'782820','Condutor de veículos a pedais'})
aAdd(aCBO,{'783110','Manobrador'})
aAdd(aCBO,{'783105','Agente de pátio'})
aAdd(aCBO,{'783205','Carregador (aeronaves)'})
aAdd(aCBO,{'783225','Ajudante de motorista'})
aAdd(aCBO,{'783230','Bloqueiro (trabalhador portuário)'})
aAdd(aCBO,{'783220','Estivador'})
aAdd(aCBO,{'783215','Carregador (veículos de transportes terrestres)'})
aAdd(aCBO,{'783210','Carregador (armazém)'})
aAdd(aCBO,{'784125','Operador de prensa de enfardamento'})
aAdd(aCBO,{'784120','Operador de máquina de envasar líquidos'})
aAdd(aCBO,{'784115','Operador de máquina de etiquetar'})
aAdd(aCBO,{'784110','Embalador, a máquina'})
aAdd(aCBO,{'784105','Embalador, a mão'})
aAdd(aCBO,{'784205','Alimentador de linha de produção'})
aAdd(aCBO,{'791105','Artesão bordador'})
aAdd(aCBO,{'791110','Artesão ceramista'})
aAdd(aCBO,{'791115','Artesão com material reciclável'})
aAdd(aCBO,{'791120','Artesão confeccionador de biojóias e ecojóias'})
aAdd(aCBO,{'791125','Artesão do couro'})
aAdd(aCBO,{'791160','Artesão rendeiro'})
aAdd(aCBO,{'791135','Artesão moveleiro (exceto reciclado)'})
aAdd(aCBO,{'791140','Artesão tecelão'})
aAdd(aCBO,{'791145','Artesão trançador'})
aAdd(aCBO,{'791150','Artesão crocheteiro'})
aAdd(aCBO,{'791155','Artesão tricoteiro'})
aAdd(aCBO,{'791130','Artesão escultor'})
aAdd(aCBO,{'810110','Mestre de produção química'})
aAdd(aCBO,{'810105','Mestre (indústria petroquímica e carboquímica)'})
aAdd(aCBO,{'810205','Mestre (indústria de borracha e plástico)'})
aAdd(aCBO,{'810305','Mestre de produção farmacêutica'})
aAdd(aCBO,{'811005','Operador de processos químicos e petroquímicos'})
aAdd(aCBO,{'811010','Operador de sala de controle de instalações químicas, petroquímicas e afins'})
aAdd(aCBO,{'811105','Moleiro (tratamentos químicos e afins)'})
aAdd(aCBO,{'811115','Operador de britadeira (tratamentos químicos e afins)'})
aAdd(aCBO,{'811120','Operador de concentração'})
aAdd(aCBO,{'811125','Trabalhador da fabricação de resinas e vernizes'})
aAdd(aCBO,{'811130','Trabalhador de fabricação de tintas'})
aAdd(aCBO,{'811110','Operador de máquina misturadeira (tratamentos químicos e afins)'})
aAdd(aCBO,{'811215','Operador de tratamento químico de materiais radioativos'})
aAdd(aCBO,{'811205','Operador de calcinação (tratamento químico e afins)'})
aAdd(aCBO,{'811330','Operador de filtro-prensa (tratamentos químicos e afins)'})
aAdd(aCBO,{'811335','Operador de filtros de parafina (tratamentos químicos e afins)'})
aAdd(aCBO,{'811325','Operador de filtro-esteira (mineração)'})
aAdd(aCBO,{'811320','Operador de filtro de tambor rotativo (tratamentos químicos e afins)'})
aAdd(aCBO,{'811315','Operador de filtro de secagem (mineração)'})
aAdd(aCBO,{'811310','Operador de exploração de petróleo'})
aAdd(aCBO,{'811305','Operador de centrifugadora (tratamentos químicos e afins)'})
aAdd(aCBO,{'811410','Destilador de produtos químicos (exceto petróleo)'})
aAdd(aCBO,{'811405','Destilador de madeira'})
aAdd(aCBO,{'811415','Operador de alambique de funcionamento contínuo (produtos químicos, exceto petróleo)'})
aAdd(aCBO,{'811420','Operador de aparelho de reação e conversão (produtos químicos, exceto petróleo)'})
aAdd(aCBO,{'811425','Operador de equipamento de destilação de álcool'})
aAdd(aCBO,{'811430','Operador de evaporador na destilação'})
aAdd(aCBO,{'811505','Operador de painel de controle (refinação de petróleo)'})
aAdd(aCBO,{'811510','Operador de transferência e estocagem - na refinação do petróleo'})
aAdd(aCBO,{'811610','Operador de carro de apagamento e coque'})
aAdd(aCBO,{'811605','Operador de britador de coque'})
aAdd(aCBO,{'811615','Operador de destilação e subprodutos de coque'})
aAdd(aCBO,{'811650','Operador de sistema de reversão (coqueria)'})
aAdd(aCBO,{'811645','Operador de refrigeração (coqueria)'})
aAdd(aCBO,{'811640','Operador de reator de coque de petróleo'})
aAdd(aCBO,{'811635','Operador de preservação e controle térmico'})
aAdd(aCBO,{'811630','Operador de painel de controle'})
aAdd(aCBO,{'811625','Operador de exaustor (coqueria)'})
aAdd(aCBO,{'811620','Operador de enfornamento e desenfornamento de coque'})
aAdd(aCBO,{'811705','Bamburista'})
aAdd(aCBO,{'811710','Calandrista de borracha'})
aAdd(aCBO,{'811770','Moldador de plástico por injeção'})
aAdd(aCBO,{'811775','Trefilador de borracha'})
aAdd(aCBO,{'811760','Moldador de plástico por compressão'})
aAdd(aCBO,{'811725','Confeccionador de velas por imersão'})
aAdd(aCBO,{'811735','Confeccionador de velas por moldagem'})
aAdd(aCBO,{'811745','Laminador de plástico'})
aAdd(aCBO,{'811750','Moldador de borracha por compressão'})
aAdd(aCBO,{'811715','Confeccionador de pneumáticos'})
aAdd(aCBO,{'811820','Operador de máquina de fabricação de produtos de higiene e limpeza (sabão, sabonete, detergente, ab'})
aAdd(aCBO,{'811815','Operador de máquina de fabricação de cosméticos'})
aAdd(aCBO,{'811805','Operador de máquina de produtos farmacêuticos'})
aAdd(aCBO,{'811810','Drageador (medicamentos)'})
aAdd(aCBO,{'812110','Trabalhador da fabricação de munição e explosivos'})
aAdd(aCBO,{'812105','Pirotécnico'})
aAdd(aCBO,{'813120','Operador de processo (química, petroquímica e afins)'})
aAdd(aCBO,{'813110','Operador de calandra (química, petroquímica e afins)'})
aAdd(aCBO,{'813105','Cilindrista (petroquímica e afins)'})
aAdd(aCBO,{'813125','Operador de produção (química, petroquímica e afins)'})
aAdd(aCBO,{'813130','Técnico de operação (química, petroquímica e afins)'})
aAdd(aCBO,{'813115','Operador de extrusora (química, petroquímica e afins)'})
aAdd(aCBO,{'818105','Assistente de laboratório industrial'})
aAdd(aCBO,{'818110','Auxiliar de laboratório de análises físico-químicas'})
aAdd(aCBO,{'820110','Mestre de aciaria'})
aAdd(aCBO,{'820115','Mestre de alto-forno'})
aAdd(aCBO,{'820120','Mestre de forno elétrico'})
aAdd(aCBO,{'820125','Mestre de laminação'})
aAdd(aCBO,{'820105','Mestre de siderurgia'})
aAdd(aCBO,{'820210','Supervisor de fabricação de produtos de vidro'})
aAdd(aCBO,{'820205','Supervisor de fabricação de produtos cerâmicos, porcelanatos e afins'})
aAdd(aCBO,{'821105','Operador de centro de controle'})
aAdd(aCBO,{'821110','Operador de máquina de sinterizar'})
aAdd(aCBO,{'821205','Forneiro e operador (alto-forno)'})
aAdd(aCBO,{'821215','Forneiro e operador (forno elétrico)'})
aAdd(aCBO,{'821225','Forneiro e operador de forno de redução direta'})
aAdd(aCBO,{'821220','Forneiro e operador (refino de metais não-ferrosos)'})
aAdd(aCBO,{'821210','Forneiro e operador (conversor a oxigênio)'})
aAdd(aCBO,{'821255','Soprador de convertedor'})
aAdd(aCBO,{'821250','Operador de desgaseificação'})
aAdd(aCBO,{'821245','Operador de área de corrida'})
aAdd(aCBO,{'821240','Operador de aciaria (recebimento de gusa)'})
aAdd(aCBO,{'821235','Operador de aciaria (dessulfuração de gusa)'})
aAdd(aCBO,{'821230','Operador de aciaria (basculamento de convertedor)'})
aAdd(aCBO,{'821325','Operador de laminador de tubos'})
aAdd(aCBO,{'821320','Operador de laminador de metais não-ferrosos'})
aAdd(aCBO,{'821315','Operador de laminador de barras a quente'})
aAdd(aCBO,{'821310','Operador de laminador de barras a frio'})
aAdd(aCBO,{'821305','Operador de laminador'})
aAdd(aCBO,{'821330','Operador de montagem de cilindros e mancais'})
aAdd(aCBO,{'821335','Recuperador de guias e cilindros'})
aAdd(aCBO,{'821440','Operador de tesoura mecânica e máquina de corte, no acabamento de chapas e metais'})
aAdd(aCBO,{'821435','Operador de jato abrasivo'})
aAdd(aCBO,{'821430','Operador de escória e sucata'})
aAdd(aCBO,{'821425','Operador de cabine de laminação (fio-máquina)'})
aAdd(aCBO,{'821420','Operador de bobinadeira de tiras a quente, no acabamento de chapas e metais'})
aAdd(aCBO,{'821415','Marcador de produtos (siderúrgico e metalúrgico)'})
aAdd(aCBO,{'821410','Escarfador'})
aAdd(aCBO,{'821405','Encarregado de acabamento de chapas e metais (têmpera)'})
aAdd(aCBO,{'821445','Preparador de sucata e aparas'})
aAdd(aCBO,{'821450','Rebarbador de metal'})
aAdd(aCBO,{'822110','Forneiro de forno-poço'})
aAdd(aCBO,{'822125','Forneiro de revérbero'})
aAdd(aCBO,{'822120','Forneiro de reaquecimento e tratamento térmico na metalurgia'})
aAdd(aCBO,{'822115','Forneiro de fundição (forno de redução)'})
aAdd(aCBO,{'822105','Forneiro de cubilô'})
aAdd(aCBO,{'823130','Preparador de aditivos'})
aAdd(aCBO,{'823125','Preparador de esmaltes (cerâmica)'})
aAdd(aCBO,{'823120','Preparador de barbotina'})
aAdd(aCBO,{'823115','Preparador de massa de argila'})
aAdd(aCBO,{'823110','Preparador de massa (fabricação de vidro)'})
aAdd(aCBO,{'823135','Operador de atomizador'})
aAdd(aCBO,{'823105','Preparador de massa (fabricação de abrasivos)'})
aAdd(aCBO,{'823215','Forneiro na fundição de vidro'})
aAdd(aCBO,{'823210','Extrusor de fios ou fibras de vidro'})
aAdd(aCBO,{'823220','Forneiro no recozimento de vidro'})
aAdd(aCBO,{'823265','Trabalhador na fabricação de produtos abrasivos'})
aAdd(aCBO,{'823255','Temperador de vidro'})
aAdd(aCBO,{'823250','Operador de prensa de moldar vidro'})
aAdd(aCBO,{'823245','Operador de máquina extrusora de varetas e tubos de vidro'})
aAdd(aCBO,{'823240','Operador de máquina de soprar vidro'})
aAdd(aCBO,{'823235','Operador de banho metálico de vidro por flutuação'})
aAdd(aCBO,{'823230','Moldador de abrasivos na fabricação de cerâmica, vidro e porcelana'})
aAdd(aCBO,{'823330','Trabalhador da fabricação de pedras artificiais'})
aAdd(aCBO,{'823325','Trabalhador da elaboração de pré-fabricados (concreto armado)'})
aAdd(aCBO,{'823320','Trabalhador da elaboração de pré-fabricados (cimento amianto)'})
aAdd(aCBO,{'823315','Forneiro (materiais de construção)'})
aAdd(aCBO,{'823305','Classificador e empilhador de tijolos refratários'})
aAdd(aCBO,{'828105','Oleiro (fabricação de telhas)'})
aAdd(aCBO,{'828110','Oleiro (fabricação de tijolos)'})
aAdd(aCBO,{'830105','Mestre (indústria de celulose, papel e papelão)'})
aAdd(aCBO,{'831120','Operador de lavagem e depuração de pasta para fabricação de papel'})
aAdd(aCBO,{'831115','Operador de digestor de pasta para fabricação de papel'})
aAdd(aCBO,{'831110','Operador de branqueador de pasta para fabricação de papel'})
aAdd(aCBO,{'831105','Cilindreiro na preparação de pasta para fabricação de papel'})
aAdd(aCBO,{'831125','Operador de máquina de secar celulose'})
aAdd(aCBO,{'832135','Operador de rebobinadeira na fabricação de papel e papelão'})
aAdd(aCBO,{'832120','Operador de máquina de fabricar papel (fase seca)'})
aAdd(aCBO,{'832115','Operador de máquina de fabricar papel (fase úmida)'})
aAdd(aCBO,{'832110','Operador de cortadeira de papel'})
aAdd(aCBO,{'832105','Calandrista de papel'})
aAdd(aCBO,{'832125','Operador de máquina de fabricar papel e papelão'})
aAdd(aCBO,{'833110','Confeccionador de bolsas, sacos e sacolas e papel, a máquina'})
aAdd(aCBO,{'833115','Confeccionador de sacos de celofane, a máquina'})
aAdd(aCBO,{'833120','Operador de máquina de cortar e dobrar papelão'})
aAdd(aCBO,{'833125','Operador de prensa de embutir papelão'})
aAdd(aCBO,{'833105','Cartonageiro, a máquina'})
aAdd(aCBO,{'833205','Cartonageiro, a mão (caixas de papelão)'})
aAdd(aCBO,{'840110','Supervisor da indústria de bebidas'})
aAdd(aCBO,{'840105','Supervisor de produção da indústria alimentícia'})
aAdd(aCBO,{'840115','Supervisor da indústria de fumo'})
aAdd(aCBO,{'840120','Chefe de confeitaria'})
aAdd(aCBO,{'841110','Moleiro de especiarias'})
aAdd(aCBO,{'841115','Operador de processo de moagem'})
aAdd(aCBO,{'841105','Moleiro de cereais (exceto arroz)'})
aAdd(aCBO,{'841205','Moedor de sal'})
aAdd(aCBO,{'841210','Refinador de sal'})
aAdd(aCBO,{'841305','Operador de cristalização na refinação de açucar'})
aAdd(aCBO,{'841310','Operador de equipamentos de refinação de açúcar (processo contínuo)'})
aAdd(aCBO,{'841315','Operador de moenda na fabricação de açúcar'})
aAdd(aCBO,{'841320','Operador de tratamento de calda na refinação de açúcar'})
aAdd(aCBO,{'841484','Trabalhador de preparação de pescados (limpeza)'})
aAdd(aCBO,{'841476','Trabalhador de fabricação de margarina'})
aAdd(aCBO,{'841472','Refinador de óleo e gordura'})
aAdd(aCBO,{'841468','Preparador de rações'})
aAdd(aCBO,{'841464','Prensador de frutas (exceto oleaginosas)'})
aAdd(aCBO,{'841460','Operador de preparação de grãos vegetais (óleos e gorduras)'})
aAdd(aCBO,{'841456','Operador de câmaras frias'})
aAdd(aCBO,{'841448','Lagareiro'})
aAdd(aCBO,{'841444','Hidrogenador de óleos e gorduras'})
aAdd(aCBO,{'841440','Esterilizador de alimentos'})
aAdd(aCBO,{'841432','Desidratador de alimentos'})
aAdd(aCBO,{'841428','Cozinhador de pescado'})
aAdd(aCBO,{'841420','Cozinhador de frutas e legumes'})
aAdd(aCBO,{'841416','Cozinhador de carnes'})
aAdd(aCBO,{'841408','Cozinhador (conservação de alimentos)'})
aAdd(aCBO,{'841505','Trabalhador de tratamento do leite e fabricação de laticínios e afins'})
aAdd(aCBO,{'841605','Misturador de café'})
aAdd(aCBO,{'841610','Torrador de café'})
aAdd(aCBO,{'841615','Moedor de café'})
aAdd(aCBO,{'841620','Operador de extração de café solúvel'})
aAdd(aCBO,{'841625','Torrador de cacau'})
aAdd(aCBO,{'841630','Misturador de chá ou mate'})
aAdd(aCBO,{'841740','Vinagreiro'})
aAdd(aCBO,{'841745','Xaropeiro'})
aAdd(aCBO,{'841705','Alambiqueiro'})
aAdd(aCBO,{'841710','Filtrador de cerveja'})
aAdd(aCBO,{'841715','Fermentador'})
aAdd(aCBO,{'841720','Trabalhador de fabricação de vinhos'})
aAdd(aCBO,{'841725','Malteiro (germinação)'})
aAdd(aCBO,{'841730','Cozinhador de malte'})
aAdd(aCBO,{'841735','Dessecador de malte'})
aAdd(aCBO,{'841805','Operador de forno (fabricação de pães, biscoitos e similares)'})
aAdd(aCBO,{'841810','Operador de máquinas de fabricação de doces, salgados e massas alimentícias'})
aAdd(aCBO,{'841815','Operador de máquinas de fabricação de chocolates e achocolatados'})
aAdd(aCBO,{'842125','Operador de máquina (fabricação de cigarros)'})
aAdd(aCBO,{'842135','Operador de máquina de preparação de matéria prima para produção de cigarros'})
aAdd(aCBO,{'842120','Auxiliar de processamento de fumo'})
aAdd(aCBO,{'842115','Classificador de fumo'})
aAdd(aCBO,{'842110','Processador de fumo'})
aAdd(aCBO,{'842105','Preparador de melado e essência de fumo'})
aAdd(aCBO,{'842230','Charuteiro a mão'})
aAdd(aCBO,{'842225','Celofanista na fabricação de charutos'})
aAdd(aCBO,{'842235','Degustador de charutos'})
aAdd(aCBO,{'842205','Preparador de fumo na fabricação de charutos'})
aAdd(aCBO,{'842210','Operador de máquina de fabricar charutos e cigarrilhas'})
aAdd(aCBO,{'842215','Classificador de charutos'})
aAdd(aCBO,{'842220','Cortador de charutos'})
aAdd(aCBO,{'848115','Salsicheiro (fabricação de lingüiça, salsicha e produtos similares)'})
aAdd(aCBO,{'848110','Salgador de alimentos'})
aAdd(aCBO,{'848105','Defumador de carnes e pescados'})
aAdd(aCBO,{'848215','Manteigueiro na fabricação de laticínio'})
aAdd(aCBO,{'848205','Pasteurizador'})
aAdd(aCBO,{'848210','Queijeiro na fabricação de laticínio'})
aAdd(aCBO,{'848305','Padeiro'})
aAdd(aCBO,{'848310','Confeiteiro'})
aAdd(aCBO,{'848315','Masseiro (massas alimentícias)'})
aAdd(aCBO,{'848325','Trabalhador de fabricação de sorvete'})
aAdd(aCBO,{'848405','Degustador de café'})
aAdd(aCBO,{'848410','Degustador de chá'})
aAdd(aCBO,{'848425','Classificador de grãos'})
aAdd(aCBO,{'848420','Degustador de vinhos ou licores'})
aAdd(aCBO,{'848415','Degustador de derivados de cacau'})
aAdd(aCBO,{'848525','Retalhador de carne'})
aAdd(aCBO,{'848520','Magarefe'})
aAdd(aCBO,{'848505','Abatedor'})
aAdd(aCBO,{'848510','Açougueiro'})
aAdd(aCBO,{'848515','Desossador'})
aAdd(aCBO,{'848605','Trabalhador do beneficiamento de fumo'})
aAdd(aCBO,{'860105','Supervisor de manutenção eletromecânica (utilidades)'})
aAdd(aCBO,{'860115','Supervisor de operação elétrica (geração, transmissão e distribuição de energia elétrica)'})
aAdd(aCBO,{'860110','Supervisor de operação de fluidos (distribuição, captação, tratamento de água, gases, vapor)'})
aAdd(aCBO,{'861120','Operador de reator nuclear'})
aAdd(aCBO,{'861115','Operador de central termoelétrica'})
aAdd(aCBO,{'861110','Operador de quadro de distribuição de energia elétrica'})
aAdd(aCBO,{'861105','Operador de central hidrelétrica'})
aAdd(aCBO,{'861205','Operador de subestação'})
aAdd(aCBO,{'862155','Operador de utilidade (produção e distribuição de vapor, gás, óleo, combustível, energia, oxigênio)'})
aAdd(aCBO,{'862140','Operador de estação de bombeamento'})
aAdd(aCBO,{'862130','Operador de compressor de ar'})
aAdd(aCBO,{'862120','Operador de caldeira'})
aAdd(aCBO,{'862115','Operador de bateria de gás de hulha'})
aAdd(aCBO,{'862110','Maquinista de embarcações'})
aAdd(aCBO,{'862105','Foguista (locomotivas a vapor)'})
aAdd(aCBO,{'862150','Operador de máquinas fixas, em geral'})
aAdd(aCBO,{'862205','Operador de estação de captação, tratamento e distribuição de água'})
aAdd(aCBO,{'862305','Operador de estação de tratamento de água e efluentes'})
aAdd(aCBO,{'862310','Operador de forno de incineração no tratamento de água, efluentes e resíduos industriais'})
aAdd(aCBO,{'862405','Operador de instalação de extração, processamento, envasamento e distribuição de gases'})
aAdd(aCBO,{'862505','Operador de instalação de refrigeração'})
aAdd(aCBO,{'862510','Operador de refrigeração com amônia'})
aAdd(aCBO,{'862515','Operador de instalação de ar-condicionado'})
aAdd(aCBO,{'910110','Supervisor de manutenção de aparelhos térmicos, de climatização e de refrigeração'})
aAdd(aCBO,{'910130','Supervisor de manutenção de máquinas operatrizes e de usinagem'})
aAdd(aCBO,{'910125','Supervisor de manutenção de máquinas industriais têxteis'})
aAdd(aCBO,{'910120','Supervisor de manutenção de máquinas gráficas'})
aAdd(aCBO,{'910105','Encarregado de manutenção mecânica de sistemas operacionais'})
aAdd(aCBO,{'910115','Supervisor de manutenção de bombas, motores, compressores e equipamentos de transmissão'})
aAdd(aCBO,{'910205','Supervisor da manutenção e reparação de veículos leves'})
aAdd(aCBO,{'910210','Supervisor da manutenção e reparação de veículos pesados'})
aAdd(aCBO,{'910905','Supervisor de reparos linhas férreas'})
aAdd(aCBO,{'910910','Supervisor de manutenção de vias férreas'})
aAdd(aCBO,{'911105','Mecânico de manutenção de bomba injetora (exceto de veículos automotores)'})
aAdd(aCBO,{'911135','Mecânico de manutenção de turbocompressores'})
aAdd(aCBO,{'911130','Mecânico de manutenção de turbinas (exceto de aeronaves)'})
aAdd(aCBO,{'911125','Mecânico de manutenção de redutores'})
aAdd(aCBO,{'911120','Mecânico de manutenção de motores diesel (exceto de veículos automotores)'})
aAdd(aCBO,{'911115','Mecânico de manutenção de compressores de ar'})
aAdd(aCBO,{'911110','Mecânico de manutenção de bombas'})
aAdd(aCBO,{'911205','Mecânico de manutenção e instalação de aparelhos de climatização e refrigeração'})
aAdd(aCBO,{'911310','Mecânico de manutenção de máquinas gráficas'})
aAdd(aCBO,{'911305','Mecânico de manutenção de máquinas, em geral'})
aAdd(aCBO,{'911320','Mecânico de manutenção de máquinas têxteis'})
aAdd(aCBO,{'911315','Mecânico de manutenção de máquinas operatrizes (lavra de madeira)'})
aAdd(aCBO,{'911325','Mecânico de manutenção de máquinas-ferramentas (usinagem de metais)'})
aAdd(aCBO,{'913110','Mecânico de manutenção de equipamento de mineração'})
aAdd(aCBO,{'913105','Mecânico de manutenção de aparelhos de levantamento'})
aAdd(aCBO,{'913115','Mecânico de manutenção de máquinas agrícolas'})
aAdd(aCBO,{'913120','Mecânico de manutenção de máquinas de construção e terraplenagem'})
aAdd(aCBO,{'914105','Mecânico de manutenção de aeronaves, em geral'})
aAdd(aCBO,{'914110','Mecânico de manutenção de sistema hidráulico de aeronaves (serviços de pista e hangar)'})
aAdd(aCBO,{'914205','Mecânico de manutenção de motores e equipamentos navais'})
aAdd(aCBO,{'914305','Mecânico de manutenção de veículos ferroviários'})
aAdd(aCBO,{'914420','Mecânico de manutenção de tratores'})
aAdd(aCBO,{'914415','Mecânico de manutenção de motocicletas'})
aAdd(aCBO,{'914410','Mecânico de manutenção de empilhadeiras e outros veículos de cargas leves'})
aAdd(aCBO,{'914425','Mecânico de veículos automotores a diesel (exceto tratores)'})
aAdd(aCBO,{'914405','Mecânico de manutenção de automóveis, motocicletas e veículos similares'})
aAdd(aCBO,{'915110','Técnico em manutenção de hidrômetros'})
aAdd(aCBO,{'915105','Técnico em manutenção de instrumentos de medição e precisão'})
aAdd(aCBO,{'915115','Técnico em manutenção de balanças'})
aAdd(aCBO,{'915205','Restaurador de instrumentos musicais (exceto cordas arcadas)'})
aAdd(aCBO,{'915210','Reparador de instrumentos musicais'})
aAdd(aCBO,{'915215','Luthier (restauração de cordas arcadas)'})
aAdd(aCBO,{'915305','Técnico em manutenção de equipamentos e instrumentos médico-hospitalares'})
aAdd(aCBO,{'915405','Reparador de equipamentos fotográficos'})
aAdd(aCBO,{'919105','Lubrificador industrial'})
aAdd(aCBO,{'919115','Lubrificador de embarcações'})
aAdd(aCBO,{'919110','Lubrificador de veículos automotores (exceto embarcações)'})
aAdd(aCBO,{'919205','Mecânico de manutenção de máquinas cortadoras de grama, roçadeiras, motosserras e similares'})
aAdd(aCBO,{'919310','Mecânico de manutenção de bicicletas e veículos similares'})
aAdd(aCBO,{'919305','Mecânico de manutenção de aparelhos esportivos e de ginástica'})
aAdd(aCBO,{'919315','Montador de bicicletas'})
aAdd(aCBO,{'950105','Supervisor de manutenção elétrica de alta tensão industrial'})
aAdd(aCBO,{'950110','Supervisor de manutenção eletromecânica industrial, comercial e predial'})
aAdd(aCBO,{'950205','Encarregado de manutenção elétrica de veículos'})
aAdd(aCBO,{'950305','Supervisor de manutenção eletromecânica'})
aAdd(aCBO,{'951105','Eletricista de manutenção eletroeletrônica'})
aAdd(aCBO,{'951305','Instalador de sistemas eletroeletrônicos de segurança'})
aAdd(aCBO,{'951310','Mantenedor de sistemas eletroeletrônicos de segurança'})
aAdd(aCBO,{'953105','Eletricista de instalações (aeronaves)'})
aAdd(aCBO,{'953110','Eletricista de instalações (embarcações)'})
aAdd(aCBO,{'953115','Eletricista de instalações (veículos automotores e máquinas operatrizes, exceto aeronaves e embarca'})
aAdd(aCBO,{'954105','Eletromecânico de manutenção de elevadores'})
aAdd(aCBO,{'954110','Eletromecânico de manutenção de escadas rolantes'})
aAdd(aCBO,{'954115','Eletromecânico de manutenção de portas automáticas'})
aAdd(aCBO,{'954120','Mecânico de manutenção de instalações mecânicas de edifícios'})
aAdd(aCBO,{'954125','Operador eletromecânico'})
aAdd(aCBO,{'954205','Reparador de aparelhos eletrodomésticos (exceto imagem e som)'})
aAdd(aCBO,{'954210','Reparador de rádio, tv e som'})
aAdd(aCBO,{'954305','Reparador de equipamentos de escritório'})
aAdd(aCBO,{'991105','Conservador de via permanente (trilhos)'})
aAdd(aCBO,{'991110','Inspetor de via permanente (trilhos)'})
aAdd(aCBO,{'991115','Operador de máquinas especiais em conservação de via permanente (trilhos)'})
aAdd(aCBO,{'991120','Soldador aluminotérmico em conservação de trilhos'})
aAdd(aCBO,{'991205','Mantenedor de equipamentos de parques de diversões e similares'})
aAdd(aCBO,{'991305','Funileiro de veículos (reparação)'})
aAdd(aCBO,{'991310','Montador de veículos (reparação)'})
aAdd(aCBO,{'991315','Pintor de veículos (reparação)'})
aAdd(aCBO,{'992105','Alinhador de pneus'})
aAdd(aCBO,{'992120','Lavador de peças'})
aAdd(aCBO,{'992115','Borracheiro'})
aAdd(aCBO,{'992110','Balanceador'})
aAdd(aCBO,{'992205','Encarregado geral de operações de conservação de vias permanentes (exceto trilhos)'})
aAdd(aCBO,{'992220','Pedreiro de conservação de vias permanentes (exceto trilhos)'})
aAdd(aCBO,{'992215','Operador de ceifadeira na conservação de vias permanentes'})
aAdd(aCBO,{'992210','Encarregado de equipe de conservação de vias permanentes (exceto trilhos)'})
aAdd(aCBO,{'992225','Auxiliar geral de conservação de vias permanentes (exceto trilhos)'})

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