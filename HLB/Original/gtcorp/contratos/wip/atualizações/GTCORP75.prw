#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.ch"


/*
Funcao      : GTCORP75
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função Mbrowse da tabela Z55, Aprovação de Propostas
Autor       : Matheus Massarotto
Data/Hora   : 20/08/2012    10:14
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/

*-----------------------*
User Function GTCORP75()
*-----------------------*
Local cString	:= "Z55"
Local lFilter	:= .T.	//Define se deve ser filtrado a apresentação das propostas por usuário
Local cIdUser	:= __cUserID // Id do usuário logado
Local cFiltro	:= ""
Local aIndexZ55 := {}
Local lFilter 	:= .T.

Private aRotina	:= {}

if !cEmpAnt $ "99" .AND. !alltrim(UPPER(GetEnvServer())) $ "TESTE"

	if !TCCANOPEN("Z55"+cEmpAnt+"0")//Capa das propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z55")
		Return()
	endif
	if !TCCANOPEN("Z54"+cEmpAnt+"0")//Itens das propostas      Antiga Z78
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z54")
		Return()
	endif
	if !TCCANOPEN("Z53"+cEmpAnt+"0")//Itens das propostas      Antiga Z78
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z53")
		Return()
	endif
	if !TCCANOPEN("Z52"+cEmpAnt+"0")//Itens das propostas      Antiga Z78
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z52")
		Return()
	endif
	if !TCCANOPEN("Z50"+cEmpAnt+"0") //Posicionamento das propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z50")
		Return()
	endif
	if !TCCANOPEN("Z49"+cEmpAnt+"0") //Pagamentos propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z49")
		Return()
	endif
	if !TCCANOPEN("Z48"+cEmpAnt+"0") //Anexos Propostas
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z48")
		Return()
	endif
	if !TCCANOPEN("Z66"+cEmpAnt+"0") //Capa controle de alçada
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z66")
		Return()
	endif
	if !TCCANOPEN("Z65"+cEmpAnt+"0") //Itens controle de alçada
		Alert("Rotina não disponível para esta empresa!"+CRLF+"Não existe a tabela Z65")
		Return()
	endif
endif
  
AADD( aRotina, { "Pesquisar"		, "AxPesqui"  		, 0 , 1 } )
//AADD( aRotina, { "Visualizar"		, 'U_GTCORP74("Z55",RECNO(),2)' 	, 0 , 2 } )
//AADD( aRotina, { ""					, 'U_GTCORP74("Z55",RECNO(),3)' 	, 0 , 3 } )
//AADD( aRotina, { "Informar"			, 'U_GTCORP74("Z55",RECNO(),4)' 	, 0 , 4 } )

AADD( aRotina, { "Visualizar"		, 'U_GTCORP72("Z55",RECNO(),2,,"2")', 0 , 2 } ) 
AADD( aRotina, { ""					, 'U_GTCORP72("Z55",RECNO(),3)' 	, 0 , 3 } ) 
AADD( aRotina, { "Informar"			, 'U_GTCORP72("Z55",RECNO(),9)' 	, 0 , 4 } )

Private aCores		:= {}


		   		cStatus:= ""
		   		
				cQrySta:=" SELECT Z44_CODLEG AS LEGENDA FROM "+RETSQLNAME("Z44")+" Z44							
				cQrySta+=" JOIN "+RETSQLNAME("Z47")+" Z47 ON Z44.Z44_CODACA=Z47.Z47_CODIGO
				cQrySta+=" WHERE Z44.D_E_L_E_T_='' AND Z47.D_E_L_E_T_='' AND Z47.Z47_NOPC='9'
								    				    
				if select("QRYTEMP")>0
					QRYTEMP->(DbCloseArea())
				endif

				DbUseArea( .T., "TOPCONN", TcGenqry( , , cQrySta), "QRYTEMP", .F., .F. )
				
				Count to nRecCount
			        
				if nRecCount >0
				
					QRYTEMP->(DbGotop())
					While QRYTEMP->(!EOF())
	                    
	                    cStatus+=QRYTEMP->LEGENDA+"/"
	                    QRYTEMP->(DbSkip())
                    Enddo
                    
			    endif
			
			
				cFiltro:="Z55->Z55_STATUS $ '"+cStatus+"'"

//Definição de filtro                                                       
If lFilter

	bCondicao := {|| &cFiltro}
	cCondicao := cFiltro
	DbSelectArea(cString)

	DbSetFilter(bCondicao,cCondicao)
Else
	DbSelectArea(cString)
Endif

DbSetOrder(1)

MBrowse( 6,1,22,75,cString)

//Retira a função de filtro da tecla F12.
Set Key VK_F12  to

//Deleta o filtro da MBrowse.
EndFilBrw("Z55",aIndexZ55)

DbSelectArea("Z55")
 
Return