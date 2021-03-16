#include 'rwmake.ch'                     
#include 'Protheus.ch'

/*
Funcao      : SD1100I
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1.
				 O registro no SD1 já se encontra travado (Lock). Será executado uma vez para cada item do Documento de Entrada que está sendo incluída.
TDN			: http://tdn.totvs.com/display/public/mp/SD1100I
Autor       : 
Data/Hora   : 
*/
*---------------------*
User Function SD1100I()
*---------------------*
Local _cDoc			//Numero da Nota Fiscal
Local _cSerie		//Serie da Nota Fiscal
Local _cCliente		//Cliente do PV ou NF
Local _cLoja		//Loja do PV ou NF
Local _cPedido		//Numero do Pedido de Venda
Local _cNaturez		//Natureza do cliente
Local _cNomeCli		//Nome fatazia do cliente
Local _dEmissao		//Emissao da Nota Origem da Devolucao
Local bb, pp		//Controla for..next
Local _aBonific	:= {} //Array com os tipos de bonificacao encontrados para cada item da nf. sendo [1]=GRUPO, [2]=TIPO BONIFIC, [3]=PERCENT, [4]=Base para calculo
Local _aParc	:= {} //Arrya com as parcelas de cada bonificacao
Local _cPerfixo	:= &(GetMv("MV_1DUPREF"))
Local _nChr		:= Asc(Alltrim(GetMv("MV_1DUP"))) - 1          
Local _cParcela	:= " "
Local _Tipo     := "NDC"                                        

// Variaveis Locais da Funcao
Private cGet1	 := Space(25)
Private cGet2	 := Space(25)
Private cGet3	 := Space(25)
Private oGet1
Private oGet2
Private oGet3

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                    
Private ALTERA := .F.                        
Private DELETA := .F.                        

Do Case
	Case cEmpAnt $ "EQ/ZN"
		
		If !SF1->F1_TIPO=="D"
			Return
		EndIf
		_aArea      := GetArea()
		
		// Dados da Nota Fiscal de Saida
		_cDoc	    	:= SF1->F1_DOC
		_cSerie		:= SF1->F1_SERIE
		_cCliente	:= SF1->F1_FORNECE
		_cLoja		:= SF1->F1_LOJA
		_cNaturez	:= Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NATUREZ")
		_cNomeCli	:= Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NREDUZ")
		
		//Verifica os grupos dos produtos dos itens da nota fiscal e grava num array
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbGotop()
		dbSeek(xFilial("SD1")+_cDoc+_cSerie+_cCliente+_cLoja)
		While !eof() .and. SD1->D1_DOC=_cDoc .and. SD1->D1_SERIE=_cSerie .and. SD1->D1_FORNECE=_cCliente .and. SD1->D1_LOJA=_cLoja
			dbSelectArea("SF2")
			dbSetOrder(1)
			dbSeek(xFilial("SF2")+SD1->D1_NFORI+SD1->D1_SERIORI+_cCliente+_cLoja,.T.)
			If !found()
				dbSkip()
				Loop
			EndIf
			_dEmissao := SF2->F2_EMISSAO
			dbSelectArea("SZ1")
			dbSetOrder(1) //Filial+Cliente+Loja+Grupo+tipo
			If dbSeek(xFilial("SZ1")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_GRUPO,.T.) .or. dbSeek(xFilial("SZ1")+SD1->D1_FORNECE+SD1->D1_LOJA+"****",.T.)
				While !eof() .and. SZ1->Z1_CLIENTE==SD1->D1_FORNECE .and. SZ1->Z1_LOJA==SD1->D1_LOJA .and. (SZ1->Z1_GRUPO==SD1->D1_GRUPO .or. SZ1->Z1_GRUPO=="****")
					If SZ1->Z1_INICIO < _dEmissao .and. SZ1->Z1_FIM>_dEmissao
						_nPos := aScan(_aBonific,{ |x| x[2] == SZ1->Z1_TIPOBON})
						If _nPos == 0
							If SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="N"
								Aadd(_aBonific,{SD1->D1_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*(SD1->D1_TOTAL-SD1->D1_VALICM)} )
							ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="N"
								Aadd(_aBonific,{SD1->D1_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*((SD1->D1_TOTAL-SD1->D1_VALICM)+SD1->D1_VALIPI)} )
							ElseIf SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="S"
								Aadd(_aBonific,{SD1->D1_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*((SD1->D1_TOTAL-SD1->D1_VALICM)+SD1->D1_VALICM)} )
							ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="S"
								Aadd(_aBonific,{SD1->D1_GRUPO, SZ1->Z1_TIPOBON, (SZ1->Z1_PERCENT/100)*((SD1->D1_TOTAL-SD2->D2_VALICM)+SD1->D1_VALIPI+SD1->D1_VALICM)} )
							EndIf
						Else
							If SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="N"
								_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*(SD1->D1_TOTAL-SD1->D1_VALICM)
							ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="N"
								_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*((SD1->D1_TOTAL-SD1->D1_VALICM)+SD1->D1_VALIPI)
							ElseIf SZ1->Z1_IPI=="N" .and. SZ1->Z1_ICM=="S"
								_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*((SD1->D1_TOTAL-SD1->D1_VALICM)+SD1->D1_VALICM)
							ElseIf SZ1->Z1_IPI=="S" .and. SZ1->Z1_ICM=="S"
								_aBonific[_nPos][3] := _aBonific[_nPos][3] + (SZ1->Z1_PERCENT/100)*((SD1->D1_TOTAL-SD1->D1_VALICM)+SD1->D1_VALIPI+SD1->D1_VALICM)
							EndIf
						Endif
					EndIf
					dbSelectArea("SZ1")
					dbSkip()
				End
			EndIf
			dbSelectArea("SD1")
			dbSkip()
		End
		
		//Atualiza no Contas a Receber criando os titulos de bonificação em cada parcela
		dbSelectArea("SE1")
		For bb := 1 to Len(_aBonific)
			//	_aParc  := Condicao(_aBonific[bb][3],_cCond,,dDatabase)
			//	For pp := 1 to Len(_aParc)
			                
			SE1->(DbSetOrder(1))       
			SE1->(DbGotop())
			lGrava:= Dbseek(xFilial("SE1")+_aBonific[bb][2]+_cDoc+_cParcela+_Tipo) 
			     
			If !(lGrava)
			   SE1->(RecLock("SE1",.T.))
			   Replace E1_FILIAL	With	xFilial("SE1")
			   Replace E1_PREFIXO	With	_aBonific[bb][2]
			   Replace E1_NUM		With	_cDoc
		       Replace E1_PARCELA	With	_cParcela
			   Replace E1_TIPO		With	_Tipo
			   Replace E1_CLIENTE	With	_cCliente
			   Replace E1_LOJA		With	_cLoja
			   Replace E1_NATUREZ	With	_cNaturez
		       Replace E1_EMISSAO	With	dDatabase
			   Replace E1_VENCTO	With	dDatabase
			   Replace E1_VENCREA	With	DataValida(dDatabase)
			   Replace E1_VALOR		With	_aBonific[bb][3] //Valor
			   Replace E1_NOMCLI	With	_cNomeCli
			   Replace E1_EMIS1		With	dDataBase
			   Replace E1_HIST		With	"DESC. BONIF. "+_aBonific[bb][2]//Grupo
			   Replace E1_LA		With	"S"
			   Replace E1_SITUACA	With	"0"
			   Replace E1_SALDO		With	_aBonific[bb][3] //Valor
			   Replace E1_MOEDA		With	1
			   Replace E1_PEDIDO	With	""
			   Replace E1_VLCRUZ	With	_aBonific[bb][3] //Valor
			   Replace E1_NUMNOTA	With	_cDoc
			   Replace E1_SERIE		With	_cSerie
			   Replace E1_STATUS	With	"A"
			   Replace E1_ORIGEM	With	"MATA460"
			   Replace E1_VENCORI	With	dDatabase
			   Replace E1_FILORIG	With	xFilial("SF2")
			   SE1->(MsUnlock())  
			   
			EndIf   
		Next
		
		RestArea(_aArea)
	
	Case cEmpAnt $ "EF"
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
			Reclock("SD1",.F.)
			Replace SD1->D1_OP With SC7->C7_OP
			MsUnlock()
		EndIf

	Case cEmpAnt $ "F2" .or. cEmpAnt == "9M"//Creata // Sungard
		If 	SF1->(FieldPos("F1_P_FLAG")) <> 0 .And.;
			SF1->(FieldPos("F1_P_CC"))	 <> 0 .And.;
			SF1->(FieldPos("F1_P_PROF")) <> 0 .And.; 
			SF1->(FieldPos("F1_P_PROJ")) <> 0 .And.;
			SD1->D1_RATEIO <> "1" .And.;
			!SF1->F1_P_FLAG
			
			DEFINE MSDIALOG oDlg TITLE "Cost Centre/Projects" FROM C(194),C(228) TO C(465),C(625) PIXEL
			
			// Cria as Groups do Sistema
			@ C(012),C(017) TO C(121),C(180) LABEL "Register" PIXEL OF oDlg
			
			// Cria Componentes Padroes do Sistema             
			@ C(029),C(069) MsGet oGet1 Var cGet1 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" F3 "CTT" PIXEL OF oDlg
			@ C(030),C(035) Say "Cost Center" Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg

			@ C(045),C(069) MsGet oGet2 Var cGet2 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" F3 "CTD" PIXEL OF oDlg
			@ C(045),C(035) Say "Projects" Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg

			@ C(061),C(069) MsGet oGet3 Var cGet3 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" F3 "CTH" PIXEL OF oDlg
			@ C(062),C(035) Say "Profit Center" Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg        

			@ C(090),C(079) Button "Ok" Size C(037),C(012) action(ClickOK(cGet1,cGet2,cGet3)) PIXEL OF oDlg
			
			oGet1:bValid     := {|| IIF(EMPTY(cGet1),.T.,EXISTCPO("CTT",cGet1,1)) }
			oGet2:bValid     := {|| IIF(EMPTY(cGet2),.T.,EXISTCPO("CTD",cGet2,1)) }      
			oGet3:bValid     := {|| IIF(EMPTY(cGet3),.T.,EXISTCPO("CTH",cGet3,1)) }
			
			ACTIVATE MSDIALOG oDlg CENTERED 
			       
			RECLOCK("SF1",.F.)
			SF1->F1_P_FLAG:=.T.
			MSUNLOCK()	
		EndIf
		
	Case cEmpAnt $ "LX/LW"
	                                                            
	    
		//Esse tratamento foi migrado para o fonte P.E - SF1100I- TLM Tratamento de fatura 20140828
		//Chama tela para inserção do número da PO
		if SF1->(FieldPos("F1_P_FATUR"))>0
        	if empty(SF1->F1_P_FATUR)
	        	CadPO()
        	endif
		endif  

		
	End Case

Return
	                        
*----------------------------------------*
Static Function ClickOK(cGet1,cGet2,cGet3)
*----------------------------------------*
If Empty(cGet2)
	msginfo("Campo projeto não informado!")
EndIf              

DBSELECTAREA("SF1")        


RECLOCK("SF1",.F.)
	SF1->F1_P_CC   := cGet1
	SF1->F1_P_PROJ := cGet2
    SF1->F1_P_PROF := cGet3
MSUNLOCK()


oDlg:end()
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*----------------------------------------*
Static Function C(nTam)                   
*----------------------------------------*                                      
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)

Return(.T.)     



/*
Funcao      : CadPO()
Objetivos   : Gerar tela para inserção do número da PO que será gravada em campo customizado no F1
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2014 
*/
*--------------------*
Static Function CadPO
*--------------------*

Local cGet1:=space(20)
Local cGet2:=space(50)
Local oDlg1,oGrp1,oSay1,oGet1,oSay2,oGet2,oBtn1,oBtn2


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        
//Tratamento de fatura - TLM 20140828
If (SF1->(FieldPos("F1_P_FATUR")) > 0)
   
	oDlg1      := MSDialog():New( 227,414,400,672,"Cadastro de PO / FATURA",,,.F.,DS_MODALFRAME,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 004,004,060,124,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 012,020,{||"Código PO:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 020,020,{|u| if(PCount()>0,cGet1:=u,cGet1)},oGrp1,088,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet1",,)
	oSay2      := TSay():New( 032,020,{||"Fatura:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet2      := TGet():New( 040,020,{|u| if(PCount()>0,cGet2:=u,cGet2)},oGrp1,088,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet2",,)

	oBtn1      := TButton():New( 064,050,"Salvar",oDlg1,{||  IIF(empty(alltrim(cGet2)),alert("O Campo 'Fatura' é de preenchimento obrigatório."),( IIF(MsgYesNo("Deseja realmente salvar estes código de PO e FATURA?"),(SalvaPO(cGet1,cGet2),oDlg1:end()),) )) },037,012,,,,.T.,,"",,,,.F. )
	
	oDlg1:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

Else

	oDlg1      := MSDialog():New( 227,514,352,772,"Cadastro de PO",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 004,004,040,124,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 012,020,{||"Código PO:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 020,020,{|u| if(PCount()>0,cGet1:=u,cGet1)},oGrp1,088,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet1",,)
	oBtn1      := TButton():New( 044,012,"Salvar",oDlg1,{||  IIF(empty(cGet1),alert("Preencha o campo código!"),( IIF(MsgYesNo("Deseja realmente salvar este código de PO?"),(SalvaPO(cGet1),oDlg1:end()),) )) },037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 044,080,"Cancelar",oDlg1,{|| IIF(MsgYesNo("Deseja realmente cancelar?"),oDlg1:end(),) },037,012,,,,.T.,,"",,,,.F. )

EndIf

oDlg1:Activate(,,,.T.)

Return

/*
Funcao      : SalvaPO()
Objetivos   : Grava em campo customizado no F1 o número da PO
Autor       : Matheus Massarotto
Data/Hora   : 16/01/2014 
*/
*-------------------------------------*
Static Function SalvaPO(cGet1,cGet2)
*------------------------------------*	
	
	if SF1->(FieldPos("F1_P_PO"))>0
		RecLock("SF1",.F.)
			SF1->F1_P_PO:=cGet1
		MsUnLock()
	endif       
	     
	//TLM Tratamento de fatura 20140828
	If SF1->(FieldPos("F1_P_FATUR"))>0
		RecLock("SF1",.F.)
			SF1->F1_P_FATUR:=cGet2
		MsUnLock()
	Endif       
 		       
Return