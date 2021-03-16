#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
/*
Funcao      : GTLOJ002
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Manutenção de condição de pagamento de cupons(SL4).
Autor       : Jean Victor Rocha
Data/Hora   : 06/08/2016
*/
*----------------------*
User Function GTLOJ002()
*----------------------*                                             
Return Processa({|| MainGT() },"Processando aguarde...")

//Funções de usuario auxiliares
*----------------------*
User Function GTLOJ02T()
*----------------------*
If ReadVar() == "M->VALOR"
	oBrw1:ACOLS[oBrw1:NAT][3] := M->VALOR
EndIf
Return Totalizador()


//Função principal.
*----------------------*
Static Function MainGT()
*----------------------*
Private oDlg
Private oLayer	:= FWLayer():new()
Private aSize 	:= MsAdvSize()
Private oSelS	:= LoadBitmap( nil, "LBOK")
Private oSelN	:= LoadBitmap( nil, "LBNO") 
Private oStsBr	:= LoadBitmap( nil, "BR_BRANCO")
Private oStsok	:= LoadBitmap( nil, "BR_VERDE")

Private aAjustes:= {}

oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL - Integração APDATA",,,.F.,,,,,,.T.,,,.T. )

oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )
                                 
oLayer:addCollumn('1',025,.F.,'1')
oLayer:addCollumn('2',075,.F.,'1')
         
oLayer:addWindow('1','Win11'	,'Cupon'		  		,100,.F.,.F.,{||  }				,'1',{|| })
oLayer:addWindow('2','Win12A'	,'Menu'					,015,.F.,.F.,{||  }				,'1',{|| })
oLayer:addWindow('2','Win12B'	,'Pagamentos'			,085,.F.,.F.,{||  }				,'1',{|| })

//Definição das janelas para objeto.
oWin21 := oLayer:getWinPanel('1','Win11'	,'1')
oWin22A:= oLayer:getWinPanel('2','Win12A'	,'1')
oWin22B:= oLayer:getWinPanel('2','Win12B'	,'1')

//Menu -----------------------------------------------------------------------------
oBtn0 := TBtnBmp2():New(02,(oWin22A:NRIGHT)-40,26,26,"FINAL",,,,{|| oDlg:end()}			,;
														oWin22A,"Sair"					,,.T.)
oBtn1 := TBtnBmp2():New(02,010,26,26,"PMSRRFSH"	  	   	   	,,,,{|| Processa({|| LoadWin21(.T.) },"Processando aguarde...")},;
													 	oWin22A,"Recarregar telas",,.T.)
oBtn2 := TBtnBmp2():New(02,050,26,26,"SALVAR"	  	   	   	,,,,{|| Processa({|| SaveManut() },"Processando aguarde...")},;
													 	oWin22A,"Salvar Alterações",,.T.)
oBtn3 := TBtnBmp2():New(02,090,26,26,"SELECT"	  	   	   	,,,,{|| Processa({|| TrocaSts() },"Processando aguarde...")},;
													 	oWin22A,"Trocar Status em lote",,.T.)
oBtn4 := TBtnBmp2():New(02,130,26,26,"DEVOLNF"	  	   	   	,,,,{|| Processa({|| RemoveSts() },"Processando aguarde...")},;
													 	oWin22A,"Reverter ajuste",,.T.)													 	


aHWin21	:= {}
aCWin21	:= {}
aAWin21	:= {}  

aHWin21A	:= {}
aCWin21A	:= {}
aAWin21A	:= {}

aHWin22B	:= {}
aCWin22B	:= {}
aAWin22B	:= {}

AADD(aHWin21,{ TRIM("Data")			,"DATA"		,""	   					,08,0,"","","D","",""})

AADD(aHWin21A,{ TRIM("Serie PDV")	,"SERPDV"	,"@!"  					,20,0,"","","C","",""})
                                        
AADD(aHWin22B,{ TRIM("Sts.")	  	,"STS"		,"@BMP"					,02,0,"","","C","",""})
AADD(aHWin22B,{ TRIM("Serie PDV")	,"SERPDV"	,"@!"					,20,0,"","","C","",""})
AADD(aHWin22B,{ TRIM("Num. Cupom")	,"NUM"		,"@!"					,06,0,"","","C","",""})
AADD(aHWin22B,{ TRIM("Total Cupom")	,"VALOR"	,"@E 9,999,999,999.99"	,16,2,"","","N","",""})

oDadosW21 := MsNewGetDados():New(01,01,(oWin21:NHEIGHT/2)-2,(oWin21:NRIGHT/4)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
							"", aAWin21,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin21,aHWin21, aCWin21, {|| MudaLinha("oWin21")})
									
oDadosW21A := MsNewGetDados():New(01,(oWin21:NRIGHT/4),(oWin21:NHEIGHT/2)-2,(oWin21:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
							"", aAWin21A,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin21,aHWin21A, aCWin21A, {|| MudaLinha("oWin22B")})
							
oDadosW22B := MsNewGetDados():New(01,01,(oWin22B:NHEIGHT/2)-2,(oWin22B:NRIGHT/2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
							"", aAWin22B,, 99, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin22B,aHWin22B, aCWin22B)

oDadosW22B:AddAction("STS", {|| EditVal()})
oDadosW22B:AddAction("SERPDV", {|| EditVal()})
oDadosW22B:AddAction("NUM", {|| EditVal()})
oDadosW22B:AddAction("VALOR", {|| EditVal()})
                           
oDadosW22B:LEDITLINE := .T.

//Carrega dados iniciais das telas
LoadWin21()

oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao	    : LoadWin21()
Parametros  : 
Retorno     : 
Objetivos   : Carrega os dados do objeto oWin21
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-----------------------------*
Static function LoadWin21(lAtu)
*-----------------------------*
Local cQry := ""

Default lAtu := .F.
     
//Validaçaõ de confirmação de usuario.
If lAtu .And. !MsgYesNo("Confirma a atualização dos dados? Todas as edições serão perdidas!","HLB BRASIL")
	Return .T.
EndIf

aAjustes := {}

//Carrega dados por data
oDadosW21:ACOLS := {}
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif

cQry += " Select L1_EMISSAO
cQry += " From "+RETSQLNAME("SL1")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 	AND L1_FILIAL = '"+xFilial("SL1")+"'
cQry += " 	AND L1_SITUA = 'PE'
cQry += " Group By L1_EMISSAO

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)

QRY->(DbGoTop())
While QRY->(!EOF())
	aAdd(oDadosW21:ACOLS,	{	STOD(QRY->L1_EMISSAO),;
									.F.})//Deletado
	QRY->(DbSkip())
EndDo
           
If Len(oDadosW21:ACOLS) == 0
	MsgInfo("Sem dados a serem carregados!","HLB BRASIL")
ElseIf lAtu
	MudaLinha("OWIN22B",.F.)
EndIf
	
Return .T.

/*
Funcao	    : MudaLinha()
Parametros  : 
Retorno     : 
Objetivos   : Atualiza o Browse de acordo com o cupom posicionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-------------------------------------*
Static function MudaLinha(cOpc,lvalida)
*-------------------------------------*
Local cQry := ""
Local i
Local lTemCont := .F.

Default lvalida := .T.
                
//Validaçaõ de perda de conteudo com o usuario
For i:=1 to Len(oDadosW22B:ACOLS)
	If ValType(oDadosW22B:ACOLS[i][1]) == "O" .and. oDadosW22B:ACOLS[i][1] == oStsok
		lTemCont:= .T.
		Exit
	EndIf
Next i

If lvalida .and. lTemCont .And.;
	!MsgYesNo("Existem pagamentos editados que não foram gravados. Deseja realmente sair e perder as alterações?","HLB BRASIL")
	Return .T.
EndIf
aAjustes := {}

cOpc := UPPER(cOpc)

If Len(oDadosW21:ACOLS) == 0
	LoadWin21()
EndIf                  
If Len(oDadosW21:ACOLS) <>0 .and. cOpc == "OWIN21"
	If Select("QRY") > 0
		QRY->(DbClosearea())
	Endif
	oDadosW21A:ACOLS := {}
	//Carrega dados por SERVPDV
	cQry := " Select L1_SERPDV
	cQry += " From "+RETSQLNAME("SL1")
	cQry += " Where D_E_L_E_T_ <> '*'
	cQry += " 	AND L1_FILIAL = '"+xFilial("SL1")+"'
	cQry += " 	AND L1_SITUA = 'PE'
	cQry += " 	AND L1_EMISSAO = '"+DTOS(oDadosW21:ACOLS[oDadosW21:NAT][1])+"'
	cQry += " Group By L1_SERPDV
	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
	
	aAdd(oDadosW21A:ACOLS,{	"TODOS",;
							.F.})//Deletado
	
	QRY->(DbGoTop())
	While QRY->(!EOF())
		aAdd(oDadosW21A:ACOLS,{	QRY->L1_SERPDV,;
									.F.})//Deletado
		QRY->(DbSkip())
	EndDo
	                                                                                                
	oLayer:setWinTitle('2','Win12B','Pagamentos - '+DTOC(oDadosW21:ACOLS[oDadosW21:NAT][1]),'1')
	
	oDadosW21A:ForceRefresh()
EndIf	
If Len(oDadosW21:ACOLS) <>0 .and. Len(oDadosW21A:ACOLS) <>0 .and. (cOpc == "OWIN21" .or. cOpc == "OWIN22B")
	If Select("QRY") > 0
		QRY->(DbClosearea())
	Endif
	oDadosW22B:ACOLS := {}
	
	nValor := 0
	
	//Carrega dados por SERVPDV
	cQry := " Select L4_NUM,L4_SERPDV,SUM(L4_VALOR) as L4_VALOR
	cQry += " From "+RETSQLNAME("SL4")
	cQry += " Where D_E_L_E_T_ <> '*'
	cQry += " 	AND L4_FILIAL = '"+xFilial("SL4")+"'
	cQry += " 	AND L4_SITUA = 'PE'
	cQry += " 	AND L4_DATA = '"+DTOS(oDadosW21:ACOLS[oDadosW21:NAT][1])+"'
	If oDadosW21A:ACOLS[oDadosW21A:NAT][1] != "TODOS"
		cQry += " 	AND L4_SERPDV = '"+oDadosW21A:ACOLS[oDadosW21A:NAT][1]+"'
	EndIf
	cQry += " Group By L4_NUM,L4_SERPDV,L4_ADMINIS
	cQry += " Order By L4_NUM,L4_SERPDV,L4_ADMINIS
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)

	QRY->(DbGoTop())
	While QRY->(!EOF())
		//Busca outras formas de pagamentos para o totalizador.
		If Select("TMP") > 0
			TMP->(DbClosearea())
		Endif
		cQry := " Select SUM(L4_VALOR) as L4_VALOR
		cQry += " From "+RETSQLNAME("SL4")
		cQry += " Where D_E_L_E_T_ <> '*'
		cQry += " 	AND L4_FILIAL = '"+xFilial("SL4")+"'
		cQry += " 	AND L4_DATA = '"+DTOS(oDadosW21:ACOLS[oDadosW21:NAT][1])+"'
		cQry += " 	AND L4_NUM = '"+QRY->L4_NUM+"'
		cQry += " 	AND L4_SERPDV = '"+QRY->L4_SERPDV+"'
		cQry += "	AND L4_FORMA <> 'CC'
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)	
		
		aAdd(oDadosW22B:ACOLS,{	oStsBr,;
								QRY->L4_SERPDV,;
								QRY->L4_NUM,;
								QRY->L4_VALOR + TMP->L4_VALOR,;
								.F.})//Deletado
		QRY->(DbSkip())
	EndDo
	oDadosW22B:ForceRefresh()
EndIf

Return .T.

/*
Funcao	    : EditVal()
Parametros  : 
Retorno     : 
Objetivos   : Tela de ajuste de dados dos pagamentos
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*------------------------*
Static function  EditVal()
*------------------------*
Local i
Local nTotCC := 0

Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private noBrw1  := 0

Private cGet1 := ""
Private cGet2 := "0,00"
Private cGet3 := ""
Private cGet4 := ""
Private cGet5 := ""
Private cGet6 := ""
Private cGet7 := "0,00"

SetPrvt("oDlg1","oBrw1","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oGet1","oGet2","oGet3","oSBtn1")
SetPrvt("oSay6","oSay7","oSay8","oGet4","oGet5","oGet6")

AADD(aHoBrw1,{ TRIM("Parcela")				,"PARCELA"	,"@E 99"				,02,0,"","","N","",""})
AADD(aHoBrw1,{ TRIM("Vencimento")			,"VENCTO"	,""						,08,0,"","","D","",""})
AADD(aHoBrw1,{ TRIM("Valor")		  		,"VALOR"	,"@E 9,999,999,999.99"	,16,2,"","","N","",""})

aAlBrw1 := {"VENCTO","VALOR","PARCELA"}

//Total de pagamentos em outras formas de pagamento para o mesmo cupom
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif
cQry := " Select L4_NUM,L4_SERPDV,SUM(L4_VALOR) as L4_VALOR
cQry += " From "+RETSQLNAME("SL4")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 	AND L4_FILIAL = '"+xFilial("SL4")+"'
cQry += " 	AND L4_NUM = '"+ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3])+"'
cQry += " 	AND L4_SERPDV = '"+ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2])+"'
cQry += " 	AND L4_FORMA <> 'CC'
cQry += " Group By L4_NUM,L4_SERPDV
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
If QRY->(!EOF())
	cGet2 := ALLTRIM(TRANSFORM(QRY->L4_VALOR,"@E 9,999,999,999.99"))
EndIf

//Dados do cabeçalho do cupom fiscal
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif
cQry := " Select *
cQry += " From "+RETSQLNAME("SL1")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 	AND L1_FILIAL = '"+xFilial("SL1")+"'
cQry += " 	AND L1_NUM = '"+ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3])+"'
cQry += " 	AND L1_SERPDV = '"+ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2])+"'
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
If QRY->(!EOF())
	cGet4 := ALLTRIM(ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3]))
	cGet5 := STOD(QRY->L1_EMISSAO)
	cGet6 := ALLTRIM(ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2]))
	cGet7 := ALLTRIM(TRANSFORM(QRY->L1_VLRTOT,"@E 9,999,999,999.99"))
EndIf

//Carrega dados de pagamentos por CC.

//Filial + NUM + SERPDV
nPos := aScan(aAjustes, {|x| 	x[1] == xFilial("SL4") .and.;
								x[2] == ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3]) .and.;
								x[3] == ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2]) })
If nPos == 0
	If Select("QRY") > 0
		QRY->(DbClosearea())
	Endif
	cQry := " Select L4_DATA,L4_NUM,L4_SERPDV,L4_VALOR
	cQry += " From "+RETSQLNAME("SL4")
	cQry += " Where D_E_L_E_T_ <> '*'
	cQry += " 	AND L4_FILIAL = '"+xFilial("SL4")+"'
	cQry += " 	AND L4_NUM = '"+ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3])+"'
	cQry += " 	AND L4_SERPDV = '"+ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2])+"'
	cQry += " 	AND L4_FORMA = 'CC'
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
	QRY->(DbGoTop())
	While QRY->(!EOF())
		nTotCC += QRY->L4_VALOR
		aAdd(aCoBrw1,{	1,;
						STOD(QRY->L4_DATA),;
						QRY->L4_VALOR,;
						.F.})//Deletado
		QRY->(DbSkip())
	EndDo
Else
	For i:=1 to len(aAjustes[npos][Len(aAjustes[npos])])
   		aAdd(aCoBrw1, aAjustes[npos][Len(aAjustes[npos])][i] )
	Next i
EndIf
	
cGet1 := ALLTRIM(TRANSFORM(nTotCC,"@E 9,999,999,999.99"))
cGet3 := ALLTRIM(TRANSFORM(nTotCC+VAL(cGet2),"@E 9,999,999,999.99"))

oDlg1      := MSDialog():New( 117,466,570,912,"Manutenção Pagamento C.C.",,,.F.,,,,,,.T.,,,.T. )
oBrw1      := MsNewGetDados():New(044,004,156,219,GD_INSERT+GD_DELETE+GD_UPDATE,;
							'AllwaysTrue()','AllwaysTrue()','',aAlBrw1,0,99,'U_GTLOJ02T()','','AllwaysTrue()',oDlg1,aHoBrw1,aCoBrw1, {|| Totalizador()} )

oBrw1:LEDITLINE := .F.							

oGrp2      := TGroup():New( 002,004,040,219,"Cabeçalho Cupom",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay6      := TSay():New( 012,008,{||"Cupom: "},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
oGet4      := TGet():New( 012,036,{|| cGet4},oGrp2,076,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
oSay7      := TSay():New( 024,008,{||"Serv. PDV:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet6      := TGet():New( 024,036,{|| cGet6},oGrp2,076,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
oSay8      := TSay():New( 012,127,{||"Data"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
oGet5      := TGet():New( 012,155,{|| cGet5},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
oSay9      := TSay():New( 024,127,{||"Valor"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
oGet7      := TGet():New( 024,155,{|| CGet7},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

oGrp1      := TGroup():New( 160,004,218,132,"Totalizador Cupom",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay2      := TSay():New( 172,008,{||"Soma C.C."},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
oGet1      := TGet():New( 172,056,{|| cGet1},oGrp1,068,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
oSay3      := TSay():New( 184,008,{||"Outras formas:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
oGet2      := TGet():New( 184,056,{|| CGet2},oGrp1,068,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
oSay5      := TSay():New( 195,008,{||"_______________________________________________________"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,116,008)
oSay4      := TSay():New( 204,008,{||"TOTAL"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
oGet3      := TGet():New( 204,056,{|| cGet3},oGrp1,068,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

oSBtn1     := SButton():New( 185,191,1, {|| IIF(GrvPag(),oDlg1:End(),.F.) } ,oDlg1,,"", )
oSBtn2     := SButton():New( 205,191,2,{|| oDlg1:End() },oDlg1,,"", )

oDlg1:Activate(,,,.T.)

oDadosW22B:LEDITLINE := .T.

Return oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][oDadosW22B:Obrowse:ColPos]

/*
Funcao	    : Totalizador()
Parametros  : 
Retorno     : 
Objetivos   : Tela de totalizador de pagamentos do Cupom fiscal.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*----------------------------*
Static function  Totalizador()
*----------------------------*
Local i
Local nTotal := 0

For i:=1 to Len(oBrw1:ACOLS)
	nTotal += oBrw1:ACOLS[i][3]
Next i

cGet1 := ALLTRIM(TRANSFORM(nTotal,"@E 9,999,999,999.99"))
oGet1:CTEXT := cGet1

cGet3 := ALLTRIM(TRANSFORM(nTotal+VAL(oGet2:CTEXT),"@E 9,999,999,999.99"))
oGet3:CTEXT := cGet3

Return .T.                               

/*
Funcao	    : GrvPag()
Parametros  : 
Retorno     : 
Objetivos   : Gravação dos dados da tela de edição de pagamento
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-----------------------*
Static function  GrvPag()
*-----------------------*
Local i
Local aAux := {}

If oGet3:CTEXT <> oGet7:CTEXT
	Alert("Valor do cupom não confere com o valor total dos pagamentos!")
	Return .F.
EndIf

For i:=1 to len(oBrw1:ACOLS)
	aAdd(aAux, oBrw1:ACOLS[i])
Next i

//Verifica se ja existe cadastrado
nPos := aScan(aAjustes, {|x| 	x[1] == xFilial("SL4") .and.;
								x[2] == ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3]) .and.;
								x[3] == ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2]) })

If nPos <> 0
	aAjustes[nPos][LEN(aAjustes[nPos])] := aAux
Else
	aAdd(aAjustes,{xFilial("SL4"),;
					ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3]),;
					ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2]),;
					aAux})
EndIf

oDadosW22B:ACOLS[oDadosW22B:Obrowse:nAt][1] := oStsok

Return .T.

/*
Funcao	    : TrocaSts()
Parametros  : 
Retorno     : 
Objetivos   : Troca Status de pagamento em lote, para casos em que não sera necessario o ajuste, mas precisa ser realizado o aceite pelo usuario.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*------------------------*
Static function TrocaSts()
*------------------------*
Local i

Private aCoBrw2 := {}
Private aHoBrw2 := {}
Private aAlBrw2 := {"SEL"}

SetPrvt("oDlg2","oBrw2")

oDlg2      := MSDialog():New( 100,466,570,912,"Alterar Status em lote",,,.F.,,,,,,.T.,,,.T. )

oBtn10 := TBtnBmp2():New(05,010,26,26,'SELECTALL'	,,,,{|| MarcaButton()}		, oDlg2,"Marca Todos"			,,.T.)

oSBtn10     := SButton():New( 05,190,1,{|| IIF(GrvNewStatus(),oDlg2:End(),.F.) } ,oDlg2,,"", )
oSBtn11     := SButton():New( 05,160,2,{|| oDlg2:End() },oDlg2,,"", )

oSay10 := TSay():New( 22,005,{|| "Esta rotina possibilita alterar o status em "+;
									"lote para o status VERDE, para que seja "},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay12 := TSay():New( 30,005,{|| "gravado e processado."},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)

AADD(aHoBrw2,{ TRIM("Sel.")			,"SEL","@BMP",02,0,"","","C","",""})
AADD(aHoBrw2,{ TRIM("Sts.")			,"STS","@BMP",02,0,"","","C","",""})
AADD(aHoBrw2,{ TRIM("Linha") 		,"LINHA"	,"@E 99999"				,05,0,"","","N","",""})
AADD(aHoBrw2,{ TRIM("Serie PDV")	,"SERPDV"	,"@!"					,20,0,"","","C","",""})
AADD(aHoBrw2,{ TRIM("Num. Cupom")	,"NUM"		,"@!"					,06,0,"","","C","",""})
AADD(aHoBrw2,{ TRIM("Total Cupom")	,"VALOR"	,"@E 9,999,999,999.99"	,16,2,"","","N","",""})

For i:=1 to Len(oDadosW22B:ACOLS)
	If oDadosW22B:ACOLS[i][1] == oStsBr
		aAdd(aCoBrw2,{	oSelN,;
						oDadosW22B:ACOLS[i][1],;
						i,;
						oDadosW22B:ACOLS[i][2],;	
						oDadosW22B:ACOLS[i][3],;
						oDadosW22B:ACOLS[i][4],;
						.F.})
	EndIf
Next i

oBrw2      := MsNewGetDados():New(040,004,232,219,GD_INSERT+GD_DELETE+GD_UPDATE,;
							'AllwaysTrue()','AllwaysTrue()','',aAlBrw2,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlg2,aHoBrw2,aCoBrw2)

oBrw2:AddAction("SEL", {|| MudaStatus()})

oDlg2:Activate(,,,.T.)


Return .T.

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*--------------------------*
Static Function MudaStatus()
*--------------------------*
Local cArqConte := oBrw2:aCols[oBrw2:Obrowse:nAt][1]

If oSelS == cArqConte
	cArqConte := oSelN
Else 
	cArqConte := oSelS
Endif

Return(cArqConte)

/*
Funcao	    : MarcaButton()
Parametros  : 
Retorno     : 
Objetivos   : Marca e Desmarca Todas as integrações.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*---------------------------*
Static function MarcaButton()
*---------------------------*
Local i
Local oSelBtn

If UPPER(LEFT(oBtn10:CTOOLTIP,3)) == "MAR"
	oBtn10:CTOOLTIP := "Desmarca Todos"
	oBtn10:LoadBitmaps("UNSELECTALL")
	oSelBtn := oSelS
Else
	oBtn10:CTOOLTIP := "Marca Todos"
	oBtn10:LoadBitmaps("SELECTALL")
	oSelBtn := oSelN
EndIf

For i:=1 to len(oBrw2:ACOLS) 
	oBrw2:ACOLS[i][1] := oSelBtn
Next i

oBrw2:ForceRefresh()

Return .T.

/*	
Funcao	    : GrvNewStatus()
Parametros  : 
Retorno     : 
Objetivos   : Gravar novo status, para gravação em lote.
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*----------------------------*
Static function GrvNewStatus()
*----------------------------*
Local i
Local aAux := {}

For i:=1 to len(oBrw2:ACOLS)
	If oBrw2:ACOLS[i][1] == oSelS
		If MsgYesNo("Confirma a alteração de status para os marcados?","HLB BRASIL")
			Exit
		Else
			Return .F.
		EndIf
	EndIf
Next i

For i:=1 to len(oBrw2:ACOLS)
	If oBrw2:ACOLS[i][1] == oSelS
		oDadosW22B:ACOLS[oBrw2:ACOLS[i][3]][1] := oStsok

		If Select("QRY") > 0
			QRY->(DbClosearea())
		Endif
		cQry := " Select L4_DATA,L4_NUM,L4_SERPDV,L4_VALOR
		cQry += " From "+RETSQLNAME("SL4")
		cQry += " Where D_E_L_E_T_ <> '*'
		cQry += " 	AND L4_FILIAL = '"+xFilial("SL4")+"'
		cQry += " 	AND L4_NUM = '"+ALLTRIM(oDadosW22B:aCols[oBrw2:ACOLS[i][3]][3])+"'
		cQry += " 	AND L4_SERPDV = '"+ALLTRIM(oDadosW22B:aCols[oBrw2:ACOLS[i][3]][2])+"'
		cQry += " 	AND L4_FORMA = 'CC'
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)
		QRY->(DbGoTop())
		While QRY->(!EOF())
			aAdd(aAux,{Len(aAux)+1,;
					STOD(QRY->L4_DATA),;
					QRY->L4_VALOR,;
					.F.})

			QRY->(DbSkip())
		EndDo
		aAdd(aAjustes,{xFilial("SL4"),;
				ALLTRIM(oDadosW22B:aCols[oBrw2:ACOLS[i][3]][3]),;
				ALLTRIM(oDadosW22B:aCols[oBrw2:ACOLS[i][3]][2]),;
				aAux})
	EndIf
Next i

Return .T.

/*
Funcao	    : SaveManut()
Parametros  : 
Retorno     : 
Objetivos   : Processamento da gravação das alterações
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-------------------------*
Static function SaveManut()
*-------------------------*
Local i

//Validação de conteudo a ser gravado
If Len(aAjustes) == 0
	MsgInfo("Sem ajustes a serem gravados!","HLB BRASIL")
	Return .F.
EndIf

//Confirmação com usuario da gravação.
If !MsgYesNo("Confirma a gravação dos registros com status em verde?","HLB BRASIL")
	Return .F.
EndIf

For i:=1 to len(aAjustes)
	GrvSL4(aAjustes[i])
Next i

//Recarrega a tela
LoadWin21()
MudaLinha("OWIN22B",.F.)

oDadosW22B:ForceRefresh()

Return .T.

/*
Funcao	    : GrvSL4()
Parametros  : 
Retorno     : 
Objetivos   : Gravação do SL4
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*----------------------------*
Static function GrvSL4(aDados)
*----------------------------*
Local i
Local cAdminis := ""
Local cCGC := ""

//Busca o Pagamento para utilizar como base para gravação dos demais e posteriormente para deleta-lo.
If Select("QRY") > 0
	QRY->(DbClosearea())
Endif
cQry := " Select *
cQry += " From "+RETSQLNAME("SL4")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " 	AND L4_FILIAL = '"+aDados[1]+"'
cQry += " 	AND L4_NUM = '"+aDados[2]+"'
cQry += " 	AND L4_SERPDV = '"+aDados[3]+"'
cQry += " 	AND L4_FORMA = 'CC'
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"QRY",.F.,.T.)

//Gravação dos pagamentos
If QRY->(!EOF())
	cAdminis := QRY->L4_ADMINIS
	cCGC	:= 	 QRY->L4_CGC
EndIf

For i:=1 to len(aDados[4])
	cInsert := " Insert into "+RETSQLNAME("SL4")+" (L4_FILIAL,L4_NUM,L4_SERPDV,L4_DATA,L4_SITUA,L4_VALOR,L4_FORMA,L4_ADMINIS,L4_CGC,R_E_C_N_O_)
	cInsert += " Values ('"+aDados[1]+"','"+aDados[2]+"','"+aDados[3]+;
							"','"+DTOS(aDados[4][i][2])+"','RX',"+ALLTRIM(STRTRAN(TRANSFORM(aDados[4][i][3],"@E 9999999.9999"),",","."))+;
							",'CC','"+cAdminis+"','"+cCGC+"',(SELECT ISNULL(MAX(R_E_C_N_O_),0)+1 FROM "+RETSQLNAME("SL4")+"))

	TCSQLEXEC(cInsert)
Next i

//Deleta os pagamentos anteriores
QRY->(DbGoTop())
While QRY->(!EOF())
	cUpd := "Update "+RETSQLNAME("SL4")+" Set D_E_L_E_T_ = '*' Where R_E_C_N_O_ = "+ALLTRIM(STR(QRY->R_E_C_N_O_))
	TCSQLEXEC(cUpd)
	QRY->(DbSkip())
EndDo

//atualiza os SITUAs
cUpd := "Update "+RETSQLNAME("SL1")+" Set L1_SITUA = 'RX' Where L1_FILIAL = '"+xFilial("SL1")+;
							"' AND L1_NUM = '"+aDados[2]+"' AND L1_SERPDV = '"+aDados[3]+"'"
TCSQLEXEC(cUpd)
cUpd := "Update "+RETSQLNAME("SL2")+" Set L2_SITUA = 'RX' Where L2_FILIAL = '"+xFilial("SL2")+;
							"' AND L2_NUM = '"+aDados[2]+"' AND L2_SERPDV = '"+aDados[3]+"'"
TCSQLEXEC(cUpd)

Return .T.

/*
Funcao	    : RemoveSts()
Parametros  : 
Retorno     : 
Objetivos   : Deleta os ajustes e volta a marcação inicial
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*-------------------------*
Static function RemoveSts()
*-------------------------*
Local nPos := 0
Local cStatus := oDadosW22B:ACOLS[oDadosW22B:Obrowse:nAt][1]

If cStatus <> oStsok
	Return .T.
EndIf

If !MsgYesNo("Confirma apagar as edições do pagamento selecionado?","HLB BRASIL")
	Return .T.
EndIf

oDadosW22B:ACOLS[oDadosW22B:Obrowse:nAt][1] := oStsBr
          
nPos := aScan(aAjustes,{|x| x[1] == xFilial("SL4") .and.;
   							x[2] == ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][3]) .and.;
							x[3] == ALLTRIM(oDadosW22B:aCols[oDadosW22B:Obrowse:nAt][2])	})
If nPos <> 0
	aDel(aAjustes,nPos)
	aSize(aAjustes,Len(aAjustes)-1)
EndIf

Return .T.