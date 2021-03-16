#Include "rwmake.ch"
#Include "topconn.ch"
#Include "colors.ch"

/*
Funcao      : YYPGPE04
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Rotina para inclusao de títulos da Folha de Pagamento no Contas a Pagar gerando lancamentos contabeis.
	      Serao processados os Liquidos a serem pagos lidos no arquivo de movimento mensal da Folha SRC.  
Autor	    : Wederson L. Santana 
Data        : 06/12/05
Obs         : Específico para clientes Pryor de Folha Pagamento
	      Os titulos serao gerados para que o Financeiro emita cheque.
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 14/12/2012
Módulo      : Faturamento
Cliente     : Todos 
*/

*-------------------------*
User Function YYPGPE04()
*-------------------------*

SetPrvt("_cHist,_cSx5,cMatDe,cMatAt")
SetPrvt("cArquivo ,cLoteEST,nHdlPrv")

Private _cNatureza := Space(10)
Private _cConta    := Space(20)
Private cCombo     := "MENSAL"
Private cCombo2    := "Aberta"
Private aItens     := {"MENSAL","QUINZENAL","1.PARC13","2.PARC13","RESCISAO","FERIAS"}
Private aItens2    := {"Aberta","Fechada"}
Private _dData     := Ctod("  /  /  ")
cArquivo :=cLoteEST:=""
nHdlPrv  :=nTotal  :=0
cMatDe   :=Space(06)
cMatAt   :=Space(06)    
lRescisao := .F.

@ 200,001 To 580,390 Dialog oLeTxt Title "Integracao Folha - Financeiro "
@ 002,005 To 190,190
@ 008,018 Say "Especifico  P R Y O R " COLOR CLR_HRED, CLR_WHITE 
@ 018,018 Say "Geracao do Financeiro - Lancamentos Contabeis" COLOR CLR_HBLUE, CLR_WHITE 
@ 048,018 ComboBox cCombo  Items aItens  Size 50,50
@ 062,018 ComboBox cCombo2 Items aItens2 Size 50,50
@ 062,070 Say "Processa Folha"
@ 079,018 Get _dData Size 50,100 
@ 079,070 Say "Data do Credito / Fechamento - Folha"

@ 095,018 Say "Rescisao / Ferias - Informe a matricula " COLOR CLR_HBLUE, CLR_WHITE 
@ 108,018 Say "Matricula de" COLOR CLR_HBLUE, CLR_WHITE
@ 108,058 Get cMatDe F3 "SRA" Size 050,050
@ 118,018 Say "Matricula ate" COLOR CLR_HBLUE, CLR_WHITE
@ 118,058 Get cMatAt F3 "SRA" Size 050,050 Valid! Vazio() .And. cMatAt >= cMatDe //.And. Existchav("SRA")

@ 138,018 Say "Ultima execucao:  "+Dtoc(GetMv("MV_FOLFIN"))
@ 148,018 Say "Verifique a data base do Sistema " COLOR CLR_HRED, CLR_WHITE 

@ 168,128 BmpButton Type 01 Action Processa({|| fOkProc() } ,"Processando...")
@ 168,158 BmpButton Type 02 Action Close(oLeTxt)      
Activate Dialog oLeTxt Centered

SA2->(DbSetOrder(1))
Return               


*-------------------------*
Static Function fOkProc()
*-------------------------*

Close(oLeTxt)
Private aVetor := {}
lOk     :=.T.                                  
_cConta :="211130001"
If AllTrim(GetMv("MV_MCONTAB")) $ "CON"
   If dDataBase<GetMv("MV_DATADE") .OR. dDataBase>GetMv("MV_DATAATE")
	   MsgInfo("Periodo contabil de : "+ dtoc(GetMv("MV_DATADE")) + " ate: " + dtoc(GetMv("MV_DATAATE"))+Chr(10)+Chr(13)+;
	           "A Contabilidade deve atualizar os parametros","A T E N C A O")
	   lOk:=.F.        
	EndIf      
   SI1->(DbSetOrder(1))
   If! SI1->(DbSeek(xFilial("SI1")+_cConta ))
       MsgInfo("Conta contabil nao cadastrada : "+_cConta,"A T E N C A O")
   EndIf
Else
    fValidaCtb()
    DbSelectArea("CCTG")
    If CTG_STATUS <> '1'
       lOk:=.F.
       MsgInfo("Calendário contábil bloqueado."+Chr(10)+Chr(13)+;
               "Calendário :"+CTG_CALEND+Chr(10)+Chr(13)+;
               "Exercício  :"+CTG_EXERC+Chr(10)+Chr(13)+;
               "Período    :"+CTG_PERIOD+Chr(10)+Chr(13))
    Endif
    CT1->(DbSetOrder(1))
    If! CT1->(DbSeek(xFilial("CT1")+_cConta ))
        MsgInfo("Conta contabil nao cadastrada : "+_cConta,"A T E N C A O")
    EndIf
EndIf
If lOk
  If "MENSAL" $ cCombo
	 If "Aberta" $ cCombo2
		
		DbSelectArea("SX5")
		If! DbSeek(xFilial("SX5")+"09FIN")
			RecLock("SX5",.T.)
			FIELD->X5_FILIAL   := xFilial("SX5")
			FIELD->X5_TABELA   := "09"
			FIELD->X5_CHAVE    := "FIN"
			FIELD->X5_DESCRI   := "1100"
			FIELD->X5_DESCSPA  := "1100"
			FIELD->X5_DESCENG  := "1100"
			MsUnLock()
		EndIf
		
		_cSx5 := X5_DESCRI

		DbSelectArea("SRC")
		DbSetOrder(1)
		DbGotop()
		ProcRegua(RecCount())		
		Do While.Not.Eof()
		  	_cMat     := SRC->RC_MAT
			_cNatureza:="2102"
			fCriaFornec(SRC->RC_MAT,_cNatureza,_cConta)
			DbSelectArea("SRC")
			While _cMat = SRC->RC_MAT 
				IncProc("Processando: "+SRC->RC_MAT+SRC->RC_PD)
            SRV->(DbSetOrder(1))
            SRV->(DbSeek(xFilial("SRV")+SRC->RC_PD))
			//If SRV->RV_CODFOL $ "047"
			If SRV->RV_CODFOL == STRZERO(47,TAMSX3("RV_CODFOL")[1])
               If RC_FILIAL $ xFilial("SRC")
				      If RC_DATA < DDATABASE
				         MsgInfo("Data de emissao maior que o vencimento "+Chr(10)+Chr(15)+;
				                 "Funcionario :"+SRC->RC_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
				                 "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
				                 "Valor :"+TransForm(RC_VALOR,"999,999,999.99"),"A T E N C A O")
				      Else
				         SED->(DbSetOrder(1))
			            If SED->(DbSeek(xFilial("SED")+_cNatureza ))			            
				         		SRA->(DbSetOrder(1))
				               SRA->(DbSeek(xFilial("SRA")+SRC->RC_MAT))
			                  _cNumTit := "   "
			                  _cNumTit += STRZERO(VAL(DTOS(RC_DATA)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
			                //_cNumTit += SubStr(Dtoc(RC_DATA),1,2)+SubStr(Dtoc(RC_DATA),4,2)+SubStr(Dtoc(RC_DATA),7,2)
			                  _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                 				_cHist   := "Folha Mensal / "+SRA->RA_NOME     
			                  If fGravaOk(_cNumTit,RC_VALOR,RC_DATA) 
					               nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYPGPE04",Subs(cUsuario,7,6),@cArquivo)
					               nTotal  := DetProva(nHdlPrv,"510","YYPGPE04",AllTrim(_cSX5))
					               RodaProva(nHdlPrv,nTotal)
				 	               Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.F.)   
			                  Endif    
                     Else
				               MsgInfo("Natureza financeira nao cadastrada :"+_cNatureza+Chr(10)+Chr(15)+;
				                     "Funcionario :"+SRC->RC_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
				                     "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
				                     "Valor :"+TransForm(RC_VALOR,"999,999,999.99"),"A T E N C A O") 
				         Endif   
				      Endif
				   Endif   
				Endif       
				DbSelectArea("SRC")
				DbSkip()
			End
		EndDo
	Else
		cVerba :=""
		SRV->(DbSetOrder(1))
		If SRV->(DbSeek(xFilial("SRV")+"252"))
		   cVerba +="252','"
		Endif
		SRV->(DbSetOrder(2))
		If SRV->(DbSeek(xFilial("SRV")+STRZERO(47,TAMSX3("RV_CODFOL")[1])))
			//While SRV->RV_CODFOL == "047"
			While SRV->RV_CODFOL == STRZERO(47,TAMSX3("RV_CODFOL")[1])
				cVerba+=SRV->RV_COD+"','"
				SRV->(DbSkip())
			End
			DbSelectArea("SX5")
			If! DbSeek(xFilial("SX5")+"09FIN")
				RecLock("SX5",.T.)
				SX5->X5_FILIAL   := xFilial("SX5")
				SX5->X5_TABELA   := "09"
				SX5->X5_CHAVE    := "FIN"
				SX5->X5_DESCRI   := "1100"
				SX5->X5_DESCSPA  := "1100"
				SX5->X5_DESCENG  := "1100"
				MsUnLock()
			EndIf
			_cSx5 := SX5->X5_DESCRI
			
			fGeraSrd()
			cont:=0
			DbSelectArea("SQL")
			DbGotop()
			ProcRegua(RecCount())
			Do While.Not.Eof()
				SA2->(DbSetOrder(3))
				If! SA2->(DbSeek(xFilial("SA2")+SQL->RA_CIC))
					RecLock("SA2",.T.)
					Replace A2_FILIAL  With xFILIAL("SA2")
					Replace A2_COD     With GetSx8Num("SA2","A2_COD")
					Replace A2_LOJA    With "01"
					Replace A2_NOME    With SQL->RA_NOME
					Replace A2_NREDUZ  With SubStr(SQL->RA_NOME,1,20)
					Replace A2_END     With SQL->RA_ENDEREC
					Replace A2_BAIRRO  With SQL->RA_BAIRRO
					Replace A2_MUN     With SQL->RA_MUNICIP
					Replace A2_EST     With SQL->RA_ESTADO
					Replace A2_CEP     With SQL->RA_CEP
					Replace A2_CGC     With SQL->RA_CIC
					Replace A2_TEL     With SQL->RA_TELEFON
					Replace A2_NATUREZ With "2102"
					Replace A2_CONTA   With "211130001"
					Replace A2_TIPO    With "F"
					MsUnLock()
					ConfirmSx8()
				Endif
				DbSelectArea("SQL")
				SED->(DbSetOrder(1))
			   If! SED->(DbSeek(xFilial("SED")+"2102"))
					MsgInfo("Natureza Financeira nao cadastrada : 2102 "+Chr(13)+;
					        "Matricula   : "+RA_MAT +Chr(13)+;
				           "Funcionario : "+RA_NOME+Chr(13)+;
				           "Cod.Fornec. : "+SA2->A2_COD,"A T E N C A O")
			   Endif
				SI1->(DbSetOrder(1))
			   If! SI1->(DbSeek(xFilial("SI1")+"211130001"))
			      MsgInfo("Conta Contabil nao cadastrada : 211130001"+Chr(13)+;
			              "Matricula   : "+RA_MAT +Chr(13)+;
					        "Funcionario : "+RA_NOME+Chr(13)+;
					        "Cod.Fornec. : "+SA2->A2_COD,"A T E N C A O")
			   Endif     
			    _cNome  :=RA_NOME
				_nValor :=0		
				_cChave :=RD_MAT
				_dDatPgt:=RD_DATPGT
				While RD_MAT == _cChave
				      IncProc(RA_NOME)
				      _nValor +=RD_VALOR
				      DbSkip()
				End
				_cNumTit := "   "
			   //_cNumTit += SubStr(Dtoc(_dDatPgt),1,2)+SubStr(Dtoc(_dDatPgt),4,2)+SubStr(Dtoc(_dDatPgt),7,2)
			   _cNumTit += STRZERO(VAL(DTOS(_dDatPgt)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
			   _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
				_cHist   := "Folha Mensal / "+_cNome
				If fGravaOk(_cNumTit,_nValor,_dDatPgt)
					nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYPGPE04",Subs(cUsuario,7,6),@cArquivo)
					nTotal  := DetProva(nHdlPrv,"510","YYPGPE04",AllTrim(_cSX5))
					RodaProva(nHdlPrv,nTotal)
					Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.F.)
				Else
					MsgInfo("Titulo ja existe : "+_cNumTit   +Chr(13)+;
					        "Matricula        : "+_cChave    +Chr(13)+;
					        "Funcionario      : "+_cNome     +Chr(13)+;
					        "Cod.Fornec.      : "+SA2->A2_COD+Chr(13)+;
					        "Valor            : "+TransForm(_nValor,"999,999,999.99"),+;
					        "A T E N C A O")
				Endif
				DbSelectArea("SQL")
			EndDo
		Else
			MsgInfo("Nao encontrada verba com o liquido ,"+Chr(10)+Chr(13)+;
			        "identificador de calculo '047' !","A T E N C A O")
		Endif
	Endif
  ElseIf "QUINZENAL" $ cCombo
  	 If "Aberta" $ cCombo2
	    _cDedIrrf:=""
	
	    DbSelectArea("SX5")
	    DbGoTop()
	    If !DbSeek(xFilial("SX5")+"09FIN")
		    DbSelectArea("SX5")
		    RecLock("SX5",.T.)
		    FIELD->X5_FILIAL   := xFilial("SX5")
		    FIELD->X5_TABELA   := "09"
		    FIELD->X5_CHAVE    := "FIN"
		    FIELD->X5_DESCRI   := "1100"
		    FIELD->X5_DESCSPA  := "1100"
		    FIELD->X5_DESCENG  := "1100"
		    MsUnLock()
	    EndIf
	
	    _cSx5 := X5_DESCRI
	
	   DbSelectArea("SRC")
	   DbSetOrder(1)
	   DbGotop()
	   ProcRegua(LastRec())
      Do While.Not.Eof()
		   _cMat     := SRC->RC_MAT
		   _nValor   := 0   
		   _dRcData  := dDataBase
		   Do While.Not.Eof().And._cMat = SRC->RC_MAT 
			   IncProc("Processando "+SRC->RC_MAT+"-"+SRC->RC_PD)
			   If xFilial("SRC")==RC_FILIAL
			 	   SRV->(DbSetOrder(1))             
			      If SRV->(DbSeek(xFilial("SRV")+SRC->RC_PD))
			         //If SRV->RV_CODFOL $ "006/007/008".Or.SRV->RV_COD $ "252"
			         If SRV->RV_CODFOL == STRZERO(6,TAMSX3("RV_CODFOL")[1]) .or.;
			       		SRV->RV_CODFOL == STRZERO(7,TAMSX3("RV_CODFOL")[1]) .or.;
			        	SRV->RV_CODFOL == STRZERO(8,TAMSX3("RV_CODFOL")[1]) .or.;
			         	SRV->RV_COD $ "252"
			         	
			            _nValor +=RC_VALOR
			         Endif   
		            //If SRV->RV_CODFOL $ "012/009"
		            If	SRV->RV_CODFOL == STRZERO(9,TAMSX3("RV_CODFOL")[1]) .or.;
						SRV->RV_CODFOL == STRZERO(12,TAMSX3("RV_CODFOL")[1])
                     _nValor -=RC_VALOR
		            Endif
					   if !Empty(Dtos(SRC->RC_DATA))
	           		   _dRcData:= SRC->RC_DATA
	           	   endif	  
		         Endif
		      Endif
		      DbSkip()
		   EndDo   

		  _cNatureza :="2101"
	     fCriaFornec(_cMat,_cNatureza,_cConta)			  
	     If _dRcData < dDataBase
		     MsgInfo("Data de emissao maior que o vencimento "+Chr(10)+Chr(15)+;
		             "Funcionario :"+_cMat+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
		             "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+; 
		             "Vencimento :"+Dtoc(_dRcData)+;
		             "Valor :"+TransForm(_nValor,"999,999,999.99"),"A T E N C A O")
		  Else
		     SED->(DbSetOrder(1))
		     If! SED->(DbSeek(xFilial("SED")+_cNatureza ))
		         MsgInfo("Natureza financeira nao cadastrada :"+_cNatureza+Chr(10)+Chr(15)+;
		                 "Funcionario :"+_cMat+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
		                 "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
		                 "Valor :"+TransForm(_nValor,"999,999,999.99"),"A T E N C A O")
           Else
		         	SRA->(DbSetOrder(1))
			 	      SRA->(DbSeek(xFilial("SRA")+SRC->RC_MAT))

				      _cNumTit := "ADI"
			         //_cNumTit += SubStr(Dtoc(_dRcData),1,2)+SubStr(Dtoc(_dRcData),4,2)+SubStr(Dtoc(_dRcData),7,2)
			         _cNumTit += STRZERO(VAL(DTOS(_dRcData)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
			         _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                 	 _cHist   := "Folha Adiantamento / "+SRA->RA_NOME
			         If fGravaOk(_cNumTit,_nValor,_dRcData)
					      nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYGPE10",Subs(cUsuario,7,6),@cArquivo)
					      nTotal  := DetProva(nHdlPrv,"510","YYGPE10",AllTrim(_cSX5))
					      RodaProva(nHdlPrv,nTotal)
				 	      Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.F.)
			         Endif
			      
			  Endif     
		  Endif	
		  DbSelectArea("SRC")
	   EndDo	  
    Else
       _cDedIrrf:=""
	
	    DbSelectArea("SX5")
	    DbGoTop()
	    If !DbSeek(xFilial("SX5")+"09FIN")
		    DbSelectArea("SX5")
		    RecLock("SX5",.T.)
		    FIELD->X5_FILIAL   := xFilial("SX5")
		    FIELD->X5_TABELA   := "09"
		    FIELD->X5_CHAVE    := "FIN"
		    FIELD->X5_DESCRI   := "1100"
		    FIELD->X5_DESCSPA  := "1100"
		    FIELD->X5_DESCENG  := "1100"
		    MsUnLock()
	    EndIf
	
	    _cSx5 := X5_DESCRI
	
	   DbSelectArea("SRA")
	   DbSetOrder(1)
	   DbGotop()
	   ProcRegua(LastRec())
      Do While.Not.Eof()
		   _nValor   := 0   
		   SRD->(DbSetOrder(1))
		   If SRD->(DbSeek(xFilial("SRD")+SRA->RA_MAT+SubStr(Dtos(_dData),1,6)))
   		   _cMat     := SRA->RA_MAT
   		   _cNome    := SRA->RA_NOME
		      While xFilial("SRD")+SRA->RA_MAT+SubStr(Dtos(_dData),1,6) = SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ
			         IncProc("Processando "+SRA->RA_MAT+"-"+SRA->RA_NOME)
		 	         SRV->(DbSetOrder(1))             
		            If SRV->(DbSeek(xFilial("SRV")+SRD->RD_PD))
		               If SRV->RV_CODFOL $ STRZERO(7,TAMSX3("RV_CODFOL")[1])
		                  _nValor +=SRD->RD_VALOR
		               Endif   
	               Endif
	            SRD->(DbSkip())
		      End   
		      _cNatureza :="2101"
	         fCriaFornec(_cMat,_cNatureza,_cConta)			  
	         If _dData < dDataBase
		         MsgInfo("Data de emissao maior que o vencimento "+Chr(10)+Chr(15)+;
		                 "Funcionario :"+_cMat+"-"+_cNome+Chr(10)+Chr(15)+;
		                 "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+; 
		                 "Vencimento :"+Dtoc(_dData)+;
		                 "Valor :"+TransForm(_nValor,"999,999,999.99"),"A T E N C A O")
		      Else
		         SED->(DbSetOrder(1))
		         If! SED->(DbSeek(xFilial("SED")+_cNatureza ))
		             MsgInfo("Natureza financeira nao cadastrada :"+_cNatureza+Chr(10)+Chr(15)+;
		                     "Funcionario :"+_cMat+"-"+_cNome+Chr(10)+Chr(15)+;
		                     "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
		                     "Valor :"+TransForm(_nValor,"999,999,999.99"),"A T E N C A O")
               Else
		                  _cNumTit := "ADI"
   			            //_cNumTit += SubStr(Dtoc(_dData),1,2)+SubStr(Dtoc(_dData),4,2)+SubStr(Dtoc(_dData),7,2)
   			            _cNumTit += STRZERO(VAL(DTOS(_dDatPgt)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
	   		            _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                     	_cHist   := "Folha Adiantamento / "+_cNome
			              If fGravaOk(_cNumTit,_nValor,_dData)
				    	        nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYGPE10",Subs(cUsuario,7,6),@cArquivo)
					           nTotal  := DetProva(nHdlPrv,"510","YYGPE10",AllTrim(_cSX5))
					           RodaProva(nHdlPrv,nTotal)
				 	           Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.F.)
			               Endif
			          
			      Endif     
		      Endif	 
		   EndIf   
		   DbSelectArea("SRA")
		   DbSkip()
	   EndDo	  

    EndIf		  

  ElseIf "2.PARC13" $ cCombo

	DbSelectArea("SX5")
	DbGoTop()
	If !DbSeek(xFilial("SX5")+"09FIN")
		DbSelectArea("SX5")
		RecLock("SX5",.T.)
		FIELD->X5_FILIAL   := xFilial("SX5")
		FIELD->X5_TABELA   := "09"
		FIELD->X5_CHAVE    := "FIN"
		FIELD->X5_DESCRI   := "1100"
		FIELD->X5_DESCSPA  := "1100"
		FIELD->X5_DESCENG  := "1100"
		MsUnLock()
	EndIf
	
	_cSx5 := X5_DESCRI

	DbSelectArea("SRI")
	DbSetOrder(1)
	DbGotop()
	ProcRegua(LastRec())
	Do While.Not.Eof()         
      _cNatureza :="2112"
      fCriaFornec(RI_MAT,_cNatureza,_cConta)	
		_cMat     := SRI->RI_MAT
		While _cMat = SRI->RI_MAT 
				IncProc("Processamento : "+SRI->RI_MAT+SRI->RI_PD)
	         SRV->(DbSetOrder(1))
	         If SRV->(DbSeek(xFilial("SRV")+SRI->RI_PD))
		         If SRV->RV_CODFOL $ STRZERO(21,TAMSX3("RV_CODFOL")[1])   
			         If xFilial("SRI")==SRI->RI_FILIAL
				         If SRI->RI_DATA < DDATABASE
		                  MsgInfo("Data de emissao maior que o vencimento "+Chr(10)+Chr(15)+;
		                          "Funcionario :"+SRI->RI_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
		                          "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
		                          "Valor :"+TransForm(SRI->RI_VALOR,"999,999,999.99"),"A T E N C A O")
		               Else
		                  SED->(DbSetOrder(1))
		                  If! SED->(DbSeek(xFilial("SED")+_cNatureza ))
		                      MsgInfo("Natureza financeira nao cadastrada :"+_cNatureza+Chr(10)+Chr(15)+;
		                              "Funcionario :"+SRI->RI_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
		                              "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
		                              "Valor :"+TransForm(SRI->RI_VALOR,"999,999,999.99"),"A T E N C A O")
                        Else
		                       	  SRA->(DbSetOrder(1))
				                    SRA->(DbSeek(xFilial("SRA")+SRI->RI_MAT))

				                    _cNumTit := "213"
			                       //_cNumTit += SubStr(Dtoc(SRI->RI_DATA),1,2)+SubStr(Dtoc(RI_DATA),4,2)+SubStr(Dtoc(RI_DATA),7,2)
			                       _cNumTit += STRZERO(VAL(DTOS(SRI->RI_DATA)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
			                       _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                 	              _cHist   := "2a.Parcela 13 / "+SRA->RA_NOME
			                       If fGravaOk(_cNumTit,SRI->RI_VALOR,RI_DATA)
					                    nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYGPE10",Subs(cUsuario,7,6),@cArquivo)
					                    nTotal  := DetProva(nHdlPrv,"510","YYGPE10",AllTrim(_cSX5))
					                    RodaProva(nHdlPrv,nTotal)
				 	                    Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.F.)
				 	               Endif
			               Endif
			            Endif    
			         Endif     
		         Endif	       
		      Endif
		      DbSelectArea("SRI")
		      DbSkip()
		End
	EndDo
	
  ElseIf "RESCISAO" $ cCombo

       DbSelectArea("SX5")
       DbGoTop()
       If !DbSeek(xFilial("SX5")+"09FIN")
	 	    RecLock("SX5",.T.)
	       SX5->X5_FILIAL   := xFilial("SX5")
	       SX5->X5_TABELA   := "09"
	       SX5->X5_CHAVE    := "FIN"
	       SX5->X5_DESCRI   := "1100"
	       SX5->X5_DESCSPA  := "1100"
	       SX5->X5_DESCENG  := "1100"
	       MsUnLock()
       EndIf
     
       DbSelectArea("SRR")
       DbSetOrder(1)
       DbSeek(xFilial("SRR")+cMatDe,.T.)
       ProcRegua(RecCount())                                                                      
       While cMatDe >= RR_MAT.And.RR_MAT <= cMatAt
             nValorIr:= 0
             nValorLi:= 0
             SRA->(DbSetOrder(1))
	          SRA->(DbSeek(xFilial("SRA")+SRR->RR_MAT))
	          SA2->(DbSetOrder(3))
	          If SA2->(DbSeek(xFilial("SA2")+SRA->RA_CIC))
                cMat  := RR_MAT     
                While cMat == RR_MAT 
                      If RR_DATA == _dData.And.RR_TIPO3 $ "R"
                         SRV->(DbSetOrder(1))
                         SRV->(DbSeek(xFilial("SRV")+SRR->RR_PD))
                         SED->(DbSetOrder(1))
                         SED->(DbSeek(xFilial("SED")+"2108"))

                         If SRV->RV_CODFOL $ STRZERO(126,TAMSX3("RV_CODFOL")[1])   
                         	 _cNumTit := "RES"
			                   //_cNumTit += SubStr(Dtoc(RR_DATA),1,2)+SubStr(Dtoc(RR_DATA),4,2)+SubStr(Dtoc(RR_DATA),7,2)
			                   _cNumTit += STRZERO(VAL(DTOS(RR_DATA)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
			                   _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                            _cHist   := "Rescisao / "+SRA->RA_NOME
                            If fGravaOk(_cNumTit,RR_VALOR,RR_DATA)

                               nHdlPrv:=HeadProva(AllTrim(SX5->X5_DESCRI),"YYPGPE05",Subs(cUsuario,7,6),@cArquivo)
                               nTotal  := DetProva(nHdlPrv,"510","YYPGPE05",AllTrim(SX5->X5_DESCRI))
                               RodaProva(nHdlPrv,nTotal)                                     
                               Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(SX5->X5_DESCRI),.T.,.T.)     
                               lRescisao:= .T. 
                            Endif
                          //ElseIf SRV->RV_CODFOL $ "066/067/071"
							ElseIf	SRV->RV_CODFOL == STRZERO(66,TAMSX3("RV_CODFOL")[1]) .or.;
						   			SRV->RV_CODFOL == STRZERO(67,TAMSX3("RV_CODFOL")[1]) .or.;
						   			SRV->RV_CODFOL == STRZERO(71,TAMSX3("RV_CODFOL")[1])

                               nValorIr += RR_VALOR
                               cTipo    := RR_TIPO3
                          Endif
                      Endif
                      DbSeLectArea("SRR")
                      IncProc(RR_MAT)
                      DbSkip()         
                      If Eof()
                         Exit
                      Endif
                End    
            Else
                 MsgInfo("Fornecedor nao encontrado !"+Chr(10)+Chr(15)+;
                         SRA->RA_NOME ," A T E N C A O")
             Endif             
             
             If nValorIr > 0                          
                _cHist   := "IR RESCISAO / "+SRA->RA_NOME
                _cMes    := StrZero(Month(_dData)+1,2)
                _cAno    := SubStr(Dtos(_dData),1,4)
              	 _cNumTit := "RES"
                //_cNumTit += SubStr(Dtoc(_dData),1,2)+SubStr(Dtoc(_dData),4,2)+SubStr(Dtoc(_dData),7,2)
                _cNumTit += STRZERO(VAL(DTOS(_dData)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
                _cHist   := "Rescisao / "+SRA->RA_NOME

                If fGravaOk(_cNumTit,nValorIr,Ctod("10/"+_cMes+"/"+_cAno))
                	 SED->(DbSetOrder(1))
		             SED->(DbSeek(xFilial("SED")+"2105"))        
		             SA2->(DbSetOrder(1))
		             SA2->(DbSeek(xFilial("SA2")+"UNIAO "+"01"))

                   nHdlPrv:=HeadProva(AllTrim(SX5->X5_DESCRI),"YYPGPE04",Subs(cUsuario,7,6),@cArquivo)
                   nTotal  := DetProva(nHdlPrv,"510","YYPGPE04",AllTrim(SX5->X5_DESCRI))
                   RodaProva(nHdlPrv,nTotal)                                     
                   Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(SX5->X5_DESCRI),.T.,.T.) 
                Endif   
             Endif
                                         
             If Eof()
                Exit
             Endif
       End
       If lRescisao 
          MsgInfo("Favor verificar as datas!"+chr(10)+chr(13)+" Não foi encontrada Recisão na data informada.")
      EndIf  

  ElseIf "FERIAS" $ cCombo

     DbSelectArea("SX5")
     DbGoTop()
     If !DbSeek(xFilial("SX5")+"09FIN")
	      DbSelectArea("SX5")
 	      RecLock("SX5",.T.)
	      FIELD->X5_FILIAL   := xFilial("SX5")
	      FIELD->X5_TABELA   := "09"
	      FIELD->X5_CHAVE    := "FIN"
	      FIELD->X5_DESCRI   := "1100"
	      FIELD->X5_DESCSPA  := "1100"
	      FIELD->X5_DESCENG  := "1100"
	      MsUnLock()
     EndIf 
     
     _cSx5 := X5_DESCRI

     SX5->(dbSeek(xFilial("SX5")+"09FIN"))
     
	  DbSelectArea("SRR")
     DbSetOrder(1)
     DbSeek(xFilial("SRR")+cMatDe,.T.)
     ProcRegua(RecCount())                                                                      
     While cMatDe >= RR_MAT.And.RR_MAT <= cMatAt
           SRA->(DbSetOrder(1))
	        SRA->(DbSeek(xFilial("SRA")+SRR->RR_MAT))
	        cMat := RR_MAT     
            While cMat == RR_MAT 
                  If RR_DATA == _dData.And.RR_TIPO3 $ "F"
                     SRV->(DbSetOrder(1))
                     SRV->(DbSeek(xFilial("SRV")+SRR->RR_PD))
                     SED->(DbSetOrder(1))
                     SED->(DbSeek(xFilial("SED")+"2113"))

                     If SRV->RV_CODFOL $ STRZERO(102,TAMSX3("RV_CODFOL")[1])//"102"  //---> Liquido 
                        _cHist   :="Ferias / "+SRA->RA_NOME
                        fCriaFornec(SRR->RR_MAT,"2113","211130001")	
                    	   _cNumTit := "FER"
   			              //_cNumTit += SubStr(Dtoc(RR_DATA),1,2)+SubStr(Dtoc(RR_DATA),4,2)+SubStr(Dtoc(RR_DATA),7,2)
   			              _cNumTit += STRZERO(VAL(DTOS(RR_DATA)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
		                  _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                        If fGravaOk(_cNumTit,RR_VALOR,RR_DATA)       
                
                           nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYPGPE04",Subs(cUsuario,7,6),@cArquivo)
                           nTotal  := DetProva(nHdlPrv,"510","YYPGPE04",AllTrim(_cSX5))
                           RodaProva(nHdlPrv,nTotal)                                     
                           Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.T.)      
                        Endif
                    /* ElseIf SRV->RV_CODFOL $ "067" //---> Ir   ***** Wed - Chamado 8427
                        _cHist   := "IR FERIAS / "+SRA->RA_NOME
                        _cMes    := StrZero(Month(_dData)+1,2)
                        _cAno    := SubStr(Dtos(_dData),1,4)           
                    	   _cNumTit := "UNI"
   			            _cNumTit += SubStr(Dtoc(RR_DATA),1,2)+SubStr(Dtoc(RR_DATA),4,2)+SubStr(Dtoc(RR_DATA),7,2)

                        If fGravaOk(_cNumTit,RR_VALOR,Ctod("10/"+_cMes+"/"+_cAno))
                           SED->(DbSetOrder(1))
		                     SED->(DbSeek(xFilial("SED")+"2106"))        
		                     SA2->(DbSetOrder(1))
		                     SA2->(DbSeek(xFilial("SA2")+"UNIAO "+"01"))

                           nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYPGPE04",Subs(cUsuario,7,6),@cArquivo)
                           nTotal  := DetProva(nHdlPrv,"510","YYPGPE04",AllTrim(_cSX5))
                           RodaProva(nHdlPrv,nTotal)                                     
                           Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.T.)          
                        Endif*/
                     Endif   
                  Endif
                  DbSeLectArea("SRR")
                  IncProc(RR_MAT)
                  DbSkip()         
                  If Eof()
                     Exit
                  Endif
            End           
            If Eof()
               Exit
            Endif
     End

  ElseIf "1.PARC13" $ cCombo
	
	DbSelectArea("SX5")
	DbGoTop()
	If !DbSeek(xFilial("SX5")+"09FIN")
		DbSelectArea("SX5")
		RecLock("SX5",.T.)
		FIELD->X5_FILIAL   := xFilial("SX5")
		FIELD->X5_TABELA   := "09"
		FIELD->X5_CHAVE    := "FIN"
		FIELD->X5_DESCRI   := "1100"
		FIELD->X5_DESCSPA  := "1100"
		FIELD->X5_DESCENG  := "1100"
		MsUnLock()
	EndIf
	
	_cSx5 := X5_DESCRI

  If "Aberta" $ cCombo2 
  
	DbSelectArea("SRC")
	DbSetOrder(1)
	DbGotop()
	ProcRegua(LastRec())
	Do While.Not.Eof()
		_cNatureza :="2112"
		fCriaFornec(SRC->RC_MAT,_cNatureza,_cConta)	
	   _cMat     := SRC->RC_MAT
		Do While.Not.Eof().And. _cMat = SRC->RC_MAT
			   IncProc("Processando: "+SRC->RC_MAT+SRC->RC_PD)
	         SRV->(DbSetOrder(1))
	         If SRV->(DbSeek(xFilial("SRV")+SRC->RC_PD))
		         If SRV->RV_CODFOL $ STRZERO(22,TAMSX3("RV_CODFOL")[1])//"022"   
			         If xFilial("SRC")==RC_FILIAL
			            If RC_DATA < DDATABASE
				            MsgInfo("Data de emissao maior que o vencimento "+Chr(10)+Chr(15)+;
				                    "Funcionario :"+SRC->RC_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
				                    "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
				                    "Valor :"+TransForm(RC_VALOR,"999,999,999.99"),"A T E N C A O")
				         Else
				            SED->(DbSetOrder(1))
			               If! SED->(DbSeek(xFilial("SED")+_cNatureza ))
				                MsgInfo("Natureza financeira nao cadastrada :"+_cNatureza+Chr(10)+Chr(15)+;
				                        "Funcionario :"+SRC->RC_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
				                        "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
				                        "Valor :"+TransForm(RC_VALOR,"999,999,999.99"),"A T E N C A O")
                        Else
					               SRA->(DbSetOrder(1))
	                           SRA->(DbSeek(xFilial("SRA")+_cMat))
                              _cNumTit := "113"
			                     _cNumTit += STRZERO(VAL(DTOS(RC_DATA)),TAMSX3("E2_NUM")[1])        //JSS Alterado para solucionar o caso 017944
			                     //_cNumTit += SubStr(Dtoc(RC_DATA),1,2)+SubStr(Dtoc(RC_DATA),4,2)+SubStr(Dtoc(RC_DATA),7,2)
			                     _cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                 				   _cHist   := "1a.Parcela 13 / "+SRA->RA_NOME
			                     If fGravaOk(_cNumTit,RC_VALOR,RC_DATA)
					                  nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYGPE10",Subs(cUsuario,7,6),@cArquivo)
					                  nTotal  := DetProva(nHdlPrv,"510","YYGPE10",AllTrim(_cSX5))
					                  RodaProva(nHdlPrv,nTotal)
				 	                  Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.F.)
			                     Endif
				            Endif   
				         Endif
				      Endif       
				   Endif   
				Endif   
				DbSelectArea("SRC")
		      DbSkip()
		EndDo
	EndDo
  Else
      cVerba:=""
      SRV->(DbSetOrder(2))
		If SRV->(DbSeek(xFilial("SRV")+STRZERO(22,TAMSX3("RV_CODFOL")[1]) ))//"022"))
			While SRV->RV_CODFOL == STRZERO(22,TAMSX3("RV_CODFOL")[1])//"022"
				cVerba+=SRV->RV_COD+"','"
				SRV->(DbSkip())
			End
		Endif	
		
   fGeraSrd() 
  	DbSelectArea("SQL")
	DbGotop()
	ProcRegua(LastRec())
	Do While.Not.Eof()
		_cNatureza :="2112"
      fCriaFornec(SQL->RD_MAT,_cNatureza,_cConta)	
      DbSelectArea("SQL")
	   _cMat     := RD_MAT
		While _cMat = RD_MAT
			   IncProc("Processando: "+RD_MAT+RD_PD)   
                     If RD_DATPGT < DDATABASE
				            MsgInfo("Data de emissao maior que o vencimento "+Chr(10)+Chr(15)+;
				                    "Funcionario :"+RD_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
				                    "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
				                    "Valor :"+TransForm(RD_VALOR,"999,999,999.99"),"A T E N C A O")
				        Else
				            SED->(DbSetOrder(1))
			               If! SED->(DbSeek(xFilial("SED")+_cNatureza ))
				                MsgInfo("Natureza financeira nao cadastrada :"+_cNatureza+Chr(10)+Chr(15)+;
				                        "Funcionario :"+RD_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
				                        "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
				                        "Valor :"+TransForm(RD_VALOR,"999,999,999.99"),"A T E N C A O")
                        Else
					               SRA->(DbSetOrder(1))
	                           SRA->(DbSeek(xFilial("SRA")+_cMat))
            
			                     _cNumTit := "113"                                     
			                     _cNumTit += Alltrim(RD_MAT)
			                     //_cNumTit += SubStr(Dtoc(RD_DATPGT),1,2)+SubStr(Dtoc(RD_DATPGT),4,2)+SubStr(Dtoc(RD_DATPGT),7,2)
			                     //_cNumTit += Space(01)+"FOL"+SA2->A2_COD+SA2->A2_LOJA
                 				   _cHist   := "1a.Parcela 13 / "+SRA->RA_NOME
			                     If fGravaOk(_cNumTit,RD_VALOR,RD_DATPGT)
					                  nHdlPrv:=HeadProva(AllTrim(_cSX5),"YYGPE10",Subs(cUsuario,7,6),@cArquivo)
					                  nTotal  := DetProva(nHdlPrv,"510","YYGPE10",AllTrim(_cSX5))
					                  RodaProva(nHdlPrv,nTotal)
				 	                  Ca100Incl(cArquivo,nHdlPrv,3,AllTrim(_cSX5),.T.,.F.)
			                     Endif
				              				            Endif   
				         Endif
				DbSelectArea("SQL")         
		      DbSkip()
		End
	EndDo
  Endif	
 Endif

 PutMv("MV_FOLFIN",dDataBase)    // ATUALIZA PARAMETRO DE ULTIMA EXECUCAO.
Endif
Return


*--------------------------------------------------*
Static Function fGravaOk(_cChave,_nTotal,_dDataVen)
*--------------------------------------------------*

Local lRet :=.F.

SE2->(DbSetOrder(1))
If SE2->(DbSeek(xFilial("SE2")+_cChave))
	   MsgInfo("Titulo ja cadastrado : "+_cChave+Chr(10)+Chr(15)+;
	           "Funcionario :"+SRA->RA_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
	           "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
		           "Valor :"+TransForm(_nTotal,"999,999,999.99"),"A T E N C A O")
ElseIf _nTotal == 0
	MsgInfo("Titulo não sera criado, valor Zero : "+_cChave+Chr(10)+Chr(15)+;
			"Funcionario :"+SRA->RA_MAT+"-"+SRA->RA_NOME+Chr(10)+Chr(15)+;
	        "Cod.Fornecedor :"+SA2->A2_COD+Chr(10)+Chr(15)+;
		    "Valor :"+TransForm(_nTotal,"999,999,999.99"),"A T E N C A O")
Else
	   Reclock("SE2",.T.)
	   Replace E2_PREFIXO  With SubStr(_cChave,1,3)
	   Replace E2_NUM      With SubStr(_cChave,4,TamSX3("E2_NUM")[1])
	   Replace E2_PARCELA  With Space(01)
	   Replace E2_FILIAL   With xFilial("SE2")
	   Replace E2_TIPO     With "FOL"
	   Replace E2_NATUREZ  With SED->ED_CODIGO
	   Replace E2_CCREDIT  With "211130001"
	   Replace E2_TITORIG  With "FOLHA PAGTO"
	   Replace E2_FORNECE  With SA2->A2_COD
	   Replace E2_LOJA     With SA2->A2_LOJA
	   Replace E2_NOMFOR   With SubStr(SA2->A2_NOME,1,20)
	   Replace E2_EMISSAO  With dDataBase
	   Replace E2_VENCTO   With _dDataVen
	   Replace E2_VENCREA  With _dDataVen
	   Replace E2_VALOR    With _nTotal
	   Replace E2_EMIS1    With dDataBase
	   Replace E2_SALDO    With _nTotal
	   Replace E2_VENCORI  With _dDataVen
	   Replace E2_MOEDA    With 1
	   Replace E2_VLCRUZ   With _nTotal
	   Replace E2_HIST     With _cHist
	   Replace E2_ORIGEM   With "FINA050"
	   Replace E2_FLUXO    With "S"
	   MsUnlock()
	   ConfirmSx8()
	   lRet:=.T.
Endif   

Return(lRet)


*----------------------------*
Static Function fValidaCtb()
*----------------------------*

If Select("CCTG") > 0
	CCTG->(DbCloseArea())
EndIf

aStruCCTG :={}

cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("CTG")+Chr(10)
cQuery += "WHERE CTG_FILIAL = '"+xFilial("CTG")+"' "+Chr(10)
cQuery += "AND CTG_DTINI <= '"+Dtos(_dData)+"' AND CTG_DTFIM  >= '"+Dtos(_dData)+"' "+Chr(10)
cQuery += "AND D_E_L_E_T_ <> '*' "+Chr(10)

TCQuery cQuery ALIAS "CCTG" NEW       

For nX := 1 To Len(aStruCCTG)
	If aStruCCTG[nX,2]<>"C"
		TcSetField("CCTG",aStruCCTG[nX,1],aStruCCTG[nX,2],aStruCCTG[nX,3],aStruCCTG[nX,4])
	EndIf
Next nX

cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"CCTG",.T.)

Return

*-------------------------*
Static Function fGeraSrd()
*-------------------------*

If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

aStruSRD :={}

cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SRD")+" SRD , "+RetSqlName("SRA")+" SRA WHERE "+Chr(10)
cQuery += "SRA.RA_FILIAL = '"+xFilial("SRA")+"' AND SRD.RD_FILIAL = '"+xFilial("SRD")+"'"+Chr(10)
cQuery += "AND SRA.RA_FILIAL+SRA.RA_MAT = SRD.RD_FILIAL+SRD.RD_MAT "+Chr(10)
cQuery += "AND SRD.RD_DATPGT = '"+Dtos(_dData)+"'"+Chr(10)
cQuery += "AND SRD.RD_PD IN ('"+cVerba+"') "+Chr(10)
cQuery += "AND SRD.D_E_L_E_T_ <> '*' AND SRA.D_E_L_E_T_ <> '*'"+Chr(10)
cQuery += "ORDER BY RD_MAT,RD_PD"

TCQuery cQuery ALIAS "SQL" NEW       

TCSetField("SQL","RD_DATPGT","D",08,0)
TCSetField("SQL","RD_VALOR" ,"N",17,2)

For nX := 1 To Len(aStruSRD)
	If aStruSRD[nX,2]<>"C"
		TcSetField("SQL",aStruSRD[nX,1],aStruSRD[nX,2],aStruSRD[nX,3],aStruSRD[nX,4])
	EndIf
Next nX

cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SQL",.T.)

Return

*------------------------------------------------*
Static Function fCriaFornec(_cVar,_cVar2,_cVar3)
*------------------------------------------------*

SRA->(DbSetOrder(1))
If SRA->(DbSeek(xFilial("SRA")+_cVar))
	SA2->(DbSetOrder(3))
	If! SA2->(DbSeek(xFilial("SA2")+SRA->RA_CIC))
		 RecLock("SA2",.T.)
		 A2_FILIAL  := xFilial("SA2")
		 A2_COD     := GetSx8Num("SA2","A2_COD")
		 A2_LOJA    := "01"
		 A2_NOME    := SRA->RA_NOME
		 A2_NREDUZ  := SubStr(SRA->RA_NOME,1,20)
		 A2_END     := SRA->RA_ENDEREC
		 A2_BAIRRO  := SRA->RA_BAIRRO
		 A2_MUN     := SRA->RA_MUNICIP
		 A2_EST     := SRA->RA_ESTADO
		 A2_CEP     := SRA->RA_CEP
		 A2_CGC     := SRA->RA_CIC
		 A2_TEL     := SRA->RA_TELEFON
		 A2_NATUREZ := _cVar2
		 A2_CONTA   := _cVar3
		 A2_TIPO    := "F"
		MsUnlock()
      ConfirmSx8()
	Endif
Endif	
Return