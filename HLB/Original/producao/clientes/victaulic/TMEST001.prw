#Include 'Protheus.Ch'
#Include 'fileio.ch'

/*
Funcao      : TMEST001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Envio de Saldo F�sico por FTP.
Autor       : Renato Rezende
Data/Hora   : 01/12/2016
Cliente		: Victaulic
*/

*------------------------------* 
 User Function TMEST001()
*------------------------------*
Private lJob	:=.F.

//Testa para verificar se est� sendo feito pelo JOB ou pelo menu				                        
If Select("SX3")<=0
	lJob := .T.
	RpcSetType(3)
	RpcSetEnv("TM", "01")  //Abre ambiente em rotinas autom�ticas  
	ExecRotina(.T.)
Else
	If !(cEmpAnt $ ("TM"))
		MsgInfo("Rotina n�o disponivel para esse cliente","HLB BRASIL") 
		Return .F.
	EndIf
	ExecRotina(.F.) 
EndIf

If lJob
	RpcClearEnv()
EndIf  

Return nil

/*
Funcao      : ExecRotina
Parametros  : lJob
Retorno     : Nenhum
Objetivos   : Func�o para montar o arquivo Txt
Autor     	: Renato Rezende
Data     	: 01/12/2016
Obs         :
*/
*-----------------------------------*
  Static Function ExecRotina(lJob)  
*-----------------------------------*
Local lConsulta		:= .F.
Local lEnvFtp		:= .F.

Local nR			:= 0

Local cHtml			:= ""

Local aCabec		:= {"Supply Point","Part NR","Landed Inventory Cost","On Hand Inventory Qty","QTY Allocated to Orders","Last Transaction Date","Date Key","Date of Last Sale"}

Private cDir		:= "\FTP\"+cEmpAnt+"\TMEST001\"
Private cNomeArq	:= "Victaulic_saldo_"+GravaData( dDataBase,.F.,6 )+"_"+Substr(TIME(),1,2)+"_"+Substr(TIME(),4,2)+"_"+Substr(TIME(),7,2)+".CSV"
Private cLocal		:= ""
Private cArq		:= cDir+cNomeArq
Private cArqServ	:= cArq
Private cPath	 	:= Alltrim(GETMV("MV_P_FTP",,'ftp.victaulic.com'))
Private cLogin		:= Alltrim(GETMV("MV_P_USR",,'gthornton'))
Private cPass		:= Alltrim(GETMV("MV_P_PSW",,'GT_willow@57m'))

If !LisDir( cDir )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\TMEST001\" )
	MakeDir( "\FTP\" + cEmpAnt + "\TMEST001\processados" )		
EndIf

If !lJob
	cLocal		:= GetTempPath()
	cArq		:= cLocal+cNomeArq
EndIf

//Limpar o arquivo caso exista
If File(cArq)
	FErase(cArq)
EndIf

//Para n�o causar estouro de variavel.
nHdl		:= FCREATE(cArq,FC_NORMAL )  //Cria��o do Arquivo
If nHdl > 0
	nBytesSalvo	:= FWRITE(nHdl, cHtml ) // Grava��o do seu Conteudo.
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
Else
	Conout("Arquivo n�o foi criado! Erro:"+ Alltrim(STR(FERROR())))
	Return
EndIf
//Monta o Select
lConsulta := ConsultaDados() 

If lConsulta
	
	//Incluindo o cabe�alho no relat�rio
	For nR := 1 to Len(aCabec)
		cHtml+= aCabec[nR]+';'
	Next nR
	cHtml+= Chr( 13 ) + Chr( 10 )

	//Itens
	While SB2QRY->(!EOF())
      
		cHtml+= 'VIC082;'
		cHtml+= Alltrim(SB2QRY->B2_COD)+';'
		cHtml+= Alltrim(TRANSFORM((SB2QRY->B2_CM2),"@E 99,999,999,999.99"))+';'
		cHtml+= Alltrim(TRANSFORM((SB2QRY->B2_QATU),"@E 99999999.9999"))+';'
		cHtml+= Alltrim(TRANSFORM((SB2QRY->B2_QPEDVEN),"@E 99999999.9999"))+';'
		cHtml+= DtoC(StoD(SB2QRY->ULTCOMP))+';'
		cHtml+= DtoC(Date())+';'
		cHtml+= DtoC(StoD(SB2QRY->ULTVENDA))
		cHtml+= Chr( 13 ) + Chr( 10 )

		If Len(cHtml) >= 50000
			cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
		EndIf		
			
		SB2QRY->(DbSkip())
	EndDo
	
	cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	
	//Copiando arquivo para o servidor caso n�o seja Job
	If !lJob
		If CpyT2S( cArq , cDir ,.T. )  
			conout("Arquivo enviado para o servidor: "+cNomeArq)
			//Limpar o arquivo caso exista
			If File(cArq)
				FErase(cArq)
			EndIf
		Else		
			conout("Erro na copia para o servidor: "+cNomeArq )
		EndIf
	EndIf
	//Envio do Arquivo para o FTP
	lEnvFtp:= ManuArqFTP(cArqServ)
	If lEnvFtp
		If lJob
			conout("Arquivo enviado para o FTP Victaulic: "+cNomeArq )
		Else
			MsgAlert("Arquivo enviado para o FTP Victaulic: "+cNomeArq,"HLB BRASIL")
		EndIf
	Else
		If lJob
			conout("Arquivo n�o foi enviado para o FTP Victaulic: "+cNomeArq )
		Else
			MsgAlert("Arquivo n�o foi enviado para o FTP Victaulic: "+cNomeArq,"HLB BRASIL")
		EndIf	
	EndIf
	
	
else
	Aviso("Aviso","N�o existe informa��es.",{"Abandona"},2)	
Endif

Return

/*
Funcao      : ConsultaDados
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Fun��o para executar consulta na base
Autor     	: Renato Rezende
Data     	: 01/12/2016
Obs         :
*/
*--------------------------------------*
  Static Function ConsultaDados()  
*--------------------------------------*
Local cQuery 		:= ""
Local lRet			:= .T.

If Select("SB2QRY") > 0
	SB2QRY->(DbCloseArea())
Endif

cQuery:= "	SELECT B2_COD,B2_CM2,B2_QATU,B2_QPEDVEN, " 
cQuery+= "	ISNULL((SELECT TOP 1 D1_EMISSAO FROM SD1"+cEmpAnt+"0 WHERE D1_COD = B2.B2_COD AND D1_FILIAL = B2.B2_FILIAL AND D_E_L_E_T_ <> '*' AND D1_LOCAL = '01' ORDER BY D1_EMISSAO DESC),'') AS ULTCOMP, " 
cQuery+= "	ISNULL((SELECT TOP 1 D2_EMISSAO FROM SD2"+cEmpAnt+"0 WHERE D2_COD = B2.B2_COD AND D2_FILIAL = B2.B2_FILIAL AND D_E_L_E_T_ <> '*' AND D2_LOCAL = '02' ORDER BY D2_EMISSAO DESC),'') AS ULTVENDA "
cQuery+= "	  FROM SB2"+cEmpAnt+"0 AS B2 "
cQuery+= "	 WHERE B2.D_E_L_E_T_ <> '*' " 
cQuery+= "	   AND B2.B2_LOCAL = '02' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SB2QRY",.T.,.T.)

SB2QRY->(DbGoTop())	
//Verifica se retornou registro
If SB2QRY->(EOF()) .OR. SB2QRY->(BOF())
	lRet:=.F.
EndIf

Return lRet

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da vari�vel cHtml em partes para n�o causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 02/12/2016
*/
*------------------------------*
 Static Function Grv(cHtml)
*------------------------------*
Local nHdl		:= 0

nHdl := Fopen(cArq, FO_READWRITE + FO_SHARED)
If nHdl > 0
	// Posiciona no fim do arquivo
	FSeek(nHdl,0,FS_END)
	nBytesSalvo += FWRITE(nHdl, cHtml)
	//Fecha arquivo
	Fclose(nHdl)
Else 
	Conout("Arquivo n�o foi aberto! Erro:"+ Alltrim(STR(FERROR())))
EndIf

Return ""

/*
Funcao      : ManuArqFTP()  
Parametros  : cArq
Retorno     : lRet
Objetivos   : Fun��o responsavel por manipular os arquivos no FTP.
Autor       : Renato Rezende
Data/Hora   : 07/12/2016
*/
*--------------------------------------------*
Static Function ManuArqFTP(cArqServ)
*--------------------------------------------*
Local i				:= 0
Local lConnect		:= .F.
Local aArqs			:= {}
Local lRet			:= .F.

//Conexao com o FTP informado nos paramentros.
For i:=1 to 3// Tenta 3 vezes.
	lConnect := FTPConnect(cPath,,cLogin,cPass)
	If lConnect
 		i:=3
   	EndIf
Next
If !lConnect
	If lJob
   		Conout("TMEST001 - N�o foi possivel estabelecer conex�o com FTP!")		
	Else
		MsgAlert("N�o foi possivel estabelecer conex�o com FTP.","HLB BRASIL")
	EndIf
 	lRet:= .F.
Else
	aArqs := Directory(cArqServ)
	For i:=1 to Len(aArqs)
		//Enviando para o FTP
		lRet:= FTPUpLoad(cDir+Alltrim(aArqs[i][1]),Alltrim(aArqs[i][1]))
		//Copiando arquivo para a pasta de enviados
		__CopyFile(cDir+Alltrim(aArqs[i][1]),cDir+"processados\"+Alltrim(aArqs[i][1]))
		//Excluindo arquivo da pasta principal
		FERASE(cDir+alltrim(aArqs[i][1]))
	Next i
EndIf

//Encerra conex�o com FTP
FTPDisconnect()

Return lRet