#Include "Protheus.Ch"
#Include "TopConn.Ch"



/*
Função.............: DPCTB102GR
Objetivo...........: Ponto de Entrada no final da contabilização
Autor..............: Leandro Diniz de Brito ( BRL Consulting )
Data...............: 11/04/2016
Observações........: 
Parametros.........: ParamIXB //  {nOpcx,dDataLanc,cLote,cSubLote,cDoc }
*/                  

*--------------------------------------*
User Function DPCTB102GR        
*--------------------------------------*
Local aArea 
Local aAreaCT2 
Local nOpc			:= ParamIxb[ 1 ]
Local cChave    	:= xFilial( 'CT2' ) + DtoS( ParamIxb[ 2 ] ) + ParamIxb[ 3 ] + ParamIxb[ 4 ] + ParamIxb[ 5 ]
Local cSequen		:= ""
Local lVazio   

Do Case
	Case ( cEmpAnt == '28' ) //** BBVA
		
		If ( nOpc == 3 .Or. nOpc == 4 .OR. nOpc == 7 ) //Adiciona a opção 7 - cópia de lançamento
			aArea := GetArea()
			aAreaCT2 := CT2->( GetArea() )
			
			
			/*
				* Varre lançamento para saber se existe alguma linha com o campo CT2_SEQUEN vazio .
			*/
			lVazio := .F.
			CT2->( DbSetOrder( 1 ) , DbSeek( cChave ) )
			While CT2->( !Eof() .And. CT2_FILIAL + DtoS( CT2_DATA ) + CT2_LOTE + CT2_SBLOTE + CT2_DOC == cChave )
			    
			    If !Empty( CT2->CT2_SEQUEN )
			    	cSequen := CT2->CT2_SEQUEN
			    EndIf 
			    
			    If Empty( CT2->CT2_SEQUEN )
			    	lVazio := .T.
			    EndIf
			    			    
		    	CT2->( DbSkip() )
			EndDo 
			
			/*
				* Se existir sequencia vazio, atualizo o lançamento com um nova sequencia ou existente em alguma linha do lançamento ( no caso de alteração )
			*/
			If lVazio

				If Empty( cSequen )
					cSequen := GetSxeNum( "_CT" )				 
					ConfirmSX8()
				EndIf  
				
				CT2->( DbSeek( cChave ) )
				While CT2->( !Eof() .And. CT2_FILIAL + DtoS( CT2_DATA ) + CT2_LOTE + CT2_SBLOTE + CT2_DOC == cChave )
				    
				    CT2->( RecLock( 'CT2' , .F. ) )
				    CT2->CT2_SEQUEN := cSequen
					CT2->( MSUnLock() )
				    			    
			    	CT2->( DbSkip() )
				EndDo 				
			
			EndIf
					
			RestArea( aAreaCT2 )		
			RestArea( aArea )
		EndIf
EndCase  

Return