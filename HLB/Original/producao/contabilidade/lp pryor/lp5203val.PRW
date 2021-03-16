#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03
#include "topconn.ch"
User Function lp5203val()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

Local cPrefixo := ""
Local cNumero  := ""
Local cParcela := ""
Local cTipo    := ""
Local cCliente := ""
Local cLoja    := ""
Local nValor := 0

DbSelectArea("SE1")
cAlias := Alias()
nOrder := DbSetOrder()
nRecno := Recno()

cPrefixo  := SE1->E1_PREFIXO
cNumero   := SE1->E1_NUM
cParcela  := SE1->E1_PARCELA
cCliente  := SE1->E1_CLIENTE
cLoja     := SE1->E1_LOJA
cSituaca  := SE1->E1_SITUACA
cSaldo    := SE1->E1_SALDO
cAmbiente := GetEnvServer()

DbSetOrder(1)


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao////////////s utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
// ALTERA합ES FEITA DIA 01/02/05 POR JOS  F. REFERENTES A LEI 10925     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

///// SetPrvt("_VRETORNO")

_vRetorno := 0
If AllTrim(FunName())$ "FINA200"
	//If !Empty(SE1->E1_PREFIXO) .And. !Empty(SE1->E1_NUM) .And. !Empty(SE1->E1_TIPO) - TMS 27/11/2019 - condi豫o apenas para empresa "MN" na linha 45
		//AOA - 06/01/2016 - Estava somando o juros de forma indevida no LP - chamado 031340
		If cEmpAnt $ "MN" .And. !Empty(SE1->E1_PREFIXO) .And. !Empty(SE1->E1_NUM) .And. !Empty(SE1->E1_TIPO)
			_vRetorno := SE1->E1_VALOR-SE1->E1_DESCONT   
		ElseIf cEmpAnt $ "QN"
	        _vRetorno :=(SE1->E1_VALOR+SE1->E1_MULTA)-SE1->E1_DESCONT
		Else
			_vRetorno :=(SE1->E1_VALOR+SE1->E1_MULTA+SE1->E1_JUROS)-SE1->E1_DESCONT
		EndIf
	//EndIf
Else                    
	If cEmpAnt $ "40"
		IF cSaldo = 0
			
			_vRetorno := SE5->E5_VALOR       // valor do pagamento
			_vRetorno += SE1->E1_DESCONT	 // valor do desconto
			_vRetorno += SE1->E1_IRRF        // valor do IRRF
			_vRetorno -= SE1->E1_JUROS       // valor dos juros
			_vRetorno -= SE1->E1_MULTA       // valor da multa
			
			ctipo := "PI-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CF-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CS-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF 
			ctipo := "IR-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				//CAS - 20-09-2019 Ajuste para contabilizar o IR se data maior que 01-09-2019
				IF DTOS(SE1->E1_EMISSAO) < "20190901"
					_vRetorno -= SE1->E1_VALOR
				EndIF
			ENDIF
			
		ELSEIF cSaldo <> 0
			_vRetorno := SE5->E5_VALOR
			_vRetorno += SE1->E1_DESCONT
			_vRetorno -= SE1->E1_JUROS
			_vRetorno -= SE1->E1_MULTA
			
			ctipo := "PI-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CF-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CS-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF    
			ctipo := "IR-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno -= SE1->E1_VALOR
			ENDIF
			
		ELSE
			_vRetorno := 0
		EndIf
	EndIf
	
	IF cSituaca = "0" .AND. cEmpAnt <> "40"
		IF cSaldo = 0
			
			_vRetorno := SE5->E5_VALOR       // valor do pagamento
			_vRetorno += SE1->E1_DESCONT	 // valor do desconto
			_vRetorno += SE1->E1_IRRF        // valor do IRRF
			_vRetorno -= SE1->E1_JUROS       // valor dos juros
			_vRetorno -= SE1->E1_MULTA       // valor da multa
			
			ctipo := "PI-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CF-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CS-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF 
			ctipo := "IR-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno -= SE1->E1_VALOR
			ENDIF
			
		ELSEIF cSaldo <> 0
			_vRetorno := SE5->E5_VALOR
			_vRetorno += SE1->E1_DESCONT
			_vRetorno -= SE1->E1_JUROS
			_vRetorno -= SE1->E1_MULTA
			
			ctipo := "PI-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CF-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF
			ctipo := "CS-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno += SE1->E1_VALOR
			ENDIF    
			ctipo := "IR-"
			DbSetOrder(1)
			IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
				_vRetorno -= SE1->E1_VALOR
			ENDIF
			
		ELSE
			_vRetorno := 0
		endif
		
	ELSEIF cSituaca $ "1/3/".AND. cEmpAnt <> "40"
		IF cSaldo = 0
			_vRetorno := SE5->E5_VALOR      			// valor do pagamento
			_vRetorno := _vRetorno + SE1->E1_DESCONT	// valor do desconto
			_vRetorno := _vRetorno + SE1->E1_IRRF       // valor do IRRF
			_vRetorno := _vRetorno - SE1->E1_JUROS      // valor dos juros
			_vRetorno := _vRetorno - SE1->E1_MULTA      // valor da multa
			
			IF SUBSTR(GETVERSAO(),1,3) = 'AP7'
				ctipo := "PI-"
				IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
					_vRetorno := _vRetorno + SE1->E1_VALOR
				ENDIF
				ctipo := "CF-"
				IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
					_vRetorno := _vRetorno + SE1->E1_VALOR
				ENDIF
				ctipo := "CS-"
				IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
					_vRetorno := _vRetorno + SE1->E1_VALOR
				ENDIF
			ELSE
				_vRetorno := _vRetorno + SE1->E1_COFINS         //  ALTERACAOES
				_vRetorno := _vRetorno + SE1->E1_PIS            // REFERENTES  A LEI
				_vRetorno := _vRetorno + SE1->E1_CSLL           //      10925
			ENDIF
		ELSEIF cSaldo <> 0
			_vRetorno := SE5->E5_VALOR
			_vRetorno := _vRetorno + SE1->E1_DESCONT
			_vRetorno := _vRetorno - SE1->E1_JUROS
			
			//		If! Empty(SE5->E5_ARQCNAB)
			//		    _vRetorno += SE5->E5_VLJUROS       // valor dos juros
			//		Endif
			
			_vRetorno := _vRetorno - SE1->E1_MULTA
		ELSE
			_vRetorno := 0
		endif
		
	ELSEIF cSituaca = "2".AND. cEmpAnt <> "40"
		IF cSaldo = 0
			_vRetorno := SE5->E5_VALOR      					// valor do pagamento
			_vRetorno := _vRetorno + SE1->E1_DESCONT		// valor do desconto
			_vRetorno := _vRetorno + SE1->E1_IRRF        // valor do IRRF
			_vRetorno := _vRetorno - SE1->E1_JUROS       // valor dos juros
			_vRetorno := _vRetorno - SE1->E1_MULTA       // valor da multa
			//		IF cEmpant $"Z4/CZ/FA/DT/YY/CD/FI/ZK/CH/".OR. upper(cAmbiente) == "AMB02".OR. upper(cAmbiente) == "AMB03"
			IF SUBSTR(GETVERSAO(),1,3) = 'AP7'
				ctipo := "PI-"
				IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
					_vRetorno := _vRetorno + SE1->E1_VALOR
				ENDIF
				ctipo := "CF-"
				IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
					_vRetorno := _vRetorno + SE1->E1_VALOR
				ENDIF
				ctipo := "CS-"
				IF DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
					_vRetorno := _vRetorno + SE1->E1_VALOR
				ENDIF
			ELSE
				_vRetorno := _vRetorno + SE1->E1_COFINS
				_vRetorno := _vRetorno + SE1->E1_PIS
				_vRetorno := _vRetorno + SE1->E1_CSLL
			ENDIF
			
		ELSEIF cSaldo <> 0
			_vRetorno := SE5->E5_VALOR
			_vRetorno := _vRetorno + SE1->E1_DESCONT
			_vRetorno := _vRetorno - SE1->E1_JUROS
			_vRetorno := _vRetorno - SE1->E1_MULTA
		ELSE
			_vRetorno := 0
		endif
	ENDIF
EndIf

DbSelectArea(cAlias)
DbSetOrder(nOrder)
DbGoto(nRecno)


RETURN(_vRetorno)
