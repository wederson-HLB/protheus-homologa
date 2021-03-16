
#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTBAUD03  ºAutor  ³Rafael Rosa da Silvaº Data ³  31/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de Controle de Acesso	 								 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL									  		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GTBAUD03()

Local cPerg		:= "GTBAUD0301"
Local aParamBox	:= {}
Local cTitulo	:= "Relatorio de Controle de Acesso"
Local aRet		:= {}

aAdd(aParamBox, {1,"Usuário de :",Space(6),"@!","","USR",".T.",6,.F.} )
aAdd(aParamBox, {1,"Usuário AtE",Space(6),"@!","","USR",".T.",6,.F.} )
//  [2] : Descrição
//  [3] : String contendo o inicializador do campo
//  [4] : String contendo a Picture do campo
//  [5] : String contendo a validação
//  [6] : Consulta F3
//  [7] : String contendo a validação When
//  [8] : Tamanho do MsGet
//  [9] : Flag .T./.F. Parâmetro Obrigatório ?
aAdd(aParamBox, {6,"Selecione o Diretorio:",Space(80),"","","",80,.T.,"Arquivo .XML |*.XML","C:\",GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY})
// Tipo 6 -> File
//  [2] : Descrição
//  [3] : String contendo o inicializador do campo
//  [4] : String contendo a Picture do campo
//  [5] : String contendo a validação
//  [6] : String contendo a validação When
//  [7] : Tamanho do MsGet
//  [8] : Flag .T./.F. Parâmetro Obrigatório ?
//  [9] : Texto contendo os tipos de arquivo Ex.: "Arquivos .CSV |*.CSV"
//  [10]: Diretório inicial do cGetFile
//  [11]: PARAMETROS do cGETFILE

// Parametros da função Parambox()
// -------------------------------
// 1- Vetor com as configurações
// 2- Tú‘ulo da janela
// 3- Vetor passador por referencia que contém o retorno dos parâmetros
// 4- Code block para validar o botão Ok
// 5- Vetor com mais botões além dos botões de Ok e Cancel
// 6- Centralizar a janela
// 7- Se não centralizar janela coordenada X para inú€io
// 8- Se não centralizar janela coordenada Y para inú€io
// 9- Utiliza o objeto da janela ativa
//10- Nome do perfil se caso for carregar
//11- Salvar os dados informados por perfil

If ParamBox(aParamBox,cTitulo,@aRet)
	Processa( {|| AUD03Prc(aRet) }, "Aguarde...", "Filtrando os dados...",.F.)		
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUD03Prc  ºAutor  ³Rafael Rosa da Silvaº Data ³  31/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtra as informacoes conforme os parametros repostados peloº±±
±±º          ³usuario															 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL									  		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AUD03Prc(aParam)

Local aUsers	:= AllUsers(.F.,.T.)		//Busca todos os usuarios
Local aGroups	:= {}						//Busca os dados do grupo do usuario
Local nI		:= 0						//contador
Local nY		:= 0						//Contador
Local nX		:= 0						//Contador
Local nPUser	:= 0						//Posicao do array aDados
Local aDados	:= {}						//Array contendo os dados do Usuario
Local aMenus	:= {}						//Array Contendo os Menus e seus respectivos dados
Local aMnuGrp	:= {}						//Menus vinculados aos grupos
Local cMenu	:= ""						//Nome do Menu tratado
Local lGrupo	:= .F.						//Verifica se prioriza a regra por grupo					
Local cPUsrIni	:= Alltrim(aParam[1])				//Usuario inicial do parametro
Local cPUsrFim	:= Alltrim(aParam[2])				//Usuario final do parametro
Local cDirExp	:= Alltrim(aParam[3])				//Diretorio de 
Local cTpGrpUsr	:= ""								//Informa o tipo do Grupo do Usuario
Local cDcTpGrp	:= ""

/*========================================\
|		Elementos do Array aDados			|
|_________________________________________|						
|aDados[01]	-	Codigo				
|aDados[02]	-	Usuario					|
|aDados[03]	-	Nome Completo				|
|aDados[04]	-	E-Mail						|
|aDados[05]	-	Departamento				|
|aDados[06]	-	Cargo						|
|aDados[07][1]-	Grupo						|
|aDados[07][2]-	Nome do Grupo				|
|aDados[08]	-	Prioriza					|
|aDados[09][1]-	Modulo (Nome do Modulo)	|
|aDados[09][2]-	Perfil (Nome do Arquivo)	|
|aDados[10]	-	Permissoes do Usuario	|
\========================================*/ 

ProcRegua(0)

//Busca os dados do Usuario
For nI := 1 to Len(aUsers)
	IncProc()
	
	If Alltrim(aUsers[nI][1][01])  < cPUsrIni .Or. Alltrim(aUsers[nI][1][01])  > cPUsrFim
		Loop
	EndIf
	/*=====================================\
	|		Regra de grupo do usuário		|
	| ------------------------------------	|
	|0 - Não encontrou o usuário informado	|
	|1 - Prioriza regra por grupo			|
	|2 - Desconsidera regra por grupo		|
	|3 - Soma regra por grupo				|
	\=====================================*/
	cTpGrpUsr := FWUsrGrpRule(Alltrim(aUsers[nI][1][01]))
	
	//Monta a Descricao do Tipo de Regra do Grupo
	If cTpGrpUsr == "1"
		cDcTpGrp := "Prioriza regra por grupo"
	ElseIf cTpGrpUsr == "2"
		cDcTpGrp := "Desconsidera regra por grupo"
	ElseIf cTpGrpUsr == "3"
		cDcTpGrp := "Soma regra por grupo"
	EndIf
	
	aAdd(aDados,{	Alltrim(aUsers[nI][1][01]),;			//01 - Codigo
					Alltrim(aUsers[nI][1][02]),;			//02 - Usuario
					Alltrim(aUsers[nI][1][04]),;			//03 - Nome Completo
					Alltrim(aUsers[nI][1][14]),;			//04 - E-Mail
					Alltrim(aUsers[nI][1][12]),;			//05 - Departamento
					Alltrim(aUsers[nI][1][13]),;			//06 - Cargo
					{"",""},;									//07 - Dados do Grupo
					cDcTpGrp,;									//08 - Prioriza o Grupo
					{},;										//09 - Menus
					aUsers[nI][2][5]})						//10 - Permissoes do Usuario
					
	nPUser := Len(aDados)

	//Trata os grupos que o usuario pertence					
	For nY := 1 to Len(aUsers[nI][1][10])
		If Alltrim(aUsers[nI][1][10][nY]) >= Alltrim(MV_PAR01) .And. Alltrim(aUsers[nI][1][10][nY]) <= Alltrim(MV_PAR02)
			aGroups := FWGrpParam(aUsers[nI][1][10][nY])
			If nY == 1
				aDados[nPUser][7][1]	:= Alltrim(aGroups[1][1])	//Codigo do Grupo
				aDados[nPUser][7][2]	:= Alltrim(aGroups[1][2])	//Nome do Grupo										
			Else
				aAdd(aDados[nPUser][7],{Alltrim(aGroups[1][1]),Alltrim(aGroups[1][2])})
			EndIf
		EndIf
	Next nY
	
	//Trata os Menus que ele possui
	//Verifica se prioriza Grupo ou se Soma ao grupo
	If cTpGrpUsr == "1" .Or. cTpGrpUsr == "3"
		For nY := 1 to Len(aUsers[nI][1][10])
			aMnuGrp := FWGrpMenu(aUsers[nI][1][10][nY])
			For nX := 1 to Len(aMnuGrp)
				If Upper(Alltrim(SubStr(aMnuGrp[nX],3,1))) <> "X"
					cMenu	:= Upper(Alltrim(SubStr(aMnuGrp[nX],4)))
					 
					aAdd(aDados[nPUser][9],{cMenu,Val(SubStr(aMnuGrp[nX],1,2))})
					
					If aScan(aMenus,{|x| x[1] == cMenu }) == 0
						aAdd(aMenus,{cMenu,XNULoad(cMenu),Val(SubStr(aMnuGrp[nX],1,2))})
					EndIf
				EndIf
			Next nX
		Next nY
	EndIf
	
	//Verifica se nao prioriza o Grupo ou se Soma
	If cTpGrpUsr == "2" .Or. cTpGrpUsr == "3"
		For nY := 1 to Len(aUsers[nI][3])
			If Upper(Alltrim(SubStr(aUsers[nI][3][nY],3,1))) <> "X"
				cMenu	:= Upper(Alltrim(SubStr(aUsers[nI][3][nY],4)))
				 
				aAdd(aDados[nPUser][9],{cMenu,Val(SubStr(aUsers[nI][3][nY],1,2))})
				
				If aScan(aMenus,{|x| x[1] == cMenu }) == 0
					aAdd(aMenus,{cMenu,XNULoad(cMenu),Val(SubStr(aUsers[nI][3][nY],1,2))})
				EndIf
			EndIf
		Next nY
	EndIf
Next nI

If Len(aDados) > 0
	Processa( {|| AUD03MontXML(aDados,aMenus,cDirExp) }, "Aguarde...", "Montando os Arquivos...",.F.)
Else
	ApMsgInfo("Não foram encontrados dados para exportar")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUD03MontXMLºAutor³Rafael Rosa da Silvaº Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que monta o XML											 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL											º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AUD03MontXML(aDados,aMenus,cDirExp)

Local nI		:= 0					//Contador

ProcRegua(Len(aDados))

For nI := 1 to Len(aDados)
	
	IncProc("Processando analise do usuario: " + aDados[nI][2])
	
	AUD03XMLDet(aDados[nI],aMenus,cDirExp)
Next nI

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUD03XMLDetºAutor ³Rafael Rosa da Silvaº Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o Cabecalho do XML											 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL											º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AUD03XMLDet(aUsr,aMenus,cDirExp)

Local nI		:= 0									//Contador
Local nY		:= 0 									//Contador
Local nPMenu	:= 0									//Variavel de posicionamento para aScan
Local nLinha	:= 1									//Numero da Linha
Local cMenu	:= ""									//Nome do Menu posicionado
Local cTitulo	:= "Controle de Acesso Protheus" 	//Titulo da planilha	
Local cCodigo	:= aUsr[1]								//Codigo do Usuario
Local cUser	:= aUsr[2]								//Usuario de Acesso
Local cNomComp:= aUsr[3]								//Nome Completo
Local cEMail	:= aUsr[4]								//E-Mail
Local cDepart	:= aUsr[5]								//Departamento
Local cCargo	:= aUsr[6]								//Cargo
Local cGrupo	:= aUsr[7][1]							//Grupo do Usuario
Local cPriori	:= aUsr[8]								//Prioriza o Grupo
Local aMenuUsr	:= aUsr[9]								//Menus vinculados ao usuario
Local cPerUsr	:= aUsr[10]							//Permissao do cadastro do usuario  
Local aMenuAux:= {}									//Array Auxiliar do Menu
Local oExcel	:= FWMSEXCEL():New()					//Cria o objeto do Excel
Local aPerusr	:= AUD03PerUsr()						//Busca o array contendo todas as permissoes disponiveis para o sistema
Local aNomMenu	:= AUD03NomMod()						//Busca o nome do Menu

//Permissoes do Cadastro de Usuario
cMenu := "Usuário"
oExcel:AddworkSheet(cMenu)
oExcel:AddTable (cMenu,cTitulo)

oExcel:AddColumn(cMenu,cTitulo,"",1,1)
oExcel:AddColumn(cMenu,cTitulo,"",1,1)
	
oExcel:AddRow(cMenu,cTitulo,{"Código:"			,cCodigo		})
oExcel:AddRow(cMenu,cTitulo,{"Usuário:"		,cUser			})
oExcel:AddRow(cMenu,cTitulo,{"Nome Completo:"	,cNomComp		})	
oExcel:AddRow(cMenu,cTitulo,{"E-Mail:"			,cEMail		})
oExcel:AddRow(cMenu,cTitulo,{"Departamento:"	,cDepart		})
oExcel:AddRow(cMenu,cTitulo,{"Cargo:"			,cCargo		})	
oExcel:AddRow(cMenu,cTitulo,{"Grupo:"			,cGrupo		})
oExcel:AddRow(cMenu,cTitulo,{"Prioriza:"		,cPriori		})

oExcel:AddRow(cMenu,cTitulo,{""		,""		})
oExcel:AddRow(cMenu,cTitulo,{"Acesso"		,"Habilitado"		})

//Tratamento das permissoes do cadastro do usuario
For nI := 1 to Len(aPerUsr)
	 oExcel:AddRow(cMenu,cTitulo,{aPerUsr[nI][2]	,IIF(SubStr(cPerUsr,nI,1) == "S","Sim","Não")	})
Next nI

//Permissoes do Menu
For nI := 1 to Len(aMenuUsr)
	nPMenu 		:= aScan(aMenus,{|x| x[1] == aMenuUsr[nI][1] })
	aMenuAux	:= aMenus[nPMenu][2]
	cMenu		:= aNomMenu[aScan(aNomMenu,{|x| x[1] == aMenuUsr[nI][2]})][2]
	cTitulo		:= "Módulo: " + cMenu + " Perfil: " + aMenuUsr[nI][1]
	
	oExcel:AddworkSheet(cMenu)
	oExcel:AddTable (cMenu,cTitulo)

	oExcel:AddColumn(cMenu,cTitulo,"Nú“eis de Acesso",1,1)
	oExcel:AddColumn(cMenu,cTitulo,"Habilitado"		,1,1)
	oExcel:AddColumn(cMenu,cTitulo,"Visualizar"		,1,1)
	oExcel:AddColumn(cMenu,cTitulo,"Incluir"			,1,1)	
	oExcel:AddColumn(cMenu,cTitulo,"Alterar"			,1,1)
	oExcel:AddColumn(cMenu,cTitulo,"Excluir"			,1,1)
	oExcel:AddColumn(cMenu,cTitulo,"Observações"		,1,1)	
	
	//No laco do Menu chama a funcao recursiva AUD03TratNo para tratar os Nos do Menu 
	For nY := 1 to Len(aMenuAux)
		AUD03TratNo(aMenuAux[nY],@oExcel,cMenu,cTitulo,.T.)
	Next nY
Next nI

oExcel:Activate()
If File(cDirExp + cUser + ".XML")
	oExcel:GetXMLFile(cDirExp + cUser + dTos(dDataBase) + StrTran(Time(),":","") +".XML")
Else
	oExcel:GetXMLFile(cDirExp + cUser + ".XML")
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUD03TratNoºAutor ³Rafael Rosa da Silvaº Data ³  08/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para tratar os Nos do Menu							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AUD03TratNo(aMnuNo,oExcel,cMenu,cTitulo,lNoPrinc)

Local nI		:= 0			//Contador
Local cTxtMenu	:= ""			//Label do item do menu
Local cVisual	:= ""			//Disponivel Visualizacao?
Local cInclui	:= ""			//Disponivel Inclusao?
Local cAltera	:= ""			//Disponivel Alteracao?
Local cExclui	:= ""			//Disponivel Exclusao?
Local cRotina	:= ""			//Coluna de Observacoes
Local cStItMen:= ""			//Status do item de Menu (Habilitado/Desabilitado/Inativo)

Default lNoPrinc	:= .F.

If ValType(aMnuNo[3]) == "A" .And. Len(aMnuNo[3]) > 0 
	cTxtMenu:= aMnuNo[1][1]
	cStItMen:= IIF(aMnuNo[2] == "E","Habilitado",IIF(aMnuNo[2] == "D","Desabilitado","Inativo"))
	
	//Inclui a raiz do Menu
	//If lNoPrinc
		oExcel:AddRow(cMenu,cTitulo,{""			,""			,""		,""		,""		,""		,""		})
	//EndIf
	
	oExcel:AddRow(cMenu,cTitulo,{cTxtMenu	,cStItMen	," - "	," - "	," - "	," - "	," - "	})
	  	

	For nI := 1 to Len(aMnuNo[3])
		AUD03TratNo(aMnuNo[3][nI],@oExcel,cMenu,cTitulo,.F.)
	Next nI
Else
	cTxtMenu	:= aMnuNo[1][1]
	cVisual	:= IIF(Upper(SubStr(aMnuNo[5],2,1)) == "X","Sim","Não")	
	cInclui	:= IIF(Upper(SubStr(aMnuNo[5],3,1)) == "X","Sim","Não")
	cAltera	:= IIF(Upper(SubStr(aMnuNo[5],4,1)) == "X","Sim","Não")
	cExclui	:= IIF(Upper(SubStr(aMnuNo[5],5,1)) == "X","Sim","Não")
	cRotina	:= aMnuNo[3]
	cStItMen	:= IIF(aMnuNo[2] == "E","Habilitado",IIF(aMnuNo[2] == "D","Desabilitado","Inativo"))
	
	oExcel:AddRow(cMenu,cTitulo,{cTxtMenu,cStItMen,cVisual,cInclui,cAltera,cExclui,cRotina})
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUD03PerUsrºAutor  ³Rafael Rosa da Silvaº Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que retorna as permissoes de usuario				    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL											º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³O tratamento interno do Protheus eh fixo						º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AUD03PerUsr()

Local aPerUsr	:= {}

aAdd(aPerUsr,{1	,"Excluir Produtos"																			})
aAdd(aPerUsr,{2	,"Alterar Produtos"																			})
aAdd(aPerUsr,{3	,"Excluir Cadastros"																			})
aAdd(aPerUsr,{4	,"Alterar Solicit Compras"																	})
aAdd(aPerUsr,{5	,"Excluir Solicit Compras"																	})
aAdd(aPerUsr,{6	,"Alterar Pedidos Compras"																	})
aAdd(aPerUsr,{7	,"Excluir Pedidos Compras"																	})
aAdd(aPerUsr,{8	,"Analisar Cotaçoes"																			})
aAdd(aPerUsr,{9	,"Relat Ficha Cadastral"																		})
aAdd(aPerUsr,{10	,"Relat Bancos"																				})
aAdd(aPerUsr,{11	,"Relacao Solicit Compras"																	})
aAdd(aPerUsr,{12	,"Relacao de Pedidos Compra"																})
aAdd(aPerUsr,{13	,"Alterar Estruturas"																		})
aAdd(aPerUsr,{14	,"Excluir Estruturas"																		})
aAdd(aPerUsr,{15	,"Alterar TES"																				})
aAdd(aPerUsr,{16	,"Excluir TES"																				})
aAdd(aPerUsr,{17	,"Inventario"																					})
aAdd(aPerUsr,{18	,"Fechamento Mensal"																			})
aAdd(aPerUsr,{19	,"Proc Diferenca Inventario"																})
aAdd(aPerUsr,{20	,"Alterar Pedidos de Venda"																	})
aAdd(aPerUsr,{21	,"Excluir Pedidos de Venda"																	})
aAdd(aPerUsr,{22	,"Alterar Help`s"																				})
aAdd(aPerUsr,{23	,"Substituiçäo de TEulos"																	})
aAdd(aPerUsr,{24	,"Inclusäo do Dados Via F3"																	})
aAdd(aPerUsr,{25	,"Rotina de Atendimento"																		})
aAdd(aPerUsr,{26	,"Proc. Troco"																				})
aAdd(aPerUsr,{27	,"Proc. Sangria"																				})
aAdd(aPerUsr,{28	,"BorderECheques PrEDat."																	})
aAdd(aPerUsr,{29	,"Rotina de Pagamento"																		})
aAdd(aPerUsr,{30	,"Rotina de Recebimento"																		})
aAdd(aPerUsr,{31	,"Troca de Mercadorias"																		})
aAdd(aPerUsr,{32	,"Acesso Tabela de Precos"																	})
aAdd(aPerUsr,{33	,"Não utilizado"																				})
aAdd(aPerUsr,{34	,"Não utilizado"																				})
aAdd(aPerUsr,{35	,"Acesso Condicao Negociada"																})
aAdd(aPerUsr,{36	,"Alterar Database do Sist."																})
aAdd(aPerUsr,{37	,"Alterar Empenhos de OPs."																	})
aAdd(aPerUsr,{38	,"Não utilizado"																				})
aAdd(aPerUsr,{39	,"Form.Preços Todos Nú“eis"																	})
aAdd(aPerUsr,{40	,"Configura Venda Rapida"																	})
aAdd(aPerUsr,{41	,"Abrir/Fechar Caixa"																		})
aAdd(aPerUsr,{42	,"Excluir Nota/OrE LOJA"																	})
aAdd(aPerUsr,{43	,"Alterar Bem Ativo Fixo"																	})
aAdd(aPerUsr,{44	,"Excluir Bem Ativo Fixo"																	})
aAdd(aPerUsr,{45	,"Incluir Bem via Copia"																		})
aAdd(aPerUsr,{46	,"Tx Juros Condic Negociada"																})
aAdd(aPerUsr,{47	,"Liberacao Venda Forcad TEF"																})
aAdd(aPerUsr,{48	,"Cancelamento Venda TEF"																	})
aAdd(aPerUsr,{49	,"Cadastra Moeda na Abertura"																})
aAdd(aPerUsr,{50	,"Alterar Num. da NF"																		})
aAdd(aPerUsr,{51	,"Emitir NF Retroativa"																		})
aAdd(aPerUsr,{52	,"Excluir Baixa - Receber"																	})
aAdd(aPerUsr,{53	,"Excluir Baixa - Pagar"																		})
aAdd(aPerUsr,{54	,"Incluir Tabelas"																			})
aAdd(aPerUsr,{55	,"Alterar Tabelas"																			})
aAdd(aPerUsr,{56	,"Excluir Tabelas"																			})
aAdd(aPerUsr,{57	,"Incluir Contratos"																			})
aAdd(aPerUsr,{58	,"Alterar Contratos"																			})
aAdd(aPerUsr,{59	,"Excluir Contratos"																			})
aAdd(aPerUsr,{60	,"Uso Integraçäo SIGAEIC"																	})
aAdd(aPerUsr,{61	,"Incluir Emprestimo"																		})
aAdd(aPerUsr,{62	,"Alterar Emprestimo"																		})
aAdd(aPerUsr,{63	,"Excluir Emprestimo"																		})
aAdd(aPerUsr,{64	,"Incluir Leasing"																			})
aAdd(aPerUsr,{65	,"Alterar Leasing"																			})
aAdd(aPerUsr,{66	,"Excluir Leasing"																			})
aAdd(aPerUsr,{67	,"Incluir Imp.Nao Financ."																	})
aAdd(aPerUsr,{68	,"Alterar Imp.Nao Financ."																	})
aAdd(aPerUsr,{69	,"Excluir Imp.Nao Financ."																	})
aAdd(aPerUsr,{70	,"Incluir Imp.Financiada"																	})
aAdd(aPerUsr,{71	,"Alterar Imp.Financiada"																	})
aAdd(aPerUsr,{72	,"Excluir Imp.Financiada"																	})
aAdd(aPerUsr,{73	,"Incluir Imp.Fin.Export."																	})
aAdd(aPerUsr,{74	,"Alterar Imp.Fin.Export."																	})
aAdd(aPerUsr,{75	,"Excluir Imp.Fin.Export."																	})
aAdd(aPerUsr,{76	,"Incluir Contrato"																			})
aAdd(aPerUsr,{77	,"Alterar Contrato"																			})
aAdd(aPerUsr,{78	,"Excluir Contrato"																			})
aAdd(aPerUsr,{79	,"Lancar Taxa Libor"																			})
aAdd(aPerUsr,{80	,"Consolidar Empresas"																		})
aAdd(aPerUsr,{81	,"Incluir Cadastros"																			})
aAdd(aPerUsr,{82	,"Alterar Cadastros"																			})
aAdd(aPerUsr,{83	,"Incluir Cotacao Moedas"																	})
aAdd(aPerUsr,{84	,"Alterar Cotacao Moedas"																	})
aAdd(aPerUsr,{85	,"Excluir Cotacao Moedas"																	})
aAdd(aPerUsr,{86	,"Incluir Corretoras"																		})
aAdd(aPerUsr,{87	,"Alterar Corretoras"																		})
aAdd(aPerUsr,{88	,"Excluir Corretoras"																		})
aAdd(aPerUsr,{89	,"Incluir Imp./Exp./Cons"																	})
aAdd(aPerUsr,{90	,"Alterar Imp./Exp./Cons"																	})
aAdd(aPerUsr,{91	,"Excluir Imp./Exp./Cons"																	})
aAdd(aPerUsr,{92	,"Baixa Solicitacoes"																		})
aAdd(aPerUsr,{93	,"Visualiza Arquivo Limite"																	})
aAdd(aPerUsr,{94	,"Imprime  Doctos.Cancelados"																})
aAdd(aPerUsr,{95	,"Reativa  Doctos.Cancelados"																})
aAdd(aPerUsr,{96	,"Consulta Doctos.Obsoletos"																})
aAdd(aPerUsr,{97	,"Imprime  Doctos.Obsoletos"																})
aAdd(aPerUsr,{98	,"Consulta Doctos.Vencidos"																	})
aAdd(aPerUsr,{99	,"Imprime  Doctos.Vencidos"																	})
aAdd(aPerUsr,{100	,"Def. Laudo final Entrega"																	})
aAdd(aPerUsr,{101	,"Imprime Param Relatorios"																	})
aAdd(aPerUsr,{102	,"Transfere Pendencias"																		})
aAdd(aPerUsr,{103	,"Usa relatorio por e-mail"																	})
aAdd(aPerUsr,{104	,"Consulta posicao cliente"																	})
aAdd(aPerUsr,{105	,"Manuten. Aus Temp. Todos"																	})
aAdd(aPerUsr,{106	,"Manuten. Aus. Temp Usuario"																})
aAdd(aPerUsr,{107	,"Formação de Preço"																			})
aAdd(aPerUsr,{108	,"Gravar Resposta Parametros"																})
aAdd(aPerUsr,{109	,"Configurar Consulta F3"																	})
aAdd(aPerUsr,{110	,"Permite alterar configuração de impressora"												})
aAdd(aPerUsr,{111	,"Gerar Rel. em Disco Local"																})
aAdd(aPerUsr,{112	,"Gerar Rel. no Servidor"																	})
aAdd(aPerUsr,{113	,"Incluir Solic. Compras"																	})
aAdd(aPerUsr,{114	,"MBrowse - Visualiza outras filiais"														})
aAdd(aPerUsr,{115	,"MBrowse - Edita registros de outras filiais"											})
aAdd(aPerUsr,{116	,"MBrowse - Permite o uso de filtro"														})
aAdd(aPerUsr,{117	,"F3 - Permite o uso de filtro"																})
aAdd(aPerUsr,{118	,"MBrowse - Permite a configuração de colunas"											})
aAdd(aPerUsr,{119	,"Altera Orçamento Aprovado"																})
aAdd(aPerUsr,{120	,"Revisa Orçamento Aprovado"																})
aAdd(aPerUsr,{121	,"Usa impressora no Server"																	})
aAdd(aPerUsr,{122	,"Usa impressora no Client"																	})
aAdd(aPerUsr,{123	,"Agendar Processos/Relatórios"																})
aAdd(aPerUsr,{124	,"Processos identicos na MDI"																})
aAdd(aPerUsr,{125	,"Datas diferentes na MDI"																	})
aAdd(aPerUsr,{126	,"Cad.Cli. no Catalogo E-mail"																})
aAdd(aPerUsr,{127	,"Cad.For. no Catalogo E-mail"																})
aAdd(aPerUsr,{128	,"Cad.Ven. no Catalogo E-mail"																})
aAdd(aPerUsr,{129	,"Impr. informacöes personalizadas"														})
aAdd(aPerUsr,{130	,"Respeita parametro MV_WFMESSE"															})
aAdd(aPerUsr,{131	,"Aprovar/Rejeitar Pre Estrutura"															})
aAdd(aPerUsr,{132	,"Criar Estrutura com base em PrEEstrutura"												})
aAdd(aPerUsr,{133	,"Gerir Etapas"																				})
aAdd(aPerUsr,{134	,"Gerir Despesas"																				})
aAdd(aPerUsr,{135	,"Liberar Despesa para Faturamento"														})
aAdd(aPerUsr,{136	,"Lib. Ped. Venda (credito)"																})
aAdd(aPerUsr,{137	,"Lib. Ped. Venda (estoque)"																})
aAdd(aPerUsr,{138	,"Habilitar opção Executar(Ctrl+R)"														})
aAdd(aPerUsr,{139	,"Permite incluir Ordem de Produção"														})
aAdd(aPerUsr,{140	,"Acesso via ActiveX"																		})
aAdd(aPerUsr,{141	,"Excluir Bens"																				})
aAdd(aPerUsr,{142	,"Rateio do item por cento de custo"														})
aAdd(aPerUsr,{143	,"Alterar o cadastro de clientes"															})
aAdd(aPerUsr,{144	,"Excluir Cadastro de clientes"																})
aAdd(aPerUsr,{145	,"Habilitar Filtros nos relatórios"														})
aAdd(aPerUsr,{146	,"Contatos no Catalogo E-mail"																})
aAdd(aPerUsr,{147	,"Criar formulas nos relatorios"															})
aAdd(aPerUsr,{148	,"Personalizar relatórios"																	})
aAdd(aPerUsr,{149	,"Acesso ao cadastro de lotes"																})
aAdd(aPerUsr,{150	,"Gravar Resposta Parametros por Empresa"													})
aAdd(aPerUsr,{151	,"Manutenção no Repositório de Imagens"													})
aAdd(aPerUsr,{152	,"Criar Relatórios Personalizáveis"														})
aAdd(aPerUsr,{153	,"Permissão para utilizar o TOII"															})
aAdd(aPerUsr,{154	,"Acesso ao SigaRPM"																			})
aAdd(aPerUsr,{155	,"Maiúsculo/Minúsculo na consulta padrão"													})
aAdd(aPerUsr,{156	,"Valida acesso do grupo por Emp/Filial"													})
aAdd(aPerUsr,{157	,"Acessa Base Instalada no Cad. Técnicos"													})
aAdd(aPerUsr,{158	,"Desabilita opção usuários do menu"														})
aAdd(aPerUsr,{159	,"Impressão local p/ componente gráfico"													})
aAdd(aPerUsr,{160	,"Impressão em planilha"																		})
aAdd(aPerUsr,{161	,"Acesso a scripts confidenciais"															})
aAdd(aPerUsr,{162	,"Qualificação de Suspects"																	})
aAdd(aPerUsr,{163	,"Execução de scripts dinâmicos"															})
aAdd(aPerUsr,{164	,"MDI - Permite encerrar ambiente pelo X"													})
aAdd(aPerUsr,{165	,"Permite utilizar o WalkThru"																})
aAdd(aPerUsr,{166	,"Geração de Forecast"																		})
aAdd(aPerUsr,{167	,"Execução de Mashups"																		})
aAdd(aPerUsr,{168	,"Permite Exportar Planilha PMS para Excel"												})
aAdd(aPerUsr,{169	,"Gravar Filtro do Browse com Empresa/Filial"												})
aAdd(aPerUsr,{170	,"Exportar telas para Excel (Mod1 e 3)"													})
aAdd(aPerUsr,{171	,"Se Administrador, pode utilizar o SIGACFG."												})
aAdd(aPerUsr,{172	,"Se Administrador, pode utilizar o APSDU."												})
aAdd(aPerUsr,{173	,"Se acessa APSDU, ERead-Write"															})
aAdd(aPerUsr,{174	,"Acesso a inscrição nos eventos do EventViewer"											})
aAdd(aPerUsr,{175	,"MBrowse - Permite utilizacão do localizador"											})
aAdd(aPerUsr,{176	,"Visualização via F3"																		})
aAdd(aPerUsr,{177	,"Excluir Purchase Order"																	})
aAdd(aPerUsr,{178	,"Alterar Purchase Order"																	})
aAdd(aPerUsr,{179	,"Excluir Solicitação de Importação"														})
aAdd(aPerUsr,{180	,"Alterar Solicitação de importação"														})
aAdd(aPerUsr,{181	,"Excluir Desembaraço"																		})
aAdd(aPerUsr,{182	,"Alterar Desembaraço"																		})
aAdd(aPerUsr,{183	,"Incluir Agenda Médica"																		})
aAdd(aPerUsr,{184	,"Alterar Agenda Médica"																		})
aAdd(aPerUsr,{185	,"Excluir Agenda Médica"																		})
aAdd(aPerUsr,{186	,"Acesso a Fórmulas"																			})
aAdd(aPerUsr,{187	,"Utilizar config. de impressão na TMSPrinter"											})
aAdd(aPerUsr,{188	,"MBrowse - Habilita Impressão"																})
aAdd(aPerUsr,{189	,"Acesso via SmartClient HTML"																})
aAdd(aPerUsr,{190	,"Grava Configuração do Browse por Empresa/Filial"										})
aAdd(aPerUsr,{191	,"Permite efetuar lançamentos manuais através da rotina de Lançamentos Contábeis"	})

Return aPerUsr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUD03NomModºAutor  ³Rafael Rosa da Silvaº Data ³  06/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que retorna o nome do modulo							º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL											º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³O tratamento interno do Protheus eh fixo						º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AUD03NomMod()

Local aNumMod	:= {}

aAdd(aNumMod,{1	,"SIGAATF"		})
aAdd(aNumMod,{2	,"SIGACOM"		})
aAdd(aNumMod,{3	,"SIGACON"		})
aAdd(aNumMod,{4	,"SIGAEST"		})
aAdd(aNumMod,{5	,"SIGAFAT"		})
aAdd(aNumMod,{6	,"SIGAFIN"		})
aAdd(aNumMod,{7	,"SIGAGPE"		})
aAdd(aNumMod,{8	,"SIGAFAS"		})
aAdd(aNumMod,{9	,"SIGAFIS"		})
aAdd(aNumMod,{10	,"SIGAPCP"		})
aAdd(aNumMod,{11	,"SIGAVEI"		})
aAdd(aNumMod,{12	,"SIGALOJA"	})
aAdd(aNumMod,{13	,"SIGATMK"		})
aAdd(aNumMod,{14	,"SIGAOFI"		})
aAdd(aNumMod,{15	,"SIGARPM"		})
aAdd(aNumMod,{16	,"SIGAPON"		})
aAdd(aNumMod,{17	,"SIGAEIC"		})
aAdd(aNumMod,{18	,"SIGATCF"		})
aAdd(aNumMod,{19	,"SIGAMNT"		})
aAdd(aNumMod,{20	,"SIGARSP"		})
aAdd(aNumMod,{21	,"SIGAQIE"		})
aAdd(aNumMod,{22	,"SIGAQMT"		})
aAdd(aNumMod,{23	,"SIGAFRT"		})
aAdd(aNumMod,{24	,"SIGAQDO"		})
aAdd(aNumMod,{25	,"SIGAQIP"		})
aAdd(aNumMod,{26	,"SIGATRM"		})
aAdd(aNumMod,{27	,"SIGAEIF"		})
aAdd(aNumMod,{28	,"SIGATEC"		})
aAdd(aNumMod,{29	,"SIGAEEC"		})
aAdd(aNumMod,{30	,"SIGAEFF"		})
aAdd(aNumMod,{31	,"SIGAECO"		})
aAdd(aNumMod,{32	,"SIGAAFV"		})
aAdd(aNumMod,{33	,"SIGAPLS"		})
aAdd(aNumMod,{34	,"SIGACTB"		})
aAdd(aNumMod,{35	,"SIGAMDT"		})
aAdd(aNumMod,{36	,"SIGAQNC"		})
aAdd(aNumMod,{37	,"SIGAQAD"		})
aAdd(aNumMod,{38	,"SIGAQCP"		})
aAdd(aNumMod,{39	,"SIGAOMS"		})
aAdd(aNumMod,{40	,"SIGACSA"		})
aAdd(aNumMod,{41	,"SIGAPEC"		})
aAdd(aNumMod,{42	,"SIGAWMS"		})
aAdd(aNumMod,{43	,"SIGATMS"		})
aAdd(aNumMod,{44	,"SIGAPMS"		})
aAdd(aNumMod,{45	,"SIGACDA"		})
aAdd(aNumMod,{46	,"SIGAACD"		})
aAdd(aNumMod,{47	,"SIGAPPAP"	})
aAdd(aNumMod,{48	,"SIGAREP"		})
aAdd(aNumMod,{49	,"SIGAGE"		})
aAdd(aNumMod,{50	,"SIGAEDC"		})
aAdd(aNumMod,{51	,"SIGAHSP"		})
aAdd(aNumMod,{52	,"SIGAVDOC"	})
aAdd(aNumMod,{53	,"SIGAAPD"		})
aAdd(aNumMod,{54	,"SIGAGSP"		})
aAdd(aNumMod,{55	,"SIGACRD"		})
aAdd(aNumMod,{56	,"SIGASGA"		})
aAdd(aNumMod,{57	,"SIGAPCO"		})
aAdd(aNumMod,{58	,"SIGAGPR"		})
aAdd(aNumMod,{59	,"SIGAGAC"		})
aAdd(aNumMod,{60	,"SIGAPRA"		})
aAdd(aNumMod,{61	,"SIGAHGP"		})
aAdd(aNumMod,{62	,"SIGAHHG"		})
aAdd(aNumMod,{63	,"SIGAHPL"		})
aAdd(aNumMod,{64	,"SIGAAPT"		})
aAdd(aNumMod,{65	,"SIGAGAV"		})
aAdd(aNumMod,{66	,"SIGAICE"		})
aAdd(aNumMod,{67	,"SIGAAGR"		})
aAdd(aNumMod,{68	,"SIGAARM"		})
aAdd(aNumMod,{69	,"SIGAGCT"		})
aAdd(aNumMod,{70	,"SIGAORG"		})
aAdd(aNumMod,{71	,"SIGALVE"		})
aAdd(aNumMod,{72	,"SIGAPHOTO"	})
aAdd(aNumMod,{73	,"SIGACRM"		})
aAdd(aNumMod,{74	,"SIGABPM"		})
aAdd(aNumMod,{75	,"SIGAAPON"	})
aAdd(aNumMod,{76	,"SIGAJURI"	})
aAdd(aNumMod,{77	,"SIGAPFS"		})
aAdd(aNumMod,{78	,"SIGAGFE"		})
aAdd(aNumMod,{79	,"SIGASFC"		})
aAdd(aNumMod,{80	,"SIGAACV"		})
aAdd(aNumMod,{81	,"SIGALOG"		})
aAdd(aNumMod,{82	,"SIGADPR"		})
aAdd(aNumMod,{83	,"SIGAVPON"	})
aAdd(aNumMod,{84	,"SIGATAF"		})
aAdd(aNumMod,{85	,"SIGAESS"		})
aAdd(aNumMod,{86	,"SIGAVDF"		})
aAdd(aNumMod,{87	,"SIGAGCP"		})
aAdd(aNumMod,{88	,"SIGAGTP"		})
aAdd(aNumMod,{97	,"SIGAESP"		})
aAdd(aNumMod,{98	,"SIGAESP1"	})
aAdd(aNumMod,{96	,"SIGAESP2"	})
aAdd(aNumMod,{99	,"SIGACFG"		})

Return aNumMod