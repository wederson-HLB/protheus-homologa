#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"
#INCLUDE "FWPrintSetup.ch"   
#INCLUDE "topconn.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE DS_MODALFRAME   128

/*
Funcao      : N7FIN001
Retorno     : 
Objetivos   : Impressao de Boleto Bancario do Banco Bradesco com Codigo de Barras, Linha Digitavel e Nosso Numero.
Autor       : Anderson Arrais
Data/Hora   : 10/08/2017 
TDN         : 
Empresa		: Globalenglish
M?dulo      : Financeiro.
*/ 

*-----------------------------------------*
 USER FUNCTION N7FIN001(lSelAuto,lPreview)  
*-----------------------------------------*

Local aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},;
						{"E1_PREFIXO","Prefixo","@!"},;
						{"E1_NUM","Titulo","@!"},;
						{"E1_PARCELA","Parcela","@!"},;
						{"E1_VALOR","Valor","@E 9,999,999.99"},;
						{"E1_VENCREA","Vencimento"}}
Local aPergs 		:= {}
Local lExec         := .T.
Local nOpc         	:= 0
Local aMarked      	:= {}
Local aDesc        	:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
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

Private Exec       	:= .F.
Private cIndexName 	:= ''
Private cIndexKey  	:= ''
Private cFilter    	:= ''

Tamanho  := "M"
titulo   := "Impressao de Boleto Bradesco"
cDesc1   := "Este programa destina-se a impressao do Boleto Bradesco."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "N7FIN001"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
dbSelectArea("SE1")

if !lSelAuto

	cPerg     :="N7FIN001"
	
	Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	AjustaSx1("N7FIN001",aPergs)
	
	SET DATE FORMAT "dd/mm/yyyy"
	
	
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
	alert("N?o h? dados com esses par?metros!")
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
		Aviso("Aviso", 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao ser? gerado.',{"Abandona"},2 ) 
	Else	
		Aviso("Aviso","N?o existe informa??es.",{"Abandona"},2)	
    EndIf    
Endif

Return( cFileRet )
                                        
*------------------------------------------*
STATIC FUNCTION MontaRel(lSelAuto,lPreview) 
*------------------------------------------*
Local oPrint
Local n         := 0

Local aDadosEmp := {SM0->M0_NOMECOM,;																	//[1]Nome da Empresa
						SM0->M0_ENDCOB,; 																//[2]Endere?o
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;	//[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 				//[4]CEP
						"PABX/FAX: "+SM0->M0_TEL,; 														//[5]Telefones
						"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;				//[6]CGC
						Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;							//[6]CGC
						Subs(SM0->M0_CGC,13,2),;														//[6]CGC
						"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;				//[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}								//[7]I.E
						
Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local aBolText  	:= {"Ap?s o vencimento cobrar multa de R$ ",;
						"Mora Diaria de R$ ",;
						"TITULO SUJEITO A PROTESTO 30 DIAS AP?S O VENCIMENTO"}

Local i         	:= 1
Local CB_RN_NN  	:= {}
Local nRec      	:= 0
Local _nVlrAbat 	:= 0
Local n, nI     	:= 0
Local _nRecSE1  	:= 0
Local cFileName 	:= "Boleto_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)
Local cFile    		:= ""
Local cLocal  		:= GetTempPath()
Local cDirBol 		:= "\FTP\" + cEmpAnt + "\N7FIN001\"
Local cNroDoc  		:= ""    

Private aBMP	    := {	"LOGO237.BMP",;	// Banner Publicitario Bradesco
					    	"LGRL.bmp"}		// Logo da Empresa

Private cPortGrv	:= ""
Private cAgeGrv		:= ""
Private cContaGrv	:= ""
Private cQry		:= ""
Private aCols		:= {}
Private aAuxAcols	:= {}

If !LisDir( cDirBol )
	MakeDir( "\FTP" )
	MakeDir( "\FTP\" + cEmpAnt )	
	MakeDir( "\FTP\" + cEmpAnt + "\N7FIN001\" )		
EndIf	

if !lSelAuto
	oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T./*.F.*/,,.T.,.F.,,,,,,.T.,0)
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




dbSelectArea ("SE1")
DbGotop()
ProcRegua(RecCount())
DbSetOrder(1)
DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)

While !EOF() .AND. xFilial("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == MV_PAR01 .AND. SE1->E1_NUM <= Mv_Par03
	If !SE1->E1_TIPO $ "NF /DP "
		SE1->(dbSkip())
		Loop
	Endif 
	
	If ( SE1->E1_SALDO == 0 )
		MsgStop( 'Titulo ' + SE1->E1_NUM  + If( !Empty( SE1->E1_PARCELA ) , '-Parcela ' + SE1->E1_PARCELA , '' ) + ' sem saldo. Boleto nao ser? gerado.' ) 
		SE1->(dbSkip())
		Loop
	Endif	


	If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
		
		If Alltrim(SM0->M0_CODIGO) $ "N7" //GlobalEnglish
			cBanco    := "237"
			cAgencia  := "0105 "
			cConta    := "2171511  "
			cSubConta := "002"
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
	
	cPortGrv    := SE1->E1_PORTADO
	cAgeGrv     := SE1->E1_AGEDEP
	cContaGrv   := SE1->E1_CONTA
	cSubConta   := If(Empty(cSubConta),"002",cSubConta)
	
	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta,.T.)
	
	aDadosBanco := {SA6->A6_COD ,;												// [1]Numero do Banco
					"Bradesco",;	    									    // [2]Nome do Banco
					SUBSTR(SA6->A6_AGENCIA,1,4),;								// [3]Agencia
					SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
					SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	    // [5]Digito da conta corrente
					SA6->A6_CARTEIR}     										// [6]Codigo da Carteira
					
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
		cNroDoc 	:= SUBSTR(NOSSONUM(),2,11)
		cCart		:="09"
		nB7			:=2
		nSoma		:=0
		cCartNN		:=alltrim(cCart)+alltrim(cNroDoc)
		
		for i:=len(cCartNN) to 1 STEP -1
			
			if nB7==8
				nB7:=2
			endif
			nSoma+= (val(substr(cCartNN,i,1)) * nB7)
			nB7++
		next

		_RESTO  := INT(nSoma % 11)

		_DIGITO := 11 - _RESTO
		
		if _DIGITO==11 
			_RETDIG :="0"
		elseif _DIGITO==10 
			_RETDIG :="P"
		else
			_RETDIG :=alltrim(STR(_DIGITO))
		endif
		
		cNroDoc+=_RETDIG
		
		DbSelectArea("SE1")
		RecLock("SE1",.f.)
			SE1->E1_NUMBCO 	:=	cNroDoc// Nosso n?mero (Ver f?rmula para calculo)
		MsUnlock()

	Else
		cNroDoc   	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf	
	nSaldo 	 := (E1_SALDO - _nVlrAbat-E1_DECRESC+E1_ACRESC)
	CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,nSaldo,E1_VENCREA,aDadosBanco[6])
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;	  		// [1] Numero do Titulo
					E1_EMISSAO,;						      		// [2] Data da Emissao do Titulo
					Date(),;							      		// [3] Data da Emissao do Boleto
					E1_VENCREA,;							  		// [4] Data do Vencimento
					nSaldo,;   										// [5] Valor do Titulo
					CB_RN_NN[3],;	                   		      	// [6] Nosso Numero (Ver Formula para Calculo)
					E1_PREFIXO,;					   		   	 	// [7] Prefixo da NF
					E1_TIPO,;						  				// [8] Tipo do Titulo
					SE1->E1_DECRESC,;		    		            // [9] Decrescimo    
					SE1->E1_ACRESC}				                    // [10] Acrescimo
					
	IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM)
	
	Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
	n := n + 1

	DbSelectArea("SE1")
	SE1->(dbSkip())
	IncProc()
	
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
		MsgStop( 'Erro na copia para o servidor, boleto ' + cFileName+  ".pdf" )
	EndIf
EndIf


RETURN (cFile) 

*------------------------------------------------------------------------------------------------*
STATIC FUNCTION Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN) 
*------------------------------------------------------------------------------------------------*
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont18
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
oFont18 := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)

oPrint:StartPage()	// Inicia uma nova Pagina

_nLin2 := 20
// Inicia aqui a alteracao para novo layout - RAI
oPrint:Line(0150,0560,0050,0560)
oPrint:Line(0150,0800,0050,0800)
oPrint:SayBitmap(0050,0100,aBmp[1],430,90 )
oPrint:Say (0062+_nLin2+20,0567,aDadosBanco[1]+"-2",oFont24)			// [1] Numero do Banco
oPrint:Say (0084+_nLin2,1870,"Comprovante de Entrega",oFont10)
oPrint:Line(0150,0100,0150,2300)
oPrint:Say (0150+_nLin2,0100,"Benefici?rio",oFont8)
oPrint:Say (0200+_nLin2,0100,aDadosEmp[1]	,oFont10)				// [1] Nome + CNPJ
oPrint:Say (0150+_nLin2,1060,"Ag?ncia/C?digo Benefici?rio",oFont8)
oPrint:Say (0200+_nLin2,1060,aDadosBanco[3]+"/"+Strzero(val(aDadosBanco[4]),7)+"-"+aDadosBanco[5],oFont10)
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
oPrint:Say (_nLin+_nLin2+0652,0567,aDadosBanco[1]+"-2",oFont24)	// [1]Numero do Banco
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
oPrint:Say (_nLin+_nLin2+0750,0100,"Pag?vel preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)
//oPrint:Say (_nLin+_nLin2+0775,0100,"APOS O VENCIMENTO, PAGUE SOMENTE NO Bradesco,oFont8)
oPrint:Say (_nLin+_nLin2+0710,1910,"Vencimento",oFont8)
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+0750,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+0810,0100,"Benefici?rio",oFont8)
//oPrint:Say (_nLin+0850,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+_nLin2+0835,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+_nLin2+0870,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (_nLin+_nLin2+0810,1910,"Ag?ncia/C?digo Benefici?rio",oFont8)
cString   := aDadosBanco[3]+"/"+Strzero(val(aDadosBanco[4]),7)+"-"+aDadosBanco[5]
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
oPrint:Say (_nLin+_nLin2+0910,1910,"Carteira / Nosso N?mero",oFont8) 
oPrint:Say (_nLin+_nLin2+0940,1960,aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],3),oFont10)
//cString   := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],3)
//nCol   	  := 1900+(374-(len(cString)*22))
//oPrint:Say (_nLin+_nLin2+0940,nCol,cString,oFont10)
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
//oPrint:Say (_nLin+_nLin2+1150,0100,aBolText[1],oFont10) 
//oPrint:Say (_nLin+_nLin2+1200,0100,aBolText[2],oFont10)
//oPrint:Say (_nLin+_nLin2+1250,0100,aBolText[3],oFont10)
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
oPrint:Say (_nLin+_nLin2+1589,1950,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],3),oFont10)
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
oPrint:Say (_nLin+_nLin2+1932,0567,aDadosBanco[1]+"-2",oFont24)// [1] Numero do Banco
oPrint:Say (_nLin+_nLin2+1934,0820,CB_RN_NN[2],oFont18)		// [2] Linha Digitavel do Codigo de Barras
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
oPrint:Say (_nLin+_nLin2+2040,0100,"Pag?vel preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)
//oPrint:Say (_nLin+_nLin2+2065,0100,"APOS O VENCIMENTO, PAGUE SOMENTE NO ",oFont8)
oPrint:Say (_nLin+_nLin2+2000,1910,"Vencimento",oFont8)
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+_nLin2+2040,nCol,cString,oFont10)
oPrint:Say (_nLin+_nLin2+2100,0100,"Benefici?rio",oFont8)
oPrint:Say (_nLin+_nLin2+2125,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+_nLin2+2160,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //End
oPrint:Say (_nLin+_nLin2+2100,1910,"Ag?ncia/C?digo Benefici?rio",oFont8)
cString   := aDadosBanco[3]+"/"+Strzero(val(aDadosBanco[4]),7)+"-"+aDadosBanco[5]
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
oPrint:Say (_nLin+_nLin2+2200,1910,"Carteira / Nosso N?mero",oFont8)
oPrint:Say (_nLin+_nLin2+2230,1960,aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],3),oFont10)
//cString   := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],3)
//nCol   	  := 1900+(374-(len(cString)*22))
//oPrint:Say (_nLin+_nLin2+2230,nCol,cString,oFont10)
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
//oPrint:Say (_nLin+_nLin2+2440,0100,aBolText[1],oFont10)
//oPrint:Say (_nLin+_nLin2+2490,0100,aBolText[2],oFont10)
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
oPrint:Say (_nLin+_nLin2+2879,1950,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],3),oFont10)
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

/*/
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????Ŀ??
??? Funcao    ? MODULO10()  ? Autor ? Flavio Novaes    ? Data ? 03/02/2005 ???
??????????????????????????????????????????????????????????????????????????Ĵ??
??? Descricao ? Impressao de Boleto Bancario do Banco Bradesco com Codigo ???
???           ? de Barras, Linha Digitavel e Nosso Numero.                 ???
???           ? Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.???
??????????????????????????????????????????????????????????????????????????Ĵ??
??? Uso       ? FINANCEIRO                                                 ???
???????????????????????????????????????????????????????????????????????????ٱ?
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
/*/
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
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????Ŀ??
??? Funcao    ? MODULO11()  ? Autor ? Flavio Novaes    ? Data ? 03/02/2005 ???
??????????????????????????????????????????????????????????????????????????Ĵ??
??? Descricao ? Impressao de Boleto Bancario do Banco Bradesco com Codigo ???
???           ? de Barras, Linha Digitavel e Nosso Numero.                 ???
???           ? Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.???
??????????????????????????????????????????????????????????????????????????Ĵ??
??? Uso       ? FINANCEIRO                                                 ???
???????????????????????????????????????????????????????????????????????????ٱ?
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
/*/
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
	IF P = 9
		P := 1
	ENDIF
	L := L - 1
ENDDO
D := 11 - (mod(D,11))
IF (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
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
*-------------------------------------------------------------------------------*
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto) 
*-------------------------------------------------------------------------------*

LOCAL cValorFinal 	:= strzero((nValor*100),10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator      	:= Strzero(dVencto - ctod("07/10/97"),4)
LOCAL cCart			:= "09"
LOCAL cMoeda	    := "9"
//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
cS    :=  cCart + substr(alltrim(cNroDoc),1,len(alltrim(cNroDoc))-1) //19 001000012
nDvnn := modulo11(cS) // digito verifacador
cNNSD := cS //Nosso Numero sem digito
cNN   := cCart + substr(alltrim(cNroDoc),1,len(alltrim(cNroDoc))-1)+ '-' + substr(alltrim(cNroDoc),len(alltrim(cNroDoc)),1)
//----------------------------------
//	 campo livre do c?digo de barras
//----------------------------------
cLivre 	:= Strzero(Val(cAgencia),4)+ cCart + SUBSTR(cNNSD,3,LEN(cNNSD)-2) + Strzero(Val(cConta),7) + "0"

cS		:= cBanco + cMoeda + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
nDvcb 	:= modulo11(cS)
cCB   	:= SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		DDDDD.DDDDDY	FFFFF.FFFFFZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := cBanco + cMoeda + Substr(cLivre,1,5)
nDv   := Mod102(cS) //1?DAC
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 2:
//	DDDDDDDDDD = Posi??o 6 a 15 do Nosso Numero
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS 	:= Subs(cLivre,6,10)
nDv	:= Mod102(cS) //2? DAC
cRN	+= Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

// 	CAMPO 3:
//	FFFFFFFFFF = Posi??o 16 a 25 do Nosso Numero
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS 	:=Subs(cLivre,16,10)
nDv	:= Mod102(cS) //3? DAC
cRN	+= Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN  += cFator + StrZero((nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})

/*/
?????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????Ŀ??
???Fun??o    ? AjustaSx1    ? Autor ? Microsiga            	? Data ? 13/10/03 ???
?????????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ? Verifica/cria SX1 a partir de matriz para verificacao          ???
?????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Especifico para Clientes Microsiga                    	  		???
??????????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????????
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

*----------------------------*
Static function Mod102(cData) 
*----------------------------*

Local nBin:=2        
Local nNum:=0
Local nTot:=0
Local nBase10:=0
Local nDig:=0

	for i:=len(alltrim(cData)) to 1 STEP -1
		nNum:=val(substr(alltrim(cData),i,1))*nBin
        	if len(alltrim(str(nNum)))>1
        		for j:=1 to len(alltrim(str(nNum)))
        			nTot+=val(substr(alltrim(str(nNum)),j,1))
        		next
        	else
        		nTot+=nNum
        	endif 
        	
		nBin:=(nBin%2)+1
	next
    
    if nTot%10==0
    	nBase10:= nTot
    else
		nBase10:= ABS((nTot%10)-10)+nTot
    endif
    
	nDig:=nBase10-nTot

Return(nDig)
