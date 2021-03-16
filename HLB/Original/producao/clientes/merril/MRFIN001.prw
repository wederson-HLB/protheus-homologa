#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"  
#INCLUDE "topconn.ch"     

/*----------------------------------------------------------------------------------------------------------------------------------*
Funcao      : MRFIN001                                                                                                      
Parametros  :                                                                                                        
Retorno     : 
Objetivos   : Impressao de Boleto Bancario do Banco Itau  com Codigode Barras, Linha Digitavel e Nosso Numero.
Autor       : João Silva
TDN         : 
Revisão     : 
Data/Hora   : 18/03/2014
Módulo      : Financeiro.
*-----------------------------------------------------------------------------------------------------------------------------------*/    

*--------------------------------*
USER FUNCTION MRFIN001(lSelAuto )    
*--------------------------------*     
 
Local aPergs			:= {}   
Local aAreaAnt			:= GetArea()       

Private cBanco			:= ''
Private cAgencia		:= ''
Private cConta			:= ''
Private cSubConta		:= ''

DEFAULT lSelAuto		:=.F.

cString  := "SE1"

//Parametros para impressão.
If !lSelAuto

	cPerg		:="PMRFIN002"
	
	Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Diretorio" ,"","","mv_ch4","C",50,0,0,"G","","MV_PAR04","","","","c:\","","","","","","","","","","","","","","","","","","","","","","","","",""})

	AjustaSx1("PMRFIN002",aPergs)
	
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF

EndIf    

	Processa({|lEnd|MontaRel(lSelAuto)}) 
//	MontaRel(lSelAuto)   

RestArea(aAreaAnt)  
Return Nil


/*----------------------------------------------------------------------------------------------------------------------------------*
Funcao      : MONTAREL(lSelAuto )                                                                                                       
Parametros  : lSelAuto                                                                                                       
Retorno     : Nil
Objetivos   : Monta a estrutura da Impressao de Boleto Bancario do Banco Itau  com Codigode Barras, Linha Digitavel e Nosso Numero.
Autor       : João Silva
TDN         : 
Revisão     : 
Data/Hora   : 18/03/2014
Módulo      : Financeiro.
*-----------------------------------------------------------------------------------------------------------------------------------*/ 

*--------------------------------*
STATIC FUNCTION MontaRel(lSelAuto)
*--------------------------------*
Local aDadosEmp			:= {}
Local aDadosTit
Local aDadosBanco
Local aDadosSacado 
Local n, nI				:= 0   
Local CNRODOC			:= ""  
Local aBolText			:= {"Após o vencimento cobrar multa de R$ ",;
							"Mora Diaria de R$ "}
Private oFont8  := TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont8n := TFont():New("Arial",9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont10 := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont10n:= TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont14n:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16n:= TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont20 := TFont():New("Arial",9,20,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont24n:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Private oBrush  := TBrush():New("",RGB(220,220,220))

Private oPrinter
Private lAdjustToLegacy	:= .F.
Private lDisableSetup		:= .T.
Private cLocal          	:= alltrim(MV_PAR04)
Private cLogoBol			:= "LOGO341.bmp"

Private cPortGrv		:= ""
Private cAgeGrv			:= ""
Private cContaGrv		:= ""
Private cQry			:= ""
  		

	 // Carrega variavel com os dados da empresa logada.			   		
	 aDadosEmp := { AllTrim (SM0->M0_NOMECOM),;												  		//[1]Nome da Empresa
					AllTrim (SM0->M0_ENDCOB),;														//[2]Endereço
					AllTrim (SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;   //[3]Complemento
					"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			    //[4]CEP
					"PABX/FAX: "+SM0->M0_TEL,; 														//[5]Telefones
					"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;		     	//[6]
					Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;							//[6]
					Subs(SM0->M0_CGC,13,2),;														//[6]CGC
					"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;				//[7]
					Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}						     	//[7]I.E  	
                    
             
								
DbSelectArea ("SE1")
DbGotop()
ProcRegua(RecCount())
DbSetOrder(1)
DbSeek(xFilial("SE1")+MV_PAR01+MV_PAR02,.T.)
While  xFilial("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == MV_PAR01 .AND. SE1->E1_NUM <= MV_PAR03
	oPrinter:= FWMSPrinter():New("Boleto da NF "+ALLTRIM(SE1->E1_NUM),6,.F.,,.T.)//,,,,,,,.F.)
	//oPrinter:SetPaperSize(9)//9 - A4     210mm x 297mm  620 x 876
	oPrinter:cPathPDF := cLocal
	oPrinter:SetPortrait()
	oPrinter:StartPage() 
	If !SE1->E1_TIPO $"NF /DP "
		SE1->(DbSkip())
		Loop	 			   		
	EndIf 

	If Empty(cBanco) .OR. Empty(cAgencia) .OR. Empty(cConta)   
	
		If  Alltrim(SM0->M0_CODIGO)=="MR"    // teste
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "93010-7   "
			cSubConta := "001"	
		Else
		   Msginfo("Rotina não implementada para esta empresa!","HLB BRASIL")
	   	EndIf
	
	EndIf
		   
	// Verifica qual é a subconta de remessa    
	cQry:=" SELECT EE_SUBCTA FROM "+RETSQLNAME("SEE")
	cQry+=" WHERE EE_FILIAL='"+xFilial("SEE")+"' AND D_E_L_E_T_=''"
	cQry+=" AND EE_CODIGO='"+cBanco+"'"
	cQry+=" AND EE_AGENCIA='"+cAgencia+"'"
	cQry+=" AND EE_CONTA='"+cConta+"'"
	cQry+=" AND (EE_OPER LIKE '%REM%' OR EE_EXTEN = 'REM')"
    
	If Select("QUERYTRB")>0
		QUERYTRB->(DbCloseArea())
	EndIf
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QUERYTRB",.T.,.T.)

	COUNT TO nRecCount
	
	If  nRecCount>0
		QUERYTRB->(DbGotop())
		cSubConta:=QUERYTRB->EE_SUBCTA
    Else
        SE1->(DbSkip())
        Loop		
	EndIf

	cPortGrv    := SE1->E1_PORTADO
	cAgeGrv     := SE1->E1_AGEDEP
	cContaGrv   := SE1->E1_CONTA
	cSubConta   := If(Empty(cSubConta),"001",cSubConta)

	// Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta,.T.)

	aDadosBanco := {SA6->A6_COD ,;												// [1]Numero do Banco
	"BANCO ITAU",;					   						    				// [2]Nome do Banco
	SUBSTR(SA6->A6_AGENCIA,1,4),;							   					// [3]Agencia
	SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(StrTran(SA6->A6_NUMCON,"-","")))-1),;	// [4]Conta Corrente
	SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	    				// [5]Digito da conta corrente
	SA6->A6_CARTEIR}     														// [6]Codigo da Carteira

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
			aDatSacado := {	AllTrim(SA1->A1_NOME),;				// [1]Razao Social
			AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;				// [2]Codigo
			AllTrim(SA1->A1_END)+" - "+AllTrim(SA1->A1_BAIRRO),;// [3]Endereco
			AllTrim(SA1->A1_MUN),;								// [4]Cidade
			SA1->A1_EST,;										// [5]Estado
			SA1->A1_CEP,;										// [6]CEP
			SA1->A1_CGC}										// [7]CGC		
    
	DbSelectArea("SE1")
	
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	
	DbSelectArea("SE1")
	_nRecSE1  := recno()                                                

	If Empty(SE1->E1_NUMBCO)
		DbSelectArea("SEE")
		DbSetOrder(1)
		DbGoTop()
		If DbSeek (xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+cConta+cSubConta) 
			RecLock("SEE",.F.)
			cNroDoc			:= SUBSTR(AllTrim (SEE->EE_FAXATU),(LEN(AllTrim(SEE->EE_FAXATU))-7),8)
			SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU))
			MsUnLock()
		EndIf
		
		DbSelectArea("SE1")
		RecLock("SE1",.f.)
		SE1->E1_NUMBCO 	:= cNroDoc       
		SE1->E1_PORTADO := SA6->A6_COD
		SE1->E1_AGEDEP  := SA6->A6_AGENCIA
		SE1->E1_CONTA   := SA6->A6_NUMCON
		MsUnlock()
	
	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	
	EndIf
	DbSelectArea("SE1")
	DbGoTo(_nRecSE1)
	
	CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,(E1_VALOR-_nVlrAbat),E1_VENCREA,aDadosBanco[6])
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;	        // [1] Numero do Titulo
					E1_EMISSAO,;		                			// [2] Data da Emissao do Titulo
					Date(),;				                		// [3] Data da Emissao do Boleto
					E1_VENCREA,;						            // [4] Data do Vencimento
					(E1_SALDO - _nVlrAbat),;	                	// [5] Valor do Titulo
					CB_RN_NN[3],;									// [6] Nosso Numero (Ver Formula para Calculo)
					E1_PREFIXO,;									// [7] Prefixo da NF
					E1_TIPO}										// [8] Tipo do Titulo   
	
	IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM) 
	
	// Função que é responsavel pela criação do layout do boleto
	Impress(aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)   
	
	oPrinter:EndPage()                             
	oPrinter:Print()
	DbSelectArea("SE1")
	SE1->(dbSkip())
	IncProc()
	    
EndDo

Return 
	
/*----------------------------------------------------------------------------------------------------------------------------------*
Funcao      : Impress()                                                                                                       
Parametros  : oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN                                                                                                       
Retorno     : Nil
Objetivos   : Desenha o layout da estrutura do Boleto Bancario do Banco Itau com Codigode Barras, Linha Digitavel e Nosso Numero.
Autor       : João Silva
TDN         : 
Revisão     : 
Data/Hora   : 18/03/2014
Módulo      : Financeiro.
*-----------------------------------------------------------------------------------------------------------------------------------*/ 									   				  

*---------------------------------------------------------------------------------------------------*
STATIC FUNCTION Impress(aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
*---------------------------------------------------------------------------------------------------*
Local cProtesto			:= ""
Local nValor   			:= aDadosTit[5]-SE1->E1_DECRESC+SE1->E1_ACRESC  

	If SE1->(FieldPos("E1_P_MSGBO")) > 0
		cProtesto:= AllTrim(SE1->E1_P_MSGBO)
	EndIf

//1º Bloco 
oPrinter:Line(  35,  25,  35, 555)  						//Linha horizontal 1
oPrinter:Line(  60,  25,  60, 450)							//Linha horizontal 2
oPrinter:Line(  85,  25,  85, 450)							//Linha horizontal 3
oPrinter:Line( 110, 253, 110, 450)							//Linha horizontal 4
oPrinter:Line( 135,  25, 135, 555)							//Linha horizontal 5 

oPrinter:Line(  10, 140,  35, 140)							//Linha vertical 1 
oPrinter:Line(  10, 200,  35, 200)						    //Linha vertical 2 
oPrinter:Line(  35, 253, 135, 253)							//Linha vertical 3
oPrinter:Line(  85, 330, 135, 330)							//Linha vertical 4
oPrinter:Line(  35, 353,  85, 353)							//Linha vertical 5
oPrinter:Line(  35, 450, 135, 450)							//Linha vertical 6 

oPrinter:SayBitmap(  10,  10,cLogoBol,40,24 )			   	//Logo do banco 
oPrinter:Say (  30,  50,aDadosBanco[2], oFont16n)			//Nome do banco
oPrinter:Say (  30, 145,aDadosBanco[1]+"-7",oFont24n)		//Numero do banco
oPrinter:Say (  30, 450,"Comprovante de Entrega",oFont12n)  
oPrinter:Say (  43,  25,"Beneficiário",oFont8)    
oPrinter:Say (  55,  25,aDadosEmp[1],oFont10n) 				//Nome do beneficiario
oPrinter:Say (  43, 255,"Agência/Código Beneficiário",oFont8)
oPrinter:Say (  55, 255,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10n) //Numero de agencia e conta do beneficiario
oPrinter:Say (  43, 355,"Nro.Documento",oFont8) 
oPrinter:Say (  55, 355,aDadosTit[7]+""+ aDadosTit[1],oFont10n)//Prefixo + Numero + Parcela
oPrinter:Say (  68,  25,"Pagador",oFont8)
oPrinter:Say (  80,  25,aDatSacado[1],oFont10n)				//Nome do pagador
oPrinter:Say (  68, 255,"Vencimento",oFont8)
oPrinter:Say (  80, 255,STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4),oFont10n)// Data do vencimento
oPrinter:Say (  68, 355,"Valor do Documento",oFont8)
oPrinter:Say (  80, 355,AllTrim(Transform(nValor,"@E 999,999,999.99")),oFont10n)//Valor a ser pago  
oPrinter:Say ( 100,  25,"Recebi(emos) o bloqueto/título",oFont10n)
oPrinter:Say ( 110,  25,"com as características acima.",oFont10n)
oPrinter:Say (  93, 255,"Data",oFont8)
oPrinter:Say (  93, 332,"Assinatura",oFont8)
oPrinter:Say ( 118, 255,"Data",oFont8)
oPrinter:Say ( 118, 332,"Entregador",oFont8) 
oPrinter:Say (  43, 452,"(  )Mudou-se",oFont8)
oPrinter:Say (  54, 452,"(  )Ausente",oFont8)
oPrinter:Say (  65, 452,"(  )Não existe nº indicado",oFont8)
oPrinter:Say (  76, 452,"(  )Recusado",oFont8)
oPrinter:Say (  87, 452,"(  )Não procurado",oFont8)
oPrinter:Say (  98, 452,"(  )Endereço insuficiente",oFont8)
oPrinter:Say ( 110, 452,"(  )Desconhecido",oFont8)
oPrinter:Say ( 121, 452,"(  )Falecido",oFont8)
oPrinter:Say ( 132, 452,"(  )Outros(anotar no verso)",oFont8)   

FOR i := 25 TO 555 STEP 5
	oPrinter:Line( 185,i,185,i+3)				//Linha pontilhada
NEXT i


//2º Bloco
oPrinter:Line( 220,  25, 220, 555)  						//Linha horizontal 1
oPrinter:Line( 245,  25, 245, 555)							//Linha horizontal 2
oPrinter:Line( 270,  25, 270, 555)							//Linha horizontal 3
oPrinter:Line( 290,  25, 290, 555)							//Linha horizontal 4
oPrinter:Line( 310,  25, 310, 555)							//Linha horizontal 5
oPrinter:Line( 330, 450, 330, 555)							//Linha horizontal 6
oPrinter:Line( 350, 450, 350, 555)							//Linha horizontal 7
oPrinter:Line( 370, 450, 370, 555)							//Linha horizontal 8
oPrinter:Line( 390, 450, 390, 555)							//Linha horizontal 9
oPrinter:Line( 410,  25, 410, 555)							//Linha horizontal 10 
oPrinter:Line( 460,  25, 460, 555)							//Linha horizontal 11 

oPrinter:Line( 195, 140, 220, 140)							//Linha vertical 1 
oPrinter:Line( 195, 200, 220, 200)						    //Linha vertical 2 
oPrinter:Line( 270, 120, 310, 120)							//Linha vertical 3
oPrinter:Line( 290, 180, 310, 180)							//Linha vertical 4
oPrinter:Line( 270, 240, 310, 240)							//Linha vertical 5 
oPrinter:Line( 270, 320, 290, 320)							//Linha vertical 6
oPrinter:Line( 270, 360, 310, 360)							//Linha vertical 7
oPrinter:Line( 220, 450, 410, 450)							//Linha vertical 8 


oPrinter:SayBitmap( 195,  10,cLogoBol,40,24 )			   	//Logo do banco 
oPrinter:Say ( 215,  50,aDadosBanco[2], oFont16n)			//Nome do banco
oPrinter:Say ( 215, 145,aDadosBanco[1]+"-7",oFont24n)		//Numero do banco
oPrinter:Say ( 215, 450,"Recibo do Pagador",oFont12n)
oPrinter:Say ( 228,  25,"Local de Pagamento",oFont8)
oPrinter:Say ( 236,  25,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU",oFont8)
oPrinter:Say ( 244,  25,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont8)
oPrinter:Say ( 228, 452,"Vencimento",oFont8)
cString :=STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	:=	 (555-(len(cString)*5))
oPrinter:Say (240,nCol,cString,oFont10n)//Data de Vencimento
oPrinter:Say ( 253,  25,"Beneficiário",oFont8)
oPrinter:Say ( 265,  25,aDadosEmp[1]+"   -   "+aDadosEmp[6],oFont10n) //Nome do beneficiario e CNPJ
oPrinter:Say ( 253, 452,"Agência/Código Beneficiário",oFont8)
cString := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol   	:= (555-(len(cString)*5))
oPrinter:Say (265,nCol,cString,oFont10n)
oPrinter:Say ( 278,  25,"Data do Documento",oFont8)
oPrinter:Say ( 288,  25,STRZERO(day(aDadosTit[2],2),2)+"/"+STRZERO(month(aDadosTit[2],2),2)+"/"+STRZERO(year(aDadosTit[2],4),4),oFont10n) // Data da emissao do Titulo
oPrinter:Say ( 278, 122,"Nro.Documento",oFont8)
oPrinter:Say ( 288, 122,aDadosTit[7]+" "+aDadosTit[1],oFont10n) //Prefixo +Numero+Parcela
oPrinter:Say ( 278, 242,"Espécie Doc.",oFont8)
oPrinter:Say ( 288, 242,aDadosTit[8],oFont10n) //Tipo do Titulo
oPrinter:Say ( 278, 322,"Aceite",oFont8)
oPrinter:Say ( 288, 330,"N",oFont10n)
oPrinter:Say ( 278, 362,"Data do Processamento",oFont8)
oPrinter:Say ( 288, 372,STRZERO(DAY(aDadosTit[3],2),2)+"/"+STRZERO(MONTH(aDadosTit[3],2),2)+"/"+STRZERO(YEAR(aDadosTit[3],2),4),oFont10n) // Data impressao
oPrinter:Say ( 278, 452,"Nosso Número",oFont8)
cString := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1)
nCol   	:= (555-(len(cString)*5))
oPrinter:Say ( 288,nCol,cString,oFont10n)
oPrinter:Say ( 298,  25,"Uso do Banco",oFont8)
oPrinter:Say ( 298, 122,"Carteira",oFont8)
oPrinter:Say ( 308, 132,aDadosBanco[6],oFont10n) //Numero da carteira
oPrinter:Say ( 298, 182,"Espécie",oFont8)
oPrinter:Say ( 308, 192,"R$",oFont10n)
oPrinter:Say ( 298, 242,"Quantidade",oFont8)
oPrinter:Say ( 298, 362,"Valor",oFont8)
oPrinter:Say ( 298, 452,"Valor do Documento",oFont8)
cString := AllTrim(Transform(nValor,"@E 999,999,999.99"))
nCol   	:= (555-(len(cString)*5))
oPrinter:Say ( 308,nCol,cString,oFont10n)
oPrinter:Say ( 318,  25,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
oPrinter:Say ( 338,  25,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.03),"@E 99,999.99")),oFont10n)     //Mensagem  e Calculo de multa em 3%
oPrinter:Say ( 358,  25,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10n)//Mensagem  e Calculo de mora diaria de 5% ao mes
oPrinter:Say ( 378,  25,cProtesto,oFont10n)
oPrinter:Say ( 318, 452,"(-)Desconto/Abatimento",oFont8)
oPrinter:Say ( 338, 452,"(-)Outras Deduções",oFont8)
oPrinter:Say ( 358, 452,"(+)Mora/Multa",oFont8)
oPrinter:Say ( 378, 452,"(+)Outros Acréscimos",oFont8)
oPrinter:Say ( 398, 452,"(=)Valor Cobrado",oFont8)
oPrinter:Say ( 418,  25,"Pagador",oFont8)
oPrinter:Say ( 425, 100,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10n) //Nome do sacado
oPrinter:Say ( 435, 100,aDatSacado[3],oFont10n)//Endereço do sacado 
oPrinter:Say ( 445, 100,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado do sacado
oPrinter:Say ( 455, 100,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC do sacado
oPrinter:Say ( 455, 455,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10n)//Numero de cartera e numero do nusso numero
oPrinter:Say ( 458,  25,"Pagador/Avalista",oFont8)
oPrinter:Say ( 468, 200,"Autenticação Mecânica -",oFont8)

FOR i := 25 TO 555 STEP 5
	oPrinter:Line( 510,i,510,i+3)				//Linha pontilhada
NEXT i


//3º Bloco 
oPrinter:Line( 540,  25, 540, 555)  						//Linha horizontal 1
oPrinter:Line( 565,  25, 565, 555)							//Linha horizontal 2
oPrinter:Line( 590,  25, 590, 555)							//Linha horizontal 3
oPrinter:Line( 610,  25, 610, 555)							//Linha horizontal 4
oPrinter:Line( 630,  25, 630, 555)							//Linha horizontal 5
oPrinter:Line( 650, 450, 650, 555)							//Linha horizontal 6
oPrinter:Line( 670, 450, 670, 555)							//Linha horizontal 7
oPrinter:Line( 690, 450, 690, 555)							//Linha horizontal 8
oPrinter:Line( 710, 450, 710, 555)							//Linha horizontal 9
oPrinter:Line( 730,  25, 730, 555)							//Linha horizontal 10 
oPrinter:Line( 780,  25, 780, 555)							//Linha horizontal 11 

oPrinter:Line( 515, 140, 540, 140)							//Linha vertical 1 
oPrinter:Line( 515, 200, 540, 200)						    //Linha vertical 2 
oPrinter:Line( 590, 120, 630, 120)							//Linha vertical 3
oPrinter:Line( 610, 180, 630, 180)							//Linha vertical 4
oPrinter:Line( 590, 240, 630, 240)							//Linha vertical 5 
oPrinter:Line( 590, 320, 610, 320)							//Linha vertical 6
oPrinter:Line( 590, 360, 630, 360)							//Linha vertical 7
oPrinter:Line( 540, 450, 730, 450)							//Linha vertical 8 


oPrinter:SayBitmap( 515,  10,cLogoBol,40,24 )			   	//Logo do banco 
oPrinter:Say ( 535,  50,aDadosBanco[2], oFont16n)			//Nome do banco
oPrinter:Say ( 535, 145,aDadosBanco[1]+"-7",oFont24n)		//Numero do banco
oPrinter:Say ( 535, 202,CB_RN_NN[2],oFont14n)	  			//Linha Digitavel do Codigo de Barras
oPrinter:Say ( 548,  25,"Local de Pagamento",oFont8)
oPrinter:Say ( 556,  25,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU",oFont8)
oPrinter:Say ( 564,  25,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont8)
oPrinter:Say ( 548, 452,"Vencimento",oFont8)
cString :=STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	:=	 (555-(len(cString)*5))
oPrinter:Say ( 564,nCol,cString,oFont10n)//Data de Vencimento
oPrinter:Say ( 573,  25,"Beneficiário",oFont8)
oPrinter:Say ( 585,  25,aDadosEmp[1]+"   -   "+aDadosEmp[6],oFont10n) //Nome do beneficiario e CNPJ
oPrinter:Say ( 573, 452,"Agência/Código Beneficiário",oFont8)
cString := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol   	:= (555-(len(cString)*5))
oPrinter:Say ( 585,nCol,cString,oFont10n)
oPrinter:Say ( 598,  25,"Data do Documento",oFont8)
oPrinter:Say ( 608,  25,STRZERO(day(aDadosTit[2],2),2)+"/"+STRZERO(month(aDadosTit[2],2),2)+"/"+STRZERO(year(aDadosTit[2],4),4),oFont10n) // Data da emissao do Titulo
oPrinter:Say ( 598, 122,"Nro.Documento",oFont8)
oPrinter:Say ( 608, 122,aDadosTit[7]+" "+aDadosTit[1],oFont10n) //Prefixo +Numero+Parcela
oPrinter:Say ( 598, 242,"Espécie Doc.",oFont8)
oPrinter:Say ( 608, 242,aDadosTit[8],oFont10n) //Tipo do Titulo
oPrinter:Say ( 598, 322,"Aceite",oFont8)
oPrinter:Say ( 608, 330,"N",oFont10n)
oPrinter:Say ( 598, 362,"Data do Processamento",oFont8)
oPrinter:Say ( 608, 372,STRZERO(DAY(aDadosTit[3],2),2)+"/"+STRZERO(MONTH(aDadosTit[3],2),2)+"/"+STRZERO(YEAR(aDadosTit[3],2),4),oFont10n) // Data impressao
oPrinter:Say ( 598, 452,"Nosso Número",oFont8)
cString := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1)
nCol   	:= (555-(len(cString)*5))
oPrinter:Say ( 608,nCol,cString,oFont10n)
oPrinter:Say ( 618,  25,"Uso do Banco",oFont8)
oPrinter:Say ( 618, 122,"Carteira",oFont8)
oPrinter:Say ( 628, 132,aDadosBanco[6],oFont10n) //Numero da carteira
oPrinter:Say ( 618, 182,"Espécie",oFont8)
oPrinter:Say ( 628, 192,"R$",oFont10n)
oPrinter:Say ( 618, 242,"Quantidade",oFont8)
oPrinter:Say ( 618, 362,"Valor",oFont8)
oPrinter:Say ( 618, 452,"Valor do Documento",oFont8)
cString := AllTrim(Transform(nValor,"@E 999,999,999.99"))
nCol   	:= (555-(len(cString)*5))
oPrinter:Say ( 628,nCol,cString,oFont10n)
oPrinter:Say ( 638,  25,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
oPrinter:Say ( 658,  25,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.03),"@E 99,999.99")),oFont10n)     //Mensagem  e Calculo de multa em 2%
oPrinter:Say ( 678,  25,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99")),oFont10n)//Mensagem  e Calculo de mora diaria de 5% ao mes
oPrinter:Say ( 698,  25,cProtesto,oFont10n)
oPrinter:Say ( 638, 452,"(-)Desconto/Abatimento",oFont8)
oPrinter:Say ( 658, 452,"(-)Outras Deduções",oFont8)
oPrinter:Say ( 678, 452,"(+)Mora/Multa",oFont8)
oPrinter:Say ( 698, 452,"(+)Outros Acréscimos",oFont8)
oPrinter:Say ( 718, 452,"(=)Valor Cobrado",oFont8)
oPrinter:Say ( 738,  25,"Pagador",oFont8)
oPrinter:Say ( 745, 100,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10n) //Nome do sacado
oPrinter:Say ( 755, 100,aDatSacado[3],oFont10n)//Endereço do sacado 
oPrinter:Say ( 765, 100,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado do sacado
oPrinter:Say ( 775, 100,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC do sacado
oPrinter:Say ( 775, 455,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10n)//Numero de cartera e numero do nusso numero
oPrinter:Say ( 778,  25,"Pagador/Avalista",oFont8)

/*--------------------------------------------------------------------------------------------*
Parâmetros do codigo de barras

Nome 		Tipo		Descrição			
cTypeBar	Caracter	Código do tipo do código de barras:
						"EAN13", "EAN8", "UPCA" , "SUP5" , "CODE128",
						"INT25","MAT25,"IND25","CODABAR","CODE3_9"
nRow		Numérico	Posição relativa à esquerda
nCol		Numérico	Posição relativa ao topo
cCode		Caracter	Texto a ser transformado em código de barra
oPrint		Objeto		Objeto Printer
lCheck		Lógico		Se calcula o digito de controle. Defautl .T.
Color		Numérico	Numero da Cor, utilize a "color.ch". Default CLR_BLACK
lHorz		Lógico		Se imprime na Horizontal. Default .T.
nWidth		Numérico	Numero do Tamanho da barra. Default 0.025
nHeigth		Numérico	Numero da Altura da barra. Default 1.5
lBanner	 	Lógico		Se imprime a linha com o código embaixo da barra. Default .T.
cFont		Caracter	Nome do Fonte a ser utilizado. Defautl "Arial"
cMode		Caracter	Modo do codigo de barras CO. Default ""
lPrint     	Lógico		Se executa o método Print() de oPrinter pela MsBar. Default .T.
nPFWidth	Numérico	Número do índice de ajuste da largura da fonte. Default 1
nPFHeigth	Numérico	Número do índice de ajuste da altura da fonte. Default 1
lCmtr2Pix	Lógico		Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.
*---------------------------------------------------------------------------------------------*/

oPrinter:FWMSBAR("INT25" /*cTypeBar*/,64/*nRow*/ ,2/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,1.4/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)


Return    

/*----------------------------------------------------------------------------------------------------------------------------------*
Funcao      : MODULO10()                                                                                                      
Parametros  : cData                                                                                                       
Retorno     : D
Objetivos   : Calcula o digito em modulo 10
Autor       : João Silva
TDN         : 
Revisão     : 
Data/Hora   : 18/03/2014
Módulo      : Financeiro.
*-----------------------------------------------------------------------------------------------------------------------------------*/   
*-------------------------------*
STATIC FUNCTION Modulo10(cData)
*-------------------------------*

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
D := 10 - (Mod(D,10))
If D = 10
	D := 0
EndIf
Return(D) 
/*----------------------------------------------------------------------------------------------------------------------------------*
Funcao      : MODULO11()                                                                                                      
Parametros  : cData                                                                                                       
Retorno     : D
Objetivos   : Calcula o digito em modulo 11
Autor       : João Silva
TDN         : 
Revisão     : 
Data/Hora   : 18/03/2014
Módulo      : Financeiro.
*-----------------------------------------------------------------------------------------------------------------------------------*/ 
*-------------------------------*
STATIC FUNCTION Modulo11(cData)
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

If (D == 0 .Or. D == 1 .Or. D == 10 .or. D == 11)
	D := 1
Else
	D := 11 - (mod(D,11))	
EndIf 


Return(D)
/*----------------------------------------------------------------------------------------------------------------------------------*
Funcao      : Ret_cBarra                                                                                                      
Parametros  : cData                                                                                                       
Retorno     : D
Objetivos   : Calcula o digito em modulo 10
Autor       : João Silva
TDN         : 
Revisão     : 
Data/Hora   : 18/03/2014
Módulo      : Financeiro.
*-----------------------------------------------------------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------------------*
STATIC FUNCTION Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cCarteira)
*------------------------------------------------------------------------------------------*
Local cConta 		:= StrTran(cConta,"-","")
Local cCarteira    	:= alltrim(cCarteira) 
Local BlDocNuFinal 	:= cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)
Local _nVlrAbat    	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
Local nValor       	:= SE1->E1_SALDO - _nVlrAbat
Local blvalorfinal 	:= Strzero((nValor-SE1->E1_DECRESC+SE1->E1_ACRESC)*100,10)//Tratamento para o Acrescimo e Decrescimo
Local dvnn         	:= 0
Local dvcb         	:= 0
Local dv			:= 0
Local NN           	:= ''
Local RN           	:= ''
Local CB           	:= ''
Local s            	:= ''
Local cMoeda       	:= "9"
Local cFator       	:= Strzero(SE1->E1_VENCREA - ctod("07/10/1997"),4)       
	
//Montagem DAC do NOSSO NUMERO
snn   := BlDocNuFinal  // Nosso Numero
dvnn  := Alltrim(Str(modulo10(snn)))  //Digito verificador no Nosso Numero
cNN   := Strzero(val(cNroDoc),8) + dvnn 
                                         
//Montagem DAC do campo agencia+conta+carteira+nossonumero

cCod  := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)

dvCod := Alltrim(Str(modulo10(cCod)))    
     
//MONTAGEM DA LINHA DIGITAVEL 
//Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 1 
campo1  := cBanco + cMoeda + cCarteira + substr(cNN,1,2) 
dvC1    := Alltrim(Str(modulo10(campo1)))                                  
cCampo1 := campo1 + dvC1

//Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 2 
campo2  := substr(cNN,3,6) + dvCod + substr(cAgencia,1,3)  
dvC2    := Alltrim(Str(modulo10(campo2)))
cCampo2 := campo2 + dvC2   //+ substr(cNroDoc+dvnn,3,7)

//Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 3 
campo3  := substr(cAgencia,4,1) + cConta + cDacCC + "000" 
dvC3    := Alltrim(Str(modulo10(campo3)))
cCampo3 := campo3 + dvC3 //+ substr(cAgencia,4,1)

//Montagem das DACs do Codigo de Barras
//campo 4
campo4  := cBanco + cMoeda + cFator + blvalorfinal + cCarteira + cNroDoc+dvnn + cAgencia + cConta + cDacCC + "000"
cDacCB  := Alltrim(Str(Modulo11(campo4)))
cCampo4 := cDacCB

//Montagem 
//campo 5
cCampo5  := cFator + blvalorfinal

cCB      := cBanco + cMoeda + cDacCB + cFator + blvalorfinal + cCarteira + cNroDoc+dvnn + cAgencia + cConta + cDacCC + "000" // codigo de barras

//Montagem da linha  digitavel 
cRN := substr(cCampo1,1,5)+"."+substr(cCampo1,6,5)+space(2)+ substr(cCampo2,1,5)+"."+substr(cCampo2,6,6)+space(2)+ substr(cCampo3,1,5)+"."+substr(cCampo3,6,6)+space(2) + cCampo4 + space(2)+ cCampo5 

Return({cCB,cRN,cNN})

/*----------------------------------------------------------------------------------------------------------------------------------*
Funcao      : AjustaSx1
Parametros  : cPerg, aPergs
Retorno     : Nil
Objetivos   : Verifica/cria SX1 a partir de matriz para verificacao
Revisão     : 
Data/Hora   : 18/03/2014
Módulo      : Financeiro.               	  	
*-----------------------------------------------------------------------------------------------------------------------------------*/
*---------------------------------------*
STATIC FUNCTION AjustaSX1(cPerg, aPergs) 
*---------------------------------------*

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local cKey		:= ""
Local nJ		:= 0
Local nCondicao

cPerg := Padr(cPerg,10)

aCposSX1:={ "X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
			"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
			"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
			"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
			"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
			"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
			"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
			"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

DbSelectArea("SX1")
DbSetOrder(1)
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


Return
