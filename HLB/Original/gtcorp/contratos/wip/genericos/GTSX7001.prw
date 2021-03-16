#Include "Protheus.ch"

/*
Funcao      : GTSX7001
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gatilhar o valor + impostos para o valor bruto da proposta
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 09/08/2013    10:28
Módulo      : Genérico
*/

*-------------------------*
User Function GTSX7001()
*-------------------------*
Local nRet		 := 0
Local nVlrLiqSur := 0
Local nVlrImp	 := 0
Local nPosVlLiq  := 0  
Local nPosVlSur  := 0
Local nPosHora   := 0  
Local nPosTxSur  := 0
Local nPosRecup  := 0
Local nPosVlBru  := 0

//Valor liquivo mais porcentagem de surcharge
nVlrLiqSur:=( M->Z55_VLRLIQ + (M->Z55_VLRLIQ*(M->Z55_SURCHA/100))) 
//nVlrImp:=M->Z55_IMPOST/100
nVlrImp:=((100-M->Z55_IMPOST)/100)

//nRet:=nVlrLiqSur+(nVlrLiqSur*nVlrImp)
nRet:= nVlrLiqSur /nVlrImp

///////////////////////////////////////////////////////////
//ECR - Calculo o valor do Preço Liq + Surcharge no grid.//
///////////////////////////////////////////////////////////

//Retorna a posição dos campos no grid
nPosVlLiq := aScan(oGetDados:aHeader,{|x| Alltrim(x[2])=="Z54_PRECOL"})
nPosVlSur := aScan(oGetDados:aHeader,{|x| Alltrim(x[2])=="Z54_PRELSU"})
nPosHora  := aScan(oGetDados:aHeader,{|x| Alltrim(x[2])=="Z54_HORAPR"})
nPosTxSur := aScan(oGetDados:aHeader,{|x| Alltrim(x[2])=="Z54_TXMESU"})
nPosRecup := aScan(oGetDados:aHeader,{|x| Alltrim(x[2])=="Z54_RECUPE"})
nPosVlBru := aScan(oGetDados:aHeader,{|x| Alltrim(x[2])=="Z54_CUSTOT"})

//Loop em todas as linhas do grid
For nI:=1 to len(oGetDados:aCols)
    
	//Verifica se a linha não está apagada.
	If !oGetDados:aCols[nI][Len(oGetDados:aCols[nI])]	

		//Calcula o valor do Preço Liq. + Surcharge.
		oGetDados:aCols[nI][nPosVlSur] := oGetDados:aCols[nI][nPosVlLiq] + (oGetDados:aCols[nI][nPosVlLiq] * (M->Z55_SURCHA/100))

		//Calcula a taxa média com surcharge.
		oGetDados:aCols[nI][nPosTxSur] := oGetDados:aCols[nI][nPosVlSur] / oGetDados:aCols[nI][nPosHora]
		
		//Calcula a taxa de recuperação
		oGetDados:aCols[nI][nPosRecup] := (oGetDados:aCols[nI][nPosVlSur] * 100)/oGetDados:aCols[nI][nPosVlBru]
		
	EndIf
Next

oGetDados:Refresh()
////////Fim da atualização do grid/////////

Return(ROUND(nRet,2))