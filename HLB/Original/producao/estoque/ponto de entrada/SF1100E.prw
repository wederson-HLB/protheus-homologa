#Include 'Protheus.Ch'

/*
Função..............: SF1100E
Objetivo............: Ponto de Entrada ao final da Exclusao do Documento de Entrada
Autor...............: Leandro Diniz de Brito
Data................: 19/09/2016
*/                              

*----------------------------------* 
User Function SF1100E 
*----------------------------------*
Local i 
Local cArquivo 

Local aLog    	:= {}  
Local aHeaderLog  

Local cPedCom        

If FindFunction( 'u_EmpVogel' ) .And. cEmpAnt $ u_EmpVogel() 

	If !Empty( SF1->F1_P_SISTE )
		aHeaderLog := { 'EMP','FILIAL','STATUS','C7_NUM','C7_P_REF','A2_CGC','D1_SERIE','D1_DOC','D1_EMISSAO','D1_COD','D1_TOTAL','D1_CF' }
	
		cArquivo := 'ENTRADAS_CANC_' + SM0->M0_CGC + '_' + DtoS( dDataBase ) + StrTran( Time() , ':' , '' ) + '.CSV' 
		Aadd( aLog , { , aHeaderLog } )	                
		Aadd( aLog , { cArquivo , {} }  )	
		
		SA2->( DbSetOrder( 1 ) )
		SA2->( DbSeek( xFilial( 'SA2' ) + SF1->F1_FORNECE +  SF1->F1_LOJA ) )
		SC7->( DbSetOrder( 1 ) )
		For i := 1 To Len( aCols )
			cPedCom := PadR( GdFieldGet( 'D1_PEDIDO' , i )	, Len( SC7->C7_NUM ) )
			cPedRef := ''
			If SC7->( DbSeek( xFilial( 'SC7' ) + cPedCom ) )
				cPedRef := SC7->C7_P_REF
			EndIf
			
		    aAux := { SM0->M0_CGC ,;
						cFilAnt ,;
						'C',;
						cPedCom ,;
						cPedRef,;
						SA2->A2_CGC,;
						SF1->F1_SERIE,;
						SF1->F1_DOC,;
						DtoC( SF1->F1_EMISSAO ) ,;
						GdFieldGet( 'D1_COD' , i ),;
						Transf( GdFieldGet( 'D1_TOTAL' , i ) , "@R 99999999999.99" ) ,;
						GdFieldGet( 'D1_CF' , i ) }
							
			Aadd( aLog[ 2 ][ 2 ] , aAux )
						
		
		Next
		
	    /*
	    	* Gera arquivo de log e envia ao servidor FTP
	    */
	    If Len( aLog[ 2 ][ 2 ] ) > 0
			u_GerEnvLg( aLog , .F. )    
	    EndIf  		                      

	EndIf

EndIf	
	
Return