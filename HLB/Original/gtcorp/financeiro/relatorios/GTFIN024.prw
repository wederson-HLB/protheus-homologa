#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "FWPrintSetup.ch" 
#INCLUDE "RPTDEF.CH"

#DEFINE DS_MODALFRAME   128 

/*
Funcao      : GTFIN024()
Parametros  : _nOpc
Retorno     : _cRet
Objetivos   : Impressao de Boleto Bancario do Banco Itau com Codigode Barras, Linha Digitavel e Nosso Numero.
Autor	    : Anderson Arrais
Data/Hora   : 14/11/2016
M?dulo      : Financeiro.
Empresa		: GTCORP
*/

*-----------------------------------------------*
USER FUNCTION GTFIN024(lSelAuto,lPreview,lAutom)
*-----------------------------------------------*
Local aArea			:= GetArea()
LOCAL aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},{"E1_PREFIXO","Prefixo","@!"},{"E1_NUM","Titulo","@!"},;
						{"E1_PARCELA","Parcela","@!"},{"E1_VALOR","Valor","@E 9,999,999.99"},{"E1_VENCREA","Vencimento"}}
LOCAL	aPergs 		:= {}
LOCAL lExec         := .T.
LOCAL nOpc         	:= 0
LOCAL aMarked      	:= {}
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
Default lPreview    := .T.
DEFAULT lSelAuto	:= .F.
Default lAutom		:= .F.

Tamanho  := "M"
titulo   := "Impressao de Boleto Itau"
cDesc1   := "Este programa destina-se a impressao do Boleto Itau."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
dbSelectArea("SE1")
 
if !lSelAuto

	cPerg     :="GTFIN024"
	
	Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//Aadd(aPergs,{"Envia Email","","","mv_ch4","N",1,0,0,"C","","MV_PAR04","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""})
	
	AjustaSx1("GTFIN024",aPergs)
	
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF
/*Else
	//Quando vem do fonte GTFIN026
	MV_PAR01 := SQLSE1->E1_PREFIXO
	MV_PAR02 := SQLSE1->E1_NUM
	MV_PAR03 := SQLSE1->E1_NUM*/
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
	dbSelectArea ("SE1")
	DbGotop()
	ProcRegua(RecCount())
	DbSetOrder(1)
	DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)

	If ( SE1->E1_SALDO == 0 )
		Aviso("Aviso", 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao ser? gerado.',{"Abandona"},2 ) 
	Else	
		Aviso("Aviso","N?o existe informa??es.",{"Abandona"},2)	
    EndIf

Endif

Return( cFileRet )

*---------------------------------------------------*
 STATIC FUNCTION MontaRel(lSelAuto,lPreview,lAutom)
*---------------------------------------------------*
LOCAL oPrint
LOCAL n         := 0
LOCAL aDadosEmp := {SM0->M0_NOMECOM,;																//[1]Nome da Empresa
					SM0->M0_ENDCOB,; 																//[2]Endere?o
					AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;    //[3]Complemento
					"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			    //[4]CEP
					"PABX/FAX: "+SM0->M0_TEL,; 														//[5]Telefones
					"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;		     	//[6]
					Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;							//[6]
					Subs(SM0->M0_CGC,13,2),;														//[6]CGC
					"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;				//[7]
					Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}						     	//[7]I.E



LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado

LOCAL aBolText  := {}//U_GTFIN029()

LOCAL i         := 1
LOCAL CB_RN_NN  := {}
LOCAL nRec      := 0
LOCAL _nVlrAbat := 0
Local n, nI     := 0
Local _nRecSE1  := 0
Local cFileName := ""
Local cFile 	:= ""
Local cLocal 	:= GetTempPath()
Local cDirBol	:= "\FTP\" + cEmpAnt + "\GTFIN024\"    
Local cNroDoc	:= ""
Local cParMV    := ""
Local cParMV1   := ""
Local cBancPort := ""
Local cCamBol	:= ""
Local nTipoBol
Private aBMP	    := {	"ITAU.BMP",;	// Banner Publicitario Itau
					    	"LGRL.bmp"}		// Logo da Empresa
					    	
Private cQry		:= ""
Private aCols		:= {}
Private aAuxAcols	:= {}

dbSelectArea ("SE1")
DbGotop()
ProcRegua(RecCount())
DbSetOrder(1)
DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)

cFileName := "Boleto_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+"_"+SE1->E1_PREFIXO+ALLTRIM(SE1->E1_NUM)+ALLTRIM(SE1->E1_PARCELA) 

If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\GTFIN024\" )		
EndIf	

if !lSelAuto
	If !lPreview
		oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.F.,0)
	Else
		oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*F.*/,,.T.,.F.,,,,,,.T.,0)
	EndIf
	oPrint:Setup()
	oPrint:SetPortrait()			// ou SetLandscape()
	oPrint:SetPaperSize(9)			// Seta para papel A4
	//oPrint:StartPage()			// Inicia uma nova pagina
else
	If !lPreview
		oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.F.,0)
	Else
		oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*F.*/,,.T.,.F.,,,,,,.T.,0)
	EndIf

   	oPrint:SetResolution(72)
	oPrint:SetPortrait()			// ou SetLandscape()
	oPrint:nDevice := IMP_PDF
	oPrint:cPathPDF := cLocal 		
	oPrint:SetPaperSize(DMPAPER_A4)// Seta para papel A4
	//oPrint:SetMargin(60,60,60,60) 		
endif

While !EOF() .AND. xFilial("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == MV_PAR01 .AND. SE1->E1_NUM <= Mv_Par03
	If !SE1->E1_TIPO $ "NF /DP "
		SE1->(dbSkip())
		Loop
	Endif 

	If SA1->(FieldPos("A1_P_TPBOL")>0)
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE +SE1->E1_LOJA))
			nTipoBol:= Val(SA1->A1_P_TPBOL)
		EndIf
	Endif
	
	If lSelAuto
		If nTipoBol <> MV_PAR05 
			SE1->(DBSKIP())
			LOOP
		Endif
	Endif

	If !Empty(SE1->E1_PORTADO) .AND. SE1->E1_PORTADO <> "341" // GFP 03/02/2017 - Sistema ignora qualquer titulo com boleto ja gerado que seja diferente de Itau
		SE1->(dbSkip())
		Loop
	Endif 
	
	If ( SE1->E1_SALDO == 0 )
		MsgStop( 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao ser? gerado.' ) 
		SE1->(dbSkip())
		Loop
	Endif	

	If n > 0  // GFP - 16/01/2017 - Altera??o para gera??o de um boleto por arquivo.
		cFileName := "Boleto_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+"_"+SE1->E1_PREFIXO+ALLTRIM(SE1->E1_NUM)+ALLTRIM(SE1->E1_PARCELA)  	
		If !lPreview
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.F.,0)
		Else 
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*F.*/,,.T.,.F.,,,,,,.T.,0)
		EndIf
	    
	   	oPrint:SetResolution(72)
		oPrint:SetPortrait()			// ou SetLandscape()
		oPrint:nDevice := IMP_PDF
		oPrint:cPathPDF := cLocal 		
		oPrint:SetPaperSize(DMPAPER_A4)// Seta para papel A4
		//oPrint:SetMargin(60,60,60,60) 		
	endif

	If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
		Z18->(DbSetOrder(1))
		If	Z18->(DbSeek(xFilial("Z18")+AvKey(SM0->M0_CODIGO,"Z18_EMP")+AvKey(SM0->M0_CODFIL,"Z18_FILEMP")+AvKey("341","Z18_BANCO"))) .OR.;
			Z18->(DbSeek(xFilial("Z18")+AvKey(SM0->M0_CODIGO,"Z18_EMP")+AvKey("","Z18_FILEMP")+AvKey("341","Z18_BANCO")))
			Do While Z18->(!Eof()) .AND. Z18->Z18_FILIAL == xFilial("Z18") .AND.;
										Z18->Z18_EMP == AvKey(SM0->M0_CODIGO,"Z18_EMP") .AND.;
										IIF(!Empty(Z18->Z18_FILEMP),Z18->Z18_FILEMP == AvKey(SM0->M0_CODFIL,"Z18_FILEMP"),.T.) .AND.;
										Z18->Z18_BANCO == AvKey("341","Z18_BANCO")
				If Z18->Z18_DTINI <= SE1->E1_EMISSAO
					If Empty(Z18->Z18_DTFIM) .OR. Z18->Z18_DTFIM >= SE1->E1_EMISSAO
		   				cBanco    := AvKey(AllTrim(Z18->Z18_BANCO),"EE_CODIGO")		//Banco 341
		   				cAgencia  := AvKey(AllTrim(Z18->Z18_AGENC),"EE_AGENCIA")	//Agencia
		   				cConta    := AvKey(AllTrim(Z18->Z18_CONTA),"EE_CONTA") 		//Conta + digito
		   				cSubConta := "001"
		   				Exit
		   			EndIf
		   		EndIf
		   		Z18->(DbSkip())
		   	EndDo
		 Else
		 	MsgStop("Conta Corrente n?o cadastrada para esta empresa. Entre em contato com o suporte.","Grant Thornton" ) 
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
		cSubConta:=QUERYTRB->EE_SUBCTA
	else
		SE1->(dbSkip())
		Loop
	endif
	
	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+cBanco+(cAgencia+Space(TamSX3("A6_AGENCIA")[1]-Len(cAgencia)))+(cConta+Space(TamSX3("A6_NUMCON")[1]-Len(cConta))),.T.)
	
	aDadosBanco := {SA6->A6_COD ,;												// [1]Numero do Banco
					"BANCO ITAU SA",;										    // [2]Nome do Banco
					SUBSTR(SA6->A6_AGENCIA,1,4),;								// [3]Agencia
					SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
					SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	    // [5]Digito da conta corrente
					"109"}			     										// [6]Codigo da Carteira
					
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	aDatSacado := {	SubStr(AllTrim(SA1->A1_NOME),1,42),;						// [1]Razao Social
					AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;						// [2]Codigo
					AllTrim(SA1->A1_END)+" - "+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereco
					AllTrim(SA1->A1_MUN),;										// [4]Cidade
					SA1->A1_EST,;												// [5]Estado
					SA1->A1_CEP,;												// [6]CEP
					SA1->A1_CGC}												// [7]CGC
	
	dbSelectArea("SE1")
	
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	
	dbSelectArea("SE1")
	_nRecSE1  := recno()
	
	IF EMPTY(SE1->E1_NUMBCO)
		dbSelectArea("SEE")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+aDadosBanco[4]+aDadosBanco[5]+Space(TamSX3("A6_NUMCON")[1]-Len(aDadosBanco[4]+aDadosBanco[5]))+cSubConta)
			RecLock("SEE",.F.)
			cNroDoc			:= StrZero(VAL(SEE->EE_FAXATU)+1,8)
			SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU),8)
			MsUnLock()
		EndIf
		
		DbSelectArea("SE1")
		RecLock("SE1",.f.)
		SE1->E1_NUMBCO 	:=	cNroDoc   // Nosso n?mero (Ver f?rmula para calculo)
		SE1->E1_PORTADO := SA6->A6_COD
		SE1->E1_AGEDEP  := SA6->A6_AGENCIA
		SE1->E1_CONTA   := SA6->A6_NUMCON
		MsUnlock()
	ElseIf SE1->E1_PORTADO <> SA6->A6_COD .OR. SE1->E1_CONTA <> SA6->A6_NUMCON//Verifica se o banco j? gravado no titulo ? o mesmo do boleto atual
		If SE1->E1_PORTADO $ "033"
			cBancPort := "Santander"
		Else
			cBancPort := "outra conta"
		EndIf 
		MsgStop("Nosso n?mero gerado para "+cBancPort+".","Grant Thornton" ) 
		Return .F.
	Else	
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf
	DbSelectArea("SE1")
	dbGoTo(_nRecSE1)
	
	nSaldo := (E1_SALDO - _nVlrAbat-E1_DECRESC+E1_ACRESC)
	CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,nSaldo,E1_VENCREA,aDadosBanco[6])
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;	 // [1] Numero do Titulo
					E1_EMISSAO,;						     // [2] Data da Emissao do Titulo
					Date(),;							     // [3] Data da Emissao do Boleto
					E1_VENCREA,;							 // [4] Data do Vencimento
					nSaldo,;								 // [5] Valor do Titulo
					CB_RN_NN[3],;	                         // [6] Nosso Numero (Ver Formula para Calculo)
					E1_PREFIXO,;					      	 // [7] Prefixo da NF
					"DM"}//E1_TIPO}							 // [8] Tipo do Titulo
					
	//IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM)

	aBolText  := U_GTFIN029(nSaldo)
	
	Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
	n := n + 1
	
	If File( cLocal+cFileName+".pdf" )
		FErase(cLocal+cFileName+".pdf")
	EndIf
	
	If lPreview
		oPrint:Preview()
	Else
 		oPrint:Print()
	EndIf
	
	If !CpyT2S( cLocal+cFileName+".pdf" , cDirBol ,.T. )
  		MsgStop( 'Erro na copia para o servidor, boleto ' + cFileName+  ".pdf" )
   	EndIf	
	   		   		
	Ms_Flush()	
	if MV_PAR04==1
   		oOk		:= LoadBitmap( GetResources(), "LBOK")
   		AADD(aCols,{oOk,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_VALOR,SE1->E1_CLIENTE,AllTrim(SA1->A1_NOME),Alltrim(SA1->A1_P_EMAIC),cDirBol + cFileName+".pdf","",.F.})
		AADD(aAuxAcols,{Alltrim(SA1->A1_P_EMAIL),SE1->E1_EMISSAO})
    endif

	DbSelectArea("SE1")
	SE1->(dbSkip())
	IncProc()
	
	//AOA - 13/11/2017 - Ajuste para envio de mais de um boleto anexo quando tem parcela - Ticket 16886
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

RETURN (cFile) 

*---------------------------------------------------------------------------------------------------------*
 STATIC FUNCTION Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
*---------------------------------------------------------------------------------------------------------*
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont14n
LOCAL oFont24
LOCAL i        := 0
LOCAL _nLin    := 60//200
LOCAL aCoords1 := {0150,1900,0550,2300}
LOCAL aCoords2 := {0450,1050,0550,1900}
LOCAL aCoords3 := {_nLin+0710,1900,_nLin+0810,2300}
LOCAL aCoords4 := {_nLin+0980,1900,_nLin+1050,2300}
LOCAL aCoords5 := {_nLin+1330,1900,_nLin+1400,2300}
LOCAL aCoords6 := {_nLin+2000,1900,_nLin+2100,2300}
LOCAL aCoords7 := {_nLin+2270,1900,_nLin+2340,2300}
LOCAL aCoords8 := {_nLin+2620,1900,_nLin+2690,2300}
LOCAL oBrush
Local nValor   := aDadosTit[5]

// Par?metros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont8  := TFont():New("Arial",9,10/*08*/,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,12/*10*/,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)

oPrint:StartPage()	// Inicia uma nova Pagina

_nLin2 := 20
// Inicia aqui a alteracao para novo layout - RAI
oPrint:Line(0150,0560,0050,0560)
oPrint:Line(0150,0800,0050,0800)
oPrint:SayBitmap(0050,0100,aBmp[1],430,90 )
oPrint:Say (0062+_nLin2+10,0567,aDadosBanco[1]+"-7",oFont24)			// [1] Numero do Banco
oPrint:Say (0084+_nLin2,1870,"Comprovante de Entrega",oFont10)
oPrint:Line(0150,0100,0150,2300)
oPrint:Say (0150+_nLin2,0100,"Benefici?rio",oFont8)
oPrint:Say (0200+_nLin2,0100,aDadosEmp[1]	,oFont10)				// [1] Nome + CNPJ
oPrint:Say (0150+_nLin2,1060,"Ag?ncia/C?digo Benefici?rio",oFont8)
oPrint:Say (0200+_nLin2,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
oPrint:Say (0150+_nLin2,1510,"Nro.Documento",oFont8)
oPrint:Say (0200+_nLin2,1510,aDadosTit[7]+aDadosTit[1],oFont10)    // [7] Prefixo + [1] Numero + Parcela
oPrint:Say (0250+_nLin2,0100,"Pagador",oFont8)
oPrint:Say (0300+_nLin2,0100,aDatSacado[1],oFont10)				// [1] Nome
oPrint:Say (0250+_nLin2,1060,"Vencimento",oFont8)
oPrint:Say (0300+_nLin2,1060,STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4),oFont10)
oPrint:Say (0250+_nLin2,1510,"Valor do Documento",oFont8)
oPrint:Say (0300+_nLin2,1550,AllTrim(Transform(nValor,"@E 999,999,999.99")),oFont10)
oPrint:Say (0400+_nLin2,0100,"Recebi(emos) o bloqueto/t?tulo",oFont10)
oPrint:Say (0450+_nLin2,0100,"com as caracter?sticas acima.",oFont10)
oPrint:Say (0350+_nLin2,1060,"Data",oFont8)
oPrint:Say (0350+_nLin2,1410,"Assinatura",oFont8)
oPrint:Say (0450+_nLin2,1060,"Data",oFont8)
oPrint:Say (0450+_nLin2,1410,"Entregador",oFont8)
oPrint:Line(0250,0100,0250,1900)
oPrint:Line(0350,0100,0350,1900)
oPrint:Line(0450,1050,0450,1900) //---
oPrint:Line(0550,0100,0550,2300)
oPrint:Line(0550,1050,0150,1050)
oPrint:Line(0550,1400,0350,1400)
oPrint:Line(0350,1500,0150,1500) //--
oPrint:Line(0550,1900,0150,1900)
oPrint:Say (0150+_nLin2,1910,"(  )Mudou-se",oFont8)
oPrint:Say (0190+_nLin2,1910,"(  )Ausente",oFont8)
oPrint:Say (0230+_nLin2,1910,"(  )N?o existe n? indicado",oFont8)
oPrint:Say (0270+_nLin2,1910,"(  )Recusado",oFont8)
oPrint:Say (0310+_nLin2,1910,"(  )N?o procurado",oFont8)
oPrint:Say (0350+_nLin2,1910,"(  )Endere?o insuficiente",oFont8)
oPrint:Say (0390+_nLin2,1910,"(  )Desconhecido",oFont8)
oPrint:Say (0430+_nLin2,1910,"(  )Falecido",oFont8)
oPrint:Say (0470+_nLin2,1910,"(  )Outros(anotar no verso)",oFont8)


_nLin := _nLin - 10
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+0600,i,_nLin+0600,i+30)
NEXT i
oPrint:Line(_nLin+0710,0100,_nLin+0710,2300)
oPrint:Line(_nLin+0710,0560,_nLin+0610,0560)
oPrint:Line(_nLin+0710,0800,_nLin+0610,0800)
oPrint:SayBitmap(_nLin+0610,0100,aBmp[1],430,90 )
oPrint:Say (_nLin+_nLin2+0652,0567,aDadosBanco[1]+"-7",oFont24)	// [1]Numero do Banco
oPrint:Say (_nLin+_nLin2+0644,1900,"Recibo do Pagador",oFont10)
oPrint:Line(_nLin+0810,0100,_nLin+0810,2300)
oPrint:Line(_nLin+0910,0100,_nLin+0910,2300)
oPrint:Line(_nLin+0980,0100,_nLin+0980,2300)
oPrint:Line(_nLin+1050,0100,_nLin+1050,2300)
oPrint:Line(_nLin+0910,0500,_nLin+1050,0500)
oPrint:Line(_nLin+0980,0750,_nLin+1050,0750)
oPrint:Line(_nLin+0910,1000,_nLin+1050,1000)
oPrint:Line(_nLin+0910,1350,_nLin+0980,1350)
oPrint:Line(_nLin+0910,1550,_nLin+1050,1550)
oPrint:Say (_nLin+_nLin2+0710,0100,"Local de Pagamento",oFont8)
oPrint:Say (_nLin+_nLin2+0750,0100,"ATE O VENCIMENTO, PAGUE PREFERENCIALMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+_nLin2+0775,0100,"APOS O VENCIMENTO, PAGUE SOMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+_nLin2+0710,1910,"Vencimento",oFont8)
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+0750,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+0810,0100,"Benefici?rio",oFont8)
oPrint:Say (_nLin+_nLin2+0835,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+_nLin2+0870,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (_nLin+_nLin2+0810,1910,"Ag?ncia/C?digo Benefici?rio",oFont8)
cString   := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+0850,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+0910,0100,"Data do Documento",oFont8)
oPrint:Say (_nLin+_nLin2+0940,0100,STRZERO(day(aDadosTit[2],2),2)+"/"+STRZERO(month(aDadosTit[2],2),2)+"/"+STRZERO(year(aDadosTit[2],4),4),oFont10) // Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+_nLin2+0910,0505,"Nro.Documento",oFont8)
oPrint:Say (_nLin+_nLin2+0940,0605,aDadosTit[7]+" "+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela
oPrint:Say (_nLin+_nLin2+0910,1005,"Esp?cie Doc.",oFont8)
//oPrint:Say (_nLin+_nLin2+0940,1050,aDadosTit[8],oFont10) //Tipo do Titulo
oPrint:Say (_nLin+_nLin2+0940,1050,"DM",oFont10) //Tipo do Titulo
oPrint:Say (_nLin+_nLin2+0910,1355,"Aceite",oFont8)
oPrint:Say (_nLin+_nLin2+0940,1455,"N",oFont10)
oPrint:Say (_nLin+_nLin2+0910,1555,"Data do Processamento",oFont8)
oPrint:Say (_nLin+_nLin2+0940,1655,STRZERO(DAY(aDadosTit[3],2),2)+"/"+STRZERO(MONTH(aDadosTit[3],2),2)+"/"+STRZERO(YEAR(aDadosTit[3],2),4),oFont10) // Data impressao
oPrint:Say (_nLin+_nLin2+0910,1910,"Nosso N?mero",oFont8)
cString   := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1)
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+0940,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+0980,0100,"Uso do Banco",oFont8)
oPrint:Say (_nLin+_nLin2+0980,0505,"Carteira",oFont8)
oPrint:Say (_nLin+_nLin2+1010,0555,aDadosBanco[6],oFont10)
oPrint:Say (_nLin+_nLin2+0980,0755,"Esp?cie",oFont8)
oPrint:Say (_nLin+_nLin2+1010,0805,"R$",oFont10)
oPrint:Say (_nLin+_nLin2+0980,1005,"Quantidade",oFont8)
oPrint:Say (_nLin+_nLin2+0980,1555,"Valor",oFont8)
oPrint:Say (_nLin+_nLin2+0980,1910,"Valor do Documento",oFont8)
cString   := AllTrim(Transform(nValor,"@E 999,999,999.99"))
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+1010,nCol,cString,oFont10)
//oPrint:Say (_nLin+_nLin2+1050,0100,"Instru??es (Todas informa??es deste bloqueto s?o de exclusiva responsabilidade do Benefici?rio)",oFont8)
oPrint:Say (_nLin+_nLin2+1050,0100,"Instru??es (Instru??es de responsabilidade do benefici?rio. Qualquer d?vida sobre este boleto, contate o benefici?rio)",oFont8)
	_nLin3:=1110
For i=1 To Len(aBolText)
	oPrint:Say (_nLin+_nLin2+_nLin3,0100,aBolText[i],oFont10)
	_nLin3:= _nLin3+50 	
Next

oPrint:Say (_nLin+_nLin2+1050,1910,"(-)Desconto/Abatimento",oFont8)
oPrint:Say (_nLin+_nLin2+1120,1910,"(-)Outras Dedu??es",oFont8)
oPrint:Say (_nLin+_nLin2+1190,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (_nLin+_nLin2+1260,1910,"(+)Outros Acr?scimos",oFont8)
oPrint:Say (_nLin+_nLin2+1330,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (_nLin+_nLin2+1400,0100,"Pagador",oFont8)
oPrint:Say (_nLin+_nLin2+1430,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (_nLin+_nLin2+1483,0400,aDatSacado[3],oFont10)
oPrint:Say (_nLin+_nLin2+1536,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
oPrint:Say (_nLin+_nLin2+1589,0400,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
oPrint:Say (_nLin+_nLin2+1589,1950,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10)
oPrint:Say (_nLin+_nLin2+1605,0100,"Pagador/Avalista",oFont8)
oPrint:Say (_nLin+_nLin2+1645,1500,"Autentica??o Mec?nica -",oFont8)
oPrint:Line(_nLin+0710,1900,_nLin+1400,1900)
oPrint:Line(_nLin+1120,1900,_nLin+1120,2300)
oPrint:Line(_nLin+1190,1900,_nLin+1190,2300)
oPrint:Line(_nLin+1260,1900,_nLin+1260,2300)
oPrint:Line(_nLin+1330,1900,_nLin+1330,2300)
oPrint:Line(_nLin+1400,0100,_nLin+1400,2300)
oPrint:Line(_nLin+1640,0100,_nLin+1640,2300)

_nLin := _nLin - 120
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+1880,i,_nLin+1880,i+30)
NEXT i
// Encerra aqui a alteracao para o novo layout - RAI

oPrint:Line(_nLin+2000,0100,_nLin+2000,2300)
oPrint:Line(_nLin+2000,0560,_nLin+1900,0560)
oPrint:Line(_nLin+2000,0800,_nLin+1900,0800)
oPrint:SayBitmap(_nLin+1900,0100,aBmp[1],430,90 )
oPrint:Say (_nLin+_nLin2+1932,0567,aDadosBanco[1]+"-7",oFont24)// [1] Numero do Banco
oPrint:Say (_nLin+_nLin2+1934,0820,CB_RN_NN[2],oFont16n)		// [2] Linha Digitavel do Codigo de Barras
oPrint:Line(_nLin+2100,0100,_nLin+2100,2300)
oPrint:Line(_nLin+2200,0100,_nLin+2200,2300)
oPrint:Line(_nLin+2270,0100,_nLin+2270,2300)
oPrint:Line(_nLin+2340,0100,_nLin+2340,2300)
oPrint:Line(_nLin+2200,0500,_nLin+2340,0500)
oPrint:Line(_nLin+2270,0750,_nLin+2340,0750)
oPrint:Line(_nLin+2200,1000,_nLin+2340,1000)
oPrint:Line(_nLin+2200,1350,_nLin+2270,1350)
oPrint:Line(_nLin+2200,1550,_nLin+2340,1550)
oPrint:Say (_nLin+_nLin2+2000,0100,"Local de Pagamento",oFont8)
oPrint:Say (_nLin+_nLin2+2040,0100,"ATE O VENCIMENTO, PAGUE PREFERENCIALMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+_nLin2+2065,0100,"APOS O VENCIMENTO, PAGUE SOMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+_nLin2+2000,1910,"Vencimento",oFont8)
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+2040,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+2100,0100,"Benefici?rio",oFont8)
oPrint:Say (_nLin+_nLin2+2125,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+_nLin2+2160,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (_nLin+_nLin2+2100,1910,"Ag?ncia/C?digo Benefici?rio",oFont8)
cString   := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+2140,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+2200,0100,"Data do Documento",oFont8)
oPrint:Say (_nLin+_nLin2+2230,0100,STRZERO(DAY(aDadosTit[2],2),2)+"/"+STRZERO(MONTH(aDadosTit[2],2),2)+"/"+STRZERO(YEAR(aDadosTit[2],2),4),oFont10)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+_nLin2+2200,0505,"Nro.Documento",oFont8)
oPrint:Say (_nLin+_nLin2+2230,0605,aDadosTit[7]+" "+aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
oPrint:Say (_nLin+_nLin2+2200,1005,"Esp?cie Doc.",oFont8)
//oPrint:Say (_nLin+_nLin2+2230,1050,aDadosTit[8],oFont10)					//Tipo do Titulo
oPrint:Say (_nLin+_nLin2+2230,1050,"DM",oFont10)					//Tipo do Titulo
oPrint:Say (_nLin+_nLin2+2200,1355,"Aceite",oFont8)
oPrint:Say (_nLin+_nLin2+2230,1455,"N",oFont10)
oPrint:Say (_nLin+_nLin2+2200,1555,"Data do Processamento",oFont8)
oPrint:Say (_nLin+_nLin2+2230,1655,STRZERO(DAY(aDadosTit[3],2),2)+"/"+STRZERO(MONTH(aDadosTit[3],2),2)+"/"+STRZERO(YEAR(aDadosTit[3],2),4),oFont10) // Data impressao
oPrint:Say (_nLin+_nLin2+2200,1910,"Nosso N?mero",oFont8)
cString   := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1)
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+2230,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+2270,0100,"Uso do Banco",oFont8)
oPrint:Say (_nLin+_nLin2+2270,0505,"Carteira",oFont8)
oPrint:Say (_nLin+_nLin2+2300,0555,aDadosBanco[6],oFont10)
oPrint:Say (_nLin+_nLin2+2270,0755,"Esp?cie",oFont8)
oPrint:Say (_nLin+_nLin2+2300,0805,"R$",oFont10)
oPrint:Say (_nLin+_nLin2+2270,1005,"Quantidade",oFont8)
oPrint:Say (_nLin+_nLin2+2270,1555,"Valor",oFont8)
oPrint:Say (_nLin+_nLin2+2270,1910,"Valor do Documento",oFont8)
cString   := AllTrim(Transform(nValor,"@E 999,999,999.99"))
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+2300,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+2340,0100,"Instru??es (Instru??es de responsabilidade do benefici?rio. Qualquer d?vida sobre este boleto, contate o benefici?rio)",oFont8)
	_nLin3:=2400
For i=1 To Len(aBolText)
	oPrint:Say (_nLin+_nLin2+_nLin3,0100,aBolText[i],oFont10)
	_nLin3:= _nLin3+50 
Next

//oPrint:Say (_nLin+_nLin2+2440,0100,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")),oFont10)
//oPrint:Say (_nLin+_nLin2+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.02)/30),"@E 99,999.99")),oFont10)
//oPrint:Say (_nLin+_nLin2+2540,0100,aBolText[3],oFont10)
oPrint:Say (_nLin+_nLin2+2340,1910,"(-)Desconto/Abatimento",oFont8)
oPrint:Say (_nLin+_nLin2+2410,1910,"(-)Outras Dedu??es",oFont8)
oPrint:Say (_nLin+_nLin2+2480,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (_nLin+_nLin2+2550,1910,"(+)Outros Acr?scimos",oFont8)
oPrint:Say (_nLin+_nLin2+2620,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (_nLin+_nLin2+2690,0100,"Pagador",oFont8)
oPrint:Say (_nLin+_nLin2+2720,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (_nLin+_nLin2+2773,0400,aDatSacado[3],oFont10)
oPrint:Say (_nLin+_nLin2+2826,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
oPrint:Say (_nLin+_nLin2+2879,0400,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)	// CGC
oPrint:Say (_nLin+_nLin2+2879,1950,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10)
oPrint:Say (_nLin+_nLin2+2895,0100,"Pagador/Avalista",oFont8)
oPrint:Say (_nLin+_nLin2+2935,1500,"Autentica??o Mec?nica -",oFont8)
oPrint:Say (_nLin+_nLin2+2935,1850,"Ficha de Compensa??o",oFont10)
oPrint:Line(_nLin+2000,1900,_nLin+2690,1900)
oPrint:Line(_nLin+2410,1900,_nLin+2410,2300)
oPrint:Line(_nLin+2480,1900,_nLin+2480,2300)
oPrint:Line(_nLin+2550,1900,_nLin+2550,2300)
oPrint:Line(_nLin+2620,1900,_nLin+2620,2300)
oPrint:Line(_nLin+2690,0100,_nLin+2690,2300)
oPrint:Line(_nLin+2930,0100,_nLin+2930,2300)

cFont:="Helvetica 65 Medium"

oPrint:FWMSBAR("INT25" /*cTypeBar*/,65.5/*nRow*/ ,2/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.95/*0.8*//*nHeigth*/,.F./*lBanner*/, cFont/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

/*
???Parametros? 01 cTypeBar String com o tipo do codigo de barras           ???
???          ? 				"EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"     ???
???          ? 				"INT25","MAT25,"IND25","CODABAR","CODE3_9"     ???
???          ? 				"EAN128"                                       ???
???          ? 02 nRow		Numero da Linha em centimentros                ???
???          ? 03 nCol		Numero da coluna em centimentros			   ???
???          ? 04 cCode		String com o conteudo do codigo                ???
???          ? 05 oPr		Obejcto Printer                                ???
???          ? 06 lcheck	Se calcula o digito de controle                ???
???          ? 07 Cor 		Numero  da Cor, utilize a "common.ch"          ???
???          ? 08 lHort		Se imprime na Horizontal                       ???
???          ? 09 nWidth	Numero do Tamanho da barra em centimetros      ???
???          ? 10 nHeigth	Numero da Altura da barra em milimetros        ???
???          ? 11 lBanner	Se imprime o linha em baixo do codigo          ???
???          ? 12 cFont		String com o tipo de fonte                     ???
???          ? 13 cMode		String com o modo do codigo de barras CODE128  ???
???          ? 14 lPrint	Logico que indica se imprime ou nao            ???
???          ? 15 nPFWidth	Numero do indice de ajuste da largura da fonte ???
???          ? 16 nPFHeigth Numero do indice de ajuste da altura da fonte  ???
*/

oPrint:EndPage ()
RETURN Nil

*------------------------------*
STATIC FUNCTION Modulo10(cData) 
*------------------------------*
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
WHILE L > 0
	P := VAL(SUBSTR(cData, L, 1))
	IF (B)
		P := P * 2
		IF P > 9   //JSS
			P := P - 9//JSS
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

*------------------------------*
STATIC FUNCTION Modulo11(cData) 
*------------------------------*
LOCAL L, D, P := 0
L := LEN(cdata)
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

IF (D == 0 .Or. D == 1 .Or. D == 10 .or. D == 11)
	D := 1
ELSE
	D := 11 - (mod(D,11))
ENDIF


RETURN(D)

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  ?Ret_cBarra? Autor ? Microsiga             ? Data ? 13/10/03 ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ? IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Especifico para Clientes Microsiga                         ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/
*-----------------------------------------------------------------------------------------*
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cCarteira) 
*-----------------------------------------------------------------------------------------*

Local cCarteira    := alltrim(cCarteira)//"109"
LOCAL BlDocNuFinal := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)
LOCAL blvalorfinal := Strzero((nValor)*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL cMoeda       := "9"
Local cFator       := Strzero(SE1->E1_VENCREA - ctod("07/10/1997"),4)

//Montagem DAC do NOSSO NUMERO
snn   := BlDocNuFinal  // Nosso Numero
dvnn  := Alltrim(Str(modulo10(snn)))  //Digito verificador no Nosso Numero
cNN   := Strzero(val(cNroDoc),8) + dvnn

//Montagem DAC do campo agencia+conta+carteira+nossonumero

cCod  := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)

dvCod := Alltrim(Str(modulo10(cCod)))

//MONTAGEM DA LINHA DIGITAVEL
// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 1
campo1  := cBanco + cMoeda + cCarteira + substr(cNN,1,2)
dvC1    := Alltrim(Str(modulo10(campo1)))
cCampo1 := campo1 + dvC1

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 2
campo2  := substr(cNN,3,6) + dvCod + substr(cAgencia,1,3)
dvC2    := Alltrim(Str(modulo10(campo2)))
cCampo2 := campo2 + dvC2   //+ substr(cNroDoc+dvnn,3,7)

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 3
campo3  := substr(cAgencia,4,1) + cConta + cDacCC + "000"
dvC3    := Alltrim(Str(modulo10(campo3)))
cCampo3 := campo3 + dvC3 //+ substr(cAgencia,4,1)

// Montagem das DACs do Codigo de Barras
//campo 4

//campo4  := cBanco + cMoeda + cFator + blvalorfinal + cCarteira + cNroDoc+dvnn + cAgencia + cConta + cDacCC + "000"
campo4  := cBanco + cMoeda + cFator + blvalorfinal + cCarteira + cNN + cAgencia + cConta + cDacCC + "000"
cDacCB  := Alltrim(Str(Modulo11(campo4)))
cCampo4 := cDacCB

// Montagem
//campo 5
cCampo5  := cFator + blvalorfinal
////////////////////////////////////////////////////////////////////////////

cCB      := cBanco + cMoeda + cDacCB + cFator + blvalorfinal + cCarteira + cNN + cAgencia + cConta + cDacCC + "000" // codigo de barras

////////////////////////////////////////////////////////////////////////////
//MONTAGEM DA LINHA DIGITAVEL

cRN := substr(cCampo1,1,5)+"."+substr(cCampo1,6,5)+space(2)+ substr(cCampo2,1,5)+"."+substr(cCampo2,6,6)+space(2)+ substr(cCampo3,1,5)+"."+substr(cCampo3,6,6)+space(2) + cCampo4 + space(2)+ cCampo5

Return({cCB,cRN,cNN})

//??????????????????Ŀ
//? Valida Banco     ?
//????????????????????
*-------------------------*
Static Function VALIDBCO() 
*-------------------------*

Local lRetorno := .T.

DbSelectarea("SA6")
DbSetorder(1)
If DbSeek(xFilial("SA6") + cGet1)
	cGet2 := SA6->A6_AGENCIA
	cGet3 := SA6->A6_NUMCON
	oGet2:Refresh()
	oGet3:Refresh()
Else
	lRetorno := .F.
	Aviso("Aviso","Banco Inv?lido!!!",{"Retorna"})
	cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
	cGet3 	:= Space(TamSx3("A6_NUMCON")[1])
	oGet2:Refresh()
	oGet3:Refresh()
EndIf

Return lRetorno