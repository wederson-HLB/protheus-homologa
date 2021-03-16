//---------------------------------------------------------------------------------------------------------------------------------------------
//Wederson L. Santana - Específico Marici - 31/12/2020
//---------------------------------------------------------------------------------------------------------------------------------------------
  
#include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

User Function X2FAT001()
Local nPosCod 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosDesc 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCRI"})
Local nPosLoc 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPosPrc 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPosTot 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPosFCI 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_FCICOD"})
Local nPosRem   := 0

Local aListRem  := {}
Local lMarca    := .F.

Local nOpc      := 0
Local nX        := 0
Local nPos      := 0
Local lMarca    := .F.
Local nQtde1Tot := 0
Local nQtde2Tot := 0
Local aTamX3    := TamSX3("D3_QUANT")
Local aTamX3Cus := TamSX3("D3_CUSTO1")
Local aCampos   := {"",AllTrim(RetTitle("C2_NUM")),AllTrim(RetTitle("D3_COD")),AllTrim(RetTitle("B1_DESC")),AllTrim(RetTitle("D3_QUANT")),AllTrim(RetTitle("D3_CUSTO1"))}
Local oOk       := LoadBitMap(GetResources(), "LBOK")
Local oNo       := LoadBitMap(GetResources(), "LBNO")
Local nPreco    := 0
Local cItem     := ""
Local nQtdRem   := 0
Local cNumFCI   := ""

If Sc6->(FieldPos("C6_XXREMOP")) > 0
   nPosRem 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_XXREMOP"})
EndIf

fOkDados()

dbSelectArea("SD2")
dbSetOrder(3)
If dbSeek(xFilial("SD2")+M->C5_XXNOTA+M->C5_XXSERIE)
    cNumFCI:=SD2->D2_FCICOD
EndIf 

If! Empty(cNumFCI)
    dbSelectArea("SQL")
    While! Eof()
        dbSelectArea("SB1")
        dbSetOrder(1)
        dbSeek(xFilial("SB1")+SQL->D3_COD)
    
        If aScan(aCols,{|x| AllTrim(x[nPosCod])==AllTrim(SQL->D3_COD)}) == 0
            nQtdRem := (SQL->D3_QUANT - fConRem(SQL->D3_COD,SQL->D3_OP))
            If nQtdRem > 0 
                aAdd(aListRem,{lMarca, SQL->C2_NUM, SQL->D3_COD , SB1->B1_DESC, nQtdRem, Iif( Empty(SQL->D3_CUSTO1),SQL->D4_XXCUSTO,SQL->D3_CUSTO1),SQL->D3_LOCAL,SQL->D3_OP, cNumFCI})
            EndIf
        EndIf

        dbSelectArea("SQL")   
        dbSkip()
    End    

    If !Empty(aListRem) 
	    aSort(aListRem,,,{|x,y| x[2] < y[2]})

		DEFINE MSDIALOG oDlg FROM 50,40 TO 285,750 TITLE "Selecione as remessas do projeto - NF "+M->C5_XXSERIE+" / "+M->C5_XXNOTA+" - Específico Marici" Of oMainWnd PIXEL //
		oListBox := TWBrowse():New(05,4,243,86,,aCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:SetArray(aListRem)
		oListBox:bLDblClick := {|| aListRem[oListBox:nAt,1] := !aListRem[oListBox:nAt,1]}
		oListBox:bLine := {|| {If(aListRem[oListBox:nAt,1],oOk,oNo),aListRem[oListBox:nAT,2],;
                                                                    aListRem[oListBox:nAT,3],;
                                                                    aListRem[oListBox:nAT,4],;
											Str(aListRem[oListBox:nAT,5],aTamX3[1],aTamX3[2]),;
											Str(aListRem[oListBox:nAT,6],aTamX3Cus[1],aTamX3Cus[2]) }}
	
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,oDlg:End())},{||(nOpc := 0,oDlg:End())})

        If nOpc == 1
           For nX := 1 To Len(aListRem) 

               If! aListRem[nX,1] == .F.
                    If !Empty(aCols[n,nPosCod]) .And. aScan(aCols,{|x| AllTrim(x[nPosCod])==AllTrim(aListRem[nX][3])}) == 0
		                aAdd(aCols,aClone(aCols[n]))
                        aCols[Len(aCols),nPosItem] := StrZero(Len(aCols),2)
                    EndIf
			        nPos := Len(aCols)

                    nPreco := aListRem[nx][6] / aListRem[nx][5]

                    aCols[nPos,nPosCod]   := aListRem[nx][3]
                    aCols[nPos,nPosDesc]  := aListRem[nx][4]
                    aCols[nPos,nPosLoc]   := aListRem[nx][7]
			        aCols[nPos,nPosPrc]   := nPreco
                    aCols[nPos,nPosQuant] := aListRem[nx][5]
                    aCols[nPos,nPosTot]   := aListRem[nx][5] * nPreco
                   
                    If nPosRem>0
                       aCols[nPos,nPosRem] := aListRem[nx][8]
                    EndIf

                    aCols[nPos,nPosFCI] := aListRem[nx][9]

               EndIf    
               
           Next
        EndIf
    Else
	    MsgInfo("Ordem de produção não encontrada ou já atendida.","Remessa p/ projeto")
    EndIf
    aSort(aCols,,,{|x,y| x[1] < y[1]})
Else
    MsgInfo("Não encontrado o número da FCI no documento fiscal informado."+Chr(13)+Chr(10)+"Verifique Série: "+M->C5_XXSERIE+" NF: "+M->C5_XXNOTA+"."," A t e n ç ã o - FCI")
EndIf
Return()

//------------------

Static Function fOkDados()
Local cQuery

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery:= "SELECT C5_NUM,C5_NOTA,C5_SERIE,C2_NUM,D3_COD,D3_CF,D3_QUANT,D3_CUSTO1,D4_XXCUSTO,D4_QTDEORI,D3_LOCAL,D3_OP  " 
cQuery+= "FROM "+RetSqlName("SC5")+" SC5 "
cQuery+= "    ,"+RetSqlName("SC6")+" SC6 "
cQuery+= "	  ,"+RetSqlName("SC2")+" SC2 "
cQuery+= "	  ,"+RetSqlName("SD3")+" SD3 "
cQuery+= "	  ,"+RetSqlName("SD4")+" SD4 "
cQuery+= "WHERE SC5.D_E_L_E_T_ = '' "
cQuery+= "AND SC6.D_E_L_E_T_ = '' "
cQuery+= "AND SC6.D_E_L_E_T_ = '' "
cQuery+= "AND SD3.D_E_L_E_T_ = '' "
cQuery+= "AND SD4.D_E_L_E_T_ = '' "
cQuery+= "AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery+= "AND C5_NOTA = '"+M->C5_XXNOTA+"' "
cQuery+= "AND C5_SERIE = '"+M->C5_XXSERIE+"' "
cQuery+= "AND C5_FILIAL = C6_FILIAL "
cQuery+= "AND C5_NUM = C6_NUM "
cQuery+= "AND C6_FILIAL = C2_FILIAL "
cQuery+= "AND C6_NUMOP = C2_NUM "
cQuery+= "AND C2_FILIAL = D3_FILIAL "
cQuery+= "AND C6_NUMOP+C2_ITEM+C2_SEQUEN = D3_OP "
cQuery+= "AND D3_ESTORNO <> 'S' "
cQuery+= "AND D3_CF IN ('RE1','RE0') "
cQuery+= "AND D3_FILIAL = D4_FILIAL "
cQuery+= "AND D3_OP = D4_OP "
cQuery+= "AND D3_COD = D4_COD "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL",.T.,.T.)

Return

//-----------------------------------

Static Function fConRem(cProduto,cOp)
Local cQryRem := ""
Local nQtdRet := 0

If Select("SQL_REM") > 0
	SQL_REM->(dbCloseArea())
EndIf

cQryRem:= "SELECT C6_QTDVEN "
cQryRem+= "FROM "+RetSqlName("SC5")+" SC5 "
cQryRem+= "    ,"+RetSqlName("SC6")+" SC6 "
cQryRem+= "WHERE SC5.D_E_L_E_T_ = '' "
cQryRem+= "AND SC6.D_E_L_E_T_ = '' "
cQryRem+= "AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQryRem+= "AND C5_XXSERIE = '"+M->C5_XXSERIE+"' "
cQryRem+= "AND C5_XXNOTA = '"+M->C5_XXNOTA+"' "
cQryRem+= "AND C5_FILIAL = C6_FILIAL "
cQryRem+= "AND C5_NUM = C6_NUM "
cQryRem+= "AND C6_XXREMOP = '"+cOp+"' "
cQryRem+= "AND C6_PRODUTO = '"+cProduto+"' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRem),"SQL_REM",.T.,.T.)

dbSelectArea("SQL_REM")
While !Eof()
    nQtdRet += SQL_REM->C6_QTDVEN
    dbSkip()
End

Return(nQtdRet)
