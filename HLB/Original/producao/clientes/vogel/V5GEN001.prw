#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"  
#Include "tbiconn.ch"

/*
Funcao      : V5GEN001
Parametros  : cChamada ( '1' => Integração Entrada , '2' => Integração Saída ( Default )
Retorno     : Nil
Objetivos   : Rotina de integração
Autor       : Leandro Brito\Renato Rezende
Data/Hora   : 22/07/2016
*/
*-----------------------------------*
User Function V5GEN001( cChamada )
*-----------------------------------*
//Variaveis locais.
Local i

//Controle Global no Fonte para saber qual a integração esta sendo gravada
Private nNATAtu := 0
Private cArqAtu := ""

//Verifica se a chamada foi de JOB ou não
Private lJob := (Select("SX3") <= 0)

//Parametros do FTP  //MSM - 07/04/2015 - Alterado para não trazer o ftp da produção quando não existir nos parâmetros

Private cPath 	:= GETMV("MV_P_FTP",,'10.0.30.35') //GETMV("MV_P_FTP",,"192.168.201.2")
Private clogin	:= GETMV("MV_P_USR",,'vogel') //GETMV("MV_P_USR",,"gt_twitter")
Private cPass	:= GETMV("MV_P_PSW",,'Vogel@gt123') //GETMV("MV_P_PSW",,"gt_twitter")

//Diretorios no FTP do cliente
Private cDirFtpIn := "/IN"
Private cDirFtpout:= "/OUT"

//Diretorio no Servido Protheus
Private cDirSrvIn := "\FTP\V5\IN"   
Private cDirSrvOut := "\FTP\V5\OUT"

//Email de Notificação de interface
Private cEmailA1 	:= GETMV("MV_P_00026",,"")
Private cEmailA5 	:= GETMV("MV_P_00027",,"")
Private cEmailZX 	:= GETMV("MV_P_00028",,"")
Private cEmailF2 	:= GETMV("MV_P_00029",,"")
Private cEmailE1 	:= GETMV("MV_P_00030",,"")

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

Private oGetDados

//Criação da referencia da integração com o Nome de Arquivo.
Private aRefArq 

//Tipo de arquivo ZIP.
Private cExtZip := "ZIP"

//Controle de Alteração na Rotina.
Private lonlyView	:= .F.         

Private aFilEmp := LoadFil()

//Controle de Status e Check de tela
Private oSelS	:= LoadBitmap( nil, "LBOK")
Private oSelN	:= LoadBitmap( nil, "LBNO") 
Private oStsok	:= LoadBitmap( nil, "BR_VERDE")
Private oStsAl	:= LoadBitmap( nil, "BR_LARANJA")
Private oStsEr	:= LoadBitmap( nil, "BR_VERMELHO")
Private oStsBr	:= LoadBitmap( nil, "BR_BRANCO")
Private oStsIn	:= LoadBitmap( nil, "BR_PRETO") 
Private oStsPr	:= LoadBitmap( nil, "BR_PRETO") 
Private aProcessados := {}

Default cChamada := '2' 

Private cInt     := cChamada  //** Para ser usado dentro das Users Functions


If ( cInt == '1' )  //** Entrada
	aRefArq:= {	{'04','COMPRAS_'	,{|| u_V5Est001('04') },"IN" , 'Integração Pedidos de Compras' },;
				{'05','FORNECEDOR_'	,{|| u_V5Est002('05') },"IN" , 'Integração de Fornecedores' },;
				{'02','PRODUTO_'	,{|| u_V5Fat002('02') },"IN" , 'Integração de Produtos' };
			 }
ElseIf ( cInt == '2' )  //** Saida
	aRefArq:= {	{'03','PEDIDO_'		,{|| u_V5Fat003('03') },"IN" , 'Integração de Pedidos'  },;
				{'01','CLIENTE_'	,{|| u_V5Fat001('01') },"IN" , 'Integração de Clientes' },;
				{'02','PRODUTO_'	,{|| u_V5Fat002('02') },"IN" , 'Integração de Produtos' };
			 } 
			 
ElseIf ( cInt == '3' )  //** Requisicoes
	aRefArq:= {	{'06','REQUISICOES_'		,{|| u_V5Est004('06') },"IN" , 'Integração Requisicoes de Estoque'  }}
			 
ElseIf ( cInt == '4' )  //** Recebimento
	aRefArq:= {	{'07','RECEBIMENTO_'		,{|| u_V5Est005('07') },"IN" , 'Integração Recebimento de Materiais'  } }			 			 

EndIf

//Criação dos arrays dos dados das integrações e Dos logs de erros
For i:=1 to Len(aRefArq)
	&("a"+aRefArq[i][1]) := {}
	&("aLog"+aRefArq[i][1]) := {}
Next i

//Cabeçalho dos Array de Erro.
NewCabLog()                     

If !( cEmpAnt $ u_EmpVogel() )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf

                              
//Busca os arquivos no Servidor FTP e coloca na pasta

ManuArqFTP("GET") 

//Chamada da interface grafica, somente quando não for JOB.
If !lJob
	Processa({|| MainGT() },"Processando aguarde...")
Else
	loadArq()
	SaveArq()
EndIf

Return .T.

*----------------------*
Static Function MainGT()
*----------------------*
Local i
Local aHeader,aCols
Private oDlg
Private oLayer	:= FWLayer():new()
Private aSize 	:= MsAdvSize()

Private aLegenda := {{"BR_BRANCO"	,"Integração Disponivel."},;
			   	  	{"BR_PRETO"		,"Integração Inativa."}}
			   	  	
Private aLegenda2 := {{"BR_VERDE"  		,"Integração Disponivel."},;
						{"BR_VERMELHO"	,"Integração Indisponivel."}}

Private aLegenda3 := {{"BR_VERDE"  		,"Recebido retorno."},;
						{"BR_VERMELHO"	,"Recebido Retorno com Erro."},;
						{"BR_BRANCO"	,"Aguardando Retorno."}}  
						
Private aLegenda4 := {{"BR_VERDE"  		,"Registro Aceito"},;
						{"BR_VERMELHO"	,"Registro Rejeitado"},;
						{"BR_BRANCO"	,"Nao processado"},;
						{"BR_PRETO"	,   "Ja Processado/CNPJ Invalido" }}																
						
//Criação da tela principal da integração
oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',25,.F.,'1')
oLayer:addCollumn('2',75,.F.,'1')

oLayer:addWindow('1','Win11','Menu'					,015,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('1','Win12','Tipos de Integrações'	,045,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('1','Win13','Legenda'		   			,040,.F.,.T.,{|| },'1',{|| })

oLayer:addWindow('2','Win21','Visualização'			,100,.F.,.T.,{|| },'1',{|| })


oWin11 := oLayer:getWinPanel('1','Win11','1')
oWin12 := oLayer:getWinPanel('1','Win12','1')
oWin13 := oLayer:getWinPanel('1','Win13','1')

oWin21 := oLayer:getWinPanel('2','Win21','1')

//Menu -----------------------------------------------------------------------------
oBtn1 := TBtnBmp2():New(02,0010,26,26,'FINAL'   	   	,,,,{|| oDlg:end()}											, oWin11,"Sair"	   		,,.T.)
If !lonlyView
	oBtn2 := TBtnBmp2():New(02,180,26,26,'PMSSETABOT'  	,,,,{|| ManuArqFTP("GET")}									, oWin11,"Download"		,,.T.)
	oBtn3 := TBtnBmp2():New(02,210,26,26,'PMSSETATOP'	,,,,{|| ManuArqFTP("PUT")}									, oWin11,"Upload"		,,.T.)
	oBtn4 := TBtnBmp2():New(02,240,26,26,'TK_REFRESH'   ,,,,{|| loadInt()}											, oWin11,"Buscar Arquivo"	,,.T.)
	oBtn5 := TBtnBmp2():New(02,270,26,26,'RPMSAVE'  	,,,,{|| Processa({|| SaveInt() },"Processando aguarde...")}	, oWin11,"Processar"	,,.T.)

	oBtn6 := TBtnBmp2():New(02,150,26,26,'FILTRO'   	,,,,{|| loadInt()}											, oWin11,"Filtro"		,,.T.)
	oBtn7 := TBtnBmp2():New(02,120,26,26,'SELECTALL'  	,,,,{|| MarcaButton()}	 									, oWin11,"Marca Todos"	,,.T.)
EndIf      

oBtn2:Hide()
oBtn3:Hide()
oBtn4:Show()
oBtn5:Show()
oBtn6:Hide()
oBtn7:Hide()

//Tipos de Integrações -------------------------------------------------------------
aHeader := {}
aCols	:= {}
AADD(aHeader,{ TRIM("Integração")	,"DES","@!  ",20,0,"","","C","",""})


If ( cInt == '1' )
	aAdd(aCols, {"01. Pedidos" 			,.F.})
	aAdd(aCols, {"02. Fornecedores"		,.F.})
	aAdd(aCols, {"03. Produtos" 			,.F.}) 
ElseIf ( cInt == '2' )
	aAdd(aCols, {"01. Pedidos" 			,.F.})
	aAdd(aCols, {"02. Clientes"		,.F.})
	aAdd(aCols, {"03. Produtos" 			,.F.})
ElseIf ( cInt == '3' )
	aAdd(aCols, {"01. Requisicoes" 			,.F.})
ElseIf ( cInt == '4' )
	aAdd(aCols, {"01. Recebimento" 			,.F.})
EndIf	

aAlter	:= {"STS"}

oGetDados := MsNewGetDados():New(01,01,(oWin12:NHEIGHT/2)-2,(oWin12:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAlter,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin12,aHeader, aCols, {|| MudaLinha()})


oGetDados:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oGetDados:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oGetDados:ForceRefresh()

TBmpRep():New(2,05,08,08,aLegenda4[ 1 ][ 1 ],.T.,oWin13)
@ 15,30 Say aLegenda4[ 1 ][ 2 ] OF oWin13 SIZE 50,10 PIXEL   

TBmpRep():New(3.5,05,08,08,aLegenda4[ 2 ][ 1 ],.T.,oWin13)
@ 25,30 Say aLegenda4[ 2 ][ 2 ] OF oWin13 SIZE 50,10 PIXEL   

TBmpRep():New(5,05,08,08,aLegenda4[ 3 ][ 1 ],.T.,oWin13)
@ 35,30 Say aLegenda4[ 3 ][ 2 ] OF oWin13 SIZE 50,10 PIXEL   

TBmpRep():New(6.5,05,08,08,aLegenda4[ 4 ][ 1 ],.T.,oWin13)
@ 45,30 Say aLegenda4[ 4 ][ 2 ] OF oWin13 SIZE 100,10 PIXEL  

//Visualização -------------------------------------------------------------
For i:=1 to Len(aRefArq)
	Private &("aHArq"+aRefArq[i][1]) := {}
	Private &("aCArq"+aRefArq[i][1]) := {}
	Private &("aAArq"+aRefArq[i][1]) := {}

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
Local nLenSx3 := Len( SX3->X3_CAMPO )

Default lGetaCpos := .F.

AADD(aRet,{ TRIM("Sts.")			,"STS","@BMP",02,0,"","","C","",""})
AADD(aRet,{ 'Empresa'			,"WKEMP","",14,0,"","","C","",""}) 
AADD(aRet,{ "Arquivo","ARQ_ORI","",40,0,"","","C","",""})

aCpos := u_V5RetCmp( cTipoInt )

For i:=1 to Len(aCpos)
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(Left(aCpos[i],nLenSx3)))
		AADD(aRet,{ TRIM(SX3->X3_TITULO),"WK"+SX3->X3_CAMPO,;
							/*SX3->X3_PICTURE*/"",SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
	Else
		AADD(aRet,{ TRIM(aCpos[i]),"WK"+SUBSTR(aCpos[i],AT("_",aCpos[i]),50),"",20,0,"","","C","",""})			
	EndIf
Next i
		

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

//Atualiza o Tipo de edição para a integração de Invoice.

//Atualiza a Visualizações
oArqView:LVISIBLECONTROL := .F.

//Troca o Browse de arquivos ---------------------------------
For i:=1 to len(aRefArq)
	&("oArq"+aRefArq[i][1]):OBROWSE:LVISIBLECONTROL := .F.
Next i
&("oArq"+aRefArq[oGetDados:NAT][1]):OBROWSE:LVISIBLECONTROL := .T.


Return .T.

/*
Funcao      : ManuArqFTP()  
Parametros  : cOpc *
Retorno     : Nil
Objetivos   : Função responsavel por manipular os arquivos no FTP.
Autor       : Jean Victor Rocha
Data/Hora   : 
* ATENÇÃO:
Get - Efetua o Download dos arquivos do FTP	; ou seja, Pegamos na Pasta de Entrada do Cliente e colocamos na Nossa pasta de entrada.
Put - Efetua o Upload dos arquivos no FTP	; ou seja, Pegamos na nossa Pasta de Saida e colocamos na pasta de Saida do cliente.
*/
*--------------------------------------------*
Static Function ManuArqFTP(cOpc,aArqProc,lLog)
*--------------------------------------------*
Local i
Local cDirFtpAtu	:= ""
Local cDirSrvAtu	:= ""
Local lConnect		:= .F.
Local aArqFTP		:= {}

Local aArqServer	//:= DIRECTORY(cDirFtpIn+"\*.CSV" , ) 
Local aAuxFtp

Default aArqProc 	:= {} 
Default lLog := .T.

//Conexao com o FTP informado nos paramentros.
For i:=1 to 3// Tenta 3 vezes.
	lConnect := ConectaFTP()
	If lConnect
 		i:=3
   	EndIf
Next
If !lConnect
	If lJob
   		Conout("V5GEN001 - Não foi possivel estabelecer conexão com FTP!")		
	Else
		MsgAlert("Não foi possivel estabelecer conexão com FTP.","HLB BRASIL")
	EndIf
 	Return .F.
EndIf   

//Definição do Tipo de atualização que sera feita. (Upload ou Download)
Do Case 

	Case cOpc == "GET"
		cDirFtpAtu	:= cDirFtpIn
		cDirSrvAtu	:= cDirSrvIn

		//Monta o diretório do FTP.
		FTPDirChange(cDirFtpAtu)

		//Carregar os arquivos que estão no FTP somente da integração selecionada
		aAuxFtp := {}
		//aArqFTP := FTPDIRECTORY("*.*",) 
		aArqFTP := {}
		For i := 1 To Len( aRefArq )
			aAuxFtp := FTPDIRECTORY(aRefArq[i][2]+"*.*",)
			For j := 1 To Len( aAuxFtp )
				AAdd( aArqFTP , aAuxFtp[ j ] )
			Next 
		Next		

	Case cOpc == "PUT"
		cDirFtpAtu	:= cDirFtpOut
		cDirSrvAtu	:= cDirSrvOut

		//Monta o diretório do FTP.
		FTPDirChange(cDirFtpAtu)

		/*
			* Carrega para o evento "PUT" somente os arquivos que foram processados, ou seja, que foram gravados na ZX2 atraves do array 'aProcessados'
		*/                                                                                                                                             
		aArqServer := aClone( aProcessados )

EndCase          


Do Case
	Case cOpc == "GET"
		//Compata arquivos atuais na pasta somente se tiver um novo no FTP.
		
		//Efetua o Download do Arquivo do FTP para o Server.
		For i:=1 to Len(aArqFTP) 
			If File( cDirSrvAtu+"\"+aArqFTP[i][1])
				FErase( cDirSrvAtu+"\"+aArqFTP[i][1]) 			
			EndIf
			FTPDownLoad(cDirSrvAtu+"\"+aArqFTP[i][1],Upper(aArqFTP[i][1]))
			//FTPErase(aArqFTP[i][1])
		Next i

	Case cOpc == "PUT"
		
		//Efetua o Upload do Arquivo do Server para o FTP.
		For i:=1 to Len(aArqServer)
		   
			
			If RIGHT(aArqServer[i][1],3) <> cExtZip
				/*
					* Se fez a copia do arquivo de Log para o FTP
				*/
				FTPDirChange(cDirFtpAtu)

				If FTPUpload(cDirSrvAtu+"\"+aArqServer[i][1],aArqServer[i][1]) 
					
					/*
						**	Retira o arquivo de entrada do Ftp
					*/                                        
					If lLog
						cArqEnt := aArqServer[i][2]
						FTPDirChange(cDirFtpIn)
						If FTPErase(cArqEnt)
						
							/*
								** Move o arquivo de entrada e saida do server para a pasta 'processado'
							*/
							If File( cDirSrvIn+"\"+cArqEnt )
								__COPYFILE(cDirSrvIn+"\"+cArqEnt,cDirSrvIn+"\processado\"+cArqEnt)
								FErase( cDirSrvIn+"\"+cArqEnt ) 
							EndIf  
	
							If File( cDirSrvOut+"\"+aArqServer[i][1] )
								__COPYFILE(cDirSrvOut+"\"+aArqServer[i][1],cDirSrvOut+"\processado\"+aArqServer[i][1])
								FErase( cDirSrvOut+"\"+aArqServer[i][1] ) 
							EndIf	

						EndIf
					Else	
						If File( cDirSrvOut+"\"+aArqServer[i][1] )
							__COPYFILE(cDirSrvOut+"\"+aArqServer[i][1],cDirSrvOut+"\processado\"+aArqServer[i][1])
							FErase( cDirSrvOut+"\"+aArqServer[i][1] ) 
						EndIf						
					EndIf
				EndIf
				
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
		Conout("V5GEN001 - Falha ao carregar diretórios FTP no Servidor!")
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
Local aCols := {}
Local aHeader := {}  
Local aAuxCols
Local nInd        
Local aAuxServer

Local oFT   := fT():New()//FUNCAO GENERICA 
Local cEmpresa 
Local nLenSx3 := Len( SX3->X3_CAMPO )
//Executa a limpeza da variavel com os dados e da tela, caso não for Job.
For i:=1 to Len(aRefArq)
	&("a"+aRefArq[i][1]) := {}
	&("oArq"+aRefArq[i][1]):ACOLS := {}
	aAdd(&("aCArq"+aRefArq[i][1]),Array(Len(&("aHArq"+aRefArq[i][1]))+1))
	&("aCArq"+aRefArq[i][1])[1][LEN(&("aCArq"+aRefArq[i][1])[1])] := .F.
	&("oArq"+aRefArq[i][1]):ForceRefresh()
Next i    

//Carrega arquivos do Servidor Protheus
//aArqServer	:= DIRECTORY(cDirSrvAtu+"\*.CSV",)
//Carrega arquivos do Servidor Protheus
aAuxServer := {}        
aArqServer := {}
//aArqServer	:= DIRECTORY(cDirSrvAtu+"\*.CSV",)
For i := 1 To Len( aRefArq )
	aAuxServer := DIRECTORY(cDirSrvAtu+"\"+aRefArq[i][2]+"*.CSV",)
	For j := 1 To Len( aAuxServer )
		AAdd( aArqServer , aAuxServer[ j ] )
	Next 
Next

aArqServer	:= aSort( aArqServer )
//Carrega as Infromações do Arquivo.
If lJob
	cTipoInt := "IN"
Else
	cTipoInt := aRefArq[oGetDados:NAT][4]
EndIf

If cTipoInt == "IN"
	For i:=1 to len(aArqServer)
		aArquivo := {}
        
		//Leitura do arquivo de tratamento.
		oFT:FT_FUse(cDirSrvAtu+"\"+aArqServer[i][1])
		//Deixando na primeira linha do arquivo
		oFT:FT_FGoto(1)
		While !oFT:FT_FEof()
			cLinha := oFT:FT_FReadln()
			If AT(cDelimitador,cLinha) <> 0
				aAdd(aArquivo, separa(UPPER(cLinha),cDelimitador))// Sepera para vetor e adiciona no array de arquivo.
			EndIf                          
			aAdd(aArquivo[Len(aArquivo)],aArqServer[i][1])
	        oFT:FT_FSkip() // Proxima linha
		Enddo
		oFT:FT_FUse() // Fecha o arquivo 


		If (nPos := aScan(aRefArq, {|x| ALLTRIM(x[2]) == ALLTRIM(SUBSTR(aArqServer[i][1],1,AT("_",aArqServer[i][1]))) } )  ) <> 0

			If LEN(&("a"+aRefArq[nPos][1])) == 0
				&("a"+aRefArq[nPos][1]) := aArquivo
			Else
				If LEN(aArquivo) >= 2 //RRP - 04/08/2016 - Ajuste para pegar caso tenha mais de 1 item no arquivo
					For j:=2 to Len(aArquivo)  //RRP - 28/07/2016 - Ajustado para a segunda linha quando contiver mais de 1 arquivo
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
			

			aCols    := &("a"+aRefArq[i][1])
			aGetCols := &("oArq"+aRefArq[i][1]):ACOLS
			aGetCols := {}
			 
			aHeader := &("oArq"+aRefArq[i][1]):aHeader
			nPosArq := aScan(aHeader,{|x|x[2]=="ARQ_ORI" })
			

			
			//Executa somente se tiver dados no array
				//Verifica se existe quantidade de linhas maior que somente os Titulos dos campos.
				If Len(aCols) > 1
					//Reseta os dados da Tela, ACOLS.
	
					aFields := aCols[ 1 ]
					nPosEmp := Ascan( aFields , "EMP" ) 
						
					For j:=2 to len(aCols)


						//Adiciona uma nova linha no Acols.
						//Executa para cada linha do arquivo, iniciando o For nos dados
						aAdd(aGetCols,Array(Len(aHeader)+1))
						nLenCols := Len( aGetCols )
	   					
	   					aGetCols[nLenCols][LEN(aHeader)+1] := .F.
						//Executa para cada campo enviado no arquivo.
						aGetCols[ nLenCols ][1] := oStsBr

						For h:=2 to len(aHeader)
							//Caso o campo informado no arquivo exista na tela, preenche, caso contrario não.
							If (nPos := Ascan( aFields , { | x | Alltrim( Left( x , nLenSx3 ) ) == AllTrim( StrTran( aHeader[ h ][ 2 ] , "WK" , '' ) ) } ) ) > 0 
								aGetCols[nLenCols][h] := If( aHeader[ h ][ 8 ] == 'N' , Val( aCols[j][nPos] ) ,;
														 If( aHeader[ h ][ 8 ] == 'D' , CtoD( aCols[j][nPos] ) , u_V5ConvStr( aCols[j][nPos] ) ) )
							EndIf
						Next h
						If nPosArq <> 0
							aGetCols[ nLenCols ][nPosArq] := aCols[j][Len(aCols[j])]
							If ViewZX2( aGetCols[ nLenCols ][nPosArq]  ) .Or. ;
								Left( aCols[ j ][ nPosEmp ] , 10 ) <> Left( SM0->M0_CGC , 10 ) .Or. ; 
								Empty( u_V5RetFil( aCols[ j ][ nPosEmp ]  )  )
		      				
		      					aGetCols[ nLenCols ][1] := oStsPr
    	                    
    	                    EndIf							
						EndIf
					Next j
				EndIf               
			
			/*
				* Somente para ordenar pela imagem, pois a ASort nao ordena objeto
			*/
			aAuxCols := {}
			For nInd := 1 To Len( aGetCols )
				If aGetCols[ nInd ][ 1 ]:cName == 'BR_BRANCO' 
					Aadd( aAuxCols , aClone( aGetCols[ nInd ] ) )
				EndIf
			Next  
			
			For nInd := 1 To Len( aGetCols )
				If aGetCols[ nInd ][ 1 ]:cName <> 'BR_BRANCO' 
					Aadd( aAuxCols , aClone( aGetCols[ nInd ] ) )
				EndIf
			Next 	   
			
			aGetCols := aClone( aAuxCols )		
			
			&("oArq"+aRefArq[i][1]):aCols := aClone( aGetCols )	
			&("oArq"+aRefArq[i][1]):ForceRefresh()
			&("oArq"+aRefArq[i][1]):oBrowse:Refresh()
			
						
		Next i
	EndIf
		
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
Local cTipoInt := "IN"
Local cMsgPerg := ""
Local aArquivos := {}    

//Zera os arquivos de LOG.
NewCabLog()


//Controla o Tipo de Integração que sera realizada
If !lJob
	cTipoInt := aRefArq[oGetDados:NAT][4]
EndIf


If ( cInt == '1' ) 
	cMsgPerg := "Serão importados os arquivos de Fornecedores, Produtos e Pedidos de Compras, Deseja Continuar?"
ElseIf ( cInt == '2' ) 
	cMsgPerg := "Serão importados os arquivos de Clientes, Produtos e Pedidos de Vendas, Deseja Continuar?"
ElseIf ( cInt == '3' ) 
	cMsgPerg := "Serão importados os arquivos de Requisicoes de Estoque, Deseja Continuar?"	
ElseIf ( cInt == '4' ) 
	cMsgPerg := "Serão importados os arquivos de Recebimento de Materiais, Deseja Continuar?"	
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
					If !ViewZX2(&("a"+aRefArq[i][1])[1])
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
		//For i:=1 to len(aRefArq) 
		For i:=len(aRefArq) to 1 Step -1 
			If aRefArq[i][4] == cTipoInt
				cArqAtu := ""
				If Len(&("a"+aRefArq[i][1])) >= 2
					
			   		Eval(aRefArq[i][3])
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
			If aRefArq[i][4] = "IN"
				If LEN(&("aLog"+aRefArq[i][1])) > 1
					GeraLog(&("aLog"+aRefArq[i][1]) )
				EndIf
			EndIf	
		Next i

	EndIf
    
	ManuArqFTP("PUT") 
    
EndIf

Return .T. 

/*
Funcao      : GeraLog
Parametros  : 
Retorno     :
Objetivos   : Função para a geração do arquivo de LOG na pasta Out do FTP no SERVER.
Autor       : Leandro Brito
Data/Hora   : 
*/
*----------------------------*
Static Function GeraLog(aInfo,lLog)
*----------------------------*
Local i,j,k
Local nHdl	:= 0
Local cLinha := ""
Local cArqLog := "" 
Local cHeader := ''

Local aArquivos := aInfo //GetNameArq(aInfo)    
Default lLog := .T.

/*
	* Montagem do Header do arquivo retorno
*/
For k := 1 To Len( aArquivos[ 1 ][ 2 ] )
	If !Empty( cHeader )
		cHeader += cDelimitador 		
	EndIf
	cHeader += aArquivos[ 1 ][ 2 ][ k ]
Next     
	
For k:=2 to Len(aArquivos)
	
	//Criação do nome do arquivo de LOG referente ao Arquivo.
	If lLog
		cArqLog := ""
		cArqLog += SUBSTR(aArquivos[k][1],1,AT("_",aArquivos[k][1]))
		cArqLog += "LOG"
		cArqLog += SubStr(aArquivos[k][1],AT("_",aArquivos[k][1]),Len(aArquivos[k][1]))
		cArqLog := cArqLog
	Else
		cArqLog  := aArquivos[k][1]
	EndIf 
	
	cArqLog := cArqLog     
	
	//Validação de arquivo não existente
	If File(cDirSrvOut+"\"+cArqLog)
		FErase(cDirSrvOut+"\"+cArqLog)
	EndIf
	
	nHdl := FCreate(cDirSrvOut+"\"+cArqLog,0 )
	FWrite(nHdl, cHeader+ Chr( 13 ) + Chr( 10 ))
	
	For j:=1 to Len(aArquivos[k][2])
		cLinha := ""
		For l:=1 To Len( aArquivos[k][2][l])
			If !Empty( cLinha )
				cLinha += cDelimitador 		
			EndIf
			cLinha += ALLTRIM(aArquivos[k][2][j][l])
		Next l	
		FWrite(nHdl, cLinha+Chr( 13 ) + Chr( 10 ))
	Next j

	FClose(nHdl)
	
	GrvTabLog(aArquivos[k][1] )
	Aadd( aProcessados , { cArqLog , aArquivos[k][1] } ) //** Este array serve para apagar os arquivos processados e mover pra pasta OUT do FTP	
	//MailLog(aArquivos[k][1],aInfo)
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

If AliasInDic( 'ZX2' )
	ZX2->(DbSetOrder(1))
	ZX2->(RecLock("ZX2",.T.))
	ZX2->ZX2_FILIAL := xFilial("ZX2")
	ZX2->ZX2_COD := STRZERO(ZX2->(Recno()),9)
	ZX2->ZX2_ARQ := UPPER(cNomeArq)
	ZX2->ZX2_DATA := Date()
	ZX2->ZX2_HORA := Time()
	ZX2->ZX2_USER := cUserName
	ZX2->(MsUnlock()) 
EndIf

Return .T.

/*
Funcao      : ViewZX2
Parametros  : 
Retorno     :
Objetivos   : Verifica se o arquivo ja consta no Log de processados.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function ViewZX2(cArq)
*---------------------------*
Local lRet := .F.

ZX2->( DbSetOrder( 2 ) )
lRet := ZX2->( DbSeek( xFilial() + cArq ) )

Return lRet





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

aProcessados := {}

Return .T.


/*
Funcao      : ClieTw
Parametros  :
Retorno     :
Objetivos   : Buscar infromações do cliente pelo ID proprio
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
User Function V5ClieTw(cId,cCGC)
*------------------------------*
Local aArea := GetArea()
Local aRet := {}   

Default lOnlyView := .F.
Default cId := ""
Default cCgc := ""

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif                   

//cQuery := " Select Top 1 *"
cQuery := " Select Top 1 A1_COD,A1_LOJA"
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

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif                   

RestArea( aArea )

Return aRet


/*
Funcao      : MailLog
Parametros  :
Retorno     :
Objetivos   : envia email de processamento
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*----------------------------------------*
Static Function MailLog(cArqLog, aLogMail)
*----------------------------------------*
Local i
Local cQuery := ""

Local cArqMail := ""

Private nOk := 0
Private nErro := 0

Private cFrom		:= "totvs@hlb.com.br"
Private cTo			:= ""
Private cMsg		:= ""
Private cSubject	:= Capital(SUBSTR(cArqLog,4,AT("OB",cArqLog)-5)+" INTERFACE")

Private cArq  := UPPER(LEFT(cArqLog,LEN(cArqLog)-3))+LOWER(RIGHT(cArqLog,3))
Private cDate := ""
Private cTime := ""
Private cUser := ""

Do Case
	Case SUBSTR(cArqLog,4,AT("OB",cArqLog)-5) == "CUSTOMER"
		cTo := cEmailA1

	Case SUBSTR(cArqLog,4,AT("OB",cArqLog)-5) == "SALESORDER"
		cTo := cEmailA5

	Case SUBSTR(cArqLog,4,AT("OB",cArqLog)-5) == "CAMPAIGNS"
		cTo := cEmailZX

	Case SUBSTR(cArqLog,4,AT("IB",cArqLog)-5) == "INVOICE"
		cTo := cEmailZX

	Case SUBSTR(cArqLog,4,AT("IB",cArqLog)-5) == "RECEIPTS"
		cTo := cEmailZX

EndCase

//Realiza a contagem dos Logs para montagem do Email
If aRefArq[oGetDados:NAT][4] == "IN"
	If Len(aLogMail) > 2
		For i:=3 to Len(aLogMail)
			If ALLTRIM(aLogMail[i][aScan(aLogMail[2],{|x| ALLTRIM(UPPER(x)) == "FILE"})]) == ALLTRIM(cArqLog) 
				If aLogMail[i][aScan(aLogMail[2], {|x| ALLTRIM(UPPER(x)) == "SEQ"})] == "1"
					If aLogMail[i][aScan(aLogMail[2], {|x| ALLTRIM(UPPER(x)) == "STATUS"})] == "S"
			   			nOk	++
			  		Else
						nErro ++
					EndIf
				EndIf
			EndIf
		Next i
	EndIf
Else
	cSubject := Capital(SUBSTR(cArqLog,4,AT("IB",cArqLog)-5)+" INTERFACE")
	nOk	:= aLogMail[2]
EndIf

//Busca os dados do log gravado
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif  
cQuery := " Select *"
cQuery += " From "+RETSQLNAME("ZX2")
cQuery += " Where ZX2_ARQ = '"+ALLTRIM(UPPER(cArqLog))+"'
cQuery += " 	AND D_E_L_E_T_ <> '*'

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

QRY->(DbGoTop())
If QRY->(!EOF())
	cDate := DTOCEUA(STOD(QRY->ZX2_DATA))
	cTime := QRY->ZX2_HORA
	cUser := QRY->ZX2_USER
EndIf
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif 

//Tratamento para envio do Arquivo de log anexo ao Email. 
cArqMail := ""
cFile := ""
cArqZip := ""

cArqMail += SUBSTR(cArqLog,1,AT("_",cArqLog)+2)
cArqMail += "LOG"
cArqMail += SubStr(cArqLog,AT("_",cArqLog)+2,Len(cArqLog))
cArqMail := UPPER(cArqMail)

cFile	:= cDirSrvOut+"\"+cArqMail
If AT("_",cFile) <> 0//compacta somente quando for processamento de entrada.
	cArqZip	:= cDirSrvOut+"\"+LEFT(cArqMail,LEN(cArqMail)-3)+"ZIP"
	compacta(cFile,cArqZip,.F.)
EndIf

cMsg := Email()

oEmail          := DEmail():New()
oEmail:cFrom   	:= cFrom
oEmail:cTo		:= PADR(cTo,200)
oEmail:cSubject	:= padr(cSubject,200)
If File(cArqZip)
	oEmail:cAnexos := cArqZip
EndIf
oEmail:cBody   	:= cMsg
oEmail:lExibMsg := .F.
oEmail:Envia()

If File(cArqZip)
	FERASE(cArqZip)
EndIf

Return .T.       

/*
Funcao      : Email
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Criar Email de Notificação
Autor       : Jean Victor Rocha
Data/Hora   : 
Autor       : Jean Victor Rocha	
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
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>FILE PROCESSED '+cArq+'</b></font>   </td>
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
If aRefArq[oGetDados:NAT][4] == "IN"
	cHtml += '					<br><font size="2" face="tahoma">'+ALLTRIM(STR(nOk))	+' records processed successfully </font>
	cHtml += '					<br><font size="2" face="tahoma">'+ALLTRIM(STR(nErro))	+' records processed with errors</font>

Else
	cHtml += '					<br><font size="2" face="tahoma">'+ALLTRIM(STR(nOk))	+' records processed successfully </font>

EndIf
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

/*
Funcao      : V5ConvStr
Parametros  : 
Retorno     :
Objetivos   : Retira caracteres invalidos da string
Autor       : Jean Victor Rocha
Data/Hora   : 11/12/2014
*/
*-------------------------------*
User Function V5ConvStr(cInfo)
*-------------------------------* 
Local i
Local cRet := ""

//RPB - 17/04/2017 - Ajuste para retirar os espaços.
cRet := Alltrim(FwNoAccent(DecodeUTF8(cInfo)))

Return UPPER(cRet)

/*
Funcao      : MarcaButton
Parametros  : 
Retorno     :
Objetivos   : Função de marca de desmarca todos.
Autor       : Jean Victor Rocha
Data/Hora   : 25/05/2015
*/
*---------------------------*
Static Function MarcaButton()
*---------------------------* 
Local i
Local oSelBtn
Local lAlterado := .F.

If UPPER(LEFT(oBtn7:CTOOLTIP,3)) == "MAR"
	oSelBtn := oSelS
Else
	oSelBtn := oSelN
EndIf

For i:=1 to len(&("oArq"+aRefArq[oGetDados:NAT][1]):aCols) 
	If &("oArq"+aRefArq[oGetDados:NAT][1]):aCols[i][2] == oStsok
		&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[i][1] := oSelBtn
		lAlterado := .T.
	Else 
		&("oArq"+aRefArq[oGetDados:NAT][1]):aCols[i][1] := oSelN
	Endif
Next i

&("oArq"+aRefArq[oGetDados:NAT][1]):ForceRefresh()

If !lAlterado
	oBtn7:CTOOLTIP := "Desmarca Todos"
	oBtn7:LoadBitmaps("UNSELECTALL")
	MsgInfo("Não foi encontrado registros permitidos para seleção!","HLB BRASIL")
Else
	If UPPER(LEFT(oBtn7:CTOOLTIP,3)) == "MAR"
		oBtn7:CTOOLTIP := "Desmarca Todos"
		oBtn7:LoadBitmaps("UNSELECTALL")
	Else
		oBtn7:CTOOLTIP := "Marca Todos"
		oBtn7:LoadBitmaps("SELECTALL")
	EndIf
EndIf

Return .T.

/*
Funcao      : V5RetCmp
Parametros  : cTipoInt => codigo da integração , lObrigat => retornar somente obrigatorios
Retorno     :
Objetivos   : Retornar campos da integração
Autor       : Leandro Diniz de Brito
Data/Hora   : 25/07/2016
*/
*-----------------------------------------------* 
User Function V5RetCmp( cTipoInt , lObrigat ) 
*-----------------------------------------------*
Local aCampos := {} 
Local aRet    := {} 

Default lObrigat := .F.

//RRP - 04/08/2016 - Retirada natureza, conta, complemento obrigatoria                   
If ( cTipoInt == '01' )  
	aCampos := { { 'A1_FILIAL'	, .F. },;
				{ 'A1_P_ID' 	, .T. },;
				{ 'A1_NOME' 	, .T. },;
				{ 'A1_PESSOA' 	, .T. },;
				{ 'A1_NREDUZ' 	, .T. },; 
				{ 'A1_TIPO' 	, .T. },;
				{ 'A1_END' 		, .T. },;
				{ 'A1_COMPLEM' 	, .F. },;
				{ 'A1_EST' 		, .T. },;
				{ 'A1_BAIRRO' 	, .T. },;
				{ 'A1_CEP' 		, .T. },;
				{ 'A1_CGC' 		, .T. },;
				{ 'A1_NATUREZ' 	, .F. },;
				{ 'A1_COD_MUN' 	, .T. },;
				{ 'A1_MUN' 		, .T. },;
				{ 'A1_CONTA' 	, .F. },;
				{ 'A1_CODPAIS'	, .T. },;
				{ 'A1_EMAIL'	, .T. },;
				{ 'A1_TPESSOA' 	, .T. },;
				{ 'A1_INSCR'	, .F. },;
				{ 'A1_INSCRM'	, .F. }}

ElseIf ( cTipoInt == '02' )
	aCampos := { { 'B1_FILIAL' 	, .F. },;
			    { 'B1_COD'   	, .T. },;
			    { 'B1_DESC'  	, .T. },;
			    { 'B1_TIPO'  	, .T. },;
			    { 'B1_UM'   	, .T. },; 
			    { 'B1_LOCPAD'	, .F. },;
			    { 'B1_PICM'		, .F. },;
			    { 'B1_IPI'		, .F. },;
			    { 'B1_POSIPI'	, .T. },;
			    { 'B1_CONTA'	, .F. },;
			    { 'B1_ORIGEM'	, .F. },;                                    
			    { 'B1_IMPORT'	, .T. },;
			    { 'B1_P_TIP'	, .T. },;
			    { 'B1_GARANT'	, .T. },;
			    { 'B1_COFINS'	, .F. },;
			    { 'B1_CSLL'		, .F. },;
			    { 'B1_PIS'  	, .F. },;
			    { 'B1_ALIQISS' 	, .F. },;
			    { 'B1_CODISS' 	, .F. },;
			    { 'B5_NBS' 		, .F. }}

ElseIf ( cTipoInt == '03' )
		aCampos := { { 'C5_FILIAL' , .F. },;	
				{ 'C5_P_REF' , .T. },;  					
				{ 'C5_TIPO' , .T. },;     	
				{ 'C5_TIPOCLI' , .T. },;  	
				{ 'C5_CONDPAG' , .T. },; 	
				{ 'C5_EMISSAO' , .T. },;  	
				{ 'C5_MENNOTA' , .F. },;	
				{ 'C5_P_CONSU' , .T. },;	
				{ 'C6_ITEM' , .T. },;
				{ 'C6_PRODUTO' , .T. },;
				{ 'C6_DESCRI' , .T. },;
				{ 'C6_QTDVEN' , .T. },;
				{ 'C6_PRCVEN' , .T. },;
				{ 'C6_VALOR' , .T. },;
				{ 'C6_VALDESC' , .F. },;
				{ 'C6_TES' , .F. },;
				{ 'C6_LOCAL' , .T. },;
				{ 'A1_CGC' , .T. },;
				{ 'C5_P_BOL' , .T. },;
				{ 'C5_P_DTINI' , .T. },;
				{ 'C5_P_DTFIM' , .T. },;
				{ 'C5_P_AM' , .T. },;
				{ 'C5_P_CONTA' , .F. },;
				{ 'C5_P_CID' , .T. } ,;
				{ 'C5_P_PROJ' , .F. },;
				{ 'C5_P_REG' , .F. }; 				
				}

ElseIf ( cTipoInt == '04' ) 
		aCampos := { { 'C7_FILIAL' , .F. },;	
				{ 'C7_NUM' 			, .F. },;  					
				{ 'C7_P_REF' 		, .T. },;     	
				{ 'C7_COND' 		, .T. },;  	
				{ 'A2_CGC' 			, .T. },;  	
				{ 'C7_ITEM' 		, .T. },;	
				{ 'C7_PRODUTO' 		, .T. },;	
				{ 'C7_LOCAL' 		, .T. },;
				{ 'C7_EMISSAO' 		, .T. },;
				{ 'C7_QUANT' 		, .T. },;
				{ 'C7_PRECO' 		, .T. },;
				{ 'C7_TOTAL' 		, .T. },;
				{ 'C7_P_PROJ'		, .F. },;
				{ 'C7_P_REG' 		, .F. },;
				{ 'C7_CC' 			, .F. };
				}

ElseIf ( cTipoInt == '05' )  
		aCampos := { { 'A2_FILIAL' , .F. },;	
				{ 'A2_P_ID' , .T. },;  					
				{ 'A2_NOME' , .T. },;     	
				{ 'A2_TIPO' , .T. },;  	
				{ 'A2_CGC' , .T. },;  	
				{ 'A2_NREDUZ' , .T. },;	
				{ 'A2_END' , .T. },;	
				{ 'A2_COMPLEM' , .F. },;
				{ 'A2_EST' , .T. },;
				{ 'A2_BAIRRO' , .T. },;
				{ 'A2_CEP' , .T. },;
				{ 'A2_CGC' , .T. },;
				{ 'A2_NATUREZ' , .F. },;
				{ 'A2_COD_MUN' , .T. },;
				{ 'A2_MUN' , .T. } ,;
				{ 'A2_CONTA' , .F. } ,;
				{ 'A2_CODPAIS' , .T. } ,;
				{ 'A2_EMAIL' , .T. } ,;
				{ 'A2_TPESSOA' , .T. }, ;																				
				{ 'A2_PAIS' , .T. } } 
				
ElseIf ( cTipoInt == '06' )  
		aCampos := { { 'ZX1_FILIAL' , .F. },;	
				{ 'ZX1_P_REF' , .T. },;  					
				{ 'ZX1_DATA' , .T. },;     	
				{ 'ZX1_ITEM' , .T. },;  	
				{ 'ZX1_PRODUT' , .T. },;  	
				{ 'ZX1_QUANT' , .T. },;	
				{ 'ZX1_P_PROJ' , .F. },;
				{ 'ZX1_P_REG' , .F. } }
				
ElseIf ( cTipoInt == '07' )  
		aCampos := { { 'ZX0_FILIAL' , .F. },;	
				{ 'ZX0_P_REF' , .T. },;  					
				{ 'ZX0_DOC' , .T. },;     	
				{ 'ZX0_SERIE' , .T. },;  	
				{ 'ZX0_EMISSA' , .T. },;  	
				{ 'ZX0_DATA' , .T. },;	
				{ 'ZX0_CGC' , .T. },;	
				{ 'ZX0_ITEM' , .T. },;
				{ 'ZX0_PRODUT' , .T. },;
				{ 'ZX0_QUANT' , .T. },;
				{ 'ZX0_P_PROJ' , .F. },;
				{ 'ZX0_P_REG' , .F. };																				
				}								

EndIf   

AEVal( aCampos , { | x,y | If( !lObrigat .Or. ( lObrigat .And. x[ 2 ] )  , Aadd( aRet , x[ 1 ] ) , ) } )

Return( aRet )

*------------------------------------*
Static Function LoadFil               
*------------------------------------*
Local nRec := SM0->( Recno() )
Local cEmpAtu := SM0->M0_CODIGO 
Local aRet 		:= {}

SM0->( DbGoTop() )
While SM0->( !Eof() )
	If ( SM0->M0_CODIGO == cEmpAtu ) 
		Aadd( aRet , { SM0->M0_CGC , SM0->M0_CODFIL } )	
	EndIf
	SM0->( DbSkip() )
EndDo                              

SM0->( DbGoTo( nRec ) )

Return( aRet )

*------------------------------------*
User Function V5RetFil( cCgc )               
*------------------------------------*
Local cFil := ''
Local nPos

If ( nPos := Ascan( aFilEmp ,{ | x | Alltrim( x[ 1 ] ) == AllTrim( cCgc ) } )  ) > 0 
	cFil := aFilEmp[ nPos ][ 02 ]
EndIf

Return( cFil )

                   
/*
Função..........: GerEnvLg    
Objetivo........: Gerar e enviar arquivo de log a partir de qualquer rotina externa 
Autor...........: Leandro Brito
Data............: 15/08/2016
*/
*------------------------------------*
User Function GerEnvLg( aDadosLog , lLog )              
*------------------------------------*
Private cPath 	:= GETMV("MV_P_FTP",,'10.0.30.35') 
Private clogin	:= GETMV("MV_P_USR",,'vogel') 
Private cPass	:= GETMV("MV_P_PSW",,'Vogel@gt123') 

//Diretorios no FTP do cliente
Private cDirFtpIn := "/IN"
Private cDirFtpout:= "/OUT"

//Diretorio no Servido Protheus
Private cDirSrvIn := "\FTP\V5\IN"   
Private cDirSrvOut := "\FTP\V5\OUT"

Private cDelimitador := "|"
Private cExtZip := "ZIP"
Private aProcessados := {}

GeraLog( aDadosLog , lLog )     
ManuArqFTP("PUT" ,, .F.) 

Return

/*
Função..........: EmpVogel 
Objetivo........: Retornas todas empresas da Vogel
Autor...........: Leandro Brito
Data............: 19/08/2016
*/
*---------------------*
User Function EmpVogel ; Return( 'V5\FA\FC\FE\G4' )
*---------------------*

/*
Funcao      : V5IEMasc 
Parametros  : cEstSm0
Retorno     : cIE
Objetivos   : Retorna a mascara para Inscrição Estadual na impressão das faturas
Autor       : Renato Rezende
Data/Hora   : 20/09/2016
*/
*--------------------------------*
 User Function V5IEMasc(cEstSm0)
*--------------------------------*
Local aIE 	:= {}
Local cIE	:= ""
Local nR	:= ""

aIE := {{'RS','999-9999999' 		},;
		{'SC','999.999.999' 		},;
		{'PR','99999999-99' 		},;
		{'SP','999.999.999.999' 	},;
		{'MG','999.999.999/9999' 	},;
		{'RJ','99.999.99-9' 		},;
		{'ES','999.999.99-9'		},;
		{'BA','999.999.99-9'		},;
		{'SE','999999999-9' 		},;
		{'AL','999999999' 			},;
		{'PE','99.9.999.9999999-9' 	},;
		{'PB','99999999-9' 	   		},;
		{'RN','99.999.999-9' 		},;
		{'PI','999999999' 			},;
		{'MA','999999999' 			},;
		{'CE','99999999-9'			},;
		{'GO','99.999.999-9' 		},;
		{'TO','99999999999' 		},;
		{'MT','999999999' 			},;
		{'MS','999999999' 			},;
		{'DF','99999999999-99' 		},;
		{'AM','99.999.999-9' 		},;
		{'AC','99.999.999/999-99' 	},;
		{'PA','99-999999-9' 		},;
		{'RO','999.99999-9' 		},;
		{'RR','99999999-9' 			},;
		{'AP','999999999' 			}}


//Validando a mascara por estado
For nR:=1 to Len(aIE)
	If aIE[nR][1] == Alltrim(cEstSm0)
		cIE:= Alltrim(aIE[nR][2])
		Exit
	Else
		cIE:= '99999999999999'
	EndIf
Next nR

Return cIE