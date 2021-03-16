#Include 'Totvs.Ch'

/*
Funcao      : CHGX5FIL
Parametros  : Nenhum
Retorno     : cFilSX5
Objetivos   : P.E. Antes da janela para selecionar a série da nota fiscal. 
Autor       : Renato Rezende
Data/Hora   : 19/10/2016
TDN         : Este Ponto de Entrada, localizado no TMSA200.PRW(Cálculo do Frete), foi criado para utilizar uma Tabela 01 exclusiva em um SX5 compartilhado
Módulo      : Faturamento
*/

*----------------------------*
 User Function CHGX5FIL()
*----------------------------* 
Local cFilSX5 := xFilial("SX5")

//Verifica se é a empresa Vogel
If cEmpAnt $ u_EmpVogel()
	If ZX3->(DbSeek(xFilial('ZX3')+cEmpAnt+cFilAnt+SB1->B1_TIPO))
		If ZX3->ZX3_EXCLU
			cFilSX5 := cFilAnt
		EndIf
	EndIf

//RRP - 04/09/2017 - X5 exclusivo, projeto das filiais
//Media
ElseIf cEmpAnt == "UY"
    //RRP - 07/11/2018 - Retirada a customizacao
    //Criação de série e ajuste dos parâmetors MV_ESPECIE e MV_SER79
    //UYSerie()
    
    //SX5 tabela 01 exclusiva
	cFilSX5 := cFilAnt

//AOA - 07/08/2018 - Ajuste para tratamento de filial para doTerra
ElseIf cEmpAnt == "N6"
    //SX5 tabela 01 exclusiva
	cFilSX5 := cFilAnt
	
EndIf

Return cFilSX5

/*
Funcao      : UYSerie
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Criação de série e ajuste dos parâmetors MV_ESPECIE e MV_SER79
Autor       : Renato Rezende
Data/Hora   : 05/09/2017
*/

*----------------------------*
 Static Function UYSerie()
*----------------------------*
Local cEspecie	:= ""
Local cSerieNF	:= ""
Local cESer79	:= ""
Local cQuery	:= ""

Local nRecCount	:= 0
Local nDigitos	:= 9

Local dDataSis	:= dDataBase

//Verifica se é a empresa Media
If cEmpAnt == "UY"

	//Verifica se precisa criar a série nova de telecom e ajuste das séries inclusas nos parâmetros
	UYTeleco(dDataSis)

	If Select("TZX1") > 0
		TZX1->(DbCloseArea())
	EndIf
	
	cQuery:= " SELECT * FROM "+RetSQLName("ZX1")+" " +CRLF
	cQuery+= "  WHERE ZX1_EMPFIL = '"+cEmpAnt+cFilAnt+"' AND D_E_L_E_T_ <> '*' " +CRLF
	cQuery+= "	  AND ZX1_MSBLQL <> '1' " +CRLF
	cQuery+= "	ORDER BY ZX1_DATAIN DESC " +CRLF
	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TZX1",.F.,.T.)
	
	Count to nRecCount
	
	TZX1->(DbGoTop())
	
	//Retornou resultado no select
	If nRecCount > 0

		//Percorrer as series
		While TZX1->(!Eof())
			
			cSerieNF := TZX1->ZX1_SERIE
			nDigitos := 9
			
			//Verifica se será 6 ou 9 digitos
			If TZX1->ZX1_TIPONF $ "S/T"
				nDigitos:= 6
			EndIf
			
			DbSelectArea("SX5")
			SX5->(DbSetOrder(1))
			//Se não encontrar a série, criar no SX5 tabela 01
			If !SX5->(DbSeek(cFilAnt + PadR('01',Len(SX5->X5_TABELA)) + PadR(cSerieNF,Len(SX5->X5_CHAVE))))
				SX5->( RecLock( "SX5" , .T. ) )
				SX5->X5_FILIAL := cFilAnt
				SX5->X5_TABELA := '01'
				SX5->X5_CHAVE  := cSerieNF
				SX5->X5_DESCRI := PadL('1',nDigitos,'0')
				SX5->(MSUnlock())
			EndIf
			
			//Guardar so os ultimos 4 meses no parametro
			cEspecie += Alltrim(TZX1->ZX1_SERIE) + "=" + Alltrim(TZX1->ZX1_ESPECI) + ";"
			
			//Guardar so os ultimos 4 meses no parametro
			If TZX1->ZX1_TIPONF == 'T' //Nota Telecom
				cESer79 += Alltrim(TZX1->ZX1_SERIE)+ "/"
			EndIf
			  	
			TZX1->(DbSkip())
		
		EndDo
	
		//Criação do parâmetro MV_ESPECIE por filial
		SX6->(DbSetorder(1))
		If SX6->(!DbSeek(cFilAnt + 'MV_ESPECIE'))
			SX6->(RecLock('SX6',.T.))
			SX6->X6_FIL		:= cFilAnt
			SX6->X6_VAR		:= 'MV_ESPECIE'
			SX6->X6_TIPO	:= 'C'
			SX6->X6_DESCRIC	:= 'Contem tipos de documentos fiscais utilizados na'
			SX6->X6_DESC1	:= 'emissao de notas fiscais'
			SX6->X6_CONTEUD	:= cEspecie
			SX6->(MSUnlock())
		Else
			SX6->(RecLock('SX6',.F.))
			SX6->X6_CONTEUD	:= cEspecie    
			SX6->(MSUnlock())
		EndIf              
		
		//Criação do parâmetroMV_SER79 por filial                            
		If SX6->(!DbSeek(cFilAnt + 'MV_SER79'))
			SX6->(RecLock('SX6',.T.))
			SX6->X6_FIL		:= cFilAnt
			SX6->X6_VAR		:= 'MV_SER79'
			SX6->X6_TIPO	:= 'C'
			SX6->X6_DESCRIC	:= 'Series que devem ser consideradas para as Notas'
			SX6->X6_DESC1	:= 'Fiscais Modelo 01 da CAT79.'
			SX6->X6_CONTEUD	:= cESer79
			SX6->(MSUnlock())
		Else
			SX6->(RecLock('SX6',.F.))
			SX6->X6_CONTEUD := cESer79
			SX6->(MSUnlock())
		EndIf
    Else
		MsgInfo("Filial não configurada para criação de série automática!","HLB BRASIL")
	EndIf
EndIf

Return Nil

/*
Funcao      : UYTeleco
Parametros  : dDataSis
Retorno     : Nenhum
Objetivos   : Verifica se precisa criar a série nova de telecom e ajuste das séries inclusas nos parâmetros
Autor       : Renato Rezende
Data/Hora   : 05/09/2017
*/

*------------------------------------*
 Static Function UYTeleco(dDataSis)
*------------------------------------*
Local lRet		:= .T.
Local cQuery	:= ""
Local cQuery2	:= ""
Local nRecCount	:= 0

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf		   

cQuery:= " SELECT * FROM "+RetSQLName("ZX1")+" " +CRLF
cQuery+= "  WHERE ZX1_EMPFIL = '"+cEmpAnt+cFilAnt+"' AND D_E_L_E_T_ <> '*' " +CRLF
cQuery+= "	  AND ZX1_TIPONF = 'T' " +CRLF
cQuery+= "	  AND ZX1_DATAIN BETWEEN '"+DtoS(FirstDay(dDataSis)) +"' AND '"+DtoS(LastDay(dDataSis))+"' " +CRLF

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

Count to nRecCount

QRY->(DbGoTop())

//Não retornou resultado no select
If nRecCount == 0

	If Select("SQRY") > 0
		SQRY->(DbCloseArea())
	EndIf
	
	cQuery2:= " SELECT TOP 1 ZX1_SERIE FROM "+RetSQLName("ZX1")+" " +CRLF
	cQuery2+= "  WHERE ZX1_EMPFIL = '"+cEmpAnt+cFilAnt+"' AND D_E_L_E_T_ <> '*' " +CRLF
	cQuery2+= "	  AND ZX1_TIPONF = 'T' " +CRLF
	cQuery2+= "	ORDER BY ZX1_DATAIN DESC " +CRLF
	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery2),"SQRY",.F.,.T.)

	ZX1->(RecLock('ZX1',.T.))
		ZX1->ZX1_EMPFIL		:= cEmpAnt+cFilAnt
		ZX1->ZX1_EXCLU		:= .T.
		ZX1->ZX1_DATAIN		:= FirstDay(dDataSis)
		ZX1->ZX1_SERIE		:= Soma1(SQRY->ZX1_SERIE)
		ZX1->ZX1_TIPONF		:= 'T'
		ZX1->ZX1_ESPECIE	:= 'NTST'
		ZX1->ZX1_MSBLQL		:= '1'
	ZX1->(MSUnlock())
EndIf

//Update direto no banco para Bloquear todas as séries de telecom
TcSqlExec( "UPDATE " + RetSqlName( "ZX1" ) + " SET ZX1_MSBLQL = '1' " +;
		   " WHERE ZX1_EMPFIL = '"+cEmpAnt+cFilAnt+"' AND D_E_L_E_T_ <> '*' AND ZX1_TIPONF = 'T' " )

//Update direto no banco para desbloquear as ultimas 4 séries de telecom
TcSqlExec( "UPDATE " + RetSqlName( "ZX1" ) + " SET ZX1_MSBLQL = '2' " +;
		   " WHERE ZX1_EMPFIL = '"+cEmpAnt+cFilAnt+"' AND D_E_L_E_T_ <> '*' AND ZX1_TIPONF = 'T' " +;
		   "   AND ZX1_SERIE IN (SELECT TOP 4 ZX1_SERIE FROM " + RetSqlName( "ZX1" ) + " WHERE ZX1_TIPONF = 'T' AND ZX1_EMPFIL = '"+cEmpAnt+cFilAnt+"' " +; 
								" AND D_E_L_E_T_ <> '*' AND ZX1_DATAIN <= "+DtoS(dDataSis)+" ORDER BY ZX1_DATAIN DESC )" )
								
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

If Select("SQRY") > 0
	SQRY->(DbCloseArea())
EndIf

Return Nil