#include "topconn.ch"
#include "rwmake.ch"  

/*
Funcao      : SNF022
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Vendas no exercicio por vendedor	  
Autor     	: 
Data     	: 
Obs         : 
TDN         :
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 17/07/2012
Módulo      : Faturamento
Cliente     : SNF
*/ 

*-----------------------*
 User Function SNF022()
*-----------------------*

If !(cEmpAnt $ "BH" )  
   MsgStop("Rotina especifica SNF","Atenção") 
   Return .F.
EndIf



SetPrvt("cPerg,cImpOrdem,cOrdem,&cArqTmp,&cArqTmp2,cArqTmp,cArqTmp2,dVectoDe")
cPerg := "SNF02B    "

CriaPerg()
                                                  
If Pergunte(cPerg,.T.)                             
	
	dEmissDe := Mv_Par01
	dEmissAt := Mv_Par02
	nOpc     := Mv_Par03
	nMoeda   := Mv_Par04
	nValQtd  := Mv_Par05

	tamanho  :='G'
	limite   :=220
	titulo   :="VENDAS NO EXERCICIO POR VENDEDOR / CLIENTE - "+If(nValQtd=1,"VALORES EM ","Q U A N T I D A D E S ")+;
	            If(nValQtd=1,If(nMoeda=1,"R$ SEM IMPOSTOS","U$$ SEM IMPOSTOS"),"")+" - "+Dtoc(dEmissDe)+" a "+Dtoc(dEmissAt)
	cDesc1   :='Faturamento'
	cDesc2   :='Especifico SNF'
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
	aOrd     := '' 
	wnRel    := NomeProg := 'SNF022'
	nImp     :=022
	nImpAcu  :=204
	
	wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)
	
	If LastKey()== 27 .or. nLastKey== 27 .or. nLastKey== 286
		Return
	Endif
	
	SetDefault(aReturn,cString)

	If ".##R"$aReturn[6]  //Wederson -->27/06/05 - Se o relatório for via email está disposicionando
	   nImp   :=023
	   nImpAcu:=205
	Endif
	
	If LastKey() == 27 .or. nLastKey == 27
		Return
	Endif
	
	Processa({|| fGeraSql()},titulo)                            
	
Endif

Return

//---Regua do Relatório
//123456789d123456789v123456789t123456789q123456789c123456789s123456789t123456789o123456789n123456789*123456789d123456789v123456789t123456789q123456789c123456789s123456789t123456789o123456789n123456789*123456789d123456789v
//XxxxxxxxxxxxxxX XxxxxxxxxxxxxxX   9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 9999999999.99 
//                                  1                  2                3           4           5            6           7              8              9           10             11           12              13

Static Function fImprime()

Cabec2 := "Codigo          Descricao                 Janeiro     Fevereiro         Marco         Abril          Maio         Junho         Julho        Agosto      Setembro       Outubro      Novembro      Dezembro        Acumulado"
nLin   := 100      
aMeses := Array(12)
aCli   := Array(12)
aVend  := Array(12)
aGeral := Array(12)
_nGeral:= 0
For i:=1 To Len(aGeral)
    aGeral[i]:=0.00
Next     

DbSelectArea("SQL") 
DbGoTop()
SetRegua(RecCount())
Do While.Not.Eof()      
	SA3->(DbSetOrder(1))
   SA3->(DbSeek(xFilial("SA3")+SQL->F2_VEND1))
   Cabec  :="Vendedor "+If(Empty(F2_VEND1),"Nao Informado",AllTrim(SA3->A3_NOME))
   Cabec  := Space((limite/2)-(Len(Cabec)/2))+Cabec
   Cabec(titulo,Cabec,Cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	nLin   :=9
	For i:=1 To Len(aVend)
       aVend[i]:=0.00
   Next     
   _nTotalVend :=0
   
   _cVend   :=F2_VEND1
   Do While.Not.Eof().And._cVend == F2_VEND1
       If nLin > 60
		    Cabec(titulo,Cabec,Cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
		    nLin:=9
		 Endif
       For i:=1 To Len(aCli)
           aCli[i]:=0.00
       Next     
       _nTotalCli :=0
       
       _cCli   :=F2_CLIENTE+F2_LOJA
       Do While.Not.Eof().And._cVend+_cCli == F2_VEND1+F2_CLIENTE+F2_LOJA
          If nLin > 60
		       Cabec(titulo,Cabec,Cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
				 nLin:=9
			 Endif
          If nOpc == 2
             SB1->(DbSetOrder(1))
             SB1->(DbSeek(xFilial("SB1")+SQL->D2_COD))
             @ nLin,000 Psay D2_COD+" "+SubStr(SB1->B1_DESC,1,20)
          Endif   
          _nTotalProd:=0
          For i:=1 To Len(aCli)
              aMeses[i]:=0.00
          Next     
                 
          _cProd   :=Alltrim(D2_COD)
          Do While.Not.Eof().And._cVend+_cCli+_cProd ==F2_VEND1+F2_CLIENTE+F2_LOJA+Alltrim(D2_COD)
             _nSoma:=0                              
             If nLin > 60
		          Cabec(titulo,Cabec,Cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
				    nLin:=9
			    Endif
             
             _cMes :=AllTrim(Str(Month(D2_EMISSAO)))
             Do While.Not.Eof().And._cVend+_cCli+_cProd+_cMes == F2_VEND1+F2_CLIENTE+F2_LOJA+Alltrim(D2_COD)+AllTrim(Str(Month(D2_EMISSAO)))
                _nSoma :=If(nValQtd==1,If(nMoeda==1,((D2_TOTAL*0.9535)-D2_VALICM),(((D2_TOTAL*0.9535)-D2_VALICM)/RecMoeda(D2_EMISSAO,"2"))),D2_QUANT)
                aMeses[Val(_cMes)]+=_nSoma
                aCli  [Val(_cMes)]+=_nSoma
                aVend [Val(_cMes)]+=_nSoma
                aGeral[Val(_cMes)]+=_nSoma
                _nTotalProd  +=_nSoma
                _nTotalCli   +=_nSoma
                _nTotalVend  +=_nSoma
                _nGeral      +=_nSoma  
                DbSkip()
                IncRegua()
             EndDo
          EndDo 
          If nOpc == 2
             If nLin > 60
		          Cabec(titulo,Cabec,Cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
				    nLin:=9
			    Endif
             For i :=1 To Len(aMeses) 
                 @ nLin,021+(14*i) Psay aMeses[i] Picture "@E 9999999999.99"
             Next
             @ nLin,203 Psay _nTotalProd Picture "@E 9,999,999,999.99"
             nLin+=1
          Endif   
       EndDo
       If nOpc == 2
          If nLin > 60
		 	    Cabec(titulo,Cabec,Cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
		       nLin:=9
		    Endif
          SA1->(DbSetOrder(1))
          SA1->(DbSeek(xFilial("SA1")+_cCli))
          @ nLin,000 Psay Alltrim(SA1->A1_NREDUZ)
          For i :=1 To Len(aCli) 
              @ nLin,nImp+(14*i) Psay aCli[i] Picture "@E 9999999999.99"
          Next
          @ nLin,nImpAcu Psay _nTotalCli Picture "@E 9,999,999,999.99"
          nLin+=2
       Endif   
	EndDo     
	If nLin > 60
	   Cabec(titulo,Cabec,Cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
		nLin:=9
	Endif
   @ nLin,000 Psay "Vendedor: "+If(Empty(SubStr(SA3->A3_NOME,1,25)),"Nao Informado",SubStr(SA3->A3_NOME,1,25))
   For i :=1 To Len(aVend) 
       @ nLin,nImp+(14*i) Psay aVend[i] Picture "@E 9999999999.99"
   Next
   @ nLin,nImpAcu Psay _nTotalVend Picture "@E 9,999,999,999.99"
   nLin+=2
EndDo                  
nLin +=1
@ nLin,000 Psay "Total Geral: "
For i :=1 To Len(aGeral) 
    @ nLin,nImp+(14*i) Psay aGeral[i] Picture "@E 9999999999.99"
Next
@ nLin,nImpAcu Psay _nGeral Picture "@E 9,999,999,999.99"
nLin ++
Roda(0,"","G")
If aReturn[5] == 1
	Set Printer To
	Commit
	OurSpool(aReturn[6])
Endif
MS_FLUSH()
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf
Return

//-----------------------------------------------------------

Static Function fGeraSql()
ProcRegua(10)
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf    
IncProc(4)
aStruSF2:= SF2->(dbStruct())
cQuery:= " SELECT F2_VEND1,F2_CLIENTE,F2_LOJA,D2_COD,D2_EMISSAO,D2_TOTAL,D2_QUANT,D2_VALICM"
cQuery+= " FROM  "+RetSqlName("SD2")+","+RetSqlName("SF2")
cQuery+=	" WHERE D2_DOC+D2_SERIE = F2_DOC+F2_SERIE "+Chr(13)
cQuery+= " AND D2_EMISSAO BETWEEN '"+Dtos(dEmissDe)+"' AND '"+Dtos(dEmissAt)+"'"+Chr(13)
cQuery+= " AND D2_TES IN ('56V','57D','69D','70D','73A','74A','75A','92D','95C','77T') "+Chr(13)
cQuery+= " AND SD2BH0.D_E_L_E_T_<>'*' AND SF2BH0.D_E_L_E_T_<>'*' "//+Chr(10)+Chr(13)          
cQuery+= " ORDER BY F2_VEND1 , F2_CLIENTE , F2_LOJA , D2_COD , D2_EMISSAO"

TCQuery cQuery ALIAS "SQL" NEW
//cQuery+= " AND  F2_VEND1 = '003'AND F2_CLIENTE = '1032'"+Chr(13)    

TCSetField("SQL","D2_EMISSAO","D",08,0)
TCSetField("SQL","D2_TOTAL"  ,"N",14,2)
IncProc(5)
For nX := 1 To Len(aStruSF2)
	If aStruSF2[nX,2]<>"C"
		TcSetField("SQL",aStruSF2[nX,1],aStruSF2[nX,2],aStruSF2[nX,3],aStruSF2[nX,4])
	EndIf
Next nX
IncProc(1)
cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
DbCloseArea()
DbUseArea(.T.,,cArqTMP,"SQL",.T.)

DbSelectArea("SQL")
If RecCount("SQL")> 1
	RptStatus({|| fImprime()},titulo)                            
Else
   MsgInfo("Nao existem dados para serem emitidos !","A T E N C A O ")
Endif	
Return

//-------------------------------------------------------------

Static Function CriaPerg()

_sAlias := Alias()

DbSelectArea("SX1")
DbSetOrder(1)

cPerg := PADR(cPerg,10)
aRegs := {}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","De data de Emissao ?","","","mv_ch1","D",08,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
aAdd(aRegs,{cPerg,"02","Ate data de Emissao?","","","mv_ch2","D",08,0,0,"G","","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","",   ""})
aAdd(aRegs,{cPerg,"03","Imprimir Sintetico ?","","","mv_ch3","N",01,0,1,"C","","mv_par03","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",   ""})
aAdd(aRegs,{cPerg,"04","Moeda              ?","","","mv_ch4","N",01,0,1,"C","","mv_par04","Real"  ,"","","","","Dolar"  ,"","","","","","","","","","","","","","","","","","","",   ""})
aAdd(aRegs,{cPerg,"05","Valor/Quantidade   ?","","","mv_ch5","N",01,0,1,"C","","mv_par05","Valor"  ,"","","","","Quantidade"  ,"","","","","","","","","","","","","","","","","","","",   ""})

For i:=1 to Len(aRegs)
	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

DbSelectArea(_sAlias)
Return(Nil)