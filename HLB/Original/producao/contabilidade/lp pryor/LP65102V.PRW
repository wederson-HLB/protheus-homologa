#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP65102V()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT,_CTES1,_CTES2,_CTES3,_CTES4,_cTes5,_cTes6,_cTes7,_CTESIMP")
//aArea  := GETAREA()                                	

lEasy     := SuperGetMV("MV_EASY") == "S"

gSd1A := ALIAS()
gSd1B := dbSetOrder()
gSd1C := recno()
DbSelectArea("SD1")
gSd1D := dbSetOrder()
gSd1E := recno()


_valResult:=0 


_cTes1:=         "02A/03A/04A/05A/06A/07A/08A/09B/13A/14A/16A/17A/18A/19A/20A/21A/"    	// COMPRAS
_cTes1:=_cTes1 + "02B/03B/04B/05B/06B/07B/13B/15B/16B/17B/18B/19B/25B/31A/"         // COMPRAS
_cTes1:=_cTes1 + "19M/22M/" 										  				// COMPRAS ATIVO
_cTes1:=_cTes1 + "04P/17P/26P/"    											  		// OUTRAS ENTRADAS

_cTes2:=         "15A/22A/23A/24A/25A/26A/"   										//MAO DE OBRA
_cTes2:=_cTes2 + "12B/14B/26B/03S/"   													//COMPRA MAT.PRIMA
_cTes2:=_cTes2 + "02C/"   															//COMPRA ORDEM INDUSTR.
_cTes2:=_cTes2 + "01G/02G/03G/04G/05G/06G/07G/08G/09G/10G/12G/13G/14G/15G/16G/"   	//COMPRA ENERGIA
_cTes2:=_cTes2 + "01H/02H/03H/04H/05H/06H/07H/"                                     //COMPRA SERV.COMUN.
_cTes2:=_cTes2 + "01I/"                                                             //COMPRA SERV.TRANSP.
_cTes2:=_cTes2 + "11J/"   															//?COMPRA C/SUB.TRIB.
_cTes2:=_cTes2 + "02P/"   															//REM.EMPRESTIMO

_cTes3:=         "22B/"   															// INDUSTRIALIZACAO
_cTes3:=_cTes3 + "11G/"   															// COMPRA ENERGIA
_cTes3:=_cTes3 + "08H/"   															// AQ.SERV.COMUNIC
_cTes3:=_cTes3 + "02I/03I/04I/06I/07I/08I/09I/10I/11I/13I/1C0"						// COMPRA SERV.TRANSP
_cTes3:=_cTes3 + "01J/02J/03J/04J/05J/06J/"   										// COMPRA C/SUB.TRIB.
_cTes3:=_cTes3 + "01L/"   															// ENTR.FIM EXPORT
_cTes3:=_cTes3 + "01M/02M/03M/09M/10M/11M/12M/13M/15M/"   							// COMPRA ATIVO
_cTes3:=_cTes3 + "01O/40O/41O/42O/48O/"   											// OUTRAS ENTRADAS
_cTes3:=_cTes3 + "11P/"   															// AQUIS.BRINDE
_cTes3:=_cTes3 + "49R/37D/46U/49B/"

_cTes4:=         "09A/10A/12A/27A/28A/29A/30A/"   					    			// COMPRAS P/INDUSTR.
_cTes4:=_cTes4 + "08B/09B/10B/11A/11B/20B/21B/23B/27B/28B/"    	             		// IMPORT.P/COMERC.
_cTes4:=_cTes4 + "03M/04M/05M/18M/14M/16M/"   					     				// COMPRAS ATIVO
_cTes4:=_cTes4 + "43O/44O/45O/47O/08B/11R/"   												// IMPORT. OUTRAS.

_cTes5:=         "01A/"                                                             // COMPRAS P/INDUSTR.
_cTes5:=_cTes5 + "01B/02B/10B/"                                                     // COMPRAS P/INDUSTR.
_cTes5:=_cTes5 + "02P/"                                                             // REM.EMPRESTIMO

_cTes6:=         "01E/02E/03E/04E/05E/06E/07E/08E/09E/10E/11E/12E/13E/"             // DEVOLUCAO DE VENDAS
_cTes6:=_cTes6 + "07M/08M/"                                                         // DEVOLUCAO DE VENDAS

_cTes7:="08P/49P/46O/48P/23K/24Q/1BF"     // COMPRA DE SERVICOS COM PIS/COFINS/CSLL    // SERVICOS TOMADOS

_CTESIMP:="08V"                                                                     // TES DE IMPORTAÇÃO

cAmbiente := GetEnvServer()   

//IF !lEasy
If EMPTY(SD1->D1_CONHEC)

   IF SM0->M0_CODIGO $'MV' .AND. SD1->D1_COD=='COMISSAO'
	 
	   _valResult:=(SDE->DE_CUSTO1 - ((SD1->D1_VALIRR+SD1->D1_VALISS+SD1->D1_P_INS20+SD1->D1_VALINS)*(SDE->DE_PERC/100)) - ((SD1->D1_VALCOF+SD1->D1_VALCSLL+SD1->D1_VALPIS)*(SDE->DE_PERC/100)) )
	
   ELSEIF (SF4->F4_DUPLIC=="N" .AND. !(SD1->D1_TES$_cTes5) .AND. !(SD1->D1_TES$_cTes4)) .OR. SD1->D1_TES$(_cTes6)
	
      _valResult:=0
	
   ELSEIF SD1->D1_TES$(_cTes1+_cTes2+_cTes3)
	
      _valResult:=((SDE->DE_CUSTO1+ (SD1->D1_VALIPI*(SDE->DE_PERC/100) )+ (SD1->D1_ICMSRET*(SDE->DE_PERC/100) )))
	
   ELSEIF SD1->D1_TES$(_cTes4)
	
      _valResult:=(SDE->DE_CUSTO1)
	
   ELSEIF  SD1->D1_TES$(_cTes5)
	
	/////	_valResult:=(SD1->D1_TOTAL-SD1->D1_VALIPI-SD1->D1_VALICM)
      _valResult:=(SDE->DE_CUSTO1+( SD1->D1_VALIPI*(SDE->DE_PERC/100)) )
	
   ELSEIF  SD1->D1_TES$(_cTes7)
	
      IF SD1->D1_VALIRR >= (GETMV("MV_VLRETIR")) .AND. SD1->D1_VALINS >= (GETMV("MV_VLRETIN"))
		//iF cEmpant $"Z4/CZ/FA/DT/YY/FI/Z0/30/RS/"  .OR. UPPER(cAmbiente) $"AMB02/AMB03/ENV03/ENV04/ENV06/L_SQL_AMB2/"
	     IF SUBSTR(GETVERSAO(),1,3) = 'P10'
		    _valResult:=(SDE->DE_CUSTO1- ((SD1->D1_VALIRR+SD1->D1_VALISS+SD1->D1_VALINS)*(SDE->DE_PERC/100)) )	  // TOTAL - PIS
		 else
		   _valResult:=(SDE->DE_CUSTO1- ((SD1->D1_VALIRR+SD1->D1_VALISS+SD1->D1_VALINS)*(SDE->DE_PERC/100) )- ((SD1->D1_VALCOF+SD1->D1_VALCSLL+SD1->D1_VALPIS)*(SDE->DE_PERC/100)) )	  // TOTAL - PIS
		 endif
	ENDIF
	
	IF SD1->D1_VALIRR < (GETMV("MV_VLRETIR")) .AND. SD1->D1_VALINS >= (GETMV("MV_VLRETIN"))
		//iF cEmpant $"Z4/CZ/FA/DT/YY/FI/Z0/30/RS/".OR. UPPER(cAmbiente) $ "AMB02/AMB03/ENV03/ENV04/ENV06/L_SQL_AMB2/"
		IF SUBSTR(GETVERSAO(),1,3) = 'P10'
			_valResult:=(SDE->DE_CUSTO1- ((SD1->D1_VALISS+SD1->D1_VALINS)*(SDE->DE_PERC/100)) )	  // TOTAL - PIS
		else
			_valResult:=(SDE->DE_CUSTO1-((SD1->D1_VALISS+SD1->D1_VALINS)*(SDE->DE_PERC/100))-((SD1->D1_VALCOF+SD1->D1_VALCSLL+SD1->D1_VALPIS)*(SDE->DE_PERC/100)))	  // TOTAL - PIS
		endif
	ENDIF
	IF SD1->D1_VALIRR >= (GETMV("MV_VLRETIR")) .AND. SD1->D1_VALINS < (GETMV("MV_VLRETIN"))
		//			iF cEmpant $"Z4/CZ/FA/DT/YY/FI/Z0/30/RS/".OR. UPPER(cAmbiente) $ "AMB02/AMB03/ENV03/ENV04/ENV06/L_SQL_AMB2/"
		IF SUBSTR(GETVERSAO(),1,3) = 'P10'
			_valResult:=(SDE->DE_CUSTO1- ((SD1->D1_VALIRR+SD1->D1_VALISS)*(SDE->DE_PERC/100)))	  // TOTAL - PIS
		else
			//				_valResult:=(SD1->D1_TOTAL-(SD1->D1_VALIRR+SD1->D1_VALISS)-(SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_PIS))	  // TOTAL - PIS
			_valResult:=(SDE->DE_CUSTO1- ((SD1->D1_VALIRR+SD1->D1_VALISS)*(SDE->DE_PERC/100))-((SD1->D1_VALCOF+SD1->D1_VALCSLL+SD1->D1_VALPIS)*(SDE->DE_PERC/100)))	  // TOTAL - PIS
			
		endif
	ENDIF
	IF SD1->D1_VALIRR < (GETMV("MV_VLRETIR")) .AND. SD1->D1_VALINS < (GETMV("MV_VLRETIN"))
		//			iF cEmpant $"Z4/CZ/FA/DT/YY/FI/Z0/30/RS/".OR. UPPER(cAmbiente) $ "AMB02/AMB03/ENV03/ENV04/ENV06/L_SQL_AMB2/"
		IF SUBSTR(GETVERSAO(),1,3) = 'P10'
			_valResult:=(SDE->DE_CUSTO1-((SD1->D1_VALISS)*(SDE->DE_PERC/100)))	  // TOTAL - PIS
		else
			_valResult:=(SDE->DE_CUSTO1-((SD1->D1_VALISS)*(SDE->DE_PERC/100))-((SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_PIS)*(SDE->DE_PERC/100)))	  // TOTAL - PIS
		endif
	ENDIF
	
  ELSE   

	//_valResult:=(SD1->D1_TOTAL+SD1->D1_VALIPI)
	// TLM  - TES de IMPORTAÇÃO c/ EIC não fará lançamento padrão 650, verificar lançamentos 950.        
	If !(SD1->D1_TES$(_CTESIMP))  
	   _valResult:=(SDE->DE_CUSTO1+(SD1->D1_VALIPI*(SDE->DE_PERC/100)))
	EndIf
	
   ENDIF
   
EndIf

DbSelectArea("SD1")
dbSetOrder(gSd1D)
recno(gSd1E)

dbSelectArea(gSd1A)
dbSetorder(gSd1b)
dbGoto(gSd1c)

//RestArea(aArea)    

RETURN(_valResult)





