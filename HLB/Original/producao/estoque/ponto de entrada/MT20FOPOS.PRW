#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : MT20FOPOS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada para WorkFlow de cadastro de Fornecedores.
Autor       : Jean Victor Rocha
Data/Hora   : 29/08/2013
Revisao     :
Obs.        :       
*/  
*----------------------*
User Function MT20FOPOS()
*----------------------*
                          
//Verifica se é inclusão ou se esta Habilitado para a empresa.
If ParamIxb[1] <> 3 .or. !GetMV("MV_P_00001",,.F.)
	Return .T.
EndIf

Private cServer:= "mail.hlb.com.br"
Private cEmail := "totvs@hlb.com.br"
Private cPass  := "Protheus@2010"

Private cDe      := padr('totvs@hlb.com.br',200)
Private cPara    := PADR(GetMV("MV_P_00002",,""),200)

Private cCc      := padr('',200)
Private cAssunto := padr(ALLTRIM(SM0->M0_NOME)+' - Cadastro de fornecedor numero '+ALLTRIM(M->A2_COD),200)
Private cMsg     := ""
     
Email()//monta e-mail

EnviaMail()//envia e-mail.
	 
Return .t.

*---------------------*
Static Function Email()
*---------------------*
Local cHora:= TIME()

cMsg += "<body style='background-color: #9370db'>"
cMsg += '	 <table height="361" width="844" bgColor="#fffaf0" border="0" bordercolor="#fffaf0" style="border-collapse: collapse" cellpadding="0" cellspacing="0"> '
If VAl(SUBSTR(cHora, 1, 2)) < 12
	cMsg += '		 <td colspan="5"> Bom Dia!'
ElseIf VAl(SUBSTR(cHora, 1, 2)) < 18
	cMsg += '		 <td colspan="5"> Boa Tarde!'
Else 
	cMsg += '		 <td colspan="5"> Boa Noite!'
EndIf
cMsg += '			<br></br>'
cMsg += '		 </td>'
cMsg += '		 <tr>'
cMsg += "			<td colspan='5'>Identificado o Cadastro de um novo Fornecedor. Favor verificar!"
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '			</td>'
cMsg += '		 </tr>'
cMsg += '		 <tr>'
cMsg += "			 <td colspan='5'>      </td>"
cMsg += '		 </tr>'
cMsg += '		 <tr>'
cMsg += '			 <td width="040" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Empresa\Cod.   </b></font></td>'
cMsg += '			 <td width="040" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Filial         </b></font></td>'
cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Ambiente       </b></font></td>'
cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Modulo		 </b></font></td>' 
cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Cod. Fornecedor</b></font></td>' 
cMsg += '			 <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Nome Reduz	 </b></font></td>' 
cMsg += '			 <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3"><b> Usuario Resp.	 </b></font></td>' 
cMsg += '		 </tr>'
	cMsg += '		 <tr>'  
	cMsg += '			 <td width="040" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+cEmpAnt+'</td>'
	cMsg += '			 <td width="040" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+cFilAnt+'</td>'
	cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+GetEnvServer()+'</td>'
	cMsg += '			 <td width="100" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+OAPP:CMODDESC+'</td>'
	cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+M->A2_COD+'</td>'
	cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+M->A2_NREDUZ+'</td>'
	cMsg += '			 <td width="080" height="41" bgcolor="#fffaf0" bordercolor="#fffaf0" align = "Left"><font face="times" color="black" size="3">'+OAPP:CUSERNAME+'</td>'
	cMsg += '		 </tr>' 
cMsg += '		<tr>'
cMsg += '			 <td colspan="5">'
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '				<em>'
cMsg += '					<strong>Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe TI da HLB BRASIL. </Strong>'
cMsg += '				</em>'
cMsg += '			 </td>'
cMsg += '		</tr>'
cMsg += '	 </Table>'
cMsg += ' <BR?>'
cMsg += CRLF 


Return .t.   

*--------------------------*
STATIC FUNCTION EnviaMail()
*--------------------------*
Local lResulConn := .T.
Local lResulSend := .T.
Local cError := ""  

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

If !lResulConn
   GET MAIL ERROR cError
   Conout("MT20FOPOS - Falha na conexão "+cError)
   Return(.F.)
Endif

SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg  RESULT lResulSend   

GET MAIL ERROR cError
If !lResulSend
	Conout("MT20FOPOS - Falha no Envio do e-mail " + cError)
Endif

DISCONNECT SMTP SERVER                         

Return .T.