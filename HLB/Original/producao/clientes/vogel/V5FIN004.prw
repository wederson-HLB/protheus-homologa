#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "FWPrintSetup.ch" 
#INCLUDE "RPTDEF.CH"
#Include "tbiconn.ch"

#DEFINE DS_MODALFRAME   128

/*
Funcao      : V5FIN004
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Boleto Bancario do Banco Santander com Codigo de Barras, Linha Digitavel e Nosso Numero.
Autor     	: Anderson Arrais
Data     	: 02/06/2017
M�dulo      : Financeiro.
Empresa		: VOGEL
*/

*-----------------------------------------*
USER FUNCTION V5FIN004(lSelAuto,lPreview)   
*-----------------------------------------*

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
Private cAgencia    := ''
Private cConta      := ''
Private cSubConta   := ''
Default lPreview    := .T.
DEFAULT lSelAuto	:= .F.

Tamanho  := "M"
titulo   := "Impressao de Boleto Santander
cDesc1   := "Este programa destina-se a impressao do Boleto Santander."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
dbSelectArea("SE1")

if !lSelAuto

	cPerg     :="V5FIN004"
	
	Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	AjustaSx1("V5FIN004",aPergs)
	
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF

Else
	MV_PAR01 := SF2->F2_PREFIXO
	MV_PAR02 := SF2->F2_DUPL
	MV_PAR03 := SF2->F2_DUPL
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
	Processa({|lEnd| cFileRet := MontaRel(lSelAuto,lPreview)})
else
	dbSelectArea ("SE1")
	DbGotop()
	ProcRegua(RecCount())
	DbSetOrder(1)
	DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)
	
	If ( SE1->E1_SALDO == 0 )
		Aviso("Aviso", 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao ser� gerado.',{"Abandona"},2 ) 
	Else	
		Aviso("Aviso","N�o existe informa��es.",{"Abandona"},2)	
    EndIf
    
Endif

Return( cFileRet )

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao    � MONTAREL()  � Autor � Flavio Novaes    � Data � 03/02/2005 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao � Impressao de Boleto Bancario do Banco Santander com Codigo ���
���           � de Barras, Linha Digitavel e Nosso Numero.                 ���
���           � Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.���
��������������������������������������������������������������������������Ĵ��
��� Uso       � FINANCEIRO                                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
STATIC FUNCTION MontaRel(lSelAuto,lPreview)
LOCAL oPrint
LOCAL n			:= 0
LOCAL nI     	:= 0
LOCAL aBitmap   := {	"",;			                                                            // Banner Publicitario
						"LGRL.bmp"}		                                                            // Logo da Empresa
LOCAL aDadosEmp := {SM0->M0_NOMECOM,;								   								//[1]Nome da Empresa
						SM0->M0_ENDCOB,; 															//[2]Endere�o
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
	LOCAL aBolText  := {"Juros e multas por atraso ser�o cobrados na pr�xima fatura.",;
						"Mantenha o pagamento em dia e evite a suspens�o parcial/total dos servi�os e a inclus�o nos �rg�os de prote��o do cr�dito.",;
					""}
LOCAL aBMP      	:= aBitMap
LOCAL i         	:= 1
LOCAL CB_RN_NN  	:= {}
LOCAL nRec     	 	:= 0
LOCAL _nVlrAbat 	:= 0
Local cLocal    	:= GetTempPath()
Local cFileName 	:= ""
Local cFile 		:= ""
Local cDirBol 	    := "\FTP\" + cEmpAnt + "\V5FIN004\" 
Private cPortGrv	:= ""
Private cAgeGrv		:= ""
Private cContaGrv	:= ""
Private cCodEmp		:= ""
Private aCols		:={}
Private aAuxAcols	:={}
Private nTipoBol    := 0


If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\V5FIN004\" )		
EndIf	

If Alltrim(SM0->M0_CODIGO)=="V5" // VOGEL
	cPortGrv    := "033"
	cAgeGrv     := "0119 "
	cContaGrv   := "130050831"
	cCodEmp		:= "8754357"
ElseIf Alltrim(SM0->M0_CODIGO) $ "FA" //SOUTH (Sul Americana)
	cPortGrv    := "033"
	cAgeGrv     := "0079 "
	cContaGrv   := "130043865"
	cCodEmp		:= "8754373"
EndIf                                    

If Empty(cPortGrv) .Or. Empty(cAgeGrv) .Or. Empty(cContaGrv)
	Aviso("Aviso","Portador n�o Escolhido, Boleto n�o ser� impresso.",{"Abandona"},2)
	Return Nil
EndIf  


SC5->( DbSetOrder( 1 ) , DbSeek( xFilial() + SQL->E1_PEDIDO )  )

cFileName := "Boleto_" + AllTrim( SF2->F2_DOC ) + "_" + AllTrim( SC5->C5_P_REF )

Do While SQL->(!EOF())

	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))

	//Posiciona o SA6 (Bancos)
	If Empty(SE1->E1_PORTADO)
		DbSelectArea("SA6")
		DbSetOrder(1)
		IF DbSeek(xFilial("SA6") + cPortGrv + cAgeGrv + cContaGrv)
			RecLock("SE1",.F.)
			SE1->E1_PORTADO := SA6->A6_COD
			SE1->E1_AGEDEP  := SA6->A6_AGENCIA
			SE1->E1_CONTA   := SA6->A6_NUMCON
			MsUnLock()
		EndIf
	EndIf
	
	SQL->(DbSkip())
EndDo

ProcRegua(SQL->(RecCount()))

SQL->(dbGoTop())

if !lSelAuto
	//oPrint  := TMSPrinter():New("Boleto Laser")

	oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.T.,0)
	oPrint:Setup()
	oPrint:SetPortrait()			// ou SetLandscape()
	oPrint:SetPaperSize(9)			// Seta para papel A4
	//oPrint:StartPage()				// Inicia uma nova pagina
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
	oPrint:SetPaperSize(DMPAPER_A4) 				// Seta para papel A4
	//oPrint:SetMargin(60,60,60,60) 		
endif

SQL->(dbGoTop())
ProcRegua(SQL->(RecCount()))
WHILE SQL->(!EOF())
	
	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))
	
	If Empty(SE1->E1_PORTADO)
		SQL->(DBSKIP())
		LOOP
	EndIf
	
	If SE1->E1_PORTADO $ "341"
		SQL->(dbSkip())
		Loop
	Endif 
	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	// Posiciona na Arq de Parametros CNAB
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	// Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	// Seleciona o SE1 (Contas a Receber)
	dbSelectArea("SE1")
	aDadosBanco := {"033",;													  //SA6->A6_COD [1]Numero do Banco
					"SANTANDER",;											  // [2]Nome do Banco
					SUBSTR(SA6->A6_AGENCIA,1,4),;							  // [3]Agencia
					SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),; // [4]Conta Corrente
					SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	  // [5]Digito da conta corrente                 
					"101"}													  // [6]Codigo da Carteira
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
	
	IF EMPTY(SE1->E1_NUMBCO) 
	
	nTam := TamSx3("EE_FAXATU")[1]
	nTamE1 := TamSx3("E1_NUMBCO")[1]

		// Enquanto nao conseguir criar o semaforo, indica que outro usuario
		// esta tentando gerar o nosso numero.
		cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)
		
		While !MayIUseCode( SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))  //verifica se esta na memoria, sendo usado
			cNumero := Soma1(cNumero)									               // busca o proximo numero disponivel 
		EndDo
		
		cNroDoc 	:= SUBSTR(cNumero,LEN(cNumero)-7,8)
		cNroDoc 	:= cNroDoc + AllTrim(Str(MODULO11(cNroDoc)))//E1_NUMBCO � gravado com o digito verificador
		
				
			RecLock("SE1",.F.)
			Replace SE1->E1_NUMBCO With cNroDoc
			SE1->( MsUnlock( ) )
			
			RecLock("SEE",.F.)
			Replace SEE->EE_FAXATU With Soma1(cNumero, nTam)
			SEE->( MsUnlock() )
		
		cNroDoc 	:= SUBSTR(ALLTRIM(SE1->E1_NUMBCO),LEN(ALLTRIM(SE1->E1_NUMBCO))-8,8)//ALLTRIM(SE1->E1_NUMBCO)	
	   
		Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
		DbSelectArea("SE1")
	
	Else
		cNroDoc 	:= SUBSTR(ALLTRIM(SE1->E1_NUMBCO),LEN(ALLTRIM(SE1->E1_NUMBCO))-8,8)//ALLTRIM(SE1->E1_NUMBCO)
	EndIf
	nSaldo := (E1_SALDO - _nVlrAbat-E1_DECRESC+E1_ACRESC)
	CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,nSaldo,E1_VENCREA)
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;			// [1] Numero do Titulo
					E1_EMISSAO,;									// [2] Data da Emissao do Titulo
					Date(),;										// [3] Data da Emissao do Boleto
					E1_VENCREA,;									// [4] Data do Vencimento
					nSaldo,;   										// [5] Valor do Titulo Liquido
					CB_RN_NN[3],;									// [6] Nosso Numero (Ver Formula para Calculo)
					E1_PREFIXO,;									// [7] Prefixo da NF
					E1_TIPO,;										// [8] Tipo do Titulo  
					E1_DECRESC,;                            		// [9] Desconto
					E1_ACRESC,;                              		//[10] Acrecimos  
					nSaldo }                              		    //[11] Valor do Titulo Bruto

	IF .t. //aMarked[i]
		Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
		n := n + 1
	ENDIF
	
	SQL->(dbSkip())
	SQL->(INCPROC())
	i := i + 1
ENDDO

If File( cLocal+cFileName+".pdf" )
	FErase(cLocal+cFileName+".pdf")
EndIf


If lPreview
	oPrint:Preview()
	
Else
	oPrint:Print()
	If CpyT2S( cLocal + cFileName + ".pdf" , cDirBol ,.T. )
		cFile := cDirBol + cFileName+".pdf"
		
	Else
		
		MsgStop( 'Erro na c�pia para o servidor, boleto ' + cFileName+  ".pdf" )
	EndIf
EndIf

SQL->(DbCloseArea())

RETURN( cFile )
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao    � IMPRESS()   � Autor � Flavio Novaes    � Data � 03/02/2005 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao � Impressao de Boleto Bancario do Banco Santander com Codigo ���
���           � de Barras, Linha Digitavel e Nosso Numero.                 ���
���           � Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.���
��������������������������������������������������������������������������Ĵ��
��� Uso       � FINANCEIRO                                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
//Local cSantLogo:="Santander10.bmp"
Local cSantLogo:="santban10.bmp"

SET DATE FORMAT "dd/mm/yyyy"

// Par�metros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont8  := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
//oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)
oPrint:StartPage()	// Inicia uma nova Pagina

// Inicia aqui a alteracao para novo layout - RAI
oPrint:Line(0150,0560,0050,0560)
oPrint:Line(0150,0800,0050,0800)
//oPrint:Say (0084,0100,aDadosBanco[2],oFont16)					// [2] Nome do Banco
oPrint:SayBitmap(0050,0100,cSantLogo,430,90 )

oPrint:Say (nSalto+0082,0567,aDadosBanco[1]+"-7",oFont24)					// [1] Numero do Banco
oPrint:Say (nSalto+0084,1870,"Comprovante de Entrega",oFont10)
oPrint:Line(0150,0100,0150,2300)
oPrint:Say (nSalto+0150,0100,"Benefici�rio",oFont8)
oPrint:Say (nSalto+0200,0100,aDadosEmp[1]	,oFont10)					// [1] Nome + CNPJ
oPrint:Say (nSalto+0150,1060,"Ag�ncia/C�digo Cedente",oFont8)
oPrint:Say (nSalto+0200,1060,aDadosBanco[3]+"/"+cCodEmp,oFont10)
oPrint:Say (nSalto+0150,1510,"Nro.Documento",oFont8)
oPrint:Say (nSalto+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10)	// [7] Prefixo + [1] Numero + Parcela
oPrint:Say (nSalto+0250,0100,"Pagador",oFont8)
oPrint:Say (nSalto+0300,0100,aDatSacado[1],oFont10)					// [1] Nome
oPrint:Say (nSalto+0250,1060,"Vencimento",oFont8)
oPrint:Say (nSalto+0300,1060,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+0250,1510,"Valor do Documento",oFont8)
oPrint:Say (nSalto+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+0400,0100,"Recebi(emos) o bloqueto/t�tulo",oFont10)
oPrint:Say (nSalto+0450,0100,"com as caracter�sticas acima.",oFont10)
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
oPrint:Say (nSalto+0230,1910,"(  )N�o existe n� indicado",oFont8)
oPrint:Say (nSalto+0270,1910,"(  )Recusado",oFont8)
oPrint:Say (nSalto+0310,1910,"(  )N�o procurado",oFont8)
oPrint:Say (nSalto+0350,1910,"(  )Endere�o insuficiente",oFont8)
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
//oPrint:Say (nSalto+_nLin+0750,0100,"QUALQUER BANCO AT� A DATA DO VENCIMENTO",oFont10)
oPrint:Say (nSalto+_nLin+0750,0100,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO SANTANDER",oFont8)
oPrint:Say (nSalto+_nLin+0775,0100,"APOS O VENCIMENTO PAGUE SOMENTE NO SANTANDER",oFont8)
oPrint:Say (nSalto+_nLin+0710,1910,"Vencimento",oFont8)
oPrint:Say (nSalto+_nLin+0750,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+_nLin+0810,0100,"Benefici�rio",oFont8)
oPrint:Say (nSalto+_nLin+0835,0100,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (nSalto+_nLin+0870,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (nSalto+_nLin+0810,1910,"Ag�ncia/C�digo Cedente",oFont8)
oPrint:Say (nSalto+_nLin+0850,1950,aDadosBanco[3]+"/"+cCodEmp,oFont10)
oPrint:Say (nSalto+_nLin+0910,0100,"Data do Documento",oFont8)
oPrint:Say (nSalto+_nLin+0940,0100,DTOC(aDadosTit[2]),oFont10) // Emissao do Titulo (E1_EMISSAO)
oPrint:Say (nSalto+_nLin+0910,0505,"Nro.Documento",oFont8)
oPrint:Say (nSalto+_nLin+0940,0605,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela
oPrint:Say (nSalto+_nLin+0910,1005,"Esp�cie Doc.",oFont8)
oPrint:Say (nSalto+_nLin+0940,1050,aDadosTit[8],oFont10) //Tipo do Titulo
oPrint:Say (nSalto+_nLin+0910,1355,"Aceite",oFont8)
oPrint:Say (nSalto+_nLin+0940,1455,"N",oFont10)
oPrint:Say (nSalto+_nLin+0910,1555,"Data do Processamento",oFont8)
oPrint:Say (nSalto+_nLin+0940,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (nSalto+_nLin+0910,1910,"Nosso N�mero",oFont8)
//oPrint:Say (nSalto+_nLin+0940,1950,SUBSTR(aDadosTit[6],1,3)+"/"+SUBSTR(aDadosTit[6],4),oFont10)
oPrint:Say (nSalto+_nLin+0940,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'),oFont10)
oPrint:Say (nSalto+_nLin+0980,0100,"Uso do Banco",oFont8)
oPrint:Say (nSalto+_nLin+0980,0505,"Carteira",oFont8)
oPrint:Say (nSalto+_nLin+1010,0555,aDadosBanco[6],oFont10)
oPrint:Say (nSalto+_nLin+0980,0755,"Esp�cie",oFont8)
oPrint:Say (nSalto+_nLin+1010,0805,"R$",oFont10)
oPrint:Say (nSalto+_nLin+0980,1005,"Quantidade",oFont8)
oPrint:Say (nSalto+_nLin+0980,1555,"Valor",oFont8)
oPrint:Say (nSalto+_nLin+0980,1910,"Valor do Documento",oFont8)
oPrint:Say (nSalto+_nLin+1010,1950,AllTrim(Transform(aDadosTit[11],"@E 999,999,999.99")),oFont10)//JSS Alterado para solu��o do caso 031197
oPrint:Say (nSalto+_nLin+1050,0100,"Instru��es (Instru��es de responsabilidade do benefici�rio. Qualquer d�vida sobre este boleto, contate o benefici�rio)",oFont8)
oPrint:Say (nSalto+_nLin+1150,0100,aBolText[1],oFont10)
oPrint:Say (nSalto+_nLin+1200,0100,aBolText[2],oFont10)
//oPrint:Say (nSalto+_nLin+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+1250,0100,aBolText[3],oFont10)
oPrint:Say (nSalto+_nLin+1050,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+1080,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10) 
oPrint:Say (nSalto+_nLin+1120,1910,"(-)Outras Dedu��es",oFont8)
oPrint:Say (nSalto+_nLin+1190,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (nSalto+_nLin+1260,1910,"(+)Outros Acr�scimos",oFont8)
//oPrint:Say (nSalto+_nLin+1290,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10) 
oPrint:Say (nSalto+_nLin+1330,1910,"(=)Valor Cobrado",oFont8)    
oPrint:Say (nSalto+_nLin+1360,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10) 
oPrint:Say (nSalto+_nLin+1400,0100,"Pagador",oFont8)
oPrint:Say (nSalto+_nLin+1430,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (nSalto+_nLin+1483,0400,aDatSacado[3],oFont10)
oPrint:Say (nSalto+_nLin+1536,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
oPrint:Say (nSalto+_nLin+1589,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
//oPrint:Say (nSalto+_nLin+1589,1950,SUBSTR(aDadosTit[6],1,3)+"/00"+SUBSTR(aDadosTit[6],4,8),oFont10)
oPrint:Say (nSalto+_nLin+1589,1950,SUBSTR(aDadosTit[6],4,len(aDadosTit[6])-3),oFont10)
oPrint:Say (nSalto+_nLin+1605,0100,"Pagador/Avalista",oFont8)
oPrint:Say (nSalto+_nLin+1645,1500,"Autentica��o Mec�nica -",oFont8)
oPrint:Say (nSalto+_nLin+1645,1850,"Ficha de Compensa��o",oFont8)
oPrint:Line(_nLin+0710,1900,_nLin+1400,1900)
oPrint:Line(_nLin+1120,1900,_nLin+1120,2300)
oPrint:Line(_nLin+1190,1900,_nLin+1190,2300)
oPrint:Line(_nLin+1260,1900,_nLin+1260,2300)
oPrint:Line(_nLin+1330,1900,_nLin+1330,2300)
oPrint:Line(_nLin+1400,0100,_nLin+1400,2300)
oPrint:Line(_nLin+1640,0100,_nLin+1640,2300)

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
oPrint:Say (nSalto+_nLin+1934,0820,CB_RN_NN[2],oFont14n)		// [2] Linha Digitavel do Codigo de Barras
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
//oPrint:Say (nSalto+_nLin+2040,0100,"QUALQUER BANCO AT� A DATA DO VENCIMENTO",oFont10)
oPrint:Say (nSalto+_nLin+2000,1910,"Vencimento",oFont8)
oPrint:Say (nSalto+_nLin+2040,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+_nLin+2100,0100,"Benefici�rio",oFont8)
oPrint:Say (nSalto+_nLin+2125,0100,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (nSalto+_nLin+2160,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (nSalto+_nLin+2100,1910,"Ag�ncia/C�digo Cedente",oFont8)
oPrint:Say (nSalto+_nLin+2140,1950,aDadosBanco[3]+"/"+cCodEmp,oFont10)
oPrint:Say (nSalto+_nLin+2200,0100,"Data do Documento",oFont8)
oPrint:Say (nSalto+_nLin+2230,0100,DTOC(aDadosTit[2]),oFont10)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (nSalto+_nLin+2200,0505,"Nro.Documento",oFont8)
oPrint:Say (nSalto+_nLin+2230,0605,aDadosTit[7]+aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
oPrint:Say (nSalto+_nLin+2200,1005,"Esp�cie Doc.",oFont8)
oPrint:Say (nSalto+_nLin+2230,1050,aDadosTit[8],oFont10)					//Tipo do Titulo
oPrint:Say (nSalto+_nLin+2200,1355,"Aceite",oFont8)
oPrint:Say (nSalto+_nLin+2230,1455,"N",oFont10)
oPrint:Say (nSalto+_nLin+2200,1555,"Data do Processamento",oFont8)
oPrint:Say (nSalto+_nLin+2230,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (nSalto+_nLin+2200,1910,"Nosso N�mero",oFont8)
//oPrint:Say (nSalto+_nLin+2230,1950,SUBSTR(aDadosTit[6],1,3)+"/"+SUBSTR(aDadosTit[6],4),oFont10)
oPrint:Say (nSalto+_nLin+2230,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),14,'0'),oFont10)
oPrint:Say (nSalto+_nLin+2270,0100,"Uso do Banco",oFont8)
oPrint:Say (nSalto+_nLin+2270,0505,"Carteira",oFont8)
oPrint:Say (nSalto+_nLin+2300,0555,aDadosBanco[6],oFont10)
oPrint:Say (nSalto+_nLin+2270,0755,"Esp�cie",oFont8)
oPrint:Say (nSalto+_nLin+2300,0805,"R$",oFont10)
oPrint:Say (nSalto+_nLin+2270,1005,"Quantidade",oFont8)
oPrint:Say (nSalto+_nLin+2270,1555,"Valor",oFont8)
oPrint:Say (nSalto+_nLin+2270,1910,"Valor do Documento",oFont8)
oPrint:Say (nSalto+_nLin+2300,1950,AllTrim(Transform(aDadosTit[11],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2340,0100,"Instru��es (Instru��es de responsabilidade do benefici�rio. Qualquer d�vida sobre este boleto, contate o benefici�rio)",oFont8)
oPrint:Say (nSalto+_nLin+2440,0100,aBolText[1],oFont10)
oPrint:Say (nSalto+_nLin+2490,0100,aBolText[2],oFont10)
//oPrint:Say (nSalto+_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2540,0100,aBolText[3],oFont10)
oPrint:Say (nSalto+_nLin+2340,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+2370,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10) 
oPrint:Say (nSalto+_nLin+2410,1910,"(-)Outras Dedu��es",oFont8)
oPrint:Say (nSalto+_nLin+2480,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (nSalto+_nLin+2550,1910,"(+)Outros Acr�scimos",oFont8)
//oPrint:Say (nSalto+_nLin+2580,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2620,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (nSalto+_nLin+2650,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2690,0100,"Pagador",oFont8)
oPrint:Say (nSalto+_nLin+2720,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (nSalto+_nLin+2773,0400,aDatSacado[3],oFont10)
oPrint:Say (nSalto+_nLin+2826,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
oPrint:Say (nSalto+_nLin+2879,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)	// CGC
//oPrint:Say (nSalto+_nLin+2879,1950,SUBSTR(aDadosTit[6],1,3)+"/00"+SUBSTR(aDadosTit[6],4,8),oFont10)
oPrint:Say (nSalto+_nLin+2879,1950,SUBSTR(aDadosTit[6],4,len(aDadosTit[6])-3),oFont10)
oPrint:Say (nSalto+_nLin+2895,0100,"Pagador/Avalista",oFont8)
oPrint:Say (nSalto+_nLin+2935,1500,"Autentica��o Mec�nica -",oFont8)
oPrint:Say (nSalto+_nLin+2935,1850,"Ficha de Compensa��o",oFont8)
oPrint:Line(_nLin+2000,1900,_nLin+2690,1900)
oPrint:Line(_nLin+2410,1900,_nLin+2410,2300)
oPrint:Line(_nLin+2480,1900,_nLin+2480,2300)
oPrint:Line(_nLin+2550,1900,_nLin+2550,2300)
oPrint:Line(_nLin+2620,1900,_nLin+2620,2300)
oPrint:Line(_nLin+2690,0100,_nLin+2690,2300)
oPrint:Line(_nLin+2930,0100,_nLin+2930,2300)

//MSBAR("INT25"  ,27.8,1.5,CB_RN_NN[1],oPrint,.F.,,,,1.4,,,,.F.)   
cFont:="Helvetica 65 Medium"
oPrint:FWMSBAR("INT25" /*cTypeBar*/,64.3/*nRow*/ ,2/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.95/*0.8*//*nHeigth*/,.F./*lBanner*/, cFont/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
     

oPrint:EndPage()	// Finaliza a Pagina
RETURN Nil
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao    � MODULO10()  � Autor � Flavio Novaes    � Data � 03/02/2005 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao � Impressao de Boleto Bancario do Banco Santander com Codigo ���
���           � de Barras, Linha Digitavel e Nosso Numero.                 ���
���           � Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.���
��������������������������������������������������������������������������Ĵ��
��� Uso       � FINANCEIRO                                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao    � MODULO11()  � Autor � Flavio Novaes    � Data � 03/02/2005 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao � Impressao de Boleto Bancario do Banco Santander com Codigo ���
���           � de Barras, Linha Digitavel e Nosso Numero.                 ���
���           � Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.���
��������������������������������������������������������������������������Ĵ��
��� Uso       � FINANCEIRO                                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
STATIC FUNCTION Modulo11(cData,lCodBarra)
LOCAL L, D, P := 0
Default lCodBarra := .F.


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

//Tratamento para digito verificador.
If lCodBarra //Codigo de Barras
	//Se o resto for 0,1 ou 10 o digito � 1
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		D := 1
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
Else //Nosso Numero
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		//Se o resto for 0 ou 1 o digito � 0
		IF (D == 0 .Or. D == 1)
			D := 0

		//Se o resto for 10 o digito � 1
		ELSEIF (D == 10)
			D := 1
		ENDIF
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
EndIf	

RETURN(D)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Ret_cBarra� Autor � Microsiga             � Data � 13/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Clientes Microsiga                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
cS    := cNroDoc
nDvnn := modulo11(cS,.F.) // digito verifacador
cNNSD := cS //Nosso Numero sem digito
cNNCD := PADL(cS+AllTrim(Str(nDvnn)),13,'0')
cNN   := cCart + cNroDoc + '-' + AllTrim(Str(nDvnn))
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
//	DDDDDDD = Posi��o 14 a 20 do Nosso Numero
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Complemento Cedente
cCompCed:=SUBSTR(cCodEmp,5,3) //"301"
//cS 	:=Subs(cLivre,6,10)
cS 	:=cCompCed+Subs(cNNCD,1,7)
nDv	:= modulo10(cS)
cRN	+= Subs(cS,1,3)+substr(cNNCD,1,2) +'.'+ substr(cNNCD,3,5) + Alltrim(Str(nDv)) + '  

// 	CAMPO 3:
//	FFFFFF = Posi��o 22 a 27 do Nosso Numero
//	QQQQ =Tipo de modalidade
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

//**Tipo de modalidade
cTipoMod:="0101" //Cobran�a Simples R�pida COM Registro                   

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

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � AjustaSx1    � Autor � Microsiga            	� Data � 13/10/03 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica/cria SX1 a partir de matriz para verificacao          ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Clientes Microsiga                    	  		���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local cKey		:= ""
Local nJ		:= 0
Local nCondicao

cPerg := Padr(cPerg,10)

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		U_PUTHelp(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

//--------------------------------------------------------------
/*/{Protheus.doc} SELPORT
Description

@param xParam Parameter Description
@return xRet Return Description
@author  - Amedeo D. P. Filho
@since 02/03/2011
/*/
//--------------------------------------------------------------
Static Function SELPORT()

Local oFont1	:= TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
Local nOpcA		:= 0

Private cGet1 	:= Space(TamSx3("A6_COD")[1])
Private cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
Private cGet3 	:= Space(TamSx3("A6_NUMCON")[1])

Private oGet1
Private oGet2
Private oGet3

Static oDlg

DEFINE MSDIALOG oDlg TITLE "Selecionar Portador" FROM 000, 000  TO 230, 200 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

oDlg:lEscClose	:= .F.

@ 011, 010 SAY oSay1 PROMPT "Selecione Portador" 	SIZE 080, 012 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 035, 010 SAY oSay2 PROMPT "Banco :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 050, 010 SAY oSay3 PROMPT "Agencia :" 			SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 065, 010 SAY oSay4 PROMPT "Conta :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 035, 040 MSGET oGet1 VAR cGet1 SIZE 040, 010 OF oDlg COLORS 0, 16777215 F3 "SANTAN" PIXEL Valid(VALIDBCO())
@ 050, 040 MSGET oGet2 VAR cGet2 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.
@ 065, 040 MSGET oGet3 VAR cGet3 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.

DEFINE SBUTTON oSButton1 FROM 087, 020 TYPE 01 OF oDlg ENABLE Action (nOpcA := 1, oDlg:End())
DEFINE SBUTTON oSButton2 FROM 087, 051 TYPE 02 OF oDlg ENABLE Action (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcA == 1
	cPortGrv	:= cGet1
	cAgeGrv		:= cGet2
	cContaGrv	:= cGet3
EndIf

//������������������Ŀ
//� Valida Banco     �
//��������������������
Static Function VALIDBCO()
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
	Aviso("Aviso","Banco Inv�lido!!!",{"Retorna"})
	cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
	cGet3 	:= Space(TamSx3("A6_NUMCON")[1])
	oGet2:Refresh()
	oGet3:Refresh()
EndIf

Return lRetorno		
