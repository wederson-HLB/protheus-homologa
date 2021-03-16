#Include "Protheus.ch"

/*
Funcao      : GTCORP22
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função para filtro da consulta SB1Z85, utilizada no cadastro de proposta
Autor       : Matheus Massarotto
Data/Hora   : 28/06/2012
Revisao     : 
Data/Hora   :
Obs.        : 
*/

*-----------------------*
User Function GTCORP22()
*-----------------------*
Local cRet  := "alltrim(SB1->B1_COD)<>''"
Local cTipo	:= M->Z86_TPCTR
Local nAt  := 0
Local nPos := 0

Local aCbox := {}

Local lRet:=.T.

if !empty(cTipo)

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("Z86_TPCTR"))
	
		cCbox := AllTrim(SX3->X3_CBOX)
		nAt := At(";",cCbox)
		While nAt > 0
			cAux  := Left(cCbox,nAt-1)
											
			aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 
											
			cCbox := Substr(cCbox,nAt+1)
			nAt := At(";",cCbox)
		EndDo
		cAux  := cCbox
		aAdd(aCbox,{Left(cAux,1),Substr(cAux,3)}) 			
	EndIf
	
	nPos := aScan(aCbox,{|a| Alltrim(a[1])== AllTrim(cTipo)})
	
	cDescOpc := SUBSTR(aCbox[nPos][2],1,3)
	
	cRet:=FilProd(cDescOpc)

endif

Return &cRet

/*
Funcao      : FilProd()  
Parametros  : cDescOpc
Retorno     : cFil
Objetivos   : Retorna o filtro de acordo com o tipo de proposta escolhida
Autor       : Matheus Massarotto
Data/Hora   : 31/05/2012
*/
*-------------------------------*
Static Function FilProd(cDescOpc)
*-------------------------------*
Local cFil:=""

if cDescOpc=="TAX"
	// "500034/500035/500036/500037/500038/500039/500040/500041/500042/500044/500043"'
	cFil:="alltrim(SB1->B1_COD)>='500034' .AND.  alltrim(SB1->B1_COD)<='500043'"
elseif cDescOpc=="ADV"
	// "500045/500046/500047/500048/500049/500050/500051/500052/500053/500054/500055/500056"'
	cFil:="alltrim(SB1->B1_COD)>='500045' .AND.  alltrim(SB1->B1_COD)<='500056'"
elseif cDescOpc=="AUD"
	// "500029/500030/500031"'
	cFil:="alltrim(SB1->B1_COD)>='500029' .AND.  alltrim(SB1->B1_COD)<='500031'"	
elseif cDescOpc=="OUT"
	// "500029/500030/500031"'
	cFil:="SUBSTR(alltrim(SB1->B1_COD),1,2)<>'DE' .AND.  SUBSTR(alltrim(SB1->B1_COD),1,1)<>'2'"	
elseif cDescOpc=="COR"
	// "500029/500030/500031"'
	cFil:="SUBSTR(alltrim(SB1->B1_COD),1,2)<>'DE' .AND.  SUBSTR(alltrim(SB1->B1_COD),1,1)<>'2'"	
else
	cFil:="alltrim(SB1->B1_COD)<>''"
endif

Return(cFil)
