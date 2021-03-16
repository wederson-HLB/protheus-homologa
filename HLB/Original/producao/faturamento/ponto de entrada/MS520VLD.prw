#include "Protheus.ch"
#include "Topconn.Ch"


/*
Funcao      : MS520VLD
Parametros  : 
Retorno     : Nil
Objetivos   : Ponto de entrada, no MATA521.
TDN			: Esse ponto de entrada é chamado para validar ou não a exclusão da nota na rotina MATA521
Autor       : Matheus Massarotto
Data/Hora   : 25/03/2015    09:34
Revisão		:                    
Data/Hora   : 
Módulo      : Faturamento
*/

*--------------------*
User function MS520VLD
*--------------------*
Local aHeaderLog 	:= { 'EMP','FILIAL','STATUS','C5_NUM','C5_P_REF','A1_CGC','D2_SERIE','D2_DOC','D2_EMISSAO','D2_COD','D2_TOTAL','D2_CF' }
Local cArquivo  	:= ''
Local aLog 			:= {}    
Local aAux
Local cAliasQ

Private aArea		:= GetArea()
Private lRet		:= .T.
Private lValidExc	:= GetNewPar("MV_P_00049",.F.)



if cEmpAnt $ "TP" //Twitter
                                                      

	if lValidExc
		if SF2->(FieldPos("F2_P_ARQ"))>0
			if !empty(SF2->F2_P_ARQ)
				Msginfo("Esse documento não pode ser excluído pois já foi enviado para o sistema Oracle – Tiwitter.","HLB BRASIL")
				lRet:=.F.
			endif
		endif
	endif
endif   


If lRet

	/*
		* LDB - 17/08/2016 - Projeto Vogel
	*/
	If ( cEmpAnt $  u_EmpVogel() ) .And. ( SF2->F2_TIPO == 'N' ) .And. ( SF2->F2_P_SISTE == 'S' )
		
		cArquivo := 'SAIDAS_CANC_' + SM0->M0_CGC + '_' + DtoS( dDataBase ) + StrTran( Time() , ':' , '' ) + '.CSV' 
		Aadd( aLog , { , aHeaderLog } )	                
		Aadd( aLog , { cArquivo , {} }  )

		cSql := "SELECT C5_NUM,C5_P_REF,A1_CGC,D2_SERIE,D2_DOC,D2_EMISSAO,D2_DOC,D2_TOTAL,D2_CF,D2_COD "
		cSql += "FROM " + RetSqlName( "SD2" ) + " D2 INNER JOIN " + RetSqlName( "SA1" ) +  " A1 ON D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA "
		cSql += "INNER JOIN " + RetSqlName( "SC5" ) + " C5 ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO "   
		cSql += "WHERE C5.D_E_L_E_T_ = '' AND D2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' AND "
		cSql += "A1_FILIAL = '" + xFilial( 'SA1' ) + "' AND C5_FILIAL = '" + xFilial( 'SC5' ) + "' AND D2_FILIAL = '" + xFilial( 'SD2' ) + "' AND "
		cSql += "D2_DOC = '" + SF2->F2_DOC + "' AND D2_SERIE = '" + SF2->F2_SERIE + "' " 
	
	    cAliasQ := GetNextAlias()
	    TCQuery cSql ALIAS ( cAliasQ ) NEW
	    
		While ( cAliasQ )->( !Eof() )
		    aAux := { SM0->M0_CGC ,;
						cFilAnt ,;
						'C',;
						( cAliasQ )->C5_NUM ,;
						( cAliasQ )->C5_P_REF,;
						( cAliasQ )->A1_CGC,;
						( cAliasQ )->D2_SERIE,;
						( cAliasQ )->D2_DOC,;
						DtoC( StoD( ( cAliasQ )->D2_EMISSAO ) ) ,;
						( cAliasQ )->D2_COD,;
						Transf( ( cAliasQ )->D2_TOTAL , "@R 99999999999.99" ) ,;
						( cAliasQ )->D2_CF }
							
			Aadd( aLog[ 2 ][ 2 ] , aAux )
			( cAliasQ )->( DbSkip() )
		EndDo    

	    /*
	    	* Gera arquivo de log e envia ao servidor FTP
	    */
	    If Len( aLog[ 2 ][ 2 ] ) > 0
			u_GerEnvLg( aLog , .F. )    
	    EndIf  
	    
	    ( cAliasQ )->( DbCloseArea() )
	
	EndIf     

EndIf

//RRP - 09/08/2018 - Inclusão da empresa Exeltis
If cEmpAnt $ "LG"
	//Limpa o campo de status da AGV
	If SC5->(FieldPOs("C5_P_ENV1")) <> 0
		TcSqlExec("UPDATE " + RetSqlName("SC5") + " SET C5_P_ENV1 = '' WHERE C5_FILIAL = '" + FWxFilial("SC5") + "' AND " +;
				  " C5_NOTA+C5_SERIE = '" +SF2->F2_DOC+SF2->F2_SERIE+ "' ")
	EndIf
EndIf

RestArea(aArea)
Return(lRet)