#include "protheus.ch"

/*
Funcao      : MT100TOK
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada para validar o preenchimento da chave da nota.
TDN			: Este P.E. é chamado na função A103Tudok(). Pode ser usado para validar a inclusao da NF.
Autor       : Matheus Massarotto
Data/Hora   : 09/04/2012    18:25
Revisão		:
Data/Hora   : 
Módulo      : Estoque Custos  
Empresa     : Todos
*/                                          


*------------------------*
User function MT100TOK 
*------------------------*

Local lRet		:=.T.
Local nResult	:= 0
Local nPosNFOri := 0
Local cRotina	:= StrTran(Alltrim(UPPER(FunName())),'U_','')//RRP - 27/03/2015 - Ajuste para retirar o U_ da rotina caso esteja configurada dessa forma no menu.
Local AreaSF1   :=""
Local cDocCla	:=""
Local cSerCla	:=""
Local cFornCla	:=""
Local cLojaCla	:=""		
//RRP - 02/10/2013 - Ajuste para não apresentar erro ao inutilizar uma nota fiscal. 
//RRP - 25/03/2014 - Incluída a função KPXmlImp na validação, pois o execauto Mata920, utilizado nesse fonte, não é carregado a variável cespecie  
//JSS - 15/10/2014 - Incluido a função MATA920 pois o execauto Mata920, utilizado nesse fonte, não é carregado a variável cespecie  CHA 
//RRP - 30/05/2017 - Ajuste para rotinas via WebService. IsBlind() Retorna se há interface com usuário.
If FunName() == "SPEDNFE" .OR. cRotina == "KPXMLIMP" .OR. FunName() == "MATA920" .OR. cRotina == "INTPRYOR" .OR. IsBlind()
	Return(lRet)
EndIf

If alltrim(CESPECIE) == "NFE" .OR. Alltrim(CESPECIE) == "NF-E" .OR. Alltrim(CESPECIE) == "CTE" .OR. Alltrim(CESPECIE) == "CT-E"

	//SF1->F1_CHVNFE
	If Empty(aNFEDanfe[13])
		Alert("Campo Chave NFE(Aba Informações DANFE) não preenchido, obrigatoriedade devido ao EFD Contribuições(PIS/COFINS)"+CRLF+"Em caso de dúvidas verificar com o departamento fiscal.")
		lRet:=.F.		                                                                     
	ElseIf !Empty(aNFEDanfe[13]) .AND. len(alltrim(aNFEDanfe[13]))<44
		Alert("Campo Chave NFE(Aba Informações DANFE) fora do padrão(44 dígitos).")
		lRet:=.F.
	Else    
		//WFA - 17/10/2017 - Validar se chave ja existe em outro documento. Chamado:#11758

		cDocCla:= SF1->F1_DOC
		cSerCla:= SF1->F1_SERIE
		cFornCla:= SF1->F1_FORNECE
		cLojaCla:= SF1->F1_LOJA

		AreaSF1 := SF1->(GetArea())
		DbSelectArea("SF1")
		SF1->(dbSetOrder(8))
		If SF1->(DBSeek(xFilial("SF1")+aNFEDanfe[13]))
			If l103Class
				If cDocCla+cSerCla+cFornCla+cLojaCla <> SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) 
					MsgInfo("A Chave NFE informada ja foi utilizada em outro documento","HLB BRASIL")
					lRet:=.F.
				EndIf
			Else
				MsgInfo("A Chave NFE informada ja foi utilizada em outro documento","HLB BRASIL")
				lRet:=.F.
			EndIf
		EndIf
		RestArea(AreaSF1)

		//TLM - 15/06/2012 - Validar o status da chave digitada
		If lRet .AND. (alltrim(CESPECIE) == "NFE" .OR. Alltrim(CESPECIE) == "NF-E")
			lRet:=U_GTGEN003(aNFEDanfe[13])	
		EndIf		
	EndIf

EndIf
//WFA - 15/03/2018 - Criação de validação para notas de Frete. Ticket: #28432.
//MATHEUS RIBEIRO

IF "P11_" $ Alltrim(GetEnvServer()) 
	If (Alltrim(CESPECIE) == "CTE" .OR. Alltrim(CESPECIE) == "CTEOS")
		If SF1->(Empty(aInfAdic[8]) .OR. Empty(aInfAdic[09]) .OR. Empty(aInfAdic[10]) .OR. Empty(aInfAdic[11]))
			Alert("Os Documentos de Entrada com Especie CTE ou CTEOS devem ter os campos UF e Município de Origem e Destino preenchidos na aba Informações Adicionais")
			lRet:= .F.
		EndIf
	EndIf
ELSE	
	If (Alltrim(CESPECIE) == "CTE" .OR. Alltrim(CESPECIE) == "CTEOS")
		If SF1->(Empty(aInfAdic[10]) .OR. Empty(aInfAdic[11]) .OR. Empty(aInfAdic[12]) .OR. Empty(aInfAdic[13]))
			Alert("Os Documentos de Entrada com Especie CTE ou CTEOS devem ter os campos UF e Município de Origem e Destino preenchidos na aba Informações Adicionais")
			lRet:= .F.
		EndIf
	EndIf
ENDIF

/*  TLM - 17/08/2012
If cEmpAnt $ "K2"
//SF1->F1_CHVNFE
If !Empty(aNFEDanfe[13]) .AND. len(alltrim(aNFEDanfe[13]))<44
Alert("Campo Chave NFE(Aba Informações DANFE) fora do padrão(44 dígitos).")
lRet:=.F.			
EndIf
Endif
*/

//RRP - 18/06/2013 - Tratamento para Sumitomo
If cEmpAnt == 'FF'
	nPosNFOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})

	//Nao deixar incluir NF Entrada com as especie abaixo sem preencher o campo D1_NFORI  
	If Alltrim(cTipo) =='N' .And. Alltrim(cEspecie) $ 'CTR/CTE/CTR-E'

		For nx:=1 to len(aCols)
			If Alltrim(aCols[nx][nPosNFOri]) == ""
				nResult ++
			EndIf
		Next nx

		If nResult <> 0
			Alert("Campo 'Doct. Orig.' não preenchido! Obrigatoriedade devido à espécie da nota.")
			lRet:=.F.
		EndIf	
	EndIf 
EndIf   
//JSS - 06/05/2015 - Tratamento para solucionar o caso 025885
If cEmpAnt == 'SU/LG'//EXELTIS / 0001-52                  
	nPosNFOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})

	//Nao deixar incluir NF Entrada com as especie abaixo sem preencher o campo D1_NFORI  
	If Alltrim(cTipo) =='N' .And. Alltrim(cEspecie) $ 'CTR/CTE/CTR-E'

		For nx:=1 to len(aCols)
			If Alltrim(aCols[nx][nPosNFOri]) == ""
				nResult ++
			EndIf
		Next nx

		If nResult <> 0
			Alert("Campo 'Doct. Orig.' não preenchido! Obrigatoriedade devido à espécie da nota.")
			lRet:=.F.
		EndIf	
	EndIf 
EndIf      

//Verifica se é a empresa Vogel
if cEmpAnt $ u_EmpVogel()
	nPosTes := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})


	cTesBloq:= GetNewPar("MV_P_00097", "499")

	If !Empty(cTesBloq) 

		For nx:=1 to len(aCols)
			If UPPER(Alltrim(aCols[nx][nPosTes])) == UPPER(alltrim(cTesBloq))
				nResult ++
			EndIf
		Next nx

		If nResult <> 0
			Alert("TES "+alltrim(cTesBloq)+" não é permitida para inclusão de NF, reclassifique a nota!")
			lRet:=.F.
		EndIf	
	EndIf 
endif

Return(lRet)