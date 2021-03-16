#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPE01DANFE บAutor 		ณRenato Rezendeบ  	 Data ณ  03/10/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada do fonte DANFEII e DANFEIII, responsavel   บฑฑ
ฑฑบ          ณpela impressใo da Notas Fiscais Eletronicas.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HLB BRASIL      	                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         

/*
Funcao      : PE01DANFE
Parametros  : {oNfe}
Retorno     : lRet
Objetivos   : P.E. para Customiza็ใo do fonte padrใo DanfeII e DanfeIII
Autor       : Renato Rezende
Data/Hora   : 03/10/2014       	
Obs         : 
M๓dulo      : Faturamento.
Cliente     : Todos
*/

*--------------------------*
 User Function PE01DANFE()
*--------------------------*
Local lRet		:= .F.
Local aArea1	:= {}
Local aArea2	:= {}
Local aArea3    := {}
Local aArea4	:= {}

Private oNfe	:= ParamIXB[01] 
Private aNf		:= {}

//Victaulic
If cEmpAnt $ "TM"   //JSS - Alterado para solu็ใo do caso 031531  -AOA - 10/05/2016 - Removido o c๓digo WA para nใo carregar o ponto de entrada, chamado 033337
	If XmlChildEx(oNFe:_NFE:_INFNFE:_IDE,"_TPNF")<>Nil
		//Validando se Euma nota de Sa๚a 
		If oNFe:_NFE:_INFNFE:_IDE:_TPNF:TEXT == "1" 
			If MsgYesNo("Deseja enviar o WorkFlow para o Financeiro ?","HLB BRASIL")
   				aArea1 := SE4->(GetArea())     
   				aArea2 := SA2->(GetArea())   
   				aArea3 := SA1->(GetArea())

				//Montando informa็๕es da Nota
				AADD(aNf,Alltrim(SF2->F2_DOC))//Nota
				AADD(aNf,Alltrim(SF2->F2_SERIE))//Serie
				AADD(aNf,Alltrim(SF2->F2_CLIENTE))//Codigo Cliente
				If SF2->F2_TIPO $ "D/B"
					SA2->(DbSetOrder(1))
					If SA2->(DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
						AADD(aNf,Alltrim(SA2->A2_NOME))//Nome Fornecedor
					EndIf
					SA2->(DbCloseArea())
				Else
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
						AADD(aNf,Alltrim(SA1->A1_NOME))//Nome Cliente
					EndIf
					SA1->(DbCloseArea())
				EndIf
				AADD(aNf,SF2->F2_COND)//Condi็ใo de Pagamento
				SE4->(DbSetOrder(1))
				If SE4->(DbSeek(xFilial("SE4")+SF2->F2_COND))
					AADD(aNf,Alltrim(SE4->E4_DESCRI))//Descri็ใo da condi็ใo	
				EndIf			
				AADD(aNf,DtoC(SF2->F2_EMISSAO))//Emissใo
				AADD(aNf,Transform(SF2->F2_VALBRUT,"@E 999,999,999,999.99"))//Valor Total
   				
		    	RestArea(aArea1)
   				RestArea(aArea2)	
				RestArea(aArea3)
		    	SendMail()
		    	lRet:= .T.
		    EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
Funcao      : SendMail
Parametros  : oNfe
Retorno     : Nil
Objetivos   : Enviar Email de Notifica็ใo
Autor       : Renato Rezende
Data/Hora   : 03/10/2014
*/
*-----------------------------*
 Static Function SendMail()
*-----------------------------*
Local cEmail	:= GETMV("MV_P_00022",,"")  //E-mail que recebem notifica็ใo do WorkFlow Financeiro
Local cCc		:= GETMV("MV_P_00023",,"")  //E-mail que recebem notifica็ใo do WorkFlow Financeiro
Local cPath 	:= AllTrim(GetNewPar("MV_RELSERV"," "))
Local clogin	:= AllTrim(GetNewPar("MV_RELFROM"," "))
Local cPass  	:= AllTrim(GetNewPar("MV_RELPSW" ," "))
Local cMsg		:= Email()

If Empty(Alltrim(cEmail))
	Return .T.
EndIf

oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@hlb.com.br"
oEmail:cTo		:= PADR(cEmail,200)
oEmail:cCC		:= PADR(cCC,200) 
If cEmpAnt $ "TM"
	oEmail:cSubject	:= padr("VICTAULIC GERAวรO DE BOLETOS.",200)
ElseIf cEmpAnt $ "WA"//JSS - Alterado para solu็ใo do caso 031531
	oEmail:cSubject	:= padr("SIRRA GERAวรO DE BOLETOS.",200) //JSS
EndIf
oEmail:cBody   	:= cMsg
oEmail:Envia()

Return .T.

/*
Funcao      : Email()
Parametros  : Nenhum
Retorno     : cHtml
Objetivos   : Modelo-Email
Autor       : Renato Rezende
Cliente		: Victaulic
Data/Hora   : 03/10/2014
*/   
*------------------------*
 Static Function Email()
*------------------------*
Local cHtml 	:= ""

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
cHtml += '				<td width="631" height="25"> <font size="3" face="tahoma" color="#551A8B"><b>WorkFlow Financeiro</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+DTOC(Date())+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(Time())+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+ALLTRIM(cUserName)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"><font size="2" face="tahoma">
cHtml += '											Boa tarde a todos,<br />
cHtml += '											<br />Encaminho nota fiscal para gera็ใo do boleto.<br />
cHtml += '											<br />Nota: '+aNf[1]+' - S้rie: '+aNf[2]
cHtml += '											<br />Cliente/Fornecedor: '+aNf[3]+' - Razใo Social: '+aNf[4]
cHtml += '											<br />Condi็ใo de Pag.: '+aNf[5]+' - Descr. Cond.: '+aNf[6]
cHtml += '											<br />Dt. Emissใo: '+aNf[7]+' - Valor Total: '+aNf[8]+'<br />     
If cEmpAnt $ "TM"
	cHtml += '											<br />*Ap๓s emissใo favor encaminhar para "Hugo Sobrinho" - hugo.sobrinho@victaulic.com; nos mantendo em c๓pia.</font>
ElseIf cEmpAnt $ "WA"//JSS - Alterado para solu็ใo do caso 031531
	cHtml += '											<br />*Ap๓s emissใo favor encaminhar para "Leonardo Santi" - LSanti@sierrawireless.com; "Andrea Pereira" - apereira@sierrawireless.com;  nos mantendo em c๓pia.</font>
EndIf
cHtml += '				</td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center><font size="2" face="tahoma">Mensagem automatica, nao responder.</p></td></font>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml