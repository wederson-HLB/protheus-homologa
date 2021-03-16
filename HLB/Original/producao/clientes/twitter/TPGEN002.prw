#INCLUDE "SPEDNFE.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : TPGEN002
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de integração
Autor       : Matheus Massarotto
Data/Hora   : 01/08/2016
*/
*----------------------*
User Function TPGEN002()
*----------------------*
//Variaveis locais.
Local i

//Controle Global no Fonte para saber qual a integração esta sendo gravada
Private nNATAtu := 0
Private cArqAtu := ""

//Verifica se a chamada foi de JOB ou não
Private lJob := (Select("SX3") <= 0)

//Parametros do FTP  //MSM - 07/04/2015 - Alterado para não trazer o ftp da produção quando não existir nos parâmetros

Private cPath 	:= ""//GETMV("MV_P_FTP") //GETMV("MV_P_FTP",,"192.168.201.2")
Private clogin	:= ""//GETMV("MV_P_USR") //GETMV("MV_P_USR",,"gt_twitter")
Private cPass	:= ""//GETMV("MV_P_PSW") //GETMV("MV_P_PSW",,"gt_twitter")

//Diretorios no FTP do cliente
Private cDirFtpIn := "/inbound"
Private cDirFtpout:= "/outbound"

//Diretorio no Servido Protheus
Private cDirSrvIn := "\FTP\"+cEmpAnt+"\TPGEN002\IN"
Private cDirSrvOut := "\FTP\"+cEmpAnt+"\TPGEN002\OUT"

//Parametros Iniciais dos Filtros de tela
Private cPar01 := ""
Private cPar02 := ""
Private cPar03 := ""
Private cPar04 := ""
Private cPar05 := ""
Private cPar06 := ""
Private cPar07 := ""
Private cPar08 := ""
Private nPar01 := 1

//Delimitador utilizado nos arquivos CSV.
Private cDelimitador := "|"

Private cStatPaid	:= "PAID"
Private cStatNoPaid	:= "NOT_PAID"
Private cTESPed		:= "6C8"

//Criação da referencia da integração com o Nome de Arquivo.
/*Private aRefArq:= {	{'01','BR_CUSTOMER_OB_'		,{|| GravaSA1() },"IN"},;
					{'02','BR_SALESORDER_OB_'	,{|| GravaSC5() },"IN"},;
					{'03','BR_CAMPAIGNS_OB_'	,{|| GravaZX1() },"IN"},;
					{'04','BR_INVOICE_IB_'		,{|| GravaSF2() },"OUT"},;
					{'05','BR_RECEIPTS_IB_'		,{|| GravaSE1() },"OUT"},;
					{'06','BR_INVOICE_IB_LOG_'	,{|| GrvLOGSF2()},"LOG"},;
					{'07','BR_INVOICE_IB_LOG_'	,{|| GrvLOGSE1()},"LOG"}}       
*/ 

Private aRefArq:= {	{'02','BR_INVOICE_CUSTOMER_OB_'	,{|| GravaSC5() },"IN"},;
					{'03','BR_CAMPAIGN_OB_'			,{|| GravaZX3() },"IN"}} 

//Tipo de arquivo ZIP.
Private cExtZip := "ZIP"

//Controle de Alteração na Rotina.
Private lonlyView	:= .F.

//Controle de Status e Check de tela
Private oSelS	:= LoadBitmap( nil, "LBOK")
Private oSelN	:= LoadBitmap( nil, "LBNO") 
Private oStsok	:= LoadBitmap( nil, "BR_VERDE")
Private oStsAl	:= LoadBitmap( nil, "BR_LARANJA")
Private oStsEr	:= LoadBitmap( nil, "BR_VERMELHO")
Private oStsBr	:= LoadBitmap( nil, "BR_BRANCO")
Private oStsIn	:= LoadBitmap( nil, "BR_PRETO")


Private cTabTemp	:= "##_TPGEN002"

Private cLogNota	:= ""

//Criação dos arrays dos dados das integrações e Dos logs de erros
For i:=1 to Len(aRefArq)
	&("a"+aRefArq[i][1]) := {}
	&("aLog"+aRefArq[i][1]) := {}
Next i

//Ajusta os diretorios no server protheus
If !lonlyView .and. !AtuDirServer()
	Return .F.
EndIf

//Busca os arquivos no Servidor FTP e coloca na pasta
//ManuArqFTP("GET")

if !lJob
	Processa({|| MainGT() },"Processando aguarde...")
endif

Return .T.

*----------------------*
Static Function MainGT()
*----------------------*
Local i
Private oDlg
Private oLayer		:= FWLayer():new()
Private aSize		:= MsAdvSize()

Private aLegenda	:= {{"BR_BRANCO"	,"Integração Disponivel."},;
						{"BR_PRETO"		,"Integração Inativa."}}
			   	  	
Private aLegenda2	:= {{"BR_VERDE"  	,"Integração Disponivel."},;
						{"BR_VERMELHO"	,"Integração Indisponivel."}}

Private aLegenda3 := {{"BR_VERDE"  		,"Recebido retorno."},;
						{"BR_VERMELHO"	,"Recebido Retorno com Erro."},;
						{"BR_BRANCO"	,"Aguardando Retorno."}}
						
//Criação da tela principal da integração
oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',25,.F.,'1')
oLayer:addCollumn('2',75,.F.,'1')

oLayer:addWindow('1','Win11','Menu'					,015,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('1','Win12','Tipos de Integrações'	,045,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('1','Win13','Log'		   			,040,.F.,.T.,{|| },'1',{|| })

oLayer:addWindow('2','Win21','Vizualização'			,100,.F.,.T.,{|| },'1',{|| })


oWin11 := oLayer:getWinPanel('1','Win11','1')
oWin12 := oLayer:getWinPanel('1','Win12','1')
oWin13 := oLayer:getWinPanel('1','Win13','1')

oWin21 := oLayer:getWinPanel('2','Win21','1')

//Menu -----------------------------------------------------------------------------
oBtn1 := TBtnBmp2():New(02,0010,26,26,'FINAL'   	   	,,,,{|| oDlg:end()}											, oWin11,"Sair"	   		,,.T.)
If !lonlyView
	oBtn2 := TBtnBmp2():New(02,180,26,26,'PMSSETABOT'  	,,,,{|| /*ManuArqFTP("GET")*/}								, oWin11,"Download"		,,.T.)
	oBtn3 := TBtnBmp2():New(02,210,26,26,'PMSSETATOP'	,,,,{|| /*ManuArqFTP("PUT")*/}								, oWin11,"Upload"		,,.T.)
	oBtn4 := TBtnBmp2():New(02,240,26,26,'TK_REFRESH'   ,,,,{|| loadInt()}											, oWin11,"Carregar Arq"	,,.T.)
	oBtn5 := TBtnBmp2():New(02,270,26,26,'RPMSAVE'  	,,,,{|| Processa({|| SaveInt() },"Processando aguarde...")}	, oWin11,"Salvar Arq"	,,.T.)
	
	oBtn3 := TBtnBmp2():New(02,150,26,26,'FOLDER6'	,,,,{|| upArqServ()}										, oWin11,"Up Serv Arq"	,,.T.)
EndIf

//Tipos de Integrações -------------------------------------------------------------
aHeader := {}
aCols	:= {}
AADD(aHeader,{ TRIM("Sts.")			,"STS","@BMP",02,0,"","","C","",""})
AADD(aHeader,{ TRIM("Integração")	,"DES","@!  ",20,0,"","","C","",""})

aAlter	:= {"STS"}

aAdd(aCols, {oStsBr,"01. SMB Order"		,.F.})
aAdd(aCols, {oStsBr,"02. Campanha" 			,.F.})

oGetDados := MsNewGetDados():New(01,01,(oWin12:NHEIGHT/2)-2,(oWin12:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAlter,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin12,aHeader, aCols, {|| MudaLinha()})

oGetDados:AddAction("STS", {|| BrwLegenda("Tipos de Integrações", "Legenda", aLegenda),;
							oGetDados:Obrowse:ColPos -= 1,;
							oGetDados:aCols[oGetDados:Obrowse:nAt][oGetDados:Obrowse:ColPos+1] })

oGetDados:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetDados:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetDados:ForceRefresh()

//Log ------------------------------------------------------------------

aHLog := GetCodInt("LOG")
aCLog	:= {}
aALog	:= {}

oGetLog := MsNewGetDados():New(01,01,(oWin13:NHEIGHT/2)-2,(oWin13:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aALog,,9999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin13,aHLog, aCLog, {|| })
oGetLog:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetLog:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetLog:ForceRefresh()



//Vizualização -------------------------------------------------------------
For i:=1 to Len(aRefArq)
	&("aHArq"+aRefArq[i][1]) := {}
	&("aCArq"+aRefArq[i][1]) := {}
	&("aAArq"+aRefArq[i][1]) := {}

	&("aHArq"+aRefArq[i][1]) := GetCodInt(aRefArq[i][1])

	//Inicia aCols com linha em branco
	aAdd(&("aCArq"+aRefArq[i][1]),Array(Len(&("aHArq"+aRefArq[i][1]))+1))
	&("aCArq"+aRefArq[i][1])[1][LEN(&("aCArq"+aRefArq[i][1])[1])] := .F.

	&("oArq"+aRefArq[i][1]):=MsNewGetDados():New(01,02,(oWin21:NHEIGHT/2)-2,(oWin21:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
										"", &("aAArq"+aRefArq[i][1]),,9999999, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()",;
										oWin21,&("aHArq"+aRefArq[i][1]), &("aCArq"+aRefArq[i][1]) )
	
	&("oArq"+aRefArq[i][1]):LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
	&("oArq"+aRefArq[i][1]):LEDITLINE		:= .F.//Não abre edição quando clicar na linha.

	&("oArq"+aRefArq[i][1]):OBROWSE:LVISIBLECONTROL := .F.
	&("oArq"+aRefArq[i][1]):ForceRefresh()

	cArqView := ""
	oArqView := tMultiget():New(01,(((oWin21:NRIGHT/2))/4)+2,{|u|if(Pcount()>0,cArqView:=u,cArqView)},;
				oWin21,(oWin21:NRIGHT/2)-2,(oWin21:NHEIGHT/2)-2,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
	oArqView:LVISIBLECONTROL := .F.

Next i

oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao      : GetCodInt()
Parametros  : 
Retorno     : 
Objetivos   : Função para retornar a configuração de cada Integração.
Autor       : Jean Victor Rocha
Data/Hora   : 06/10/2014
*/
*-------------------------------------------*
Static Function GetCodInt(cTipoInt,lGetaCpos)
*-------------------------------------------*
Local i
Local aCpos := {}
Local aRet := {}

Default lGetaCpos := .F.

Do Case
	Case cTipoInt == '02'

		AADD(aRet,{ "Invoice ID","M_F2_DOC","",13,0,"","","C","",""})      

		aCpos := {'F2_EMISSAO','F2_VALBRUT','F2_P_DTINI','F2_P_DTFIM','F2_P_STATC','F2_P_DATAC','F2_P_HORAC','A1_P_ID','F2_P_IDC','A1_P_ACC','A1_END','M_A1_END1',;
					'A1_MUN','A1_EST','A1_PAIS','A1_CEP','A1_NOME','M_A1_NOME1'}
		
		For i:=1 to Len(aCpos)
			SX3->(DbSetOrder(2))
			if SX3->(DbSeek(aCpos[i]))
				if aCpos[i]=="F2_VALBRUT"
					AADD(aRet,{ "Service_Amount","M_F2_TOTAL",;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
				else
					AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
				endif
			elseif SX3->(DbSeek( SUBSTRING(aCpos[i],3,LEN(aCpos[i])-4)))
					AADD(aRet,{ TRIM(SX3->X3_TITULO)+"1","M_"+alltrim(SX3->X3_CAMPO)+"1",;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})			
			else
				AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
			endif
		Next i
		AADD(aRet,{ "Arquivo","ARQ_ORI","",40,0,"","","C","",""})
		
	Case cTipoInt == '03'
		aCpos := {'ZX3_DOC','ZX3_PROD','ZX3_ID','ZX3_NAMEF','ZX3_VALOR','ZX3_EMISSA'}
		
		For i:=1 to Len(aCpos)
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aCpos[i]))
			
				if aCpos[i]=="ZX3_EMISSA"
					AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+"ZX3_EMISSAO",;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
				else
					AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
								/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
				endif
			Else
				AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
			EndIf
		Next i
		AADD(aRet,{ "Arquivo","ARQ_ORI","",40,0,"","","C","",""})

	Case cTipoInt == 'LOG'
		aCpos := {"ZX4_COD","ZX4_DATA","ZX4_HORA","ZX4_ARQ","ZX4_USER"}
		For i:=1 to Len(aCpos)
			SX3->(DbSetOrder(2))
			If SX3->(DbSeek(aCpos[i]))
				AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
								SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
			Else
				AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
			EndIf
		Next i	

EndCase

If lGetaCpos
	aRet := aCpos
EndIf

Return aRet


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
Local aCposLog := GetCodInt("LOG",.T.)

//Atualiza a Visualizações
oArqView:LVISIBLECONTROL := .F.

//Troca o Browse de arquivos ---------------------------------
For i:=1 to len(aRefArq)
	&("oArq"+aRefArq[i][1]):OBROWSE:LVISIBLECONTROL := .F.
Next i
&("oArq"+aRefArq[oGetDados:NAT][1]):OBROWSE:LVISIBLECONTROL := .T.

//Atualiza o Browse de Log de arquivos
oGetLog:ACOLS := {}

ZX4->(DbSetOrder(2))
If ZX4->(DbSeek(xFilial("ZX4")+aRefArq[oGetDados:NAT][2],.T.))
	While ZX4->(!EOF()) .and. AT(aRefArq[oGetDados:NAT][2],ZX4->ZX4_ARQ) <> 0
		aAux := {}
		For i:=1 to Len(aCposLog)
			If ZX4->(FieldPos(aCposLog[i])) <> 0
				aAdd(aAux, &("ZX4->"+aCposLog[i]) )
			EndIf
		Next i
		aAdd(aAux,.F.)
		aAdd(oGetLog:ACOLS,aAux)

		ZX4->(DbSkip())
	EndDo
EndIf
oGetLog:FORCEREFRESH()

Return .T.

/*
Funcao      : ManuArqFTP()  
Parametros  : cOpc *
Retorno     : Nil
Objetivos   : Função responsavel por manipular os arquivos no FTP.
Autor       : Jean Victor Rocha
Data/Hora   : 
* ATENÇÃO:
Get - Efetua o Download dos arquivos do FTP	; ou seja, Pegamos na Pasta de saida do Cliente e colocamos na Nossa pasta de entrada.
Put - Efetua o Upload dos arquivos no FTP	; ou seja, Pegamos na nossa Pasta de Saida e colocamos na pasta de entrada do cliente.
*/
*------------------------------*
Static Function ManuArqFTP(cOpc)
*------------------------------*

Local i
Local cDirFtpAtu	:= ""
Local cDirSrvAtu	:= ""
Local lConnect		:= .F.
Local aArqFTP		:= {}

Local aArqServer	:= DIRECTORY(cDirFtpIn+"\*.CSV" , ) 

//Conexao com o FTP informado nos paramentros.
For i:=1 to 3// Tenta 3 vezes.
	lConnect := ConectaFTP()
	If lConnect
 		i:=3
   	EndIf
Next
If !lConnect
	If lJob
   		Conout("TPGEN002 - Não foi possivel estabelecer conexão com FTP!")		
	Else
		MsgAlert("Não foi possivel estabelecer conexão com FTP.","HLB BRASIL")
	EndIf
 	Return .F.
EndIf   

//Definição do Tipo de atualização que sera feita. (Upload ou Download)
Do Case
	Case cOpc == "GET"
		cDirFtpAtu	:= cDirFtpOut
		cDirSrvAtu	:= cDirSrvIn
		
	Case cOpc == "PUT"
		cDirFtpAtu	:= cDirFtpIn
		cDirSrvAtu	:= cDirSrvOut

EndCase          

//Monta o diretório do FTP.
FTPDirChange(cDirFtpAtu)

//Carregar os arquivos que estão no FTP
aArqFTP := FTPDIRECTORY("*.*",) 

//Carrega arquivos do Servidor Protheus
aArqServer	:= DIRECTORY(cDirSrvAtu+"\*.CSV",)

Do Case
	Case cOpc == "GET"
		//Compata arquivos atuais na pasta somente se tiver um novo no FTP.
		If Len(aArqFTP) <> 0
			For i:=1 to Len(aArqServer)
				If aScan(aArqFTP, {|x| LEFT(x[1],LEN(SUBSTR(aArqServer[i][1],1,AT("OB_",aArqServer[i][1])+2)))==;
																 SUBSTR(aArqServer[i][1],1,AT("OB_",aArqServer[i][1])+2) }) <> 0
					compacta(cDirSrvAtu+"\"+aArqServer[i][1],cDirSrvAtu+"\BKP_"+STRZERO(Year(Date()),4)+STRZERO(Month(Date()),2)+"."+cExtZip)
				EndIf
			Next i
		EndIf

		//Efetua o Download do Arquivo do FTP para o Server.
		For i:=1 to Len(aArqFTP)
			FTPDownLoad(cDirSrvAtu+"\"+aArqFTP[i][1],aArqFTP[i][1])
			FTPErase(aArqFTP[i][1])
		Next i

	Case cOpc == "PUT"
		//Efetua o Upload do Arquivo do Server para o FTP.
		For i:=1 to Len(aArqServer)
			If RIGHT(aArqServer[i][1],3) <> cExtZip
				FTPUpload(cDirSrvAtu+"\"+aArqServer[i][1],aArqServer[i][1])
				FTPRenameFile(aArqServer[i][1],UPPER(LEFT(aArqServer[i][1],LEN(aArqServer[i][1])-3) )+LOWER(RIGHT(aArqServer[i][1],3)) )
				compacta(cDirSrvAtu+"\"+aArqServer[i][1],cDirSrvAtu+"\BKP_"+STRZERO(Year(Date()),4)+STRZERO(Month(Date()),2)+"."+cExtZip)
			EndIf
		Next i

EndCase

//Encerra conexão com FTP
FTPDisconnect()

Return .T.

/*
Funcao      : ConectaFTP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para conectar no FTP
Autor       : Jean Victor Rocha
Data/Hora   : 
Obs         :
*/          
*--------------------------*
Static Function ConectaFTP()
*--------------------------*
Local lRet		:= .F.

cPath  := Alltrim(cPath)
cLogin := Alltrim(cLogin)
cPass  := Alltrim(cPass) 

// Conecta no FTP
lRet := FTPConnect(cPath,,cLogin,cPass) 
   
Return (lRet)

/*
Funcao      : AtuDirServer
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para Ajustar os diretorios no server protheus
Autor       : Jean Victor Rocha
Data/Hora   : 
Obs         :
*/          
*----------------------------*
Static Function AtuDirServer()
*----------------------------*
Local i
Local lRet		:= .T.
Local cAux		:= ""
Local cAux2		:= ""
Local cDirSrv	:= ""

//Ajusta o Diretorio de Entrada e Saida no Protheus
For i:=1 to 2
	If i == 1
		cDirSrv := cDirSrvIn
	Else 
		cDirSrv := cDirSrvOut
	EndIf

	If !ExistDir(cDirSrv)
		cAux := ALLTRIM(cDirSrv)
		cAux := Left(cDirSrv,AT("\",RIGHT(cDirSrv,LEN(cDirSrv)-1)))
		While cAux <>  cDirSrv
			If !ExistDir(cAux)
				MakeDir(cAux)
			EndIf
			cAux2:= SUBSTR(cDirSrv,LEN(cAux)+1,Len(cDirSrv))
			cAux += Left(cAux2,IF(AT("\",RIGHT(cAux2,LEN(cAux2)-1))==0,LEN(cAux2),AT("\",RIGHT(cAux2,LEN(cAux2)-1)))  )
		EndDo
		If !ExistDir(cAux)
			MakeDir(cAux)
		EndIf
	EndIf
Next i

If !ExistDir(cDirSrvIn) .and. !ExistDir(cDirSrvOut)
	If lJob
		Conout("TPGEN002 - Falha ao carregar diretórios FTP no Servidor!")
	Else
		MsgInfo("Falha ao carregar diretórios FTP no Servidor!","HLB BRASIL")
	EndIf
	lRet := .F.
EndIf

Return lRet

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------------*
Static Function compacta(cArquivo,cArqRar,lApagaOri)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

Default lApagaOri := .T.

If lApagaOri
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Else
	cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe a -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
EndIf
lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : LoadInt
Parametros  : 
Retorno     :
Objetivos   : Função para Carregar uma nova integração.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------*
Static Function LoadInt()
*-----------------------*
Local i,j
Local nPos := 0
Local aArquivo := {}
Local cLinha := ""
Local cDirSrvAtu := cDirSrvIn
Local aArqServer := {}
Local cTipoInt := ""

Local oFT   := fT():New()//FUNCAO GENERICA

//Executa a limpeza da variavel com os dados e da tela, caso não for Job.
For i:=1 to Len(aRefArq)
	&("a"+aRefArq[i][1]) := {}
	&("oArq"+aRefArq[i][1]):ACOLS := {}
	aAdd(&("aCArq"+aRefArq[i][1]),Array(Len(&("aHArq"+aRefArq[i][1]))+1))
	&("aCArq"+aRefArq[i][1])[1][LEN(&("aCArq"+aRefArq[i][1])[1])] := .F.
	&("oArq"+aRefArq[i][1]):ForceRefresh()
Next i

//Carrega arquivos do Servidor Protheus
aArqServer	:= DIRECTORY(cDirSrvAtu+"\*.CSV",)

//Carrega as Infromações do Arquivo.
If lJob
	cTipoInt := "IN"
Else
	cTipoInt := aRefArq[oGetDados:NAT][4]
EndIf

For i:=1 to len(aArqServer)
	aArquivo := {}

	//Leitura do arquivo de tratamento.
	oFT:FT_FUse(cDirSrvAtu+"\"+aArqServer[i][1])
	While !oFT:FT_FEof()
		cLinha := oFT:FT_FReadln()
		If AT(cDelimitador,cLinha) <> 0
			aAdd(aArquivo, separa(UPPER(cLinha),cDelimitador))// Sepera para vetor e adiciona no array de arquivo.
		EndIf                          
		aAdd(aArquivo[Len(aArquivo)],aArqServer[i][1])
        oFT:FT_FSkip() // Proxima linha
	Enddo
	oFT:FT_FUse() // Fecha o arquivo 

	//Carrega as Informações da Variavel de destino
	If (nPos := aScan(aRefArq, {|x| ALLTRIM(x[2]) == ALLTRIM(SUBSTR(aArqServer[i][1],1,AT("OB_",aArqServer[i][1])+2)) } )  ) <> 0
		If LEN(&("a"+aRefArq[nPos][1])) == 0
			&("a"+aRefArq[nPos][1]) := aArquivo
		Else
			If LEN(aArquivo) > 2
				For j:=3 to Len(aArquivo)
					aAdd(&("a"+aRefArq[nPos][1]),aArquivo[j])
				Next j
			EndIf
		EndIf
	EndIf
Next i
//Caso não for Job, carrega para a tela os dados.
If !lJob
	//Executa para cada Integração
	For i:=1 to len(aRefArq)
		//Executa somente se tiver dados no array
		//If LEN(&("a"+aRefArq[i][1])) <> 0
			//Verifica se existe quantidade de linhas maior que somente os Titulos dos campos.
			If Len(&("a"+aRefArq[i][1])) >= 3
				//Reseta os dados da Tela, ACOLS.
				&("oArq"+aRefArq[i][1]):ACOLS := {}

				//Executa para cada linha do arquivo, iniciando o For nos dados
				For j:=3 to len(&("a"+aRefArq[i][1]))
					//Adiciona uma nova linha no Acols.
					aAdd(&("oArq"+aRefArq[i][1]):ACOLS,Array(Len(&("aHArq"+aRefArq[i][1]))+1))
   					&("oArq"+aRefArq[i][1]):ACOLS[LEN(&("oArq"+aRefArq[i][1]):ACOLS)][LEN(&("oArq"+aRefArq[i][1]):ACOLS[1])] := .F.
					
					//Executa para cada campo enviado no arquivo.
					For h:=1 to len(&("a"+aRefArq[i][1])[2])
						//Caso o campo informado no arquivo exista na tela, preenche, caso contrario não.
						If (nPos := aScan(&("aHArq"+aRefArq[i][1]), {|x| ALLTRIM(x[2]) == ALLTRIM("WK"+&("a"+aRefArq[i][1])[2][h]) })   ) <> 0 ;
							.OR. (nPos := aScan(&("aHArq"+aRefArq[i][1]), {|x| ALLTRIM(x[2]) == ALLTRIM("M_"+&("a"+aRefArq[i][1])[2][h]) })   ) <> 0
							&("oArq"+aRefArq[i][1]):ACOLS[LEN(&("oArq"+aRefArq[i][1]):ACOLS)][nPos] := &("a"+aRefArq[i][1])[j][h]
						EndIf
					Next h
					If aScan(&("aHArq"+aRefArq[i][1]),{|x|x[2]=="ARQ_ORI" }) <> 0
						&("oArq"+aRefArq[i][1]):ACOLS[LEN(&("oArq"+aRefArq[i][1]):ACOLS)][aScan(&("aHArq"+aRefArq[i][1]),{|x|x[2]=="ARQ_ORI" })] := &("a"+aRefArq[i][1])[j][LEN(&("a"+aRefArq[i][1])[j])]
					EndIf
				Next j
			EndIf
		//EndIf
		&("oArq"+aRefArq[i][1]):ForceRefresh()
	Next i
EndIf

Return .T.

/*
Funcao      : SaveInt
Parametros  : 
Retorno     :
Objetivos   : Função para Carregar uma nova integração.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------*
Static Function SaveInt()
*-----------------------*
Local i,j
Local cTipoInt 	:= "IN"
Local cMsgPerg 	:= ""
Local aArquivos := {}

Private aArqLog	:= {}

//Zera os arquivos de LOG.
NewCabLog()

//Controla o Tipo de Integração que sera realizada
If !lJob
	cTipoInt := aRefArq[oGetDados:NAT][4]
EndIf

//Verifica se o usuario tem certeza de gravar todos os arquivos.
If cTipoInt == "IN"  
	cMsgPerg := "Será importado os arquivos de Pedidos de Vendas e Campanhas, Deseja Continuar?"
Else
	cMsgPerg := "Será processado o arquivo exibido em Tela apenas para os registros selecionados, Deseja Continuar?"
EndIf

If !lJob .And. !MsgYesNo(cMsgPerg,"HLB BRASIL")
	Return .F.
EndIf

//Zera controle Global da posição
nNATAtu := 0

//Define a Barra de Processamento
ProcRegua(LEN(aRefArq))

//Grava os Dados de Integração.
If lJob
	For i:=1 to len(aRefArq)
		If aRefArq[i][4] == "IN"
			//Executa somente se tiver dados no array
			If LEN(&("a"+aRefArq[i][1])) <> 0
				If Len(&("a"+aRefArq[i][1])[2]) >= 3
					If !ViewZX4(&("a"+aRefArq[i][1])[1])
						nNATAtu := i
						Eval(aRefArq[i][3])
					EndIf
				EndIf
			EndIf
		EndIf
		IncProc("Aguarde...")
	Next i
Else
	cMsgProc := ""
	If cTipoInt == "IN"
		For i:=1 to len(aRefArq)
			If aRefArq[i][4] == cTipoInt
				cArqAtu := ""
				If Len(&("a"+aRefArq[i][1])) >= 3
			   		cMsgProc += SUBSTR(aRefArq[i][2],4,AT("OB",aRefArq[i][2])-5)+CHR(10)+CHR(13)
					aArquivos := GetNameArq(&("a"+aRefArq[i][1]),.F.)
					For j:=1 to Len(aArquivos)
						If ViewZX4(aArquivos[j])
							cMsgProc += " - "+ALLTRIM(aArquivos[j])+" - Arquivo ja processado anteriormente!"+CHR(10)+CHR(13)
						Else
							nNATAtu := i
							cArqAtu := ALLTRIM(aArquivos[j])
							Eval(aRefArq[i][3])
							cMsgProc += " - "+ALLTRIM(aArquivos[j])+" - Arquivo processado com sucesso!"+CHR(10)+CHR(13)
						EndIf
					Next j
				Else
					cMsgProc += SUBSTR(aRefArq[i][2],4,AT("OB",aRefArq[i][2])-5)+CHR(10)+CHR(13)
					cMsgProc += " - Sem dados a serem salvos para esta integração!"+CHR(10)+CHR(13)
				EndIf
			EndIf
			IncProc("Aguarde...")
		Next i
		
		//Gera Arquivo LOG fisico.
		For i:=1 to len(aRefArq)
			//Executa somente se tiver dados no array
			If LEN(&("aLog"+aRefArq[i][1])) > 2
				GeraLog(&("aLog"+aRefArq[i][1]) )
			EndIf
		Next i
		
		//RRP - 17/05/2017 - Envio de email do Log.
		MailLog()

	EndIf
    
	//ManuArqFTP("GET") 
	//ManuArqFTP("PUT") 
    
	EECVIEW("Processamento Finalizado"+CHR(10)+CHR(13)+cMsgProc+CRLF+"Notas Fiscais:"+CRLF+cLogNota)
	//MsgInfo(cMsgProc,"HLB BRASIL")
EndIf

Return .T. 

/*
Funcao      : GeraLog
Parametros  : 
Retorno     :
Objetivos   : Função para a geração do arquivo de LOG na pasta Out do FTP no SERVER.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function GeraLog(aInfo)
*----------------------------*
Local i,j,k
Local nHdl	:= 0
Local cLinha := ""
Local cArqLog := ""

Local aArquivos := GetNameArq(aInfo)

For k:=1 to Len(aArquivos)
	//Criação do nome do arquivo de LOG referente ao Arquivo.
	cArqLog := ""
	cArqLog += SUBSTR(aArquivos[k],1,AT("OB_",aArquivos[k])+2)
	cArqLog += "LOG"
	cArqLog += SubStr(aArquivos[k],AT("OB_",aArquivos[k])+2,Len(aArquivos[k]))
	cArqLog := UPPER(cArqLog)
	AADD(aArqLog,cArqLog)
	
	//Validação de arquivo não existente
	If File(cDirSrvOut+"\"+cArqLog)
		FErase(cDirSrvOut+"\"+cArqLog)
	EndIf
	
	nHdl := FCreate(cDirSrvOut+"\"+cArqLog,0 )
	cLinha := ""
	For j:=1 to Len(aInfo[1])
		cLinha += ALLTRIM(aInfo[1][j])+cDelimitador
	Next j
	cLinha := LEFT(cLinha,Len(cLinha)-1)
	FWrite(nHdl, cLinha+CHR(10))
	cLinha := ""
	For j:=1 to Len(aInfo[2])
		cLinha += ALLTRIM(aInfo[2][j])+cDelimitador
	Next j
	cLinha := LEFT(cLinha,Len(cLinha)-1)
	FWrite(nHdl, cLinha+CHR(10))
	
	For i:=3 to Len(aInfo)
		If ALLTRIM(aInfo[i][aScan(aInfo[2],{|x| ALLTRIM(UPPER(x)) == "FILE"})]) == ALLTRIM(aArquivos[k])
			cLinha := ""
			For j:=1 to Len(aInfo[i])
				cLinha += ALLTRIM(aInfo[i][j])+cDelimitador
			Next j
			cLinha := LEFT(cLinha,Len(cLinha)-1)
		
			FWrite(nHdl, cLinha+CHR(10))
		EndIf
	Next i
	FClose(nHdl)
	
	GrvTabLog(aArquivos[k] )

Next k
	
Return .T.

/*
Funcao      : GrvTabLog
Parametros  : 
Retorno     :
Objetivos   : Função para a gravação da tabela de LOG.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------------*
Static Function GrvTabLog(cNomeArq)
*---------------------------------*
ZX4->(DbSetOrder(1))
ZX4->(RecLock("ZX4",.T.))
ZX4->ZX4_FILIAL := xFilial("ZX4")
ZX4->ZX4_COD := STRZERO(ZX4->(Recno()),9)
ZX4->ZX4_ARQ := UPPER(cNomeArq)
ZX4->ZX4_DATA := Date()
ZX4->ZX4_HORA := Time()
ZX4->ZX4_USER := cUserName
ZX4->(MsUnlock())

//Move o arquivo processado para a pasta 'processado'
If File( cDirSrvIn+"\"+cNomeArq )
	__COPYFILE(cDirSrvIn+"\"+cNomeArq,cDirSrvIn+"\processado\"+cNomeArq)
	FErase( cDirSrvIn+"\"+cNomeArq ) 
EndIf

Return .T.

/*
Funcao      : ViewZX4
Parametros  : 
Retorno     :
Objetivos   : Verifica se o arquivo ja consta no Log de processados.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function ViewZX4(cArq)
*---------------------------*
Local lRet := .F.

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  

cQuery := " Select COUNT(*) AS COUNT"
cQuery += " From "+RETSQLNAME("ZX4")
cQuery += " Where ZX4_ARQ = '"+ALLTRIM(UPPER(cArq))+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet

/*
Funcao      : GravaSC5
Parametros  : 
Retorno     :
Objetivos   : Gravação dos Arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function GravaSC5()
*------------------------*
Local i

Local lErro			:= .F.
Local lCritErro		:= .F.

Local nPos			:= 0
Local nPos2			:= 0
Local nSeq 			:= 0

Local cChave 		:= ""

Local aDados		:= &("a"+aRefArq[nNATAtu][1])
Local aCposObrg		:= {'F2_DOC','F2_TOTAL','A1_P_ID','F2_EMISSAO','F2_P_DTINI','F2_P_DTFIM','F2_P_IDC','A1_NOME','A1_NOME1','F2_P_STATC','F2_P_DATAC','F2_P_HORAC'}
Local aCabPadrao	:= {'C5_NUM','C5_TIPO','C5_TIPOCLI','C5_CONDPAG','C5_EMISSAO','C5_MENNOTA','C5_P_REF','C5_CLIENTE','C5_LOJACLI'}
Local aItePadrao	:= {'C6_ITEM','C6_PRODUTO','C6_DESCRI','C6_QTDVEN','C6_PRCVEN','C6_VALOR','C6_TES','C6_LOCAL'}                                                                                         
Local aNotEmpty		:= {'F2_DOC','F2_TOTAL','A1_P_ID','F2_EMISSAO','F2_DTINI','F2_P_DTFIM','F2_P_IDC','A1_NOME','A1_NOME1','F2_P_STATC','F2_P_DATAC','F2_P_HORAC'}
Local aLog			:= &("aLog"+aRefArq[nNATAtu][1])

//Posição dos campos que compoem a chave do arquivo.
Local nPosF2_DOC		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "F2_DOC" })
Local nPosF2_P_STATC	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "F2_P_STATC" })
Local nPosF2_P_DATAC	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "F2_P_DATAC" })
Local nPosF2_P_HORAC	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "F2_P_HORAC" })
Local nPosF2_EMISSAO	:=  aScan(aDados[2], {|x| ALLTRIM(x) == "F2_EMISSAO" })
Local nPosF2_P_REF		:= 	aScan(aDados[2], {|x| ALLTRIM(x) == "F2_DOC" })
Local nPosF2_TOTAL		:= 	aScan(aDados[2], {|x| ALLTRIM(x) == "F2_TOTAL" })
Local nPosA1_PAIS 		:=	aScan(aDados[2], {|x| Upper(AllTrim(x)) == "A1_PAIS"})

//Variavel que ira possuir os dados de Capa e Itens
Local aCxI := {}
Local aCab := {}
Local aIte := {}
Local aCab2Ite := {}

Local aCxIAtrib := {}
Local nPosCxTr1 := 0
Local nPosCxTr2 := 0

Local aAux3		:= {}
Local cInsert	:= ""
Local cQry		:= ""
Local cPaisCli	:= ""

Private cCpsSC5SA1	:= ""
Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

cLogNota:=""

//Ajuste de campos para C5
For i:=1 to len(aDados[2])
	If alltrim(aDados[2][i])=="F2_DOC"
		aDados[2][i] := "C5_P_REF"
	Else
		aDados[2][i] := STRTRAN(aDados[2][i],"F2_","C5_")
	EndIf
Next i

  
if TEMPSQL(aDados[2])
	For i:=3 to len(aDados)

		cInsert	:= "" 
		For j:=1 to len(aDados[i])			
			If "A1_CEP" $ aDados[2][j]
				//RRP - 12/05/2017 - Tratamento para o CEP
				cPaisCli:= Alltrim(UPPER(aDados[i][nPosA1_PAIS]))
				//Caso o Pais seja Diferente de Brasil
				If cPaisCli <> 'BR'
					cDad:= ""
				Else
					cDad:=STRTRAN(Alltrim(aDados[i][j]),"-")
					//Campo CEP fora do padrão
					If  Len(Alltrim(cDad)) > TAMSX3(aDados[2][j])[1]
						cDad:= ""
					EndIf	
				EndIf				
				
			elseif "C5_EMISSAO" $ aDados[2][j] .OR. "C5_P_DT" $ aDados[2][j] .OR. "C5_P_DATA" $ aDados[2][j]
				cDad:=CTODBRA(alltrim(aDados[i][j]))
			else
				cDad:=alltrim(aDados[i][j])
			endif
			cInsert+="'"+alltrim(cDad)+"',"
            
			if ("S"+substring(aDados[2][j],1,2))->(FIELDPOS(aDados[2][j]))>0
				if len(alltrim(cDad)) > TAMSX3(aDados[2][j])[1] .AND. TAMSX3(aDados[2][j])[3]<>"D"  
					if nPosF2_EMISSAO <> 0 .and. nPosF2_DOC <> 0 
						aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,CTODBRA(aDados[i][nPosF2_EMISSAO]),""),;
									"",;
									IIF(nPosF2_DOC<>0,aDados[i][nPosF2_DOC],""),;
									"",;
									"",;
									aDados[1][j],;
									STRTRAN(aDados[2][j],"C5_","F2_"),;
									cDad,;
									"E","Value bigger than expected",aDados[i][Len(aDados[i])]})
					endif
                endif
            endif
		Next
   		
   		cInsert:=substring(cInsert,1,RAT(",",cInsert)-1) //retira a última virguta
		TCSQLEXEC("INSERT INTO "+cTabTemp+" VALUES("+cInsert+")" )
	Next
else
	MsgAlert("Não foi possível criar a estrutura da tabela "+cTabTemp+CRLF+TCSQLError(),"HLB BRASIL")	
	Return(.F.)
endif


if select("TRBTEMP")>0
	TRBTEMP->(DbCloseArea())
endif


//Query que busca as informações seguindo as regras: Trazer o primeiro doc que tiver pago, e depois o primeiro que tiver não pago de cada doc 
cQry+=" SELECT * 
cQry+=" FROM "+cTabTemp
cQry+=" WHERE "+aDados[2][nPosF2_DOC]+"+"+aDados[2][nPosF2_P_STATC]+"+"+aDados[2][nPosF2_P_DATAC]+"+"+aDados[2][nPosF2_P_HORAC]+" IN (
cQry+=" 	SELECT "+aDados[2][nPosF2_DOC]+"+"+aDados[2][nPosF2_P_STATC]+"+MIN("+aDados[2][nPosF2_P_DATAC]+"+"+aDados[2][nPosF2_P_HORAC]+") 
cQry+=" 	FROM "+cTabTemp
cQry+=" 	WHERE "+aDados[2][nPosF2_P_STATC]+"='"+cStatPaid+"'"
cQry+=" 	GROUP BY "+aDados[2][nPosF2_DOC]+","+aDados[2][nPosF2_P_STATC]

cQry+=" 	UNION ALL

cQry+=" 	SELECT "+aDados[2][nPosF2_DOC]+"+"+aDados[2][nPosF2_P_STATC]+"+MIN("+aDados[2][nPosF2_P_DATAC]+"+"+aDados[2][nPosF2_P_HORAC]+") 
cQry+=" 	FROM "+cTabTemp
cQry+=" 	WHERE "+aDados[2][nPosF2_P_STATC]+"='"+cStatNoPaid+"' 
cQry+=" 	AND "+aDados[2][nPosF2_DOC]+" NOT IN (SELECT "+aDados[2][nPosF2_DOC]+" FROM "+cTabTemp+" WHERE "+aDados[2][nPosF2_P_STATC]+"='"+cStatPaid+"')
cQry+=" 	GROUP BY "+aDados[2][nPosF2_DOC]+","+aDados[2][nPosF2_P_STATC]
cQry+=" )
cQry+=" ORDER BY "+aDados[2][nPosF2_DOC]

if TCSQLEXEC(cQry)<0
	MsgAlert("Não foi buscar as informações: "+	TCSQLError(),"HLB BRASIL")
	Return()
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBTEMP" ,.T.,.F.)

TRBTEMP->(DbGoTop())

aCpsQry		:= strtokarr(cCpsSC5SA1,",")
aNewDados	:= {}

AADD(aNewDados,aDados[1])
AADD(aNewDados,aDados[2])

While TRBTEMP->(!EOF())

	AADD(aNewDados,{})    

    for i:=1 to len(aCpsQry)
    	AADD(aNewDados[len(aNewDados)],&(TRBTEMP->(aCpsQry[i])))    
    next

	TRBTEMP->(DbSkip())
Enddo


nPosCpn	:= aScan(aRefArq,{|x| "BR_CAMPAIGN_" $ UPPER(ALLTRIM(x[2]))})
if nPosCpn > 0
	aAuxCamp:= &("a"+aRefArq[nPosCpn][1])
endif

nSeqArq:=0

//Executa a partir do primeiro registro com informação.
For i:=3 to len(aNewDados)
	//Reset de controles de erros
	lErro		:= .F.

	//Validações De estrutura
	For j:=1 to Len(aCposObrg)
		
		if alltrim(aCposObrg[j])=="F2_DOC"
			cCampo:= "C5_P_REF"
		else
			cCampo:= STRTRAN(aCposObrg[j],"F2_","C5_")
		endif
		
		If (nPos := aScan(aNewDados[2], {|x| ALLTRIM(x) == ALLTRIM(cCampo) })   ) == 0
			lCritErro := .T.
			aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
						"",;
						IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
						"",;
						"","",aCposObrg[j],"","E","Critical Error - Field not Exist",aNewDados[i][Len(aNewDados[i])]})
		EndIf
	
	Next j
		
	//Validações de Dados.
	If !lCritErro
		//Campos que não podem estar vazios
		For j:=1 to Len(aNotEmpty)
			If (nPos := aScan(aNewDados[2], {|x| ALLTRIM(x) == ALLTRIM(aNotEmpty[j]) }) ) <> 0
				If EMPTY(aNewDados[i][nPos])
					aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
							"",;
							IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
							"",;
							"",aNewDados[1][nPos],aNewDados[2][nPos],"","E","This field is required",aNewDados[i][Len(aNewDados[i])]})
				EndIf
			EndIf
		Next i

		//Validações especificas.
		//Se pedido ja existe no sistema
		If nPosF2_EMISSAO <> 0 .and. nPosF2_DOC <> 0 
				
			If ViewPV(aNewDados[i][nPosF2_EMISSAO],aNewDados[i][nPosF2_DOC])
			
				aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
							"",;
							IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
							"",;
							"",;
							aNewDados[1][nPosF2_EMISSAO]+"+"+aNewDados[1][nPosF2_DOC],;
							aNewDados[2][nPosF2_EMISSAO]+"+"+aNewDados[2][nPosF2_DOC],;
							aNewDados[i][nPosF2_EMISSAO]+"+"+aNewDados[i][nPosF2_DOC],;
							"E","Duplicate Sales Order",aNewDados[i][Len(aNewDados[i])]})
			
			
			ElseIf ViewPV(aNewDados[i][nPosF2_EMISSAO],aNewDados[i][nPosF2_DOC],.F.,.T.) //Se exister como NOT_PAID
				if (nC5Pos:= aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_STATC" }))>0//TRATAR PARA ATUALIZAR SOMENTE SE VIER COMO PAID  
    				
    				if UPPER(alltrim(aNewDados[i][nC5Pos])) == UPPER(alltrim(cStatPaid))
	            	
		            	cCpsQry:="UPDATE "+RETSQLNAME("SC5")+" SET " 
		
						if (nC5Pos:= aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_DTINI" }))>0 .AND. SC5->(FieldPos("C5_P_DTINI")) <> 0
							cCpsQry+="C5_P_DTINI='"+DTOS(CTOD(aNewDados[i][nC5Pos]))+"',"
						endif
						if (nC5Pos:= aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_DTFIM" }))>0 .AND. SC5->(FieldPos("C5_P_DTFIM")) <> 0
							cCpsQry+="C5_P_DTFIM='"+DTOS(CTOD(aNewDados[i][nC5Pos]))+"',"
						endif
						if (nC5Pos:= aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_IDC" }))>0 .AND. SC5->(FieldPos("C5_P_IDC")) <> 0
							cCpsQry+="C5_P_IDC='"+aNewDados[i][nC5Pos]+"',"
			            endif
						if (nC5Pos:= aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_DATAC" }))>0 .AND. SC5->(FieldPos("C5_P_DATAC")) <> 0
							cCpsQry+="C5_P_DATAC='"+DTOS(CTOD(aNewDados[i][nC5Pos]))+"',"
						endif                                                   
						if (nC5Pos:= aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_HORAC" }))>0 .AND. SC5->(FieldPos("C5_P_HORAC")) <> 0
							cCpsQry+="C5_P_HORAC='"+aNewDados[i][nC5Pos]+"',"
						endif
						if (nC5Pos:= aScan(aDados[2], {|x| ALLTRIM(x) == "C5_P_STATC" }))>0 .AND. SC5->(FieldPos("C5_P_STATC")) <> 0
							cCpsQry+="C5_P_STATC='"+aNewDados[i][nC5Pos]+"',"					
						endif
						cCpsQry:=substring(cCpsQry,1,RAT(",",cCpsQry)-1)            
						cCpsQry+="WHERE C5_P_REF='"+aNewDados[i][nPosF2_DOC]+"' AND D_E_L_E_T_=''"
											
						if TcSqlExec(cCpsQry)>=0
						
							aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
										"",;
										IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
										"",;
										"",;
										aNewDados[1][nPosF2_EMISSAO]+"+"+aNewDados[1][nPosF2_DOC],;
										aNewDados[2][nPosF2_EMISSAO]+"+"+aNewDados[2][nPosF2_DOC],;
										aNewDados[i][nPosF2_EMISSAO]+"+"+aNewDados[i][nPosF2_DOC],;
										"S","Update Sales Order",aNewDados[i][Len(aNewDados[i])]})
					    
						else        
						
							aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
										"",;
										IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
										"",;
										"",;
										aNewDados[1][nPosF2_EMISSAO]+"+"+aNewDados[1][nPosF2_DOC],;
										aNewDados[2][nPosF2_EMISSAO]+"+"+aNewDados[2][nPosF2_DOC],;
										aNewDados[i][nPosF2_EMISSAO]+"+"+aNewDados[i][nPosF2_DOC],;
										"E","Error in Update Sales Order",aNewDados[i][Len(aNewDados[i])]})				
						endif
			        
			        else
			           	aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
							"",;
							IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
							"",;
							"",;
							aNewDados[1][nPosF2_EMISSAO]+"+"+aNewDados[1][nPosF2_DOC],;
							aNewDados[2][nPosF2_EMISSAO]+"+"+aNewDados[2][nPosF2_DOC],;
							aNewDados[i][nPosF2_EMISSAO]+"+"+aNewDados[i][nPosF2_DOC],;
							"E","Duplicate Sales Order",aNewDados[i][Len(aNewDados[i])]})
			        		        	
			        endif
			   
			   endif
			   
			EndIf
			
		EndIf

		//Cliente		
		nPos := aScan(aNewDados[2],{|x| ALLTRIM(x)=="A1_P_ID"})
		If !EMPTY(aNewDados[i][nPos])
			If Len(ClieTw(aNewDados[i][nPos])) == 0
			/*	aAdd(aLog,{"",IIF(nPosC5_EMISSAO<>0,aDados[i][nPosC5_EMISSAO],""),;
							IIF(nPosC5_P_NUM<>0,aDados[i][nPosC5_P_NUM],""),;
							IIF(nPosC6_P_REF<>0,aDados[i][nPosC6_P_REF],""),;
							IIF(nPosC6_PRODUTO<>0,aDados[i][nPosC6_PRODUTO],""),;
							"",aDados[1][nPos],aDados[2][nPos],aDados[i][nPos],"E","Not found references to the ID",aDados[i][Len(aDados[i])]})
			*/
			EndIf
		Else
	   		aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
							"",;
							IIF(nPosF2_P_REF<>0,aNewDados[i][nPosF2_P_REF],""),;
							"",;
							"",aNewDados[1][nPos],aNewDados[2][nPos],"","E","This field is required",aNewDados[i][Len(aNewDados[i])]})
		EndIf

		//Condição de Pagamento.
		nPos := aScan(aNewDados[2],{|x| ALLTRIM(x)=="C5_CONDPAG"})
		if nPos > 0
			If !EMPTY(aNewDados[i][nPos])
				If EMPTY(CondPag(aNewDados[i][nPos]))
					aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
								"",;
								IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
								"",;
								"",aNewDados[1][nPos],aNewDados[2][nPos],aNewDados[i][nPos],"E","Not found references to the ID",aNewDados[i][Len(aNewDados[i])]})
				
				EndIf
			Else
		   		aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
								"",;
								IIF(nPosF2_P_REF<>0,aNewDados[i][nPosF2_P_REF],""),;
								"",;
								"",aNewDados[1][nPos],aNewDados[2][nPos],"","E","This field is required",aNewDados[i][Len(aNewDados[i])]})
			EndIf
        endif
        
        //Verificação da sequência
   		if i==3 
			nSeqArq:= val(substring(aNewDados[i][nPosF2_DOC],1,AT("-",aNewDados[i][nPosF2_DOC])-1))
		else
	   		nSeqArq+=1
		endif
		
		if nSeqArq<>val(substring(aNewDados[i][nPosF2_DOC],1,AT("-",aNewDados[i][nPosF2_DOC])-1))
			
			if aScan(aLog,{|x| ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_P_REF")})])  == STRZERO(nSeqArq,9)+"-CRA"}) ==0
			
				aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
							"",;
							STRZERO(nSeqArq,9)+"-CRA",;
							"",;
							"",aNewDados[1][nPosF2_DOC],STRTRAN(aNewDados[2][nPosF2_DOC],"C5_","F2_"),STRZERO(nSeqArq,9)+"-CRA","E","Not found ID reference in sequence ",aNewDados[i][Len(aNewDados[i])]})		
			
			endif
			nSeqArq:=val(substring(aNewDados[i][nPosF2_DOC],1,AT("-",aNewDados[i][nPosF2_DOC])-1))
		endif
        
			//Monta o Array de Cabeçalho
			aAux1 	:= {}
			            
			//-->>Monta o Array do cabeçalho do pedido SC5 e array auxilar de cliente           
			aNewDaSA1 := {{},{}}
			For j:=1 to len(aNewDados[2])
                
                if "C5_" $ alltrim(aNewDados[2][j])
	                if SC5->(FIELDPOS(alltrim(aNewDados[2][j])))>0
		                cTipoX3	:= GetSx3Cache(aNewDados[2][j],"X3_TIPO") //Retorna o tipo do X3
						cTipoUs	:= valtype(aNewDados[i][j])	//Retorna o tipo do valor do campo
						_Conteud:= aNewDados[i][j] 
						
						if alltrim(cTipoX3) <> alltrim(cTipoUs)
							if alltrim(cTipoX3)=="D" .AND. alltrim(cTipoUs)=="C"
								_Conteud:= CTOD(aNewDados[i][j])
							elseif alltrim(cTipoX3)=="N" .AND. alltrim(cTipoUs)=="C"
								_Conteud:= val(aNewDados[i][j])
							endif
						endif
						
						aAdd(aAux1, {aNewDados[2][j], _Conteud, NIl }  )
					endif
				elseif "A1_" $ alltrim(aNewDados[2][j])
					AADD(aNewDaSA1[1],aNewDados[2][j]) //Descrição dos campos
					AADD(aNewDaSA1[2],aNewDados[i][j]) //Conteúdo dos campos
				endif
            Next


			//{'C5_NUM','C5_TIPO','C5_TIPOCLI','C5_CONDPAG','C5_EMISSAO','C5_MENNOTA','C5_P_REF','C5_CLIENTE','C5_LOJACLI'}
            //Tratamento de campos adicionais faltantes na capa do pedido
            //Tipo de pedido
            nPosCps	:= 0
			nPosCps	:= aScan(aNewDados[2],{|x| "C5_TIPO" $ UPPER(ALLTRIM(x))})
       		if nPosCps==0
       			aAdd(aAux1, {"C5_TIPO", "N", NIl }  )	
       		endif 
            //Tipo de cliente
            nPosCps	:= 0
			nPosCps	:= aScan(aNewDados[2],{|x| "C5_TIPOCLI" $ UPPER(ALLTRIM(x))})
       		if nPosCps==0
       			aAdd(aAux1, {"C5_TIPOCLI", "F", NIl }  )	
       		endif
            //Condição de pagamento
            nPosCps	:= 0
			nPosCps	:= aScan(aNewDados[2],{|x| "C5_CONDPAG" $ UPPER(ALLTRIM(x))})
       		if nPosCps==0
       			aAdd(aAux1, {"C5_CONDPAG", "016", NIl }  )	
       		endif
       		
   			//RRP - 16/05/2017 - Liberação do Pedido
            nPosCps	:= 0
			nPosCps	:= aScan(aNewDados[2],{|x| "C5_TIPLIB " $ UPPER(ALLTRIM(x))})
       		If nPosCps==0
       			aAdd(aAux1, {"C5_TIPLIB ", "1", NIl }  )	
       		EndIf
       		
       		
       		//Valor total do pedido
       		nValTotC5	:= 0
       		if nPosF2_TOTAL>0
       			nValTotC5 := aNewDados[i][nPosF2_TOTAL]		
       		endif       		
       		
			//Tratamento de cliente
            aCliAux := IncAltCli(aNewDaSA1)
            aAdd(aAux1, {"C5_CLIENTE"	,aCliAux[1],Nil  } )
			aAdd(aAux1, {"C5_LOJACLI"	,aCliAux[2],Nil  } )
			aAdd(aAux1, {"C5_LOJAENT"	,aCliAux[2],Nil  } )

			//-->>Fim do monta o Array do cabeçalho
            
			//-->>Monta o Array de Itens
			aAux2_T		:= {}
			aIte		:= BuscaIte(aNewDados[i][nPosF2_DOC])
			nValTotC6 	:= 0
			
			if len(aIte)==0
            	aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
							"",;
							IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
							"",;
							"",aNewDados[1][nPosF2_DOC],STRTRAN(aNewDados[2][nPosF2_DOC],"C5_","F2_"),aNewDados[i][nPosF2_DOC],"E","Not found references to the ID in campaign file",aNewDados[i][Len(aNewDados[i])]})
			
				if nPosCpn > 0
            		aAdd(&("aLog"+aRefArq[nPosCpn][1]),{"",IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
								"",;
								"Invoice_ID","ZX3_DOC",aNewDados[i][nPosF2_DOC],"E","ID found in invoice file but not found in campaign file",aNewDados[i][Len(aNewDados[i])]})				
				endif
			else
			    //RRP - 15/05/2017 - Ajuste na sequencia do item.
			    cNumItem:= "00"
				For j:=1 to len(aIte)
					cNumItem:= SOMA1(cNumItem)
					aAux2 	:= {}
				    //"C6_ITEM","C6_PRODUTO","C6_QTDVEN","C6_PRCVEN","C6_PRUNIT","C6_VALOR","C6_TES"
					aAdd(aAux2, {"C6_FILIAL", xFilial("SC6")	, NIl  } )
					//aAdd(aAux2, {"C6_ITEM"	, STRZERO(j, 2)		, NIl  } )
					aAdd(aAux2, {"C6_ITEM"	, cNumItem		, NIl  } )
				    if len(aAuxCamp)>2
	    					nPosChv	:= aScan(aAuxCamp[2],{|x| "ZX3_PROD" $ UPPER(ALLTRIM(x))})
	                   		if nPosChv>0 
	                   			aAdd(aAux2, {"C6_PRODUTO"	, aIte[j][nPosChv]		, NIl  } )
	                        
	                        	DbSelectArea("SB1")
	                        	SB1->(DbSetOrder(1))
	                        	if !SB1->(DbSeek(xFilial("SB1")+PADR( aIte[j][nPosChv], TamSx3("B1_COD")[1])))
	                        		aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
												"",;
												IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
												"",;
												"",aAuxCamp[1][nPosChv],aAuxCamp[2][nPosChv],aIte[j][nPosChv],"E","Not found references to the ID",aNewDados[i][Len(aNewDados[i])]})
	                        	endif
	                        endif
	    					nPosChv	:= aScan(aAuxCamp[2],{|x| "ZX3_VALOR" $ UPPER(ALLTRIM(x))})
	                   		if nPosChv>0 
	                   			aAdd(aAux2, {"C6_PRCVEN"	, val(aIte[j][nPosChv])		, NIl  } )
	                   			aAdd(aAux2, {"C6_PRUNIT"	, val(aIte[j][nPosChv])		, NIl  } )
	                   			aAdd(aAux2, {"C6_VALOR"		, val(aIte[j][nPosChv])		, NIl  } )
	      						nValTotC6+=val(aIte[j][nPosChv])
	      					endif
	                endif
	                aAdd(aAux2, {"C6_QTDVEN"	, 1			, NIl  } )
	                aAdd(aAux2, {"C6_TES"		, cTESPed	, NIl  } ) //AJUSTAR TES
	            
					AADD(aAux2_T,aAux2)
	
				Next i
				//-->>Fim do monta o Array dos itens
			
				//RRP - 12/05/2017 - Alterado a validação, o valor do item será o fato gerado da nota.
				//Se o valor total dos itens não bate com o total da capa
				//if nValTotC5<>nValTotC6
				if nValTotC5>nValTotC6
					aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
						"",;
						IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
						"",;
						"",aNewDados[1][nPosF2_TOTAL],STRTRAN(aNewDados[2][nPosF2_TOTAL],"C5_","F2_"),cvaltochar(aNewDados[i][nPosF2_TOTAL]),"E","Total value is bigger than items value",aNewDados[i][Len(aNewDados[i])]})
				endif
			
			endif
			
			//Adiciona no Array com os dados organizados.
			aAdd(aCxI,{aAux1,{}})
			aAdd(aCxI[Len(aCxI)][2], aAux2_T )
			
			//aAux3:=ACLONE(aAux1)
			
			//Adiciona no Array auxiliar para tratamento dos atributos adicionais
			//aAdd(aCxIAtrib,{aAux3,{}})
			
		//EndIf
		
	EndIf
Next i


//Gravação do Pedido
If !lCritErro
	For i:=1 to Len(aCxI)
		lMsErroAuto:= .F.
		//lMSHelpAuto := .F.
		//lAutoErrNoFile := .T.

		If aScan(aLog,{|x| ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_EMISSAO")})]) == ALLTRIM(DTOC(aCxI[i][1][aScan(aNewDados[2],{|x| ALLTRIM(x)=="C5_EMISSAO" })][2])) .and.;
						ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("C5_P_REF")})])      == ALLTRIM(aCxI[i][1][aScan(aNewDados[2],{|x| ALLTRIM(x)=="C5_P_REF" })][2]) }) == 0
			//.and. ALLTRIM(x[aScan(aLog[2],{|x| alltrim(UPPER(x)) ==ALLTRIM("STATUS")})]) == "S"  )

			//Busca o Ultimo Numero dos PV.
			If Select("NUMPV") > 0
				NUMPV->(DbClosearea())
			Endif  
			cQuery := " Select MAX(C5_NUM)+1 AS PROXNUM"
			cQuery += " From "+RETSQLNAME("SC5")
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"NUMPV",.F.,.T.)
			cSeqNumC5 := STRZERO(NUMPV->PROXNUM,TAMSX3("C5_NUM")[1])
			NUMPV->(DbClosearea())
			
			//Valores deFault e Ajuste de Valores            
			aCabExec := {}
			aIteExec := {}
			aCabExec := aClone(aCxI[i][1])
			aIteExec := aClone(aCxI[i][2][1])
			
			aAdd(aCabExec,{"C5_NUM",cSeqNumC5,Nil})
			aAdd(aCabExec,{"C5_P_INT","S",Nil})
			
			lErroInCpo := .F.
			
            //Orderna Alguns campos.
			//Cabeçalho
			aAux := aCabExec
			aCabExec := {}
			aOrd := {"C5_NUM","C5_TIPO","C5_CLIENTE","C5_LOJACLI","C5_LOJAENT","C5_CONDPAG"}
			For j:=1 to Len(aOrd)
				aAdd(aCabExec,aAux[aScan(aAux,{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[j]) })] )
				aDel(aAux,aScan(aAux,{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[j]) }))
				aSize(aAux, Len(aAux)-1)
			Next j
			For j:=1 to Len(aAux)
				aAdd(aCabExec,aAux[j] )
			Next j
			//Itens
			aAux := aIteExec
			aIteExec := {}
			aOrd := {"C6_FILIAL","C6_ITEM","C6_PRODUTO","C6_QTDVEN","C6_PRCVEN","C6_PRUNIT","C6_VALOR","C6_TES"}
			aIteExec := Array(Len(aAux))
			For j:=1 to Len(aAux)
				aIteExec[j] := {}
				For k:=1 to Len(aOrd) 
			  		aAdd(aIteExec[j],aAux[j][aScan(aAux[j],{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[K]) })] )
			   		aDel(aAux[j],aScan(aAux[j],{|x| ALLTRIM(x[1]) == ALLTRIM(aOrd[K]) }))
			   		aSize(aAux[j], Len(aAux[j])-1)
			   	Next k
				//For k:=1 to Len(aAux[j])
				//	aAdd(aIteExec[j],aAux[j][j][k] )
				//Next k
			Next j

    		//Efetua a gravação do Pedido
			If !lErroInCpo
				//MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCabExec, aIteExec, 3)
				MATA410(aCabExec,aIteExec,3)
				//Tratamento de Erro
				If lMsErroAuto
					cMsg := "Error in recording"
			   		aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,DTOC(aCxI[i][1][nPosF2_EMISSAO][2]),""),;
									"",;
									IIF(nPosF2_P_REF<>0,aCxI[i][1][nPosF2_P_REF][2],""),;
									"",;
									"","","","","E",cMsg,aNewDados[i][Len(aNewDados[i])]})
				Else    
					cMsg := "Inserted successfully"
			   		aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,DTOC(aCxI[i][1][nPosF2_EMISSAO][2]),""),;
									"",;
									IIF(nPosF2_P_REF<>0,aCxI[i][1][nPosF2_P_REF][2],""),;
									"",;
									aCabExec[aScan(aCabExec,{|x| ALLTRIM(x[1])=="C5_NUM" })][2],;
									"","","","S",cMsg,aNewDados[i][Len(aNewDados[i])]})
				
					//Gera nota
					GeraNota()
				EndIf
			EndIf

		EndIf
	Next i

EndIf

//Ajuste do Log de Processamento.
If Len(aLog) >= 3
	nPosLog1 := aScan(aLog[2],{|x|x==ALLTRIM("C5_EMISSAO")})
	nPosLog2 := aScan(aLog[2],{|x|x==ALLTRIM("C5_P_NUM")})
	nPosLog3 := aScan(aLog[2],{|x|x==ALLTRIM("C5_P_REF")})
	nPosLog4 := aScan(aLog[2],{|x|x==ALLTRIM("C6_PRODUTO")})

	//Tratamento para casos que possuem itens rejeitados na integração. para apresentar log para todos.
	For i:=3 to Len(aNewDados)
		If (nPos := aScan(aLog,{|x| ALLTRIM(x[nPosLog1]) == ALLTRIM(aNewDados[i][nPosF2_EMISSAO]) 	.and.;
									ALLTRIM(x[nPosLog2]) == ALLTRIM(aNewDados[i][nPosF2_DOC]) 	}) )	<> 0 

			If aScan(aLog,{|x|	ALLTRIM(x[nPosLog1]) == ALLTRIM(aNewDados[i][nPosF2_EMISSAO]) .and.;
								ALLTRIM(x[nPosLog3]) == ALLTRIM(aNewDados[i][nPosF2_DOC]) }) == 0

				If alog[nPos][aScan(aLog[2],{|x| ALLTRIM(UPPER(x)) == ALLTRIM("STATUS")})] == "S"
					aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
								"",;
								IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
								"",;
								alog[nPos][aScan(aLog[2],{|x| ALLTRIM(UPPER(x)) == ALLTRIM("C5_NUM")})],;
								"","","","S","Inserted successfully",aNewDados[i][Len(aNewDados[i])]})
				Else
					aAdd(aLog,{"",IIF(nPosF2_EMISSAO<>0,aNewDados[i][nPosF2_EMISSAO],""),;
								"",;
								IIF(nPosF2_DOC<>0,aNewDados[i][nPosF2_DOC],""),;
								"",;
								"","","","","E","There is another item in the request rejected",aNewDados[i][Len(aNewDados[i])]})				
				EndIf
			EndIF
		EndIf
	Next i
    
	//Para manter as linhas de cabeçalho no local correto durante a ordenação
	aLog[1][nPosLog1] := "AAAAA"+aLog[1][nPosLog1]
	aLog[2][nPosLog1] := "AAAAB"+aLog[2][nPosLog1]
	
	//aSort(aLog,,,{|x,y| x[nPosLog1]+x[nPosLog3] < y[nPosLog1]+y[nPosLog3] })

	//Restaura os dados alterados
	aLog[1][nPosLog1] := SubStr(aLog[1][nPosLog1],6,Len(aLog[1][nPosLog1]) )
	aLog[2][nPosLog1] := SubStr(aLog[2][nPosLog1],6,Len(aLog[2][nPosLog1]) )

	nSeq := 1
	cChave := aLog[3][nPosLog1]+aLog[3][nPosLog3]
	
	For i:=3 to Len(aLog)
		If cChave <> aLog[i][nPosLog1]+aLog[i][nPosLog3]
			nSeq := 1
			cChave := aLog[i][nPosLog1]+aLog[i][nPosLog3]
		EndIf
		alog[i][aScan(aLog[2],{|x|x==ALLTRIM("SEQ")})] := ALLTRIM(STR(nSeq))
		nSeq ++
	Next i
EndIf

Return .T.

/*
Funcao      : GravaZX3
Parametros  : 
Retorno     :
Objetivos   : Gravação dos Arquivos.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function GravaZX3()
*------------------------*
Local i
Local aDados	:= &("a"+aRefArq[nNATAtu][1])
Local lErro		:= .F.
Local lCritErro	:= .F.
Local nPos		:= 0
Local nPos2		:= 0

Local aCposObrg	:= {'ZX3_ID','ZX3_VALOR','ZX3_EMISSAO'}
Local aNotEmpty	:= {'ZX3_ID'}
Local aLog		:= &("aLog"+aRefArq[nNATAtu][1])

//Posição dos campos que compoem a chave do arquivo.
Local nPosZX3_DOC		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "ZX3_DOC" })
Local nPosZX3_ID		:=  aScan(aDados[2], {|x| ALLTRIM(x) == "ZX3_ID" })

//Executa a partir do primeiro registro com informação.
For i:=3 to len(aDados)
	//Validações De estrutura
	For j:=1 to Len(aCposObrg)
		If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aCposObrg[j]) })   ) == 0
			lCritErro := .T.
			aAdd(aLog,{"",IIF(nPosZX3_DOC<>0,aDados[i][nPosZX3_DOC],""),;
						IIF(nPosZX3_ID<>0,aDados[i][nPosZX3_ID],""),;
						"",aCposObrg[j],"","E","Critical Error - Field not Exist",aDados[i][Len(aDados[i])]})
		EndIf
	Next j

	//Validações de Dados.
	If !lCritErro
		//Campos que não podem estar vazios
		For j:=1 to Len(aNotEmpty)
			If (nPos := aScan(aDados[2], {|x| ALLTRIM(x) == ALLTRIM(aNotEmpty[j]) }) ) <> 0
				If EMPTY(aDados[i][nPos])
					aAdd(aLog,{"",IIF(nPosZX3_DOC<>0,aDados[i][nPosZX3_DOC],""),;
						IIF(nPosZX3_ID<>0,aDados[i][nPosZX3_ID],""),;
						aDados[1][nPos],aDados[2][nPos],"","E","This field is required",aDados[i][Len(aDados[i])]})
				EndIf
			EndIf
		Next i
		
		//Validações especificas
		//Se pedido existe no sistema
		If nPosZX3_DOC <> 0
			If !ViewPV("",aDados[i][nPosZX3_DOC],.F.)
				aAdd(aLog,{"",IIF(nPosZX3_DOC<>0,aDados[i][nPosZX3_DOC],""),;
							IIF(nPosZX3_ID<>0,aDados[i][nPosZX3_ID],""),;
							aDados[1][nPosZX3_DOC],aDados[2][nPosZX3_DOC],aDados[i][nPosZX3_DOC],"E","Not found references to Sales Order",aDados[i][Len(aDados[i])]})
			EndIf
		EndIf
	EndIf
Next i

//Gravação
If !lCritErro
	For i:=3 to Len(aDados)
		If aScan(aLog,{|x| 	ALLTRIM(x[aScan(aLog[2],{|x|x==ALLTRIM("ZX3_DOC")})]) == ALLTRIM(aDados[i][nPosZX3_DOC]) .and.;
							ALLTRIM(x[aScan(aLog[2],{|x|ALLTRIM(UPPER(x))==ALLTRIM("STATUS") })]) == "E" }) == 0
			//Gravação do ZX3
			ZX3->(DbSetOrder(1))
			ZX3->(RecLock("ZX3",.T.))
			For j:=1 to Len(aDados[2])
				Do Case
					Case aDados[2][j] == "ZX3_VALOR"
						ZX3->ZX3_VALOR:=VAL(aDados[i][j])
					Case aDados[2][j] == "ZX3_EMISSAO"
						ZX3->ZX3_EMISSA := CTOD(CTODBRA(aDados[i][j]))
					OtherWise
						If ZX3->(FieldPos(aDados[2][j])) <> 0
							ZX3->(&(aDados[2][j])) := ALLTRIM(aDados[i][j])
						EndIf
				EndCase
			Next j
			ZX3->(MsUnlock())           

			aAdd(aLog,{"",IIF(nPosZX3_DOC<>0,aDados[i][nPosZX3_DOC],""),;
						IIF(nPosZX3_ID<>0,aDados[i][nPosZX3_ID],""),;
						"","","","s","Inserted successfully",aDados[i][Len(aDados[i])]})

		EndIf	
	Next i
EndIf

//Ajuste do Log de Processamento.
If Len(aLog) >= 3
	nPosLog1 := aScan(aLog[2],{|x|x==ALLTRIM("ZX3_DOC")})
	nSeq := 1
	cChave := aLog[3][nPosLog1]
	
	For i:=3 to Len(aLog)
		If cChave <> aLog[i][nPosLog1]
			nSeq := 1
			cChave := aLog[i][nPosLog1]
		EndIf
		alog[i][aScan(aLog[2],{|x|x==ALLTRIM("SEQ")})] := ALLTRIM(STR(nSeq))
		nSeq ++
	Next i
EndIf


Return .T.

/*
Funcao      : NewCabLog
Parametros  : 
Retorno     :
Objetivos   : Gravação dos Log.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------*
Static Function NewCabLog()
*-------------------------*
aLOG01 := {}
aLOG02 := {}
aLOG03 := {}

aAdd(aLOG01,{'SEQ','TWI_CUSTOMER_NUMBER','GT_COMPANY_ID','STATUS','Twitter_Reference','GT_Reference','VALUE','ERROR_MESSAGE','File'})
aAdd(aLOG01,{'SEQ','A1_P_ID','A1_COD','STATUS','Twitter Reference','GT Reference','VALUE','ERROR_MESSAGE','File'})
aAdd(aLOG02,{'SEQ','Billing_Period','IO_Number','IO_Line_Number','Item_Number','IO_number_GT','Twitter_Reference','GT_Reference','Value','Status','Error Message','File'})
aAdd(aLOG02,{'SEQ','C5_EMISSAO','C5_P_NUM','C5_P_REF','C6_PRODUTO','C5_NUM','Twitter_Reference','GT_Reference','Value','Status','Error_Message','File'})
aAdd(aLOG03,{'SEQ','Invoice_ID','Campaign_Id','Twitter_Reference','GT_Reference','VALUE','Status','Error_Message','File'})
aAdd(aLOG03,{'SEQ','ZX3_DOC','ZX3_ID','Twitter_Reference','GT_Reference','Value','Status','Error_Message','File'})

Return .T.

/*
Funcao      : AltData
Parametros  : 
Retorno     :
Objetivos   : Ajuste da Data
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------*
Static Function AltData(cInfo,cTipo)
*----------------------------------*
Local xRet
Local cMes := ""
Local cAno := ""

Default cTipo := "1"

If cTipo == "1"
	cMes := UPPER(LEFT(cInfo,3))
	cAno := RIGHT(cInfo,2)
	cNewDay := "01/"
	Do Case
		Case cMes == "JAN"
			cNewDay += "01/"
		Case cMes == "FEB"
			cNewDay += "02/"
		Case cMes == "MAR"
			cNewDay += "03/"
		Case cMes == "APR"
			cNewDay += "04/"
		Case cMes == "MAY"
			cNewDay += "05/"
		Case cMes == "JUN"
			cNewDay += "06/"
		Case cMes == "JUL"
			cNewDay += "07/"
		Case cMes == "AUG"
			cNewDay += "08/"
		Case cMes == "SEP"
			cNewDay += "09/"
		Case cMes == "OCT"
			cNewDay += "10/"
		Case cMes == "NOV"
			cNewDay += "11/"
		Case cMes == "DEC"
			cNewDay += "12/"
	EndCase
	cNewDay += cAno
	xRet := cTod(cNewDay)
Else
	cMes := ""
	cNewDay := SUBSTR(cInfo,5,2)
	cAno := SUBSTR(cInfo,3,2)
	Do Case
		Case cNewDay == "01"
			cMes += "JAN"
		Case cNewDay == "02"
			cMes += "FEB"
		Case cNewDay == "03
			cMes += "MAR"
		Case cNewDay == "04"
			cMes += "APR"
		Case cNewDay == "05"
			cMes += "MAY"
		Case cNewDay == "06"
			cMes += "JUN"
		Case cNewDay == "07"
			cMes += "JUL"
		Case cNewDay == "08"
			cMes += "AUG"
		Case cNewDay == "09"
			cMes += "SEP"
		Case cNewDay == "10"
			cMes += "OCT"
		Case cNewDay == "11"
			cMes += "NOV"
		Case cNewDay == "12"
			cMes += "DEC"
	EndCase
	xRet := cMes+"-"+cAno
EndIf

Return xRet

/*
Funcao      : ClieTw
Parametros  :
Retorno     :
Objetivos   : Buscar infromações do cliente pelo ID proprio
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function ClieTw(cId,cCGC)
*------------------------------*
Local aRet := {}

Default lOnlyView := .F.
Default cId := ""
Default cCgc := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select Top 1 *"
cQuery += " From "+RETSQLNAME("SA1")
cQuery += " Where A1_P_ID = '"+ALLTRIM(cId)+"'
If !EMPTY(cCgc)
	cQuery += " 	AND A1_CGC = '"+ALLTRIM(cCGC)+"'
EndIf
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	aRet := {QRY->A1_COD,QRY->A1_LOJA}
EndIf

Return aRet

/*
Funcao      : CondPag
Parametros  :
Retorno     :
Objetivos   : Validar a condição de pagamento
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function CondPag(cCond)
*----------------------------*
Local cRet := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("SE4")
cQuery += " Where E4_P_DESC = '"+ALLTRIM(cCond)+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	cRet := QRY->E4_CODIGO
EndIf

Return cRet

/*
Funcao      : ViewPV
Parametros  :
Retorno     :
Objetivos   : Validar se ja existe o pedido do cliente.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-----------------------------------------------------------------*
Static Function ViewPV(cC5_EMISSAO,cC5_P_REF,lVerPaid,lNotVerPaid)
*-----------------------------------------------------------------*
Local lRet := .F.

//Default cC6_PRODUTO := ""
Default cC5_EMISSAO := ""
Default lVerPaid	:= .T.
Default lNotVerPaid	:= .F.

if !Empty(cC5_EMISSAO)
	cC5_EMISSAO := DtoS(AltData(cC5_EMISSAO))
endif

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select COUNT(*) AS COUNT"
cQuery += " From "+RETSQLNAME("SC5")+" SC5
//Quando informado o Produto, executa Join no SC6
/*If !EMPTY(cC6_PRODUTO)
	cQuery += "			Inner join (Select * From "+RETSQLNAME("SC6")+" Where C6_PRODUTO = '"+cC6_PRODUTO+"' ) AS SC6 on 
	cQuery += "																						SC5.C5_FILIAL 	= SC6.C6_FILIAL	AND 
	cQuery += "																						SC5.C5_NUM 		= SC6.C6_NUM 	AND
	cQuery += "																						SC5.C5_P_NUM 	= SC6.C6_P_NUM
EndIf
*/
cQuery += " Where 
//cQuery += " SC5.C5_EMISSAO = '"+ALLTRIM(cC5_EMISSAO)+"' AND"
cQuery += " 	SC5.C5_P_REF = '"+ALLTRIM(cC5_P_REF)+"'
if lVerPaid
	cQuery += " 	AND SC5.C5_P_STATC = '"+cStatPaid+"'"
endif                                                 
if lNotVerPaid
	cQuery += " 	AND SC5.C5_P_STATC = '"+cStatNoPaid+"'"
endif                                                 
cQuery += " 	AND SC5.D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

lRet := QRY->COUNT <> 0

Return lRet

/*
Funcao      : DTOCEUA
Parametros  : 
Retorno     :
Objetivos   : Converte Data em Formato EUA MM/DD/AAAA
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------*
Static Function DTOCEUA(dData)
*----------------------------*
Default dData := Date()

Return STRZERO(Day(dData),2)+"/"+STRZERO(MONTH(dData),2)+"/"+STRZERO(YEAR(dData),4)

/*
Funcao      : GetNameArq
Parametros  : 
Retorno     :
Objetivos   : Retorna o Array somente com os nomes dos arquivos
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------------*
Static Function GetNameArq(aDados,lGetPosFile)
*--------------------------------------------*
Local i
Local nPos := 0
Local aRet := {}

Default lGetPosFile := .T.

If lGetPosFile
	If Len(aDados) > 2 .and. (nPos := aScan(aDados[2],{|x| ALLTRIM(UPPER(x)) == "FILE"})    ) <> 0
		For i:=3 to Len(aDados)
			If aScan(aRet,{|x| ALLTRIM(UPPER(x)) == ALLTRIM(UPPER(aDados[i][nPos]))}) == 0
				aAdd(aRet,aDados[i][Len(aDados[i])])
			EndIf
		Next i
	EndIf
Else
	If Len(aDados) > 2
		For i:=3 to Len(aDados)
			If aScan(aRet,{|x| ALLTRIM(UPPER(x)) == ALLTRIM(UPPER(aDados[i][Len(aDados[i])]))}) == 0
				aAdd(aRet,aDados[i][Len(aDados[i])])
			EndIf
		Next i
	EndIf
EndIf

Return aRet

/*
Funcao      : ConvString
Parametros  : 
Retorno     :
Objetivos   : Retira caracteres invalidos da string
Autor       : Jean Victor Rocha
Data/Hora   : 11/12/2014
*/
*-------------------------------*
Static Function ConvString(cInfo)
*-------------------------------* 
Local i
Local cRet := ""
Local aTabConv := {	{"Ã¡","A"},{"°",""},{"Ã‡","C"},{"Ã•","O"},{"Ãƒ","A"},{"Ã‚","A"},{"Ã€","A"},{"Ã£","A"},{"Ã¢","A"},{"Ã ","A"},;
					{"Ã§","C"},{"Ã‡","C"},{"Ãº","U"},{"Ã­","I"},{"Â€“","-"},{"Ã³","o"},{"Ãª","e"},{"Âº","a"},{"Ãª","E"},{"Ã©","E"},;
					{"Âª","a"},{"Ãµ","O"},{"Ã‰","E"},{"ÃŠ","E"}}

cRet := ALLTRIM(cInfo)

For i:=1 to Len(aTabConv)
	cRet := StrTran(cRet,aTabConv[i][1],aTabConv[i][2])
Next i

Return UPPER(cRet)

*-------------------------------*
Static Function BuscaIte(cIdRef)
*-------------------------------*
Local aAuxBus	:= {}
Local oHashIte	:= Nil
Local aValIte 	:= {}
Local lFound	:= .F.

nPos 	:= aScan(aRefArq,{|x| "BR_CAMPAIGN_" $ UPPER(ALLTRIM(x[2]))})

if nPos > 0

	aAuxBus:= &("a"+aRefArq[nPos][1])
	
    if len(aAuxBus)>2
    	nPosChv	:= aScan(aAuxBus[2],{|x| "ZX3_DOC" $ UPPER(ALLTRIM(x))})
    	
    	if nPosChv>0
	    	oHashIte:= AToHM(aAuxBus,nPosChv) //Converte uma matriz de dados (Array) em um tHashMap
	    	lFound	:= HMGet(oHashIte,alltrim(cIdRef), aValIte,3) //4 parâmetro: 0 ? não altera a palavra, 1 ? Elimina espaços a esquerda, 2 ? Elimina espaços a direita, 3 ? Elimina espaços a esquerda e a direita
    	    
    	    if !lFound
  	    		aValIte :={}
    	    endif 
    		
	    	// Limpa os dados do HashMap
			HMClean(oHashIte)
			// Libera o objeto de HashMap
			FreeObj(oHashIte)
        endif
        //preciso fazer uma função para retornar os itens do pedido
    endif

endif

Return(aValIte)

*------------------------------*
Static function TEMPSQL(aCampos)
*------------------------------*
Local lControl	:= .F.
Local cString	:= "CREATE TABLE "+cTabTemp+" ( "
Local lRet		:= .F.
Local cQry		:= ""
Local lDrop		:= .T.

DbSelectArea("SC5") 
DbSelectArea("SA1")

if select("TRBTEMP")>0
	TRBTEMP->(DbCloseArea())
endif

cQry:= " SELECT NAME FROM Tempdb..SysObjects 
cQry+= " WHERE Xtype='U' and name ='"+cTabTemp+"'"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBTEMP" ,.T.,.F.)

if select("TRBTEMP")>0
	count to nReccount
	if nRecCount>0
		//Problema ao Dropar a Tabela
		if TCSQLEXEC("DROP TABLE "+cTabTemp) < 0
			lDrop:=.F.
		endif
	endif
endif

If lDrop
	For i:=1 to len(aCampos)
		if ("S"+substring(aCampos[i],1,2))->(FIELDPOS(aCampos[i]))>0
			if TAMSX3(aCampos[i])[3]=="N" //tipo do campo
				cString+= alltrim(aCampos[i])+" DECIMAL("+ cvaltochar(TAMSX3(aCampos[i])[1])+","+cvaltochar(TAMSX3(aCampos[i])[2])+"),"
			elseif TAMSX3(aCampos[i])[3]=="D"
				cString+= alltrim(aCampos[i])+" VARCHAR(10)," 
			else
				cString+= alltrim(aCampos[i])+" VARCHAR("+cvaltochar(TAMSX3(aCampos[i])[1])+")," 
			endif
			
			//TAMSX3(aCampos[i])[2] //Decimal
			//TAMSX3(aCampos[i])[1] //Tamanho
			lControl:=.T.
			cCpsSC5SA1+=alltrim(aCampos[i])+","
		elseif "TOTAL" $ aCampos[i]
			cString+= alltrim(aCampos[i])+" DECIMAL("+ cvaltochar(TAMSX3("C6_VALOR")[1])+","+cvaltochar(TAMSX3("C6_VALOR")[2])+"),"
			lControl:=.T.
			cCpsSC5SA1+=alltrim(aCampos[i])+","
		elseif i==len(aCampos)
			cString+= "ARQUIVO VARCHAR(240)," 
			lControl:=.T.
			cCpsSC5SA1+="ARQUIVO,"
		else 
			cString+= alltrim(aCampos[i])+" VARCHAR(240)," 
			lControl:=.T.
			cCpsSC5SA1+=alltrim(aCampos[i])+","
		endif
	Next
endif

if lControl
	cString:=substring(cString,1,RAT(",",cString)-1) //retira a última virguta
	cString+=" )"

	cCpsSC5SA1:=substring(cCpsSC5SA1,1,RAT(",",cCpsSC5SA1)-1) //retira a última virguta
	
	if TCSQLEXEC(cString)>=0
		lRet:=.T.
	endif
endif

Return(lRet)

//Tratamnento para incluir ou alterar o cliente
*--------------------------------*
Static Function IncAltCli(aDados)
*--------------------------------*
Local cIDCli	:= ""
Local cCodCli	:= ""
Local cLojaCli	:= ""
Local lIncAltA1	:= .F.

if len(aDados[1])>0 .AND. len(aDados[2])>0
	cIDCli:= aDados[2][aScan(aDados[1],{|x| "A1_P_ID" $ UPPER(ALLTRIM(x))})]
endif

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " SELECT TOP 1 *"
cQuery += " FROM "+RETSQLNAME("SA1")
cQuery += " WHERE A1_P_ID = '"+ALLTRIM(cIDCli)+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
if QRY->(!EOF())
	//aRet := {QRY->A1_COD,QRY->A1_LOJA}
	cCodCli		:= QRY->A1_COD
	cLojaCli	:= QRY->A1_LOJA
	lIncAltA1	:= .F.
else
	lIncAltA1	:= .T.
endif

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
if DbSeek(xFilial("SA1")+cCodCli+cLojaCli) .AND. !lIncAltA1  //Alteração
    
    RecLock("SA1",lIncAltA1)
		for i:=1 to len(aDados[1])
        	if SA1->(FIELDPOS(alltrim(aDados[1][i])))>0 .AND. !("A1_P_ID" $ aDados[1][i])
        		if "A1_END" $ aDados[1][i] .OR. "A1_NOME" $ aDados[1][i]
        			
       				SA1->&(aDados[1][i])	:= ConvString(aDados[2][i])
        		
        		elseif "A1_PAIS" $ aDados[1][i]
        			SA1->&(aDados[1][i])	:= IIF("BR" $ UPPER(aDados[2][i]),"105","")
        		elseif "A1_MUN" $ aDados[1][i]
        			SA1->&(aDados[1][i])	:= ConvString(aDados[2][i])
        		else
	        		SA1->&(aDados[1][i])	:= aDados[2][i]
        		endif
        	else
        		if "A1_END1" $ aDados[1][i]
        			SA1->A1_COMPLEM	:= ConvString(aDados[2][i])
        		elseif "A1_NOME1" $ aDados[1][i]
        			SA1->A1_NOME := alltrim(SA1->A1_NOME)+" "+ConvString(aDados[2][i])
        		endif
        	endif
		next
	SA1->(MsUnlock())
	
else //Inclusão

	//define um novo codigo para o Cliente.
	If Select("QRY") > 0
		QRY->(DbClosearea())
	Endif  
	cQuery := " Select MAX(A1_COD) AS NEWCOD"
	cQuery += " From "+RETSQLNAME("SA1")
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
	cNewCod := SOMA1(QRY->NEWCOD)
	
    RecLock("SA1",lIncAltA1)
		
		SA1->A1_COD		:= cCodCli := cNewCod
		SA1->A1_LOJA 	:= cLojaCli:= "01"

		for i:=1 to len(aDados[1])
        	if SA1->(FIELDPOS(alltrim(aDados[1][i])))>0
        		if "A1_END" $ aDados[1][i] .OR. "A1_NOME" $ aDados[1][i]
        			
        			SA1->&(aDados[1][i])	:= ConvString(aDados[2][i])
        	        		
        		elseif "A1_PAIS" $ aDados[1][i]
        			SA1->&(aDados[1][i])	:= IIF("BR" $ UPPER(aDados[2][i]),"105","")
        		elseif "A1_MUN" $ aDados[1][i]
        			SA1->&(aDados[1][i])	:= ConvString(aDados[2][i])
        		else
	        		SA1->&(aDados[1][i])	:= aDados[2][i]
        		endif
        	else
        		if "A1_END1" $ aDados[1][i]
        			SA1->A1_COMPLEM	:= ConvString(aDados[2][i])
        		elseif "A1_NOME1" $ aDados[1][i]
        	   		SA1->A1_NOME := alltrim(SA1->A1_NOME)+" "+ConvString(aDados[2][i])
        		endif	
        	endif
		next
	
		if aScan(aDados[1],{|x| ALLTRIM(x) == "A1_TIPO"})==0
			SA1->A1_TIPO	:= "F"
		endif
		 
		if aScan(aDados[1],{|x| ALLTRIM(x) == "A1_CONTA"})==0
			SA1->A1_CONTA	:= "11211002"
		endif
	
		if aScan(aDados[1],{|x| ALLTRIM(x) == "A1_CODPAIS"})==0
			SA1->A1_CODPAIS	:= "01058"
		endif
	
		if aScan(aDados[1],{|x| ALLTRIM(x) == "A1_NREDUZ"})==0
			SA1->A1_NREDUZ	:= SA1->A1_NOME
		endif
		
		SA1->A1_RISCO	:= "A"
		
	SA1->(MsUnlock())
	

endif
	
Return({cCodCli,cLojaCli})

/*
Funcao      : CTODBRA
Parametros  : 
Retorno     :
Objetivos   : Converte Data em Formato EUA MM/DD/AAAA para BRA DD/MM/AAAA
Autor       : 
Data/Hora   : 
*/
*----------------------------*
Static Function CTODBRA(cData)
*----------------------------*
Local aData		:= {}

Default cData := ""

aData:= Separa(cData,"/",.T.)

cData := Strzero(Val(aData[2]),2,0)+"/"+Strzero(Val(aData[1]),2,0)+"/"+aData[3]

//Return SUBSTRING(cData,4,2)+"/"+SUBSTRING(cData,1,2)+"/"+SUBSTRING(cData,7,4)
Return cData

/*
Funcao      : GeraNota
Parametros  : 
Retorno     :
Objetivos   : Gera a nota fiscal do pedido
Autor       : 
Data/Hora   : 
*/
*-------------------------*
Static Function GeraNota()
*-------------------------*
Local lEstoque		:= .F.
Local cSerie		:= ""
Local cNumero		:= ""
Local lContOnline	:= .F.
Local lMostraLan	:= .F.
Local cLog			:= ""

//Avalia se existe alguma TES que movimenta estoque, neste caso grava somente pedido de venda 
//RRP - 15/05/2017 - Retirada da validação, pois a TES está fixa no fonte
/*If !lEstoque
	lEstoque := ( Posicione( 'SF4' , 1 , xFilial( 'SF4' ) + cTESPed , 'F4_ESTOQUE' ) == 'S' )
EndIf*/		


//Caso gravou pedido de venda e a TES nao movimenta estoque, gera nota fiscal de saida ( Prestacao de servicos ). 
//If !lEstoque

	/*
		** Liberacao do Pedido de Venda
	*/
	SC5->( DbSetOrder( 1 ) )
	SC5->( DbSeek( xFilial() + SC5->C5_NUM )) 
	cSerie := SUBSTR(SC5->C5_P_REF,AT("-",SC5->C5_P_REF)+1,3)
	cNumero:= SUBSTR(SC5->C5_P_REF,1,AT("-",SC5->C5_P_REF)-1)
	
	aPvlNfs:={} ;aBloqueio:={}
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)//Libera Pedidos  
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)//Verifica se há pedidos liberados
          
	If !Empty( aBloqueio )

		//Se houve algum bloqueio nao gera NF
		For i := 1 To Len( aBloqueio )
			cLogNota += "Pedido " + aBloqueio[ i ][ 1 ] + " - Produto " + aBloqueio[ i ][ 4 ] + " com bloqueio de credito. "  
		Next

	Else

		//Gera Nota Fiscal de Saida
		//Private cGtNumNf := PadL( AllTrim( ::aNotas[nI][03] ) , Len( SC5->C5_NUM ) , '0' ) 
		cRet := ""
		If SX5->( DbSetOrder( 1 ), DbSeek( xFilial() + PadR( '01' , Len( SX5->X5_TABELA ) ) + PadR( cSerie , Len( SX5->X5_CHAVE ) ) ) )
			
			SX5->( RecLock( "SX5" , .F. ) )
			SX5->X5_DESCRI := AllTrim( cNumero )
			SX5->( MSUnlock() )
			
			cRet := MaPvlNfs( aPvlNfs ,;
					  cSerie ,;
			          lMostraLan ,; //** Mostra Lancamentos Contabeis
			          .F. ,; //** Aglutina Lanuamentos
			          lContOnline ,; //** Cont. On Line ?
			          .F. ,; //** Cont. Custo On-line ?
			          .F. ,; //** Reaj. na mesma N.F.?
			          3 ,; //** Metodo calc.acr.fin? Taxa defl/Dif.lista/% Acrs.ped
			          1,; //** Arred.prc unit vist?  Sempre/Nunca/Consumid.final
			          .F.,;  //** Atualiza Cli.X Prod?
			          .F. ,,,,,,; //** Ecf ?
			          dDataBase )
		Else
				cLogNota += "Nota Fiscal "+ cRet + " Nao gerada . Serie " + cSerie + " nao parametrizada no sistema."+CRLF	
		EndIf		
		
		          
		If !Empty( cRet )
			cLogNota += "Nota Fiscal "+ cRet + " gerada com sucesso."+CRLF

			lGravou := .T.	   			

			//Adiciona o detalhe do log.
			//aAdd(aInfoLog,{"SF2",1,xFilial("SF2")+Right(cNumero,6),"I"})

			//Atualiza campo E1_P_IDC
			If SE1->(FieldPos("E1_P_IDC")) > 0			              
				TcSqlExec( "UPDATE " + RetSqlName( "SE1" ) + " SET E1_P_IDC = '" + SC5->C5_P_IDC + "' WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' AND " +;
							"E1_NUM = '" + cRet + "' AND E1_SERIE = '" + cSerie + "' AND E1_CLIENTE = '" + SC5->C5_CLIENTE + "' AND E1_LOJA = '" + SC5->C5_LOJACLI + "' " )														
			EndIf
   				
		Else
			cLogNota += "Nota Fiscal "+ cRet + " Nao gerada ."+CRLF				
		
		EndIf	   								                    
          
	EndIf
//EndIf

Return

/*
Funcao      : upArqServ
Parametros  : 
Retorno     :
Objetivos   : Subir arquivo para o servidor
Autor       : 
Data/Hora   : 
*/
*-----------------------------*
 Static Function upArqServ()
*-----------------------------*
Local cMascara  := "Arquivo | *.CSV"
Local cTitulo   := "Escolha o arquivo"
Local cDirini   := "C:\"

Local lSalvar   := .F. /*.F. = Salva || .T. = Abre*/
Local lArvore   := .F. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/
Local lSucesso	:= .F.

Local nOpcoes   := nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY )
Local nMascpad  := 1

Local aArquivo	:= {}

Local targetDir

targetDir := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If !Empty(targetDir)
	If File(targetDir+"\*.csv")
		//Adicionar os arquivos do diretorio ao array
		aArquivo:= Directory(targetDir+"\*.csv")
		
		For nR := 1 to Len(aArquivo)
			//Efetua o Upload do Arquivo para o Server.
			lSucesso:= __COPYFILE(targetDir+"\"+aArquivo[nR,1],cDirSrvIn+"\"+aArquivo[nR,1])
			
			//Caso aconteça algum erro ao copiar o arquivo
			If !lSucesso
				Exit
			EndIf
		Next nR
	
		If lSucesso
			MsgInfo("Arquivos copiados com sucesso para o servidor!", "HLB BRASIL")
		Else
			MsgInfo("Erro ao copiar o arquivo!", "HLB BRASIL")
		Endif
	Else
		MsgInfo("Nenhum arquivo encontrado no caminho especificado!", "HLB BRASIL")
	EndIf
EndIf

Return

/*
Funcao      : MailLog
Parametros  :
Retorno     :
Objetivos   : envia email de processamento
Autor       : Renato Rezende
Data/Hora   : 
*/
*----------------------------------------*
 Static Function MailLog()
*----------------------------------------*
Local i,nR

Local cFrom			:= AllTrim(GetMv("MV_RELFROM"))
Local cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
Local lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
Local cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
Local cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
Local cTo 			:= AllTrim(SuperGetMv( "MV_P_00101" , .F. , "" ,  ))//Email que será enviado o log de processamento.
Local cCC			:= ""
Local cToOculto		:= "" 
Local cAttachment 	:= ""
Local cArqMail 		:= ""
Local cSubject		:= "INTERFACE FILE PROCESSED - TWITTER "+DtoC(Date())

Private cMsg  := ""
Private cDate := DtoC(Date())
Private cTime := SubStr(Time(),1,5)
Private cUser := UsrFullName(RetCodUsr())

If Empty((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	Return .F.
EndIf

If Empty((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	Return .F.
EndIf

//Tratamento para envio do Arquivo de log anexo ao Email. 
for nR:=1 to len(aArqLog)
	cArqMail+= cDirSrvOut+"\"+aArqLog[nR]+";"
Next nR
cArqMail:= SubStr(cArqMail,1,Len(cArqMail)-1)

cAttachment	:= cArqMail

cMsg := Email()

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	Return .F.
Else
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			ConOut("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			Return .F.
		EndIf
	EndIf
	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
		SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK
	Else
		SEND MAIL FROM cFrom TO cTo BCC cToOculto;
		SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK
	EndIf
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+Alltrim(cTo))
		DISCONNECT SMTP SERVER
		Return .F.
	EndIf
EndIf

DISCONNECT SMTP SERVER

//Move o arquivo processado para a pasta 'processado'
for nR:=1 to len (aArqLog)
	If File( cDirSrvOut+"\"+aArqLog[nR])
		__COPYFILE(cDirSrvOut+"\"+aArqLog[nR],cDirSrvOut+"\processado\"+aArqLog[nR])
		FErase( cDirSrvOut+"\"+aArqLog[nR] ) 
	EndIf
Next nR

Return .T.       

/*
Funcao      : Email
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criar Email de Notificação
Autor       : Renato Rezende
Data/Hora   : 
*/
*---------------------*
Static Function Email()
*---------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>FILE PROCESSED</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+ALLTRIM(cUser)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25">
For nR:= 1 to len(aArqLog)
	cHtml += "<p>"+aArqLog[nR]+"</p>"
Next nR
cHtml += '				</td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Automatic message, no answer.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml