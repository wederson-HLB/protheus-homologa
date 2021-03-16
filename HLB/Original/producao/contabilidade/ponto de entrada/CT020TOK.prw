#Include 'Protheus.Ch'


/*
Função		: CT020TOK
Parametros  : Nenhum
Retorno     : lRet
Objetivo	: Ponto de Entrada na validacao da getdados - cadastro plano de contas    
Autor		: Leandro Diniz de Brito ( BRL Consulting )
Data		: 31/08/2015 
Obs         :
TDN         : O ponto de entrada CT020TOK é executado na validação do plano de contas.
Revisão     : Renato Rezende
Data/Hora   : 02/09/2015
Módulo      : Contabil. 
Cliente     : Todos
*/
*----------------------------*
User Function CT020TOK        
*----------------------------* 
Local lRet			:= .T. 
Local nPosEntRef	:= aScan( aHeader , { |x| AllTrim( x[2] ) == "CVD_ENTREF" } ) 
Local nPosDel       := Len( aHeader ) + 1 
	   
Local nPosPlano 	:= aScan( aHeader , { |x| AllTrim( x[2] ) == "CVD_CODPLA" } )
Local nPosCtRef		:= aScan( aHeader , { |x| AllTrim( x[2] ) == "CVD_CTAREF" } )

If INCLUI .Or. ALTERA
	If ( Ascan( aCols , { | x | !x[ nPosDel ] } ) == 0 ) .Or. ;
		( Ascan( aCols , { | x | !x[ nPosDel ] .And. Empty( x[ nPosEntRef ] ) .Or. Empty( x[ nPosPlano ] ) .Or. Empty( x[ nPosCtRef ] ) } ) > 0 )
		lRet := .F. 
		ApMsgStop( 'Obrigatorio informar entidade, plano e conta referencial .' )
	EndIf	
EndIf

Return( lRet )

