#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function LP65101V()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT,_CTES1,_CTES2,_CTES3,_CTES4,_CTES5,_CTES6,_CTES7,_CTES8,_CTES9,_CTESIMP")

lEasy     := SuperGetMV("MV_EASY") == "S"

_valResult:=0

_cTes1:=         "02A/03A/04A/05A/06A/07A/08A/13A/14A/16A/17A/18A/19A/20A/21A/31A/66A/" // COMPRAS
_cTes1:=_cTes1 + "02B/03B/04B/05B/06B/07B/13B/15B/16B/17B/18B/19B/25B/"              	// COMPRAS
_cTes1:=_cTes1 + "19M/56M/66M/"    											  			// COMPRAS ATIVO
_cTes1:=_cTes1 + "04P/17P/26P/08R/" 									  		    	// OUTRAS ENTRADAS

_cTes2:=         "15A/22A/23A/24A/25A/26A/"   											//MAO DE OBRA
_cTes2:=_cTes2 + "12B/14B/26B/32A"   													//COMPRA MAT.PRIMA
_cTes2:=_cTes2 + "02C/"   																//COMPRA ORDEMINDUSTR.
_cTes2:=_cTes2 + "01G/02G/03G/04G/05G/06G/07G/08G/09G/10G/12G/13G/14G/15G/16G/"     	//COMPRA ENERGIA
_cTes2:=_cTes2 + "01H/02H/03H/04H/05H/06H/07H/"                                         //COMPRA SERV.COMUN.
_cTes2:=_cTes2 + "01I/"                                                                 //COMPRA SERV.TRANSP.
_cTes2:=_cTes2 + "11J/"   																//COMPRA C/SUB.TRIB.
_cTes2:=_cTes2 + "02P/"   																//REM.EMPRESTIMO

_cTes3:=         "11G/"   																// INDUSTRIALIZACAO
_cTes3:=_cTes3 + "08H/"   																// AQ.SERV.COMUNIC
_cTes3:=_cTes3 + "03I/04I/06I/07I/08I/09I/10I/11I/13I/"   								// COMPRA SERV.TRANSP
_cTes3:=_cTes3 + "01J/02J/03J/04J/05J/06J/"   											// COMPRA C/SUB.TRIB.
_cTes3:=_cTes3 + "01L/"   																// ENTR.FIM EXPORT
_cTes3:=_cTes3 + "01M/02M/03M/09M/10M/11M/13M/24M/25M/26M/"   							// COMPRA ATIVO
_cTes3:=_cTes3 + "01O/40O/41O/42O/46O/48O/"   											// OUTRAS ENTRADAS
_cTes3:=_cTes3 + "11P/48P/"   															// AQUIS.BRINDE

_cTes4:=         "09A/10A/12A/27A/28A/29A/30A/"   									    // COMPRAS P/INDUSTR.
_cTes4:=_cTes4 + "09B/10B/11A/11B/20B/21B/27B/28B/"   						    		// IMPORT.P/COMERC.
_cTes4:=_cTes4 + "43O/44O/45O/47O/08B/11R/"   													// IMPORT. OUTRAS.

_cTes5:=         "01A/05A/08A/"                                                         // COMPRAS P/INDUSTR.
_cTes5:=_cTes5 + "02B/05B/07B/10B/23B/30B/33B/37B/"                                     // COMPRAS P/INDUSTR.
_cTes5:=_cTes5 + "02P/16Q/"                                                             // REM.EMPRESTIMO

_cTes6:=         "01E/02E/03E/04E/05E/06E/07E/08E/09E/10E/11E/12E/13E/"                 // DEVOLUCAO DE VENDAS
_cTes6:=_cTes6 + "07M/08M/"                                                             // DEVOLUCAO DE VENDAS

_cTes7:="08P/49P/02I/14I/06I/13I/03I/04I/23Q/22B/"     							     	//FRETE COM CREDITO DE PIS/COFINS  // SERVICOS TOMADOS (O8P)

_cTes8:="01B/03C/35B/"     																// COMPRA PARA COMERCIALIZACAO COM IPI INCLUSO

_cTes9 := "12M/"  																		// TES COM DIFERENCIAL DE ALIQUOTA / CONSUMO

_cTes10:= "03M/04M/05M/18M/14M/15M/16M/20M/"   										    // COMPRAS ATIVO

_cTes11:= "28P"																			// AMOSTRA PRA TESTE

_cTes12:= "13I"	                                                                        // TES P/ LANCTO DE FRETES
 
_cTes13:= "1C0"	                                                                        // TES P/ LANCTO DE FRETES DONALDSON

_CTESIMP:="08V"                                                                         // TES de Importação EIC

//If !lEasy
If EMPTY(SD1->D1_CONHEC)

   IF  (SD1->D1_TES$_cTes11) .OR. (SD1->D1_TES$_cTes12)
	
	  _valResult:= SDE->DE_CUSTO1    
	
   ELSE
	
      IF (SF4->F4_DUPLIC=="N" .AND. !(SD1->D1_TES$_cTes5) .AND. !(SD1->D1_TES$_cTes4)) .AND. !((SD1->D1_TES$_cTes10)) .OR. (SD1->D1_TES$(_cTes6))
		
	     _valResult:=0
		
	  ELSEIF SD1->D1_TES$(_cTes1+_cTes2+_cTes3)
		
		_valResult:=(SDE->DE_CUSTO1)
		
	  ELSEIF SD1->D1_TES$(_cTes4)
		
	   	_valResult:=(SDE->DE_CUSTO1)
		
	  ELSEIF  SD1->D1_TES$(_cTes5)
		
	    _valResult:=(SD1->D1_TOTAL-SD1->D1_VALICM-SD1->D1_VALIMP6-SD1->D1_VALIMP5)
		
	  ELSEIF  SD1->D1_TES$(_cTes7)
		
	    _valResult:=(SDE->DE_CUSTO1-( (SD1->D1_VALIMP5*(SDE->DE_PERC/100) ) + (SD1->D1_VALIMP6*(SDE->DE_PERC/100) ) ))
		
      ELSEIF  SD1->D1_TES$(_cTes8)
		
	    _valResult:=(SDE->DE_CUSTO1)
		
	  ELSEIF SD1->D1_TES$(_cTes9)
		
		_valResult:=(SDE->DE_CUSTO1- (SD1->D1_ICMSCOM*(SDE->DE_PERC/100)) )
		
	  ELSEIF SD1->D1_TES$(_cTes10)
		
		_valResult:=(SDE->DE_CUSTO1+ (SD1->D1_VALIPI*(SDE->DE_PERC/100) ) )
		
	  ELSEIF SD1->D1_TES$(_cTes13)
	
	    _valResult:=(SDE->DE_CUSTO1- (SD1->D1_VALICM*(SDE->DE_PERC/100) ))
	
      ELSE
	   //	_valResult:=(SD1->D1_TOTAL+SD1->D1_VALIPI)	     
	   // TLM  - TES de IMPORTAÇÃO c/ EIC não fará lançamento padrão 650, verificar lançamentos 950.        
	     If !(SD1->D1_TES$(_CTESIMP))
	
		    _valResult:=(SDE->DE_CUSTO1+(SD1->D1_VALIPI*(SDE->DE_PERC/100) ))
	
	     EndIf
		
      ENDIF
	
   ENDIF
   
EndIf    


RETURN(_valResult)





	
