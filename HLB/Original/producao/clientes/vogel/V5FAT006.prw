#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

/*
Funcao      : V5FAT006()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para seleção dos documentos a serem impressos ( Fatura e Boleto )
Autor       : Renato Rezende
Cliente		: Vogel
Data/Hora   : 10/08/2016
*/

*----------------------------*
 User Function V5FAT006()
*----------------------------*
Local cTitulo		:= 'Vogel - Impressao Fatura\Boleto'
Local cDescription	:= 'Esta rotina permite imprimir as faturas e boletos para as notas fiscais selecionadas, dentro do periodo informado .'

Local oProcess
Local bProcesso

Private aRotina 	:= MenuDef()
Private cPerg 	 	:= 'V5FAT006'

Private dDtIni 		:= CtoD( '' )
Private dDtFim 		:= CtoD( '' )
Private cTpSel		:= ""

If !(cEmpAnt $ u_EmpVogel())
	MsgStop( 'Empresa nao autorizada para utilizar essa rotina!', 'HLB BRASIL' )  
	Return
EndIf

//Ajusta os perguntes
AjusSx1()

bProcesso	:= { |oSelf| SelNf( oSelf ) }

oProcess 	:= tNewProcess():New( "V5FAT006" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)

Return

/*
Função  : SelNf
Objetivo: Selecionar notas fiscais para impressão
Autor   : Renato Rezende
Data    : 10/08/2016
*/
*----------------------------------------*
 Static Function SelNf( oProcess )
*----------------------------------------*
Local cExpAdvPL		:= ""
Local oColumn
Local bValid        := { || .T. }  //** Code-block para definir alguma validacao na marcação, se houver necessidade
Local bClick		:= { || .T. }
Local lPrimeiro		:= .T.

Private cMark		:= "001"
Private oMarkB

Pergunte( cPerg , .F. )

dDtIni 	:= MV_PAR01
dDtFim 	:= MV_PAR02
cTpSel 	:= MV_PAR03

//SetKey( VK_F12 , { || Pergunte( 'V5FAT206' , .T. ) } )

SF2->( DbSetOrder( 1 ) )

cExpAdvPL	:= 'SF2->F2_FILIAL=="'+xFilial("SF2")+'" .And. SF2->F2_EMISSAO >= dDtIni .And. SF2->F2_EMISSAO <= dDtFim '
//Fatura
If (cTpSel == 1)
	cExpAdvPL	+= '.And. SF2->F2_TIPO == "N" .And. Alltrim(SF2->F2_ESPECIE) == "FAT" .And. SF2->F2_P_REF <> ""'
//Telecom
ElseIf (cTpSel == 2)
	cExpAdvPL	+= '.And. SF2->F2_TIPO == "N" .And. Alltrim(SF2->F2_ESPECIE) $ "NFST/NTST" .And. SF2->F2_P_REF <> ""'
//Cominicacao
ElseIf (cTpSel == 3)
	cExpAdvPL	+= '.And. SF2->F2_TIPO == "N" .And. Alltrim(SF2->F2_ESPECIE) == "NFSC" .And. SF2->F2_P_REF <> ""'
EndIf
oMarkB := FWMarkBrowse():New()
oMarkB:SetOnlyFields({ "F2_COND" })//Definicao das colunas do browser
oMarkB:SetAlias('SF2')
//oMarkB:SetFieldMark('F2_OK')
oMarkB:SetValid(bValid)

bClickM:= { || SF2->(RecLock("SF2",.F.)), IIF(Empty(SF2->F2_OK),SF2->F2_OK:=cMark,SF2->F2_OK:='') , SF2->(MsUnlock())}
bClickA:= { || SF2->(DbEval({|| SF2->(RecLock("SF2",.F.)), IIF(Empty(SF2->F2_OK),SF2->F2_OK:=cMark,SF2->F2_OK:='') , SF2->(MsUnlock())})),oMarkB:Refresh(.T.)}

//Incluir legenda no Objeto
If SF2->(FieldPos("F2_P_ENV")) > 0
   	oMarkB:AddMarkColumns({ || If(Empty(SF2->F2_OK),'LBNO','LBOK')} ,  bClickM , bClickA)
	oMarkB:AddLegend("AllTrim(SF2->F2_P_ENV)<>'S'", "BR_VERDE","Não Enviado")
	oMarkB:AddLegend("AllTrim(SF2->F2_P_ENV)=='S'", "BR_VERMELHO","Enviado")
EndIf

// Definição das colunas do browse
ADD COLUMN oColumn DATA { || F2_DOC   														} TITLE "Nota Fiscal"	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_P_REF  														} TITLE "Sistech"		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_SERIE   													} TITLE "Serie"			SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_CLIENTE   													} TITLE "Cliente"		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_LOJA  														} TITLE "Loja"			SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_EMISSAO   													} TITLE "Emissao"		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALBRUT + F2_DESCONT , X3Picture( 'F2_VALBRUT' ) ) 	} TITLE "Valor Bruto"	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALICM , X3Picture( 'F2_VALICM' ) )   				} TITLE "Valor Icms"	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALISS , X3Picture( 'F2_VALISS' ) )  				} TITLE "Valor ISS"		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALIMP5 , X3Picture( 'F2_VALIMP5' ) )  				} TITLE "Valor Pis"		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALIMP6 , X3Picture( 'F2_VALIMP6' ) )   			} TITLE "Valor Cofins"	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALCSLL , X3Picture( 'F2_VALCSLL' ) )   			} TITLE "Valor CSLL"	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALIRRF , X3Picture( 'F2_VALIRRF' ) )   			} TITLE "Valor IRRF"	SIZE  3 OF oMarkB	

//Filtro ADVPL
oMarkB:SetFilterDefault( cExpAdvPL )

//Marcando ou desmarcando na abertura do browser
SF2->(DbGoTop())
While SF2->(!EOF())
	//Filtro do browser
	If &cExpAdvPL
		If AllTrim(SF2->F2_P_ENV)<>'S'
			SF2->(Reclock("SF2",.F.))
				SF2->F2_OK := '001'
			SF2->(MsUnlock())
		Else
			SF2->(Reclock("SF2",.F.))
				SF2->F2_OK := ''
			SF2->(MsUnlock())
		EndIf
	Else
		SF2->(Reclock("SF2",.F.))
			SF2->F2_OK := ''
		SF2->(MsUnlock())
	EndIf
	SF2->(DbSkip())
EndDo
oMarkB:ForceQuitButton( .T. ) 

oMarkB:Activate()

Return

/*
Função	: MenuDef
Objetivo: Ajusta as opções do menu
*/
*--------------------------------*
 Static Function MenuDef()
*--------------------------------*
Local aRotina 	:= {}

ADD OPTION aRotina TITLE 'Processar'	ACTION 'U_V5FATIMP(.F.)' 	OPERATION 10 ACCESS 0 
ADD OPTION aRotina TITLE 'Preview'		ACTION 'U_V5FATIMP(.T.)' 	OPERATION 11 ACCESS 0

Return aRotina

/*
Função	: V5FATIMP
Objetivo: Imprimir Fatura
*/
*---------------------------------------*
 User Function V5FatImp(lPreview)
*---------------------------------------*


Return ( MsgRun( 'Gerando e transmitindo documentos.... favor aguarde' , '' , { || Imprime( lPreview ) } ) )

/*
Função	: Imprime
Objetivo: Imprimir Fatura
*/
*-------------------------------------------*
 Static Function Imprime( lPreview )
*-------------------------------------------*
Local lmpBol                            
Local lImpNF       
Local cAnexo	:= ""
Local cSubject	:= ""
Local cMailTo 	:= ""

Pergunte('V5FAT206' , .F.)
lImpBol := ( MV_PAR01 == 2 .Or. MV_PAR01 == 1 )  
lImpNF 	:= ( MV_PAR01 == 3 .Or. MV_PAR01 == 1 ) 

SF2->(DbGotop())
While SF2->(!Eof())
	
	If ( Alltrim(SF2->F2_OK) == cMark )

		SD2->(DbSetOrder(3))
		SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SD2")+SD2->D2_PEDIDO))
				
		//Imprime Ambos ou Fatura
		cAnexo := ""
		If ( lImpNF )
			//Imprime Fatura ou Telecom
			If cTpSel == 1 //Fatura
				cAnexo := U_V5FAT009(.T., lPreview )
			ElseIF	cTpSel == 2 //Telecom
				cAnexo := U_V5FAT004(.T., lPreview )
			ElseIF	cTpSel == 3 //Comunicacao
				cAnexo := U_V5FAT010(.T., lPreview )				
			EndIf
			//Sleep( 2000 )
		EndIf
		
		//Imprime Ambos ou Boleto
		If !Empty( cAnexo )
			cAnexo += ";"
		EndIf

   		SA1->(DbSetOrder(1))
   		SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

		If ( lImpBol ) .AND. SC5->C5_P_BOL == 'S'
			//AOA - 05/06/2017 - Tratanemtno para verificar se imprime boleto Itau ou Santander
			If SA1->A1_P_TPBOL $ '1'
				cAnexo += U_V5FIN001(.T. , lPreview ) //Itau
			Else
				cAnexo += U_V5FIN004(.T. , lPreview ) //Santander
			EndIf
		EndIf
		
		If !Empty( cAnexo )
   				
			cSubject	:= 'Fatura\Boleto Vogel - Cli.:'+Alltrim(SA1->A1_NREDUZ)+' - ID.:'+Alltrim(SA1->A1_COD)+' - NF.: ' + Alltrim(SF2->F2_DOC) + ' - Sistech.:'+Alltrim(SF2->F2_P_REF)
			cMailTo		:= Alltrim(SA1->A1_EMAIL)

			cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cEmail += '</head><body>'
			cEmail += '<span style="font-weight: bold; text-align: left; font-style: italic; font-size: 11pt; font-family: calibri, sans-serif; color: #005A95;">'
			cEmail += 'Prezado cliente,'
			cEmail += '<br />'
			cEmail += '<br />'
			cEmail += 'Estamos lhe enviando o faturamento deste mês.'
			cEmail += '<br />'  
			//RPB - 23/01/2017 - Texto somente para empresa SouthTech (Fabíola).
			If  cEmpAnt $ "G4"
				cEmail += '<br />'
				cEmail += 'Devido a uma migração de sistema pela qual estamos passando, ainda não estamos conseguindo encaminhar o boleto para pagamento.'
				cEmail += 'Assim, pedimos desculpas pelo transtorno, e solicitamos que o pagamento seja efetuado através de depósito em conta.' 
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += 'Segue abaixo, os dados bancários da companhia:'
				cEmail += '<br />'
				cEmail += '<br />' 
				cEmail += 'Sul Americana Serviços de Telefonia Ltda.'
				cEmail += '<br />'
				cEmail += 'CNPJ: 15.171.237/0001-02'
				cEmail += '<br />'
				cEmail += 'Banco: Banrisul (041)'
				cEmail += '<br />'
				cEmail += 'Agência: 0100'
		   		cEmail += '<br />'
				cEmail += 'Conta: 063398290-2'
				cEmail += '<br />'
				cEmail += '<br />'
			EndIf
			cEmail += 'Caso encontre alguma divergência nos documentos enviados, pedimos que entre com contato conosco através do e-mail:'
			cEmail += '<br />'
			cEmail += '<a href="mailto:faturamento@vogeltelecom.com" style="text-decoration:none">faturamento@vogeltelecom.com.</a>'
			cEmail += '<br />'
			cEmail += '<br />'
            //RRP - 30/11/2016 - Retirada empresa Smart. Solicitado por email (Fabíola).
			If !cEmpAnt $ "FC/G4"
				cEmail += 'Para visualizar o detalhamento de sua fatura, acesse ao link abaixo:' 			
				cEmail += '<br />'
				cEmail += '<br />'
				cEmail += '<a href="https://at.vogeltelecom.com/atendimento/servicos/pedidos/itens?id_invoice='+ALLTRIM(SC5->C5_P_REF)+'" target="_blank">https://at.vogeltelecom.com/atendimento/servicos/pedidos/itens?id_invoice='+ALLTRIM(SC5->C5_P_REF)+'</a>
				cEmail += '<br />'
				cEmail += '<br />' 
			EndIf
			cEmail += 'Atenciosamente,' 
			cEmail += '<br />'
			cEmail += '<br />'
			cEmail += 'Faturamento - Vogel Telecom'
			cEmail += '<br />' 
			cEmail += '<br />'
			cEmail += '**Favor não responder este e-mail**</span>'
			cEmail += '<br />'
			cEmail += '<span style=" font-size: 8pt; font-family: calibri, sans-serif; color: #FFFFFF;">'+Alltrim(SM0->M0_CODIGO)+'-'+Alltrim(SM0->M0_FILIAL)+'-'+Alltrim(SM0->M0_NOMECOM)+'</span>'  
			cEmail += '</body></html>'
			
			If EnviaEma(cEmail,cSubject,cMailTo,cAnexo)			
		    
				//Fatura Enviada
				If SF2->(DbSeek(xFilial("SF2")+F2_DOC+F2_SERIE+F2_CLIENT+F2_LOJA))
					If SF2->(FieldPos("F2_P_ENV")) > 0
						SF2->(RecLock("SF2",.F.))
							SF2->F2_P_ENV	:= "S"
							SF2->F2_OK		:= ""
						SF2->(MsUnlock())
					EndIf
				EndIf			
		 	EndIf
		EndIf      
		
		SD2->(DbCloseArea())
		SC5->(DbCloseArea())	
	
	EndIf
	
	SF2->(DbSkip())
EndDo

Return

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Renato Rezende
Data    : 10/08/2016
*/
*------------------------------*
 Static Function AjusSx1()
*------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Emissao De ?"    },;
  					{"02","Emissao Ate ?"   },;
  					{"03","Tipo Documento ?"    }}
  					
//Verifica se o SX1 está correto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir.") 
	
	U_PUTSX1(cPerg,"01","Emissao De ?","Emissao De ?","Emissao De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja imprimir.")
	
	U_PUTSX1(cPerg,"02","Emissao Ate ?","Emissao Ate ?","Emissao Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Tipo da Nota Fiscal que")
	Aadd( aHlpPor, "se deseja imprimir.") 
	Aadd( aHlpPor, "Fatura ou Telecom.")
	
	U_PUTSX1(cPerg,"03","Tipo Documento ?","Tipo Documento ?","Tipo Documento ?","mv_ch3","N",1,0,0,"C","","","","S","mv_par03","Fatura","","","","Telecom","","","Comunicacao","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)

EndIf
//Segundo Pergunte
U_PUTSX1( 'V5FAT206' ,'01' , 'Imprimir' ,'Imprimir','Imprimir','mv_ch1','N' , 1 ,0 ,0,'C',,,,,'MV_PAR01',"Ambos",,,,"Boleto",,,'Fatura',,,,,,,,,{"Informe o que deverá ser impresso."},,,)

Return

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cAnexo
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 05/01/2015 10:20
*/

*--------------------------------------------------------------*
Static Function EnviaEma(cEmail,cSubject,cTo,cAnexos)
*--------------------------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""
Local cToOculto		:= ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	RETURN .F.
ENDIF

cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo 		:= AvLeGrupoEMail(cTo) 
cCC			:= ""
cToOculto	:= AllTrim(GetNewPar("MV_P_00082"," "))+";log.sistemas@hlb.com.br"
cFrom		:= AllTrim(GetMv("MV_RELFROM"))
cAttachment := cAnexos

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	RETURN .F.
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			RETURN .F.
		EndIf
	EndIf
	IF !EMPTY(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
	ELSE
		SEND MAIL FROM cFrom TO cTo BCC cToOculto;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
	ENDIF
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		DISCONNECT SMTP SERVER
		RETURN .F.
	ENDIF
ENDIF

DISCONNECT SMTP SERVER   

Return( .t. )
