#Include 'Protheus.Ch' 
#Include 'TopConn.Ch' 


/*
Função.............: N6FAT002
Objetivo...........: Transmitir Notas Fiscais de Saida a Sefaz ( Schedule )
Autor..............: Leandro Diniz de Brito  ( BRL Consulting )
Data...............: 22/01/2018
*/                             
*------------------------------------*
User Function N6FAT002( aParam )
*------------------------------------*
Local cFil 

Local cEmp
Local lJob	:= Type( 'oMainWnd' ) != 'O'  


If lJob 
	If ( Valtype( aParam ) != 'A' )
		cEmp := 'N6'
		cFil := '01'
	Else            
		cEmp := aParam[ 01 ]
		cFil := aParam[ 02 ]	
	EndIf
	
	RPCSetType(3)	
	RpcSetEnv( cEmp , cFil , "" , "" , 'FAT' )
EndIf                                         

If !lJob
	If !MsgYesNo( 'Confirma transmissao das Nfs a Sefaz?' )
		Return
	EndIf
EndIf         

If !lJob
	Processa( { || EnvNfSefaz( .F. ) } , 'Aguarde.. Transmitindo notas...' )
Else
	EnvNfSefaz( .T. )
EndIf

Return

/*
Função.............: EnvNfSefaz
Objetivo...........: Transmitir Notas Fiscais de Saida a Sefaz ( Schedule )
Autor..............: Leandro Diniz de Brito  ( BRL Consulting )
Data...............: 22/01/2018
*/                   
*----------------------------------------------*
Static Function EnvNfSefaz(  lJob )                      
*----------------------------------------------*
Local cSql                                              
Local nCount := 0                                                           

Local cAlias := GetNextAlias()
Local cUrl := Padr( GetNewPar("MV_SPEDURL",""), 250 )

Local cIdEnt 		:= RetIdEnti( .F. )         
Local aRetorno

//cSql := "SELECT F3_SERIE,F3_NFISCAL,COUNT( * ) OVER ( PARTITION BY 1 ) TOTREG FROM " + RetSqlName( 'SF3' ) + " WHERE D_E_L_E_T_ = '' AND F3_FILIAL = '" + xFilial( 'SF3' ) + "' AND "
//cSql += "(F3_CODRSEF > '102' OR F3_CODRSEF = '') AND LEFT( F3_CFO,1 ) >= '5' AND F3_ESPECIE IN ('SPED','NFE','NF') AND F3_DTLANC = ''  AND D_E_L_E_T_ = ''" 

cSql := "SELECT SF3.F3_SERIE,SF3.F3_NFISCAL,COUNT( SF3.F3_SERIE) OVER ( PARTITION BY 1 ) TOTREG, SC5.C5_P_DTRAX FROM " + RetSqlName( 'SF3' ) + " SF3 "
cSql += " INNER JOIN "+RetSqlName('SC5')+" SC5 ON SC5.C5_FILIAL=SF3.F3_FILIAL AND SC5.C5_NOTA=SF3.F3_NFISCAL AND SC5.C5_SERIE=SF3.F3_SERIE AND SC5.C5_CLIENTE=SF3.F3_CLIEFOR AND SC5.C5_LOJACLI=SF3.F3_LOJA AND SC5.D_E_L_E_T_='' "
cSql += " WHERE SF3.F3_FILIAL = '" + xFilial( 'SF3' ) + "' AND (SF3.F3_CODRSEF > '102' OR SF3.F3_CODRSEF = '') "
cSql += "	AND LEFT( SF3.F3_CFO,1 ) >= '5' AND SF3.F3_ESPECIE IN ('SPED','NFE','NF') AND "
cSql += "	SF3.F3_DTLANC = ''  AND SF3.D_E_L_E_T_ = '' "
cSql += "	AND SC5.C5_P_STFED<>'91' "//Status provisorio, para realizar algum tipo de ajuste e não transmitir automatico.
cSql += " GROUP BY SF3.F3_SERIE,SF3.F3_NFISCAL,SC5.C5_P_DTRAX"

TCQuery cSql ALIAS ( cAlias ) NEW                                

If ( cAlias )->( !Eof() )

	If !lJob 
		ProcRegua( ( cAlias )->TOTREG )
	EndIf
	
	ConOut( '(N6FAT002) Data ' + DtoC( dDataBase ) + ' - Hora : ' + Time() +  ' - Inicio transmissao ' )
	While ( cAlias )->( !Eof() )
		If !lJob 
			IncProc( 'Transmitindo Nf ' + ( cAlias )->F3_NFISCAL + '\' + ( cAlias )->F3_SERIE )	
		Else
			ConOut( 'Transmitindo Nf ' + ( cAlias )->F3_NFISCAL + '\' + ( cAlias )->F3_SERIE )		
		EndIf     
		
		aRetorno := getListBox( cIdEnt , cUrl, { ( cAlias )->F3_SERIE , ( cAlias )->F3_NFISCAL , ( cAlias )->F3_NFISCAL } , 1 , '55' , .F. , .T., .F. , .F. , .F.)
		
		If ( Valtype( aRetorno ) == Nil )  .Or. ( Len( aRetorno ) == 0 ) .Or. ( Len( aRetorno ) > 0 .And. Empty( aRetorno[ 1 ][ 5 ] ) ) //** Se ainda nao obteve aceite, faz tentativa de transmissao
			u_EnvNfSef( ( cAlias )->F3_NFISCAL , ( cAlias )->F3_NFISCAL , ( cAlias )->F3_SERIE, ( cAlias )->C5_P_DTRAX )        

			u_N6GEN002( "SF3"/*TABELA*/,"E"/*E=ENVIO/R=RETORNO*/,"N6FAT002"/*TIPO DE SERVIÇO*/,	""/*DE*/,""/*PARA*/,( cAlias )->F3_NFISCAL+( cAlias )->F3_SERIE/*CHAVE DE PESQUISA*/,;
						""/*CONTEUDO EM JSON RECEBIDO OU ENVIADO*/,'Nota Fiscal Transmitida.' /*CAMPO OBS*/)						
			nCount += 1
		EndIf

		( cAlias )->( DbSkip() )
	EndDo
	
	If !lJob
		MsgStop( 'Total de notas transmitidas : ' + AllTrim( Str( nCount ) ) )
	Else
		ConOut( 'Total de notas transmitidas : ' + AllTrim( Str( nCount ) ) )
	EndIf

	ConOut( '(N6FAT002) FIM ' )	

EndIf

( cAlias )->( DbCloseArea() )

Return                                                                                 

*----------------------------------------------*
static function getListBox(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, lMsg, lMDfe, lTMS,lUsaColab)
*----------------------------------------------*
	
local aLote			:= {}
local aListBox			:= {}
local aRetorno			:= {}
local cId				:= ""
local cProtocolo		:= ""
local cRetCodNfe		:= ""
local cAviso			:= ""
local cSerie			:= ""
local cNota			:= ""

local nAmbiente		:= ""
local nModalidade		:= ""
local cRecomendacao	:= ""
local cTempoDeEspera	:= ""
local nTempomedioSef	:= ""
local nX				:= 0


local oOk				:= LoadBitMap(GetResources(), "ENABLE")
local oNo				:= LoadBitMap(GetResources(), "DISABLE")

default lUsaColab		:= .F.
default lMsg			:= .T.
default lCte			:= .F.
default lMDfe			:= .F.
default cModelo			:= IIf(lCte,"57",IIf(lMDfe,"58","55"))
default lTMS			:= .F.

	
//	if cModelo <> "65"
//		lUsaColab := UsaColaboracao( IIf(lCte,"2",IIf(lMDFe,"5","1")) )
//	endif
	
if 	lUsaColab
	//processa monitoramento por tempo
	aRetorno := colNfeMonProc( aParam, nTpMonitor, cModelo, lCte, @cAviso, lMDfe, lTMS ,lUsaColab )
else
	//processa monitoramento
	aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso)
endif	


if empty(cAviso)
	
	for nX := 1 to len(aRetorno)
			
		cId				:= aRetorno[nX][1]
		cSerie			:= aRetorno[nX][2]
		cNota			:= aRetorno[nX][3]
		cProtocolo		:= aRetorno[nX][4]	
		cRetCodNfe		:= aRetorno[nX][5]
		nAmbiente		:= aRetorno[nX][7]
		nModalidade	    := aRetorno[nX][8]
		cRecomendacao	:= aRetorno[nX][9]
		cTempoDeEspera  := aRetorno[nX][10]
		nTempomedioSef  := aRetorno[nX][11]
		aLote			:= aRetorno[nX][12]
							
		aadd(aListBox,{	iif(empty(cProtocolo) .Or.  cRetCodNfe $ RetCodDene(),oNo,oOk),;
							cId,;
							if(nAmbiente == 1,"Produção","Homologação"),; //"Produção"###"Homologação"
							IIF(lUsaColab,iif(nModalidade==1,"Normal","Contingência"),IIf(nModalidade ==1 .Or. nModalidade == 4 .Or. nModalidade == 6,"Normal","Contingência")),; //"Normal"###"Contingência"								
							cProtocolo,;
							cRecomendacao,;
							cTempoDeEspera,;
							nTempoMedioSef,;	
							aLote;
						})
	next	
    
endif
    
return aListBox
