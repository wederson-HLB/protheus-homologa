#INCLUDE "PROTHEUS.CH"
#INCLUDE "ap5mail.ch"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "SHELL.CH"

/*
Funcao      : GTM001
Parametros  : 
Retorno     : 
Objetivos   : Z97(PRAZOS POR CFO)
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*--------------------*
User Function GTM001()
*--------------------*
Return AXCADASTRO("Z97","Prazos por CFO")

/*
Funcao      : GTM002
Parametros  : 
Retorno     : 
Objetivos   : CHAMADA DO HTML DE PODER DE TERCEIROS NO DESKTOP 
			: SB6,SB1,SA1,SA2,Z97(PRAZOS POR CFO)
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*--------------------*
User Function GTM002()     
*--------------------*
Private cPathSrv := U_GTJ001(SM0->M0_CODIGO,SM0->M0_CODFIL,.t.,SM0->M0_NOME)

If empty(cPathSrv)
	Return .F.
EndIf

Private cDirRmt  := AllTrim(GetTempPath())
Private cFile    := STRTRAN(UPPER(cPathSrv),"\ANEXOS\","")

LJMsgRun( "Processando arquivo...", NIL, { ||PROCHTM()} )
FERASE(cPathSrv)      

Return .T.

/*
Funcao      : GTM003
Parametros  : 
Retorno     : 
Objetivos   : Z98(EMPRESAS)
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*--------------------*
User Function GTM003()
*--------------------*
Return AXCADASTRO("Z98","Cadastro de Empresas para JOB")

/*
Funcao      : GTJ002
Parametros  : 
Retorno     : 
Objetivos   : Function para ser utilizada no Schedule. Percorre todas as empresas cadastradas na tabela Z98
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*--------------------*
User Function GTJ002()
*--------------------*

PREPARE ENVIRONMENT EMPRESA "YY" FILIAL "01"

CONOUT("Inicio Relatorio Poder3 - GTJ001.PRW")

DbSelectArea("Z98")
Dbgotop()
While Z98->(!EOF())
	nRecZ98 := Z98->(RECNO())
    cEmpZ98 := Z98->Z98_CODEMP
    cFilZ98 := Z98->Z98_CODFIL
    cNomZ98 := Z98->Z98_NOME 
    
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa cEmpZ98 Filial cFilZ98
	
	U_GTJ001(cEmpZ98,cFilZ98,.F.,cNomZ98)	
	
	PREPARE ENVIRONMENT EMPRESA "YY" FILIAL "01"
	DbSelectArea("Z98")
	DbGoTo(nRecZ98)
	
	Z98->(DbSkip())
EndDo                   

Return .T.

/*
Funcao      : GTJ001
Parametros  : 
Retorno     : 
Objetivos   : ENVIO DE E-MAIL CLASSIFICANDO STATUS DAS NOTAS COM CONTROLE DE TERCEIROS
				SB6,SB1,SA1,SA2,Z97(PRAZOS POR CFO)
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*--------------------------------------------*
User Function GTJ001(cEmp,cFil,lDeskParam,cEmpresa)
*--------------------------------------------*
Private nMin		:= 10 // maximo de dias para ser apresentado
Private cMail		:= "" // VARIAVEL PARA ENDERECOS DE MAIL
Private nRegs		:= 0
Private cQry		:= ""                     // VARIAVEL PARA QUERY
Private cData		:= DTOS(date())           // DATA ATUAL
Private lCarga		:= .f.                    // GEROU HTML
Private cMsg		:= ""                     // CORPO DO E-MAIL
Private lCor		:= .T.                    // SEMAFARO DE COR
Private aCor		:= {'rgb(244, 244,244)',' rgb(255, 204, 255)'} // COR DAS LINHAS
Private cCor		:= ""
Private nDias		:= 0
Private lCorpo		:= .T.
Private nArq, cArq	:= ""
Private cLin		:= ""
Private cQrw		:= ""
Private lDesk		:= .F.

Default cEmp   := "YY"
Default cFil   := "01"
Default lDeskParam  := .F.

lDesk := lDeskParam

SX6->(DbSetOrder(1))
If !SX6->(DbSeek(xFilial("SX6")+"MV_P_00012") )
	SX6->(RecLock("SX6",.T.))
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "MV_P_00012"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Emails de destino para envio Poder 3º"
	//SX6->X6_CONTEUD := "monalisa.martins@hlb.com.br;priscila.santos@hlb.com.br;carla.oliveira@hlb.com.br;jefferson.bernardino@hlb.com.br;renata.melloni@hlb.com.br;diogo.braga@hlb.com.br"
	//AOA - 19/04/2016 - Alterado lista de e-mail ao criar parâmetro, chamado 032886
	//SX6->X6_CONTEUD := "erica.luz@hlb.com.br;priscila.santos@hlb.com.br;fernanda.bernardes@hlb.com.br;maria.damacena@hlb.com.br;felipe.imola@hlb.com.br;jefferson.bernardino@hlb.com.br;tatiane.tandu@hlb.com.br;cristiane.cavalcante@hlb.com.br;suzana.furtado@hlb.com.br"	
	//RSB - 30/01/2017 - Alterado lista de e-mail ao criar parâmetro, chamado 035504
	SX6->X6_CONTEUD := "erica.luz@hlb.com.br;priscila.santos@hlb.com.br;fernanda.bernardes@hlb.com.br;maria.damacena@hlb.com.br;felipe.imola@hlb.com.br;jefferson.bernardino@hlb.com.br;tatiane.tandu@hlb.com.br;cristiane.cavalcante@hlb.com.br;suzana.furtado@hlb.com.br;tatiane.tandu@hlb.com.br;luis.costa@hlb.com.br;juliane.balbo@hlb.com.br"
	
	SX6->X6_PROPRI  := "U"
	SX6->(MsUnlock())
EndIf
cMail := GetMV("MV_P_00012")

If lDesk
	cPerg:="P_RPODER3"

	U_PUTSX1( cPerg, "01", "Tipo ?"	   		, "Tipo ?", "Tipo ?", "", "N",01,00,00,"C","" , "","","","MV_PAR01","Nota","","","","Produto")
	U_PUTSX1( cPerg, "02", "Produto De?" 		, "Produto De?", "Produto De?", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR02")
	U_PUTSX1( cPerg, "03", "Produto Ate?"		, "Produto Ate?", "Produto Ate?", "", "C",15,00,00,"G","" , "SB1","","","MV_PAR03")
	U_PUTSX1( cPerg, "04", "Nota Fiscal de?"	, "Nota Fiscal de?", "Nota Fiscal de?", "", "C",09,00,00,"G","" , "SF2","","","MV_PAR04")
	U_PUTSX1( cPerg, "05", "Nota Fiscal Ate?"	, "Nota Fiscal Ate?", "Nota Fiscal Ate?", "", "C",09,00,00,"G","" , "SF2","","","MV_PAR05")
	U_PUTSX1( cPerg, "06", "Serie de?"   		, "Serie de?", "Serie de?", "", "C",03,00,00,"G","" , "","","","MV_PAR06")
	U_PUTSX1( cPerg, "07", "Serie Ate?"  		, "Serie Ate?", "Serie Ate?", "", "C",03,00,00,"G","" , "","","","MV_PAR07")
	U_PUTSX1( cPerg, "08", "Armazem de?" 		, "Armazem de?", "Armazem de?", "", "C",02,00,00,"G","" , "","","","MV_PAR08")
	U_PUTSX1( cPerg, "09", "Armazem Ate?"		, "Armazem Ate?", "Armazem Ate?", "", "C",02,00,00,"G","" , "","","","MV_PAR09")
	U_PUTSX1( cPerg, "10", "Cfop?"	  		, "Cfop?", "Cfop?", "", "C",50,00,00,"G","U_VaGTM002(MV_PAR10)" , "","","","MV_PAR10","","","","","","","","","","","","","","","","",{"Informe o codigo separado por ;","exemplo:","5912;6912"})
	U_PUTSX1( cPerg, "11", "Cliente de?" 		, "Cliente de?", "Cliente de?", "", "C",06,00,00,"G","" , "SA1","","","MV_PAR11")
	U_PUTSX1( cPerg, "12", "Cliente Ate?"		, "Cliente Ate?", "Cliente Ate?", "", "C",06,00,00,"G","" , "SA1","","","MV_PAR12")
	U_PUTSX1( cPerg, "13", "Fornecedor de?"	, "Fornecedor de?", "Fornecedor de?", "", "C",06,00,00,"G","" , "SA2","","","MV_PAR13")
	U_PUTSX1( cPerg, "14", "Fornecedor Ate?"	, "Fornecedor Ate?", "Fornecedor Ate?", "", "C",06,00,00,"G","" , "SA2","","","MV_PAR14")
	U_PUTSX1( cPerg, "15", "Prazo?"	  		, "Prazo?", "Prazo?", "", "C",50,00,00,"G","U_VaGTM002(MV_PAR15)" , "","","","MV_PAR15","","","","","","","","","","","","","","","","",{"Informe o codigo separado por ;","exemplo:","60;30"})
	U_PUTSX1( cPerg, "16", "Arquivo ?"  		, "Arquivo ?", "Arquivo ?", "", "N",01,00,00,"C","" , "","","","MV_PAR16","HTML","","","","EXCEL")
	U_PUTSX1( cPerg, "17", "Imp.Dev.Remessa?"	, "Imp.Dev.Remessa?", "Imp.Dev.Remessa?", "", "N",01,00,00,"C","" , "","","","MV_PAR16","Sim","","","","Nao")
	Set Key VK_F7 TO U_GTM001()
	Set Key VK_F8 TO U_GTM003()
	
	If !pergunte(cPerg,.T.,"Parâmetros                  <F7> - <F8>")
		Return .F.
	EndIf
	If EMPTY(MV_PAR16) .or. MV_PAR16==1
		cArq := LOWER("\ANEXOS\"+CRIATRAB(,.F.)+".HTML")
	Else 
		cArq := LOWER("\ANEXOS\"+CRIATRAB(,.F.)+".XLS")
	EndIf
Else                       
	cArq := LOWER("\ANEXOS\"+CRIATRAB(,.F.)+".HTML")
EndIf

MontaDIR("\ANEXOS")
If !lDesk
	If select("SX2")>0
		RESET ENVIRONMENT
	EndIf
	
	If SELECT("SX6") == 0
		RpcSetType(3)
		PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
	EndIf
EndIf

If SELECT("TRB") <> 0
	DBSELECTAREA("TRB")
	DBCLOSEAREA("TRB")
EndIf
If SELECT("TRD") <> 0
	DBSELECTAREA("TRD")
	DBCLOSEAREA("TRD")
EndIf
If SELECT("ITE") <> 0
	DBSELECTAREA("ITE")
	DBCLOSEAREA("ITE")
EndIf                          

//VERIFICANDO QTIDADE DE ITENS, VERIFICANDO NECESSIDADE DE GERAR ANEXO
cItens := " SELECT COUNT(*) QTD FROM "+RETSQLNAME("SB6")+" WHERE D_E_L_E_T_ = '' AND B6_SALDO > 0 "
DbUseArea( .T., "TOPCONN", TcGenqry( , , cItens), "ITE", .F., .F. )
TCSETFIELD("ITE","QTD","N",17,0)

//If ITE->QTD > 500 .OR. lDesk
If ITE->QTD > 0 .OR. lDesk
	lCorpo	:= .F.
	nArq	:= fcreate(cArq,1)
Else
	lCorpo := .T.
EndIf


If lDesk
	//Ajusta o conteúdo dos parametros para manter padrao '','',''
	If !Empty(MV_PAR15)
		aContAux:=STRTOKARR(MV_PAR15,";")
		MV_PAR15 := ""
		for j:=1 to len(aContAux)
			If !EMPTY(alltrim(aContAux[j]))
				MV_PAR15+="'"+alltrim(aContAux[j])+"',"
			EndIf
		next        
		MV_PAR15 := LEFT(MV_PAR15,LEN(MV_PAR15)-1)
	Else
		MV_PAR15 := "''"
	EndIf

	aContAux:={}
	If !Empty(MV_PAR10)
		aContAux:=STRTOKARR(MV_PAR10,";")
		MV_PAR10 := ""
		for j:=1 to len(aContAux)
			If !EMPTY(alltrim(aContAux[j]))
				MV_PAR10+="'"+alltrim(aContAux[j])+"',"
			EndIf
		next
		MV_PAR10 := LEFT(MV_PAR10,LEN(MV_PAR10)-1)
	Else
		MV_PAR10 := "''"
	EndIf
	//Carrega os parametros  
	PODER3PR()

	aTTT1:=GETLastQuery()
	Memowrite("C:\RETORNO\sql1.txt",aTTT1[2])

	PODE3PRD()
Else
	// TRANSFORMANDO CARGA DA BASE EM FUNCAO PARA USO EM OUTROS COMPONENTES
	PODER3DB()
EndIf

aTTT := GETLastQuery()
Memowrite("C:\RETORNO\sql.txt",aTTT[2])

lCarga := .F.

//MONTA CABEÇALHO DO HTML
cMsg := e_cab(lCorpo)

If !lDesk //Se for executada automatica
	While TRB->(!EOF())//PERCORRE ARQUIVO DE TRABALHO DA QUERY DA ROTINA PODER3DB
		lCarga	:= .T.
		cCor	:= aCor[IIF(lCor,1,2)]
		lCor	:= !lCor
		nDias	:= (date() - TRB->B6_EMISSAO)
		cCorX	:= ""
		cFlag	:= QualFlag(NDIAS,TRB->Z97_PRAZO)
		nContDias := nDias - TRB->Z97_PRAZO  

	   	If nContDias <= -nMin
			TRB->(dbskip())
			loop
		EndIf

		nRegs++
		cLin += '<br> '
		cLin += ' 	<table border="1"> '	
		cLin += ' 	<tr> <td>'
		cLin += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
		cLin += '   	<tbody> '
		cLin += '	<tr>  '     
		CorLin := 'style="font-weight: bold; color: black; background-color: rgb(168,168,168); text-align: left;" '
		cLin += '	<th colspan="7" '+CorLin+'><small>Produto:'+TRB->(B6_PRODUTO+SPACE(3)+B1_DESC)+'</small></th> '
		cLin += '	<th '+CorLin+'><small>Local:'+TRB->B6_LOCAL+'</small></th> '
		cLin += '	<th '+CorLin+'><small>Saldo:'+TRANSFORM(TRB->B6_SALDO,"@E 999,999.9999")+'</small></th> '
		If nContDias < 0
			cLin += '	<th '+CorLin+'><small>Dias a expirar:'+cvaltochar(ABS(nContDias))+' dia(s)</small></th>'
		Else
			cLin += '	<th '+CorLin+'><small>Expirado:'+cvaltochar(nContDias)+' dia(s)</small></th>'	
		EndIf
		cLin += '	<th '+CorLin+'><small>Prazo:'+cvaltochar(TRB->Z97_PRAZO)+' dia(s)</small></th>'
		cLin += '<th '+CorLin+'></th>'
		cLin += '<th '+CorLin+'></th>'
		cLin += '	<th '+CorLin+'><small>Situacao: '+cFlag+'</small></th>'
		cLin += '</tbody></table> '                                                            
		cLin +=	CARGAREM(cCor,TRB->B6_IDENT,TRB->B6_PRODUTO,TRB->B6_QUANT,TRB->B6_SALDO,cCorx)//ROTINA PARA CONSTRUÇÃO DE ITENS DE REMESSA
		cLin +=	CARGADEV(cCor,TRB->B6_IDENT,TRB->B6_PRODUTO,TRB->B6_QUANT,TRB->B6_SALDO,cCorx)//ROTINA PARA CONSTRUÇÃO DE ITENS DE DEVOLUÇÃO
		cLin += ' 	</td></tr> '
		cLin += ' 	</table> '			

		If !lCorpo
			fWrite(nArq, cLin+CRLF)
			cLin := ""
		Else
			cMsg += cLin
		EndIf		
		TRB->(dbskip())
	EndDo
	
Else //Se for executada por um usuario
	If MV_PAR01 == 2
		While TRB->(!EOF())//PERCORRE ARQUIVO DE TRABALHO DA QUERY DA ROTINA PODER3DB
			nRegs++
			lCarga	:= .T.
			cCor	:= aCor[IIF(lCor,1,2)]
			lCor	:= !lCor
			nDias	:= (date() - TRB->B6_EMISSAO)
			cCorX	:= ""
			cFlag	:= QualFlag(NDIAS,TRB->Z97_PRAZO)
			nContDias := nDias-TRB->Z97_PRAZO  
				
			cLin += '<br> '
			cLin += ' 	<table border="1"> '	
			cLin += ' 	<tr> <td>'
			cLin += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
			cLin += '     <tbody> '
			cLin += '<tr>  '     
			CorLin := 'style="font-weight: bold; color: black; background-color: rgb(168,168,168); text-align: left;" '
			cLin += '<th colspan="7" '+CorLin+'><small>Produto:'+TRB->(B6_PRODUTO+SPACE(3)+B1_DESC)+'</small></th> '
			cLin += '<th '+CorLin+'><small>Local:'+TRB->B6_LOCAL+'</small></th> '
			cLin += '<th '+CorLin+'><small>Saldo:'+TRANSFORM(TRB->B6_SALDO,"@E 999,999.9999")+'</small></th> '
			If nContDias < 0
				cLin += '<th '+CorLin+'><small>Dias a expirar:'+cvaltochar(ABS(nContDias))+' dia(s)</small></th>'
			Else
				cLin += '<th '+CorLin+'><small>Expirado:'+cvaltochar(nContDias)+' dia(s)</small></th>'	
			EndIf
			cLin += '<th '+CorLin+'><small>Prazo:'+cvaltochar(TRB->Z97_PRAZO)+' dia(s)</small></th>'
			cLin += '<th '+CorLin+'></th>'
			cLin += '<th '+CorLin+'></th>'
			cLin += '<th '+CorLin+'><small>Situacao: '+cFlag+'</small></th>'
			cLin += '</tbody></table> '                                                            
			cLin +=	CARGAREM(cCor,TRB->B6_IDENT,TRB->B6_PRODUTO,TRB->B6_QUANT,TRB->B6_SALDO,cCorx)//ROTINA PARA CONSTRUÇÃO DE ITENS DE REMESSA
			cLin +=	CARGADEV(cCor,TRB->B6_IDENT,TRB->B6_PRODUTO,TRB->B6_QUANT,TRB->B6_SALDO,cCorx)//ROTINA PARA CONSTRUÇÃO DE ITENS DE DEVOLUÇÃO
			cLin += ' 	</td></tr> '
			cLin += ' 	</table> '			

			If !lCorpo
				fWrite(nArq, cLin+CRLF)
				cLin := ""
			Else
				cMsg += cLin
			EndIf		
			TRB->(dbskip())
		EndDo
	Else
		//Montagem de temporario para auxiliar na impressao por tipo:nota
		If select("TRBSTRU")>0
			TRBSTRU->(DbCloseArea())
		EndIf
		aStru:={}
		AADD(aStru,{"ORIGEM"	,"C",10,0})
		AADD(aStru,{"B6_DOC"	,"C",9,0})
		AADD(aStru,{"B6_SERIE"	,"C",3,0})
		AADD(aStru,{"B6_EMISSAO","D",8,0})
		AADD(aStru,{"B6_SALDO"	,"N",12,2})
		AADD(aStru,{"B6_QUANT"	,"N",11,2})
	//	AADD(aStru,{"DIAS"		,"C",3,0})
		AADD(aStru,{"Z97_PRAZO"	,"N",4,0})
		AADD(aStru,{"D2_COD"	,"C",15,0})
		AADD(aStru,{"D2_QUANT"	,"N",11,2})
		AADD(aStru,{"D2_LOCAL"	,"C",2,0})
		AADD(aStru,{"D2_VALICM"	,"N",14,2})
		AADD(aStru,{"D2_VALIPI"	,"N",14,2})
		AADD(aStru,{"D2_CF"		,"C",6,0})
		AADD(aStru,{"D2_TES"	,"C",3,0})
		AADD(aStru,{"B1_COD"	,"C",15,0})
		AADD(aStru,{"B1_DESC"	,"C",50,0})
		AADD(aStru,{"F2_VALBRUT","N",14,2})
		AADD(aStru,{"B6_IDENT"	,"C",6,0})
		AADD(aStru,{"A1_CGC"	,"C",14,0})
		AADD(aStru,{"A1_NREDUZ"	,"C",20,0})
		AADD(aStru,{"B6_PRODUTO","C",15,0})
		AADD(aStru,{"B6_LOCAL"	,"C",2,0})
		AADD(aStru,{"D2_LOTECTL","C",10,0})
		AADD(aStru,{"D2_DTVALID","D",8,0})
		AADD(aStru,{"R_E_C_N_O_","N",20,0})
		AADD(aStru,{"B6_PODER3"	,"C",1,0})
		AADD(aStru,{"D2_TOTAL"	,"N",14,2})
	
		cArqTrb := CriaTrab(aStru,.T.)
		dbUseArea(.T.,,cArqTrb,"TRBSTRU",.F.,.F.)
		cArqInd := CriaTrab(Nil,.F.)
		cChave := "R_E_C_N_O_"
		IndRegua("TRBSTRU",cArqInd,cChave,,,"Indexando Registros...")

		DbSelectArea("TRB")
		TRB->(DbGotop())
		While TRB->(!EOF())
			Reclock("TRBSTRU",.T.)
			TRBSTRU->ORIGEM:=TRB->ORIGEM
			TRBSTRU->B6_DOC:=TRB->B6_DOC
			TRBSTRU->B6_SERIE:=TRB->B6_SERIE
			TRBSTRU->B6_EMISSAO:=TRB->B6_EMISSAO
			TRBSTRU->B6_SALDO:=TRB->B6_SALDO
			TRBSTRU->B6_QUANT:=TRB->B6_QUANT
			//TRBSTRU->DIAS:=val(TRB->DIAS)
			TRBSTRU->Z97_PRAZO:=TRB->Z97_PRAZO
			TRBSTRU->D2_COD:=TRB->D2_COD
			TRBSTRU->D2_QUANT:=TRB->D2_QUANT
			TRBSTRU->D2_LOCAL:=TRB->D2_LOCAL
			TRBSTRU->D2_VALICM:=TRB->D2_VALICM
			TRBSTRU->D2_VALIPI:=TRB->D2_VALIPI
			TRBSTRU->D2_CF:=TRB->D2_CF
			TRBSTRU->D2_TES:=TRB->D2_TES
			TRBSTRU->B1_COD:=TRB->B1_COD
			TRBSTRU->B1_DESC:=TRB->B1_DESC
			TRBSTRU->F2_VALBRUT:=TRB->F2_VALBRUT
			TRBSTRU->B6_IDENT:=TRB->B6_IDENT
			TRBSTRU->A1_CGC:=TRB->A1_CGC
			TRBSTRU->A1_NREDUZ:=TRB->A1_NREDUZ
			TRBSTRU->B6_PRODUTO:=TRB->B6_PRODUTO
			TRBSTRU->B6_LOCAL:=TRB->B6_LOCAL 
			TRBSTRU->D2_LOTECTL:=TRB->D2_LOTECTL
			TRBSTRU->D2_DTVALID:=TRB->D2_DTVALID
			TRBSTRU->R_E_C_N_O_:=TRB->R_E_C_N_O_
			TRBSTRU->B6_PODER3:=TRB->B6_PODER3
			TRBSTRU->D2_TOTAL:=TRB->D2_TOTAL
			TRBSTRU->(MsUnlock())
			TRB->(DbSkip())      
		EndDo

		//FIM Montagem de temporario para auxiliar na impressao por tipo:nota
		DbSelectArea("TRBSTRU")
		TRBSTRU->(DbGotop())
		//PERCORRE ARQUIVO DE TRABALHO DA QUERY DA ROTINA PODER3DB
		While TRBSTRU->(!EOF())
			nRegs++
			lCarga	:= .T.
			cCor	:= aCor[IIF(lCor,1,2)]
			lCor	:= !lCor
			nDias	:= (date() - TRBSTRU->B6_EMISSAO)
			cCorX	:= ""
			cFlag	:= QualFlag(NDIAS,TRBSTRU->Z97_PRAZO)
			nContDias := nDias-TRBSTRU->Z97_PRAZO  
				
			cLin += '<br> '
			cLin += ' 	<table border="1"> '	
			cLin += ' 	<tr> <td>'
			cLin += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
			cLin += '   <thead>
		 	cLin += '	   <tr>  '
	 	 	cLin += '			<td colspan="10" style="font-weight: bold; color: black; background-color: rgb(192,217,217); text-align: center;" ><small>REMESSAS</small></td> '
		 	cLin += '	   </tr>  '		
			cLin += '   </thead>
			cLin += '     <tbody> '
			cLin += '<tr>  '     
			CorLin := 'style="font-weight: bold; color: black; background-color: rgb(168,168,168); text-align: left;" '
			cLin += '<th '+CorLin+'><small>NF:'+TRBSTRU->B6_DOC+'</small></th> '
			cLin += '<th '+CorLin+'><small>Serie:'+TRBSTRU->B6_SERIE+'</small></th> '		
			cLin += '<th '+CorLin+'><small>Data:'+DTOC(TRBSTRU->B6_EMISSAO)+'</small></th> '		
			cLin += '<th '+CorLin+'><small>Valor Total:'+Transform(TRBSTRU->F2_VALBRUT,PesqPict("SF2","F2_VALBRUT"))+'</small></th> '
			
			cQrw:=" SELECT SUM(B6_SALDO) AS B6_SALDO FROM "+RETSQLNAME("SB6")+CRLF
			cQrw+=" WHERE B6_FILIAL='"+xFilial("SB6")+"' AND B6_PRODUTO='"+TRBSTRU->D2_COD+"' AND B6_DOC='"+TRBSTRU->B6_DOC+"' AND B6_SERIE='"+TRBSTRU->B6_SERIE+"' AND D_E_L_E_T_=''"
			//Carrega o saldo da remessa da tabela SB6
			If SELECT('SALDO_')>0
				SALDO_->(DBCLOSEAREA())
			EndIf
			DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrw), "SALDO_", .F., .F. )
			SALDO_->(DBGOTOP())				
			cLin += '<th '+CorLin+'><small>Saldo:'+TRANSFORM(SALDO_->B6_SALDO,"@E 999,999.9999")+'</small></th> '
						
			If nContDias < 0
				cLin += '<th '+CorLin+'><small>Dias a expirar:'+cvaltochar(ABS(nContDias))+' dia(s)</small></th>'
			Else
				cLin += '<th '+CorLin+'><small>Expirado:'+cvaltochar(nContDias)+' dia(s)</small></th>'	
			EndIf
			cLin += '<th '+CorLin+'><small>Prazo:'+cvaltochar(TRBSTRU->Z97_PRAZO)+' dia(s)</small></th>'		
			cLin += '<th '+CorLin+'></th>'
			cLin += '<th '+CorLin+'></th>'
			cLin += '<th '+CorLin+'><small>Situacao: '+cFlag+'</small></th>'
			cLin += '</tbody></table> '
			cIdentfic:=""
			cLin +=	CARGNOTR(TRBSTRU->B6_IDENT,TRBSTRU->B6_DOC,TRBSTRU->B6_SERIE,@cIdentfic)//ROTINA PARA CONSTRUÇÃO DE ITENS DE REMESSA
			
			fWrite(nArq, cLin+CRLF)
			cLin := ""
			
			cLin +=	CARGNOTD(TRBSTRU->B6_IDENT,TRBSTRU->B6_DOC,TRBSTRU->B6_SERIE,TRBSTRU->B6_PRODUTO,cIdentfic,cFlag,nContDias)//ROTINA PARA CONSTRUÇÃO DE ITENS DE DEVOLUÇÃO
			cLin += ' 	</td></tr> '
			cLin += ' 	</table> '			
		
			If !lCorpo
				fWrite(nArq, cLin+CRLF)
				cLin := ""
			Else
				cMsg += cLin
			EndIf		
			TRBSTRU->(dbskip())
		EndDo
	EndIf
EndIf

//FECHA ARQUIVO HTML
cMsg += '</body></html>'

If !lCorpo
	fWrite(nArq, '</body></html>' +CRLF)
	cLin := ""
EndIf

fClose(nArq)
//SLEEP(5000)

If !lDesk// gera desktop
	If nRegs > 1
		PUTMAIL(cMail,cMsg,!lCorpo,cEmpresa)
	EndIf
	FERASE(cArq)
Else
	If MsgYesNo("Deseja enviar e-mail?"+CHR(13)+CHR(10)+"Para:"+ALLTRIM(cMail))
		PUTMAIL(cMail,cMsg,!lCorpo,cEmpresa)
	EndIf
	Return (cArq)
EndIf

Return .T.
          
/*
Funcao      : PROCHTM
Parametros  : 
Retorno     : 
Objetivos   : funcao acessoria de processamento da funcao GTM002()
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*-----------------------*
Static Function PROCHTM()
*-----------------------*
cpys2t(cPathSrv,cDirRmt,.t.)
cExt := '.xls'
cOpen := cDirrmt+cFile
SHELLEXECUTE("open",cOpen,"","",5)

MsgInfo("Arquivo Processado, o visualizador de pagina de internet padrao apresentara o relatorio!")

Return .T.

/*
Funcao      : E_CAB
Parametros  : 
Retorno     : 
Objetivos   : CABECARIO HTML
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*--------------------------*
Static Function E_CAB(lPar) 
*--------------------------*
Private cRet := ""

cRet := '   <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> '
cRet += '   <html>   '
cRet += '   <head>   '
cRet += '     <meta content="text/html; charset=ISO-8859-1"   '
cRet += '    http-equiv="content-type">				'
cRet += '     <title>HLB BRASIL - Poder de Terceiros</title>   '
cRet += '   </head> '
cRet += '   <body> '
cRet += '   <span style="font-weight: bold;">Relacao de Poder de Terceiros</span> (emissao - '+DTOC(DATE())+' &nbsp;'+TIME()+')<br>				   '
cRet += '   <br> '

If !lPar
	fWrite(nArq, cRet+CRLF)
	//cRet := "MENSAGEM ANEXO!"
	cRet := ""
	cRet+='<html xmlns:v="urn:schemas-microsoft-com:vml"'
	cRet+='xmlns:o="urn:schemas-microsoft-com:office:office"'
	cRet+='xmlns:w="urn:schemas-microsoft-com:office:word" '
	cRet+='xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"'
	cRet+='xmlns="http://www.w3.org/TR/REC-html40">'
	cRet+='<head>
	cRet+='	<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
	cRet+='	<meta name=ProgId content=Word.Document> '
	cRet+='	<meta name=Generator content="Microsoft Word 12"> '
	cRet+='	<meta name=Originator content="Microsoft Word 12">'
	cRet+='</head>
	cRet+='<body bgcolor="#FFFFFF" lang=PT-BR link=blue vlink=purple style="tab-interval:35.4pt">'
	cRet+='<div class=WordSection1>'
	cRet+="	<p class=MsoNormal  align=center style='text-align:center'> "
	cRet+='		<a href="http://www.grantthornton.com.br/">'
	cRet+="			<span style='text-decoration:none; text-underline:none'>"
	cRet+='				<center><img width=680 border=0 id="_x0000_i1025" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" nosend=1>'
	cRet+="			</span>"
	cRet+="		</a>"  
	cRet+="    </p>"
	cRet+="</div>"
	cRet+="<h1>"
	cRet+="<div align=center>"
	cRet+="	<table class=MsoNormalTable border=0 cellpadding=0 width=800 style='width:525.0pt;mso-cellspacing:1.5pt;background:white;mso-yfti-tbllook:1184'>"
	cRet+="		<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
	cRet+="			<td style='padding:.75pt .75pt .75pt .75pt'>"
	cRet+="				<div align=center>"
	cRet+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
	cRet+="						<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
	cRet+="							<td style='background:#4D1174;padding:0cm 0cm 0cm 0cm'>"
	cRet+="								<p class=MsoNormal align=left style='text-align:center'><b> "
	cRet+="<span style='font-size:10pt;font-family:"
	cRet+='"Verdana","sans-serif"'
	cRet+=";mso-fareast-font-family:"
	cRet+='"Times New Roman"'
	cRet+=";color:white'>"
	cRet+="										Relatório Anexo!"
	cRet+="									</span></b>"
	cRet+="								</p>"
	cRet+="							</td>"
	cRet+="						</tr>"
	cRet+="					</table>"
	cRet+="				</div>"
	cRet+="			</td>"  
	cRet+="		</tr>"						
	cRet+="   	</table>"
	cRet+="</div>"	
	cRet+="<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
	cRet+="	<td style='padding:.75pt .75pt .75pt .75pt'>"
	cRet+="		<p class=MsoNormal align=center style='text-align:center'>"
	cRet+="			<span class=tituloatencao1>"
	cRet+="				<span style='font-size:9.5pt;mso-fareast-font-family:"
	cRet+='				"Times New Roman"'
	cRet+="				;color:red'>"
	cRet+="						HLB BRASIL - Mensagem automática, favor não responder este e-mail."
	cRet+="				</span>"
	cRet+="			</span>"
	cRet+="		</p>"
	cRet+="    </td>"
	cRet+="</tr>"
//	cRet+="</body>"
//	cRet+="</html>"
EndIf

Return (cRet)

/*
Funcao      : QUALFlag
Parametros  : 
Retorno     : 
Objetivos   : TRATA COR DO ALERTA
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*-------------------------------*
Static Function QUALFlag(nD1,nD2)
*-------------------------------*d                               
Private cRet := ""
Private nP := 0

If nD2 == 0
	Return ("")
EndIf

If nD1 >= nD2
	cRet := "Critico"		// VERMELHO
Else
	nP := (nD1/nD2) * 100
	If nP > 75
		cRet := "Atencao"	// VERMELHO		
	ElseIf nP > 50
		cRet := "Normal"	// AMARELO		
	ElseIf nP > 25
		cRet := ""			// AZUL		
	Else
		cRet := ""			// BRANCO		
	EndIf
EndIf

Return (cRet)

/*
Funcao      : PUTMAIL
Parametros  : 
Retorno     : 
Objetivos   : ROTINA DE ENVIO DE EMAIL DO HTML GERADO 
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*---------------------------------------------------*
Static Function PUTMAIL(cDest,cBody,lAnexo,cEmpresa) 
*---------------------------------------------------*
Private cSrv := GetMV("MV_RElseRV")  //ENDEREÇO DO SERVIDOR SMTP smtp.ig.com.br
Private cMail := GetMV("MV_RELACNT") //EMAIL                     meuemail@ig.com.br
Private cPass := GetMV("MV_RELPSW")  //SENHA DO EMAIL            123abc
Private lAuth := GetMv("MV_RELAUTH") //Requer Autenticacao?
Private cPswA := GetMV("MV_RELAPSW") //SENHA DA AUTENTICAÇÃO     123abc
Private lResult := .T.
Default cEmpresa:=""

CONNECT SMTP SERVER cSrv;     //Nome do servidor SMTP
ACCOUNT cMail;   //Conta de Email
PASSWORD cPass;  //Senha de conexao
RESULT lResul    //Resultado da Conexao

If lResult
	If !lAnexo
		SEND MAIL FROM cMail ;
		TO cDest;
		SUBJECT "PODER 3. "+DTOC(DATE())+" - "+TIME()+" - "+cEmpresa ;
		BODY cBody;
		RESULT lResult := .t.
	Else  
	    If UPPER(RIGHT(cArq,4)) == "HTML"
			__CopyFile( cArq, LEFT(ALLTRIM(cArq),LEN(ALLTRIM(cArq))-4)+"XLS" )
			cArqMail := LEFT(ALLTRIM(cArq),LEN(ALLTRIM(cArq))-4)+"XLS"
		Else                
			cArqMail := SUBSTR(cArq,1,RAT(".",cArq)-1)+"A.XLS"
			__CopyFile( cArq, cArqMail )
	    EndIf
	                   
		//Tratamento para zipar quando maior que 4 Mb.
 		If ( Directory(cArqMail,"D")[1][2]/(1024^2) ) >= 4
			//SUBSTR(cArqMail,1,RAT(".",cArqMail))+"zip"
			compacta(cArqMail,SUBSTR(cArqMail,1,RAT(".",cArqMail))+"zip")
			cArqMail := SUBSTR(cArqMail,1,RAT(".",cArqMail))+"zip"
		EndIf
	
		SEND MAIL FROM cMail ;
		TO cDest;
		SUBJECT "PODER 3. "+DTOC(DATE())+" - "+TIME()+" - "+cEmpresa ;
		BODY cBody;
		ATTACHMENT cArqMail ;
		RESULT lResult
		
		Sleep(500)
		
		If File(cArqMail)
			FErase(cArqMail)
		EndIf
	EndIf

	If !lResult
		GET MAIL ERROR cError
		Conout("GTJ001.PRW -> FALHA NO ENVIO DE EMAIL: "+cError)
	EndIf

Else
	GET MAIL ERROR cError
	Conout("GTJ001.PRW -> FALHA NO ENVIO DE EMAIL: "+cError)
EndIf

//Desconecta do servidor
DISCONNECT SMTP SERVER

Return .T.

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : MONTA BASE DE DADOS  (EXCLUSIVO SINTAXE SQLSERVER)  
				QUERY PARA MONTAR ARQUIVO DE TRABALHO DE REGISTROS DO SB6 QUE POSSUAM NOTAS DE SAÍDA 
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*------------------------*
Static Function PODER3DB()
*------------------------*
Local cWhereA := ""
Local cWhereB := ""

cWhereA := "% B6.B6_SALDO > 0 AND B6.B6_TPCF = 'C' %"
cWhereB := "% B6.B6_SALDO > 0 AND B6.B6_TPCF = 'F' %"

BEGINSQL ALIAS "TRB"
	COLUMN B6_EMISSAO AS DATE
	COLUMN B6_SALDO   AS NUMERIC(17,2)
	COLUMN B6_QUANT   AS NUMERIC(17,2)
	COLUMN Z97_PRAZO  AS NUMERIC(17,2)
	COLUMN D2_QUANT   AS NUMERIC(17,2)
	COLUMN D2_VALICM  AS NUMERIC(17,2)
	COLUMN D2_VALIPI  AS NUMERIC(17,2)
	COLUMN F2_VALBRUT AS NUMERIC(17,2)
	COLUMN D2_DTVALID AS DATE
	
	SELECT 'CLIENTE' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
					, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
					, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
					, D2.D2_COD, D2.D2_QUANT, D2.D2_LOTECTL, D2.D2_DTVALID, D2.D2_LOCAL, D2.D2_VALICM, D2.D2_VALIPI, D2.D2_CF, D2.D2_TES
					, B1.B1_COD, B1.B1_DESC
					, F2.F2_VALBRUT, B6.B6_IDENT
					, A1.A1_CGC , A1.A1_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL,D2.D2_TOTAL
	FROM %table:SB6% B6 (NOLOCK)
		LEFT 	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
		LEFT 	JOIN %table:SA1% A1 (NOLOCK) ON A1.%NotDel% AND A1.A1_FILIAL = %xfilial:SA1% AND A1.A1_COD = B6.B6_CLIFOR AND A1.A1_LOJA = B6.B6_LOJA
		INNER 	JOIN %table:SD2% D2 (NOLOCK) ON D2.%NotDel% AND D2.D2_FILIAL = %xfilial:SD2% AND D2.D2_DOC = B6.B6_DOC 
															AND D2.D2_SERIE = B6.B6_SERIE AND D2.D2_IDENTB6 = B6.B6_IDENT
		LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND ZH.Z97_CFO = D2.D2_CF
		INNER 	JOIN %table:SF2% F2 (NOLOCK) ON F2.%NotDel% AND F2.F2_FILIAL = %xfilial:SF2% AND F2.F2_DOC = B6.B6_DOC AND F2.F2_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%
			AND %exp:cWhereA%
			
	UNION ALL
	SELECT 'FORNECEDOR' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D2.D2_DOC, D2.D2_QUANT, D2.D2_LOTECTL, D2.D2_DTVALID, D2.D2_LOCAL, D2.D2_VALICM, D2.D2_VALIPI, D2.D2_CF, D2.D2_TES
			, B1.B1_COD, B1.B1_DESC
			, F2.F2_VALBRUT, B6.B6_IDENT
			, A2.A2_CGC , A2.A2_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL,D2.D2_TOTAL
	FROM %table:SB6% B6 (NOLOCK)
			LEFT	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT	JOIN %table:SA2% A2 (NOLOCK) ON A2.%NotDel% AND A2.A2_FILIAL = %xfilial:SA2% AND A2.A2_COD = B6.B6_CLIFOR AND A2.A2_LOJA = B6.B6_LOJA
			INNER	JOIN %table:SD2% D2 (NOLOCK) ON D2.%NotDel% AND D2.D2_FILIAL = %xfilial:SD2% AND D2.D2_DOC = B6.B6_DOC
																AND D2.D2_SERIE = B6.B6_SERIE AND D2.D2_IDENTB6 = B6.B6_IDENT
			LEFT	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND Z97_CFO = D2.D2_CF
			INNER	JOIN %table:SF2% F2 (NOLOCK) ON F2.%NotDel% AND F2.F2_FILIAL = %xfilial:SF2% AND F2.F2_DOC = B6.B6_DOC AND F2.F2_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%        
			AND %exp:cWhereB%
    ORDER BY B1_COD
	
ENDSQL

Return .T.

/*
Funcao      : PODER3PR
Parametros  : 
Retorno     : 
Objetivos   : QUERY PARA REMESSAS COM PARAMETROS
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*------------------------*
Static Function PODER3PR()
*------------------------*
Local cWhereA := ""
Local cWhereB := ""


cWhereA := "% B6.B6_SALDO > 0 AND B6.B6_TPCF = 'C' "
If lDesk
	cWhereA += " AND B6.B6_PRODUTO BETWEEN '"+ALLTRIM(MV_PAR02)+"' AND '"+ALLTRIM(MV_PAR03)+"'
	cWhereA += " AND B6.B6_DOC     BETWEEN '"+ALLTRIM(MV_PAR04)+"' AND '"+ALLTRIM(MV_PAR05)+"'
	cWhereA += " AND B6.B6_SERIE   BETWEEN '"+ALLTRIM(MV_PAR06)+"' AND '"+ALLTRIM(MV_PAR07)+"'
	cWhereA += " AND B6.B6_LOCAL   BETWEEN '"+ALLTRIM(MV_PAR08)+"' AND '"+ALLTRIM(MV_PAR09)+"'
	cWhereA += " AND D2.D2_CF IN ("+ALLTRIM(MV_PAR10)+")
	cWhereA += " AND (   B6.B6_CLIFOR BETWEEN '"+ALLTRIM(MV_PAR11)+"' AND '"+ALLTRIM(MV_PAR12)+"' 
	cWhereA += "	  OR B6.B6_CLIFOR BETWEEN '"+ALLTRIM(MV_PAR13)+"' AND '"+ALLTRIM(MV_PAR14)+"')
	cWhereA += " AND ZH.Z97_PRAZO IN ("+ALLTRIM(MV_PAR15)+")
EndIf
cWhereA += " %"

cWhereB := "% B6.B6_SALDO > 0 AND B6.B6_TPCF = 'F'
If lDesk
	cWhereB += " AND B6.B6_PRODUTO BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'
	cWhereB += " AND B6.B6_DOC     BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	cWhereB += " AND B6.B6_SERIE   BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'
	cWhereB += " AND B6.B6_LOCAL   BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'
	cWhereB += " AND D2.D2_CF IN ("+MV_PAR10+")
	cWhereB += " AND (B6.B6_CLIFOR BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' OR B6.B6_CLIFOR BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"')
	cWhereB += " AND ZH.Z97_PRAZO IN ("+MV_PAR15+")
EndIf
cWhereB += " %"

BEGINSQL ALIAS "TRB"
	COLUMN B6_EMISSAO AS DATE
	COLUMN B6_SALDO   AS NUMERIC(17,2)
	COLUMN B6_QUANT   AS NUMERIC(17,2)
	COLUMN Z97_PRAZO  AS NUMERIC(17,2)
	COLUMN D2_QUANT   AS NUMERIC(17,2)
	COLUMN D2_VALICM  AS NUMERIC(17,2)
	COLUMN D2_VALIPI  AS NUMERIC(17,2)
	COLUMN F2_VALBRUT AS NUMERIC(17,2)  
	COLUMN D2_DTVALID AS DATE
	
	SELECT 'CLIENTE' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D2.D2_COD, D2.D2_QUANT, D2.D2_LOTECTL, D2.D2_DTVALID, D2.D2_LOCAL, D2.D2_VALICM, D2.D2_VALIPI, D2.D2_CF, D2.D2_TES
			, B1.B1_COD, B1.B1_DESC
			, F2.F2_VALBRUT, B6.B6_IDENT
			, A1.A1_CGC , A1.A1_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL, B6.R_E_C_N_O_,B6.B6_PODER3,D2.D2_TOTAL
	FROM %table:SB6% B6 (NOLOCK)
			LEFT	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA1% A1 (NOLOCK) ON A1.%NotDel% AND A1.A1_FILIAL = %xfilial:SA1% AND A1.A1_COD = B6.B6_CLIFOR AND A1.A1_LOJA = B6.B6_LOJA
			INNER 	JOIN %table:SD2% D2 (NOLOCK) ON D2.%NotDel% AND D2.D2_FILIAL = %xfilial:SD2% AND D2.D2_DOC = B6.B6_DOC 
																AND D2.D2_SERIE = B6.B6_SERIE AND D2.D2_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND ZH.Z97_CFO = D2.D2_CF
			INNER 	JOIN %table:SF2% F2 (NOLOCK) ON F2.%NotDel% AND F2.F2_FILIAL = %xfilial:SF2% AND F2.F2_DOC = B6.B6_DOC AND F2.F2_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%
			AND %exp:cWhereA%
	
	UNION ALL
	SELECT 'FORNECEDOR' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D2.D2_COD, D2.D2_QUANT, D2.D2_LOTECTL, D2.D2_DTVALID, D2.D2_LOCAL, D2.D2_VALICM, D2.D2_VALIPI, D2.D2_CF, D2.D2_TES
			, B1.B1_COD, B1.B1_DESC
			, F2.F2_VALBRUT, B6.B6_IDENT
			, A2.A2_CGC , A2.A2_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL,B6.R_E_C_N_O_,B6.B6_PODER3,D2.D2_TOTAL
	FROM %table:SB6% B6 (NOLOCK)
			LEFT 	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA2% A2 (NOLOCK) ON A2.%NotDel% AND A2.A2_FILIAL = %xfilial:SA2% AND A2.A2_COD = B6.B6_CLIFOR AND A2.A2_LOJA = B6.B6_LOJA
			INNER 	JOIN %table:SD2% D2 (NOLOCK) ON D2.%NotDel% AND D2.D2_FILIAL = %xfilial:SD2% AND D2.D2_DOC = B6.B6_DOC 
																AND D2.D2_SERIE = B6.B6_SERIE AND D2.D2_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND Z97_CFO = D2.D2_CF
			INNER 	JOIN %table:SF2% F2 (NOLOCK) ON F2.%NotDel% AND F2.F2_FILIAL = %xfilial:SF2% AND F2.F2_DOC = B6.B6_DOC AND F2.F2_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%        
			AND %exp:cWhereB%
    ORDER BY B1_COD
	
ENDSQL

Return .T.  

/*
Funcao      : PODE3PRD
Parametros  : 
Retorno     : 
Objetivos   : QUERY PARA DEVOLUCOES COM PARAMETROS
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*-----------------------*
Static Function PODE3PRD()
*-----------------------*
Local cWhereA := ""
Local cWhereB := ""

cWhereA := "% B6.B6_PODER3 = 'D' AND B6.B6_SALDO > 0 AND B6.B6_TPCF = 'C'
If lDesk
	cWhereA += " AND B6.B6_PRODUTO BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'
	cWhereA += " AND B6.B6_DOC     BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	cWhereA += " AND B6.B6_SERIE   BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'
	cWhereA += " AND B6.B6_LOCAL   BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'
	cWhereA += " AND (B6.B6_CLIFOR BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' OR B6.B6_CLIFOR BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"')
	cWhereA += " AND D1.D1_CF IN ("+MV_PAR10+")
	cWhereA += " AND ZH.Z97_PRAZO IN ("+MV_PAR15+")"
	If MV_PAR17 == 2
		cWhereA += " AND D1.D1_NFORI = ' ' AND D1.D1_SERIORI = ' ' AND D1.D1_ITEMORI = ' ' "
	EndIf
EndIf
cWhereA += " %"  

cWhereB := "% B6.B6_PODER3='D' AND B6.B6_SALDO > 0 AND B6.B6_TPCF = 'F'
If lDesk
	cWhereB += " AND B6.B6_PRODUTO BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'
	cWhereB += " AND B6.B6_DOC     BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	cWhereB += " AND B6.B6_SERIE   BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'
	cWhereB += " AND B6.B6_LOCAL   BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'
	cWhereB += " AND (B6.B6_CLIFOR BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' OR B6.B6_CLIFOR BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"')
	cWhereB += " AND D1.D1_CF IN ("+MV_PAR10+")
	cWhereB += " AND ZH.Z97_PRAZO IN ("+MV_PAR15+")"
	If MV_PAR17 == 2
		cWhereB += " AND D1.D1_NFORI = ' ' AND D1.D1_SERIORI = ' ' AND D1.D1_ITEMORI = ' ' "
	EndIf
EndIf
cWhereB += " %"  

BEGINSQL ALIAS "TRD"
	
	COLUMN B6_EMISSAO AS DATE
	COLUMN B6_SALDO   AS NUMERIC(17,2)
	COLUMN B6_QUANT   AS NUMERIC(17,2)
	COLUMN Z97_PRAZO  AS NUMERIC(17,2)
	COLUMN D1_QUANT   AS NUMERIC(17,2)
	COLUMN D1_VALICM  AS NUMERIC(17,2)
	COLUMN D1_VALIPI  AS NUMERIC(17,2)
	COLUMN F1_VALBRUT AS NUMERIC(17,2)
	COLUMN D1_DTVALID AS DATE
	
	SELECT 'CLIENTE' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D1.D1_COD, D1.D1_QUANT, D1.D1_LOTECTL, D1.D1_DTVALID, D1.D1_LOCAL, D1.D1_VALICM, D1.D1_VALIPI, D1.D1_CF, D1.D1_TES
			, B1.B1_COD, B1.B1_DESC
			, F1.F1_VALBRUT, B6.B6_IDENT
			, A1.A1_CGC , A1.A1_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL, B6.R_E_C_N_O_,B6.B6_PODER3,D1.D1_TOTAL
	FROM %table:SB6% B6 (NOLOCK)
			LEFT 	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA1% A1 (NOLOCK) ON A1.%NotDel% AND A1.A1_FILIAL = %xfilial:SA1% AND A1.A1_COD = B6.B6_CLIFOR AND A1.A1_LOJA = B6.B6_LOJA
			INNER 	JOIN %table:SD1% D1 (NOLOCK) ON D1.%NotDel% AND D1.D1_FILIAL = %xfilial:SD1% AND D1.D1_DOC = B6.B6_DOC 
																AND D1.D1_SERIE = B6.B6_SERIE AND D1.D1_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND ZH.Z97_CFO = D1.D1_CF
			INNER 	JOIN %table:SF1% F1 (NOLOCK) ON F1.%NotDel% AND F1.F1_FILIAL = %xfilial:SF1% AND F1.F1_DOC = B6.B6_DOC AND F1.F1_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%
			AND %exp:cWhereA%
	
	UNION ALL
	SELECT 'FORNECEDOR' ORIGEM, B6.B6_DOC, B6.B6_SERIE, B6.B6_EMISSAO, B6.B6_SALDO, B6.B6_QUANT
			, DATEPART(DAY,CONVERT(DATETIME, %exp:DTOS(DATE())%, 103) - CONVERT(DATETIME, B6.B6_EMISSAO , 103)) DIAS
			, ISNULL(ZH.Z97_PRAZO,0) Z97_PRAZO
			, D1.D1_COD, D1.D1_QUANT, D1.D1_LOTECTL, D1.D1_DTVALID, D1.D1_LOCAL, D1.D1_VALICM, D1.D1_VALIPI, D1.D1_CF, D1.D1_TES
			, B1.B1_COD, B1.B1_DESC
			, F1.F1_VALBRUT, B6.B6_IDENT
			, A2.A2_CGC , A2.A2_NREDUZ, B6.B6_PRODUTO, B6.B6_LOCAL,B6.R_E_C_N_O_,B6.B6_PODER3,D1.D1_TOTAL
	FROM %table:SB6% B6 (NOLOCK)
			LEFT 	JOIN %table:SB1% B1 (NOLOCK) ON B1.%NotDel% AND B1.B1_FILIAL = %xfilial:SB1% AND B1.B1_COD = B6.B6_PRODUTO
			LEFT 	JOIN %table:SA2% A2 (NOLOCK) ON A2.%NotDel% AND A2.A2_FILIAL = %xfilial:SA2% AND A2.A2_COD = B6.B6_CLIFOR AND A2.A2_LOJA = B6.B6_LOJA
			INNER	JOIN %table:SD1% D1 (NOLOCK) ON D1.%NotDel% AND D1.D1_FILIAL = %xfilial:SD1% AND D1.D1_DOC = B6.B6_DOC 
																AND D1.D1_SERIE = B6.B6_SERIE AND D1.D1_IDENTB6 = B6.B6_IDENT
			LEFT 	JOIN %table:Z97% ZH (NOLOCK) ON ZH.%NotDel% AND ZH.Z97_FILIAL = %xfilial:Z97% AND Z97_CFO = D1.D1_CF
			INNER 	JOIN %table:SF1% F1 (NOLOCK) ON F1.%NotDel% AND F1.F1_FILIAL = %xfilial:SF1% AND F1.F1_DOC = B6.B6_DOC AND F1.F1_SERIE = B6.B6_SERIE
	WHERE B6.%NotDel%
			AND %exp:cWhereB%
    ORDER BY B1_COD
	
ENDSQL

Return .T.

/*
Funcao      : 
Parametros  : cCor   COR DA LINHA
	          cIdent IDENTIFICADOR DA TABELA SB6
    	      cProd  COD. PRODUTO
        	  nQtd   QUANTIDADE
	          nSld   SALDO DO P3
    	      cCorxt COR DE AVISO
Retorno     : 
Objetivos   : ROTINA AUXILIAR PARA CONSTRUÇÃO DE ITENS DE REMESSAS EM HTML
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*---------------------------------------------------------*
Static Function cargarem(cCor,cIdent,cProd,nQtd,nSld,cCorx)
*---------------------------------------------------------*
Local aAreaR := getArea()
Local cRet   := ""
Local cRetCompl	 :=	""		

cRet += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
cRet += '     <thead> '
cRet += '	   <tr>  '
cRet += '			<td colspan="12"  style="font-weight: bold; color: black; background-color: rgb(192,217,217); text-align: center;" ><small>REMESSAS</small></td> '
cRet += '	   </tr>  '
cRet += '      <tr>  '                                                                  
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>NF</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Serie</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Data</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Cliente</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>CNPJ</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Qtdade</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>TES</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>CFO</small></td> '
//RRP - 16/12/2014 - Inclusão do Lote e Validade. Chamado 023133.
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Lote</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Vld. Lote</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor ICMS</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor IPI</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor Total NF</small></td> '	 		 		 		 	
cRet += '      </tr>  '
cRet += '      </thead>  '
cRet += '     <tbody> '

dbselectarea("SB6")
dbsetorder(3)
dbgotop()
If dbseek(xfilial("SB6")+cIdent+cProd+"R") //SOMENTE SE EXISTIR REGISTROS DE REMESSA
	While SB6->(!EOF()) .AND. SB6->B6_IDENT == cIdent .AND. SB6->B6_PRODUTO == cProd .AND. SB6->B6_PODER3 == "R"
	 	cRetCompl += '      <tr>  '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRB->B6_DOC+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRB->B6_SERIE+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(TRB->B6_EMISSAO)+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRB->A1_NREDUZ+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRB->A1_CGC+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRB->D2_QUANT,PesqPict("SD2","D2_QUANT"))+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRB->D2_TES+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRB->D2_CF+'</small></td> '
	 	//RRP - 16/12/2014 - Inclusão do Lote e Validade. Chamado 023133.
		cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRB->D2_LOTECTL+'</small></td> '
		cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(TRB->D2_DTVALID)+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRB->D2_VALICM,PesqPict("SD2","D2_VALICM"))+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRB->D2_VALIPI,PesqPict("SD2","D2_VALIPI"))+'</small></td> '
	 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRB->D2_TOTAL,PesqPict("SD2","D2_TOTAL"))+'</small></td> '
	 	cRetCompl += '      </tr>  '                            
		SB6->(DBSKIP())
	EndDo
EndIf
cRet += cRetCompl
cRet += '      </tbody>  '
cRet += '      </table>  '
//cRet += '<br>  '

RestArea(aAreaR)

Return (cRet)

/*
Funcao      : cargadev
Parametros  : cCor   COR DA LINHA                     
				cIdent IDENTIFICADOR DA TABELA SB6      
				cProd  COD. PRODUTO                     
				nQtd   QUANTIDADE                       
				nSld   SALDO DO P3                      
				cCorxt COR DE AVISO    
Retorno     : 
Objetivos   : 
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*---------------------------------------------------------*
Static Function cargadev(cCor,cIdent,cProd,nQtd,nSld,cCorx)
*---------------------------------------------------------*
Local aAreaD := getArea()
Local cRet   := ""
Local cRetCompl := ""
Local cQry:=""

dbselectarea("SB6")
SB6->(dbsetorder(3))
dbgotop()  
If SB6->(dbseek(xfilial("SB6")+cIdent+cProd+"D")) //SOMENTE SE EXISTIR REGISTROS DE DEVOLUÇÃO
	cRet += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
	cRet += '     <thead> '
	cRet += '		<tr>  '
	cRet += '			<td colspan="12"  style="font-weight: bold; color: black; background-color: rgb(192,217,217); text-align: center;" ><small>DEVOLUCOES</small></td> '
	cRet += '		</tr>  '
	cRet += '		<tr>  '		 	 	
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>NF</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Serie</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Dt Retorno</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small> </small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small> </small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Qtdade</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>TES</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>CFO</small></td> '
	//RRP - 16/12/2014 - Inclusão do Lote e Validade. Chamado 023133.
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Lote</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Vld. Lote</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor ICMS</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor IPI</small></td> '
	cRet += '          	<td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor Total NF</small></td> '			 				 				 				 				 				 				 			 	 	
	cRet += '		</tr>  '		 	 	
	cRet += '     </thead>  '
	cRet += '	<tbody>  '
	
	cQry+=" SELECT SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_EMISSAO, SUM(SD1.D1_QUANT) AS D1_QUANT,SD1.D1_TES,SD1.D1_CF,SD1.D1_LOTECTL,SD1.D1_DTVALID,SUM(SF1.F1_VALICM) AS F1_VALICM,SUM(SF1.F1_VALIPI) AS F1_VALIPI,SUM(SD1.D1_TOTAL) AS D1_TOTAL "+CRLF
	cQry+=" FROM "+RETSQLNAME("SB6")+" SB6 "+CRLF
	cQry+=" JOIN "+RETSQLNAME("SF1")+" SF1 ON SF1.F1_FILIAL = '"+XFILIAL("SF1")+"' AND SF1.F1_DOC = SB6.B6_DOC AND SF1.F1_SERIE = SB6.B6_SERIE AND SB6.B6_CLIFOR = SF1.F1_FORNECE AND SB6.B6_LOJA=SF1.F1_LOJA "+CRLF
	cQry+=" JOIN "+RETSQLNAME("SD1")+" SD1 ON SD1.D1_FILIAL = '"+XFILIAL("SD1")+"' AND SD1.D1_DOC = SB6.B6_DOC AND SD1.D1_SERIE = SB6.B6_SERIE AND SB6.B6_CLIFOR = SD1.D1_FORNECE AND SB6.B6_LOJA=SD1.D1_LOJA AND SB6.B6_PRODUTO=SD1.D1_COD "+CRLF
	cQry+=" WHERE SB6.B6_IDENT = '"+cIdent+"' AND SB6.B6_PRODUTO = '"+cProd+"' AND SB6.B6_PODER3 = 'D' AND SB6.B6_DOC <> '"+TRB->B6_DOC+"' AND SD1.D1_IDENTB6='"+cIdent+"' "+CRLF
	cQry+=" AND SF1.D_E_L_E_T_='' AND SB6.D_E_L_E_T_='' AND SD1.D_E_L_E_T_='' "+CRLF
	If lDesk .and. MV_PAR17 == 2
		cQry += " AND SD1.D1_NFORI = ' ' AND SD1.D1_SERIORI = ' ' AND SD1.D1_ITEMORI = ' ' "
	EndIf
	cQry+=" GROUP BY F1_DOC, F1_SERIE, F1_EMISSAO, D1_TES, D1_CF,D1_LOTECTL,D1_DTVALID "+CRLF
	cQry+=" ORDER BY SF1.F1_EMISSAO "

	If SELECT('DEV_')>0
		DEV_->(DBCLOSEAREA())
	EndIf							
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "DEV_", .F., .F. )
	DEV_->(DBGOTOP())
	While DEV_->(!EOF())
	 	cRetCompl += '      	<tr>  '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->F1_DOC+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->F1_SERIE+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(STOD(DEV_->F1_EMISSAO))+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small> </small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small> </small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(DEV_->D1_QUANT,PesqPict("SB6","B6_QUANT"))+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_TES+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_CF+'</small></td> '
	 	//RRP - 16/12/2014 - Inclusão do Lote e Validade. Chamado 023133.
		cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_LOTECTL+'</small></td> '
		cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(STOD(DEV_->D1_DTVALID))+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(DEV_->F1_VALICM,PesqPict("SF1","F1_VALICM"))+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(DEV_->F1_VALIPI,PesqPict("SF1","F1_VALIPI"))+'</small></td> '
	 	cRetCompl += '          	<td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(DEV_->D1_TOTAL,PesqPict("SD1","D1_TOTAL"))+'</small></td> '			 				 				 				 				 				 				 	
	 	cRetCompl += '      	</tr>  '
		DEV_->(DBSKIP())
	EndDo 
EndIf
cRet += cRetCompl
cRet += '		</tbody>  '			 	
cRet += '   </table>  '
//cRet += '<br>  '         

RestArea(aAreaD)

Return (cRet)

/*
Funcao      : cargNOTR
Parametros  : 
Retorno     : 
Objetivos   : Carrega item quando for por nota remessa
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*----------------------------------------------------*
Static Function cargNOTR(cIdent,cDoc,cSerie,cIdentfic)
*----------------------------------------------------*
Local cRet   := ""
Local cRetCompl	 :=	""		
Local cRecno:=0

cRet += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
cRet += '     <thead> '
cRet += '      <tr>  '                                                                  
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Produto</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Descricao</small></td> '
cRet += '       		   <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Data</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Local</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Qtdade</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>TES</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>CFO</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Lote</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Dt.Lote</small></td> '
cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor</small></td> '
cRet += '      </tr>  '
cRet += '     </thead>  '
cRet += '     <tbody> '

While TRBSTRU->B6_DOC==cDoc .AND. TRBSTRU->B6_SERIE==cSerie .AND. TRBSTRU->B6_PODER3=='R'
	cIdentfic += "'"+ TRBSTRU->B6_IDENT +"',"
 	cRetCompl += '      <tr>  '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->B1_COD+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->B1_DESC+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(TRBSTRU->B6_EMISSAO)+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->B6_LOCAL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRBSTRU->D2_QUANT,PesqPict("SD2","D2_QUANT"))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->D2_TES+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->D2_CF+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+TRBSTRU->D2_LOTECTL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(TRBSTRU->D2_DTVALID)+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(TRBSTRU->D2_TOTAL,PesqPict("SD2","D2_TOTAL"))+'</small></td> '
 	cRetCompl += '      </tr>  '                            

	cRecno:=TRBSTRU->R_E_C_N_O_

	TRBSTRU->(DbSkip())
EndDo

TRBSTRU->(DbSeek(cRecno))

cRet += cRetCompl
cRet += '      </tbody>  '
cRet += '      </table>  '
//cRet += '<br>  '

Return (cRet)

/*
Funcao      : cargNOTD
Parametros  : 
Retorno     : 
Objetivos   : Carrega item quando for por nota devolucao
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*--------------------------------------------------------------------------*
Static Function cargNOTD(cIdent,cDoc,cSerie,cProd,cIdentfic,cFlag,nContDias)
*--------------------------------------------------------------------------*
//Local aAreaR := getArea()
Local cRet   := ""
Local cRetCompl	 :=	""		
Local cRecno:=0
Local cQry:=""

cIdentfic:=SUBSTR(cIdentfic,1,RAT(",",cIdentfic)-1)

cQry+=" SELECT SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_EMISSAO,B1_COD,B1_DESC,B6_LOCAL, B6_EMISSAO, SUM(SD1.D1_QUANT) AS D1_QUANT,SD1.D1_TES,SD1.D1_CF,SD1.D1_LOTECTL,SD1.D1_DTVALID,SUM(SF1.F1_VALICM) AS F1_VALICM,SUM(SF1.F1_VALIPI) AS F1_VALIPI,SUM(SD1.D1_TOTAL) AS D1_TOTAL,SUM(SF1.F1_VALBRUT) AS F1_VALBRUT,SUM(SB6.B6_SALDO) AS B6_SALDO "+CRLF
cQry+=" FROM "+RETSQLNAME("SB6")+" SB6 "+CRLF
cQry+=" JOIN "+RETSQLNAME("SF1")+" SF1 ON SF1.F1_FILIAL = '"+XFILIAL("SF1")+"' AND SF1.F1_DOC = SB6.B6_DOC AND SF1.F1_SERIE = SB6.B6_SERIE AND SB6.B6_CLIFOR = SF1.F1_FORNECE AND SB6.B6_LOJA=SF1.F1_LOJA "+CRLF
cQry+=" JOIN "+RETSQLNAME("SD1")+" SD1 ON SD1.D1_FILIAL = '"+XFILIAL("SD1")+"' AND SD1.D1_DOC = SB6.B6_DOC AND SD1.D1_SERIE = SB6.B6_SERIE AND SB6.B6_CLIFOR = SD1.D1_FORNECE AND SB6.B6_LOJA=SD1.D1_LOJA AND SB6.B6_PRODUTO=SD1.D1_COD AND SD1.D1_QUANT=SB6.B6_QUANT "+CRLF
cQry+=" JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' AND SB1.B1_COD = SD1.D1_COD"+CRLF
cQry+=" WHERE SB6.B6_IDENT IN ("+cIdentfic+") AND SB6.B6_PRODUTO = '"+cProd+"' AND SB6.B6_PODER3 = 'D' AND SB6.B6_DOC <> '"+TRB->B6_DOC+"' AND SD1.D1_IDENTB6 IN ("+cIdentfic+") "+CRLF
cQry+=" AND SF1.D_E_L_E_T_='' AND SB6.D_E_L_E_T_='' AND SD1.D_E_L_E_T_='' "+CRLF
If lDesk .and. MV_PAR17 == 2
	cQry += " AND SD1.D1_NFORI = ' ' AND SD1.D1_SERIORI = ' ' AND SD1.D1_ITEMORI = ' ' "
EndIf
cQry+=" GROUP BY F1_DOC, F1_SERIE, F1_EMISSAO,B1_COD ,B1_DESC , B6_LOCAL, B6_EMISSAO, D1_TES, D1_CF,F1_VALBRUT,D1_LOTECTL,D1_DTVALID "+CRLF
cQry+=" ORDER BY SF1.F1_EMISSAO "

dbselectarea("SB6")
SB6->(dbsetorder(3))
dbgotop()  

If SELECT('DEV_')>0
	DEV_->(DBCLOSEAREA())
EndIf							
DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "DEV_", .F., .F. )
DEV_->(DBGOTOP())

Private nControle:=1
Private nContro2:=1
Private cSer_DOC:=""

While DEV_->(!EOF())
	cSer_DOC := DEV_->F1_SERIE+DEV_->F1_DOC   
	If nControle == 1
		//cRet += '<br> '
		cRet += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
		If nContro2 == 1
			cRet += '   <thead>
		 	cRet += '	   <tr>  '
	 	 	cRet += '			<td colspan="10" style="font-weight: bold; color: black; background-color: rgb(192,217,217); text-align: center;" ><small>DEVOLUCOES</small></td> '
		 	cRet += '	   </tr>  '		
			cRet += '   </thead>
		EndIf
		cRet += '     <tbody> '
		cRet += '<tr>  '     
		CorLin := 'style="font-weight: bold; color: black; background-color: rgb(168,168,168); text-align: left;" '
		cRet += '<th '+CorLin+'><small>NF:'+DEV_->F1_DOC+'</small></th> '
		cRet += '<th '+CorLin+'><small>Serie:'+DEV_->F1_SERIE+'</small></th> '		
		cRet += '<th '+CorLin+'><small>Data:'+DTOC(STOD(DEV_->B6_EMISSAO))+'</small></th> '		
		cRet += '<th '+CorLin+'><small>Valor Total:'+Transform(DEV_->F1_VALBRUT,PesqPict("SF1","F1_VALBRUT"))+'</small></th> '
		If nContDias < 0
			cRet += '<th '+CorLin+'><small>Dias a expirar:'+cvaltochar(ABS(nContDias))+' dia(s)</small></th>'
		Else
			cRet += '<th '+CorLin+'><small>Expirado:'+cvaltochar(nContDias)+' dia(s)</small></th>'	
		EndIf
		cRet += '<th '+CorLin+'><small>Prazo:'+cvaltochar(TRB->Z97_PRAZO)+' dia(s)</small></th>'
		cRet += '<th '+CorLin+'></th>'
		cRet += '<th '+CorLin+'></th>'
		cRet += '<th '+CorLin+'></th>'
		cRet += '<th '+CorLin+'><small>Situacao: '+cFlag+'</small></th>'

		cRet += '</tbody></table> '
	 	cRet += '   <table style="text-align: left; width: 1020px;" border="0" cellpadding="2" cellspacing="2">			      '
	 	cRet += '     <thead> '
	 	cRet += '      <tr>  '                                                                  
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Produto</small></td> '
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Descricao</small></td> '
	 	cRet += '  		   <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Data</small></td> '
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Local</small></td> '
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Qtdade</small></td> '
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>TES</small></td> '
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>CFO</small></td> '
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Lote</small></td> '
		cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Dt.Lote</small></td> '
	 	cRet += '          <td  style="font-weight: bold; color: black; background-color: rgb(230,232,250); text-align: left;" ><small>Valor</small></td> '
	 	cRet += '      </tr>  '
	 	cRet += '      </thead>  '
	 	cRet += '     <tbody> '
    EndIf
 	cRetCompl += '      <tr>  '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->B1_COD+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->B1_DESC+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(STOD(DEV_->B6_EMISSAO))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->B6_LOCAL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(DEV_->D1_QUANT,PesqPict("SD1","D1_QUANT"))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_TES+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_CF+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DEV_->D1_LOTECTL+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+DTOC(STOD(DEV_->D1_DTVALID))+'</small></td> '
 	cRetCompl += '          <td  style="color: black; background-color: rgb(230,232,250); text-align: left;" ><small>'+Transform(DEV_->D1_TOTAL,PesqPict("SD1","D1_TOTAL"))+'</small></td> '
 	cRetCompl += '      </tr>  '

	nControle++
	nContro2++
	DEV_->(DBSKIP())                    

	If cSer_DOC <> DEV_->F1_SERIE+DEV_->F1_DOC
		nControle:=1
	 	cRet += cRetCompl
	 	cRet += '      </tbody>  '
	 	cRet += '      </table>  '
	 	cRetCompl:=""
	EndIf 
	//MSM - 13/05/2016 - Adicionado para corrigir erro de string over flow, Chamado: 033475
	fWrite(nArq, cRet+CRLF)
	cRet:=""
	
EndDo

//cRet += '<br>  '

Return (cRet)

/*
Funcao      : VaGTM002
Parametros  : 
Retorno     : 
Objetivos   : Fonte para validar caracteres especiais
Autor       : BIALEADVPL / FABRICA DE SOFTWARE
Data/Hora   : 
*/
*-------------------------------*
User Function VaGTM002(cConteudo)
*-------------------------------*
local lRet:=.T.
local aNValid:={",",".","'","!","@","#","$","%","¨","&","*","(",")","_","-","´","`","^","~","[","]","{","}",":","/","\","?","|","+","=","ª","º"}

for i:=1 to len(aNValid)
	If aNValid[i] $ cConteudo
		msginfo("Caracter invalido: '"+aNValid[i]+"'")
		lRet:=.F.
		exit
	EndIf
next

Return lRet

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar o arquivo(boleto html)
Autor       : Matheus Massarotto
Data/Hora   : 01/08/2012
*/
*----------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*----------------------------------------*
Local lRet		:= .F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet := WaitRunSrv( cCommand , lWait , cPath )
/* COMANDOS RAR
    a       Adicionar arquivos ao arquivo.
            Exemplo:
            criar ou atualizar o arquivo existente myarch, adicionado todos os
            arquivos no diretório atual
            rar a myarch
   -ep1    Excluir diretório base dos nomes. Não salvar o caminho fornecido na
            linha de comandos.
            Exemplo:
            todos os arquivos e diretórios do diretório tmp serão adicionados
            ao arquivo 'pasta', mas o caminho não incluirá 'tmp\'
            rar a -ep1 -r pasta 'tmp\*'
            Isto é equivalente aos comandos:
            cd tmp
            rar a -r pasta
            cd ..
    -o+     Substituir arquivos existentes.
    m[f]    Mover para o arquivo [apenas arquivos]. Ao mover arquivos e
            diretórios irá resultar numa eliminação dos arquivos e
            diretórios após uma operação de compressão bem sucedida.
            Os diretórios não serão removidos se o modificador 'f' for
            utilizado e/ou o comando adicional '-ed' for aplicado. */
Return(lRet)
