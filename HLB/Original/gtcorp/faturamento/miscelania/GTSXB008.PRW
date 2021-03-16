#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"         

/*
Funcao      : GTSXB008
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para apresentar uma consulta específica com todos os projetos da empresa(e filial) atual cadastrados no MIS, parecido com a consulta padrão
			: Ou fazer a validação do campo verificando se o projeto existe.
			: 
Autor       : Weden Alves
Revisão		:
Data/Hora   : 10/01/2017    08:36
Módulo      : Genérico
*/
     
*----------------------------*
User function GTSXB008(cTipo)
*----------------------------*
Local oLayer 	:= FWLayer():new()
Local aOrdem	:= {"PROJETO","CLIENTE","SOCIO"}
Local cSeek 	:= Space(30)
Local cAlias	:= "DADTRB"                             
Local oBrowse

Local cFilter		:= ""
Local __cExpAFilter	:= ""
Local aRetFil		:= {"","",0}
Local lRet			:= .T.
Local oFilPanel2

Private aHeader	:={} 
Private oDlg,oOrdem,cOrd,oPesq,oSeek    

//Query que retorna a consulta realizada no MIS
Private cQry :="select IdProjeto, NmProjeto,NmCliente, tbCSocios.NmColaborador "+CRLF
		cQry +="as NmSocio, tbLinhasNegocio.NmLinhaNegocio, tbEmpresas.CdEmpresa, tbEmpresas.LjEmpresa "+CRLF
	    cQry +="from dbMIS..tbProjetos "+CRLF
		cQry +="left join dbMIS..tbClientes on tbClientes.IdCliente = tbProjetos.IdCliente "+CRLF
		cQry +="left join dbMIS..tbUsuarios tbUSocios on tbUSocios.IdUsuario = tbProjetos.IdSocio "+CRLF
		cQry +="left join dbMIS..tbColaboradores tbCSocios on tbCSocios.IdColaborador = tbUSocios.IdColaborador "+CRLF
		cQry +="left join dbMIS..tbLinhasNegocio on tbLinhasNegocio.IdLinhaNegocio = tbProjetos.IdLinhaNegocio "+CRLF
		cQry +="left join dbMIS..tbEmpresas on tbEmpresas.IdEmpresa = tbProjetos.IdEmpresa	where tbProjetos.IdTipoProjeto = 2 "+CRLF
		cQry +="and tbEmpresas.CdEmpresa = '"+cEmpAnt+"' and tbEmpresas.LjEmpresa = "+cFilAnt+CRLF                  

if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif
		
DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "DADTRB", .F., .F. )		
	
		                                                                                                            
if cTipo == "SXB"                                                                                                   
    
	DEFINE MSDIALOG oDlg TITLE "Pesquisa" FROM C(187),C(341) TO C(574),C(894) PIXEL
	
	
		@00,00 MSPANEL oTopPanel SIZE 250,43
		oTopPanel:Align := CONTROL_ALIGN_TOP
		
		@00,00 MSPANEL oMainPanel SIZE 250,39
		oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT
		
		@00,00 MSPANEL oBtnPanel1 SIZE 250,15                                        
		oBtnPanel1:Align := CONTROL_ALIGN_BOTTOM
		
		@00,00 MSPANEL oFilPanel PROMPT "" SIZE 18,11 OF oMainPanel
		oFilPanel:Align := CONTROL_ALIGN_BOTTOM 
		
		@00,00 MSPANEL oBtnPanel2 SIZE 250,15 OF oBtnPanel1
		oBtnPanel2:Align := CONTROL_ALIGN_ALLCLIENT
		
		//<Pesquisa>
		@03,03 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 270,36 PIXEL OF oTopPanel ;
		ON CHANGE ( DADTRB->(DbSetOrder( aScan( aOrdem, { |x| UPPER(alltrim(cOrd)) $  UPPER(x) } ) )) ,oBrowse:Refresh(.T.) )
		
			@03,275 BUTTON oPesq PROMPT "Pesquisar" SIZE 40,11 PIXEL OF oTopPanel ;
			ACTION (IIF( (!Empty(oSeek:cText) .AND. !Empty(cOrd) ) ,Busca(cOrd,cSeek,aOrdem,oBrowse),))
			
			@17,03 MSGET oSeek VAR cSeek SIZE 270,10 PIXEL OF oTopPanel
			
	        //<Fim pesquisa>
			
			Tabtemp(@aHeader)
			//Browse com as informações
			Brow(oMainPanel,@oBrowse)
			
			//<Botões>
			
			//Ok
			DEFINE SBUTTON oBtn1 FROM 02,02 TYPE 1 ENABLE OF oBtnPanel2 ONSTOP "Ok - <Ctrl-O>" ;
			ACTION (lRet:=.T.,oDlg:End()) // DEFAULT
			oBtn1:lAutDisable := .f.
	        
			//Cancelar
			DEFINE SBUTTON oBtn2 FROM 02,32 TYPE 2 ENABLE OF oBtnPanel2 ONSTOP "Cancelar - <Ctrl-X>" ;
			ACTION (lRet:=.F.,oDlg:End())
			  
			
	        //Filtro
		   	@00,00 GET oFilter VAR cFilter PIXEL SIZE 18,18 COLOR CLR_RED READONLY OF oFilPanel
		   	oFilter:Align := CONTROL_ALIGN_ALLCLIENT
			
			
			DEFINE SBUTTON oBtn6 FROM 02,62 TYPE 17 ENABLE OF oBtnPanel2 ;
			ACTION( FiltraTRB(Filtra(cAlias,@__cExpAFilter,@cFilter,@oFilPanel2),oBrowse,oMainPanel) )
	      
			//<Fim Botões>
			
	ACTIVATE MSDIALOG oDlg CENTERED       
	
elseif cTipo=="SC5"
	if SC5->(FieldPos("C5_P_MIS"))>0
		cQry+="and IdProjeto ='"+alltrim(M->C5_P_MIS)+"'"
		
		if select("DADTRB")>0                                
			DADTRB->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "DADTRB", .F., .F. )
	
		Count to nRecCount
		
		if nRecCount <= 0
			Alert("Esse código não existe no cadastro de projetos!")
			lRet:=.F.
		endif
	endif
endif
	
Return(lRet)                                                

/*
Funcao      : C
Parametros  : nTam
Retorno     : 
Objetivos   : Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario
Autor       : Weden Alves
Data/Hora   : 
*/

*----------------------*
Static Function C(nTam)                                                         
*----------------------*
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                    

/*
Funcao      : Brow()
Parametros  : oWinCC,oBrowse
Retorno     : 
Objetivos   : Função que cria o browse de apresentação dos dados
Autor       : Weden Alves
Data/Hora   : 
*/

*--------------------------------------*
Static function Brow(oWinCC,oBrowse)
*--------------------------------------*
Local oTBtnBmp1,oTBar

// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB" OF oWinCC			

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || NUM		} TITLE "Cod. Projeto" 		DOUBLECLICK  {||  }	ALIGN 1 SIZE 7   OF oBrowse		
ADD COLUMN oColumn DATA { || PROJETO   	} TITLE "Nome Projeto"		DOUBLECLICK  {||  }	ALIGN 1 SIZE 80	 OF oBrowse		
ADD COLUMN oColumn DATA { || CLIENTE    } TITLE "Cliente"			DOUBLECLICK  {||  }	ALIGN 1 SIZE 120 OF oBrowse	
ADD COLUMN oColumn DATA { || SOCIO		} TITLE "Socio"   			DOUBLECLICK  {||  }	ALIGN 1 SIZE 80  OF oBrowse
ADD COLUMN oColumn DATA { || NEGOCIO	} TITLE "Negocio"  			DOUBLECLICK  {||  }	ALIGN 1 SIZE 40	 OF oBrowse

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse


Return(.T.)                                            

/*
Funcao      : Tabtemp()
Parametros  : aHeader
Retorno     : 
Objetivos   : Função que cria a tabela temporária
Autor       : Weden Alves
Data/Hora   : 
*/

*------------------------------*
Static function Tabtemp(aHeader)
*------------------------------*
Local aDadTemp	:= {}
Local cMensErro	:= ""
//Local aAllGroup	:= FWAllGrpCompany() //Empresas

AADD(aDadTemp,{"NUM"		,"C",7		,0})
AADD(aDadTemp,{"PROJETO"	,"C",80 	,0})
AADD(aDadTemp,{"CLIENTE"	,"C",120	,0})
AADD(aDadTemp,{"SOCIO"		,"C",120 	,0})
AADD(aDadTemp,{"NEGOCIO"	,"C",60		,0})
    
	//Preencho o array para o filtro
	For nHed:=1 to len(aDadTemp)
		if aDadTemp[nHed][1] $ "NUM"
			AADD(aHeader,{ "Cod. Projeto",;
						 aDadTemp[nHed][1],;
						 "",;
						 aDadTemp[nHed][3],;
	 					 aDadTemp[nHed][4],;
	 					 "ALLWAYSFALSE()",;                           
	 					 "€€€€€€€€€€€€€€ ",;
	 					 aDadTemp[nHed][2],;
	 					 "",;
	 					 "V",;
	 					 "",;
	 					 "",;
	 					 "",;
	 					 "V" } )
	 					 
		elseif aDadTemp[nHed][1] $ "PROJETO"
			AADD(aHeader,{ "Nome Projeto",;
						 aDadTemp[nHed][1],;
						 "",;
						 aDadTemp[nHed][3],;
	 					 aDadTemp[nHed][4],;
	 					 "ALLWAYSFALSE()",;
	 					 "€€€€€€€€€€€€€€ ",;
	 					 aDadTemp[nHed][2],;
	 					 "",;
	 					 "V",;
	 					 "",;
	 					 "",;
	 					 "",;
	 					 "V" } )
	 					  
		elseif aDadTemp[nHed][1] $ "CLIENTE"
			AADD(aHeader,{ "Cliente",;
						 aDadTemp[nHed][1],;
						 "",;
						 aDadTemp[nHed][3],;
	 					 aDadTemp[nHed][4],;
	 					 "ALLWAYSFALSE()",;
	 					 "€€€€€€€€€€€€€€ ",;
	 					 aDadTemp[nHed][2],;
	 					 "",;
	 					 "V",;
	 					 "",;
	 					 "",;
	 					 "",;
	 					 "V" } )
		elseif aDadTemp[nHed][1] $ "SOCIO"
			AADD(aHeader,{ "Socio",;
						 aDadTemp[nHed][1],;
						 "",;
						 aDadTemp[nHed][3],;
	 					 aDadTemp[nHed][4],;
	 					 "ALLWAYSFALSE()",;
	 					 "€€€€€€€€€€€€€€ ",;
	 					 aDadTemp[nHed][2],;
	 					 "",;
	 					 "V",;
	 					 "",;
	 					 "",;
	 					 "",;
	 					 "V" } )
		elseif aDadTemp[nHed][1] $ "NEGOCIO"
			AADD(aHeader,{ "Negocio",;
						 aDadTemp[nHed][1],;
						 "",;
						 aDadTemp[nHed][3],;
	 					 aDadTemp[nHed][4],;
	 					 "ALLWAYSFALSE()",;
	 					 "€€€€€€€€€€€€€€ ",;
	 					 aDadTemp[nHed][2],;
	 					 "",;
	 					 "V",;
	 					 "",;
	 					 "",;
	 					 "",;
	 					 "V" } )
		endif
	Next

if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
cIndex2	:=CriaTrab(Nil,.F.)
cIndex3	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB",cIndex,"SOCIO",,,"Selecionando Registro...")  
IndRegua("DADTRB",cIndex2,"CLIENTE",,,"Selecionando Registro...")  
IndRegua("DADTRB",cIndex3,"NUM",,,"Selecionando Registro...")  

DbSelectArea("DADTRB")
DADTRB->(DbSetIndex(cIndex2+OrdBagExt()))
DADTRB->(DbSetIndex(cIndex+OrdBagExt()))
DADTRB->(DbSetOrder(1))

//Testando se a query tem problemas
if tcsqlexec(cQry)<0
	cError		:= TCSQLError()
	cMensErro	+= "Empresa: "+cEmpAnt+": "+alltrim(cError)+CRLF+"----------------------------"+CRLF
	return
endif
       
//Se a query não foi carregada
if empty(cQry)
	return
endif

if select("QRYTEMP")>0
	QRYTEMP->(DbCloseArea())
endif
	
DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
Count to nRecCount
		
	if nRecCount > 0
			
		QRYTEMP->(DbGoTop())
			
		While QRYTEMP->(!EOF())
			Reclock("DADTRB",.T.)
					
				DADTRB->NUM			:= ALLTRIM(STR(QRYTEMP->IdProjeto))
				DADTRB->PROJETO		:= QRYTEMP->NmProjeto
				DADTRB->CLIENTE		:= QRYTEMP->NmCliente
				DADTRB->SOCIO   	:= QRYTEMP->NmSocio
				DADTRB->NEGOCIO		:= QRYTEMP->NmLinhaNegocio
			DADTRB->(MsUnlock())                                                 
			QRYTEMP->(DbSkip())
		Enddo
			
	endif
		
Return

/*
Funcao      : Busca()
Parametros  : 
Retorno     : 
Objetivos   : Função que efetua a busca de acordo com a oredm
Autor       : Weden Alves
Data/Hora   : 
*/

*-----------------------------------------------*
Static Function Busca(cOrd,cSeek,aOrdem,oBrowse)
*-----------------------------------------------*
Local nGo		:= 0
Local nTamBusca	:= len(alltrim(cOrd))
Local cRecno	:= DADTRB->(RECNO())

//Verifico qual o indice a ser buscado
nGo:= aScan( aOrdem, { |x|   UPPER(alltrim(cOrd)) $  UPPER(x) } )

DADTRB->(DbSetOrder(nGo))
if !DADTRB->(DbSeek(alltrim(cSeek)))
	DADTRB->(DbGoTo(cRecno))
endif

//GoTo(< nGoto>,[ lRefresh] )
oBrowse:GoTo(DADTRB->(RECNO()),.T.)

oBrowse:Refresh()

Return()

/*
Funcao      : WaitAxVi()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Weden Alves
Data/Hora   : 
*/
*-------------------------------------------------*
Static Function WaitAxVi(cAlias,nReg,cEmp,cNomeEmp)
*-------------------------------------------------*
Local oDlg2
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

//******************Régua de processamento*******************
                                          //retira o botão X
  DEFINE DIALOG oDlg2 TITLE "Abrindo..." STYLE DS_MODALFRAME FROM 10,10 TO 50,160 PIXEL
	                                          
    // Montagem da régua
    nMeter := 0
    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg2,70,34,,.T.,,,,,,,,,)
	    
  ACTIVATE DIALOG oDlg2 CENTERED ON INIT(lRet:=Visual(cAlias,nReg,cEmp,cNomeEmp,oMeter,oDlg2))
	  
//*************************************

Return(lRet)                               

/*
Funcao      : Visual()
Parametros  : cAlias,nReg,cEmp,cNomeEmp,oMeter,oDlg2
Retorno     : 
Objetivos   : Função para visualizar o resgistro posicionado
Autor       : Weden Alves
Data/Hora   : 
*/

*------------------------------------------------------------*
Static Function Visual(cAlias,nReg,cEmp,cNomeEmp,oMeter,oDlg2)
*------------------------------------------------------------*
Local nOpc		:= 2
Local lMaximized:= .T.
Local aArea 	:= GetArea() 
Local cModo //Modo de acesso do arquivo aberto "E" ou "C" 
Local cArqInd	:= ""

Private	cCadastro:= cNomeEmp //Variavel q é responsável pelo título da dialog do AXVISUAL
Private aCposExib:= {}	//Array para armazenar os campos que serão apresentados

//Inicia a régua
oMeter:Set(0)

if select("SX3TMP")>0
	SX3TMP->(DbCloseArea())
endif
//Abro o SX3(em um alias temporário) da empresa no qual desejo visualizar o cadastro
DbUseArea(.T., "DBFCDX", "\"+CURDIR()+"SX3"+cEmp+"0.DBF", "SX3TMP", .T., .F.)

DbSelectArea("SX3TMP")
cArqInd := CriaTrab(Nil,.F.)
IndRegua("SX3TMP",cArqInd,"X3_CAMPO",,"","",.F.)

SX3TMP->(DbSetOrder(1))

//tratamento para os campos que devem aparecer
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))

//Buscar os campos do X3 tirando os campos customizados, para n dar erro de invalid fild name in alias
While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO==cAlias
	
    //Processamento da régua
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent+=5 	// atualiza régua
	oMeter:Set(nCurrent) //seta o valor na régua

	if alltrim(SX3->X3_PROPRI) <> "U" //tiro os campos de usuário
	
		if SX3TMP->(DbSeek(SX3->X3_CAMPO)) //Verifico se o campo existe na empresa na qual abrirei o registro
			AADD(aCposExib,SX3->X3_CAMPO)
	    endif
	endif
	
	SX3->(DbSkip())
Enddo

AADD(aCposExib,"NOUSER")

//Abro a tabela da outra empresa
if EmpOpenFile(cAlias,cAlias,nOpc,.T.,cEmp,@cModo) 
	&(cAlias)->(DbGoTo(nReg))
	AXVISUAL(cAlias, nReg, nOpc, aCposExib, , , , , lMaximized )
	&(cAlias)->( dbCloseArea() ) 
endif 

oDlg2:end()

ChkFile(cAlias)

RestArea(aArea)
Return


Static Function RetTopFilter(cAlias,__cSvTopFilter,cFilter,lRealExpFil,oBtnFilter,oFilter)
lRealExpFil := !lRealExpFil

If lRealExpFil
	cFilter := "FILTRO: "+__cSvTopFilter
	oBtnFilter:cToolTip := "Expressão Literal..."
Else
	cFilter := "FILTRO: "
	If !Empty(__cSvTopFilter)
		cFilter += MontDescr(cAlias,__cSvTopFilter, .T.)
	Endif
	oBtnFilter:cToolTip := "Expressão Real..."
EndIf

If Empty(__cSvTopFilter)
	cFilter := "SEM FILTRO"
EndIf

If oFilter <> Nil
	oFilter:Refresh()
EndIf

Return                  

/*
Funcao      : Filtra()
Parametros  : cAl,cExpFil,cTxtFil
Retorno     : 
Objetivos   : Apresenta a tela de filtro, parecido com BuildExpr() Criado pela necessidade de se trabalhar com o Arq. TMP
            : Função baseada na padrão do fonte: CTBA105 - função CTB105FlTl
Autor       : Weden Alves
Data/Hora   : 10/01/2017
*/

*------------------------------------------*
Static Function Filtra(cAl,cExpFil,cTxtFil)
*------------------------------------------*
Local oDlgPesq
Local oBtna , oBtn  , oBtnOp, oBtne, oBtnOu
Local oMatch, oCampo, oOper , oExpr, oTxtFil
Local aCpos		:= {}
Local aCampo	:= {}
Local aStrOp	:= {}
Local aStru		:= {}
Local cTitulo	:= ""
Local cCampo	:= ""
Local cExpr		:= ""
Local cOper		:= ""
Local nMatch 	:= 0
Local nA		:= 0
Local nOpc		:= 4

Private cAlias2	:= ""
Private cAlias	:= ""

Default cTxtFil := ""
Default cExpFil := ""
Default cAl		:= "TMP"
		cAlias	:= cAl
		cAlias2 := cAlias + "->"  
		
		
		cAntExp:=cExpFil
		cAntTxt:=cTxtFil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos do Localizador ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nA := 1 to Len(aHeader)
	AADD( aCpos , aHeader[nA][1] )
	AADD( aCampo,{aHeader[nA][2],aHeader[nA][1],.T.,"01",aHeader[nA][4],If(Empty(aHeader[nA][3]),Space(45),aHeader[nA][3]),aHeader[nA][8],aHeader[nA][5]})
Next nA

cTitulo := "Localizar"

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(cTitulo) FROM 000,000 TO 250,405 PIXEL

	aStrOp := { "Igual a","Diferente de","Menor que","Menor ou igual a","Maior que","Maior ou igual a","Contém a expresão","Não contém","Está contido em","Não está contido em"}	 
	//"Igual a"###"Diferente de"###"Menor que"###"Menor ou igual a"###"Maior que"###"Maior ou igual a"###"Cont‚m a express„o"###"N„o cont‚m"###"Est  contido em"###"N„o est  contido em"

	@ 05,005 SAY "Campo:" 		SIZE 20,8 PIXEL OF oDlgPesq //"Campo:"
	@ 05,060 SAY "Operador:" 	SIZE 30,8 PIXEL OF oDlgPesq //"Operador:"
	@ 05,115 SAY "Expressão:" 	SIZE 30,8 PIXEL OF oDlgPesq //"Express„o:"
	@ 50,005 SAY "Filtro:" 		SIZE 20,8 PIXEL OF oDlgPesq //"Filtro:"
	
	@ 35,005 BUTTON oBtna PROMPT "&Adiciona" SIZE 35,10 OF oDlgPesq PIXEL ; //"&Adiciona"
		ACTION (cTxtFil := BuildTxt(cTxtFil,Trim(cCampo),cOper,alltrim(cExpr),.t.,@cExpFil,aCampo,oCampo:nAt,oOper:nAt),cExpr := CalcField(oCampo:nAt,aCampo),BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq),oTxtFil:Refresh(),oBtne:Enable(),oBtnOp:Disable(),oBtnOu:Enable(),oBtna:Disable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh()) ;
		FONT oDlgPesq:oFont
	
	@ 35,45 BUTTON oBtn PROMPT "&Limpa Filtro" SIZE 35,10 OF oDlgPesq PIXEL ; //"&Limpa Filtro"
		ACTION (cTxtFil := "",cExpFil := "",nMatch := 0,oTxtFil:Refresh(),oBtnA:Enable(),oBtnE:Disable(),oBtnOu:Disable(),oMatch:Disable(),oBtnOp:Enable()) ;
		FONT oDlgPesq:oFont
	
	@ 30,175 BUTTON oBtnOp PROMPT OemToAnsi("(") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont ;
		ACTION (If(nMatch==0,oMatch:Enable(),nil),nMatch++,cTxtFil+= " ( ",cExpFil+="(",oTxtFil:Refresh()) ;
	
	@ 30,190 BUTTON oMatch PROMPT OemToAnsi(")") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont;
		ACTION (nMatch--,cTxtFil+= " ) ",cExpFil+=")",If(nMatch==0,oMatch:Disable(),nil),oTxtFil:Refresh()) ;
	
	@ 45,175 BUTTON oBtne PROMPT " E " SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" E "
		ACTION (cTxtFil+=" e ",cExpFil += ".and.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) ; //" e "
	
	@ 45,190 BUTTON oBtnOu PROMPT " OU " SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" OU "
		ACTION (cTxtFil+=" ou ",cExpFil += ".or.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) //" ou "
	oMatch:Disable()
	
	cCampo := aCpos[1]
	@ 15,05 COMBOBOX oCampo VAR cCampo ITEMS aCpos SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	cExpr := CalcField(oCampo:nAt,aCampo)
	cOper := aStrOp[1]
	
	@ 15,60 COMBOBOX oOper VAR cOper ITEMS aStrOp SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	
`	@ 15,115 MSGET oExpr VAR cExpr SIZE 85,10 PIXEL OF oDlgPesq PICTURE AllTrim(aCampo[oCampo:nAt,6]) FONT oDlgPesq:oFont
	
	@ 60,05 GET oTxtFil VAR cTxtFil MEMO SIZE 195,40 PIXEL OF oDlgPesq READONLY
	oTxtFil:bRClicked := {||AlwaysTrue()}
	
	If Empty(cExpFil) .And. Empty(cTxtFil)
		oBtne:Disable()
		oBtnou:Disable() 
	Else
		oBtna:Disable()
		oBtnOp:Disable()
		oMatch:Disable()
	Endif
	
	DEFINE SBUTTON o1 FROM 113,115  TYPE 20  ACTION (nOpc:=2,cExpFil:=cAntExp,cAntTxt:=cTxtFil,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o2 FROM 113,145  TYPE 01  ACTION (nOpc:=3,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o3 FROM 113,175  TYPE 02  ACTION (nOpc:=4,cExpFil:=cAntExp,cAntTxt:=cTxtFil,oDlgPesq:End()) OF oDlgPesq When .T.
	
	o1:cToolTip := "Localizar Anterior" //"Localizar Anterior"
	o2:cToolTip := "Localizar Proximo" //"Localizar Proximo"

ACTIVATE MSDIALOG oDlgPesq CENTERED
                                                                       
Return {"'"+cExpFil+"'",cTxtFil,nOpc }

/*
Funcao      : CalcField()
Parametros  : nAt,aCampo
Retorno     : 
Objetivos   : De acordo com o tipo do campo, é retornado o formato
            : Função baseada na padrão do fonte: CTBA105 - função CTB105FlTl
Autor       : Weden Alves
Data/Hora   : 10/01/2017
*/

*--------------------------------------*
Static Function CalcField(nAt,aCampo)
*--------------------------------------*
Local cRet

If aCampo[nAt,7] == "C"
	cRet := Space(aCampo[nAt,5])
ElseIf aCampo[nAt,7] == "N"
	cRet := 0
ElseIf aCampo[nAt,7] == "D"
	cRet := CTOD("  /  /  ")
EndIf

Return cRet

/*
Funcao      : BuildTxt()
Parametros  : cTxtFil,cCampo,cOper,xExpr,lAnd,cExpFil,aCampo,nCpo,nOper
Retorno     : 
Objetivos   : Controi a expressão de filtro
            : Função baseada na padrão do fonte: CTBA105 - função CTB105FlTl
Autor       : Weden Alves
Data/Hora   : 10/01/2017
*/

*----------------------------------------------------------------------------------*
Static Function BuildTxt(cTxtFil,cCampo,cOper,xExpr,lAnd,cExpFil,aCampo,nCpo,nOper)
*----------------------------------------------------------------------------------*
Local cChar := OemToAnsi(CHR(39))
Local cType := ValType(xExpr)
Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}

cTxtFil += cCampo+" "+cOper+" "+If(cType=="C",cChar,"")+cValToChar(xExpr)+If(cType=="C",cChar,"")

If cType == "C"

	If aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ AllTrim('+aCampo[nCpo,1]+'))'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!(AllTrim('+aCampo[nCpo,1]+") $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ AllTrim("+aCampo[nCpo,1] +" )"   // Inverte Posicoes

	Else

			If (aOper[nOper]=="==")
				cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
				cExpFil += '"'+cValToChar(xExpr)+'"'
			Else
				cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
				cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
			EndIf

	EndIf
ElseIf cType == "D"
	// Nao Mexer, deixar dToS pois e'a FLAG Para Limpeza do Filtro
	// 						 
	cExpFil += "dToS("+aCampo[nCpo,1]+") "+aOper[nOper]+' "'
	cExpFil += Dtos(CTOD(cValToChar(xExpr)))+'"'
Else
	cExpFil += aCampo[nCpo,1]+" "+aOper[nOper]+" "
	cExpFil += cValToChar(xExpr)
EndIf

Return cTxtFil

/*
Funcao      : ValidText()
Parametros  : cExp,cTxt
Retorno     : 
Objetivos   : Ajusta experessao de busca para que nao gere error.log de Invalid Macro por inconsistencia.
            : Função baseada na padrão do fonte: CTBA105 - função CTB105FlTl
Autor       : Weden Alves
Data/Hora   : 10/01/2017
*/

*-----------------------------------*
Static Function ValidText(cExp,cTxt)
*-----------------------------------*
Local lValid := .F.	

Default cExp := ""
Default cTxt := ""

If !Empty(cExp) .And. !Empty(cTxt)
	While !lValid
		Do Case
			Case Right(cTxt,2) == "( "  
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,2) == "E "
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,3) == "OU "
				cTxt := Left( cTxt, Len(cTxt)-4 )
			Case Right(cExp,1) == "("
				cExp := Left( cExp, Len(cExp)-1 )
			Case Right(cExp,5) == ".and."	
				cExp := Left( cExp, Len(cExp)-5 )
			Case Right(cExp,4) == ".or."	
				cExp := Left( cExp, Len(cExp)-4 )
			Otherwise
				lValid := .T.
		End Case
	EndDo
Endif

Return

/*
Funcao      : FiltraTRB()
Parametros  : 
Retorno     : 
Objetivos   : Função para executar o filtro no alias temporário
Autor       : Weden Alves
Data/Hora   : 10/01/2017
*/
*----------------------------------------------------*
Static Function FiltraTRB(aRetFil,oBrowse,oMainPanel)
*----------------------------------------------------*

if aRetFil[3]==3
	    
	bCondicao := {|| &(&(aRetFil[1]))}
	cCondicao := &(aRetFil[1])
		
	if !empty(cCondicao)
		DbSelectArea("DADTRB")
		DADTRB->(DbSetFilter(bCondicao,cCondicao))
	else
		DbSelectArea("DADTRB")
		DADTRB->(DBCLEARFILTER())
	endif
		
	oBrowse:Refresh(.T.)	
endif

Return
