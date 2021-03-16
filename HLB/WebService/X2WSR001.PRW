//---------------------------------------------------------------------------------------------------------------------------------------------
//Wederson L. Santana - Específico Marici - 31/12/2020  
//---------------------------------------------------------------------------------------------------------------------------------------------

#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function X2WSR001()
Return

//-------------------------

WSRESTFUL X2WSR001 DESCRIPTION "Serviço REST para consulta dos pedidos de compras - Tax.Id x Marici"

WSDATA PoNumero As String
WSDATA PoLinha As String
WSDATA ForneCod As String
WSDATA ForneLoja As String
WSDATA ForneCnpj As String
WSDATA PoProduto As String
WSDATA DataDe As String
WSDATA DataAte As String
WSDATA Token As String

WSMETHOD GET DESCRIPTION "Retorna consulta no compras " WSSYNTAX "/X2WSR001 || /X2WSR001/{}"

END WSRESTFUL

//-------------------------Classe

Class X2WSR001

data ClienNome	
data ClienEnd	
data ClienCep	
data ClienMun	
data ClienUf	
data ClienCnpj	
data ClienIe	
data ClienTel	
data ClienFax

data ForneCod
data ForneLoja
data ForneRazao
data ForneEnd
data ForneBair
data ForneCep
data ForneMun
data ForneUf
data ForneCnpj
data ForneIe
data ForneTel
data ForneFax

data PoNumero   
data PoLinha
data PoProduto
data PoDescric
data PoUnidMed
data PoNcm
data PoQtdLin
data PoUnidMed2    
data PoQtdLin2
data PoVrUnit
data PoVrTot
data PoAliqIpi
data PoDataEnt
data PoContaCtb
data PoItemCtb
data PoCredCtb   
data PoCcusto   
data PoNumSc      
data PoNumOp
data PoItemSaldo

Method New()
EndClass

Method New() Class X2WSR001
Return

//-------------------------

WSMETHOD GET WSRECEIVE PoNumero,PoLinha,ForneCod,ForneLoja,ForneCnpj,PoProduto,DataDe,DataAte,Token WSSERVICE X2WSR001
Local cPedido  := Upper(Alltrim(Self:PoNumero))
Local cLinha   := Upper(Alltrim(Self:PoLinha))
Local cCodFor  := Upper(Alltrim(Self:ForneCod))
Local cLojFor  := Upper(Alltrim(Self:ForneLoja))
Local cCodPro  := Upper(Alltrim(Self:PoProduto))
Local cCnpjFor := Alltrim(Self:ForneCnpj)
Local cDataDe  := Self:DataDe
Local cDataAte := Self:DataAte
Local cToken   := Self:Token

Local cTokenOk  := Alltrim(SuperGetMV("MV_XXTOKEN", .F.,"Hom@X2@2021"))
Local aArea     := GetArea()
Local oReturnPo 
Local aObjCab  as array
Local aObjLin  as array
Local cNumPc    := ""
Local cJson     := ""
Local aSM0Data  := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{"M0_NOMECOM","M0_ENDENT","M0_COMPENT","M0_BAIRENT","M0_CIDENT","M0_ESTENT","M0_TEL","M0_CGC","M0_FAX","M0_INSC","M0_CEPENT","M0_FAX"})

Local aArea     := GetArea()
Local nCab      := 1
Local nItem     
Local nVrTot    := 0
Local nItSaldo  := 0

cToken := Iif(Empty(cToken),"",cToken)

::SetContentType("application/json")

If cToken == cTokenOk

   fGeraDados(cPedido,cLinha,cCodFor,cLojFor,cCodPro,cDataDe,cDataAte,cCnpjFor)

   aObjCab := {}
   dbSelectArea("SQL")
   dbGotop()
   If! Eof()
      While! Eof()
             
            aAdd( aObjCab,  JsonObject():New() )        

            aObjCab[nCab]["ClienNome"] := Upper(Alltrim(aSM0Data[01][2]))
            aObjCab[nCab]["ClienEnd"]  := Upper(Alltrim(aSM0Data[02][2]))
            aObjCab[nCab]["ClienCep"]  := Upper(Alltrim(aSM0Data[11][2]))	
            aObjCab[nCab]["ClienMun"]  := Upper(Alltrim(aSM0Data[05][2]))	
            aObjCab[nCab]["ClienUf"]   := Upper(Alltrim(aSM0Data[06][2]))	
            aObjCab[nCab]["ClienCnpj"] := Upper(Alltrim(aSM0Data[08][2]))	
            aObjCab[nCab]["ClienIe"]   := Upper(Alltrim(aSM0Data[10][2]))	
            aObjCab[nCab]["ClienTel"]  := Upper(Alltrim(aSM0Data[07][2]))	
            aObjCab[nCab]["ClienFax"]  := Upper(Alltrim(aSM0Data[12][2]))
            aObjCab[nCab]["ForneCod"]  := SQL->C7_FORNECE
            aObjCab[nCab]["ForneLoja"] := SQL->C7_LOJA

            dbSelectArea("SA2")
            dbSetOrder(1)
            If dbSeek(xFilial("SA2")+SQL->C7_FORNECE+SQL->C7_LOJA)

               aObjCab[nCab]["ForneRazao"] := SA2->A2_NOME
               aObjCab[nCab]["ForneEnd"]   := SA2->A2_END
               aObjCab[nCab]["ForneBair"]  := SA2->A2_BAIRRO
               aObjCab[nCab]["ForneCep"]   := SA2->A2_CEP
               aObjCab[nCab]["ForneMun"]   := SA2->A2_MUN
               aObjCab[nCab]["ForneUf"]    := SA2->A2_EST
               aObjCab[nCab]["ForneCnpj"]  := SA2->A2_CGC
               aObjCab[nCab]["ForneIe"]    := SA2->A2_INSCR
               aObjCab[nCab]["ForneTel"]   := SA2->A2_TEL
               aObjCab[nCab]["ForneFax"]   := SA2->A2_FAX
        
            EndIf

            aObjCab[nCab]["PoNumero"]  := SQL->C7_NUM
            aObjLin := {}
                     
            nVrTot := 0
            nItem  := 1
            cNumPc := SQL->C7_NUM
            While! Eof().And. cNumPc == SQL->C7_NUM
               
      
                  aAdd( aObjLin,  JsonObject():New() )

                  aObjLin[nItem]["PoLinha"]    := SQL->C7_ITEM
               
                  dbSelectArea("SB1")
                  dbSetOrder(1)
                  If dbSeek(xFilial("SB1")+SQL->C7_PRODUTO)

                     aObjLin[nItem]["PoNcm"]      := SB1->B1_POSIPI
                     aObjLin[nItem]["PoUnidMed2"] := SB1->B1_SEGUM      

                  EndIf
                  nItSaldo:= (SQL->C7_QUANT - SQL->C7_QUJE)
         
                  aObjLin[nItem]["PoProduto"]  := SQL->C7_PRODUTO
                  aObjLin[nItem]["PoDescric"]  := NoAcento(SQL->C7_DESCRI)
                  aObjLin[nItem]["PoUnidMed"]  := SQL->C7_UM
                  aObjLin[nItem]["PoQtdLin"]   := nItSaldo
                  aObjLin[nItem]["PoQtdLin2"]  := SQL->C7_QTSEGUM
                  aObjLin[nItem]["PoVrUnit"]   := SQL->C7_PRECO 
                  aObjLin[nItem]["PoVrTot"]    := SQL->C7_TOTAL  
                  aObjLin[nItem]["PoAliqIpi"]  := SQL->C7_IPI
                  aObjLin[nItem]["PoDataEnt"]  := Dtos(SQL->C7_DATPRF)
                  aObjLin[nItem]["PoContaCtb"] := SQL->C7_CONTA 
                  aObjLin[nItem]["PoItemCtb"]  := SQL->C7_ITEMCTA 
                  aObjLin[nItem]["PoCredCtb"]  := SQL->C7_CLVL
                  aObjLin[nItem]["PoCcusto"]   := SQL->C7_CC
                  aObjLin[nItem]["PoNumSc"]    := SQL->C7_NUMSC      
                  aObjLin[nItem]["PoNumOp"]    := SQL->C7_OP
                  aObjLin[nItem]["PoItemSaldo"]:= nItSaldo * SQL->C7_PRECO
                  nVrTot += SQL->C7_TOTAL  
                  dbSelectArea("SQL")
                  dbSkip()
                  nItem ++
               
            End
            aObjCab[nCab]["PoVrTot"] := nVrTot
            aObjCab[nCab]["PoItem"]  := aObjLin
            nCab ++     
            
         End     
         oReturnPo :=  JsonObject():New()
         oReturnPo["infos"] := aObjCab

         cJson := oReturnPo:toJson()
      
         ::setResponse(cJson)

         cJson := FWJsonSerialize(oReturnPo,.F.,.T.)

         FwFreeObj(oReturnPo)

      Else      
         SetRestFault(400,"Empty")
      EndIf
   Else
      SetRestFault(400,"Token")
   EndIf

RestArea(aArea)
Return(.T.)

//-------------------------------------------------

Static Function fGeraDados(cPedido,cLinha,cCodFor,cLojFor,cCodPro,cDataDe,cDataAte,cCnpjFor)
Local cQuery
Local aStruSC7 := SC7->(dbStruct())

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := " SELECT SC7.* "
cQuery += " FROM SC7X20 SC7 "

If! Empty(cCnpjFor)
    cQuery += ", SA2X20 SA2 "
EndIf

cQuery += " WHERE SC7.D_E_L_E_T_ = ''"
cQuery += " AND C7_FILIAL = '"+xFilial("SC7")+"' "
cQuery += " AND C7_QUANT > C7_QUJE "

If! Empty(cCnpjFor)
    cQuery += "AND SA2.D_E_L_E_T_ = '' "
    cQuery += "AND A2_CGC = '"+cCnpjFor+"' "
    cQuery += "AND C7_FORNECE = A2_COD "
    cQuery += "AND C7_LOJA = A2_LOJA "
EndIf

If! Empty(cPedido)
         cQuery += " AND C7_NUM = '"+cPedido+"'"
EndIf         
If! Empty(cLinha)
         cQuery += " AND C7_ITEM = '"+cLinha+"'"
EndIf
If! Empty(cCodFor)
         cQuery += " AND C7_FORNECE = '"+cCodFor+"'"
         If! Empty(cLojFor)
             cQuery += " AND C7_LOJA = '"+cLojFor+"'"
         EndIf
EndIf
If! Empty(cCodPro)
         cQuery += " AND C7_PRODUTO = '"+cCodFor+"'"
EndIf
If! Empty(cDataDe)
         cQuery += " AND C7_EMISSAO >= '"+cDataDe+"'"
         cQuery += " AND C7_EMISSAO <= '"+cDataAte+"'
EndIf     

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL",.T.,.T.)

For nX := 1 To Len(aStruSC7)
	If aStruSC7[nX][2]!="C"
		TcSetField("SQL",aStruSC7[nX][1],aStruSC7[nX][2],aStruSC7[nX][3],aStruSC7[nX][4])
	EndIf
Next nX

Return

//----------------------------

Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

Return Upper(cString)

