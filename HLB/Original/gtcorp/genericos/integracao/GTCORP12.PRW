#Include "Protheus.ch"

/*
Funcao      : GTCORP12
Parametros  : cAmb,cEmp,cFil,cCgc,cDoc,cSerie,cEspecie,cEmpOri,cFilOri,aCond,aItensD2,cCliSF2,cLojaSF2,cEmpNome,dData,aErros,nOpc,cPara,cServ,cPorta
Retorno     : aArray[len(aArray)][1]
Objetivos   : Função utilizada para conectar na base do cliente da GT, e processar a função GTGEN001.
Autor       : Matheus Massarotto
Data/Hora   : 25/04/2012    15:41
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/
*------------------------------------------------------------------------------------------------------------------------------------------------------------*
User function GTCORP12(cAmb,cEmp,cFil,cCgc,cDoc,cSerie,cEspecie,cEmpOri,cFilOri,aCond,aItensD2,cCliSF2,cLojaSF2,cEmpNome,dData,aErros,nOpc,cPara,cServ,cPorta)
*------------------------------------------------------------------------------------------------------------------------------------------------------------*
Local oServ
Local lExec
Local cIp		:= alltrim(cServ) //"app04.pryor.com.br"
Local nPort		:= val(cPorta) //1024
Local cAmbiente	:= cAmb
Local cEmp		:= cEmp
Local cFil		:= cFil
Local lExec		:= .T.
Local aArray	:= {}
Local aAux		:= {}
Local cCompName	:= GetComputerName()
//U_GTGEN001(__cUserId ,cUserName,cCompName,cCgc,cDoc,cSerie,cEspecie,cEmpOri,cFilOri,aCond,aItensD2,cCliSF2,cLojaSF2,cEmpNome,nOpc)
//U_GTGEN001("000130","","","04051410000112","001384   ","C","RPS  ","CH","01",{"205","3","1,1,05","05 MES SEGUINTE"},{{"300034",1,58.5,58.5}},"000022","01","GT TECHONOLOGY ",CTOD("03/04/12"),{},3)

//conecta no servidor, (ip,porta,ambiente,empresa,filial)
oServ:=  RpcConnect(cIp,nPort,cAmbiente,cEmp,cFil)

If valtype(oServ) == 'O'
	CONOUT("CONECTOU")
	aArray := oServ:CALLPROC("U_GTGEN001",__cUserId ,cUserName,cCompName,cCgc,cDoc,cSerie,cEspecie,cEmpOri,cFilOri,aCond,aItensD2,cCliSF2,cLojaSF2,cEmpNome,dData,aErros,nOpc,cPara) //executa a função
	RpcDisconnect(oServ)// --  finaliza a conexao remota
Else
	AADD(aErros,{"ERRO",cmodulo,SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,SF2->(RECNO()),;
				"Não foi possível conectar!"+CRLF+"Ip: "+cIp+CRLF+"Porta: "+cvaltochar(nPort),;
				date(), dData ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmpAnt, cFilAnt,cEmp,cFil,SF2->F2_CLIENTE,SF2->F2_LOJA,"","",""})
	//GRAVA OS ERROS NA TABELA DE LOGS
	DbSelectArea("Z91")
	for nCont:=1 to len(aErros)
		Z91->(RecLock("Z91",.T.))
		Z91->Z91_CODIGO := GETSXENUM("Z91","Z91_CODIGO")
		Z91->Z91_OCORRE := aErros[nCont][1]
		Z91->Z91_MODULO := aErros[nCont][2]
		Z91->Z91_X_FIL  := aErros[nCont][3]
		Z91->Z91_X_DOC  := aErros[nCont][4]
		Z91->Z91_X_SERI := aErros[nCont][5]
		Z91->Z91_X_FORN := aErros[nCont][6]
		Z91->Z91_X_LOJA := aErros[nCont][7]
		Z91->Z91_X_TIPO := aErros[nCont][8]
		Z91->Z91_X_RECN := aErros[nCont][9]
		Z91->Z91_DESCRI := STRTRAN(aErros[nCont][10],CRLF," ")
		Z91->Z91_DATA   := aErros[nCont][11]
		Z91->Z91_DATASI := aErros[nCont][12]
		Z91->Z91_HORA   := aErros[nCont][13]
		Z91->Z91_CODUSE := aErros[nCont][14]
		Z91->Z91_USER   := aErros[nCont][15]
		Z91->Z91_AMBIEN := aErros[nCont][16]
		Z91->Z91_COMPUT := aErros[nCont][17]
		Z91->Z91_EMPORI := aErros[nCont][18]
		Z91->Z91_FILORI := aErros[nCont][19]
		Z91->Z91_EMPDES := aErros[nCont][20]
		Z91->Z91_FILDES := aErros[nCont][21]
		Z91->Z91_INCEXC := IIF(nOpc==3,"inclusão","exclusão")
		Z91->(MsUnlock())
		CONFIRMSX8()		                    
	next
	Z91->(DbCloseArea())
   	
   	If len(aErros)>0
		CONOUT("Entrou para enviar e-mail")
		U_GTGEN002(cPara,aErros,nOpc,2)
    EndIf
    
    AADD(aArray,{.F.})
EndIf

If len(aArray)>0
	If ValType(aArray[1][1])<>"L"
		aAux:=aArray
		ASIZE(aAux,Len(aAux)-1)
		U_GTGEN002(cPara,aAux,nOpc,2)
	endif
	//GRAVA OS ERROS NA TABELA DE LOGS
	DbSelectArea("Z91")
	for nCont1:=1 to len(aArray)-1
		Z91->(RecLock("Z91",.T.))
		Z91->Z91_CODIGO := GETSXENUM("Z91","Z91_CODIGO")
		Z91->Z91_OCORRE := aArray[nCont1][1]
		Z91->Z91_MODULO := aArray[nCont1][2]
		Z91->Z91_X_FIL  := aArray[nCont1][3]
		Z91->Z91_X_DOC  := aArray[nCont1][4]
		Z91->Z91_X_SERI := aArray[nCont1][5]
		Z91->Z91_X_FORN := aArray[nCont1][6]
		Z91->Z91_X_LOJA := aArray[nCont1][7]
		Z91->Z91_X_TIPO := aArray[nCont1][8]
		Z91->Z91_X_RECN := aArray[nCont1][9]
		Z91->Z91_DESCRI := STRTRAN(aArray[nCont1][10],CRLF," ")
		Z91->Z91_DATA   := aArray[nCont1][11]
		Z91->Z91_DATASI := aArray[nCont1][12]
		Z91->Z91_HORA   := aArray[nCont1][13]
		Z91->Z91_CODUSE := aArray[nCont1][14]
		Z91->Z91_USER   := aArray[nCont1][15]
		Z91->Z91_AMBIEN := aArray[nCont1][16]
		Z91->Z91_COMPUT := aArray[nCont1][17]
		Z91->Z91_EMPORI := aArray[nCont1][18]
		Z91->Z91_FILORI := aArray[nCont1][19]
		Z91->Z91_EMPDES := aArray[nCont1][20]
		Z91->Z91_FILDES := aArray[nCont1][21]
		Z91->Z91_INCEXC := IIF(nOpc==3,"inclusão","exclusão")
		Z91->(MsUnlock())
		CONFIRMSX8()		                    
	next

	Z91->(DbCloseArea())
EndIf

Return(aArray[len(aArray)][1])