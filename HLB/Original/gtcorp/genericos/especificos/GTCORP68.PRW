#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"

/*
Funcao      : GTCORP68
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para buscar informações sobre cadastros de clientes/prospect/transportadora/fornecedor
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 16/05/2013    10:28
Módulo      : Genérico
*/

*---------------------*
User function GTCORP68
*---------------------*
                  //Cliente,Fornecedor,Vendedor,Transportadora,Prospect
Local aAllTab	:= {"SA1","SA2","SA3","SA4","SUS"} //Tabelas para busca de informações, só preencher aqui para poder ser utilizado
Local nLinha	:= 15	//linha inicial para apresentação do checkbox
Local nCol		:= 03	//Coluna inicial para apresentação do checkbox
Local aAllGroup	:= FWAllGrpCompany() //Empresas

Local oBrowse

Local lMacTd	:= .F.
Local oMacTd

Local aSize     := {}
Local aObjects	:= {}

Local nHRes		:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor 

Private oDlg

if nHRes>1311 //Resolução do notebook de 14 polegadas
	nDif:=130
else
	nDif:=100
endif

Private oTButton2

// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()

AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 100, 70, .T., .T. } )    

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

                             
    //DEFINE DIALOG oDlg TITLE "Procurar cadastro" FROM 180,180 TO 550,700 PIXEL
    DEFINE DIALOG oDlg TITLE "Procurar cadastro" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL
        
		// Cria o Groupo 
		@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] LABEL "Parâmetros:" PIXEL OF oDlg


		
		//<------> Scroll do lado DIREITO - CIMA
   		oScr1 := TScrollBox():New(oDlg,aPosObj[1][1]+8,((aPosObj[1][4])/2)+6,aPosObj[1][3]-16,(aPosObj[1][4]-(aPosObj[1][4]/2))  -12,.T.,.T.,.T.)
	
		// Cria painel 
		@ 000,000 MSPANEL oPanel OF oScr1 SIZE (aPosObj[1][4]-(aPosObj[1][4]/2))-15,len(aAllTab)*10 COLOR CLR_HRED

		// Cria o Groupo 
		@ 01,01 TO 12,(aPosObj[1][4]-(aPosObj[1][4]/2))-15 LABEL "" PIXEL OF oPanel

		@ 03,03 CHECKBOX oMacTd VAR lMacTd PROMPT "Marca todos" SIZE 50, 10	OF oPanel PIXEL;
		ON CLICK(MarcTodo(aAllTab,lMacTd))
		
		oFont:= TFont():New('Arial',,-14,,.f.)
		oSay := TSay():New( 03, 120, {|| 'Buscar no(s) cadastro(s):'},oPanel,, oFont,,,, .T.)
		
			for i:=1 to len(aAllTab)
			
				cVar:="lCheck"+aAllTab[i]
				cObj:="oCheck"+aAllTab[i]
			    
			    //Posiciono na tabela no qual preciso do nome
			 	DbSelectArea("SX2")
			    SX2->(DbSetOrder(1))
			    SX2->(DbSeek(aAllTab[i]))
			    
				&(cVar)	:= .F.                         //Nome da tabela
				&(cObj)	:= TCheckBox():New(nLinha,nCol,Alltrim(SX2->X2_NOME),,oPanel,100,210,,,,,,,,.T.,,,)
		
				// Seta Eventos do Check
				&(cObj):bSetGet := &("{|| "+&("cVar")+"}")
				&(cObj):bLClicked := &("{|| "+&("cVar")+":= !"+&("cVar")+"}")
				nLinha+=10
                
				//tratamento para dividir as empresas em 2 colunas
				if i == INT(len(aAllTab)/2)
					nLinha	:=15
					nCol	:=150
				endif

	        next

		//<------> FIM Scroll do lado DIREITO - CIMA
        
		//<------> Scroll do lado ESQUERDO - CIMA
		
   		oScr2 := TScrollBox():New(oDlg,aPosObj[1][1]+8,((aPosObj[1][2]))+6,aPosObj[1][3]-16,(aPosObj[1][4]-(aPosObj[1][4]/2))  -12,.T.,.T.,.T.)

		// Cria o Groupo 
		@ 01,01 TO 12,(aPosObj[1][4]-(aPosObj[1][4]/2))-15 LABEL "" PIXEL OF oScr2
		
		oFont1:= TFont():New('Arial',,-14,,.f.)
		oFont2:= TFont():New('Constantia',,-14,,.F.)
		
		oSay1 := TSay():New( 03, 140, {|| 'Informações:'},oScr2,, oFont,,,, .T.)

		@ 17,05 SAY "CPF/CNPJ: " SIZE 100,10 OF oScr2 PIXEL
		@ 30,05 SAY "Descrição: " SIZE 100,10 OF oScr2 PIXEL
		
		cGet1	:= space(14)
		cGet2	:= space(100)
		aItems	:= {'Empresa atual','Todas as empresas'}
		cCombo	:= aItems[1]
		
		oGet1:= TGet():New(16,35,{|u| if(PCount()>0,cGet1:=u,cGet1)}, oScr2,80,05,'99999999999999',{|o|},,,,,,.T.,,,,,,,,,,'cGet1')				
		oGet2:= TGet():New(29,35,{|u| if(PCount()>0,cGet2:=u,cGet2)}, oScr2,230,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')
	
		@ 49,05 SAY "Tipo de pesquisa?" SIZE 100,10 OF oScr2 PIXEL

		oCombo:= TComboBox():Create(oScr2,{|u|if(PCount()>0,cCombo:=u,cCombo)},47,54,aItems,100,20,,,,,,.T.,,,,,,,,,'cCombo')

		//<------> FIM Scroll do lado Esquerdo - CIMA

		oTButton1 := TButton():New( aPosObj[1][3]+6, (aPosObj[1][4]/2)-30, "       Pesquisar",oDlg,{||Barpross(aAllTab,cGet1,cGet2,cCombo,oScr3,@oBrowse,aAllGroup,@oTButton2),oDlg:FreeChildren(),oDlg:Refresh() },60,18,,oFont2,.F.,.T.,.F.,,.F.,,,.F. )

	    // O CSS abaixo irá inserir uma imagem posicionada à esquerda/superior do botão,     
	    oTButton1:SetCss("QPushButton{ background-image: url(rpo:SDUSEEK.png);"+;
	                                " background-repeat: none; margin: 2px }")
	                                
	                                
		//<------> Scroll de BAIXO                             
   		oScr3 := TScrollBox():New(oDlg,aPosObj[2][1]+25,((aPosObj[2][2]))+6,aPosObj[2][3]-nDif,aPosObj[2][4] -16,.T.,.T.,.T.)

    ACTIVATE DIALOG oDlg CENTERED 


Return


/*
Funcao      : MarcTodo()
Parametros  : aAllTab,lMacTd
Retorno     : 
Objetivos   : Função para marcar todas as tabelas
Autor       : Matheus Massarotto
Data/Hora   : 16/05/2013	11:10
*/
*----------------------------------------*
Static Function MarcTodo(aAllTab,lMacTd)
*----------------------------------------*

for j:=1 to len(aAllTab)
	&("lCheck"+aAllTab[j]):=lMacTd
	&("oCheck"+aAllTab[j]):Refresh()
next

Return

/*
Funcao      : Barpross()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 16/05/2013	15:14
*/
*------------------------------------------------------------------------------------*
Static Function Barpross(aAllTab,cGet1,cGet2,cCombo,oScr3,oBrowse,aAllGroup,oTButton2)
*------------------------------------------------------------------------------------*
Local lTemMark	:= .F.
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

//Fazendo as validações

	if empty(cGet1) .AND. empty(cGet2)
	    Alert("Por favor informar ao menos uma informação para pesquisa!","Atenção")
		Return(.F.)
	endif
	
	if empty(cCombo)
		Alert("Por favor informar o tipo de pesquisa!","Atenção")
		Return(.F.)
	endif
	
	for i:=1 to len(aAllTab)
		cVar:="lCheck"+aAllTab[i]
		if &(cVar)
			lTemMark:=.T.
		endif
	next
	
	if !lTemMark
		Alert("Por favor informar ao menos um cadastro a ser pesquisado!","Atenção")
		Return(.F.)
	endif

//Fim - Fazendo as validações
    
	//Verifico se o objeto ja foi utilizado para limpá-lo antes da próxima pesquisa
	if valtype(oBrowse)=="O"
		oBrowse:DeActivate()   //Desabilito o objeto do browse

		oScr3:FreeChildren() //Libero todos os objetos da classe onde este método é chamado
		oScr3:Refresh()
	endif

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=ProcDado(oMeter,oDlg1,@oBrowse,oScr3,cGet1,cGet2,cCombo,aAllGroup,aAllTab,@oTButton2))
	  
	//*************************************



Return(lRet)

/*
Funcao      : ProcDado()
Parametros  : oMeter,oDlg1,oBrowse,oScr3,cGet1,cGet2,cCombo,aAllGroup,aAllTab,oTButton2
Retorno     : 
Objetivos   : Função para processar os dados
Autor       : Matheus Massarotto
Data/Hora   : 21/05/2013	11:10
*/

*-------------------------------------------------------------------------------------------------*
Static function ProcDado(oMeter,oDlg1,oBrowse,oScr3,cGet1,cGet2,cCombo,aAllGroup,aAllTab,oTButton2)
*-------------------------------------------------------------------------------------------------*
Local aDadTemp	:= {}
Local cMensErro	:= ""


AADD(aDadTemp,{"COD_EMP"	,"C",2,0})
AADD(aDadTemp,{"DESC_EMP"	,"C",20,0})
AADD(aDadTemp,{"TIPO"		,"C",20,0})
AADD(aDadTemp,{"CODIGO"		,"C",6,0})
AADD(aDadTemp,{"NOME"		,"C",50,0})
AADD(aDadTemp,{"CGC"		,"C",14,0})
AADD(aDadTemp,{"R_E_C_N_O_"	,"N",6,0})
AADD(aDadTemp,{"TABELA"		,"C",3,0})

if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif

//Inicia a régua
oMeter:Set(0)

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
cIndex2	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB",cIndex2,"CGC",,,"Selecionando Registro...")
IndRegua("DADTRB",cIndex,"NOME",,,"Selecionando Registro...")  

DbSelectArea("DADTRB")
DbSetIndex(cIndex2+OrdBagExt())
DbSetOrder(1)

// Carrega a tabela temporária com as informações
LoadTRB(@oMeter,cGet1,cGet2,cCombo,aAllGroup,aAllTab,@cMensErro,@oTButton2)


// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "DADTRB" OF oScr3		


// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || COD_EMP   	} TITLE "Cod Empresa"   	DOUBLECLICK  {|| WaitAxVi(TABELA,R_E_C_N_O_,COD_EMP,DESC_EMP) }  SIZE  2 OF oBrowse 
ADD COLUMN oColumn DATA { || DESC_EMP 	} TITLE "Descrição"   		DOUBLECLICK  {|| WaitAxVi(TABELA,R_E_C_N_O_,COD_EMP,DESC_EMP) }	 SIZE 20 OF oBrowse		
ADD COLUMN oColumn DATA { || TIPO    	} TITLE "Cadastro" 			DOUBLECLICK  {|| WaitAxVi(TABELA,R_E_C_N_O_,COD_EMP,DESC_EMP) }	 SIZE 20 OF oBrowse		
ADD COLUMN oColumn DATA { || CODIGO    	} TITLE "Cod Localizado"	DOUBLECLICK  {|| WaitAxVi(TABELA,R_E_C_N_O_,COD_EMP,DESC_EMP) }	 SIZE  6 OF oBrowse	
ADD COLUMN oColumn DATA { || NOME    	} TITLE "Nome Localizado"	DOUBLECLICK  {|| WaitAxVi(TABELA,R_E_C_N_O_,COD_EMP,DESC_EMP) }	 SIZE 50 OF oBrowse	
ADD COLUMN oColumn DATA { || CGC    	} TITLE "CPF/CNPJ"      	DOUBLECLICK  {|| WaitAxVi(TABELA,R_E_C_N_O_,COD_EMP,DESC_EMP) }	 SIZE 14 OF oBrowse	

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse

//Encerra a barra
oDlg1:end()

if !empty(cMensErro)
	oTButton2 := TButton():New( aPosObj[1][3]+6, (aPosObj[1][4]/2)+30, "       ",oDlg,{||ExibMsg(cMensErro) },18,18,,,.F.,.T.,.F.,,.F.,,,.F. )

    // O CSS abaixo irá inserir uma imagem posicionada à esquerda/superior do botão,     
    oTButton2:SetCss("QPushButton{ background-image: url(rpo:UPDWARNING.png);"+;
                     " background-repeat: none; margin: 2px }")
endif


Return(.T.)

/*
Funcao      : LoadTRB()
Parametros  : oMeter,cGet1,cGet2,cCombo,aAllGroup,aAllTab,cMensErro,oTButton2
Retorno     : 
Objetivos   : Função para buscar as informações via query e carregar o TRB
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	11:10
*/

*--------------------------------------------------------------------------------------*
Static function LoadTRB(oMeter,cGet1,cGet2,cCombo,aAllGroup,aAllTab,cMensErro,oTButton2)
*--------------------------------------------------------------------------------------*
Local cQry	:=""

cMensErro	:=""

if valtype(oTButton2)=="O"
	oTButton2:Hide()
endif

    //Percorro as tabelas
    For j:=1 to len(aAllTab)
                    
		cVar:="lCheck"+aAllTab[j]
		cObj:="oCheck"+aAllTab[j]
		if !&(cVar)
			loop	
		endif
        

        //Se for só empresa logada
        if cCombo=="Empresa atual"
			
			if !TCCanOpen(aAllTab[j]+cEmpAnt+"0")
				Loop
			endif
			
			//Testando se a query tem problemas
			cTeste:=" SELECT '"+cEmpAnt+"' AS EMP,'"+aAllTab[j]+"' AS TABELA,'"+alltrim(&(cObj):cCaption)+"' AS TIPO,"+SUBSTR(aAllTab[j],2,2)+"_COD AS COD"+","+SUBSTR(aAllTab[j],2,2)+"_NOME AS NOME,"+SUBSTR(aAllTab[j],2,2)+"_CGC AS CGC,R_E_C_N_O_ FROM "+aAllTab[j]+cEmpAnt+"0"
			if tcsqlexec(cTeste)<0
				cError		:= TCSQLError()
				cMensErro	+= "Empresa: "+cEmpAnt+": "+alltrim(cError)+CRLF+"----------------------------"+CRLF
				Loop
			endif
			
			if !empty(cQry)
			   cQry+=" UNION ALL "            	
			endif
			
			cQry+=" SELECT '"+cEmpAnt+"' AS EMP,'"+aAllTab[j]+"' AS TABELA,'"+alltrim(&(cObj):cCaption)+"' AS TIPO,"+SUBSTR(aAllTab[j],2,2)+"_COD AS COD"+","+SUBSTR(aAllTab[j],2,2)+"_NOME AS NOME,"+SUBSTR(aAllTab[j],2,2)+"_CGC AS CGC,R_E_C_N_O_ FROM "+aAllTab[j]+cEmpAnt+"0"+CRLF
			cQry+=" WHERE D_E_L_E_T_='' "
			if !empty(cGet1)
				cQry+=" AND "+SUBSTR(aAllTab[j],2,2)+"_CGC LIKE '%"+alltrim(cGet1)+"%'"
			endif
			if !empty(cGet2)
				cQry+=" AND UPPER("+SUBSTR(aAllTab[j],2,2)+"_NOME) LIKE UPPER('%"+alltrim(cGet2)+"%')"
			endif
			
			
		else
		    //Percorro todas as empresas
			For i:=1 to len(aAllGroup)
                if !TCCanOpen(aAllTab[j]+aAllGroup[i]+"0")
					Loop
				endif

    			//Testando se a query tem problemas
    			cTeste:="SELECT '"+aAllGroup[i]+"' AS EMP,'"+aAllTab[j]+"' AS TABELA,'"+alltrim(&(cObj):cCaption)+"' AS TIPO,"+SUBSTR(aAllTab[j],2,2)+"_COD AS COD"+","+SUBSTR(aAllTab[j],2,2)+"_NOME AS NOME,"+SUBSTR(aAllTab[j],2,2)+"_CGC AS CGC,R_E_C_N_O_ FROM "+aAllTab[j]+aAllGroup[i]+"0"
                if tcsqlexec(cTeste)<0
					cError		:= TCSQLError()
					cMensErro	+= "Empresa: "+aAllGroup[i]+": "+alltrim(cError)+CRLF+"----------------------------"+CRLF
					Loop
				endif
                
				if !empty(cQry)
				   cQry+=" UNION ALL "            	
				endif
				
				cQry+=" SELECT '"+aAllGroup[i]+"' AS EMP,'"+aAllTab[j]+"' AS TABELA,'"+alltrim(&(cObj):cCaption)+"' AS TIPO,"+SUBSTR(aAllTab[j],2,2)+"_COD AS COD"+","+SUBSTR(aAllTab[j],2,2)+"_NOME AS NOME,"+SUBSTR(aAllTab[j],2,2)+"_CGC AS CGC,R_E_C_N_O_ FROM "+aAllTab[j]+aAllGroup[i]+"0"+CRLF
				cQry+=" WHERE D_E_L_E_T_='' "
				if !empty(cGet1)
					cQry+=" AND "+SUBSTR(aAllTab[j],2,2)+"_CGC LIKE '%"+alltrim(cGet1)+"%'"
				endif
				if !empty(cGet2)
					cQry+=" AND UPPER("+SUBSTR(aAllTab[j],2,2)+"_NOME) LIKE UPPER('%"+alltrim(cGet2)+"%')"
				endif
				
		    Next
		    
		endif

	Next

    //Se a query n foi carregada
	if empty(cQry)
		return
	endif

		if select("QRYTEMP")>0
			QRYTEMP->(DbCloseArea())
		endif
	
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRYTEMP", .F., .F. )
	
		Count to nRecCount
		
		//de quanto em quanto a regua deve aumentar
		nAumenta:= 100/(nRecCount/100)
		
		if nRecCount > 0
			
			QRYTEMP->(DbGotop())
			
			While QRYTEMP->(!EOF())
			    Reclock("DADTRB",.T.)

               	    //Processamento da régua
					nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
					nCurrent+=nAumenta 	// atualiza régua
					oMeter:Set(nCurrent) //seta o valor na régua
			    
					DADTRB->COD_EMP		:= QRYTEMP->EMP
					DADTRB->DESC_EMP	:= FWGrpName(QRYTEMP->EMP) //Nome da Empresa
					DADTRB->TIPO		:= QRYTEMP->TIPO
					DADTRB->CODIGO		:= QRYTEMP->COD
					DADTRB->NOME		:= QRYTEMP->NOME
					DADTRB->CGC			:= QRYTEMP->CGC
					DADTRB->R_E_C_N_O_	:= QRYTEMP->R_E_C_N_O_
					DADTRB->TABELA		:= QRYTEMP->TABELA
					
				DADTRB->(MsUnlock())
				QRYTEMP->(DbSkip())
			Enddo
	
		endif

Return


/*
Funcao      : WaitAxVi()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	15:14
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
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	11:10
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

/*
Funcao      : ExibMsg()
Parametros  : cMsg
Retorno     : 
Objetivos   : Função para exibir a mensagem de erro
Autor       : Matheus Massarotto
Data/Hora   : 20/05/2013	11:10
*/

*---------------------------*
Static Function ExibMsg(cMsg)
*---------------------------*

Local bTexto := {|| cMsg}
Local oDlgErr
                                 
    DEFINE DIALOG oDlgErr TITLE "Erros encontrados!!" FROM 180,180 TO 380,700 PIXEL
        // Usando o método New    
        oScrErr := TScrollBox():New(oDlgErr,01,01,92,260,.T.,.T.,.T.)
         
    
        oSayErr:= TSay():New(01, 01, bTexto, oScrErr,,,,;
                            ,,.T.,CLR_RED,CLR_WHITE,400,1000)    
                                 
    ACTIVATE DIALOG oDlgErr CENTERED 

Return
