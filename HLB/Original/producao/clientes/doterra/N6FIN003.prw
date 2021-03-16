#INCLUDE "FINA910B.ch"
#Include "Protheus.ch"             
#Include "ApWizard.ch"
#include "fileio.ch"

#define STR0002 "Conciliação WorldPay"
#define STR0003 If( cPaisLoc $ "ANG|PTG", "Wizard utilizado para importação de ficheiros de conciliação WorldPay", "Wizard utilizado para importacao de arquivos de conciliação WorldPay" )
#define STR0004 If( cPaisLoc $ "ANG|PTG", "O objectivo deste procedimento é importar os ficheiros de conciliação WorldPay", "Esta rotina tem por objetivo importar os arquivos de conciliação WorldPay" )
#define STR0006 If( cPaisLoc $ "ANG|PTG", "Seleccione o ficheiro de integração de conciliação WorldPay", "Selecione o arquivo de integração de conciliação WorldPay" )
#define STR0010 If( cPaisLoc $ "ANG|PTG", "Para confirmar a importação do ficheiro de conciliação WorldPay, clique em Finalizar ou clique em Cancelar para sair do procedimento", "Para confirmar a importação do arquivo de conciliação WorldPay clique em Finalizar ou clique em Cancelar para sair da rotina" )
#define STR0012 If( cPaisLoc $ "ANG|PTG", "Para continuar, é necessária a pesquisa do ficheiro", "Para continuar é necessario a pesquisa do arquivo" )
#define STR0015 If( cPaisLoc $ "ANG|PTG", "Ficheiros TXT", "Arquivos TXT" )
#define STR0048 If( cPaisLoc $ "ANG|PTG", "Selecione a operadora WorldPay que gerou o ficheiro de conciliação", "Selecione a operadora WorldPay que gerou o arquivo de conciliação" )
                                              
Static nTamEmis 	:= TamSX3("E1_EMISSAO")[1]
Static nTamParc 	:= TamSX3("E1_PARCELA")[1]
Static nTamTEF 		:= TamSX3("E1_NSUTEF")[1]
Static nTamTPE1 	:= TamSX3("E1_TIPO")[1]    
Static nZX3Parc		:= TamSX3("ZX3_PARCEL")[1]  
Static nTamNSU		:= TamSX3("ZX3_WLDPA")[1]
Static nTamDtVnd	:= TamSX3("ZX3_DTTEF")[1]  

//---------------------------------------------------------------------------------------------------------------

//Detalhes do Arquivo de Conciliacao do WorldPay - Crédito
Static nPosSqReg 	:= 0 		//Seq. do Registro no Arquivo
Static nPosToReg 	:= 0		//Total de Campos do Trailer

//Detalhes do Arquivo de Conciliacao do WorldPay - Venda
Static nVPosSqReg 	:= 0		//Seq. do Registro no Arquivo
Static nVPosToReg 	:= 0		//Total de Campos do Trailer

Static cVerCon		:= ""
Static oParamFil    := Nil		//Objeto do tipo LJCHasheTable com as filiais cadastradas nos parametros 
Static aCompSA1		:= {}
Static aCompSA6		:= {} 

Static lFin910Fil	:= (ExistBlock("FIN910FIL")) //PE para seleção de filiais.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³N6FIN006  ³ Autor ³ William Souza         ³ Data ³15/05/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ CSA              ³Contato ³ 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina que importa os Arquivos do WorldPay e D-TEF   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function N6FIN003()

	Local oWizard	:= Nil		//Objeto matriz 
	Local oCamArq	:= Nil		//Objeto do caminho do arquivo
	Local cCamArq	:= ""		//variavel do caminho do arquivo
	Local lOk		:= .F.		//Variavel que verifica se o procedimento foi executado com um Finalizar

	Private lEnd 	:= .T.
	
		DEFINE WIZARD oWizard TITLE STR0002 HEADER STR0003;			//"STR0002 Conciliação Worldpay"	### STR0003 "Wizard utilizado para importacao de arquivos de Conciliação Worldpay"                                                                                                                                                                                                                                                                                                                                                                                                                                                   
			MESSAGE "";
			TEXT STR0004;										//"Esta rotina tem por objetivo importar os arquivos de Conciliação Worldpay" 
			PANEL NEXT {|| .T. } FINISH {|| .T. };

		// Painel da selecao do arquivo
		CREATE PANEL oWizard HEADER STR0005;					//"Dados conciliação"
			MESSAGE STR0006;									//"Selecione o arquivo de integração de conciliação do WorldPay"
			PANEL BACK {|| .T. } NEXT {|| A910ExtArq(cCamArq) } FINISH {|| .T. } EXEC {|| .T. }

			@ C(005),C(005) Say STR0007 			  Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oWizard:oMPanel[2]				//"Arquivo"
			@ C(004),C(055) MsGet oCamArq Var cCamArq Size C(105),C(009) COLOR CLR_BLACK PIXEL OF oWizard:oMPanel[2]

			@ C(004),C(162) Button STR0008 Size C(037),C(009) Action A910BscArq(@cCamArq,@oCamArq) PIXEL OF oWizard:oMPanel[2]	//"&Procurar"

		// Painel da importacao do arquivo e finalizacao do processo
		CREATE PANEL oWizard HEADER STR0009;					//"Finalizar"
			MESSAGE STR0010;									//"Para confirmar a importação do arquivo de conciliação do WorldPay clique em Finalizar ou clique em Cancelar para sair da rotina"
			PANEL BACK {|| .T. } FINISH {|| lOk := .T. } EXEC {|| .T.}

	ACTIVATE WIZARD oWizard CENTERED

	If lOk
		//Ponto de Entrada para substituir a importacao do arquivo padrao de Conciliacao da WorldPay
			Processa({|lEnd| A910VldArq(cCamArq,@lEnd) },STR0011, ,@lEnd)				//"Processando..."
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910VldArqºAutor  ³Rafael Rosa da Silvaº Data ³  08/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A910ExtArq(cCamArq)

	Local lRet := .T.

	If Empty(cCamArq)
		MsgInfo(STR0012)							//"Para continuar é necessario a pesquisa do arquivo"
		lRet := .F.
	ElseIf !File(cCamArq)
		MsgInfo(STR0013 + cCamArq + STR0014)		//"Arquivo "	### " nao encontrado!"
		lRet := .F.
	EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910BscArqºAutor  ³Rafael Rosa da Silvaº Data ³  08/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A910BscArq(cCamArq,oCamArq)

	Local cType := OemToAnsi(STR0015) + "(*.txt) |*.txt|"													//"Arquivos txt"

	cCamArq := Upper(Alltrim(cGetFile(cType ,STR0016,0,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE)))			//"Selecione o Arquivo"
	oCamArq:Refresh()

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910GrvArqºAutor  ³Rafael Rosa da Silvaº Data ³  08/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A910VldArq(cCamArq, lEnd)

	Local lRet		:= .T.		//Variavel de controle do retorno 
	Local cLinha	:= ""		//variavel de leitura da linha
	Local nSeq		:= 1		//Variavel que verifica se a sequencia do arquivo esta correta
	Local aLinha	:= {}		//Array contendo todos os Registros ja desmembrados
	Local lTemHead	:= .F.		//Variavel que verifica se existe o registro Header
	Local lTemVnd	:= .F.		//Variavel que verifica se existe o registro Venda
	Local lIncVnd	:= .T.		//Variavel que verifica se inclue ou nao registro Venda
	Local lFirst	:= .T.		//Variavel que estancia a existencia de Detalhes da Venda somente uma vez
	Local lTemRod	:= .F.		//Variavel que verifica se existe o registro Trailer
	Local aDados	:= {}		//Variavel que guarda as informacoes de campos e os valores que deverao ser gravados nele
	Local aLog		:= {}		//Array contendo as mensagens de nao conformidade do arquivo
	Local nRegExist	:= 0		//Verifica se foi escolhida uma opcao para registros ja existentes no tratamento do Detalhes do Arquivo
	Local cWLDPA	:= ""		//Variavel Auxiliar para montagem do indice com os espacos do tamanho do campo
	Local cParcela	:= ""		//Variavel Auxiliar para montagem do indice com os espacos do tamanho do campo
	Local _cConta   := ""       //Variavel _cConta
	Local cParc     := ""		//Variavel cParc
	Local cNPARC	:= ""       //Variavel cNPARC
	Local cEstab	:= ""       // Variavel para pesquisar o codigo do estabelecimento
	Local cIdRed	:= ""		// Variavel para pesquisar o codigo da operadora
	Local cCodLoj   := ""       //Variavel cCodLoj
	Local cCodBan	:= ""		//Codigo da bandeira 
	Local nFator 	:= 1
	Local dHoje		:= dTos(Date()) 
	Local cMsFilAnt := ""
	Local cMsFil    := ""
	Local cParc     := ""       //Variavel cParc
	Local cCodBan	:= ""		//Codigo da bandeira
	Local aCampos		:= {}
	Local aTam     	:= {}
	Local cArqTrab		:=	""
	Local cIndTmp  	:=	""
	Local cNome			:= ""   
	Local cChave		:=	""
	Local cArqReg100	:=	"TMP100"
	Local aParc			:= {}
	Local nI				:= 0                      
	Local nEx1			:= 0
	Local nEx2			:= 0
	Local cFilZX3    	:= ""
	Local cChaveTmp := ""

	Local cCodBco := ""
	Local cCodAge := ""
	Local cConta  := ""
		
	Private cSeqZX3   := ""		//Sequencial da tabela ZX3
	Private nTamWLDPA :=  TamSX3("ZX3_WLDPA")[1]
	Private nTamParcel := TamSX3("ZX3_PARCEL")[1]
	Private nTamCodEst := TamSX3("ZX3_CODEST")[1]
	Private nTAmCodRed := TamSX3("ZX3_CODRED")[1]
	Private nTAmCodFil := TamSX3("ZX3_CODFIL")[1]
	Private nDecTxServ := TamSX3("ZX3_TXSERV")[2]
	Private nDecVlBrut := TamSX3("ZX3_VLBRUT")[2]
	Private nDecVlliq  := TamSX3("ZX3_VLLIQ")[2]
	Private nDecVlCom  := TamSX3("ZX3_VLCOM")[2]
	
	aCampos := {}
	AADD(aCampos,{"CODEST"  ,"C",15,0})    
	AADD(aCampos,{"CODLOJ"  ,"C",8,0})    
	AADD(aCampos,{"NRORES"  ,"C",15,0})    
	aTam:=TamSX3("E1_EMISSAO")
	AADD(aCampos,{"DTANTEC" ,"C",8,0})
	aTam:=TamSX3("E1_VALOR")
	AADD(aCampos,{"VRANT"   ,"N",aTam[1],aTam[2]})
	AADD(aCampos,{"PARC"    ,"C",2,0})    
	AADD(aCampos,{"DTCRED" ,"C",8,0})
	aTam:=TamSX3("E1_VALOR")
	AADD(aCampos,{"VRORIG"   ,"N",aTam[1],aTam[2]})
	AADD(aCampos,{"CODBCO"  ,"C",6,0})    
	AADD(aCampos,{"CODAG"   ,"C",6,0})    
	AADD(aCampos,{"CODCTA"  ,"C",15,0})      			
	AADD(aCampos,{"RESUN"   ,"C",22,0})
	
	cArqTrab 	:=	CriaTrab(aCampos,.T.)
	
	dbUseArea(.T.,__LocalDriver, cArqTrab,cArqReg100,.F.,.F.)
	DbSelectArea(cArqReg100)
	
	cIndTmp		:=	CriaTrab(Nil,.F.)
	
	cChave   := "CODEST+CODLOJ+NRORES" 
	IndRegua(cArqReg100,cIndTmp,cChave,,Nil,)  //"Selecionando Registros..."		

	/*======================================\
	|Estrutura do Array aLog				|
	|---------------------------------------|
	|aLog[n][1] -> Linha da Ocorrencia		|
	|aLog[n][2] -> Tipo da Ocorrencia		|
	|aLog[n][1] -> Descricao da Ocorrencia	|
	\======================================*/
	ConoutR("Conciliador Worldpay - N6FIN003 - A910VldArq - INICIO IMPORTANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())
	If !LockByName( "TESTE"+cEmpAnt, .F. , .F. )
		MsgStop(STR0059,"TESTE" )//"Esta rotina está sendo utilizada por outro usuário. Tente novamente mais tarde."
		Return
    EndIf

	//Carrega as filiais cadastradas no parametro MV_EMPTEF
	A910CarFil()

	dbSelectArea("ZX3")
	dbSetOrder(5)	//ZX3_FILIAL+ZX3_DTTEF+ZX3_WLDPA+ZX3_PARCEL+ZX3_CODLOJ+ZX3_DTCRED+ZX3_SEQZX3

    nHdlFile := FT_FUse(cCamArq)
	nRecCount := FT_FLASTREC()
	fClose(nHdlFile)
	FT_FUSE()
	
	nHdlFile := fOpen(cCamArq)
	//se arquivo tiver mais de 2 mil registros realiza o commit e atualização de tela a cada 1000               
	If nRecCount > 2000
		nFator := 1000
	EndIf

	ProcRegua(nRecCount/nFator )
	nTam := 1000


	cCodBco := ""
	cCodAge := ""
	cConta  := ""
	If !(nHdlFile == -1) 

		//inicia transacao  -- somente na leitura do arquivo texto eh permitido abortar
		//                     transacao existe pq em algum momento ele deleta registro na tabela ZX3
		BeginTran()   
		While fReadLn(nHdlFile,@cLinha,nTam)

			If nSeq%nFator = 0
				IncProc(STR0060 + "(" + AllTrim(Str(nSeq)) + "/" + AllTrim(Str(nRecCount /*FT_FLASTREC()*/)) + ")")			//"Processando..."
		    EndIf			
			//caso usuario aborte pressionando botao cancelar
			If lEnd .And. Aviso( "Atencao","Abortar Processamento ?", {"Sim","Nao"} ) == 1 
				DisarmTransaction()
				MsUnLockAll() 
				Return
			Else
				lEnd := .F.
			EndIf

			If Empty(cLinha)
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retira as aspas duplas e troca por espaco em branco³
			//³senao a funcao strtokarr nao traz a coluna         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//cLinha	:= StrTran(cLinha,'""'," ")

			//Retira os caracteres especiais, no caso o " que separa os registros
			//cLinha	:= StrTran(cLinha,'"',"")

			//Transforma a linha em um array com todos os registros
			aLinha	:= StrToKArr(cLinha,"	")

			/*
				* LDB - 28/05/2018 - Gravar banco agencia e conta 
			*/                                                    
			If aLinha[1] $ "01" //header
				If Empty( cCodBco )  .And. Len( aLinha ) > 21 .And. !Empty( aLinha[ 22 ] ) 
					cCodBco := aLinha[ 22 ]
					cCodAge := If( Len( aLinha ) > 22 , aLinha[ 23 ] , "" )
					cConta 	:= If( Len( aLinha ) > 23 , aLinha[ 24 ] , "" )
				EndIf
			EndIf
			
			if aLinha[1] $ "02" //venda
			
			cSeqZX3   := A910SeqZX3(substr(alinha[10],5,8)+substr(alinha[10],3,2)+substr(alinha[10],1,2), alinha[4], alinha[19], "01", substr(alinha[10],5,8)+substr(alinha[10],3,2)+substr(alinha[10],1,2))
			aAdd(aDados,{      	    {"ZX3_FILIAL"	,FWCodFil()		   										    	,Nil},;   //1
									{"ZX3_TPREG"	,alinha[1]		   										    	,Nil},;   //2
									{"ZX3_CODEST"	,alinha[2]		   										    	,Nil},;   //3
									{"ZX3_WLDPA"	,alinha[4]		   										    	,Nil},;   //4
									{"ZX3_CODAUT"	,alinha[5]		   										    	,Nil},;   //5
									{"ZX3_DTTEF"	,stod(substr(alinha[6],5,8)+substr(alinha[6],3,2)+substr(alinha[6],1,2))   ,Nil},; //6
									{"ZX3_DTCRED"	,stod(substr(alinha[10],5,8)+substr(alinha[10],3,2)+substr(alinha[10],1,2)),Nil},; //7
									{"ZX3_CODLOJ"	,alinha[8]		   										    	,Nil},;   //8
									{"ZX3_CAPTUR"	,alinha[9]		   										    	,Nil},;   //9
									{"ZX3_CODBAN"	,IIF(alinha[11]=="VISA","01",IIF(alinha[11]=="MASTERCARD","02","03")),Nil},;  //10
									{"ZX3_CUPOM"	,"Cartao:"+alinha[11]+"/Tipo:"+alinha[15]+"/Moeda:"+alinha[16] 	,Nil},;       //11
									{"ZX3_NUCART"	,alinha[14] 													,Nil},;       //12
									{"ZX3_VLLIQ"	,val(substr(alinha[27],1,len(alinha[27])-2)+"."+right(alinha[27],2)) ,Nil},;  //13
									{"ZX3_VLBRUT"	,val(substr(alinha[17],1,len(alinha[17])-2)+"."+right(alinha[17],2)) ,Nil},;  //14
									{"ZX3_PARCEL"	,If(Val(alinha[19])>0, alinha[19],"") 													,Nil},;       //15
									{"ZX3_TOTPAR"	,alinha[20] ,Nil},;                                                           //16
									{"ZX3_VLCOM"	,val(substr(alinha[21],1,len(alinha[21])-2)+"."+right(alinha[21],2)) ,Nil},;  //17
									{"ZX3_MSIMP"	,dTos(Date())												    ,Nil},;       //18
									{"ZX3_STATUS"	,"1"														    ,Nil},;       //19
									{"ZX3_SEQZX3"	,cSeqZX3        								                ,Nil},;       //20
									{"ZX3_PARALF"   ,If(Val(alinha[19])>0,Chr(64 + Val(alinha[19])),"")										,Nil},;       //21
									{"ZX3_TXSERV"	,val(substr(alinha[22],1,len(alinha[22])-2)+"."+right(alinha[22],2)) ,Nil},;   //22    
									{"ZX3_CODBCO" , cCodBco , Nil } ,; //23
									{"ZX3_CODAGE" , AllTrim( Str( Val( cCodAge ) ) ) , Nil } ,; //24
									{"ZX3_NUMCC" , AllTrim( Str( Val( cConta ) ) ) , Nil } ; //25																		
									})  
  			Endif                                                                                                 
			//Soma um no sequenciador do arquivo
			nSeq++
		End
        
		EndTran()		//termino transacao
		MsUnlockAll()   //libera todos os registros lockados
		

		//Verifico se todos os dados do arquivo estao corretos e chamo a rotina para gravar as informacoes na tabela
		If Len(aDados) > 0
			Processa({|| A910GrvArq(aDados) },STR0035)			//"Gravando os Registros..."
		EndIf
		ConoutR("Conciliador Worldpay - N6FIN003 - A910VldArq - FIM IMPORTANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())

		If Len(aLog) > 0
			Processa({|| A910GrvLog(aLog) },STR0036)			//"Gravando os Log's..."
		EndIf
	Else
		MsgInfo(STR0007 + cCamArq + STR0037 )		//"Arquivo "	### " nao possui registros"
		lRet := .F.
	EndIf
	
	Ferase(cArqReg100+GetDBExtension())
   
	(cArqReg100)->(dbCloseArea())
	FErase(cArqReg100)

	//limpa array	       
	aDados := aSize(aDados,0)
	aDados := nil
	fClose( nHdlFile)
	UnlockByName("TESTE"+cEmpAnt, .F., .F. )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910SeqZX3ºAutor  ³Totvs               º Data ³  04/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o proximo numero do campo ZX3_SEQZX3          	  º±±
±±º          ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A910SeqZX3(cDtVend, cNsuTef, cParcela, cCodLoja, ;
						   cDtCred)

	Local aOrdZX3 := ZX3->(GetArea())    //Area ZX3
    Local cQuery := ""

	cNsuTef		:= Alltrim(cNsuTef)  + Space(nTamWLDPA - Len(Alltrim(cNsuTef)))
	cParcela	:= Alltrim(cParcela) + Space(nTamParcel - Len(Alltrim(cParcela)))				
	cCodLoja    := Alltrim(cCodLoja) + Space(nTAmCodFil - Len(Alltrim(cCodLoja)))

	#IFDEF TOP   
		// se cSeqZX3 em branco, ainda não buscou o ultimo sequencial
		If Empty(cSeqZX3)                                      
			cQuery := " SELECT MAX(ZX3_SEQZX3) MAXZX3 FROM " + RetSqlName("ZX3") 
		   	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB")
	        If TRB->(!Eof())                      
	           	cSeqZX3 := Soma1(TRB->MAXZX3) 
	        Else                        
	        	cSeqZX3 := Soma1("000000")	   	
	        EndIf   	
	        TRB->(DbCloseArea())
        Else
        	//se já estiver preenchido o sequencial, só somar 1 
        	cSeqZX3 := Soma1(cSeqZX3)
        EndIf
	#ELSE
		cSeqZX3 := GetSxENum("ZX3", "ZX3_SEQZX3")
		DbSelectArea("ZX3")
		DbSetOrder(5) //ZX3_FILIAL+ZX3_DTTEF+ZX3_WLDPA+ZX3_PARCEL+ZX3_CODLOJ+ZX3_DTCRED+ZX3_SEQZX3
	
		While ZX3->(MsSeek(xFilial("ZX3") + cDtVend + cNsuTef + cParcela + cCodLoja + cDtCred + cSeqZX3))
		  	If (__lSx8)
				ConfirmSX8()
			EndIf
			cSeqZX3 := GetSxENum("ZX3", "ZX3_SEQZX3")
		EndDo
		ConfirmSX8()
	#ENDIF

	RestArea(aOrdZX3)

Return cSeqZX3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910GrvArqºAutor  ³Rafael Rosa da Silvaº Data ³  08/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que efetua a gravacao dos registrosn na tabela ZX3	  º±±
±±º          ³(Conciliacao do WorldPay)									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A910GrvArq(aDados)

	Local nI	:= 0			//Variavel para contador de registros
	Local nX	:= 0			//Variavel para contador de registros
    Local nFator := If(Len(aDados) > 2000, 1000, 1)                                                                

	dbSelectArea("ZX3")
    DbSetOrder( 6 )  //** Leandro Brito - Filial + WorldPay + Parcela  ( Para nao duplicar leitura )
    
	CONOUTR("Conciliador Worldpay - N6FIN003 - A910GrvArq - INICIO GRAVANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())


	ProcRegua(Len(aDados)/nFator)

	BeginTran()
		For nI := 1 to Len(aDados)
			If nI%nFator == 0  
				//Encerra uma transacao e inicia outra
				EndTran()
				BeginTran()
			IncProc(STR0035 + "(" + AllTrim(Str(nI)) + "/" + AllTrim(Str(Len(aDados))) + ")")		//"Gravando os Registros..."
			EndIf	 
			
			//** LDB - Busca se ja existe o registro para nao duplicar e atualiza caso ainda nao tenha sido processado
			If DbSeek( xFilial( 'ZX3' ) + PadR( aDados[ nI ][ 4 ][ 2 ] , nTamWLDPA ) + PadR( aDados[ nI ][ 15 ][ 2 ] , nTamParcel ) )
				If AllTrim( ZX3->ZX3_STATUS ) <> '1'
					Loop
				EndIf   
				RecLock("ZX3",.F.)							
			Else
				RecLock("ZX3",.T.)
			EndIf              
			//** Fim 
			
			For nX := 1 to Len(aDados[nI])
				ZX3->&(aDados[nI][nX][1]) := aDados[nI][nX][2]
			Next nX

			ZX3->( MsUnLock() )
		Next nI
	EndTran()

	CONOUTR("Conciliador Worldpay - N6FIN003 - A910GrvArq - FIM GRAVANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910GrvLogºAutor  ³Rafael Rosa da Silvaº Data ³  08/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que efetua a gravacao dos Logs						  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A910GrvLog(aLog)

	Local cType := STR0038 + STR0039			//"Arquivos LOG"	### "(*.log) |*.log|"
	Local cDir	:= cGetFile(cType ,STR0040,0,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)			//"Selecione o diretorio para gravação do LOG"
	Local nHdl	:= 0                           //Handle do arquivo
	Local cDados:= ""                          //Descrição da Linha
	Local nI	:= 0                           //Variavel contadora de log
	Local cLin	:= ""                          //Variavel da linha do log
	Local cEOL	:= CHR(13)+CHR(10)            //Final de Linha
    Local nFator := If(Len(alog) > 2000, 1000, 1)

	//Incluo o nome do arquivo no caminho ja selecionado pelo usuario
	cDir := Upper(Alltrim(cDir)) + "LOG_FINA910_" + dTos(dDataBase) + StrTran(Time(),":","") + ".LOG"

	If (nHdl := FCreate(cDir)) == -1
	    MsgInfo(STR0041 + cDir + STR0042)			//"O arquivo de nome "	### " nao pode ser executado! Verifique os parametros."
	    Return
	EndIf

	cDados	:= STR0043								//"Linha da Ocorrencia;Tipo da Ocorrencia;Descricao da Ocorrencia"
	cLin	:= Space(Len(cDados)) + cEOL
	cLin	:= Stuff(cLin,01,Len(cDados),cDados)

	If FWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If Aviso(STR0026,STR0044,{STR0045,STR0046}) == 2		//"Atencao"	### "Ocorreu um erro na gravacao do arquivo. Continua?"	### "Sim"	### "Não"
			FClose(nHdl)
			Return
		EndIf
	EndIf

	CONOUTR("Conciliador Worldpay - N6FIN003 - A910GrvLog - INICIO GRAVANDO LOG - " + DToC(Date()) + " - Hora: " + TIME())

	ProcRegua(Len(aLog)/nFator)                      

	For nI := 1 to Len(aLog)

		If nI%nFator == 0
			IncProc(STR0036 + "(" + AllTrim(Str(nI)) + "/" + AllTrim(Str(Len(aLog))) + ")")			//"Gravando os Log's..."
        EndIf
		cDados	:= aLog[nI][1] + ';' + aLog[nI][2] + ';' + aLog[nI][3]
		cLin	:= Space( Len(cDados) ) + cEOL
		cLin	:= Stuff(cLin,01,Len(cDados),cDados)

		If FWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If Aviso(STR0026,STR0044,{STR0045,STR0046}) == 2		//"Atencao"	### "Ocorreu um erro na gravacao do arquivo. Continua?"	### "Sim"	### "Não"
				FClose(nHdl)
				Return
			EndIf
		EndIf
	Next nI

	FClose(nHdl)

	CONOUTR("Conciliador Worldpay - N6FIN003 - A910GrvLog - FIM GRAVANDO LOG - " + DToC(Date()) + " - Hora: " + TIME())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910CarFilº Autor ³ Alex Miranda       º Data ³  18/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega as filiais do parametro MV_EMPTEF mediante loja TEFº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A910CarFil()
	
	Local aArea	    := GetArea() //Variavel que armazenara WorkArea ativa
	Local cFiltro   := ''        //Variavel que armazenara o Filtro da SX6
	Local cIdioma   := ''        //Variavel que armazenara o Id do Idioma
	Local cFilWorldPay := ''        //Variavel que armazenara da filial WorldPay
    
	oParamFil := LJCHashTable():New()

	DbSelectArea("SX6")
	
	cFiltro   := "X6_VAR = 'MV_EMPTEF '"
	
	SX6->(DbSetFilter({||&cFiltro},cFiltro))
	SX6->(DbGoTop())
	
	cIdioma := IIF(__Language == "PORTUGUESE", "1",IIF(__Language == "SPANISH", "2", "3"))
	
	While !SX6->(Eof())
		cFilWorldPay := AllTrim(IIF(cIdioma == "1",SX6->X6_CONTEUD,IIF(cIdioma == "2",SX6->X6_CONTSPA,SX6->X6_CONTENG)))
	    
	    oParamFil:Add(UPPER(ALLTRIM(cFilWorldPay)), SX6->X6_FIL)
	    
	    SX6->(DbSkip())
	End
	
	SX6->(DbClearFilter())
	
	RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910MsFil º Autor ³ Alex Miranda       º Data ³  18/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pega filial do parametro MV_EMPTEF mediante loja TEF       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A910MsFil(cZX3CodLoj)
	
	Local cRetorno  := ''  	//Variavel que armazenara o retorno da função
	
	If oParamFil:Count() > 0
		If oParamFil:Contains(UPPER(ALLTRIM(cZX3CodLoj)))
	    	cRetorno := oParamFil:ElementKey(UPPER(ALLTRIM(cZX3CodLoj)))
		Else
			cRetorno := Space(nTAmCodFil)
		EndIf
    Else
    	cRetorno := Space(nTAmCodFil)
    EndIf

Return cRetorno






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA910B  ºAutor  ³Microsiga           º Data ³  11/22/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Busca informacoes do titulo relacionado com os parametros º±±
±±º          ³  (Arquivo conciliador)                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ AP                                                         º±±
±±ºaLinha    ³ Carrega os registro do arquivo conciliador.                º±±
±±ºaRetorno  ³ Retorna as informacoes do titulo relacionado.              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function DadosTit(aLinha,aRetorno)
	                              	
   //	Local lExcluSA1  := !Empty(xFilial("SA1"))			//Verifica se SA1 esta' compartilhada ou exclusiva
   //	Local lExcluSA6  := !Empty(xFilial("SA6"))			//Verifica se SA6 esta' compartilhada ou exclusiva
	Local lExcluMEP	 := !Empty(xFilial("MEP"))			//Verifica se MEP esta' compartilhada ou exclusiva        
	Local lMEP       := .T.								//Verifica se existe a tabela MEP	
	Local cQry	   	 := ""								//Instrucao de query no banco        
	Local nPos		 := 0                               //Numero de retorno do reg  
   //	Local aCompSA1 	 := {"E", "E", "E"} //Array de Compartilhamento do SA1
   //	Local aCompSA6	 := {"E", "E", "E"} //Array de Compartilhamento do SA6  
	Local cFilial	 := A910MsFil(aLinha[DI_CODLOJ]) 
	Local cFilSA1	:= ""
	Local cFilSA6    := ""
	
	
    If Len(aCompSA1) == 0 
    	If FWModeAccess("SA1",1) == "E"
    		aCompSA1 	 := {"E", "E", "E"} 
    	Else
    		aAdd(aCompSA1, "C")
    		If FWModeAccess("SA1",2) == "E" 
    			aAdd(aCompSA1, "E")
    			aAdd(aCompSA1, "E")
    		Else
    			aAdd(aCompSA1, "C")
    			aAdd(aCompSA1, FWModeAccess("SA1",2))
    		EndIf
    	EndIf
    EndIf
	
    If Len(aCompSA6) == 0 
    	If FWModeAccess("SA6",1) == "E"
    		aCompSA6 	 := {"E", "E", "E"} 
    	Else
    		aAdd(aCompSA6, "C")
    		If FWModeAccess("SA6",2) == "E" 
    			aAdd(aCompSA6, "E")
    			aAdd(aCompSA6, "E")
    		Else
    			aAdd(aCompSA6, "C")
    			aAdd(aCompSA6, FWModeAccess("SA6",2))
    		EndIf
    	EndIf
    EndIf    
    
    cFilSA1 := 	FWxFilial( "SA1", cFilial, aCompSA1[1], aCompSA1[2] , aCompSA1[3] )
    cFilSA6 := 	FWxFilial( "SA1", cFilial, aCompSA6[1], aCompSA6[2] , aCompSA6[3] )

	If  ( nPos := ASCAN(aRetorno, { |x| AllTrim(x[2][2]) == AllTrim(aLinha[DI_NSUTEF]) .AND. ;
									    AllTrim(x[3][2]) == AllTrim(DeParaArq(alinha[DI_TPPROD], "SE1")) .And. ;   
									    x[1][2] == alinha[DI_DTTEF] .And. ;
									    AllTrim(x[10][2]) == AllTrim(cFilial) } ) ) == 0
		
		If Select("TEMPDADOS") > 0
			TEMPDADOS->( DbCloseArea() )
		EndIf
	     
		#IFDEF TOP
	
			CONOUTR("FINA910B - DadosTit - QUERY - Busca titulo relacionado ao arquivo TEF. - Data: " + DToC(Date()) + " - Hora: " + TIME())
			
			
			cQry := " SELECT SE1.E1_PREFIXO, SE1.E1_NUM,E1_EMISSAO, SE1.E1_TIPO, E1_NSUTEF, SE1.E1_MSFIL," 
			cQry +=	 "SE1.E1_VENCREA, SE1.E1_LOJA, SE1.E1_VALOR, SE1.E1_CLIENTE, SE1.E1_FILIAL, SE1.E1_SALDO," 
			cQry += " SA1.A1_COD, SA1.A1_NOME, SA1.A1_LOJA, SA1.A1_BCO1, "
			cQry += " SA6.A6_COD, SA6.A6_AGENCIA, SA6.A6_NUMCON "
			  	
			cQry +=	" FROM " + RetSQLName("SE1") + " SE1 " 
	  
			cQry +=	" INNER JOIN " + RetSQLName("SA1") + " SA1 ON ( "
			
		   //	If lExcluSA1  //SA1 Exclusivo                              
				cQry +=	"SA1.A1_FILIAL = '" +cFilSA1 + "' AND "
		   //	Else		  //SA1 Compartilhado
		   //		cQry +=	"SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND " 
		   //	EndIf
			
			cQry += "SA1.A1_COD    = SE1.E1_CLIENTE AND " 
			cQry += "SA1.A1_LOJA   = SE1.E1_LOJA AND "
			CqRY += "SA1.D_E_L_E_T_ = ' ' ) "
			cQry +=	"INNER JOIN " + RetSqlName("SA6") + " SA6 ON ("
			
		   //	If lExcluSA6	//SA6 Exclusivo
				cQry += "SA6.A6_FILIAL = '" + cFilSA6 + "' AND "
		   //	Else			//SA6 Compartilhado
		   //		cQry += "SA6.A6_FILIAL = '" + xFilial("SA6") + "' AND "				
		   //	EndIf
			
			cQry += "SA6.A6_COD	  = SA1.A1_BCO1 AND "
			cQry += "SA6.D_E_L_E_T_ = ' '"  
			cQry +=	")" 
			
			
			cQry += " WHERE  E1_NSUTEF = '"+ AllTrim(aLinha[DI_NSUTEF]) +"' AND "
			

			cQry += " E1_EMISSAO=  '" +AllTrim(aLinha[DI_DTTEF])+ "' AND "		
                          
		  	
		   	cQry += " E1_TIPO = '"+ DeParaArq(aLinha[DI_TPPROD],"SE1") +"' AND  "
		   	cQry += " E1_MSFIL = '"+ A910MsFil(aLinha[DI_CODLOJ]) +"' AND "
		   	cQry += " SE1.D_E_L_E_T_ = ' '"		
					
			cQry := ChangeQuery(cQry)
			
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TEMPDADOS",.F.,.T.) 		
			
			If !TEMPDADOS->(Eof()) 					
				aAdd(aRetorno, {	{"E1_EMISSAO"	,TEMPDADOS->E1_EMISSAO			,Nil},;
									{"E1_NSUTEF"	,TEMPDADOS->E1_NSUTEF			,Nil},; 
									{"E1_TIPO"		,TEMPDADOS->E1_TIPO				,Nil},;
									{"A1_COD"		,TEMPDADOS->A1_COD				,Nil},;
									{"A1_NOME"		,TEMPDADOS->A1_NOME				,Nil},;
									{"A1_LOJA"		,TEMPDADOS->A1_LOJA				,Nil},;
									{"A6_COD"		,TEMPDADOS->A6_COD				,Nil},;
									{"A6_AGENCIA"	,TEMPDADOS->A6_AGENCIA			,Nil},;
									{"A6_NUMCON"	,TEMPDADOS->A6_NUMCON			,Nil},;
									{"E1_FILIAL"	,TEMPDADOS->E1_MSFIL			,Nil},;
									 })
				nPos := Len(aRetorno)                                                       
			Else				
				aAdd(aRetorno, {	{"E1_EMISSAO"	,alinha[DI_DTTEF]						,Nil},;
									{"E1_NSUTEF"	,AllTrim(aLinha[DI_NSUTEF])				,Nil},; 
									{"E1_TIPO"		,DeParaArq(alinha[DI_TPPROD],"SE1")		,Nil},;
									{"A1_COD"		,										,Nil},;
									{"A1_NOME"		,										,Nil},;
									{"A1_LOJA"		,			   							,Nil},;
									{"A6_COD"		,										,Nil},;
									{"A6_AGENCIA"	,										,Nil},;
									{"A6_NUMCON"	,		   								,Nil},;
									{"E1_FILIAL"	,AllTrim(cFilial)	,Nil},;
									})
				nPos := Len(aRetorno)	     
			EndIf
		#EndIf
	EndIf

Return nPos
                               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA910B  ºAutor  ³Microsiga           º Data ³  11/23/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Objetivo de retornar dados especifico da tabela SE1 e ZX3 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function DeParaArq(cCampo,cTab)

Local cTPTit  := ""

cCampo	:= AllTrim(cCampo)

If Upper(cTab) == "SE1"   //De Arquivo Para SE1   
	If cCampo $ "1;2;3"   	
		cTPTit := "CC"    //Cartao Credito
	ElseIf cCampo $ "4;5;6;7"  
		cTPTit := "CD"   //Cartao Debito
	EndIf               
ElseIf Upper(cTab) == "ZX3" //De Arquivo para ZX3
	If cCampo $ "1;2;3"   	
		cTPTit := "C"    //Cartao Credito
	ElseIf cCampo $ "4;5;6;7"  
		cTPTit := "D"   //Cartao Debito
	EndIf
EndIf


Return(cTPTit)


/*
Função.........: ConvParc
Objetivo.......: Converter campo parcela em formato Alfabetico
Autor..........: Leandro Brito
Data...........: 28/05/2018
*/                         
*---------------------------------*
Static Function ConvParc( cParc )
*---------------------------------*
Local cRet := ""

If Val( cParc ) > 0 
	cRet := Chr( 64 + Val( cParc ) )  
EndIf                                          

Return( cRet )