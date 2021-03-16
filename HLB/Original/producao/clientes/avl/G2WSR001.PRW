//---------------------------------------------------------------------------------------------------------------------------------------------
//Wederson L. Santana - Específico Marici - 31/12/2020 
//---------------------------------------------------------------------------------------------------------------------------------------------

#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
// empresa G2/FR/FY
User Function G2WSFCTB()
Return

//-------------------------

WSRESTFUL G2WSRCTB DESCRIPTION "Serviço REST para consulta contábil - AVL APLICATIVOS"

//WSDATA DataLctos As String
WSDATA CodEmp As String
WSDATA DataDe As String
WSDATA DataAte As String
WSDATA Moeda As String
WSDATA Token As String

WSDATA SaldoConta AS String OPTIONAL
WSDATA LimiteReg AS INTEGER OPTIONAL
WSDATA PesquisaReg AS INTEGER OPTIONAL

WSMETHOD GET DESCRIPTION "Retorna consulta contábil " WSSYNTAX "/G2WSRCTB || /G2WSRCTB/{}"

END WSRESTFUL

//-------------------------Classe

Class G2WSRCTB
data CT2_DATA
data CT2_LOTE
data CT2_SBLOTE
data CT2_DOC
data CT2_LINHA
data CT2_MOEDLC
data CT2_KEY
data CT2_HIST
data CONTA
data CT1_DESC01
data CCPartida
data CT2_EMPORI
data CT2_FILORI
data CCUSTO
data ITEM
data DIVISAO
data A2_NREDUZ
data A2_NOME
data A2_CGC
data cSerie
data cNotaFis
data nVrDebito
data nVrCredit
data nSaldo
data Delete
data cTipoLcto
data CCPartidaDesc 
data CCCPartida    
data CCITEM        
data CCDIVISAO     
data nSaldoCC      
data Registro

Method New()
EndClass

Method New() Class G2WSRCTB
Return

//------------------------

Class G2WSRLOG
data nCode
data cMessage

Method New()
EndClass

Method New() Class G2WSRLOG
Return

//-------------------------

WSMETHOD GET WSRECEIVE CodEmp,DataDe,DataAte,Moeda,Token WSSERVICE G2WSRCTB
Local cCodEmp   := Upper(Alltrim(Self:CodEmp))
Local cDataDe   := Self:DataDe
Local cDataAte  := Self:DataAte
Local cMoeda    := Self:Moeda
Local cToken    := Self:Token

Local cTokenOk := Alltrim(SuperGetMV("MV_XXTOKEN", .F.,"G2@Hlb@2021"))
Local oObjCtb  := JsonObject():New()//G2WSRCTB():New()
Local oObjLog  := G2WSRLOG():New()
Local cJson    := ""
Local cHist    := ""
Local cTime    := ""
Local nCount   := 1
Local nStart   := 1
Local nReg     := 0
Local nAux     := 0
Local aListCT2 := {}
Local nPage    := 1
Local nLimite  := Iif(Empty(self:limiteReg),0,self:limiteReg)
Local nPesqReg := Iif(Empty(self:pesquisaReg),0,self:pesquisaReg)
Local cConsulta:= Iif(Empty(self:saldoConta),"N",Upper(self:saldoConta))
Local nTotReg  := 0

Private cAliasCT2 := GetNextAlias()

cMoeda := Iif(Empty(cMoeda),"01",cMoeda)
cToken := Iif(Empty(cToken),"",cToken)

::SetContentType("application/json")

If cToken == cTokenOk

   cTime:=Time()
  // Conout("G2WSR001 - Inicio processamento -"+cTime+".")

   nTotReg:= fTotDados(cCodEmp,cDataDe,cDataAte,cMoeda)

   nLimite:= Iif(nLimite==0,nTotReg,nLimite)

   fGeraDados(cCodEmp,cDataDe,cDataAte,cMoeda,nPesqReg)

   If ( cAliasCT2 )->( ! Eof() )
 
      COUNT TO nRecord
      //-------------------------------------------------------------------
      // nStart -> primeiro registro da pagina
      // nReg -> numero de registros do inicio da pagina ao fim do arquivo
      //-------------------------------------------------------------------
      If nLimite >0
         If nPage > 1
            nStart := ( ( nPage - 1 ) * nLimite ) + 1
            nReg := nRecord - nStart + 1
         Else
            nReg := nRecord
         EndIf
      EndIf
     
      //-------------------------------------------------------------------
      // Posiciona no primeiro registro.
      //-------------------------------------------------------------------
      ( cAliasCT2 )->( DBGoTop() )
 
      //-------------------------------------------------------------------
      // Valida a exitencia de mais paginas
      //-------------------------------------------------------------------
      If nReg > nLimite
         oObjCtb['hasNext'] := .T.
      Else
         oObjCtb['hasNext'] := .F.
      EndIf
   Else
      //-------------------------------------------------------------------
      // Nao encontrou registros
      //-------------------------------------------------------------------
      oObjCtb['hasNext'] := .F.
   EndIf

   oObjCtb['totRegistro'] := nTotReg
  
   While ( cAliasCT2 )->( ! Eof() ) 
         
         If nCount >= nStart

            nAux++ 
            aAdd( aListCT2 , JsonObject():New() )

            aListCT2[nAux]['CT2_DATA']   := ( cAliasCT2 )->CT2_DATA
            aListCT2[nAux]['CT2_LOTE']   := ( cAliasCT2 )->CT2_LOTE//Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_NOME ) )
            aListCT2[nAux]['CT2_SBLOTE'] := ( cAliasCT2 )->CT2_SBLOTE
            aListCT2[nAux]['CT2_DOC']    := ( cAliasCT2 )->CT2_DOC
            aListCT2[nAux]['CT2_LINHA']  := ( cAliasCT2 )->CT2_LINHA
            aListCT2[nAux]['CT2_MOEDLC'] := ( cAliasCT2 )->CT2_MOEDLC
            aListCT2[nAux]['CT2_KEY']    := ( cAliasCT2 )->CT2_KEY

            aListCT2[nAux]['CT2_EMPORI'] := ( cAliasCT2 )->CT2_EMPORI
            aListCT2[nAux]['CT2_FILORI'] := ( cAliasCT2 )->CT2_FILORI
            aListCT2[nAux]['CT2_DC']     := ( cAliasCT2 )->CT2_DC

            cHist:=fGetHist(( cAliasCT2 )->CT2_FILIAL+( cAliasCT2 )->CT2_DATA+( cAliasCT2 )->CT2_LOTE+( cAliasCT2 )->CT2_SBLOTE+( cAliasCT2 )->CT2_DOC,( cAliasCT2 )->CT2_SEQUEN,( cAliasCT2 )->CT2_SEQLAN)
         
            aListCT2[nAux]['CT2_HIST'] := EncodeUTF8(( cAliasCT2 )->CT2_HIST)+" "+Alltrim(cHist)

            dData := CToD(SubStr(( cAliasCT2 )->CT2_DATA,7,2)+"/"+SubStr(( cAliasCT2 )->CT2_DATA,5,2)+"/"+SubStr(( cAliasCT2 )->CT2_DATA,1,4))  

            Do Case
               Case ( cAliasCT2 )->CT2_DC == "1"

                  aListCT2[nAux]['CONTA']     := (cAliasCT2)->CT2_DEBITO
                  aListCT2[nAux]['CCPartida'] := ""

                  CT1->(dbSetOrder(1))
                  CT1->(dbSeek(xFilial("CT1")+( cAliasCT2 )->CT2_DEBITO))
                  aListCT2[nAux]['CT1_DESC01'] := AllTrim(CT1->CT1_DESC01)

                  aListCT2[nAux]['CCUSTO']    := AllTrim(( cAliasCT2 )->CT2_CCD)
                  aListCT2[nAux]['ITEM']      := AllTrim(( cAliasCT2 )->CT2_ITEMD)
                  aListCT2[nAux]['DIVISAO']   := AllTrim(( cAliasCT2 )->CT2_CLVLDB)
                  aListCT2[nAux]['nVrDebito'] := ( cAliasCT2 )->CT2_VALOR 
                  aListCT2[nAux]['nVrCredit'] := 0
                  aListCT2[nAux]['nSaldo']    := Iif( cConsulta == "S",SaldoConta(( cAliasCT2 )->CT2_DEBITO,dData,( cAliasCT2 )->CT2_MOEDLC,( cAliasCT2 )->CT2_TPSALD,1),0)

               Case ( cAliasCT2 )->CT2_DC == "2"

                  aListCT2[nAux]['CONTA']     := ""
                  aListCT2[nAux]['CCPartida'] := AllTrim(( cAliasCT2 )->CT2_CREDIT)
                        
                  CT1->(dbSetOrder(1))
                  CT1->(dbSeek(xFilial("CT1")+( cAliasCT2 )->CT2_CREDIT))
                  aListCT2[nAux]['CCPartidaDesc'] := AllTrim(CT1->CT1_DESC01)
                                
                  aListCT2[nAux]['CCCPartida'] := ( cAliasCT2 )->CT2_CCC
                  aListCT2[nAux]['CCITEM']     := AllTrim(( cAliasCT2 )->CT2_ITEMC)
                  aListCT2[nAux]['CCDIVISAO']  := AllTrim(( cAliasCT2 )->CT2_CLVLCR)
                  aListCT2[nAux]['nVrCredit']  := ( cAliasCT2 )->CT2_VALOR
                  aListCT2[nAux]['nVrDebito']  := 0
                  aListCT2[nAux]['nSaldoCC']   := Iif( cConsulta == "S",SaldoConta(( cAliasCT2 )->CT2_DEBITO,dData,( cAliasCT2 )->CT2_MOEDLC,( cAliasCT2 )->CT2_TPSALD,1),0)

               Case ( cAliasCT2 )->CT2_DC == "3"

                  aListCT2[nAux]['CONTA']  := AllTrim(( cAliasCT2 )->CT2_DEBITO)
                     
                  CT1->(dbSetOrder(1))
                  CT1->(dbSeek(xFilial("CT1")+( cAliasCT2 )->CT2_DEBITO))
                  aListCT2[nAux]['CT1_DESC01'] := AllTrim(CT1->CT1_DESC01)
                   
                  aListCT2[nAux]['CCUSTO']     := AllTrim(( cAliasCT2 )->CT2_CCD)
                  aListCT2[nAux]['ITEM']       := AllTrim(( cAliasCT2 )->CT2_ITEMD)
                  aListCT2[nAux]['DIVISAO']    := AllTrim(( cAliasCT2 )->CT2_CLVLDB)
                  aListCT2[nAux]['nVrDebito']  := ( cAliasCT2 )->CT2_VALOR
                  aListCT2[nAux]['nSaldo']     := Iif( cConsulta == "S",SaldoConta(( cAliasCT2 )->CT2_DEBITO,dData,( cAliasCT2 )->CT2_MOEDLC,( cAliasCT2 )->CT2_TPSALD,1),0)
                 
                  aListCT2[nAux]['CCPartida']  := AllTrim(( cAliasCT2 )->CT2_CREDIT)
                  CT1->(dbSetOrder(1))
                  CT1->(dbSeek(xFilial("CT1")+( cAliasCT2 )->CT2_CREDIT))
                  aListCT2[nAux]['CCPartidaDesc'] := AllTrim(CT1->CT1_DESC01)

                  aListCT2[nAux]['CCCPartida']    := ( cAliasCT2 )->CT2_CCC
                  aListCT2[nAux]['CCITEM']        := AllTrim(( cAliasCT2 )->CT2_ITEMC)
                  aListCT2[nAux]['CCDIVISAO']     := AllTrim(( cAliasCT2 )->CT2_CLVLCR) 
                  aListCT2[nAux]['nVrCredit']     := (cAliasCT2)->CT2_VALOR
                  aListCT2[nAux]['nSaldoCC']      := Iif( cConsulta == "S",SaldoConta(( cAliasCT2 )->CT2_DEBITO,dData,( cAliasCT2 )->CT2_MOEDLC,( cAliasCT2 )->CT2_TPSALD,1),0)

            EndCase

            CTL->(dbSetOrder(1))
            If CTL->(dbSeek(xFilial("CTL")+(cAliasCT2)->CT2_LP))
               Do Case 
                  Case (cAliasCT2)->CT2_LP $ "510/511"
                        dbSelectArea(CTL->CTL_ALIAS)
                        dbSetOrder(Val(CTL->CTL_ORDER))
                        If dbSeek((cAliasCT2)->CT2_KEY)
                           SA2->(dbSetOrder(1))
                           If SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
                              aListCT2[nAux]['A2_NREDUZ'] := AllTrim(SA2->A2_NREDUZ)
                              aListCT2[nAux]['A2_NOME']   := AllTrim(SA2->A2_NOME)
                              aListCT2[nAux]['A2_CGC']    := AllTrim(SA2->A2_CGC)
                              aListCT2[nAux]['cSerie']    := SubStr(SE2->E2_PREFIXO,3,1)
                              aListCT2[nAux]['cNotaFis']  := SE2->E2_NUM
                           EndIf     
                        EndIf   
                   Case (cAliasCT2)->CT2_LP == "650"
                        dbSelectArea(CTL->CTL_ALIAS)
                        dbSetOrder(Val(CTL->CTL_ORDER))
                        If dbSeek((cAliasCT2)->CT2_KEY)
                           SA2->(dbSetOrder(1))
                           If SA2->(dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
                              aListCT2[nAux]['A2_NREDUZ'] := AllTrim(SA2->A2_NREDUZ)
                              aListCT2[nAux]['A2_NOME']   := AllTrim(SA2->A2_NOME)
                              aListCT2[nAux]['A2_CGC']    := AllTrim(SA2->A2_CGC)
                              aListCT2[nAux]['cSerie']    := SD1->D1_SERIE
                              aListCT2[nAux]['cNotaFis']  := SD1->D1_DOC
                           EndIf     
                        EndIf
                   Case (cAliasCT2)->CT2_LP $ "530/532/562/564"
                        dbSelectArea(CTL->CTL_ALIAS)
                        dbSetOrder(Val(CTL->CTL_ORDER))
                        If dbSeek((cAliasCT2)->CT2_KEY)
                           SA2->(dbSetOrder(1))
                           If SA2->(dbSeek(xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA))
                              aListCT2[nAux]['A2_NREDUZ'] := AllTrim(SA2->A2_NREDUZ)
                              aListCT2[nAux]['A2_NOME']   := AllTrim(SA2->A2_NOME)
                              aListCT2[nAux]['A2_CGC']    := AllTrim(SA2->A2_CGC)
                              aListCT2[nAux]['cSerie']    := SE5->E5_PREFIXO
                              aListCT2[nAux]['cNotaFis']  := SE5->E5_NUMERO
                           EndIf     
                        EndIf
               End Case
            EndIf

            CTL->(dbSetOrder(1))
            If CTL->(dbSeek(xFilial("CTL")+(cAliasCT2)->CT2_LP))
               Do Case 
                  Case (cAliasCT2)->CT2_LP $ "510/511"
                        dbSelectArea(CTL->CTL_ALIAS)
                         dbSetOrder(Val(CTL->CTL_ORDER))
                        If dbSeek((cAliasCT2)->CT2_KEY)
                           SA2->(dbSetOrder(1))
                           If SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
                              aListCT2[nAux]['A2_NREDUZ'] := AllTrim(SA2->A2_NREDUZ)
                              aListCT2[nAux]['A2_NOME']   := AllTrim(SA2->A2_NOME)
                              aListCT2[nAux]['A2_CGC']    := AllTrim(SA2->A2_CGC)
                              aListCT2[nAux]['cSerie']    := SubStr(SE2->E2_PREFIXO,3,1)
                              aListCT2[nAux]['cNotaFis']  := SE2->E2_NUM
                           EndIf     
                        EndIf   
                  Case (cAliasCT2)->CT2_LP == "650"
                        dbSelectArea(CTL->CTL_ALIAS)
                        dbSetOrder(Val(CTL->CTL_ORDER))
                        If dbSeek((cAliasCT2)->CT2_KEY)
                           SA2->(dbSetOrder(1))
                           If SA2->(dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
                              aListCT2[nAux]['A2_NREDUZ'] := AllTrim(SA2->A2_NREDUZ)
                              aListCT2[nAux]['A2_NOME']   := AllTrim(SA2->A2_NOME)
                              aListCT2[nAux]['A2_CGC']    := AllTrim(SA2->A2_CGC)
                              aListCT2[nAux]['cSerie']    := SD1->D1_SERIE
                              aListCT2[nAux]['cNotaFis']  := SD1->D1_DOC
                           EndIf     
                        EndIf
                  Case (cAliasCT2)->CT2_LP $ "530/532/562/564"
                        dbSelectArea(CTL->CTL_ALIAS)
                        dbSetOrder(Val(CTL->CTL_ORDER))
                        If dbSeek((cAliasCT2)->CT2_KEY)
                           SA2->(dbSetOrder(1))
                           If SA2->(dbSeek(xFilial("SA2")+SE5->E5_CLIFOR+SE5->E5_LOJA))
                              aListCT2[nAux]['A2_NREDUZ'] := AllTrim(SA2->A2_NREDUZ)
                              aListCT2[nAux]['A2_NOME']   := AllTrim(SA2->A2_NOME)
                              aListCT2[nAux]['A2_CGC']    := AllTrim(SA2->A2_CGC)
                              aListCT2[nAux]['cSerie']    := SE5->E5_PREFIXO
                              aListCT2[nAux]['cNotaFis']  := SE5->E5_NUMERO
                           EndIf     
                        EndIf
                  End Case
            EndIf
            aListCT2[nAux]['DELETE']    := ( cAliasCT2 )->DELETADO
            aListCT2[nAux]['REGISTRO']  := ( cAliasCT2 )->REGISTRO

            If Len(aListCT2) >= nLimite
               Exit
            EndIf
 
         EndIf
         
         nCount++
        ( cAliasCT2 )->( DBSkip() )
              
   End     
Else

   oObjLog:self:nCode   := "400"
   oObjLog:self:cMessage := "Token invalido"
   ::SetResponse(FWJsonSerialize(oObjLog))

EndIf

oObjCtb['G2WSRCTB'] := aListCT2
 
cJson:= FwJsonSerialize( oObjCtb )
 
FreeObj(oObjCtb)
 
Self:SetResponse( cJson ) 

SetRestFault(200,"OK",.T.)
Conout("G2WSR001 - Tempo processamento -"+cTime+"-"+Time())

( cAliasCT2 )->( DBCloseArea() )

Return(.T.)

//-------------------------------------------------

Static Function fGeraDados(cCodEmp,cDataDe,cDataAte,cMoeda,nRecno)
Local cTabela := "CT2"+cCodEmp+"0"
Local cWhere := " CT2_DC <> '4'  "

cWhere += " AND CT2_DATA >= '"+cDataDe+"' "
cWhere += " AND CT2_DATA <= '"+cDataAte+"' "
cWhere += " AND CT2_MOEDLC = '"+cMoeda+"' "
cWhere += " AND CT2_EMPORI = '"+cCodEmp+"' "

If nRecno >0
   cWhere += " AND R_E_C_N_O_ > "+AllTrim(Str(nRecno))+" "
EndIf 

cTabela := '%'+cTabela+'%'  
cWhere := '%'+cWhere+'%'

BEGINSQL Alias cAliasCT2
  
   SELECT D_E_L_E_T_ AS DELETADO,R_E_C_N_O_ AS REGISTRO,*
   FROM %Exp:cTabela% CT2
   WHERE %Exp:cWhere%
   Order by R_E_C_N_O_

ENDSQL

Return

//-------------------------------------------------

Static Function fTotDados(cCodEmp,cDataDe,cDataAte,cMoeda)
Local cAliasTMP := GetNextAlias()
Local nTotReg := 0
Local cTabela := "CT2"+cCodEmp+"0"
Local cWhereTot := " CT2_DC <> '4'  "

cWhereTot += " AND CT2_DATA >= '"+cDataDe+"' "
cWhereTot += " AND CT2_DATA <= '"+cDataAte+"' "
cWhereTot += " AND CT2_MOEDLC = '"+cMoeda+"' "
cWhereTot += " AND CT2_EMPORI = '"+cCodEmp+"' "

cTabela := '%'+cTabela+'%'  
cWhereTot := '%'+cWhereTot+'%'

BEGINSQL Alias cAliasTMP
  
   SELECT R_E_C_N_O_
   FROM %Exp:cTabela% CT2
   WHERE %Exp:cWhereTot%
  
ENDSQL

If ( cAliasTMP )->( ! Eof() )
    COUNT TO nTotReg
EndIf      

( cAliasTMP )->( DBCloseArea() )

Return(nTotReg)

//-------------------------------------------------

Static Function fGetHist(cChave,cSequen,cSeqLan)
Local cRet := ""
Local cQryHist := ""

If Select("TEMPHIST") > 0
	TEMPHIST->(dbCloseArea())
EndIf

cQryHist := " SELECT R_E_C_N_O_"
cQryHist += " FROM "+RetSqlName("CT2")
cQryHist += " WHERE CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC = '"+cChave+"'"
cQryHist += " AND CT2_DC = '4'"
cQryHist += " AND CT2_SEQUEN = '"+cSequen+"'"
cQryHist += " AND CT2_SEQLAN = '"+cSeqLan+"'"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryHist),"TEMPHIST",.T.,.T.)

dbSelectArea("TEMPHIST")
While !EOF()

       dbSelectArea("CT2")
       dbGoto(TEMPHIST->R_E_C_N_O_)
       If! Eof()
	        cRet += CT2->CT2_HIST
       EndIf

       dbSelectArea("TEMPHIST")
	    dbSkip()
EndDo

Return cRet



