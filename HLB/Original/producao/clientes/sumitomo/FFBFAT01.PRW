#Include "RWMAKE.CH"


/*
Funcao      : FFBFAT01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para liberação de notas fiscais , usuário somente emitirá a nota após liberação.
Autor     	: Wederson Lourenço Santana
Data     	: 14/06/05
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Faturamento.
Cliente     : Sumitomo.
*/
 
*-------------------------*
 User Function FFBFAT01()      
*-------------------------*

If cEmpAnt $ "FF"
   _aCores  := {{"F2_P_FLAG=='1'","ENABLE"    },; //Liberado
	             {"F2_P_FLAG==' '","BR_AMARELO"},; //Liberação Pendente
	             {"F2_P_FLAG=='2'","DISABLE"   }}  //Nota Fiscal emitida
   aRotina  := {{"Pesquisar",'AxPesqui',0,1},{"Liberar",'U_fOkLib()',0,2 },{"Estornar",'U_fCanLib()',0,3},{"Legenda",'U_fLegend()',0,4}}
   cCadastro:= "S U M I T O M O"

   fCriaPerg("FFFAT1    ")
   Pergunte("FFFAT1    ",.T.)

   _cOpc:=If(Mv_Par03==4," /1/2",If(Mv_Par03==3,"2",If(Mv_Par03==2," ","1")))
   DbSelectArea("SF2")
   DbSetFilter({|| F2_EMISSAO >= Mv_Par01.And.F2_EMISSAO <= Mv_Par02.And.F2_P_FLAG$_cOpc},' F2_EMISSAO >= Mv_Par01.And.F2_EMISSAO <= Mv_Par02.And.F2_P_FLAG$_cOpc')
   Mbrowse(01, 01, 30, 70, "SF2",,,,,,_aCores)
Else 
    MsgInfo("Especifico SUMITOMO !","A T E N C A O")
Endif   
Return

//----------------------------------------------------------Libera

User Function fOkLib()
aProc:=fVerNfLib()
If! Empty(aProc[1])
    If aProc[1] $ "N" .And. Empty(SF2->F2_P_FLAG)
       nUsado :=0
       aCols  :={}
       aHeader:={}
       RegToMemory("SF2",.F.)
       DbSelectArea("SX3")
       DbSeek("SD2")
       While !Eof().And.(X3_ARQUIVO=="SD2")
	          If X3USO(X3_USADO).And.cNivel>=X3_NIVEL
    	          nUsado:=nUsado+1
                Aadd(aHeader,{TRIM(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,;
                              X3_DECIMAL,.T.,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT } )
	          Endif
             DbSkip()
       End
       DbSelectArea("SD2")
       DbsetOrder(3)
       DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
       While !Eof().And.D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA==;
                        SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		        AADD(aCols,Array(nUsado+1))
		        For _ni:=1 to nUsado
			         aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		        Next 
		        aCols[Len(aCols),nUsado+1]:=.F.
		        DbSkip()
       End

       If Len(aCols)>0
          nOpcE         :=nOpcG :=2
          cTitulo       :="S U M I T O M O "
	       cAliasEnchoice:="SF2"
	       cAliasGetD    :="SD2"
	       cLinOk        :=".T."
	       cTudOk        :=".T."
	       cFieldOk      :=".T."
	       aCpoEnchoice  :={"F2_CLIENTE","F2_LOJA","F2_DOC","F2_SERIE","F2_COND","F2_EMISSAO","F2_VALBRUT"}

	       If Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
		       Reclock("SF2",.F.)
		       Replace SF2->F2_P_FLAG With "1"
		       MsUnlock()
	       Endif
       Endif
    ElseIf SF2->F2_P_FLAG $ "1"
           MsgInfo("Nota Fiscal ja liberada !","A T E N C A O") 
    ElseIf SF2->F2_P_FLAG $ "2"
           MsgInfo("Nota Fiscal ja emitida !","A T E N C A O ")
    Else
           MsgInfo("Existem notas pendentes !","A T E N C A O ")      
    Endif   
Endif

Return

//----------------------------------------------------------Estorna

User Function fCanLib()
If SF2->F2_P_FLAG $ "1"
   nUsado :=0
   aCols  :={}
   aHeader:={}
   RegToMemory("SF2",.F.)
   DbSelectArea("SX3")
   DbSeek("SD2")
   While !Eof().And.(X3_ARQUIVO=="SD2")
	      If X3USO(X3_USADO).And.cNivel>=X3_NIVEL
    	      nUsado:=nUsado+1
            Aadd(aHeader,{TRIM(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,;
                          X3_DECIMAL,.T.,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT } )
	      Endif
         DbSkip()
   End
   DbSelectArea("SD2")
   DbsetOrder(3)
   DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
   While !Eof().And.D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA==;
                    SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		   AADD(aCols,Array(nUsado+1))
		   For _ni:=1 to nUsado
			    aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		   Next 
		   aCols[Len(aCols),nUsado+1]:=.F.
		   DbSkip()
   End

   If Len(aCols)>0
      nOpcE         :=nOpcG :=2
      cTitulo       :="S U M I T O M O "
	   cAliasEnchoice:="SF2"
	   cAliasGetD    :="SD2"
	   cLinOk        :=".T."
	   cTudOk        :=".T."
	   cFieldOk      :=".T."
	   aCpoEnchoice  :={"F2_CLIENTE","F2_LOJA","F2_DOC","F2_SERIE","F2_COND","F2_EMISSAO","F2_VALBRUT"}
      
	   If Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
		   Reclock("SF2",.F.)
		   Replace SF2->F2_P_FLAG With " "
		   MsUnlock()
	   Endif	
   Endif
ElseIf Empty(SF2->F2_P_FLAG)
       MsgInfo("Nao e possivel estornar sem antes liberar !","A T E N C A O ")
Else
       MsgInfo("Nota Fiscal ja emitida !","A T E N C A O")
Endif   

Return

//----------------------------------------------------------Legenda

User Function fLegend()
BrwLegenda(cCadastro,"Legenda",{{"ENABLE","Liberada"                },;
		                          {"BR_AMARELO","Aguardando Liberacao"},;
		                          {"DISABLE","Emitida"}})
Return(.T.)

//----------------------------------------------------------Cria Sx1

Static Function fCriaPerg(cPerg)
aSvAlias:={Alias(),IndexOrd(),Recno()}
i:=j:=0

aRegs:={}
//           1      2    3                     4  5  6        7   8  9 1 0 11  12 13         14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38
AADD(aRegs,{cPerg,"01","Dt Geracao de      ?","","","mv_ch1","D",08,00,00,"G","","Mv_Par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Dt Geracao ate     ?","","","mv_ch2","D",08,00,00,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Visualiza Pedidos  ?","","","mv_ch3","N",01,00,00,"C","","Mv_Par03","Liberados","","","","","Pendentes","","","","","Emitidos","","","","","Todos","","","","","","","","","","","",""})

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

//-----------------------------------------------------------Cria/Executa Procedure                 

Static Function fVerNfLib()       

	If! TcSpExist("SUMITOMO_FFBFAT01_SP")
	    TcSqlExec("GO "+Chr(13)+Chr(10)+;
	              "SET ANSI_NULLS ON "+Chr(13)+Chr(10)+;
                 "GO "+Chr(13)+Chr(10)+;
                 "SET QUOTED_IDENTIFIER ON "+Chr(13)+Chr(10)+;
                 "GO "+Chr(13)+Chr(10)+;
	              "CREATE PROC dbo.SUMITOMO_FFBFAT01_SP"+Chr(13)+Chr(10)+;
	              "(@IN_Nota VarChar(09)"+Chr(13)+;
	              ",@IN_Filial VarChar(02)"+Chr(13)+;
	              ",@OUT_Res VarChar(01) OUTPUT)"+Chr(13)+;
	              "AS"+Chr(13)+Chr(10)+;
	              "BEGIN"+Chr(13)+Chr(10)+;
	              "IF (SELECT COUNT(*) FROM "+RetSqlName("SF2")+Chr(13)+Chr(10)+;
	              "   WHERE F2_FILIAL =@IN_Filial "+Chr(13)+;
	              "   AND F2_P_FLAG = '' AND F2_DOC+F2_SERIE < @IN_Nota "+Chr(13)+;
	              "   AND D_E_L_E_T_ <> '*') > 0"+Chr(13)+;
	              "   SELECT @OUT_Res = 'S'"+Chr(13)+;
	              "ELSE"+Chr(13)+Chr(10)+;
	              "   SELECT @OUT_Res = 'N'"+Chr(13)+;
	              "END"+Chr(13)+Chr(10)+;
	              "GO")                            
	Endif     

aRet:=TcSpExec("SUMITOMO_FFBFAT01_SP",SF2->F2_DOC+SF2->F2_SERIE,xFilial("SF2"))

If Empty(aRet)
	Alert("SUMITOMO_FFBFAT01_SP "+TcSqlError("SUMITOMO_FFBFAT01_SP"))
Endif

Return(aRet)	