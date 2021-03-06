#include "protheus.ch"

/*
Funcao      : MT100TOK
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada para validar o preenchimento da chave da nota.
TDN			: Este P.E. � chamado na fun��o A103Tudok(). Pode ser usado para validar a inclusao da NF.
Autor       : Matheus Massarotto
Data/Hora   : 09/04/2012    18:25
Revis�o		:
Data/Hora   : 
M�dulo      : Estoque Custos  
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
//RRP - 02/10/2013 - Ajuste para n�o apresentar erro ao inutilizar uma nota fiscal. 
//RRP - 25/03/2014 - Inclu�da a fun��o KPXmlImp na valida��o, pois o execauto Mata920, utilizado nesse fonte, n�o � carregado a vari�vel cespecie  
//JSS - 15/10/2014 - Incluido a fun��o MATA920 pois o execauto Mata920, utilizado nesse fonte, n�o � carregado a vari�vel cespecie  CHA 
//RRP - 30/05/2017 - Ajuste para rotinas via WebService. IsBlind() Retorna se h� interface com usu�rio.
If FunName() == "SPEDNFE" .OR. cRotina == "KPXMLIMP" .OR. FunName() == "MATA920" .OR. cRotina == "INTPRYOR" .OR. IsBlind()
	Return(lRet)
EndIf

If alltrim(CESPECIE) == "NFE" .OR. Alltrim(CESPECIE) == "NF-E" .OR. Alltrim(CESPECIE) == "CTE" .OR. Alltrim(CESPECIE) == "CT-E"

	//SF1->F1_CHVNFE
	If Empty(aNFEDanfe[13])
		Alert("Campo Chave NFE(Aba Informa��es DANFE) n�o preenchido, obrigatoriedade devido ao EFD Contribui��es(PIS/COFINS)"+CRLF+"Em caso de d�vidas verificar com o departamento fiscal.")
		lRet:=.F.		                                                                     
	ElseIf !Empty(aNFEDanfe[13]) .AND. len(alltrim(aNFEDanfe[13]))<44
		Alert("Campo Chave NFE(Aba Informa��es DANFE) fora do padr�o(44 d�gitos).")
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
//WFA - 15/03/2018 - Cria��o de valida��o para notas de Frete. Ticket: #28432.
//MATHEUS RIBEIRO

IF "P11_" $ Alltrim(GetEnvServer()) 
	If (Alltrim(CESPECIE) == "CTE" .OR. Alltrim(CESPECIE) == "CTEOS")
		If SF1->(Empty(aInfAdic[8]) .OR. Empty(aInfAdic[09]) .OR. Empty(aInfAdic[10]) .OR. Empty(aInfAdic[11]))
			Alert("Os Documentos de Entrada com Especie CTE ou CTEOS devem ter os campos UF e Munic�pio de Origem e Destino preenchidos na aba Informa��es Adicionais")
			lRet:= .F.
		EndIf
	EndIf
ELSE	
	If (Alltrim(CESPECIE) == "CTE" .OR. Alltrim(CESPECIE) == "CTEOS")
		If SF1->(Empty(aInfAdic[10]) .OR. Empty(aInfAdic[11]) .OR. Empty(aInfAdic[12]) .OR. Empty(aInfAdic[13]))
			Alert("Os Documentos de Entrada com Especie CTE ou CTEOS devem ter os campos UF e Munic�pio de Origem e Destino preenchidos na aba Informa��es Adicionais")
			lRet:= .F.
		EndIf
	EndIf
ENDIF

/*  TLM - 17/08/2012
If cEmpAnt $ "K2"
//SF1->F1_CHVNFE
If !Empty(aNFEDanfe[13]) .AND. len(alltrim(aNFEDanfe[13]))<44
Alert("Campo Chave NFE(Aba Informa��es DANFE) fora do padr�o(44 d�gitos).")
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
			Alert("Campo 'Doct. Orig.' n�o preenchido! Obrigatoriedade devido � esp�cie da nota.")
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
			Alert("Campo 'Doct. Orig.' n�o preenchido! Obrigatoriedade devido � esp�cie da nota.")
			lRet:=.F.
		EndIf	
	EndIf 
EndIf      

//Verifica se � a empresa Vogel
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
			Alert("TES "+alltrim(cTesBloq)+" n�o � permitida para inclus�o de NF, reclassifique a nota!")
			lRet:=.F.
		EndIf	
	EndIf 
endif

Return(lRet)