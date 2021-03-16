#include "topconn.ch"
#include "rwmake.ch"

/*
Funcao      : M460FIM 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Ponto de entrada chamado após a gravação dos dados da NFS 
Autor       : José Augusto Pereira Alves
Data/Hora   : 14/03/2008     
Obs         : 
TDN         : Este P.E. é chamado apos a Gravacao da NF de Saida, e fora da transação.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/02/2012
Obs         : Empresas do grupo GT foram tiradas do fonte assim como os não clientes - F2/Creata, etc.
Módulo      : Faturamento.
Cliente     : Arc / Shiseido / Sumitomo / Donaldson / Twitter 
*/
Static _aRecTit    
*------------------------*
 USER FUNCTION M460FIM()
*------------------------*
  
LOCAL cAlias :=ALIAS()
Local aArea  :={}                                 
Local cQuery:=""
Local nRecno:=0

Local aVetor                                             
Local cNatEnt

Local cNatCob

// Variaveis criadas pela Microsiga para o fonte da DONALDSON 

Local _aArea	 := GetArea()			// Inicializa array para capturar Area de Trabalho desconhecida
Local _aAreaSB1	 := SB1->(GetArea())	// Inicializa array para capturar Area de Trabalho SB1
Local _aAreaSF2  := SF2->(GetArea())	// Inicializa array para capturar Area de Trabalho SF2
Local _aAreaSD2	 := SD2->(GetArea())	// Inicializa array para capturar Area de Trabalho SD2
Local _aAreaSA1	 := SA1->(GetArea())	// Inicializa array para capturar Area de Trabalho SA1
Local _aAreaSA2	 := SA2->(GetArea())	// Inicializa array para capturar Area de Trabalho SA2
Local _aAreaSC5	 := SC5->(GetArea())	// Inicializa array para capturar Area de Trabalho SC5
Local _aAreaSC6	 := SC6->(GetArea())	// Inicializa array para capturar Area de Trabalho SC6
Local _aAreaSF4	 := SF4->(GetArea())	// Inicializa array para capturar Area de Trabalho SF4
Local _aAreaSE1	 := SE1->(GetArea())	// Inicializa array para capturar Area de Trabalho SE1  
Local _cNome     := ""
Local _cDoc      := SF2->F2_DOC
Local _cSerie    := SF2->F2_SERIE
Local _nQtd      := SF2->F2_VOLUME1
Local _nPBruto   := 0
Local _nPLiqui   := 0
Local _cTransp   := ""
Local _cCodRed   := ""
Local _cEspec    := "" 
Local _cNomeRed  := space(30)
Local _cPlaca    := space(08)
Local _cMarca    := space(20)
Local _cMens1    := space(03)
Local _cMens2    := space(03) 
Local _cConhec   := space(40)
Local _dDtSaida  := dDataBase 
Local _cHrSaida  := Time()                  
Local _cEspec    := ""
Local lSair      := .t.
Local _nRecD2    := 0
Local lFirst     :=.T. 
Local nItens     := 0
Local cNum       := ""  
Local lTemSerie  := .T.  

Local aAreaSC6 := SC6->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSFT := SFT->(GetArea())

Local lTotal := .T.
Local aPedido := {}

local cQry:=""    
local cQryV:=""

local cCod_P:=""
Local cNCtr	:=""

Private aCod     [8]			// Inicializa array com 8 elementos para os codigos das mensagens.
Private aMsg     [8]			// Inicializa array com 8 elementos para os textos das mensagens.
Private lMsg     := .T.
Private nVar     := 0          
Private _cMens   := ""
Private cMsg     := ""   
Private cCod     := ""
Private cLin1    := ""
Private cLin2    := ""
Private _lFecha  := .F.
Private aEstNeg  := {}
Private lTemWFEst:= GetMV("MV_P_WFEST",.T.,.F.) // Se está habilitada para Workflow do Estoque Negativo     
//JSS - Alterado para solucionar o caso 029752
If lTemWFEst                 
   //ASK - 27/08/2010 - Trata Workflow de estoque negativo - TODAS AS EMPRESAS.
   SD2->(DbSetOrder(3))        
   SD2->(DbGoTop())
      If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE)) 
         While !SD2->(EOF()) .AND. SD2->D2_DOC = SF2->F2_DOC .And. SD2->D2_SERIE = SF2->F2_SERIE 
            If SB2->(DbSeek(xFilial("SB2")+SD2->D2_COD+SD2->D2_LOCAL))
               If SB2->B2_QATU < 0  
                  aadd(aEstNeg,{SD2->D2_PEDIDO,;
                                SD2->D2_DOC,;
                                SD2->D2_SERIE,;
                                SD2->D2_CLIENTE,;
                                SD2->D2_LOJA,;
                                SB2->B2_COD,;
                                SD2->D2_QUANT,;
                                SB2->B2_QATU,;
                                SD2->D2_ITEM,;
                                SD2->D2_LOCAL})   
               EndIf
            EndIf
            SD2->(DbSkip())
         End
      EndIf       

   If FindFunction ("U_WF_P_ESTNEG") .And. len(aEstNeg) > 0  
      U_WF_P_ESTNEG(aEstNeg)
   EndIF
EndIf 

	
/*------------------------------------------------------------------
Específico ARC    
Função de entrada que grava conteúdo C6_P_CANAL no campo D2_P_CANAL 
Autor: José Augusto Pereira Alves
Data : 14/03/2008
------------------------------------------------------------------*/
If cEmpAnt $ "J0"    
   
Begin Sequence          
	
   If Select("SQL") > 0
      SQL->(dbCloseArea())
   EndIf  
   
   fGeraSql()           
   
   DbSelectArea("SQL")
   SQL->(DbGoTop())
   
   Do While.Not.Eof()
   	SC6->(DbSetOrder(2))
   	SC6->(DbSeek(xFilial("SC6")+SQL->D2_COD+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
   	SD2->(DbSetOrder(8))
   	SD2->(DbSeek(xFilial("SD2")+SQL->D2_PEDIDO+SQL->D2_ITEMPV))
      Reclock("SD2",.F.)
      Replace SD2->D2_P_CANAL With SC6->C6_P_CANAL
      MsUnlock()   
      DbSelectArea("SQL")
   	DbSkip()
   EndDo
   
End Sequence   

DbSelectArea(cAlias) 
                            

/*---------------------------------------------------------------------------------------------------------------------------
Específico SUMITOMO    
Ponto de entrada que grava o custo no campo D2_P_CUSTO quando a TES nao movimentar estoque, para usar apenas em relatorios.
Autor: Adriane Sayuri Kamiya	
Data : 23/08/2010
----------------------------------------------------------------------------------------------------------------------------*/
ElseIf cEmpAnt $ "FF" 
   
   SB2->(DbSetOrder(1))
   SF4->(DbSetOrder(1))   
   SD2->(DbSetOrder(3))        
   SD2->(DbGoTop())
   If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE)) 
      While !SD2->(EOF()) .AND. SD2->D2_DOC = SF2->F2_DOC .And. SD2->D2_SERIE = SF2->F2_SERIE 
         SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
         If SF4->F4_ESTOQUE $ 'N'  
            If SB2->(DbSeek(xFilial("SB2")+SD2->D2_COD+SD2->D2_LOCAL))
               Reclock("SD2",.F.)
               SD2->D2_P_CUSTO  := SB2->B2_CM1 * SD2->D2_QUANT
               SD2->(MsUnlock())   
            EndIf
         EndIf
         SD2->(DbSkip())
      End
   EndIf   
            

ElseIf cEmpAnt $ "R7"    
   aICMSENT := {}   
   nQtdEnt   := 0
   nIcmsEnt  := 0
   nBIcmsEnt := 0
   nIcmsRet  := 0
   nBIcmsRet := 0

  SD2->(DbSetOrder(3))        
  SD2->(DbGoTop())
  If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE)) 
     While !SD2->(EOF()) .AND. SD2->D2_DOC = SF2->F2_DOC .And. SD2->D2_SERIE = SF2->F2_SERIE //.And. SD2->D2_CF = '5405' 
        DbSelectArea("SB1")
        SB1->(DBSetOrder(1))
        SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
        If !EMPTY(SB1->B1_GRTRIB) 
           DbSelectArea("SD1")
           SD1->(DBSetOrder(5))
           SD1->(DbGotop())
           If SD1->(DbSeek(xFilial("SD1")+SD2->D2_COD+SD2->D2_LOCAL))
              While !SD1->(Eof() ) .And. SD1->D1_COD = SD2->D2_COD .And. SD1->D1_LOCAL = SD2->D2_LOCAL 
                 If SD1->D1_ICMSRET = 0 .Or. SD1->D1_TIPO <> 'N' .or. !Alltrim(SD1->D1_CF) $ '2403/2102' .or. SD1->D1_EMISSAO > SD2->D2_EMISSAO
                    SD1->(DbSkip())
                    Loop 
                 Else 
                      //                 1               2                3             4           5             6               7              8
                    aAdd(aICMSENT,{SD1->D1_QUANT,SD1->D1_ICMSRET,SD1->D1_BRICMS,SD1->D1_EMISSAO,SD1->D1_DOC, SD1->D1_SERIE,SD1->D1_TOTAL, SD1->D1_VALIPI})
                 EndIf 
                 SD1->(DbSkip()) 
              EndDo   
              If !Empty(aICMSENT) 
                 RecLock('SD2',.F.)
                 n:= len(aICMSENT) 
                 nQtdEnt          := aICMSENT[n][1]
                 nIcmsEnt         := aICMSENT[n][2]
                 nBIcmsEnt        := aICMSENT[n][3]
                 SD2->D2_P_IVAVL  := (nIcmsEnt/nQtdEnt)  * SD2->D2_QUANT
                 SD2->D2_P_IVABS  := (nBIcmsEnt/nQtdEnt) * SD2->D2_QUANT   
                 SD2->D2_P_IVAST  := ((nBIcmsEnt - (aICMSENT[n][7]+aICMSENT[n][8]))/(aICMSENT[n][7]+aICMSENT[n][8]))*100
                 SD2->D2_P_DOCST  := aICMSENT[n][5]
                 SD2->D2_P_SERST  := aICMSENT[n][6]
                 MsUnlock()            
                 aICMSENT         := {}
              EndIf
           EndIf
        EndIf
        SD2->(DbSkip())   
     EndDo
  EndIf   
  
ElseIf cEmpAnt $ "3U" 
   
   SD2->(DbSetOrder(3))        
   SD2->(DbGoTop())
   If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE))  
   
      cNum:=SD2->D2_PEDIDO         
      
      SC5->(DbSetOrder(1))
      If SC5->(DbSeek(xFilial("SC5")+cNum )) 
         If Alltrim(SC5->C5_P_TIPO) =="S"
            lTemSerie :=.F.
         EndIf
      EndIf
      
      If lTemSerie
      
         ZX2->(DbSetOrder(1))
         If ZX2->(DbSeek(xFilial("ZX2")+SD2->D2_PEDIDO))
        
            ZX3->(DbSetOrder(2))
            ZX3->(DbGoTop())   
            If ZX3->(DbSeek(xFilial("ZX3")+SD2->D2_PEDIDO)) 
            
               RecLock("ZX2",.F.)
               ZX2->ZX2_DOC    :=SF2->F2_DOC
               ZX2->ZX2_SERIE  :=SF2->F2_SERIE
               ZX2->ZX2_DTNF   :=SF2->F2_EMISSAO
               ZX2->ZX2_TIPO   :=SF2->F2_TIPO 
               ZX2->ZX2_STATUS :="NFS"
               ZX2->ZX2_OBS    :="Nota gerada"
               ZX2->(MsUnlock())  
                            
               While !ZX3->(EOF()) .AND. SD2->D2_PEDIDO ==  ZX3->ZX3_PEDIDO
              
                  RecLock("ZX3",.F.)
                  ZX3->ZX3_DOC    :=SF2->F2_DOC
                  ZX3->ZX3_SERIE  :=SF2->F2_SERIE
                  ZX3->ZX3_DTNF   :=SF2->F2_EMISSAO
                  ZX3->ZX3_TIPO   :=SF2->F2_TIPO 
                  ZX3->ZX3_STATUS :="NFS"
                  ZX3->(MsUnlock())
                
                                                      
                  ZX1->(DbSetOrder(3))   
                  If ZX1->(DbSeek(xFilial("ZX1")+ZX3->ZX3_CODBAR)) 
                     If Empty(ZX1->ZX1_NFSAID)   
                        RecLock("ZX1",.F.)
                        ZX1->ZX1_NFSAID:=SD2->D2_DOC
                        ZX1->ZX1_SESAID:=SD2->D2_SERIE
                        ZX1->ZX1_ITEMSA:=SD2->D2_ITEM
                        ZX1->ZX1_PEDIDO:=SD2->D2_PEDIDO
                        ZX1->ZX1_STATUS:="FAT"
                        ZX1->(MsUnlock())    
                       
                        If lFirst
                           ZX0->(DbSetOrder(2))  
                           If ZX0->(DbSeek(xFilial("ZX0")+ZX1->ZX1_DOC+ZX1->ZX1_SERIE  ))
                              RecLock("ZX0",.F.)
                              ZX0->ZX0_STATUS:="FAT" 
                              lFirst:=.F.
                              ZX0->(MsUnlock())                
                           EndIf
                        EndIf    
                     Else
                        MsgStop("Houve um problema na gravação da referencia da saida com a entrada, informar ao dept. TI : Serie"+ Alltrim(ZX3->ZX3_CODBAR),"EUROSILICONE")                  
                     EndIf
               
                  EndIf
                
                  ZX3->(DbSkip())           
               EndDo
            EndIf
      
         EndIf
      EndIf
   EndIf                     
                   
   SC5->(DbSetOrder(1))    
   If SC5->(DbSeek(xFilial("SC5")+cNum))
      _cConhec  := SC5->C5_P_CONHE 
      _nPLiqui  := SC5->C5_PESOL   
      _nPBruto  := SC5->C5_PBRUTO
      _cTransp  := SC5->C5_TRANSP 
      _nQtd     := SC5->C5_VOLUME1
      _cEspec   := SC5->C5_ESPECI1
   EndIf
   
   //_cTransp := Space(6) 
   //_cEspec  := Space(5)
                 
   @ 150,10 to 420,580 Dialog JanelaNF Title "Digite as Informacoes Necessarias"

   @ 012,010 SAY "NOTA FISCAL: " + SF2->F2_DOC size 80,10
   @ 012,100 SAY "CLIENTE: " + SF2->F2_CLIENTE size 120,10   
   @ 032,010 SAY "Cod. Transp.: "
   @ 052,010 SAY "Peso Liquido: "
   @ 052,115 SAY "Peso Bruto: "
   @ 072,010 SAY "Qtd: "
   @ 072,115 SAY "Especie: "
   @ 092,010 SAY "Conhecimento: "
   @ 032,050 GET _cTransp  PICTURE "@!" Valid .t. F3 "SA4" size 40,10
   @ 052,050 GET _nPLiqui  PICTURE "@E 99,999.99"          size 40,10
   @ 052,150 GET _nPBruto  PICTURE "@E 99,999.99"          size 40,10
   @ 072,050 GET _nQtd     PICTURE "@E 99999"              size 40,10
   @ 072,150 GET _cEspec   PICTURE "@!"                    size 40,10
   @ 092,060 GET _cConhec  PICTURE "@!"                    size 80,10

   @ 112,230 BMPBUTTON TYPE 1 ACTION Close(JanelaNF)
   ACTIVATE DIALOG JanelaNF CENTERED

   DbSelectArea("SC5")
   DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)  

   DbSelectArea("SC5")
   If SC5->(!Eof())
      RecLock("SC5",.f.)
      SC5->C5_TRANSP  := _cTransp
	  MsUnLock()
   EndIf
 
   DbSelectArea("SF2")
   RecLock("SF2",.f.)
   SF2->F2_TRANSP  := _cTransp
   SF2->F2_PLIQUI  := _nPLiqui
   SF2->F2_PBRUTO  := _nPBruto
   SF2->F2_VOLUME1 := _nQtd
   SF2->F2_ESPECI1 := _cEspec
   //SF2->F2_P_CONHE := _cConhec  

   MsUnLock()    
 

   RestArea(_aAreaSF2)
   RestArea(_aAreaSD2)
/*
	Específico para Chemtool- tratamento de campo específico - MSM - 26/03/2012
*/
Elseif cEmpAnt $ "G6"

      
	cCod_P:= SC5->C5_P_SCODE

	RecLock("SF2",.F.)
		SF2->F2_P_SCODE:=cCod_P
	MsUnlock()

	RestArea(_aAreaSF2)

//RRP - 25/02/2014 - Inclusão da empresa Equant. Chamado 017327.
ElseIf cEmpAnt $ "LW/LX"
    //Gravação do campo F2_XNUMCTR e E1_XNUMCTR com o conteúdo do campo C5_XNUMCTR 
	If SC5->(FieldPos("C5_XNUMCTR"))>0 .AND. SF2->(FieldPos("F2_XNUMCTR"))>0 .AND. SE1->(FieldPos("E1_XNUMCTR"))>0 
		cNCtr := SC5->C5_XNUMCTR
		If !Empty(Alltrim(cNCtr))
			RecLock("SF2",.F.)
			SF2->F2_XNUMCTR := cNCtr
			MsUnlock()
			DbSelectArea("SE1")
			SE1->(DbSetOrder(1))
			If SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC))
				While SE1->(!Eof()) .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO+SF2->F2_CLIENTE+SF2->F2_LOJA
					If Alltrim(cNCtr) <> "" 
						RecLock("SE1",.F.)
						SE1->E1_XNUMCTR := cNCtr
						MsUnlock()
					EndIf
					SE1->(DbSkip())
				EndDo		
			EndIf
		EndIf
	EndIf
	
	RestArea(_aAreaSF2)
	RestArea(_aAreaSE1)

//RRP - 26/08/2014 - Inclusão da empresa Exeltis. Chamado 020789	
ElseIf cEmpAnt $ "SU/LG"
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	While !SD2->(EOF()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		If SC5->(dbSeek(xFilial()+SD2->D2_PEDIDO))
			RecLock("SC5",.F.)
			SC5->C5_P_STACO := ""
			SC5->(MsUnLock())
		EndIf
		SD2->(dbSkip())
	EndDo
	RestArea(_aAreaSC5)
	RestArea(_aAreaSD2)
	RestArea(_aArea)
 
ElseIf cEmpAnt $ "I7" .Or. cEmpAnt $ "I6"     
            
SC6->(dbSetOrder(1))
SC5->(dbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica quais sao os pedidos de venda vinculados a nota  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
	While !SD2->(Eof()) .AND. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE
		If Ascan(aPedido,SD2->D2_PEDIDO) == 0
			AADD(aPedido,SD2->D2_PEDIDO)
		EndIf
		SD2->(dbSkip())
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acerta status de entrega dos pedidos da nota fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aPedido)
		lTotal := .T.                              			
		If SC6->(dbSeek(xFilial("SC6")+aPedido[nI]))
			While !SC6->(Eof()) .AND. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+aPedido[nI]
				If lTotal .AND. SC6->C6_QTDENT > 0 .AND. SC6->C6_QTDENT < SC6->C6_QTDVEN
					lTotal := .F.
				EndIf
				SC6->(dbSkip())
			End
			
			If SC5->(dbSeek(xFilial("SC5")+aPedido[nI]))
				RecLock("SC5",.F.)
				SC5->C5_ZZATEND := IIF(lTotal,"T","P")
				MsUnlock()
			EndIf
		EndIf
	Next

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSD2)

//Finaliza customização enviada pelo Joaquim EXXEMPLO 09/08/2011.

   aFill (aCod, space (003))		// Inicializa cada um dos 8 elementos do array com o tamanho para os codigos das mensagens.
   aFill (aMsg, space (500))		// Inicializa cada um dos 8 elementos do array com o tamanho para os textos das mensagens.

   //_lFecha := .f.

   dbSelectArea("SF2")

   _cDoc      := SF2->F2_DOC
   _cSerie    := SF2->F2_SERIE
   _nQtd      := SF2->F2_VOLUME1
   _nPBruto   := SC5->C5_PBRUTO
   _cTransp   := SC5->C5_TRANSP
   _cCodRed   := SC5->C5_REDESP
   _cEspec    := SC5->C5_ESPECI1

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Posiciona SD2 - itens da nota fiscal                    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSelectArea("SD2")
   dbSetOrder(3)                 //filial,doc,serie,cliente,loja,cod
   dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
   _nRecD2 := SD2->(Recno())

   dbSelectArea("SF4")
   dbSeek(xFilial("SF4") + SD2->D2_TES)

   DbSelectArea('SZY')	
   MsSeek(xFilial('SZY') + SD2->D2_TES)

   dbSelectArea("SC5")
   dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)

   If SF2->F2_TIPO == "D" .OR. SF2->F2_TIPO == "B" //nf de devolucao/remessa->fornecedor
      dbSelectArea("SA2")
	  dbSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
	 _cNome := SubStr(SA2->A2_NOME,1,30)
   Else
	  dbSelectArea("SA1")
	  dbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
      _cNome := SubStr(SA1->A1_NOME,1,30)
   EndIF

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Calcula Peso Liquido da Nota de Saida a partir do peso cadastrado no produto³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   _nPLiqui := SC5->C5_PESOL

   If _nPLiqui == 0 .Or. _nPBruto == 0
      dbSelectArea("SD2")
	  While SD2->(!Eof()) .and. SD2->D2_FILIAL == SF2->F2_FILIAL .and. SD2->D2_DOC == SF2->F2_DOC .and.;
         SD2->D2_SERIE == SF2->F2_SERIE

		 //Acumular o Peso Liquido
		 _nPLiqui += (SD2->D2_PESO * SD2->D2_QUANT)
		 _nPBruto += (SD2->D2_QUANT * Posicione('SB1', 1, xFilial('SB1') + SD2->D2_COD, 'B1_PESBRU'))
		
		 dbSelectArea("SD2")
		 SD2->(dbSkip())
      EndDo
   EndIf

   dbSelectArea("SD2")
   dBGoto(_nRecD2)

   _cNomeRed  := space(30)
   _cPlaca    := space(8)
   _cMarca    := space(20)
   _cMens     := ""
   _cMens1    := space(3)
   _cMen3    := space(3)
   _dDtSaida  := dDataBase
   _cHrSaida  := Time()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Se necessario alterar as informacoes abaixo                   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   @ 150,10 to 420,580 Dialog JanelaNF Title "Digite as Informacaes Necessarias"

   @ 012,010 SAY "NOTA FISCAL: " + SF2->F2_DOC size 80,10
   @ 012,100 SAY "CLIENTE: " + _cNome          size 120,10
   @ 032,010 SAY "Cod. Transp.: "
   @ 032,115 SAY "Redesp: "
   @ 032,205 SAY "Placa: "
   @ 052,010 SAY "Peso Liquido: "
   @ 052,115 SAY "Peso Bruto: "
   @ 072,010 SAY "Qtd: "
   @ 072,115 SAY "Especie: "
   @ 072,205 SAY "Marca: "
   @ 092,010 SAY "Data Saida: "
   @ 092,115 SAY "Hora: "
   @ 032,050 GET _cTransp  PICTURE "@!" Valid .t. F3 "SA4" size 40,10
   @ 032,150 GET _cCodRed  PICTURE "@!" Valid .t. F3 "SA4" size 40,10
   @ 032,230 GET _cPlaca   PICTURE "@!"                    size 40,10
   @ 052,050 GET _nPLiqui  PICTURE "@E 99,999.99"          size 40,10
   @ 052,150 GET _nPBruto  PICTURE "@E 99,999.99"          size 40,10
   @ 072,050 GET _nQtd     PICTURE "@E 99999"              size 40,10
   @ 072,150 GET _cEspec                                   size 40,10
   @ 072,230 GET _cMarca   PICTURE "@!15"                  size 40,10
   @ 092,050 GET _dDtSaida PICTURE "99/99/99"              size 40,10
   @ 092,150 GET _cHrSaida PICTURE "99:99:99"              size 40,10

   @ 112,230 BMPBUTTON TYPE 1 ACTION Close(JanelaNF)
   ACTIVATE DIALOG JanelaNF CENTERED

   //lSair := .T.

   dbSelectArea("SC5")
   If SC5->(!Eof())
      RecLock("SC5",.f.)
      SC5->C5_TRANSP  := _cTransp
      SC5->C5_REDESP  := _cCodRed
	  MsUnLock()
   EndIf
 
   dbSelectArea("SF2")
   RecLock("SF2",.f.)
   SF2->F2_TRANSP  := _cTransp
   SF2->F2_REDESP  := _cCodRed
   SF2->F2_PLIQUI  := _nPLiqui
   SF2->F2_PBRUTO  := _nPBruto
   SF2->F2_VOLUME1 := _nQtd
   SF2->F2_ESPECI1 := _cEspec
   SF2->F2_ZZMARCA := _cMarca
   SF2->F2_ZZPLACA := _cPlaca
   SF2->F2_ZZDTSAI := _dDtSaida
   SF2->F2_ZZHRSAI := _cHrSaida
   MsUnLock()

   CarregaMsg()					// Recupera as mensagens informadas no TES / Produto / Pedido.
   CadMen()						// Informacao das Mensagens.

   RestArea(_aAreaSF2)
   RestArea(_aAreaSD2)
   RestArea(_aAreaSA1) 
   RestArea(_aAreaSA2)
   RestArea(_aAreaSC5)
   RestArea(_aAreaSB1)
   RestArea(_aAreaSF4)
   RestArea(_aArea)

//RRP - 26/08/2014 - Inclusão da empresa Exeltis. Chamado 020789	
ElseIf cEmpAnt $ "TP"   

	// TLM 20141104 - Grava a chave Twitter 
	If (SC5->(FieldPos("C5_P_NUM")) > 0)
 		
 		//Grava a chave Twitter 
   		RecLock("SF2",.F.)
	 	SF2->F2_P_NUM:=SC5->C5_P_NUM
   		MsUnlock()          

  		SD2->(DbSetOrder(3))        
  		SD2->(DbGoTop())
  		If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE+SF2->F2_CLIENTE + SF2->F2_LOJA)) 
     		While !SD2->(EOF()) .AND. SD2->D2_DOC = SF2->F2_DOC .And. SD2->D2_SERIE = SF2->F2_SERIE .And. SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_CLIENTE+SD2->D2_LOJA
       			 
       			SC6->(DbSetOrder(1))
       			If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)) 
       				RecLock('SD2',.F.)             
       				SD2->D2_P_NUM  := SC6->C6_P_NUM        	
            		SD2->D2_P_REF  := SC6->C6_P_REF    
            		MsUnlock()       		
        		EndIf
        		SD2->(DbSkip())   
     		EndDo
  		EndIf     
  		
  		SE1->(DbSetOrder(1))
		If SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC))
			While SE1->(!Eof()) .And. SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA == xfilial("SE1")+SF2->F2_DOC+SF2->F2_PREFIXO+SF2->F2_CLIENTE+SF2->F2_LOJA
				RecLock("SE1",.F.)
				SE1->E1_P_NUM := SC5->C5_P_NUM
				MsUnlock()
				SE1->(DbSkip())
			EndDo		
		EndIf

 		RestArea(_aAreaSD2)
 		RestArea(_aAreaSC6)
 		RestArea(_aAreaSE1)

	EndIf

//AOA - 15/06/2016 - Inclusão da empresa ACCEDIAN	
ElseIf cEmpAnt $ "EI"   

  		SD2->(DbSetOrder(3))        
  		SD2->(DbGoTop())
  		If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE+SF2->F2_CLIENTE + SF2->F2_LOJA)) 
     		While !SD2->(EOF()) .AND. SD2->D2_DOC = SF2->F2_DOC .And. SD2->D2_SERIE = SF2->F2_SERIE .And. SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_CLIENTE+SD2->D2_LOJA
       			 
       			SC6->(DbSetOrder(1))
       			If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)) 
       				RecLock('SD2',.F.)             
       				SD2->D2_P_COD  := SC6->C6_P_COD        	
            		MsUnlock()       		
        		EndIf
        		SD2->(DbSkip())   
     		EndDo
  		EndIf     
  		
 		RestArea(_aAreaSD2)
 		RestArea(_aAreaSC6)

ElseIf ( cEmpAnt == "73" ) //** Empresa AOL - Leandro Brito - 04/2016

	If ( _aRecTit == Nil )
		_aRecTit := {}
	EndIf
	
	If !Empty( SF2->F2_DUPL ) .And. SF2->( F2_CLIENTE + F2_LOJA <> F2_CLIENT + F2_LOJENT )
		SE1->( DbSetOrder( 2 ) )  //**E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
		SE1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL ) )
		SA1->( DbSetOrder( 1 ) )
		SC5->( DbSetOrder( 1 ) )
		While SE1->( !Eof() .And. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
			xFilial('SE1') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL )
			
			
			If AllTrim( SE1->E1_TIPO ) <> 'NF'
				SE1->( DbSkip() )
				Loop
			EndIf
			
			SC5->( DbSeek( xFilial() + SE1->E1_PEDIDO ) )  
			
			//MSM - 09/05/2016 - Adição do campo ref no título
			if SE1->(FieldPos("E1_P_REF" )) > 0
				RecLock("SE1",.F.)
					SE1->E1_P_REF:=SC5->C5_P_REF
				SE1->(MsUnlock())
			endif
			
			If AllTrim( SC5->C5_P_IMPB ) <> 'COB'
				SE1->( DbSkip() )
				Loop			
			EndIf 
			
			
			Aadd( _aRecTit , { SE1->( Recno() ) , SF2->( Recno() ) } )

			SE1->( DbSkip() )
			
		EndDo
	else
	
		SE1->( DbSetOrder( 2 ) )  //**E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
		SE1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL ) )
		While SE1->( !Eof() .And. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
			xFilial('SE1') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL )

			SC5->( DbSetOrder( 1 ) )	
			SC5->( DbSeek( xFilial() + SE1->E1_PEDIDO ) )  
			
			//MSM - 09/05/2016 - Adição do campo ref no título
			if SE1->(FieldPos("E1_P_REF" )) > 0
				RecLock("SE1",.F.)
					SE1->E1_P_REF:=SC5->C5_P_REF
				SE1->(MsUnlock())
			endif
	
			SE1->( DbSkip() )
		Enddo
	EndIf

ElseIf cEmpAnt $ "S2"
	
	SE1->( DbSetOrder( 2 ) )  //**E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	SE1->( DbSeek( xFilial() + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL ) )
	While SE1->( !Eof() .And. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
		xFilial('SE1') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DUPL )
	
		SC5->( DbSetOrder( 1 ) )	
		SC5->( DbSeek( xFilial() + SE1->E1_PEDIDO ) )  
		
		//MSM - 09/05/2016 - Adição do campo ref no título
		if SE1->(FieldPos("E1_P_ESA" )) > 0
			RecLock("SE1",.F.)
				SE1->E1_P_ESA:=SC5->C5_P_REF
			SE1->(MsUnlock())
		endif
	
		SE1->( DbSkip() )
	Enddo
	
	If SF2->(FieldPos("F2_P_ESA")) > 0
		RecLock("SF2", .F.)                   	
   		SF2->F2_P_ESA := SC5->C5_P_REF
   		SF2->(MsUnlock())
	EndIf

//AOA - 30/01/2019 - Ajuste no campo F2_HORA para gerar corretamente NF quando tiver horario de verão
Elseif cEmpAnt $ "HH"
	cEstV 	:= "MT/GO/DF/MS/MG/SP/ES/RJ/PR/SC/RS" //Estados que tem horario de verão
	lHV		:= .F.
	
	If SuperGetMv("MV_ESTADO",.F.,"SP") $ cEstV
		lHV	:= .T.
	EndIf
	
	If SuperGetMv("MV_HVERAO",.F.,.F.) 
	    aRetTime := FwTimeUF( SuperGetMv("MV_ESTADO",.F.,"SP"), ,SuperGetMv("MV_HVERAO",.F.,.F.),, lHV )  //Pega a hora do estado		
		RecLock("SF2",.F.)
			SF2->F2_HORA:= SubStr(aRetTime[2],1,5)
		MsUnlock()
	EndIf
	

	//MSM - 08/03/2019 - Atualização da chave da nota, adicionado o tratamento antigo que existia
	AtuCHVNF()
	RestArea(_aAreaSF2)     
	
Else

	AtuCHVNF()
    RestArea(_aAreaSF2)   
    
EndIf

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FIM DA ROTINA M460FIM          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³ CADMEN   ³ Autor ³ TOTVS IP Campinas     º Data ³ dd/mm/aa º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Grava‡Æo de Mensagens N.F. de Entrada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CadMen ()

// Declaracao de variaveis:
_lFecha := .t.
@ 127, 015 To 182, 605 Dialog oDlg1 Title OemToAnsi ("Digitacao das mensagems da Nota Fiscal de Entrada")
@ 005, 010 Get aCod [1] Picture "@!"  F3 "SM4" Valid ValidMsg ("1")
@ 005, 040 Get aCod [2] Picture "@!"  F3 "SM4" Valid ValidMsg ("2")
@ 005, 070 Get aCod [3] Picture "@!"  F3 "SM4" Valid ValidMsg ("3")
@ 005, 100 Get aCod [4] Picture "@!"  F3 "SM4" Valid ValidMsg ("4")
@ 005, 130 Get aCod [5] Picture "@!"  F3 "SM4" Valid ValidMsg ("5")
@ 005, 160 Get aCod [6] Picture "@!"  F3 "SM4" Valid ValidMsg ("6")
@ 005, 190 Get aCod [7] Picture "@!"  F3 "SM4" Valid ValidMsg ("7")
@ 005, 220 Get aCod [8] Picture "@!"  F3 "SM4" Valid ValidMsg ("8")

@ 01,260 BMPBUTTON TYPE 11 ACTION Edmen (nVar)
@ 15,260 BMPBUTTON TYPE  1 ACTION GravMen ()
Activate Dialog oDlg1

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³ MSG      ³ Autor ³ TOTVS IP Campinas     º Data ³dd/mm/aa  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Direcionar / Edi‡Æo de Mensagens       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Alteracao feita pelo Motivo ( Descricao abaixo)            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidMsg (cVar)

nVar := Val (cVar)
lMsg := .T.
ChkMsg (nVar)

Return (lMsg)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³ CHKMSG   ³ Autor ³ TOTVS IP Campinas     º Data ³ dd/mm/aa º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Verifica‡Æo se existe a mensagem       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ChkMsg (nVar)

If !Empty (aCod [nVar])
	If Empty (Formula (aCod [nVar]))
		MsgBox ("Mensagem nao cadastrada, ou com conteudo vazio." + chr (13) + "Verifique o Cadastro de Mensagens.", "Atencao !!!", "STOP")
		lMsg := .F.
	EndIf
EndIf
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³ EDMEN    ³ Autor ³ TOTVS IP Campinas     º Data ³dd/mm/aa  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Editar as Mensagens N.F. de Entrada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Edmen (nVar)

If ! empty (aCod [nVar])
	
	if empty (aMsg [nVar])
		cCod  := aCod [nVar]
		cMsg  := Formula(cCod) + Space (500 - Len (Formula (cCod)))
		
		cLin1 := Substr(cMsg, 001, 250)
		cLin2 := Substr(cMsg, 251, 250)
	else
		cLin1 := PadR(Substr(aMsg [nVar], 001, 250), 250, " ")
		cLin2 := PadR(Substr(aMsg [nVar], 251, 250), 250, " ")
	endif
	
	@ 200, 010 To 295,580 Dialog oDlg2 Title OemToAnsi ("Edicao de Mensagens")
	@ 010, 002 Say OemToAnsi ("Lin1")
	@ 024, 002 Say OemToAnsi ("Lin2")
	@ 010, 015 Get cLin1 Valid .T. SIZE 210, 040
	@ 024, 015 Get cLin2 Valid .T. SIZE 210, 040
	@ 010, 235 BmpButton Type 01 Action MontaMsg ()
	@ 024, 235 BmpButton Type 02 Action LimpaMsg ()
	Activate Dialog oDlg2
	
Else
	
	MsgStop ("Codigo da mensagem esta em branco.")
	
Endif

Return (Nil)


      
/*------------------------------------------------------------------
Específico ARC    
Função que gera a Query com os dados do SD2 
Autor: José Augusto Pereira Alves
Data : 26/03/2008
------------------------------------------------------------------*/
Static Function fGeraSql()

Begin Sequence
     
	cQuery := "SELECT * "
   cQuery += "FROM SD2J00 AS SD2 WHERE "
   cQuery += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
   cQuery += "AND SD2.D2_DOC = '"+ cNumNota_p +"'  AND SD2.D2_SERIE = '"+cSerieNota_p+ "' AND SD2.D_E_L_E_T_ <> '*' "
   cQuery += "ORDER BY SD2.D2_ITEMPV"
	
	TCQuery cQuery ALIAS "SQL" NEW
	
	cTmp := CriaTrab(NIL,.F.)
   Copy To &cTmp
   dbCloseArea()
   dbUseArea(.T.,,cTmp,"SQL",.T.) 

End Sequence
   
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³CARREGAMSG³ Autor ³ TOTVS IP Campinas     º Data ³ dd/mm/aa º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Recuperar as mensagens informados no   ³±±
±±³            ³ TES, nos Produtos e nos Pedidos de Venda.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CarregaMsg ()

Local _nCont    := 1		// Variavel para controlar o limite de mensagens a ser exibida na tela de selecao.
Local _aNFOri   := {}
Local _cResto   := _cVlr   := _cTotal := ""
Local _nReg     := _nResto := 0
Local _cEmissao := ""
Local _cChave   := space(11)
Local _cQtdLib  := _cUnid  := _cSCMen := ""

SC5 -> (dbSetOrder (1))

dbSelectArea("SD2")
dbSetOrder (3)
dbSeek (xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

While ! eof () .and. SD2->D2_FILIAL == SF2->F2_FILIAL .and.;
	SD2->D2_DOC    == SF2->F2_DOC .and.;
	SD2->D2_SERIE  == SF2->F2_SERIE .and.;
	SD2->D2_CLIENTE == SF2->F2_CLIENTE .and.;
	SD2->D2_LOJA   == SF2->F2_LOJA
	
	// Recupera Mensagem Padrao no Pedido de Venda.
	SC5 -> (dbSeek (xFilial ("SC5") + SD2 -> D2_PEDIDO))
	_nTem := aScan (aCod, SC5 -> C5_MENPAD)
	if _nTem == 0
		if _nCont <= 8
			aCod [_nCont] := SC5 -> C5_MENPAD
			_nCont := _nCont + 1
		endif
	endif
	
	// Recupera Mensagem Padrao no Produto.
	SB1 -> (dbSeek (xFilial ("SB1") + SD2 -> D2_COD))
	_nTem := aScan (aCod, SB1 -> B1_ZZMEN1)
	if _nTem == 0
		if _nCont <= 8
			aCod [_nCont] := SB1 -> B1_ZZMEN1
			_nCont := _nCont + 1
		endif
	endif
	
	// Recupera mensagem padrão no cadastro de mensagem para TES.
	DbSelectArea('SZY')	
	If MsSeek(xFilial('SZY') + SD2->D2_TES)
		_nTem := aScan (aCod, SZY->ZY_MENS1)
		if _nTem == 0
			if _nCont <= 8
				aCod [_nCont] := SZY->ZY_MENS1
				++_nCont
			endif
		endif
		
		_nTem := aScan (aCod, SZY->ZY_MENS2)
		if _nTem == 0
			if _nCont <= 8
				aCod [_nCont] := SZY->ZY_MENS2
				++_nCont
			endif
		endif
		
		_nTem := aScan (aCod, SZY->ZY_MENS3)
		if _nTem == 0
			if _nCont <= 8
				aCod [_nCont] := SZY->ZY_MENS3
				++_nCont
			endif
		endif
	EndIf

	_cQtdLib := _cUnid := _cSCMen := ""
		
	//Posiciona no SC6 - Pedido Venda para buscar o conteudo do campo
	//C6_PEDCLI.
	dbSelectArea("SC6")
	dbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)
	If Found()
		_cUnid  := SC6->C6_UM
		If ! Empty(SC6->C6_PEDCLI) .And. ! Alltrim(SC6->C6_PEDCLI) $ _cSCMen
			_cSCMen += Iif(! Empty(_cSCMen), '/', '') + Alltrim(SC6->C6_PEDCLI)
		EndIf
	EndIf
		
	//Posiciona no SC9 - Pedido Liberados para verificar a Qtd liberada
	//do Produto, que devera ser informada na mensagem de retorno de benefic.
		
	dbSelectArea("SC9")
	If dbSeek(xFilial("SC9")+SD2->D2_PEDIDO+SD2->D2_ITEMPV)
		While ! Eof() .and. SC9->C9_PEDIDO==SD2->D2_PEDIDO .And. ;
		      SC9->C9_ITEM == SD2->D2_ITEMPV
				
			If SC9->C9_NFISCAL+SC9->C9_SERIENF == SD2->D2_DOC+SD2->D2_SERIE
				_cQtdLib := Transform(SC9->C9_QTDLIB,'@E 99,999.99')
			EndIf
				
			dbSkip()
		EndDo
	EndIf
		
	If ! Empty(SD2->D2_NFORI)
		//Posiciona no SF1/SD1 - NF Entrada - dados da nota fiscal original
		dbSelectArea("SF1")
		dbSeek(xFilial("SF1")+SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA)
		
		_cTotal   := Transform(SD2->D2_TOTAL,"@E 999,999,999.99")
		_cEmissao := SubStr(DtoS(SF1->F1_EMISSAO),7,2)+'/'+;
		             SubStr(DtoS(SF1->F1_EMISSAO),5,2)+'/'+;
		             SubStr(DtoS(SF1->F1_EMISSAO),1,4)
		
		_cChave := SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_ITEMORI
		nP      := ASCAN(_aNFori,{|X| Substr(X[1], 1, 11)==_cChave} )
		
		If nP == 0
			Aadd(_aNFOri,{SD2->D2_NFORI   ,;      // 1a. NF Original
			               SD2->D2_SERIORI ,;      // 2a. Serie NF Original
			               SD2->D2_ITEMORI ,;      // 3a. Item NF Original
			               _cTotal         ,;      // 4a. Total
			               _cEmissao       ,;      // 5a. Data Emissao NF Original
			               _cQtdLib        ,;      // 6a. Qtd Liberada - SC9
			               _cUnid  } )             // 7a. Unidade Medida - SC6
		EndIf
		
		dbSelectArea("SD2")
		
	EndIf
	SD2 -> (dbSkip ())
Enddo

If Len(_aNFori) >= 1
	
	For _nI := 1 To LEn (_aNFori)
		_cMens += Iif(! Empty(_aNFori[_nI][6]), _aNFori[_nI][6] + " - ", "") +;
		          "Referente s/ NF " + _aNFori[_nI][1] + " de " + _aNFori[_nI][5] +;
		          " no valor de R$" + _aNFori[_nI][4] + " (" + _aNFori[_nI][6] +;
		          " " + _aNFori[_nI][7] + "), "

	Next
EndIf

// Mensagem de pedido de cliente.
If ! Empty(_cSCMen)
	_cMens += Iif(! Empty(_cMens), ' - ', '') + 'Referente ao seu pedido: ' + _cSCMen
EndIf


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³ MONTAMSG ³ Autor ³ TOTVS IP Campinas     º Data ³dd/mm/aa  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Concatenar Mensagens.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaMsg ()

aMsg [nVar] := alltrim (cLin1) + " " + alltrim (cLin2)
Close (oDlg2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³ LIMPAMSG ³ Autor ³ TOTVS IP Campinas     º Data ³ dd/mm/aa º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Limpar Mensagens.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LimpaMsg ()

aMsg [nVar] := space (500)
Close (oDlg2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo      ³ GRAVMEN  ³ Autor ³ TOTVS IP Campinas     º Data ³dd/mm/aa  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo   ³ Funcao Utilizado p/ Grava‡Æo de Mensagens N.F. de Entrada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ AP7                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GravMen ()

Local _nLinGrv :=  nK := _nX := _nSeq := 0
Local _cTexto  := space(500)

For nK := 1 To 8
	if ! Empty(aCod [nK])
		_cTexto	:= Alltrim(Formula(aCod[nK]))
		
		if ! Empty (aMsg [nK])
			_cTexto	:= Alltrim(aMsg[nK])
		Endif
		
		_nLinGrv := MlCount(_cTexto, 240)
		
		dbSelectArea ("SZZ")
		
		for _nX := 1 to _nLinGrv
			++_nSeq
			
			RecLock ("SZZ", .T.)
			
			SZZ -> ZZ_FILIAL  := xFilial("SZZ")
			SZZ -> ZZ_TIPODOC := "S"		// Nota Fiscal de Saida
			SZZ -> ZZ_DOC     := SF2 -> F2_DOC
			SZZ -> ZZ_SERIE   := SF2 -> F2_SERIE
			SZZ -> ZZ_CLIFOR  := SF2 -> F2_CLIENTE
			SZZ -> ZZ_LOJA    := SF2 -> F2_LOJA
			SZZ -> ZZ_SEQMENS := StrZero(_nSeq, 2)
			SZZ -> ZZ_CODMENS := aCod [nK]
			SZZ -> ZZ_TXTMENS := MemoLine (_cTexto, 240, _nX)
			
			MsUnlock ()
		Next
	Endif
Next

If ! Empty(_cMens)
	_nLinGrv := MlCount(_cMens	, 240)
		
	dbSelectArea('SZZ')
		
	for _nX := 1 to _nLinGrv
		++_nSeq
			
		RecLock ("SZZ", .T.)
			
		SZZ -> ZZ_FILIAL  := xFilial("SZZ")
		SZZ -> ZZ_TIPODOC := "S"		// Nota Fiscal de Saida
		SZZ -> ZZ_DOC     := SF2 -> F2_DOC
		SZZ -> ZZ_SERIE   := SF2 -> F2_SERIE
		SZZ -> ZZ_CLIFOR  := SF2 -> F2_CLIENTE
		SZZ -> ZZ_LOJA    := SF2 -> F2_LOJA
		SZZ -> ZZ_SEQMENS := StrZero(_nSeq, 2)
		SZZ -> ZZ_TXTMENS := MemoLine(_cMens, 240, _nX)
			
		MsUnlock ()
	Next _nX
EndIf

If _lFecha
	Close (oDlg1)
endif

Return
*--------------------------------------------------*
User Function GetRecTit( lReset )    //** By Leandro Brito 29/04/2016
*--------------------------------------------------*

If ( lReset == Nil )
	lReset := .F.
EndIf

If lReset
	_aRecTit := {}
EndIf

Return( _aRecTit )      

*-------------------------*
Static function AtuCHVNF
*-------------------------*

	// TLM 20141024 - Tratamento de chave de nota fiscal na integração do arquivo XML de saída.
	If (SC5->(FieldPos("C5_P_CHVNF")) > 0)
       
 		// TLM 20141024 - Verifica se o campo personalizado está preenchido com o chave da nota fiscal 
		If  !Empty(SC5->C5_P_CHVNF)
                          
  			//Grava a chave na capa da nota
      	 	RecLock("SF2",.F.)
	 		SF2->F2_CHVNFE:=SC5->C5_P_CHVNF
   			MsUnlock()                     
   			
   			//Grava a chave na capa do livro 
   			If SF3->F3_FILIAL+SF3->F3_NFISCAL+SF3->F3_SERIE == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE
   				RecLock("SF3",.F.)
   		   		SF3->F3_CHVNFE:=SC5->C5_P_CHVNF 
   		   		MsUnlock() 
   			EndIf  
   			                          
   			//Grava a chave no item do livro   
   			If SFT->FT_FILIAL+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA  
	 	 		cQry := "Update SFT"+cEmpAnt+"0 set FT_CHVNFE='"+Alltrim(SC5->C5_P_CHVNF)+"' where FT_FILIAL='"+xFilial("SFT")
	 	 		cQry+="' AND FT_NFISCAL='"+SF2->F2_DOC+"' AND FT_SERIE='"+SF2->F2_SERIE+"' AND FT_CLIEFOR='"+SF2->F2_CLIENTE
	 	 		cQry+="' AND FT_LOJA='"+SF2->F2_LOJA+"' AND FT_OBSERV <> 'NF CANCELADA' AND FT_CHVNFE=' ' "  
            	TCSQLExec(cQry)  
			EndIf                
  

   			
  		EndIf          
  
    EndIf
  

Return()       
//--------------------------------------------------------FIM DAS FUNÇÕES ESPECÍFICAS-------------------------------------------------------------   
