#include "Protheus.ch"    

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  MT080GRV     ∫Autor  Eduardo C. Romanini   ∫ Data ≥ 27/01/11 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Ponto de entrada na gravaÁ„o da TES                        ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕenvÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/     

/*
Funcao      : MT081GRV 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Este ponto de entrada ÅEexecutado apos a gravaÁ„o da TES e de suas dependÍncias dentro da mesma transaÁ„o do sistema.
Autor       : Eduardo C. Romanini
TDN         : Este ponto de entrada ÅEexecutado apos a gravaÁ„o da TES e de suas dependÍncias dentro da mesma transaÁ„o do sistema. 
Revis„o     : Tiago Luiz MendonÁa 
Data/Hora   : 06/02/2012
MÛdulo      : Fiscal/Faturamento/Estoque.
*/


*----------------------*
User Function MT081GRV()
*----------------------*
	U_MT080GRV()
Return Nil

*----------------------*
User Function MT080GRV()
*----------------------*
Local cBanco 	:= ""
Local cIpBco 	:= "10.0.30.5"
Local cAmb   	:= UPPER(GetEnvServer())
Local cArqF4 	:= "SF4YY0"
Local cFilF4 	:= ""
Local cCodF4 	:= ""
Local cQry		:= ""
Local nPorta 	:= 0

Local nCon 		:= 0
Local nDel 		:= 0
Local nI   		:= 0
Local nP   		:= 0
Local nConP1200	:= 0

Local aCpsF4  := {}
Local aAmb    := {}
Local aAreaF4 := SF4->(GetArea())
Local aAreaFC := SFC->(GetArea())
Local aArea	  := {}                   
//Local _nConnect := AdvConnection()

////////////////////////////////////////////////////
//Tratamento provisÛrio para que a rotina n„o seja//
//executada em caso de alteraÁ„o.                 //
////////////////////////////////////////////////////
If Altera                                         //
	MsgInfo("Para a operaÁ„o de alteraÁ„o, a "  +;//
	        "TES n„o serÅEreplicada nos demais "+;//
	        "ambientes.","AtenÁ„o")               //
	Return                                        //
EndIf                                             //
////////////////////////////////////////////////////

//Verifica se a empresa aponta para a tabela generica.
SX2->(DbSetOrder(1))
If SX2->(DbSeek("SF4"))
	If Right(AllTrim(SX2->X2_ARQUIVO),3) <> "YY0"
		MsgInfo("Para essa empresa, a TES n„o serÅEreplicada nos demais ambientes.","AtenÁ„o")
		Return
	EndIf  
EndIf

aArea := GetArea()  
//RRP - 05/04/2018 - Ajuste para consultar dinamicamente os ambientes
nConP1200 := TcLink( "MSSQL7/P12_00","172.16.16.152",7891 )  //CAS - 10/02/2020 Alterado dados da conex„o evido a Atual.Release e servidor (MSSQL7/P12_00 e 172.16.16.152)
If nConP1200 # 0

	//ValidaÁ„o se a inclus„o da TES estÅEno ambiente produÁ„o ou homologaÁ„o
	cQry :=" SELECT Z06_AMB FROM P12_00..Z06YY0 WHERE Z06_AMB LIKE '"+Left(cAmb,6)+"%' AND Z06_PROD = 'S' AND Z06_TES = 'S' "
	
	If TCSQLExec(cQry)<0
		MsgInfo("Ocorreu um problema na busca das informaÁıes no Amb. Adm P12_00!Favor abrir um chamado!","HLB BRASIL")
		Return
	EndIf

	If select("TRBPRO")>0
		TRBPRO->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBPRO",.T.,.T.)

	Count to nRecCount
	
	If nRecCount > 0
		
		//SELECT NO Ambiente Administrativo
		cQry := " SELECT * FROM P12_00..Z06YY0 "
		cQry += "  WHERE D_E_L_E_T_='' AND Z06_BD <> '' "
		cQry += "	 AND Z06_IPBD <> '' AND Z06_PORTOP <> '' "
		cQry += "	 AND Z06_MSBLQL <> '1' AND Z06_TES = 'S' AND Z06_PROD = 'S' "
	
		If TCSQLExec(cQry)<0
			MsgInfo("Ocorreu um problema na busca das informaÁıes no Amb. Adm P12_00!Favor abrir um chamado!","HLB BRASIL")
			Return
		EndIf
	
		If select("TRBQRY")>0
			TRBQRY->(DbCloseArea())
		EndIf
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBQRY",.T.,.T.)
	
		Count to nRecCount
	
		If nRecCount > 0
			TRBQRY->(DbGotop())
			While TRBQRY->(!EOF())  
//				If Left(cAmb,4) == Left(TRBQRY->Z06_AMB,4)
		   			AADD(aAmb,{TRBQRY->Z06_BD,TRBQRY->Z06_PORTOP,TRBQRY->Z06_IPBD})
//		   		EndIf
		   		TRBQRY->(DbSkip())
		   	EndDo
		EndIf
	Else
		MsgInfo("Ambiente cadastrado como HomologaÁ„o no Adm P12_00!TES n„o serÅEreplicada!","HLB BRASIL")
		Return
	EndIf
EndIf
//Encerra a conex„o
TCunLink(nConP1200)
aArea := RestArea(aArea)

//Adiciona os campos para indice
cFilF4 := xFilial("SF4")
cCodF4 := SF4->F4_CODIGO
   
//Adiciona os campos inclu˙Åos em um array.
For nI := 1 To SF4->(FCount())
	aAdd(aCpsF4,{FieldName(nI),&('SF4->'+FieldName(nI))})    
Next

//ReplicaÁ„o da TES nos demais ambientes.   
For nI := 1 To Len(aAmb)   
	cBanco := Alltrim(aAmb[nI][1])
    //nPorta := aAmb[nI][3]
    nPorta := VAL(aAmb[nI][2])
    cIpBco := Alltrim(aAmb[nI][3])
    
    //MSM - 07/01/2015 - chamado:031253 -AlteraÁ„o para conectar em porta diferente, pois o P11_18 ÅEem outro top.
	//Realiza a conex„o com o banco de dados.
	nCon := TCLink(cBanco,cIpBco,nPorta)

	If nCon < 0
		MsgInfo("Erro ao conectar com o banco de dados: " + cBanco,"AtenÁ„o")
        
	Else
        
        If TCCanOpen(cArqF4,"SF4YY01")
        
			If Select("F4TMP") > 0
				F4TMP->(DbCloseArea())
			EndIf                             
		
			//Abre a tabela do ambiente que serÅEatualizado.
			USE &cArqF4 ALIAS "F4TMP" Shared NEW VIA "TOPCONN" INDEX "SF4YY01"
				
			//RRP - 06/04/2018 - Verifica se a TES jÅEexiste no ambiente na inclus„o.
			If Inclui .AND. F4TMP->(DbSeek(cFilF4+cCodF4))
				Loop
			EndIf
			
			If Inclui
				F4TMP->(RecLock("F4TMP",.T.))
	        ElseIf Altera
				F4TMP->(DbSetOrder(1))
				If F4TMP->(DbSeek(cFilF4+cCodF4))
					F4TMP->(RecLock("F4TMP",.F.))
				Else
					F4TMP->(RecLock("F4TMP",.T.))
				EndIf
			EndIf
		         
			For nP := 1 To Len(aCpsF4)
				If F4TMP->(FieldPos(aCpsF4[nP][1])) > 0
					F4TMP->(FieldPut(FieldPos(aCpsF4[nP][1]),aCpsF4[nP][2]))
				EndIf
			Next
		           
			F4TMP->(MsUnlock())
		
			F4TMP->(DbCloseArea())
			
			//Encerra a conex„o
			TCunLink(nCon)
			
			MsgInfo("TES atualizada com sucesso em " + aAmb[nI][1],"HLB BRASIL")
		EndIf

	EndIf
	     	
Next

//Restaura a area.
RestArea(aAreaF4)
RestArea(aAreaFC)

If Select("F4TMP") > 0
	F4TMP->(DbCloseArea())
EndIf

If Select("TRBPRO") > 0
	TRBPRO->(DbCloseArea())
EndIf

If Select("TRBQRY") > 0
	TRBQRY->(DbCloseArea())
EndIf       

Return Nil	