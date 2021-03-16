#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
Funcao      : LGFAT010
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Processar os pedidoso da tabela ZX4. Integração IMS
Autor       : Renato Rezende
Cliente		: Exeltis
Data/Hora   : 26/08/2018
*/
*------------------------*
 User Function LGFAT010()
*------------------------*
Local cTo			:= ""
Local cToOculto		:= ""
Local cSubject		:= ""
Local cMsg			:= ""
Local lImporta		:= .F.

Private lJob		:= (Select("SX3") <= 0)
Private cDate		:= ""
Private cTime		:= ""
Private cUser		:= ""
Private cAnexos		:= ""
Private cRetProc	:= ""
Private nContOk		:= 0
Private aIntIMS		:= {}

If !lJob
	MsgInfo( "Rotina não pode ser executada via SmartClient!","HLB BRASIL" )
	Return
Else
	RpcClearEnv()
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "LG" FILIAL "01" TABLES "SA1" , "SC5" , "SC6" , "SB1" MODULO "FAT" 

	cDate 		:= DtoC(Date())
	cTime 		:= SubStr(Time(),1,5)
	cUser 		:= UsrFullName(RetCodUsr())
	cSubject	:= "[EXELTIS] Integração Pedidos IMS "+DtoC(Date())	
	cTo			:= AllTrim(GetMv("MV_P_00040",," "))
	cToOculto	:= AllTrim(GetMv("MV_P_00041",," "))

	//Verifica pasta no servidor para salvar os arquivos
	If ExistDir("\FTP")
		If !ExistDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt)
			MakeDir("\FTP\"+cEmpAnt+"\IMS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\IMS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
	   		MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		Elseif !ExistDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
			MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		EndIf
	Else
		MakeDir("\FTP")
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\IMS")
		MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS")
		MakeDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
	EndIf
	
	If !ExistDir("\FTP\"+cEmpAnt+"\IMS\PEDIDOS\bkp")
		conout("Fonte LGFAT008: Falha ao carregar diretório FTP no Servidor!")
	Else
		
		//Importar pedidos IMS gravados na ZX4
		IntPed() 
		
		If Len(aIntIMS)>0
			cMsg	:= HtmlPrc()
			//Envia e-mail após concluir o processo
			lEnvia	:= u_GTGEN045(cMsg,cSubject,"",cTo,cToOculto,cAnexos)
		EndIf
	EndIf
EndIf

Return nil

/*
Função  : IntPed
Objetivo: Integra pedido de venda.
Autor   : Renato Rezende
Data    : 23/10/2017
*/
*------------------------*
 Static Function IntPed()
*------------------------*
Local aCabec	:= {}
Local aLinha	:= {}
Local aItens	:= {}
Local aAllFilial:= FWAllFilial()
Local cFilAntBkp:= ""
Local cQuery	:= ""
Local cAliasZX4	:= "QRYZX4"
Local cPryKey	:= ""
Local cSeqNumC5	:= ""
Local cTipCli 	:= ""
Local cPedidoIMS:= ""
Local cDescPro 	:= ""
Local cLocPro 	:= ""
Local nRecCount	:= 0 
Local nValTot	:= 0
Local dZX4Dt	:= CtoD("//")
Local lGetSxe	:= .T.

SX3->(DbSetOrder(2))
If (SX3->(DbSeek("C5_NUM")))
	If "GETSXENUM" $ UPPER(Alltrim(SX3->X3_RELACAO))
		lGetSxe := .F.
	EndIf
EndIf

cQuery:= "SELECT * FROM "+RetSqlName('ZX4')+" WHERE D_E_L_E_T_ <> '*' AND ZX4_NUM = '' AND ZX4_STATUS = '' AND ZX4_INTEGR = 'N' ORDER BY ZX4_PRYKEY "

If Select(cAliasZX4)>0
	(cAliasZX4)->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQuery), cAliasZX4, .F., .F. )

Count to nRecCount

(cAliasZX4)->(DbGoTop())
        
If nRecCount >0
	While (cAliasZX4)->(!EOF())
		nPos		:= aScan(aAllFilial,{|x| AllTrim(x) == AllTrim((cAliasZX4)->ZX4_FILIAL)})
		cPryKey		:= (cAliasZX4)->ZX4_PRYKEY 
		dZX4Dt		:= (cAliasZX4)->ZX4_DATA
		cPedidoIMS	:= (cAliasZX4)->ZX4_P_REF
		aCabec		:= {}
		aItens		:= {}

		If nPos > 0
			cFilAntBkp	:= cFilAnt 
			cFilAnt		:= AllTrim((cAliasZX4)->ZX4_FILIAL) 
			If lGetSxe
				cSeqNumC5	:= GETSXENUM("SC5","C5_NUM") 
				aAdd( aCabec,{"C5_NUM"    	, cValToChar(cSeqNumC5)			,NIL})
			EndIf
			cTipCli 	:= Posicione("SA1", 1, FwxFilial("SA1") + (cAliasZX4)->ZX4_CLIENT+(cAliasZX4)->ZX4_LOJACL, "A1_TIPO")
			
			aAdd( aCabec,{"C5_TIPO"   	, (cAliasZX4)->ZX4_TIPO			,NIL})
			aAdd( aCabec,{"C5_TIPOCLI"  , cTipCli  			 			,NIL})
			aAdd( aCabec,{"C5_CLIENTE"	, (cAliasZX4)->ZX4_CLIENT		,NIL})
			aAdd( aCabec,{"C5_LOJACLI"	, (cAliasZX4)->ZX4_LOJACL		,NIL})
			aAdd( aCabec,{"C5_CONDPAG"	, (cAliasZX4)->ZX4_CONDPA		,NIL})
			aAdd( aCabec,{"C5_VEND1"	, (cAliasZX4)->ZX4_VEND1		,NIL})
			aAdd( aCabec,{"C5_EMISSAO"	, StoD((cAliasZX4)->ZX4_EMISSA)	,NIL})
			aAdd( aCabec,{"C5_FECENT"	, StoD((cAliasZX4)->ZX4_FECENT)	,NIL})
			aAdd( aCabec,{"C5_MENNOTA"	, (cAliasZX4)->ZX4_MENNOTA		,NIL})
			aAdd( aCabec,{"C5_P_REF"	, cPedidoIMS					,NIL})
			aAdd( aCabec,{"C5_TABELA"	, (cAliasZX4)->ZX4_TABELA		,NIL})
			aAdd( aCabec,{"C5_TPFRETE"	, "C"	 						,NIL})
			aAdd( aCabec,{"C5_ESPECI1"	, ""	 						,NIL})
			aAdd( aCabec,{"C5_P_ENV1"	, "0"  							,NIL})
					
		
			//Percorre todos os itens
			While !(cAliasZX4)->(EoF()) .And. (cAliasZX4)->ZX4_FILIAL = FWxFilial("ZX4") .And.;
				 (cAliasZX4)->ZX4_P_REF == cPedidoIMS .AND. (cAliasZX4)->ZX4_PRYKEY == cPryKey  
	
				cDescPro 	:= Posicione("SB1", 1, FwxFilial("SB1") + (cAliasZX4)->ZX4_PRODUT, "B1_DESC")
				nValTot		:= NOROUND((cAliasZX4)->ZX4_QTDVEN*(cAliasZX4)->ZX4_PRCVEN, 2) 
				cLocPro 	:= Posicione("SB1", 1, FwxFilial("SB1") + (cAliasZX4)->ZX4_PRODUT, "B1_LOCPAD")

				aLinha := {}				
				aAdd( aLinha,{"C6_ITEM"		, (cAliasZX4)->ZX4_ITEM			,NIL})
				aAdd( aLinha,{"C6_PRODUTO"	, (cAliasZX4)->ZX4_PRODUT		,NIL})
				aAdd( aLinha,{"C6_DESCRI"	, Alltrim(cDescPro)				,NIL})
				aAdd( aLinha,{"C6_QTDVEN"	, (cAliasZX4)->ZX4_QTDVEN		,NIL})
				aAdd( aLinha,{"C6_PRCVEN"	, (cAliasZX4)->ZX4_PRCVEN		,NIL})
				aAdd( aLinha,{"C6_VALOR"	, nValTot 						,NIL})
				aAdd( aLinha,{"C6_OPER"		, (cAliasZX4)->ZX4_OPER			,Nil})
				aAdd( aLinha,{"C6_LOCAL"	, cLocPro 						,NIL})
				aAdd( aLinha,{"C6_PEDCLI"	, (cAliasZX4)->ZX4_PEDCLI		,NIL})
				aAdd( aLinha,{"C6_XDESCO1"	, (cAliasZX4)->ZX4_XDESCO		,NIL})
				aAdd( aLinha,{"C6_VALDES1"	, (cAliasZX4)->ZX4_VALDES		,NIL})
		        aAdd( aItens,aLinha)
		        
				(cAliasZX4)->(DbSkip())
			EndDo

			//Execauto para incluir pedido de venda
			aIntIMS 	:= GravPed(aCabec,aItens,cPryKey,dZX4Dt)
			
			//Volta variavel cFilAnt
			cFilAnt := cFilAntBkp
		
		Else
			//Empresa nao encontrada no Sigamat
			//Atualizar campos da ZX4
			aIntIMS:={.F.,"Empresa nao encontrada no SIGAMAT."}
			cUpdate:= " UPDATE "+RetSqlName("ZX4")+" SET ZX4_STATUS = '1', ZX4_MSG = 'Empresa nao encontrada no SIGAMAT.', ZX4_INTEGR = 'N' "
			cUpdate+= "  WHERE ZX4_FILIAL = '"+(cAliasZX4)->ZX4_FILIAL+"' AND D_E_L_E_T_ <> '*' " 
			cUpdate+= "	   AND ZX4_PRYKEY = '"+cPryKey+"' AND ZX4_P_REF = '"+cPedidoIMS+"' AND ZX4_DATA = '"+dZX4Dt+"' " 
			TcSqlExec(cUpdate)
			
			(cAliasZX4)->(DbSkip())	
		EndIf
	   	//Trata retorno de integração para envio do email
		cRetProc	 += "Ped. Cliente "+cPedidoIMS+" - "+ aIntIMS[2]+"<br>-------------<br>" //mensagem
		nContOk := nContOk+1
	EndDo
EndIf

Return Nil

/*
Função  : GravPed
Objetivo: Grava pedido de venda na base via execauto
Autor   : Renato Rezende
Data    : 24/10/2017
*/
*-----------------------------------------------------*
 Static Function GravPed(aCabec,aItens,cChave, dZX4Dt)
*-----------------------------------------------------*
Local lErro	   			:= .F.
Local cStatus			:= ""
Local cPRef				:= ""
Local cPedNum			:= ""
Local cUpdate			:= ""
Local aValdNum			:= {}
Local nPos				:= 0

Private lMsErroAuto		:= .F.
Private lMSHelpAuto 	:= .F.
Private lAutoErrNoFile 	:= .T.

nPos:= aScan(aCabec,{|x| UPPER(ALLTRIM(x[1])) == "C5_P_REF" })
cPRef := Alltrim(aCabec[nPos][2])

/*
STATUS C5_P_ENV1
0 - Pedido não Enviado
1 - Erro Processo
2 - Pedido Bloqueado
3 - Enviado (Pendente retorno)
4 - Pedido Rejeitado
5 - Pedido Faturado
*/

aValdNum:= VlNumPed(cPRef)
    
If !aValdNum[1]
	MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCabec, aItens, 3)
    
	If lMsErroAuto
		ROLLBACKSXE()		  		
		cMsgProc	:= ""
		aAutoErro 	:= GETAUTOGRLOG()
		cMsgProc	:= XLOG(aAutoErro)
	    
		lErro:=.T.
		DisarmTransaction()
		cStatus		:= "1"
	Else
		Confirmsx8()
		cStatus		:= "0"
		cPedNum		:= Alltrim(SC5->C5_NUM)
		cMsgProc	:= "Pedido "+cPedNum+" gravado com sucesso."
	EndIF
Else
	lErro		:= .T.
	cStatus		:= "1"
	cMsgProc 	:= "Campo C5_P_REF Ja existe referencia cadastrada no pedido "+Alltrim(aValdNum[2])+"."
EndIf

//Atualizar campos da ZX4
cUpdate:= " UPDATE "+RetSqlName("ZX4")+" SET ZX4_STATUS = '"+cStatus+"', ZX4_MSG = '"+cMsgProc+"', ZX4_INTEGR = '"+IIF(lErro,"N","S")+"', ZX4_NUM = '"+cPedNum+"' "
cUpdate+= "  WHERE ZX4_FILIAL = '"+FwxFilial("ZX4")+"' AND D_E_L_E_T_ <> '*' AND ZX4_PRYKEY = '"+cChave+"' " 
cUpdate+= "	   AND ZX4_P_REF = '"+cPRef+"' AND ZX4_DATA = '"+dZX4Dt+"' "
TcSqlExec(cUpdate)

Return({lErro,cMsgProc})

/*
Funcao      : Xlog()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro, para todos
Autor       : Renato Rezende
Data/Hora   : 12/06/2018
*/
*-------------------------------*
 Static Function XLOG(aAutoErro)  
*-------------------------------*     
Local cRet := ""
Local nX := 1

For nX := 1 to Len(aAutoErro)
	If nX==1
		cRet+=alltrim(substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; ")
	Else
		If at("Invalido",aAutoErro[nX])>0
			cRet += Alltrim(aAutoErro[nX])+"; "
		EndIf
	EndIf
Next nX

Return cRet  

/*
Funcao      : VlNumPed 
Parametros  : cPRef
Retorno     : lErro
Objetivos   : Validar o campo C5_P_REF para não gravar duplicidade
Autor       : Renato Rezende
Data/Hora   : 12/06/2018
*/
*------------------------------*
 Static Function VlNumPed(cPRef)
*------------------------------*
Local lErro 	:= .F.

Local cQrC5Ref	:= ""

If !Empty(cPRef)
	cQrC5Ref:=" SELECT C5_NUM,C5_P_REF FROM "+RetSqlName("SC5")+CRLF
	cQrC5Ref+="  WHERE D_E_L_E_T_= '' AND C5_FILIAL='"+FwxFilial("SC5")+"' AND UPPER(C5_P_REF)=UPPER('"+alltrim(cPRef)+"')"
	
	If Select("QRYTEMP")>0
		QRYTEMP->(DbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrC5Ref), "QRYTEMP", .F., .F. )
	
	Count to nRecCount
	
	QRYTEMP->(DbGoTop())
	        
	If nRecCount >0
		lErro:=.T.
	EndIf
EndIf

Return ({lErro,QRYTEMP->C5_NUM}) 

/*
Funcao      : HtmlPrc
Retorno     : cHtml
Objetivos   : Criar corpo do email de arquivo enviado para processar
Autor       : Renato Rezende
Data/Hora   : 12/06/2018
*/
*----------------------------------------*
 Static Function HtmlPrc()
*----------------------------------------*
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
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>PROCESSAMENTO</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+IIF(Empty(ALLTRIM(cUser)),"JOB", Alltrim(cUser))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">LOG DO PROCESSAMENTO:</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">Quantidade de Pedidos Integrados: '+cValtoChar(nContOk)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">'+cRetProc+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml