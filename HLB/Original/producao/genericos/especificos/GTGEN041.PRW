#include "totvs.ch" 
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#Include "rwmake.ch"
#Include "tbiconn.ch"

/*
Funcao      : GTGEN041()
Parametros  : Nenhum
Retorno     : 
Objetivos   : Gera Copia das tabelas em DBF e envia para FTP
Autor       : Anderson Arrais	
Data	    : 26/05/2017
*/    
*--------------------------*
User Function GTGEN041(aEmp)
*--------------------------* 
Private cPath 	:= ""
Private clogin	:= ""
Private cPass 	:= ""
Private cDir	:= ""

If !Used() 
	conout(aEmp[1]+" "+aEmp[2])
	
	RpcClearEnv()
	RpcSetType( 3 )
	PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SE1" MODULO "FIN"
	conout("Fonte GTGEN041: preparou GTGEN041")
EndIf

cPath 	:= GETMV("MV_P_FTP",,"") // "179.184.211.226"
clogin	:= GETMV("MV_P_USR",,"") // "user_ftp_bbva"
cPass 	:= GETMV("MV_P_PSW",,"") // "autbank@2017" 
cDir	:= ""

Return Main()

/*
Funcao      : Main
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função principal
Autor     	: Anderson Arrais	
Data     	: 29/05/2017
Obs         :
*/ 
*--------------------*
Static Function Main()   
*--------------------*
Local lConnect   := .F.  
Local arq		 := ""

Private aArqsImp := {}

//Ajusta a Pasta de Origem no Servidor - Temporaria
If ExistDir("\FTP")
	If !ExistDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt)
	EndIf
Else
	MakeDir("\FTP")
	MakeDir("\FTP\"+cEmpAnt)
EndIf
If !ExistDir("\FTP\"+cEmpAnt)
	conout("Fonte GTGEN041: Falha ao carregar diretório FTP no Servidor!")
	Return .F.
EndIf

cDir := "\FTP\"+cEmpAnt

//Conexao do FTP interno
For i:=1 to 3// Tenta 3 vezes.
	lConnect := ConectaFTP()
	If lConnect
 		i:=3
   	EndIf
Next   
If !lConnect
	conout("Fonte GTGEN041: Não foi possivel estabelecer conexão com FTP.")
 	Return .F.
EndIf

//Gera os Arquivos
GeraArq()

//Sobre arquivos para FTP
UP2FTP()

//Encerra conexão com FTP
FTPDisconnect()

Return .T. 

/*
Funcao		: UP2FTP
Objetivo	: Envio do DBF para o FTP
Autor     	: Anderson Arrais	
Data     	: 29/05/2017
*/     
*------------------------------*
Static Function UP2FTP()
*------------------------------*

aArqs := Directory(cDir+"\*.DBF")
conout("Fonte GTGEN041: Up FTP")
For i:=1 to Len(aArqs)
	FTPUpLoad(cDir+"\"+alltrim(aArqs[i][1]),alltrim(aArqs[i][1]))
	FERASE(cDir+"\"+alltrim(aArqs[i][1]))
	aAdd(aArqsImp, alltrim(aArqs[i][1]) )
Next i               

Return .T. 

/*
Funcao		: ConectaFTP
Objetivo	: Conecta ao FTP
Autor     	: Anderson Arrais	
Data     	: 29/05/2017
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
If lRet
	conout("Fonte GTGEN041: Conectado ao FTP")
EndIf
   
Return (lRet)

/*
Funcao		: GeraArq
Objetivo	: Gera os arquivos DBF com base no parâmetro MV
Autor     	: Anderson Arrais	
Data     	: 29/05/2017
*/  
*-------------------------*
Static Function GeraArq()
*-------------------------* 
Local cQueCpo 	:= ""  
Local nR		:= 0
Local aLista	:= &(SuperGetMv("MV_P_00102"))		

For nR := 1 to len(aLista)
	If Select('cAlias') > 0 
 		cAlias->(DbCloseArea())
    EndIf

	cAlias	 	:= GetNextAlias()                   	
	conout("Fonte GTGEN041: Inicia DBF"+aLista[nR])

	// Obtém a estrutura atual da tabela
	aStru := (aLista[nR])->( DBStruct() )
	 
	// Monta uma query para busca de dados
	cQuery 		:= "SELECT *"
	cQuery 		+= " FROM "+RetSQLName(aLista[nR])
	cQuery 		+= " WHERE D_E_L_E_T_ <> '*'"
	cQuery 		:= ChangeQuery( cQuery )
	 
	// Abre o cursor sob o alias
	dbUseArea( .T., 'TOPCONN', TCGenQry( , , cQuery ), cAlias, .F., .T. )
	
	nT := len( aStru )
	For nI := 1 to nT
	  If ( aStru[nI][2] $ 'DNL' )
	    TCSetField( cAlias, aStru[nI, 1], aStru[nI, 2], aStru[nI, 3], aStru[nI,4] )
	  Endif
	Next
	                       
	If Select('cAlias') > 0 
 		(cAlias)->(DbCloseArea()) 
    Endif 

	dbSelectArea(cAlias)
	_cArqDBF	:= Alltrim( RetSQLName(aLista[nR]) )+"_"+GravaData(Date(),.F.,8)+".DBF"
	FErase(_cArqDBF)//Excluir arquivo
	Copy To &("\FTP\"+cEmpAnt+"\"+_cArqDBF) 
	(cAlias)->(DbCloseArea())
Next nR

Return(_cArqDBF) 