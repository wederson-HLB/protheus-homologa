#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : BHFAT001()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatório de vendas diário SNF.
Autor       : Renato Rezende
Data/Hora   : 01/04/2014
*/                          
*---------------------------*
 User Function BHFAT001(aEmp)
*---------------------------*
Local cHtml			:= ""
Local cQuery		:= ""
Local cVendedor		:= ""
Local cRegiao		:= ""
Local cTo			:= ""
Local cSubject 		:= "SNF do Brasil - Regiao : "
Local cDataEmi		:= ""		 

Private cPerg  		:="BHFAT001"

//Verifica se será utilizado por Schedule
If Select("SX3")<=0
	conout(aEmp[1]+" "+aEmp[2])
	
	RpcClearEnv()
	RpcSetType(3)
	//AOA - 23/11/2017 - Alterado para pegar a empresa informada no cadastro do job
	Prepare Environment Empresa aEmp[1] Filial aEmp[2]
	cDataEmi	:= "Convert(VarChar(10),GetDate()-1,112)"
ElseIf !(cEmpAnt) $ "BH"
     MsgInfo("Rotina não implementada para essa empresa!","HLB BRASIL")
     Return
Else
	//Criando Pergunte
	U_PUTSX1(cPerg,"01" ,"Data de envio: ? "				,"Data de envio: ?"  				,"Data de envio: ?"  				,"mv_ch1","D",08,0, 0,"G","","","","","mv_par01",""		,""		,""		,""	,""		,""		,""		,"","","","","","","","","",{"Data de envio"} 							,{},{})
	
	If !pergunte(cPerg,.T.)
		return()
	endif
	
	cDataEmi	:= DtoS(MV_PAR01)	
EndIf

// Se as tabelas temporarias estiverem abertas, fecha.
If Select('TMP')>0
	TRT->(DbCloseArea())
EndIf

//Início do Select
cQuery:= " Select A3_EMAIL AS EMAIL"
cQuery+= " 			,A3_REGIAO AS REGIAO"
cQuery+= " 			,A3_NOME AS VENDEDOR"
cQuery+= "			,F2_VEND1 As CODIGO"
cQuery+= " 				,SubString(D2_EMISSAO,7,2)+'/'+SubString(D2_EMISSAO,5,2)+'/'+SubString(D2_EMISSAO,1,4) As EMISSAO"
cQuery+= "				,D2_SERIE+D2_DOC As DOCUMENTO"              
cQuery+= "				,D2_CLIENTE+'/'+D2_LOJA As CLIENTE"    
cQuery+= "				,A1_NOME  As NOME" 
cQuery+= "				,A1_END+'-'+A1_MUN+'/'+A1_EST  As ENDERECO"
cQuery+= "				,D2_COD As PRODUTO"                       
cQuery+= "				,C6_DESCRI As DESCRICAO"                    
cQuery+= "				,Convert(Numeric(9,2),D2_QUANT) As QUANT"                      
cQuery+= "				,Convert(Numeric(18,2),D2_TOTAL+D2_VALIPI) As TOTAL"
cQuery+= "				From SF2BH0 SF2"
cQuery+= "					,SD2BH0 SD2"
cQuery+= "					,SA1BH0 SA1"
cQuery+= "					,SC6BH0 SC6"
cQuery+= "					,SF4YY0 SF4"
cQuery+= "					,SA3BH0 SA3"
cQuery+= "				Where SF2.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SD2.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SA1.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SC6.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SF4.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SA3.D_E_L_E_T_ <> '*'"
cQuery+= "				AND SA3.A3_EMAIL <> ''"
cQuery+= "				AND SF2.F2_VEND1 = SA3.A3_COD"
//cQuery+= "				AND SF2.F2_EMISSAO = Convert(VarChar(10),GetDate()-1,112)"
cQuery+= "				AND SF2.F2_EMISSAO = "+cDataEmi
cQuery+= "				AND SF2.F2_CLIENTE = SA1.A1_COD"
cQuery+= "				AND SF2.F2_LOJA = SA1.A1_LOJA"
cQuery+= "				AND SF2.F2_SERIE = SD2.D2_SERIE"
cQuery+= "				AND SF2.F2_DOC =  SD2.D2_DOC"
cQuery+= "				AND SD2.D2_TES = SF4.F4_CODIGO"
cQuery+= "				AND SF4.F4_DUPLIC = 'S'"
cQuery+= "				AND SD2.D2_PEDIDO = SC6.C6_NUM"
cQuery+= "				AND SD2.D2_ITEMPV = SC6.C6_ITEM"
cQuery+= "				Order By F2_VEND1,A3_EMAIL,A3_REGIAO,D2_EMISSAO,D2_SERIE,D2_DOC"

DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.)

cVendedor	:= ""
cHtml		:= ""
cRegiao		:= ""
cTo			:= ""

TMP->(DbGoTop())
While TMP->(!Eof())
	If cVendedor <> TMP->CODIGO
		If !EMPTY(cHtml)
			cHtml+='	</table>'
			If !EMPTY(cTo)
				ENVIA_EMAIL(cTo,cSubject+cRegiao+cVendedor,cHtml) //Chamando a Função para envio do email
			EndIf
		EndIf
		
		cHtml := ""
		cHtml+='<H1><font face="Verdana" color="#0000FF" size="2">Vendas realizadas dia '+DTOC(Date()-1)+CRLF+CRLF
		cHtml+='Vendedor : '+TMP->CODIGO+'/'+TMP->VENDEDOR+'</font></H1>'
		cHtml+='	<table border="1" style="font-family: Verdana; font-size: 8pt">'
		cHtml+='		<tr>'
		cHtml+='			<td><p align="center"><strong>Vendedor</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Data</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Documento</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Cliente</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Nome Cliente</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Endereço</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Produto</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Descrição</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Quantidade</strong></p></td>'
		cHtml+='			<td><p align="center"><strong>Total</strong></p></td>'
		cHtml+='		</tr>'
		cRegiao 	:= TMP->REGIAO+" - "
		cTo 		:= TMP->EMAIL
	  	cVendedor 	:= TMP->CODIGO
	EndIf
	cHtml+='		<tr>'
	cHtml+='			<td>'+Alltrim(TMP->CODIGO)+'</td>'
	cHtml+='			<td>'+TMP->EMISSAO+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->DOCUMENTO)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->CLIENTE)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->NOME)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->ENDERECO)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->PRODUTO)+'</td>'
	cHtml+='			<td>'+Alltrim(TMP->DESCRICAO)+'</td>'
	cHtml+='			<td>'+Alltrim(TRANSFORM(TMP->QUANT, "@R 99999999999.99"))+'</td>'
	cHtml+='			<td>'+Alltrim(TRANSFORM(TMP->TOTAL, "@R 99999999999.99"))+'</td>'
	cHtml+='		</tr>'

	TMP->(DbSkip())
EndDo

If !EMPTY(cHtml)//Garante que o ultimo vendedor recebe o email.
	cHtml+='	</table>'
	If !EMPTY(cTo)
		ENVIA_EMAIL(cTo,cSubject+cRegiao+cVendedor,cHtml) //Chamando a Função para envio do email
	EndIf  
EndIf
 
TMP->(DbSkip())


TMP->(DbCloseArea())

Return cHtml 

/*
Funcao      : ENVIA_EMAIL()
Parametros  : cSubject,cBody,cTo
Retorno     : .T.
Objetivos   : Função para envio do e-mail
Autor       : Matheus Massarotto
Data/Hora   : 28/02/2012
*/
*----------------------------------------------*
Static Function ENVIA_EMAIL(cTo,cSubject,cHtml)
*----------------------------------------------*
Local cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
Local cUser,lMens:=.T.,nOp:=0,oDlg
Local nHora		:= VAL(SUBSTR(TIME(),1,2))
Local cBody1	:= '<font face="Verdana" color="#0000FF" size="2">'+IIF(nHora<6,'Boa noite!',IIF(nHora<12,'Bom dia!',IIF(nHora<18,'Boa tarde!','Boa noite!')))+'</font>'
Local cCC		:= AllTrim(GetNewPar("MV_P_00110"," "))//AOA - 14/11/2017 - Inclusão de parametro MV//"cmarques@snfbrasil.com;dmoura@snfbrasil.com;matheus.massarotto@hlb.com.br;renato.rezende@hlb.com.br;" 

DEFAULT cHtml   := ""
cBody1+= '<br>'
cBody1+= cHtml
	
IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
   RETURN .F.
ENDIF   

IF EMPTY(cTo)
   ConOut("E-mail para envio, nao informado.")
   RETURN .F.
ENDIF   

cAttachment:= "" //Anexo

cFrom:= AllTrim(GetMv("MV_RELFROM"))
cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
lAutentica:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   ConOut("Falha na Conexão com Servidor de E-Mail")
ELSE                                     
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO("Falha na Autenticacao do Usuario")
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf 
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC;
      BCC "renato.rezende@hlb.com.br";
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo;
      BCC "renato.rezende@hlb.com.br";
      SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
   ENDIF   
   If !lOK 
      ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk 
   ConOut("E-mail enviado com sucesso.")
ENDIF   
                        
RETURN                  