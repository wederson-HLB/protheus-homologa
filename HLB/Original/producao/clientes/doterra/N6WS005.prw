#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6WS005   º Autor ³ William Souza      º Data ³  17/01/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ User function para trazer a confirmação do picking         º±±
±±º          ³ físico na FEDEX                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ doTerra Brasil                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------*
User Function N6WS005(aParam)
*---------------------------*
Local aHeadStr 	   := {}
Local aData    	   := {}
Local aRetorno     := {} 
Local aSku         := {}
Local cUrl         := ""
Local aUser        := ""
Local aArea        := ""
Local cSql         := ""
Local cXml    	   := "" 
Local oXml	       := ""
Local cHeadRet     := ""
Local sPostRet     := "" 
Local cError       := ""
Local cWarning     := ""
Local cRetorno     := ""
Local cMsg         := "" 
Local cContent     := ""
Local lJob	       := Type( 'oMainWnd' ) != 'O'
Local i            := nil
Local y			   := nil
Local nVolume	   := nil
Local nPesoBruto   := nil
Local nPesoLiquido := nil 
Local nTimeOut 	   := nil
Local lValida      := .F.
Local lValidaItem  := .F.
Local lErro		   := .F. 
Local cEmail	   := ""

//rotina para deixar a função para ser chamada via menu.
If lJob 
	If ( Valtype( aParam ) != 'A' )
		cEmp := 'N6'
		cFil := '01'
	Else            
		cEmp := aParam[ 01 ]
		cFil := aParam[ 02 ]	
	EndIf
	RPCSetType(3)	
	RpcSetEnv( cEmp , cFil , "" , "" , 'FAT' )
EndIf 

//Preparação de variáveis
cUrl         := alltrim(getMV("MV_P_00116"))
aUser        := &(getMV("MV_P_00117")) 
aArea        := GetArea()
nVolume	     := 0
i            := 0 
y			 := 0
nPesoBruto   := 0
nPesoLiquido := 0
nTimeOut 	 := 120

//Query para trazer as notas que precisam de confirmação do saldo físico
//cSQL := "SELECT * FROM " + RetSqlName("SC5") +" WHERE D_E_L_E_T_ = '' AND C5_P_STFED IN ('02','06') AND C5_FILIAL ='02' AND C5_NOTA='' ORDER BY C5_P_DTFED"    
cSQL := "SELECT TOP 20 SC5.*
cSQL += " FROM "+RetSqlName("SC5")+" SC5
cSQL += " LEFT JOIN (SELECT ZX2_CHAVE, MAX(R_E_C_N_O_) AS R_E_C_N_O_
cSQL += "            FROM "+RetSqlName("ZX2")+" WITH (INDEX(ZX2N601))
cSQL += " 		   WHERE ZX2_FILIAL='02'
cSQL += " 					AND ZX2_ALIAS='SC5'
cSQL += " 					AND ZX2_SERWS='ConfirmCaixaSeparacaoWMS1'
cSQL += " 					AND ZX2_TIPO='R'
cSQL += "            GROUP BY ZX2_CHAVE
cSQL += " 		   ) AS ZX2 ON SC5.C5_P_DTRAX = ZX2.ZX2_CHAVE
cSQL += " WHERE SC5.D_E_L_E_T_ = '' 
cSQL += " 	AND SC5.C5_P_STFED IN ('02','06') 
cSQL += " 	AND SC5.C5_FILIAL ='02' 
cSQL += " 	AND SC5.C5_NOTA='' 
cSQL += " ORDER BY ZX2.R_E_C_N_O_,SC5.C5_P_DTFED,SC5.R_E_C_N_O_

If Select("SQL") > 0 
	SQL->(DbCloseArea())
EndIf 

cSQL := ChangeQuery(cSQL)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), "SQL", .F., .T.) 

ProcRegua(RecCount())

SQL->(dbGoTop())
While SQL->(!Eof())
   	cMsg 	:= ""
	lErro	:= .F.  	

	//header do xml
	aHeadStr := {}
	aadd(aHeadStr,'Content-Type: text/xml;charset=UTF-8')
	aadd(aHeadStr,"SOAPAction: sii:CONFIRMACAO_SEPARACAO_WMS10")     
	aadd(aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')') 

	//preparação do xml de consulta
	cXml:="<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:gen='http://www.rapidaocometa.com.br/GenPdvPickConfWMS10In' xmlns:mesa='http://www.sterlingcommerce.com/mesa'>"
	cXml+="<soapenv:Header/>"
	cXml+="<soapenv:Body>"
	cXml+="<Entrada>"
	cXml+="<CLIENTE_ID>DOTERRA</CLIENTE_ID>"
	cXml+="<DEPOSITO_ID>WMWHSE8</DEPOSITO_ID>"
	cXml+="<NUMERO_ORDEM_EXTERNA_ID>"+ALLTRIM(SQL->C5_P_CHAVE)+"</NUMERO_ORDEM_EXTERNA_ID>" 
	cXml+="</Entrada>"
	cXml+="<mesa:mesaAuth>"
	cXml+="<mesa:principal>"+aUser[1]+"</mesa:principal>"
	cXml+="<mesa:auth hashType='?'>"+aUser[2]+"</mesa:auth>"
	cXml+="</mesa:mesaAuth>"
	cXml+="</soapenv:Body>"
	cXml+="</soapenv:Envelope>"            

    //Grava log Transacao 
	u_N6GEN002("SC5","E","ConfirmCaixaSeparacaoWMS10In","Totvs","FedEX",ALLTRIM(SQL->C5_P_CHAVE),cXml,"")
	
	//envio NFE para a FEDEX
	sPostRet := HttpPost(cUrl,'',cXML,nTimeOut,aHeadStr,@cHeadRet)

	Sleep( 1000 )

	If ( Valtype( sPostRet ) = 'U' )
		conout(sPostRet)
		SQL->(dbSkip())
		Loop		
	EndIf
	If AT("DOCTYPE HTML PUBLIC",sPostRet) == 0 
		If AT("<faultcode>",sPostRet) == 0
		    If !empty(sPostRet)
				If AT("<GenPdvPickConfOut:Retorno>",sPostRet) == 0
  				 	If AT("HEADER_ConfSepOut",sPostRet) == 0
						oXml     := XmlParser( sPostRet, "_", @cError, @cWarning ) 
						cRetorno := oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_SAIDA:_HEADER 
						If Valtype(cRetorno) == "A"
							For y := 1 to len(cRetorno)
								nPesoBruto   += val(StrTran(cRetorno[y]:_PESO_BRUTO:TEXT,",","."))									
								nPesoLiquido += val(StrTran(cRetorno[y]:_PESO_LIQUIDO:TEXT,",","."))
							Next y
							nVolume := len(cRetorno)		
						Else                
							nPesoBruto   := val(StrTran(cRetorno:_PESO_BRUTO:TEXT,",","."))							
							nPesoLiquido := val(StrTran(cRetorno:_PESO_LIQUIDO:TEXT,",","."))
							nVolume 	 := 1
						EndIF 							
						TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='03',C5_PESOL='"+cValtochar(nPesoLiquido)+"',C5_PBRUTO='"+cValtochar(nPesoBruto)+"',C5_VOLUME1='"+cValtoChar(nVolume)+"',C5_ESPECI1='CAIXA' WHERE C5_P_CHAVE='"+ALLTRIM(SQL->C5_P_CHAVE)+"'") 
		        		cMsg := "SUCESSO"
		        		
						//Gravação de rastreio
						cQry := " UPDATE "+RetSqlName("ZX6")
						cQry += " SET ZX6_DTREPK='"+DTOS(Date())+"',ZX6_HRREPK='"+TIME()+"'
						cQry += " WHERE ZX6_FILIAL = '"+xFilial("SC5")+"'
						cQry += "		AND ZX6_DTRAX = '"+SQL->C5_P_CHAVE+"'
						cQry += "		AND ZX6_DTREPK=''
						TCSQLEXEC(cQry)
						InsertZX7(SQL->C5_FILIAL,SQL->C5_P_CHAVE,SQL->C5_NUM,"Picking liberado pelo operador logistico.","Confirmação de Picking")
			        EndIf
			    Else
			 		cMsg := "Vazio"
			 		//Atualizar o Status do pedido em casos que consultas anteriores retornaram com erro.
			 		TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='02' WHERE C5_P_CHAVE='"+ALLTRIM(SQL->C5_P_CHAVE)+"' AND C5_P_STFED='06'")
			    EndIf   
			Else 	
			   cMsg := "Retorno em branco do webservice. Log gravado e entrar em contato com o time de desenvolvimento."
			   TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='06' WHERE C5_P_CHAVE='"+ALLTRIM(SQL->C5_P_CHAVE)+"'") 
			   lErro := .T.
			EndIf
		Else
			If AT("ja em execucao",sPostRet) == 0 
				cMsg := "Erro na estrutura do XML para envio ao webservice da FedEX. Log gravado e entrar em contato o time de desenvolvimento para correção."	    
				TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='06' WHERE C5_P_CHAVE='"+ALLTRIM(SQL->C5_P_CHAVE)+"'")
				lErro := .T.
			Else
				//Processo ja em execucao, refaz a tentativa 
   				u_N6GEN002("SC5","R","ConfirmCaixaSeparacaoWMS10In","FedEX","Totvs",ALLTRIM(SQL->C5_P_CHAVE),sPostRet,"Processo ja em execucao")
				Loop		
			EndIf				
		EndIF
    Else
	    cMsg := "Erro de conexão com o servidor de webservice, log de erro gravado e favor entrar em contato com a FedEx."
		//TCSqlExec("UPDATE "+RetSqlName("SC5")+"  SET C5_P_STFED='06' WHERE C5_P_CHAVE='"+ALLTRIM(SQL->C5_P_CHAVE)+"'") //Como não houve consulta, não atualiza o Pedido.
		lErro := .T.
	EndIf

	//Grava log Transacao 
   	u_N6GEN002("SC5","R","ConfirmCaixaSeparacaoWMS10In","FedEX","Totvs",ALLTRIM(SQL->C5_P_CHAVE),sPostRet,cMsg)
	/*If lErro     //Caso houver algum erro, o Job irá disparar um email informando a falha
		//Corpo do email
		cEmail:="<font size='3' face='Tahoma, Geneva, sans-serif'>"
		cEmail+="<p><b>Pedido de Venda Protheus:</b> "+SQL->C5_NUM+"<br /><b>Pedido de venda(DataTrax):</b> "+SQL->C5_P_DTRAX+" <br> <b>Hora:</b> "+Time()+"<br /><b>Data:</b> "+dtoc(ddatabase)+"</p>"
		cEmail+="<p>Falha na comunicação do TOTVS com FedEx na confirmação de picklist</p></font>"
		cEmail+="<table width='100%' border='0' cellspacing='1' cellpadding='1' align='center'><tr>"
		cEmail+="<td width='231' align='center' bgcolor='#666666'><font size='3' face='Tahoma, Geneva, sans-serif' color='#BABB00'>Mensagem de Erro</font></td></tr>"
		cEmail+="<tr><td  bgcolor='#EFEFEF'><font size='2' face='Tahoma, Geneva, sans-serif'>"+cMsg+"</font></td></tr>" 
		cEmail+="</table><br><br><br>"	
	  	//u_N6GEN001(cEmail,"Erro confirmação picklist FedEx - ("+SQL->C5_P_DTRAX+"/"+SQL->C5_NUM+")",,alltrim(GETMV("MV_P_00120")))
	EndIf*/

   	SQL->(dbSkip())
Enddo

If Select("SQL") > 0 
	SQL->(DbCloseArea())
EndIf 

RestArea(aArea)	
Return .T.

/*
Funcao      : InsertZX7
Parametros  : 
Retorno     : 
Objetivos   : Gravação do Log de movimentação
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*-------------------------------------------------------*
Static Function InsertZX7(cFil,cDtrax,cNum,cOcorr,cEtapa)
*-------------------------------------------------------*
Local cInsert := ""

If EMPTY(cFil) .or. EMPTY(cDtrax) .or. EMPTY(cNum)
	Return .F.
EndIf

cInsert := " INSERT INTO "+RETSQLNAME("ZX7") 
cInsert += " VALUES('"+LEFT(cFil	,TamSX3("ZX7_FILIAL")[1])+"',
cInsert += " 		'"+LEFT(cDtrax	,TamSX3("ZX7_DTRAX")[1])+"',
cInsert += " 		'"+LEFT(cNum	,TamSX3("ZX7_NUM")[1])+"',
cInsert += " 		(SELECT ISNULL(MAX(ZX7_SEQ),0)+1 FROM "+RETSQLNAME("ZX7")+" WHERE ZX7_DTRAX = '"+LEFT(cDtrax,TamSX3("ZX7_DTRAX")[1])+"'),
cInsert += " 		'"+DTOS(date())+"',
cInsert += " 		'"+LEFT(Time()	,8)+"',
cInsert += " 		'"+LEFT(cOcorr	,TamSX3("ZX7_OCORR")[1])+"',
cInsert += " 		'"+LEFT(cEtapa	,TamSX3("ZX7_ETAPA")[1])+"',
cInsert += " 		'',
cInsert += " 		(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM "+RETSQLNAME("ZX7")+"))
TCSQLEXEC(cInsert)

Return .T.