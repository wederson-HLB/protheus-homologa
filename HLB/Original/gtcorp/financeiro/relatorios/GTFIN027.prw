#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "FWPrintSetup.ch" 
#INCLUDE "RPTDEF.CH"
#Include "tbiconn.ch"

#DEFINE DS_MODALFRAME   128

/*
Funcao      : GTFIN027()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Boleto Bancario do Banco Santander(Sofisa) com Codigo de Barras, Linha Digitavel e Nosso Numero.
Autor     	: Anderson Arrais
Data     	: 28/11/2016 
TDN         :  
Módulo      : Financeiro.
Empresa		: GTCORP
*/

*------------------------------------------------*
USER FUNCTION GTFIN027(lSelAuto,lPreview,lAutom)   
*------------------------------------------------*

LOCAL aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},{"E1_PREFIXO","Prefixo","@!"},{"E1_NUM","Titulo","@!"},;
						{"E1_PARCELA","Parcela","@!"},{"E1_VALOR","Valor","@E 9,999,999.99"},{"E1_VENCREA","Vencimento"}}
LOCAL	aPergs 		:= {}
LOCAL lExec         := .T.
LOCAL nOpc         	:= 0
LOCAL aDesc        	:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
Local cFileRet		:= ""
PRIVATE Exec       	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''
Private cBanco      := ''
Private cAgencia    := ''
Private cConta      := ''
Private cSubConta   := '' 
Default lPreview    :=.T.
DEFAULT lSelAuto	:=.F.
Default lAutom		:= .F.


Tamanho  := "M"
titulo   := "Impressao de Boleto Santander"
cDesc1   := "Este programa destina-se a impressao do Boleto Santander."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
dbSelectArea("SE1")

If !cEmpAnt $ "Z4/ZB/ZG/ZP/ZF" .AND. cFilAnt $ "01"
	MsgStop("Empresa não autorizada a usar essa rotina.")
 	Return .F.	
EndIf

if !lSelAuto

	cPerg     :="GTFIN027"
	
	Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	AjustaSx1("GTFIN027",aPergs)
	
	
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF

EndIf

If Select('SQL') > 0
	SQL->(DbCloseArea())
EndIf
BeginSql Alias 'SQL'
	
	SELECT E1_OK,E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_PEDIDO,E1_NUMSOL,R_E_C_N_O_  as 'RECNUM' 
	FROM %table:SE1%
	WHERE %notDel%
	  AND E1_FILIAL = %xfilial:SE1%
	  AND E1_SALDO > 0
	  AND E1_PREFIXO = %exp:MV_PAR01%
	  AND E1_NUM     >= %exp:MV_PAR02% AND E1_NUM <= %exp:MV_PAR03%
	  AND E1_TIPO = 'NF'
	ORDER BY E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO
EndSql

SQL->(dbGoTop())

If SQL->(EOF()) .or. SQL->(BOF())
	lExec := .F.
EndIf


If lExec
	Processa({|lEnd| cFileRet := MontaRel(lSelAuto,lPreview,lAutom)})
else
	SE1->(DbSetOrder(1))
	SE1->(DbGotop())
	ProcRegua(SE1->(RecCount()))
	SE1->(DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.))
	
	If ( SE1->E1_SALDO == 0 )
		Aviso("Aviso", 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao será gerado.',{"Abandona"},2 ) 
	Else	
		Aviso("Aviso","Não existe informações.",{"Abandona"},2)	
    EndIf
Endif

Return( cFileRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MONTAREL()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION MontaRel(lSelAuto,lPreview,lAutom)
LOCAL oPrint
LOCAL n			:= 0
LOCAL nI     	:= 0
LOCAL aBitmap   := {	"",;			                                                            // Banner Publicitario
						"LGRL.bmp"}		                                                            // Logo da Empresa

LOCAL aDadosEmp := {	SM0->M0_NOMECOM,;									   						//[1]Nome da Empresa
						SM0->M0_ENDCOB,; 															//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;//[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			//[4]CEP
						"PABX/FAX: "+SM0->M0_TEL,; 													//[5]Telefones
						"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;			//[6]
						Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;						//[6]
						Subs(SM0->M0_CGC,13,2),;													//[6]CGC
						"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;			//[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}							//[7]I.E
LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText  := {}
LOCAL aBMP      := aBitMap
LOCAL i         := 1
LOCAL CB_RN_NN  := {}
LOCAL nRec      := 0
LOCAL _nVlrAbat := 0
Local cLocal      := GetTempPath()
Local cFileName,cEmail,cSubject
Local cFile 	:= ""
Local cDirBol 	:= "\FTP\" + cEmpAnt + "\GTFIN027\" 
Local cNroDoc	:= ""
Local cParMV    := ""
Local cParMV1   := ""
Local cBancPort := ""
Local cCamBol	:= ""

Private cPortGrv	:= ""
Private cAgeGrv		:= ""
Private cContaGrv	:= ""
Private cCodEmp		:= ""
Private cQry		:= ""
Private aCols		:={}
Private aAuxAcols	:={}
Private nTipoBol    := 0

SE1->(DbSetOrder(1))
SE1->(DbGotop())
ProcRegua(SE1->(RecCount()))
SE1->(DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.))

If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\GTFIN027\" )		
EndIf	

if !lSelAuto
	cFileName := "Boleto_"+SE1->E1_PREFIXO+ALLTRIM(SE1->E1_NUM)+ALLTRIM(SE1->E1_PARCELA)    	
	If !lPreview
		oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.F.,0)
	Else 
		oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*F.*/,,.T.,.F.,,,,,,.T.,0)
	EndIf
	oPrint:Setup()
	oPrint:SetPortrait()			// ou SetLandscape()
	oPrint:SetPaperSize(9)			// Seta para papel A4
	//oPrint:StartPage()			// Inicia uma nova pagina
EndIf


//AOA - 22/12/2016 - Alterações feitas no fonte para ser enviado junto com a NSF na rotina de envio de email.
SE1->(DbSetOrder(1))
SA1->(DbSetOrder(1))
Z18->(DbSetOrder(1))
SA6->(dbSetOrder(1))

SQL->(dbGoTop())
ProcRegua(SQL->(RecCount()))
WHILE SQL->(!EOF())
	SE1->(DbGoTo(SQL->RECNUM))

	If SA1->(FieldPos("A1_P_TPBOL") > 0)
		If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
			nTipoBol := Val(SA1->A1_P_TPBOL)
		EndIf
	Endif

	If lSelAuto
		If nTipoBol <> MV_PAR05 
			SQL->(DBSKIP())
			LOOP
		Endif
	Endif
	
	If !SE1->E1_TIPO $ "NF /DP "
		SQL->(dbSkip())
		Loop
	Endif 

	If !Empty(SE1->E1_PORTADO) .AND. SE1->E1_PORTADO <> "033" // GFP 03/02/2017 - Sistema ignora qualquer titulo com boleto ja gerado que seja diferente de Santander
		SQL->(dbSkip())
		Loop
	Endif

	If ( SE1->E1_SALDO == 0 )
		MsgStop( 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao será gerado.' ) 
		SQL->(dbSkip())
		Loop
	Endif

	If lSelAuto
		cFileName := "Boleto_"+SE1->E1_PREFIXO+ALLTRIM(SE1->E1_NUM)+ALLTRIM(SE1->E1_PARCELA)
		If !lPreview
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.F.,0)
		Else 
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.T.,0)
		EndIf
	    
	   	oPrint:SetResolution(72)
		oPrint:SetPortrait()			// ou SetLandscape()
		oPrint:nDevice := IMP_PDF
		oPrint:cPathPDF := cLocal 		
		oPrint:SetPaperSize(DMPAPER_A4)// Seta para papel A4
		//oPrint:SetMargin(60,60,60,60) 		
	endif

	If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
		//Dados bancarios para Z4 e ZB, é usado as mesmas informações.
		/*
		cBanco    := "033"
		cAgencia  := "3689"
		cConta    := "4845013"
		cSubConta := "001"
		cCodEmp   := cConta
		*/

		If	Z18->(DbSeek(xFilial("Z18")+AvKey(SM0->M0_CODIGO,"Z18_EMP")+AvKey(SM0->M0_CODFIL,"Z18_FILEMP")+AvKey("033","Z18_BANCO"))) .OR.;
			Z18->(DbSeek(xFilial("Z18")+AvKey(SM0->M0_CODIGO,"Z18_EMP")+AvKey("","Z18_FILEMP")+AvKey("033","Z18_BANCO")))
			Do While Z18->(!Eof()) .AND. Z18->Z18_FILIAL == xFilial("Z18") .AND.;
		 									Z18->Z18_EMP == AvKey(SM0->M0_CODIGO,"Z18_EMP") .AND.;
		   									IIF(!Empty(Z18->Z18_FILEMP),Z18->Z18_FILEMP == AvKey(SM0->M0_CODFIL,"Z18_FILEMP"),.T.) .AND.;
		   									Z18->Z18_BANCO == AvKey("033","Z18_BANCO")
		 		
		 		If Z18->Z18_DTINI <= SE1->E1_EMISSAO
	   				If Empty(Z18->Z18_DTFIM) .OR. Z18->Z18_DTFIM >= SE1->E1_EMISSAO
	   					cBanco    := AvKey(AllTrim(Z18->Z18_BANCO),"EE_CODIGO")		//Banco 033
	   					cAgencia  := AvKey(AllTrim(Z18->Z18_AGENC),"EE_AGENCIA")	//Agencia
	   					cConta    := AvKey(AllTrim(Z18->Z18_CONTA),"EE_CONTA") 		//Conta + digito
	   					cSubConta := "001"
	   					cCodEmp   := cConta
	   					Exit
	   				EndIf
	   			EndIf
	  			Z18->(DbSkip())
	   		EndDo
	   Else
	   		MsgStop("Conta Corrente não cadastrada para esta empresa. Entre em contato com o suporte.","Grant Thornton" ) 
			Return .F.
		EndIf
	Endif
	
	cQry:=" SELECT EE_SUBCTA FROM "+RETSQLNAME("SEE")
	cQry+=" WHERE EE_FILIAL='"+xFilial("SEE")+"' AND D_E_L_E_T_=''"
	cQry+=" AND EE_CODIGO='"+cBanco+"'"
	cQry+=" AND EE_AGENCIA='"+cAgencia+"'"
	cQry+=" AND EE_CONTA='"+cConta+"'"
	cQry+=" AND (EE_OPER LIKE '%REM%' OR EE_EXTEN = 'REM')"
	
	if select("QUERYTRB")>0
		QUERYTRB->(DbCloseArea())
	endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QUERYTRB",.T.,.T.)

	COUNT TO nRecCount
	
	if nRecCount>0
		QUERYTRB->(DbGotop())
		cSubConta := QUERYTRB->EE_SUBCTA
	else
		SE1->(dbSkip())
		Loop
	endif
	
	// Posiciona o SA6 (Bancos)
	SA6->(dbSeek(xFilial("SA6")+cBanco+(cAgencia+Space(TamSX3("A6_AGENCIA")[1]-Len(cAgencia)))+(cConta+Space(TamSX3("A6_NUMCON")[1]-Len(cConta))),.T.))
	aDadosBanco := {SA6->A6_COD ,;												// [1]Numero do Banco
					"SANTANDER",;	    									    // [2]Nome do Banco
					SUBSTR(SA6->A6_AGENCIA,1,4),;								// [3]Agencia
					SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
					SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	    // [5]Digito da conta corrente
					"101"}			     										// [6]Codigo da Carteira
					
	SA1->(dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.))
	IF EMPTY(SA1->A1_ENDCOB)
		aDatSacado := {	AllTrim(SA1->A1_NOME),;								  // [1]Razao Social
						AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;				  // [2]Codigo
						AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;	  // [3]Endereco
						AllTrim(SA1->A1_MUN),;								  // [4]Cidade
						SA1->A1_EST,;										  // [5]Estado
						SA1->A1_CEP,;										  // [6]CEP
						SA1->A1_CGC}										  // [7]CGC
	ELSE
		aDatSacado := {	AllTrim(SA1->A1_NOME),;								  // [1]Razao Social
						AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;			  // [2]Codigo
						AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;// [3]Endereco
						AllTrim(SA1->A1_MUNC),;								  // [4]Cidade
						SA1->A1_ESTC,;										  // [5]Estado
						SA1->A1_CEPC,;										  // [6]CEP
						SA1->A1_CGC}										  // [7]CGC
	ENDIF
	
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	_nRecSE1  := SE1->(Recno())

	IF EMPTY(SE1->E1_NUMBCO)
		SEE->(dbSetOrder(1))
		If SEE->(dbSeek(xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+aDadosBanco[4]+aDadosBanco[5]+Space(TamSX3("A6_NUMCON")[1]-Len(aDadosBanco[4]+aDadosBanco[5]))+cSubConta))
			If EMPTY(SEE->EE_FAXATU)
				conout("EE_FAXATU EM BRANCO "+retSqlName("SEE")+":"+SEE->(Recno()) )
				conout("EE_FAXATU :"+xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+aDadosBanco[4]+aDadosBanco[5]+Space(TamSX3("A6_NUMCON")[1]-Len(aDadosBanco[4]+aDadosBanco[5]))+cSubConta)
			EndIf

			SEE->(RecLock("SEE",.F.))
			cNroDoc			:= VAL(SEE->EE_FAXATU)+1
			//SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU),12)
			SEE->EE_FAXATU	:= STRZERO(cNroDoc,12)
			SEE->(MsUnLock())
		EndIf
		
		SE1->(DbSelectArea("SE1"))
		SE1->(RecLock("SE1",.f.))
		SE1->E1_NUMBCO 	:= SUBSTR(cValToChar(cNroDoc),3,10)
		SE1->E1_PORTADO := SA6->A6_COD
		SE1->E1_AGEDEP  := SA6->A6_AGENCIA
		SE1->E1_CONTA   := SA6->A6_NUMCON
		SE1->(MsUnlock())
	ElseIf SE1->E1_PORTADO <> SA6->A6_COD .OR. SE1->E1_CONTA <> SA6->A6_NUMCON//Verifica se o banco já gravado no titulo é o mesmo do boleto atual
		If SE1->E1_PORTADO $ "341"
			cBancPort := "Itau"
		Else
			cBancPort := "outra conta"
		EndIf 
		MsgStop("Nosso número gerado para "+cBancPort+".","Grant Thornton" ) 
		Return .F.
	Else	
		cNroDoc 	:= "10"+ALLTRIM(SE1->E1_NUMBCO)
	EndIf

	SE1->(dbGoTo(_nRecSE1))
	
	nSaldo := (SE1->E1_SALDO - _nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC)
	CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,nSaldo,SE1->E1_VENCREA,aDadosBanco[6])
	
	aDadosTit := {	AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),;	 // [1] Numero do Titulo
					SE1->E1_EMISSAO,;					  		     // [2] Data da Emissao do Titulo
					Date(),;							   			 // [3] Data da Emissao do Boleto
					SE1->E1_VENCREA,;						  		 // [4] Data do Vencimento
					nSaldo,;							  			 // [5] Valor do Titulo
					CB_RN_NN[3],;	                       			 // [6] Nosso Numero (Ver Formula para Calculo)
					SE1->E1_PREFIXO,;					      		 // [7] Prefixo da NF
					SE1->E1_TIPO}						   		 	 // [8] Tipo do Titulo
					
	//IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM)
	aBolText  := U_GTFIN029(nSaldo)
	
	Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
	n := n + 1
	
	if lSelAuto
		If File( cLocal+cFileName+".pdf" )
			FErase(cLocal+cFileName+".pdf")
		EndIf
		
		If !ExistDir(cDirBol)
			MakeDir(cDirBol)
		EndIf
		If lPreview
			oPrint:Preview()
		Else
			oPrint:Print()
		EndIf
	   	
		If !CpyT2S( cLocal+cFileName+".pdf" , cDirBol ,.T. )
  			MsgStop( 'Erro na copia para o servidor, boleto ' + cFileName+  ".pdf" )
   	   	EndIf
   		
		Ms_Flush ()	
		if MV_PAR04==1
	   		oOk		:= LoadBitmap( GetResources(), "LBOK")
	   		AADD(aCols,{oOk,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_VALOR,SE1->E1_CLIENTE,AllTrim(SA1->A1_NOME),Alltrim(SA1->A1_P_EMAIC),cDirBol + cFileName+".pdf","",.F.})
			AADD(aAuxAcols,{Alltrim(SA1->A1_P_EMAIL),SE1->E1_EMISSAO})
	    endif
	EndIf	
	SQL->(dbSkip())
	IncProc()
	
	//AOA - 27/10/2017 - Ajuste para envio de mais de um boleto anexo quando tem parcela - Ticket 16886
	If EMPTY(cCamBol)
		cCamBol := cDirBol+cFileName+".pdf"	
	Else
		cCamBol += ";"+cDirBol+cFileName+".pdf"	
	EndIf
ENDDO

if lSelAuto
	If !lAutom .AND. MV_PAR04==1
		U_GTCORP32(aCols,aAuxAcols)
	ElseIf lAutom
		//U_GTFAT016(.T.,cDirBol+cFileName+".pdf")
		U_GTFAT016(.T.,cCamBol)
	EndIf
else
	Ms_Flush()
endif

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ IMPRESS()   ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont14n
LOCAL oFont24
LOCAL i        := 0
LOCAL _nLin    := 0//200
LOCAL aCoords1 := {0150,1900,0550,2300}
LOCAL aCoords2 := {0450,1050,0550,1900}
LOCAL aCoords3 := {_nLin+0710,1900,_nLin+0810,2300}
LOCAL aCoords4 := {_nLin+0980,1900,_nLin+1050,2300}
LOCAL aCoords5 := {_nLin+1330,1900,_nLin+1400,2300}
LOCAL aCoords6 := {_nLin+2000,1900,_nLin+2100,2300}
LOCAL aCoords7 := {_nLin+2270,1900,_nLin+2340,2300}
LOCAL aCoords8 := {_nLin+2620,1900,_nLin+2690,2300}
LOCAL oBrush
Local nSalto   := 18
Local nValor   := nSaldo
//Local cSantLogo:="Santander10.bmp"
Local cSantLogo:="santban10.bmp"
Local cNomeBenef := Upper(AllTrim(SM0->M0_NOMECOM))
Local cCNPJBenef := Transform(AllTrim(SM0->M0_CGC),AvSx3("A1_CGC",6))

SET DATE FORMAT "dd/mm/yyyy"

// Parâmetros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont8  := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
//oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)
oPrint:StartPage()	// Inicia uma nova Pagina
// "Pinta" os Campos com Cinza.
//oPrint:FillRect(aCoords1,oBrush)
//oPrint:FillRect(aCoords2,oBrush)
//oPrint:FillRect(aCoords3,oBrush)
//oPrint:FillRect(aCoords4,oBrush)
//oPrint:FillRect(aCoords5,oBrush)
//oPrint:FillRect(aCoords6,oBrush)
//oPrint:FillRect(aCoords7,oBrush)
//oPrint:FillRect(aCoords8,oBrush)

// Inicia aqui a alteracao para novo layout - RAI
oPrint:Line(0150,0560,0050,0560)
oPrint:Line(0150,0800,0050,0800)
//oPrint:Say (0084,0100,aDadosBanco[2],oFont16)					// [2] Nome do Banco
oPrint:SayBitmap(0050,0100,cSantLogo,430,90 )

oPrint:Say (nSalto+0082,0567,aDadosBanco[1]+"-7",oFont24)					// [1] Numero do Banco
oPrint:Say (nSalto+0084,1870,"Comprovante de Entrega",oFont10)
oPrint:Line(0150,0100,0150,2300)
oPrint:Say (nSalto+0150,0100,"Beneficiário",oFont8)
//oPrint:Say (nSalto+0200,0100,aDadosEmp[1]	,oFont10)					// [1] Nome + CNPJ
oPrint:Say (nSalto+0180,0100,cNomeBenef + " - " + cCNPJBenef + " / ",oFont8)
oPrint:Say (nSalto+0210,0100,"BANCO SOFISA S.A.",oFont8)
oPrint:Say (nSalto+0150,1060,"Agência/Código Cedente",oFont8)
oPrint:Say (nSalto+0200,1060,aDadosBanco[3]+"/"+cCodEmp,oFont10)
oPrint:Say (nSalto+0150,1510,"Nro.Documento",oFont8)
oPrint:Say (nSalto+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10)	// [7] Prefixo + [1] Numero + Parcela
oPrint:Say (nSalto+0250,0100,"Pagador",oFont8)
oPrint:Say (nSalto+0300,0100,aDatSacado[1],oFont10)					// [1] Nome
oPrint:Say (nSalto+0250,1060,"Vencimento",oFont8)
oPrint:Say (nSalto+0300,1060,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+0250,1510,"Valor do Documento",oFont8)
oPrint:Say (nSalto+0300,1550,AllTrim(Transform(nValor,"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
oPrint:Say (nSalto+0450,0100,"com as características acima.",oFont10)
oPrint:Say (nSalto+0350,1060,"Data",oFont8)
oPrint:Say (nSalto+0350,1410,"Assinatura",oFont8)
oPrint:Say (nSalto+0450,1060,"Data",oFont8)
oPrint:Say (nSalto+0450,1410,"Entregador",oFont8)
oPrint:Line(0250,0100,0250,1900)
oPrint:Line(0350,0100,0350,1900)
oPrint:Line(0450,1050,0450,1900) //---
oPrint:Line(0550,0100,0550,2300)
oPrint:Line(0550,1050,0150,1050)
oPrint:Line(0550,1400,0350,1400)
oPrint:Line(0350,1500,0150,1500) //--
oPrint:Line(0550,1900,0150,1900)
oPrint:Say (nSalto+0150,1910,"(  )Mudou-se",oFont8)
oPrint:Say (nSalto+0190,1910,"(  )Ausente",oFont8)
oPrint:Say (nSalto+0230,1910,"(  )Não existe nº indicado",oFont8)
oPrint:Say (nSalto+0270,1910,"(  )Recusado",oFont8)
oPrint:Say (nSalto+0310,1910,"(  )Não procurado",oFont8)
oPrint:Say (nSalto+0350,1910,"(  )Endereço insuficiente",oFont8)
oPrint:Say (nSalto+0390,1910,"(  )Desconhecido",oFont8)
oPrint:Say (nSalto+0430,1910,"(  )Falecido",oFont8)
oPrint:Say (nSalto+0470,1910,"(  )Outros(anotar no verso)",oFont8)
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+0600,i,_nLin+0600,i+30)
NEXT i    

oPrint:Line(_nLin+0710,0100,_nLin+0710,2300)
oPrint:Line(_nLin+0710,0560,_nLin+0610,0560)
oPrint:Line(_nLin+0710,0800,_nLin+0610,0800)
//oPrint:Say (nSalto+nSalto+_nLin+0644,0100,aDadosBanco[2],oFont16)	// [2]Nome do Banco
oPrint:SayBitmap(_nLin+0610,0100,cSantLogo,430,90 )
oPrint:Say (nSalto+_nLin+0652,0567,aDadosBanco[1]+"-7",oFont24)	// [1]Numero do Banco
oPrint:Say (nSalto+_nLin+0654,1900,"Recibo do Pagador",oFont10)
oPrint:Line(_nLin+0810,0100,_nLin+0810,2300)
oPrint:Line(_nLin+0910,0100,_nLin+0910,2300)
oPrint:Line(_nLin+0980,0100,_nLin+0980,2300)
oPrint:Line(_nLin+1050,0100,_nLin+1050,2300)
oPrint:Line(_nLin+0910,0500,_nLin+1050,0500)
oPrint:Line(_nLin+0980,0750,_nLin+1050,0750)
oPrint:Line(_nLin+0910,1000,_nLin+1050,1000)
oPrint:Line(_nLin+0910,1350,_nLin+0980,1350)
oPrint:Line(_nLin+0910,1550,_nLin+1050,1550)
oPrint:Say (nSalto+_nLin+0710,0100,"Local de Pagamento",oFont8)
//oPrint:Say (nSalto+_nLin+0750,0100,"QUALQUER BANCO ATÉ A DATA DO VENCIMENTO",oFont10)
oPrint:Say (nSalto+_nLin+0750,0100,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO SANTANDER",oFont8)
oPrint:Say (nSalto+_nLin+0775,0100,"APOS O VENCIMENTO PAGUE SOMENTE NO SANTANDER",oFont8)
oPrint:Say (nSalto+_nLin+0710,1910,"Vencimento",oFont8)
oPrint:Say (nSalto+_nLin+0750,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+_nLin+0810,0100,"Beneficiário",oFont8)
oPrint:Say (nSalto+_nLin+0845,0100,cNomeBenef + " - " + cCNPJBenef + " / BANCO SOFISA S.A.",oFont14n) //Nome + CNPJ
//oPrint:Say (nSalto+_nLin+0835,0100,aDadosdEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
//oPrint:Say (nSalto+_nLin+0870,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (nSalto+_nLin+0810,1910,"Agência/Código Cedente",oFont8)
oPrint:Say (nSalto+_nLin+0850,1950,aDadosBanco[3]+"/"+cCodEmp,oFont10)
oPrint:Say (nSalto+_nLin+0910,0100,"Data do Documento",oFont8)
oPrint:Say (nSalto+_nLin+0940,0100,DTOC(aDadosTit[2]),oFont10) // Emissao do Titulo (E1_EMISSAO)
oPrint:Say (nSalto+_nLin+0910,0505,"Nro.Documento",oFont8)
oPrint:Say (nSalto+_nLin+0940,0605,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela
oPrint:Say (nSalto+_nLin+0910,1005,"Espécie Doc.",oFont8)
oPrint:Say (nSalto+_nLin+0940,1050,aDadosTit[8],oFont10) //Tipo do Titulo
oPrint:Say (nSalto+_nLin+0910,1355,"Aceite",oFont8)
oPrint:Say (nSalto+_nLin+0940,1455,"N",oFont10)
oPrint:Say (nSalto+_nLin+0910,1555,"Data do Processamento",oFont8)
oPrint:Say (nSalto+_nLin+0940,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (nSalto+_nLin+0910,1910,"Nosso Número",oFont8)
//oPrint:Say (nSalto+_nLin+0940,1950,SUBSTR(aDadosTit[6],1,3)+"/"+SUBSTR(aDadosTit[6],4),oFont10)
oPrint:Say (nSalto+_nLin+0940,1950,aDadosTit[6],oFont10)
oPrint:Say (nSalto+_nLin+0980,0100,"Uso do Banco",oFont8)
oPrint:Say (nSalto+_nLin+0980,0505,"Carteira",oFont8)
oPrint:Say (nSalto+_nLin+1010,0555,aDadosBanco[6],oFont10)
oPrint:Say (nSalto+_nLin+0980,0755,"Espécie",oFont8)
oPrint:Say (nSalto+_nLin+1010,0805,"R$",oFont10)
oPrint:Say (nSalto+_nLin+0980,1005,"Quantidade",oFont8)
oPrint:Say (nSalto+_nLin+0980,1555,"Valor",oFont8)
oPrint:Say (nSalto+_nLin+0980,1910,"Valor do Documento",oFont8)
oPrint:Say (nSalto+_nLin+1010,1950,AllTrim(Transform(nValor,"@E 999,999,999.99")),oFont10)//JSS Alterado para solução do caso 031197
oPrint:Say (nSalto+_nLin+1050,0100,"Instruções (Instruções de responsabilidade do beneficiário. Qualquer dúvida sobre este boleto, contate o beneficiário)",oFont8)
	_nLin3:=1110
For i=1 To Len(aBolText)
	oPrint:Say (nSalto+_nLin+_nLin3,0100,aBolText[i],oFont10)
	_nLin3:= _nLin3+50 	
Next
//oPrint:Say (nSalto+_nLin+1250,0100,aBolText[3],oFont10)
oPrint:Say (nSalto+_nLin+1050,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+1080,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10) //JSS - ADICONADO PARA SOLUCIONAR O CHAMADO 017963  
oPrint:Say (nSalto+_nLin+1120,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (nSalto+_nLin+1190,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (nSalto+_nLin+1260,1910,"(+)Outros Acréscimos",oFont8)
//oPrint:Say (nSalto+_nLin+1290,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10) //JSS - ADICONADO PARA SOLUCIONAR O CHAMADO 017963 
oPrint:Say (nSalto+_nLin+1330,1910,"(=)Valor Cobrado",oFont8)    
//oPrint:Say (nSalto+_nLin+1360,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10) //JSS Alterado para solução do caso 031197
oPrint:Say (nSalto+_nLin+1400,0100,"Pagador",oFont8)
oPrint:Say (nSalto+_nLin+1430,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (nSalto+_nLin+1483,0400,aDatSacado[3],oFont10)
oPrint:Say (nSalto+_nLin+1536,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
oPrint:Say (nSalto+_nLin+1589,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
//oPrint:Say (nSalto+_nLin+1589,1950,SUBSTR(aDadosTit[6],1,3)+"/00"+SUBSTR(aDadosTit[6],4,8),oFont10)
oPrint:Say (nSalto+_nLin+1589,1950,aDadosTit[6],oFont10)
oPrint:Say (nSalto+_nLin+1650,0100,"Sacador/Avalista",oFont8)
oPrint:Say (nSalto+_nLin+1650,0400,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (nSalto+_nLin+1675,1500,"Autenticação Mecânica -",oFont8)
oPrint:Say (nSalto+_nLin+1675,1850,"Ficha de Compensação",oFont8)
oPrint:Line(_nLin+0710,1900,_nLin+1400,1900)
oPrint:Line(_nLin+1120,1900,_nLin+1120,2300)
oPrint:Line(_nLin+1190,1900,_nLin+1190,2300)
oPrint:Line(_nLin+1260,1900,_nLin+1260,2300)
oPrint:Line(_nLin+1330,1900,_nLin+1330,2300)
oPrint:Line(_nLin+1400,0100,_nLin+1400,2300)
oPrint:Line(_nLin+1670,0100,_nLin+1670,2300)

_nLin := _nLin - 110
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+1890,i,_nLin+1890,i+30)
NEXT i
// Encerra aqui a alteracao para o novo layout - RAI
oPrint:Line(_nLin+2000,0100,_nLin+2000,2300)
oPrint:Line(_nLin+2000,0560,_nLin+1900,0560)
oPrint:Line(_nLin+2000,0800,_nLin+1900,0800)
//oPrint:Say (nSalto+_nLin+1934,0100,aDadosBanco[2],oFont16)	// [2] Nome do Banco
oPrint:SayBitmap(_nLin+1900,0100,cSantLogo,430,90 )
oPrint:Say (nSalto+_nLin+1937,0567,aDadosBanco[1]+"-7",oFont24)	// [1] Numero do Banco
oPrint:Say (nSalto+_nLin+1934,0820,CB_RN_NN[2],oFont16n)		// [2] Linha Digitavel do Codigo de Barras
oPrint:Line(_nLin+2100,0100,_nLin+2100,2300)
oPrint:Line(_nLin+2200,0100,_nLin+2200,2300)
oPrint:Line(_nLin+2270,0100,_nLin+2270,2300)
oPrint:Line(_nLin+2340,0100,_nLin+2340,2300)
oPrint:Line(_nLin+2200,0500,_nLin+2340,0500)
oPrint:Line(_nLin+2270,0750,_nLin+2340,0750)
oPrint:Line(_nLin+2200,1000,_nLin+2340,1000)
oPrint:Line(_nLin+2200,1350,_nLin+2270,1350)
oPrint:Line(_nLin+2200,1550,_nLin+2340,1550)
oPrint:Say (nSalto+_nLin+2000,0100,"Local de Pagamento",oFont8)
oPrint:Say (nSalto+_nLin+2040,0100,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO SANTANDER",oFont8)
oPrint:Say (nSalto+_nLin+2065,0100,"APOS O VENCIMENTO PAGUE SOMENTE NO SANTANDER",oFont8)
//oPrint:Say (nSalto+_nLin+2040,0100,"QUALQUER BANCO ATÉ A DATA DO VENCIMENTO",oFont10)
oPrint:Say (nSalto+_nLin+2000,1910,"Vencimento",oFont8)
oPrint:Say (nSalto+_nLin+2040,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+_nLin+2100,0100,"Beneficiário",oFont8)
oPrint:Say (nSalto+_nLin+2135,0100,cNomeBenef + " - " + cCNPJBenef + " / BANCO SOFISA S.A.",oFont14n) //Nome + CNPJ
//oPrint:Say (nSalto+_nLin+2125,0100,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
//oPrint:Say (nSalto+_nLin+2160,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (nSalto+_nLin+2100,1910,"Agência/Código Cedente",oFont8)
oPrint:Say (nSalto+_nLin+2140,1950,aDadosBanco[3]+"/"+cCodEmp,oFont10)
oPrint:Say (nSalto+_nLin+2200,0100,"Data do Documento",oFont8)
oPrint:Say (nSalto+_nLin+2230,0100,DTOC(aDadosTit[2]),oFont10)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (nSalto+_nLin+2200,0505,"Nro.Documento",oFont8)
oPrint:Say (nSalto+_nLin+2230,0605,aDadosTit[7]+aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
oPrint:Say (nSalto+_nLin+2200,1005,"Espécie Doc.",oFont8)
oPrint:Say (nSalto+_nLin+2230,1050,aDadosTit[8],oFont10)					//Tipo do Titulo
oPrint:Say (nSalto+_nLin+2200,1355,"Aceite",oFont8)
oPrint:Say (nSalto+_nLin+2230,1455,"N",oFont10)
oPrint:Say (nSalto+_nLin+2200,1555,"Data do Processamento",oFont8)
oPrint:Say (nSalto+_nLin+2230,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (nSalto+_nLin+2200,1910,"Nosso Número",oFont8)
//oPrint:Say (nSalto+_nLin+2230,1950,SUBSTR(aDadosTit[6],1,3)+"/"+SUBSTR(aDadosTit[6],4),oFont10)
oPrint:Say (nSalto+_nLin+2230,1950,aDadosTit[6],oFont10)
oPrint:Say (nSalto+_nLin+2270,0100,"Uso do Banco",oFont8)
oPrint:Say (nSalto+_nLin+2270,0505,"Carteira",oFont8)
oPrint:Say (nSalto+_nLin+2300,0555,aDadosBanco[6],oFont10)
oPrint:Say (nSalto+_nLin+2270,0755,"Espécie",oFont8)
oPrint:Say (nSalto+_nLin+2300,0805,"R$",oFont10)
oPrint:Say (nSalto+_nLin+2270,1005,"Quantidade",oFont8)
oPrint:Say (nSalto+_nLin+2270,1555,"Valor",oFont8)
oPrint:Say (nSalto+_nLin+2270,1910,"Valor do Documento",oFont8)
oPrint:Say (nSalto+_nLin+2300,1950,AllTrim(Transform(nValor,"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2340,0100,"Instruções (Instruções de responsabilidade do beneficiário. Qualquer dúvida sobre este boleto, contate o beneficiário)",oFont8)
	_nLin3:=2400
For i=1 To Len(aBolText)
	oPrint:Say (nSalto+_nLin+_nLin3,0100,aBolText[i],oFont10)
	_nLin3:= _nLin3+50 
Next
//oPrint:Say (nSalto+_nLin+2440,0100,AllTrim (aDadosTit[12]),oFont8)//JSS Alterado para solução do caso 031197
//oPrint:Say (nSalto+_nLin+2440,0100,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")),oFont10)
//oPrint:Say (nSalto+_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10)
//oPrint:Say (nSalto+_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10)
//oPrint:Say (nSalto+_nLin+2540,0100,aBolText[3],oFont10)
oPrint:Say (nSalto+_nLin+2340,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+2370,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10) //JSS - ADICONADO PARA SOLUCIONAR O CHAMADO 017963 
oPrint:Say (nSalto+_nLin+2410,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (nSalto+_nLin+2480,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (nSalto+_nLin+2550,1910,"(+)Outros Acréscimos",oFont8)
//oPrint:Say (nSalto+_nLin+2580,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10) //JSS Alterado para solução do caso 031197963
oPrint:Say (nSalto+_nLin+2620,1910,"(=)Valor Cobrado",oFont8)
//oPrint:Say (nSalto+_nLin+2650,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)//JSS Alterado para solução do caso 031197
oPrint:Say (nSalto+_nLin+2690,0100,"Pagador",oFont8)
oPrint:Say (nSalto+_nLin+2710,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (nSalto+_nLin+2763,0400,aDatSacado[3],oFont10)
oPrint:Say (nSalto+_nLin+2816,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
oPrint:Say (nSalto+_nLin+2864,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)	// CGC
//oPrint:Say (nSalto+_nLin+2879,1950,SUBSTR(aDadosTit[6],1,3)+"/00"+SUBSTR(aDadosTit[6],4,8),oFont10)
oPrint:Say (nSalto+_nLin+2874,1950,aDadosTit[6],oFont10)
oPrint:Say (nSalto+_nLin+2905,0100,"Sacador/Avalista",oFont8)
oPrint:Say (nSalto+_nLin+2905,0400,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (nSalto+_nLin+2940,1500,"Autenticação Mecânica -",oFont8)
oPrint:Say (nSalto+_nLin+2940,1850,"Ficha de Compensação",oFont8)
oPrint:Line(_nLin+2000,1900,_nLin+2690,1900)
oPrint:Line(_nLin+2410,1900,_nLin+2410,2300)
oPrint:Line(_nLin+2480,1900,_nLin+2480,2300)
oPrint:Line(_nLin+2550,1900,_nLin+2550,2300)
oPrint:Line(_nLin+2620,1900,_nLin+2620,2300)
oPrint:Line(_nLin+2690,0100,_nLin+2690,2300)
oPrint:Line(_nLin+2935,0100,_nLin+2935,2300)

//MSBAR("INT25"  ,27.8,1.5,CB_RN_NN[1],oPrint,.F.,,,,1.4,,,,.F.)   
cFont:="Helvetica 65 Medium"
oPrint:FWMSBAR("INT25" /*cTypeBar*/,64.5/*nRow*/ ,2/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.95/*0.8*//*nHeigth*/,.F./*lBanner*/, cFont/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

oPrint:EndPage()	// Finaliza a Pagina
RETURN Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO10()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
WHILE L > 0
	P := VAL(SUBSTR(cData, L, 1))
	IF (B)
		P := P * 2
		IF P > 9
			P := P - 9
		ENDIF
	ENDIF
	D := D + P
	L := L - 1
	B := !B
ENDDO
D := 10 - (Mod(D,10))
IF D = 10
	D := 0
ENDIF
RETURN(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO11()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Santander com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo11(cData,lCodBarra)
LOCAL L, D, P := 0
Default lCodBarra := .F.

L := LEN(cData)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P == 9
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

//Tratamento para digito verificador.
If lCodBarra //Codigo de Barras
	//Se o resto for 0,1 ou 10 o digito é 1
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		D := 1
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
Else //Nosso Numero
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		//Se o resto for 0 ou 1 o digito é 0
		IF (D == 0 .Or. D == 1)
			D := 0

		//Se o resto for 10 o digito é 1
		ELSEIF (D == 10)
			D := 1
		ENDIF
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
EndIf	

RETURN(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)

LOCAL cValorFinal 	:= strzero((nValor*100),10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator      	:= Strzero(dVencto - ctod("07/10/97"),4)
LOCAL cCart			:= "101"
//-----------------------------                                      
// Definicao do NOSSO NUMERO
// ----------------------------
//cS    :=  cCart + cNroDoc //19 001000012
cS    := cvaltochar(cNroDoc)
nDvnn := modulo11(cS,.F.) // digito verifacador
cNNSD := cS //Nosso Numero sem digito
cNNCD := PADL(cS+AllTrim(Str(nDvnn)),13,'0')
//cNN   := cCart + cNroDoc + '-' + AllTrim(Str(nDvnn))
cNN	  := cvaltochar(cNroDoc) + '-' + AllTrim(Str(nDvnn))
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cLivre 	:= Strzero(Val(cAgencia),4)+ cCart + cNNSD + Strzero(Val(cConta),8) + "0"

//cS		:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
cS		:= cBanco + cFator +  cValorFinal + "9"+SUBSTR(cCodEmp,1,4)+SUBSTR(cCodEmp,5,3)+cNNCD+"0"+cCart
nDvcb 	:= modulo11(cS,.T.)
cCB   	:= SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		WWWDD.DDDDDY	FFFFF.FQQQQZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**CEDENTE
cCedente:=SUBSTR(cCodEmp,1,4)// "4806"
//cS    := cBanco + "9" + Substr(cLivre,1,4)
cS    := cBanco + "9" + cCedente
nDv   := modulo10(cS)  //DAC
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '


// 	CAMPO 2:
//	WWW =COD CEDENTE PADRAO
//	DDDDDDD = Posição 14 a 20 do Nosso Numero
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Complemento Cedente
cCompCed:=SUBSTR(cCodEmp,5,3) //"301"
//cS 	:=Subs(cLivre,6,10)
cS 	:=cCompCed+Subs(cNNCD,1,7)
nDv	:= modulo10(cS)
cRN	+= Subs(cS,1,3)+substr(cNNCD,1,2) +'.'+ substr(cNNCD,3,5) + Alltrim(Str(nDv)) + '  

// 	CAMPO 3:
//	FFFFFF = Posição 22 a 27 do Nosso Numero
//	QQQQ =Tipo de modalidade
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Tipo de modalidade
cTipoMod:="0101" //Cobrança Simples Rápida COM Registro                   

//cS 	:=Subs(cLivre,16,10)
cS 	:=substr(cNNCD,8,6)+cTipoMod
nDv	:= modulo10(cS)
cRN	+= substr(cNNCD,8,5) +'.'+ substr(cNNCD,13,1)+cTipoMod+ Alltrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN  += cFator + StrZero((nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Banco     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VALIDBCO()
Local lRetorno := .T.

SA6->(DbSetorder(1))
If SA6->(DbSeek(xFilial("SA6") + cGet1))
	cGet2 := SA6->A6_AGENCIA
	cGet3 := SA6->A6_NUMCON
	oGet2:Refresh()
	oGet3:Refresh()
Else
	lRetorno := .F.
	Aviso("Aviso","Banco Inválido!!!",{"Retorna"})
	cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
	cGet3 	:= Space(TamSx3("A6_NUMCON")[1])
	oGet2:Refresh()
	oGet3:Refresh()
EndIf

Return lRetorno		