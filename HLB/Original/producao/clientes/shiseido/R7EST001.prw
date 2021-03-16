#INCLUDE "Protheus.ch"

/*
Funcao      : R7EST001
Parametros  : 
Retorno     : .T.
Objetivos   : Utilizado na validação de usuário do campo D1_TES
            : Buscar o valor de venda da tabela SB0 e fazer o cálculo para colocar atualizar a BASEIPI e ValorIPI do D1, na inclusão da Nota. 
Autor       : Matheus Massarotto
Data/Hora   : 30/10/2012    17:01
Revisão		:                    
Data/Hora   : 
Módulo      : Estoque
*/

*----------------------*
User function R7EST001()
*----------------------*
Local aArea		:= GETAREA()
Local cTes		:= alltrim(aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="D1_TES"})])
Local cCodPro	:= aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="D1_COD"})]
Local nAliqIpi	:= SB1->B1_IPI
Local nQuanti	:= aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="D1_QUANT"})]

if cEmpAnt $ "R7/VJ"

	if empty(cTes) .OR. empty(cCodPro) .OR. empty(nAliqIpi) .OR. empty(nQuanti)
		Return(.T.)
	endif
	
	if cTes $ GETMV("MV_P_TESLJ")

		DbSelectArea("SB0")
		SB0->(DbSetOrder(1))
		if SB0->(DbSeek(xFilial("SB0")+cCodPro)) // Buscando valor de venda
						
			_nValTab := SB0->B0_PRV1
			
			BASEIPI  := ((_nValTab * nQuanti) * 0.90) 
			VALORIPI := (((_nValTab * nQuanti) * 0.90) * nAliqIpi)/100
			
			//Atualiza Item do documento de entrada de acordo com calculo acima
			aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="D1_BASEIPI"})]	:= BASEIPI
			aCols[n][aScan(aHeader,{|x|AllTrim(x[2])=="D1_VALIPI"})]	:= VALORIPI
            
			//Atualiza o valor do IPI na aba impostos
			MaFisRef("IT_VALIPI","MT100",VALORIPI)
			//Atualiza o valor do Base do IPI na aba impostos
			MaFisRef("IT_BASEIPI","MT100",BASEIPI)

		endif
		
	endif

endif

RESTAREA(aArea)
Return(.T.)