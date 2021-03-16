#include "topconn.ch"
#include "rwmake.ch" 

/*
Funcao      : D1RCOM01
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Relatório de necessidade de compras
Autor     	: Wederson Lourenço Santana
Data     	: 27/07/2005  
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Compras
Cliente     : Tellabs
*/


*------------------------*
 User Function D1RCOM01()
*------------------------*

If cEmpAnt $ "D1"
   cPerg := "RCOM01    "
   CriaPerg()

   If Pergunte(cPerg,.T.)
	
	   dEmissDe := Mv_Par01
	   dEmissAt := Mv_Par02
	   cComprDe := Mv_Par03
	   cComprAt := Mv_Par04
	   cForneDe := Mv_Par05
	   cForneAt := Mv_Par06
	   cProduDe := Mv_Par07
	   cProduAt := Mv_Par08

	   tamanho  :='G'
	   limite   :=220
	   titulo   :="Necessidade de Compras"
	   cDesc1   :='Especifico'
	   cDesc2   :='Tellabs do Brasil Ltda'
	   cDesc3   :=''
	   aReturn  := { 'Zebrado', 1,'Financeiro ', 1, 2, 1,'',1 }
	   lImprAnt := .F.
	   aLinha   := { }
	   nLastKey := 0
	   imprime  := .T.
	   cbtxt    := SPACE(10)
	   cbcont   := 0
	   cString  := 'SQL'
	   nLin     := 100
	   m_pag    := 1
	   aOrd     := {'Curva ABC','Por Projeto' }
	   wnRel    := NomeProg := cPerg
	
	   wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)
	
	   If LastKey()== 27 .or. nLastKey== 27 .or. nLastKey== 286
		   Return
	   Endif
	
	   SetDefault(aReturn,cString)
	
	   If LastKey() == 27 .or. nLastKey == 27
		   Return
	   Endif
	   Processa({|| fOkProc()},titulo)                            
	Endif   
Else
	 MsgInfo("Relatorio especifico Tellabs !","A T E N C A O")
Endif

Return

//------------------------------------------------------

Static Function fOkProc() 

fGeraSql()    
aDados:={}
DbSelectArea("SQL") 
DbGoTop()
ProcRegua(RecCount())
Do While.Not.Eof()
      
      nVenda  :=0         
      cDesc   :=SubStr(B1_DESC,1,30)
      cProj   :=C6_P_PRJ
      cChave  :=C6_PRODUTO
      While C6_PRODUTO == cChave
            nVenda +=(C6_QTDVEN-C6_QTDENT)
            IncProc("Produto "+AllTrim(cChave)+" - "+SubStr(cDesc,1,20) )
            DbSkip()
      End
           
      nCompra :=0
      SC7->(DbSetOrder(2))
      SC7->(DbSeek(xFilial("SC7")+cChave))
      While xFilial("SC7")+cChave == SC7->C7_FILIAL+SC7->C7_PRODUTO
            If SC7->C7_FORNECE >= cForneDe.And.SC7->C7_FORNECE <= cForneAt
               If SC7->C7_USER >= cComprDe.And.SC7->C7_USER <= cComprAt 
                  If SC7->C7_EMISSAO >= dEmissDe.And.SC7->C7_EMISSAO <= dEmissAt
                     If (SC7->C7_QUANT - SC7->C7_QUJE) > 0
                         nCompra +=(SC7->C7_QUANT-SC7->C7_QUJE)
                     Endif    
                  Endif   
               Endif   
           Endif
           SC7->(DbSkip())
      End
      
      SB1->(DbSetOrder(1))
      SB1->(DbSeek(xFilial("SB1")+cChave))
      SB2->(DbSetOrder(1))
      SB2->(DbSeek(xFilial("SB2")+cChave))
      While xFilial("SB2")+cChave == SB2->B2_FILIAL+SB2->B2_COD   
            nPlano  :=(SB2->B2_QATU+nCompra)-nVenda
            nComprar:=((SB2->B2_QATU+nCompra)-nVenda)-SB1->B1_EMIN
            nComprar:=If(SB1->B1_EMIN > nPlano,nPlano-SB1->B1_EMIN,If(SB1->B1_EMIN < nPlano,0,nComprar))
            //              1     2         3             4           5     6       7              8             9           10           11                     12                   13
            AADD(aDados,{cChave,cDesc,SB2->B2_LOCAL,SB2->B2_QATU,nCompra,nVenda,nPlano,SB2->B2_QATU-nVenda,SB1->B1_EMIN,SB2->B2_VATU1,(nComprar*-1),StrTran(cProj," ",""),cProj})
            SB2->(DbSkip())
      End   
EndDo

If AllTrim(Str(aReturn[8]))$ "1"                
   aSort(aDados,,, {|x, y| x[11] > y[11]})                   
   RptStatus({|| fImprime()},titulo)                            
Else
   aSort(aDados,,, {|x, y| x[12]+TransForm(x[11],"@E 999,999,999,999.99") > y[12]+TransForm(y[11],"@E 999,999,999,999.99")})                      
   RptStatus({|| fImpProj()},titulo)                            
Endif   

Return

//-------------------------------------------
//---Regua do Relatório
//------------------------------------------------------------
//123456789d123456789v123456789t123456789q123456789c123456789s123456789t123456789o123456789n123456789*123456789d123456789v123456789t12345789q123456789c123456789s123456789t123456789o123456789n123456789*123456789d123456789v
//Produto            Descricao                          Local          Em Maos            Compras             Vendas       Planejamento   Disponivel Vendas Minimo Inventario        Custo Medio              Comprar

Static Function fImprime()

SetRegua(Len(aDados))      

nLin   := 100         
Cabec1 := "Curva ABC"   
Cabec2 := "Produto            Descricao                          Local          Em Maos            Compras             Vendas       Planejamento   Disponivel Vendas    Minimo Inventario       Custo Medio           Comprar"
For i:=1 To Len(aDados)
       IncRegua()
       If nLin > 60
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,15)
          nLin := 9
       Endif
       @ nLin,000 Psay aDados[i][01]
       @ nLin,019 Psay aDados[i][02]
       @ nLin,056 Psay aDados[i][03]
       @ nLin,065 Psay aDados[i][04] Picture "@E 999,999,999"
       @ nLin,084 Psay aDados[i][05] Picture "@E 999,999,999"
       @ nLin,103 Psay aDados[i][06] Picture "@E 999,999,999"
       @ nLin,122 Psay aDados[i][07] Picture "@E 999,999,999"
       @ nLin,142 Psay aDados[i][08] Picture "@E 999,999,999"
       @ nLin,163 Psay aDados[i][09] Picture "@E 999,999,999"
       @ nLin,182 Psay aDados[i][10] Picture "@E 999,999.99"
       @ nLin,199 Psay aDados[i][11] Picture "@E 999,999,999"
       nLin ++
Next
   
Roda(0,"","M")

If aReturn[5] == 1
	Set Printer TO
	Commit
	OurSpool(aReturn[6])
Endif

MS_FLUSH()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

Return

//-----------------------------------------------------------
//-------------------------------------------
//---Regua do Relatório
//------------------------------------------------------------
//123456789d123456789v123456789t123456789q123456789c123456789s123456789t123456789o123456789n123456789*123456789d123456789v123456789t12345789q123456789c123456789s123456789t123456789o123456789n123456789*123456789d123456789v
//Produto            Descricao                          Local          Em Maos            Compras             Vendas       Planejamento   Disponivel Vendas Minimo Inventario        Custo Medio              Comprar

Static Function fImpProj()

SetRegua(Len(aDados))      

nLin   := 100         
Cabec1 := "Projeto"   
Cabec2 := "Produto            Descricao                          Local          Em Maos            Compras             Vendas       Planejamento   Disponivel Vendas    Minimo Inventario       Custo Medio           Comprar"
i      := 1
While i <= Len(aDados)
      IncRegua()
       If nLin > 60
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,15)
          nLin := 9
       Endif
       @ nLin,000 Psay If(Empty(aDados[i][13]),"Projeto nao informado",aDados[i][13])
       nLin ++                                                                       
       @ nLin,000 Psay Replicate("-",220)
       nLin ++
       cQuebra:= aDados[i][12]
       While cQuebra == aDados[i][12]
             If nLin > 60
                Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,15)
                nLin := 9
             Endif
             @ nLin,000 Psay aDados[i][01]
             @ nLin,019 Psay aDados[i][02]
             @ nLin,056 Psay aDados[i][03]
             @ nLin,065 Psay aDados[i][04] Picture "@E 999,999,999"
             @ nLin,084 Psay aDados[i][05] Picture "@E 999,999,999"
             @ nLin,103 Psay aDados[i][06] Picture "@E 999,999,999"
             @ nLin,122 Psay aDados[i][07] Picture "@E 999,999,999"
             @ nLin,142 Psay aDados[i][08] Picture "@E 999,999,999"
             @ nLin,163 Psay aDados[i][09] Picture "@E 999,999,999"
             @ nLin,182 Psay aDados[i][10] Picture "@E 999,999.99"
             @ nLin,199 Psay aDados[i][11] Picture "@E 999,999,999"
             nLin ++
             i++     
             If i > Len(aDados)
                Exit
             Endif
        End     
        nLin ++
End  

Roda(0,"","M")

If aReturn[5] == 1
	Set Printer TO
	Commit
	OurSpool(aReturn[6])
Endif

MS_FLUSH()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

Return

//-----------------------------------------------------------

Static Function fGeraSql()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSC6:= SC6->(dbStruct())

cQuery := "SELECT C6_PRODUTO,B1_DESC,C6_QTDVEN,C6_QTDENT,C6_P_PRJ "+Chr(10)
cQuery += "FROM "+RetSqlName("SC6")+" AS SC6 ,"+RetSqlName("SB1")+" AS SB1"+Chr(10)
cQuery += "WHERE SC6.C6_FILIAL = '"+xFilial("SC6")+"'"+Chr(10)
cQuery += "AND SC6.C6_PRODUTO = SB1.B1_COD "+Chr(10)
cQuery += "AND SC6.C6_PRODUTO BETWEEN '"+cProduDe      +"' AND '"+cProduAt      +"' "+Chr(10)
cQuery += "AND SC6.C6_NOTA = '' "+Chr(10)
cQuery += "AND SC6.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*'"+Chr(10)
cQuery += "ORDER BY C6_PRODUTO"  

TCQuery cQuery ALIAS "SQL" NEW

For nX := 1 To Len(aStruSC6)
	If aStruSC6[nX,2]<>"C"
		TcSetField("SQL",aStruSC6[nX,1],aStruSC6[nX,2],aStruSC6[nX,3],aStruSC6[nX,4])
	EndIf
Next nX

cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SQL",.T.)

Return

//-------------------------------------------------------------

Static Function CriaPerg()
aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0

aRegs:={}
//               1      2    3                     4  5  6        7   8  9 1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegs,{cPerg,"01","Emissao de      ?","","","mv_ch1","D",08,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Emissao ate     ?","","","mv_ch2","D",08,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Comprador de    ?","","","mv_ch3","C",06,00,00,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","SY1","","",""})
AADD(aRegs,{cPerg,"04","Comprador ate   ?","","","mv_ch4","C",06,00,00,"G","","Mv_Par04","","","","","","","","","","","","","","","","","","","","","","","","","SY1","","",""})
AADD(aRegs,{cPerg,"05","Fornecedor de   ?","","","mv_ch5","C",06,00,00,"G","","Mv_Par05","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","",""})
AADD(aRegs,{cPerg,"06","Fornecedor ate  ?","","","mv_ch6","C",06,00,00,"G","","Mv_Par06","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","",""})
AADD(aRegs,{cPerg,"07","Produto de      ?","","","mv_ch7","C",15,00,00,"G","","Mv_Par07","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","",""})
AADD(aRegs,{cPerg,"08","Produto ate     ?","","","mv_ch8","C",15,00,00,"G","","Mv_Par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","",""})

DbSelectArea("SX1")
For i := 1 to Len(aRegs)
	DbSeek(aRegs[i,1]+aRegs[i,2])
	If !Found()
		While !RecLock("SX1",.T.)
		End
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	Endif
Next i

dbSelectArea(aSvAlias[1])
dbSetOrder(aSvAlias[2])
dbGoto(aSvAlias[3])

Return(Nil)
