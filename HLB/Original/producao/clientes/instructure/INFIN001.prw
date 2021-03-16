#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "FWPrintSetup.ch" 
#INCLUDE "RPTDEF.CH"
#Include "tbiconn.ch"

#DEFINE DS_MODALFRAME   128

/*
Funcao      : INFIN001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Impressao de Boleto Bancario do Banco Citibank com Codigo de Barras, Linha Digitavel e Nosso Numero.
Autor     	: Anderson Arrais
Data     	: 30/03/2016 
TDN         :  
Revisão     :  
Data/Hora   : 
Módulo      : Financeiro.
Empresa		: Instructure
*/

*-----------------------*
USER FUNCTION INFIN001()   
*-----------------------*

LOCAL aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},;    		 //[01] - Codigo do cliente.
						{"E1_PREFIXO","Prefixo","@!"},;          //[02] - Prefixo da nota. 
						{"E1_NUM","Titulo","@!"},;               //[03] - Numero da nota. 
						{"E1_PARCELA","Parcela","@!"},;          //[04] - Parcela da nota.
						{"E1_VALOR","Valor","@E 9,999,999.99"},; //[05] - Valor da nota.
						{"E1_VENCREA","Vencimento"}}             //[06] - Data de vencimento.
LOCAL aPergs 		:= {}
LOCAL lExec         := .T.
LOCAL nOpc         	:= 0
LOCAL aMarked      	:= {}
LOCAL aDesc        	:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"} 

PRIVATE Exec       	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''
Private cBanco		:= ''
Private cAgencia	:= ''
Private cConta		:= ''
Private cSubConta	:= ''

Tamanho  := "M"
titulo   := "Impressao de Boleto CitiBank"
cDesc1   := "Este programa destina-se a impressao do Boleto CitiBank."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOL755IN"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
dbSelectArea("SE1")

cPerg     :="BLTIN"

Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch4","C",9,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela","","","mv_ch5","C",1,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela","","","mv_ch6","C",1,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Cliente","","","mv_ch7","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"Ate Cliente","","","mv_ch8","C",6,0,0,"G","","MV_PAR08","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"De Loja","","","mv_cha","C",2,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Loja","","","mv_chb","C",2,0,0,"G","","MV_PAR10","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao","","","mv_chc","D",8,0,0,"G","","MV_PAR11","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao","","","mv_chd","D",8,0,0,"G","","MV_PAR12","","","","31/12/20","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Vencimento","","","mv_che","D",8,0,0,"G","","MV_PAR13","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento","","","mv_chf","D",8,0,0,"G","","MV_PAR14","","","","31/12/20","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Bordero","","","mv_chg","C",6,0,0,"G","","MV_PAR15","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Bordero","","","mv_chh","C",6,0,0,"G","","MV_PAR16","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1("BLTIN",aPergs)

SET DATE FORMAT "dd/mm/yyyy"

If !Pergunte (cPerg,.T.)
	Return Nil
EndIF

If Select('SQL') > 0
	SQL->(DbCloseArea())
EndIf

cQry:=" SELECT E1_OK,E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,R_E_C_N_O_  as 'RECNUM' 
cQry+=" FROM "+RETSQLNAME("SE1")
cQry+=" WHERE D_E_L_E_T_=''
cQry+=" AND E1_FILIAL ='"+xFilial("SE1")+"' 
cQry+=" AND E1_SALDO > 0
cQry+=" AND E1_PREFIXO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
cQry+=" AND E1_NUM     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
cQry+=" AND E1_PARCELA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
cQry+=" AND E1_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
cQry+=" AND E1_LOJA    BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'
cQry+=" AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR11)+"' AND '"+DTOS(MV_PAR12)+"'
cQry+=" AND E1_VENCREA BETWEEN '"+DTOS(MV_PAR13)+"' AND '"+DTOS(MV_PAR14)+"' 
cQry+=" AND E1_NUMBOR BETWEEN '"+MV_PAR15+"' AND '"+MV_PAR16+"'
cQry+=" AND E1_TIPO IN ('NF','BOL')
cQry+=" ORDER BY E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "SQL" ,.T.,.F.)

SQL->(dbGoTop())

If SQL->(EOF()) .or. SQL->(BOF())
	lExec := .F.
	alert("Não há dados com esses parâmetros!")
EndIf

If lExec
	Processa({|lEnd|MontaRel()})
else
	Aviso("Aviso","Não existe informações.",{"Abandona"},2)	
Endif

Return Nil

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
STATIC FUNCTION MontaRel(aMarked)
LOCAL oPrint
LOCAL n			:= 0
LOCAL nI     	:= 0
LOCAL aBitmap   := {	MV_PAR19,;			                                                        // Banner Publicitario
						"LGRL.bmp"}		                                                            // Logo da Empresa

LOCAL aDadosEmp := {	SM0->M0_NOMECOM,;															//[1]Nome da Empresa
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
LOCAL aBolText  := {"TITULO SUJEITO A PROTESTO APÓS 30 DIAS DO VENCIMENTO"}    

LOCAL aBMP      := aBitMap
LOCAL i         := 1
LOCAL CB_RN_NN  := {}
LOCAL nRec      := 0
LOCAL _nVlrAbat := 0
LOCAL cFileName

If Alltrim(SM0->M0_CODIGO) $ "IN"
	cBanco		:= "745"
	cAgencia	:= "0001 "
	cConta		:= "0109634018" 
	cSubConta	:= "001"
EndIf                                    

If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
	Aviso("Aviso","Portador não Escolhido, Boleto não será impresso.",{"Abandona"},2)
	Return Nil
EndIf

SQL->(dbGoTop())
	cFileName := "Boleto_Instructure_" + AllTrim(  SQL->E1_NUM )
	oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.T.,0)
	oPrint:Setup()
	oPrint:SetPortrait()			// ou SetLandscape()
	oPrint:SetPaperSize(9)			// Seta para papel A4
	//oPrint:StartPage()				// Inicia uma nova pagina
	
ProcRegua(SQL->(RecCount()))
Do While SQL->(!EOF())

	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))

	//Posiciona o SA6 (Bancos)
	If Empty(SE1->E1_PORTADO)
		DbSelectArea("SA6")
		DbSetOrder(1)
		IF DbSeek(xFilial("SA6") + cBanco + cAgencia + cConta)
			RecLock("SE1",.F.)
			SE1->E1_PORTADO := SA6->A6_COD
			SE1->E1_AGEDEP  := SA6->A6_AGENCIA
			SE1->E1_CONTA   := SA6->A6_NUMCON
			MsUnLock()
		EndIf
	EndIf
	
	
	SQL->(DbSkip())
EndDo

Private nTipoBol    := 0

SQL->(dbGoTop())
ProcRegua(SQL->(RecCount()))
WHILE SQL->(!EOF())
	
	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))
    	
	If Empty(SE1->E1_PORTADO)
		//SE1->(DBSKIP())
		SQL->(DBSKIP())
		LOOP
	EndIf
	
	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	// Posiciona na Arq de Parametros CNAB
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+cSubConta,.T.)
	// Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	// Seleciona o SE1 (Contas a Receber)
	dbSelectArea("SE1")
	aDadosBanco := {"745",;													  //SA6->A6_COD [1]Numero do Banco
					"CITIBANK",;											  // [2]Nome do Banco
					SUBSTR(SA6->A6_AGENCIA,1,4),;							  // [3]Agencia
					SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),; // [4]Conta Corrente
					SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	  // [5]Digito da conta corrente                 
					"112"}													  // [6]Codigo da Carteira
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
	
		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))
		SEE->(DbGoTop())
		If DbSeek (xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta) 
			RecLock("SEE",.F.)
			cNroDoc			:= SubStr(AllTrim(SEE->EE_FAXATU),(LEN(AllTrim(SEE->EE_FAXATU))-10),LEN(AllTrim(SEE->EE_FAXATU)))		
			SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU))
			MsUnLock()

			//Calcula o digito verificador do nosso numero para impressao no E1_NUMBCO
			cDig := Alltrim(Mod11NN(AllTrim(cNroDoc))) //Digito verificador 
			cNroDoc	:= cNroDoc+cDig
			
			DbSelectArea("SE1")
			RecLock("SE1",.f.)
			SE1->E1_NUMBCO 	:= cNroDoc       
			SE1->E1_PORTADO := SA6->A6_COD
			SE1->E1_AGEDEP  := SA6->A6_AGENCIA
			SE1->E1_CONTA   := SA6->A6_NUMCON
			MsUnlock()   
		EndIf                                                                    			
	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)	
	EndIf 
	
	CB_RN_NN := Ret_cBarra(cBanco,cAgencia,cConta,aDadosBanco[5],cNroDoc,(E1_SALDO - _nVlrAbat-E1_DECRESC+E1_ACRESC),E1_VENCREA,aDadosBanco[6],cSubConta)
	
	aDadosTit := {	AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),;	  	 			// [1] Numero do Titulo
					SE1->E1_EMISSAO,;								 				// [2] Data da Emissao do Titulo
					Date(),;									  					// [3] Data da Emissao do Boleto
					SE1->E1_VENCREA,;								 		  		// [4] Data do Vencimento
					(SE1->E1_SALDO - _nVlrAbat-SE1->E1_DECRESC+SE1->E1_ACRESC),;	// [5] Valor do Titulo Liquido
					CB_RN_NN[3],;								 					// [6] Nosso Numero (Ver Formula para Calculo)
					SE1->E1_PREFIXO,;								 				// [7] Prefixo da NF
					SE1->E1_TIPO,;								   					// [8] Tipo do Titulo  
					SE1->E1_DECRESC,;                            	 				// [9] Desconto
					SE1->E1_ACRESC,;                              					//[10] Acrecimos  
					SE1->E1_SALDO}                                 					//[11] Valor do Titulo Bruto

		Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
		n := n + 1

	SQL->(dbSkip())
	SQL->(INCPROC())
	i := i + 1
ENDDO
oPrint:EndPage()	// Finaliza a Pagina.
oPrint:Preview()	// Visualiza antes de Imprimir.

SQL->(DbCloseArea())

RETURN nil
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
LOCAL _nLin    := -450//200
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
Local cSantLogo:="citi.bmp"

SET DATE FORMAT "dd/mm/yyyy"

// Parâmetros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont8  := TFont():New("Arial",9,09,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,18,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)
oPrint:StartPage()	// Inicia uma nova Pagina

oPrint:Line(_nLin+0710,0100,_nLin+0710,2300)
oPrint:Line(_nLin+0710,0560,_nLin+0610,0560)
oPrint:Line(_nLin+0710,0800,_nLin+0610,0800)
oPrint:SayBitmap(_nLin+0610,0100,cSantLogo,430,90 )
oPrint:Say (nSalto+_nLin+0652,0567,aDadosBanco[1]+"-5",oFont24)	// [1]Numero do Banco
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
oPrint:Say (nSalto+_nLin+0750,0100,"PAGÁVEL NA REDE BANCÁRIA ATÉ O VENCIMENTO",oFont8)
oPrint:Say (nSalto+_nLin+0710,1910,"Vencimento",oFont8)
oPrint:Say (nSalto+_nLin+0750,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+_nLin+0810,0100,"Beneficiário",oFont8)
oPrint:Say (nSalto+_nLin+0835,0100,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (nSalto+_nLin+0870,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (nSalto+_nLin+0810,1910,"Agência/Código Cedente",oFont8)
oPrint:Say (nSalto+_nLin+0850,1950,aDadosBanco[3]+"/"+cConta,oFont10)
oPrint:Say (nSalto+_nLin+0910,0100,"Data do Documento",oFont8)
oPrint:Say (nSalto+_nLin+0940,0100,DTOC(aDadosTit[2]),oFont10) // Emissao do Titulo (E1_EMISSAO)
oPrint:Say (nSalto+_nLin+0910,0505,"Nro.Documento",oFont8)
oPrint:Say (nSalto+_nLin+0940,0605,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela
oPrint:Say (nSalto+_nLin+0910,1005,"Espécie Doc.",oFont8)
oPrint:Say (nSalto+_nLin+0940,1050,"DMI",oFont10) //Tipo do Titulo
oPrint:Say (nSalto+_nLin+0910,1355,"Aceite",oFont8)
oPrint:Say (nSalto+_nLin+0940,1455,"N",oFont10)
oPrint:Say (nSalto+_nLin+0910,1555,"Data do Processamento",oFont8)
oPrint:Say (nSalto+_nLin+0940,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (nSalto+_nLin+0910,1910,"Nosso Número",oFont8)
oPrint:Say (nSalto+_nLin+0940,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),12,'0'),oFont10)
oPrint:Say (nSalto+_nLin+0980,0100,"Uso do Banco",oFont8)
oPrint:Say (nSalto+_nLin+1010,0100,"Cliente RCO",oFont10)
oPrint:Say (nSalto+_nLin+0980,0505,"Carteira",oFont8)
oPrint:Say (nSalto+_nLin+1010,0555,aDadosBanco[6],oFont10)
oPrint:Say (nSalto+_nLin+0980,0755,"Espécie",oFont8)
oPrint:Say (nSalto+_nLin+1010,0805,"R$",oFont10)
oPrint:Say (nSalto+_nLin+0980,1005,"Quantidade",oFont8)
oPrint:Say (nSalto+_nLin+0980,1555,"Valor",oFont8)
oPrint:Say (nSalto+_nLin+0980,1910,"Valor do Documento",oFont8)
oPrint:Say (nSalto+_nLin+1010,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+1050,0100,"Instruções (Instruções de responsabilidade do beneficiário. Qualquer dúvida sobre este boleto, contate o beneficiário)",oFont8)
oPrint:Say (nSalto+_nLin+1250,0100,aBolText[1],oFont10)
oPrint:Say (nSalto+_nLin+1050,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+1080,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+1120,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (nSalto+_nLin+1190,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (nSalto+_nLin+1260,1910,"(+)Outros Acréscimos",oFont8)
//oPrint:Say (nSalto+_nLin+1290,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+1330,1910,"(=)Valor Cobrado",oFont8)    
//oPrint:Say (nSalto+_nLin+1360,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+1400,0100,"Pagador",oFont8)
oPrint:Say (nSalto+_nLin+1430,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (nSalto+_nLin+1483,0400,aDatSacado[3],oFont10)
oPrint:Say (nSalto+_nLin+1536,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
oPrint:Say (nSalto+_nLin+1589,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
//oPrint:Say (nSalto+_nLin+1589,1950,SUBSTR(aDadosTit[6],1,3)+"/00"+SUBSTR(aDadosTit[6],4,8),oFont10)
//oPrint:Say (nSalto+_nLin+1589,1950,SUBSTR(aDadosTit[6],4,len(aDadosTit[6])-3),oFont10)
oPrint:Say (nSalto+_nLin+1605,0100,"Pagador/Avalista",oFont8)
oPrint:Say (nSalto+_nLin+1645,1500,"Autenticação Mecânica -",oFont8)
oPrint:Say (nSalto+_nLin+1645,1850,"Ficha de Compensação",oFont8)
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
oPrint:SayBitmap(_nLin+1900,0100,cSantLogo,430,90 )
oPrint:Say (nSalto+_nLin+1937,0567,aDadosBanco[1]+"-5",oFont24)	// [1] Numero do Banco
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
oPrint:Say (nSalto+_nLin+2040,0100,"PAGÁVEL NA REDE BANCÁRIA ATÉ O VENCIMENTO",oFont8)
oPrint:Say (nSalto+_nLin+2000,1910,"Vencimento",oFont8)
oPrint:Say (nSalto+_nLin+2040,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (nSalto+_nLin+2100,0100,"Beneficiário",oFont8)
oPrint:Say (nSalto+_nLin+2125,0100,aDadosEmp[1]+"             - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (nSalto+_nLin+2160,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (nSalto+_nLin+2100,1910,"Agência/Código Cedente",oFont8)
oPrint:Say (nSalto+_nLin+2140,1950,aDadosBanco[3]+"/"+cConta,oFont10)
oPrint:Say (nSalto+_nLin+2200,0100,"Data do Documento",oFont8)
oPrint:Say (nSalto+_nLin+2230,0100,DTOC(aDadosTit[2]),oFont10)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (nSalto+_nLin+2200,0505,"Nro.Documento",oFont8)
oPrint:Say (nSalto+_nLin+2230,0605,aDadosTit[7]+aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
oPrint:Say (nSalto+_nLin+2200,1005,"Espécie Doc.",oFont8)
oPrint:Say (nSalto+_nLin+2230,1050,"DMI",oFont10)					//Tipo do Titulo
oPrint:Say (nSalto+_nLin+2200,1355,"Aceite",oFont8)
oPrint:Say (nSalto+_nLin+2230,1455,"N",oFont10)
oPrint:Say (nSalto+_nLin+2200,1555,"Data do Processamento",oFont8)
oPrint:Say (nSalto+_nLin+2230,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (nSalto+_nLin+2200,1910,"Nosso Número",oFont8)
oPrint:Say (nSalto+_nLin+2230,1950,PADL(alltrim(SUBSTR(aDadosTit[6],4)),12,'0'),oFont10)
oPrint:Say (nSalto+_nLin+2270,0100,"Uso do Banco",oFont8)
oPrint:Say (nSalto+_nLin+2300,0100,"Cliente RCO",oFont10)
oPrint:Say (nSalto+_nLin+2270,0505,"Carteira",oFont8)
oPrint:Say (nSalto+_nLin+2300,0555,aDadosBanco[6],oFont10)
oPrint:Say (nSalto+_nLin+2270,0755,"Espécie",oFont8)
oPrint:Say (nSalto+_nLin+2300,0805,"R$",oFont10)
oPrint:Say (nSalto+_nLin+2270,1005,"Quantidade",oFont8)
oPrint:Say (nSalto+_nLin+2270,1555,"Valor",oFont8)
oPrint:Say (nSalto+_nLin+2270,1910,"Valor do Documento",oFont8)
oPrint:Say (nSalto+_nLin+2300,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2340,0100,"Instruções (Instruções de responsabilidade do beneficiário. Qualquer dúvida sobre este boleto, contate o beneficiário)",oFont8)
oPrint:Say (nSalto+_nLin+2540,0100,aBolText[1],oFont10)
oPrint:Say (nSalto+_nLin+2340,1910,"(-)Desconto/Abatimento",oFont8)
//oPrint:Say (nSalto+_nLin+2370,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2410,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (nSalto+_nLin+2480,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (nSalto+_nLin+2550,1910,"(+)Outros Acréscimos",oFont8)
//oPrint:Say (nSalto+_nLin+2580,1950,AllTrim(Transform(aDadosTit[10],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2620,1910,"(=)Valor Cobrado",oFont8)
//oPrint:Say (nSalto+_nLin+2650,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (nSalto+_nLin+2690,0100,"Pagador",oFont8)
oPrint:Say (nSalto+_nLin+2720,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (nSalto+_nLin+2773,0400,aDatSacado[3],oFont10)
oPrint:Say (nSalto+_nLin+2826,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
oPrint:Say (nSalto+_nLin+2879,0400,"C.N.P.J.: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)	// CGC
//oPrint:Say (nSalto+_nLin+2879,1950,SUBSTR(aDadosTit[6],1,3)+"/00"+SUBSTR(aDadosTit[6],4,8),oFont10)
//oPrint:Say (nSalto+_nLin+2879,1950,SUBSTR(aDadosTit[6],4,len(aDadosTit[6])-3),oFont10)
oPrint:Say (nSalto+_nLin+2895,0100,"Pagador/Avalista",oFont8)
oPrint:Say (nSalto+_nLin+2935,1500,"Autenticação Mecânica -",oFont8)
oPrint:Say (nSalto+_nLin+2935,1850,"Ficha de Compensação",oFont8)
oPrint:Line(_nLin+2000,1900,_nLin+2690,1900)
oPrint:Line(_nLin+2410,1900,_nLin+2410,2300)
oPrint:Line(_nLin+2480,1900,_nLin+2480,2300)
oPrint:Line(_nLin+2550,1900,_nLin+2550,2300)
oPrint:Line(_nLin+2620,1900,_nLin+2620,2300)
oPrint:Line(_nLin+2690,0100,_nLin+2690,2300)
oPrint:Line(_nLin+2930,0100,_nLin+2930,2300)

cFont:="Helvetica 65 Medium"
oPrint:FWMSBAR("INT25" /*cTypeBar*/,55.3/*nRow*/ ,3/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.95/*0.8*//*nHeigth*/,.F./*lBanner*/, cFont/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

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
*------------------------------*
STATIC FUNCTION Modulo10(cData) 
*------------------------------*

Local L,D,P := 0
Local B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := VAL(SUBSTR(cData, L, 1))
	If (B)
		P := P * 2
		IF P > 9
			P := P - 9
		EndIf
	EndIf
	D := D + P
	L := L - 1
	B := !B
EndDo
D := STR(10 - (Mod(D,10)))  
If D = "10"
	D := "0"
EndIf
RETURN(D)  

*-------------------------------*
Static Function CalcDig(cBase)
*-------------------------------*

Local _nDigito, _cDigito
Local _cMult := "1212121212"

_nDigito := 0
_nCbase  := Len(cBase)                
_nTam    := Len(_cMult) 
While _nCbase > 0 
	 _nSoma   := Val(Subs(cBase,_nCbase,1)) * Val(Subs(_cMult,_nTam,1))
	 _nDigito += Val(SubStr(StrZero(_nSoma,2),1,1))+Val(SubStr(StrZero(_nSoma,2),2,1))
    _nCbase -=1  
    _nTam   -=1
End          

_nDigito := 10 - (_nDigito % 10)	// Calcula Modulo 10
_cDigito := Alltrim (Str (_nDigito))  

If _cDigito == "10"
	_cDigito := "0"
EndIf

Return (_cDigito) 

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
*-----------------------------*
STATIC FUNCTION Mod11NN(cData) 
*-----------------------------*

Local L, D, P := 0

L := LEN(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	If P == 9
		P := 1
	EndIf
	L := L - 1
EndDo

D := (mod(D,11))

If (D == 0 .Or. D == 1)
	 D := "0" 

Else
	 D := STR(11 - D)	
EndIf 

RETURN(D)

*-------------------------------*
STATIC FUNCTION ModCod11(cData)
*-------------------------------*
Local L, D, P := 0

L := LEN(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	If P == 9
		P := 1
	EndIf
	L := L - 1
EndDo

D := (mod(D,11))

If (D == 0 .Or. D == 1)// .Or. D == 10 .or. D == 11)
	 D := "1" 

Else
	 D := STR(11 - D)	
EndIf 

Return(D)

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
*--------------------------------------------------------------------------------------------------*
STATIC FUNCTION Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cCarteira,cSubConta)
*--------------------------------------------------------------------------------------------------*

Local cConta 		:= StrTran(cConta,"-","")
Local cCarteira    	:= alltrim(cCarteira) 
Local _nVlrAbat    	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
Local nValor       	:= SE1->E1_SALDO - _nVlrAbat
Local blvalorfinal 	:= StrZero((nValor-SE1->E1_DECRESC+SE1->E1_ACRESC)*100,10)//Tratamento para o Acrescimo e Decrescimo
Local dvnn         	:= 0
Local dvcb         	:= 0 
Local dvld 			:= 0
Local dv			:= 0
Local NN           	:= ''
Local RN           	:= ''
Local CB           	:= ''
Local s            	:= ''
Local cMoeda       	:= "9"
Local cFator       	:= StrZero(dVencto - ctod("07/10/1997"),4)
Local snn			:= ''
Local cLinDig       := ''  

DbSelectArea("SEE")
SEE->(DbSetOrder(1))
SEE->(DbGoTop())
DbSeek (xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta) 
    
//-----------------------------
// Definicao do Nosso Numero
// ----------------------------
dvnn  := Alltrim(Mod11NN (SubStr(AllTrim(cNroDoc),1,11))) //Digito verificador  
cNN   := SubStr(AllTrim(cNroDoc),1,11) + dvnn 

//----------------------------------
//	Definição Linha Digitavel
//----------------------------------    

// 	CAMPO 1:
cCampo1  := cBanco + cMoeda + "3112" + SubStr(cConta,2,1)
cLinDig := ccampo1 + CalcDig(ccampo1)                                 

// 	CAMPO 2:
cCampo2  := SubStr(cConta,3,8) + SubStr(cNN,1,2)  
cLinDig += cCampo2 + CalcDig(cCampo2)
 

// 	CAMPO 3:
cCampo3 := SubStr(cNN,3,10)
cLinDig += cCampo3 + CalcDig(cCampo3 )

// Dac da linha digitavel
dvld := ModCod11(cBanco + cMoeda + cFator + blvalorfinal +"3112"+StrZero(Val(cConta),9)+cNN)//Modulo10(cCampo1+cCampo2+cCampo3)
cLinDig += AllTrim(dvld) + cFator + blvalorfinal  
                                                      
// -----------------------------                                         
// Definicao do Codigo de Barras
// -----------------------------
dvcb  := ModCod11(cBanco + cMoeda + cFator + blvalorfinal +"3112"+StrZero(Val(cConta),9)+cNN)
cCB   := cBanco + cMoeda + AllTrim(dvcb) + cFator + blvalorfinal +"3112"+StrZero(Val(cConta),9)+cNN

//------------------------------
//Montagem da linha  digitavel  
//------------------------------
cRN  :=Transform(cLinDig, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999")

Return({cCB,cRN,cNN})

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*---------------------------------------*
Static Function AjustaSX1(cPerg, aPergs)
*---------------------------------------*

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
*------------------------*
Static Function SELPORT()
*------------------------*

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
	cBanco		:= cGet1
	cAgencia	:= cGet2
	cConta 		:= cGet3
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Banco     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	Aviso("Aviso","Banco Inválido!!!",{"Retorna"})
	cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
	cGet3 	:= Space(TamSx3("A6_NUMCON")[1])
	oGet2:Refresh()
	oGet3:Refresh()
EndIf

Return lRetorno		
