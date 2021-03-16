#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

#DEFINE MAXLIN 790

/*
Função..................: S2FAT002
Objetivo................: Tela para seleção dos documentos a serem enviados por email( Fatura e Boleto )
Autor...................: Weden Ferreira Alves
Data....................: 24/09/2018
Cliente HLB.............: Cognizant
*/

*----------------------------------*
User Function S2FAT002
*----------------------------------*                                               
Local cTitulo		:= SM0->M0_NOME+'- Envio de NFS-e \Boleto'
Local cDescription	:= 'Esta rotina permite imprimir as NFS-e e boletos para as notas fiscais selecionadas, dentro do periodo informado .'

Local oProcess
Local bProcesso

Private cPerg 	 	:= 'S2FAT002'
Private cTpSel    


If ( cEmpAnt <> 'S2' )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf

AjusSx1()

bProcesso	:= { |oSelf| SelNf( oSelf ) }
oProcess 	:= tNewProcess():New( "S2FAT001" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)


Return

/*
Função..........: SelfNf
Objetivo........: Selecionar notas fiscais para impressão
*/
*-------------------------------------------------*
Static Function SelNf( oProcess )
*-------------------------------------------------*
Local cExpAdvPL
Local oColumn
Local cArqTrb		:= ""

Private aColumn		:= {}
Private aStruSel	:= {} 
Private aBroPar		:= {}
Private oMarkB      := nil
Private cMailTo 	:= ''   

//Gravando os parametros para manter o filtro no atualização do Browser      
aAdd(aBroPar,{DtoS(MV_PAR01)})
aAdd(aBroPar,{DtoS(MV_PAR02)}) 
aAdd(aBroPar,{MV_PAR03}) 
aAdd(aBroPar,{MV_PAR04}) 
aAdd(aBroPar,{MV_PAR05}) 
aAdd(aBroPar,{MV_PAR06}) 
aAdd(aBroPar,{MV_PAR07})
aAdd(aBroPar,{MV_PAR08}) 

//Verifica se existe a tabela
If Select ("TMPSEL")>0
	TMPSEL->(DbCloseArea())
EndIf

aAdd(aStruSel,{"F2_OK"				,"C"						,2							,0})
aAdd(aStruSel,{"F2_P_EMAIL"			,AvSx3("F2_P_EMAIL"		,2)	,AvSx3("F2_P_EMAIL"		,3)	,AvSx3("F2_P_EMAIL"		,4),})
aAdd(aStruSel,{"F2_DOC"				,AvSx3("F2_DOC"			,2)	,AvSx3("F2_DOC"			,3)	,AvSx3("F2_DOC"			,4),})
aAdd(aStruSel,{"F2_SERIE"			,AvSx3("F2_SERIE"		,2)	,AvSx3("F2_SERIE"		,3)	,AvSx3("F2_SERIE"		,4),})
aAdd(aStruSel,{"F2_CLIENTE"			,AvSx3("F2_CLIENTE"		,2)	,AvSx3("F2_CLIENTE"		,3)	,AvSx3("F2_CLIENTE"		,4),}) 
aAdd(aStruSel,{"A1_P_BOLTE"			,AvSx3("A1_P_BOLTE"		,2)	,AvSx3("A1_P_BOLTE"		,3)	,AvSx3("A1_P_BOLTE"		,4),})
aAdd(aStruSel,{"F2_LOJA"			,AvSx3("F2_LOJA"		,2)	,AvSx3("F2_LOJA"		,3)	,AvSx3("F2_LOJA"		,4),})
aAdd(aStruSel,{"F2_EMISSAO"			,AvSx3("F2_EMISSAO"		,2)	,AvSx3("F2_EMISSAO"		,3)	,AvSx3("F2_EMISSAO"		,4),}) 
aAdd(aStruSel,{"F2_VALBRUT"			,AvSx3("F2_VALBRUT"		,2)	,AvSx3("F2_VALBRUT"		,3)	,AvSx3("F2_VALBRUT"		,4),})
aAdd(aStruSel,{"F2_VALICM"			,AvSx3("F2_VALICM"		,2)	,AvSx3("F2_VALICM"		,3)	,AvSx3("F2_VALICM"		,4),})
aAdd(aStruSel,{"F2_VALISS"			,AvSx3("F2_VALISS"		,2)	,AvSx3("F2_VALISS"		,3)	,AvSx3("F2_VALISS"		,4),})
aAdd(aStruSel,{"F2_VALPIS"			,AvSx3("F2_VALPIS"		,2)	,AvSx3("F2_VALPIS"		,3)	,AvSx3("F2_VALPIS"		,4),})
aAdd(aStruSel,{"F2_VALCOFI"			,AvSx3("F2_VALCOFI"		,2)	,AvSx3("F2_VALCOFI"		,3)	,AvSx3("F2_VALCOFI"		,4),})
aAdd(aStruSel,{"F2_VALCSLL"			,AvSx3("F2_VALCSLL"		,2)	,AvSx3("F2_VALCSLL"		,3)	,AvSx3("F2_VALCSLL"		,4),})
aAdd(aStruSel,{"F2_VALIRRF"			,AvSx3("F2_VALIRRF"		,2)	,AvSx3("F2_VALIRRF"		,3)	,AvSx3("F2_VALIRRF"		,4),})
aAdd(aStruSel,{"F2_FILIAL"			,AvSx3("F2_FILIAL"		,2)	,AvSx3("F2_FILIAL"		,3)	,AvSx3("F2_FILIAL"		,4),})

//Colunas do Browse
aAdd(aColumn,{"Filial" 		,{||TMPSEL->F2_FILIAL}		,TAMSX3("F2_FILIAL")[3]		,PesqPict("SF2","F2_FILIAL")	,1,TAMSX3("F2_FILIAL")[1]		,TAMSX3("F2_FILIAL")[2]})
aAdd(aColumn,{"Documento"	,{||TMPSEL->F2_DOC}			,TAMSX3("F2_DOC")[3]		,PesqPict("SF2","F2_DOC")		,1,TAMSX3("F2_DOC")[1]			,TAMSX3("F2_DOC")[2]})
aAdd(aColumn,{"Serie"		,{||TMPSEL->F2_SERIE}		,TAMSX3("F2_SERIE")[3]		,PesqPict("SF2","F2_SERIE")		,1,TAMSX3("F2_SERIE")[1]		,TAMSX3("F2_SERIE")[2]})
aAdd(aColumn,{"Cliente"		,{||TMPSEL->F2_CLIENTE}		,TAMSX3("F2_CLIENTE")[3]	,PesqPict("SF2","F2_CLIENTE")	,1,TAMSX3("F2_CLIENTE")[1]		,TAMSX3("F2_CLIENTE")[2]})
aAdd(aColumn,{"Loja"		,{||TMPSEL->F2_LOJA}		,TAMSX3("F2_LOJA")[3]		,PesqPict("SF2","F2_LOJA")		,1,TAMSX3("F2_LOJA")[1]			,TAMSX3("F2_LOJA")[2]})
aAdd(aColumn,{"Pagamento"	,{|| IIF (TMPSEL->A1_P_BOLTE == '1', "Boleto", IIF (TMPSEL->A1_P_BOLTE == '2', "TED", "Nao Informado"))}		,TAMSX3("A1_P_BOLTE")[3]	,PesqPict("SA1","A1_P_BOLTE")	,1,TAMSX3("A1_P_BOLTE")[1]		,TAMSX3("A1_P_BOLTE")[2]})
aAdd(aColumn,{"Emissao"		,{||TMPSEL->F2_EMISSAO}		,TAMSX3("F2_EMISSAO")[3]	,PesqPict("SF2","F2_EMISSAO")	,1,TAMSX3("F2_EMISSAO")[1]		,TAMSX3("F2_EMISSAO")[2]})
aAdd(aColumn,{"Valor Bruto"	,{||TMPSEL->F2_VALBRUT}		,TAMSX3("F2_VALBRUT")[3]	,PesqPict("SF2","F2_VALBRUT")	,1,TAMSX3("F2_VALBRUT")[1]		,TAMSX3("F2_VALBRUT")[2]})
aAdd(aColumn,{"Valor ICMS"	,{||TMPSEL->F2_VALICM}		,TAMSX3("F2_VALICM")[3]		,PesqPict("SF2","F2_VALICM")	,1,TAMSX3("F2_VALICM")[1]		,TAMSX3("F2_VALICM")[2]})
aAdd(aColumn,{"Valor ISS"	,{||TMPSEL->F2_VALISS}		,TAMSX3("F2_VALISS")[3]		,PesqPict("SF2","F2_VALISS")	,1,TAMSX3("F2_VALISS")[1]		,TAMSX3("F2_VALISS")[2]})
aAdd(aColumn,{"Valor Pis"	,{||TMPSEL->F2_VALPIS}		,TAMSX3("F2_VALPIS")[3]		,PesqPict("SF2","F2_VALPIS")	,1,TAMSX3("F2_VALPIS")[1]		,TAMSX3("F2_VALPIS")[2]})
aAdd(aColumn,{"Valor Cofins",{||TMPSEL->F2_VALCOFI}		,TAMSX3("F2_VALCOFI")[3]	,PesqPict("SF2","F2_VALCOFI")	,1,TAMSX3("F2_VALCOFI")[1]		,TAMSX3("F2_VALCOFI")[2]})
aAdd(aColumn,{"Valor CSLL"	,{||TMPSEL->F2_VALCSLL}		,TAMSX3("F2_VALCSLL")[3]	,PesqPict("SF2","F2_VALCSLL")	,1,TAMSX3("F2_VALCSLL")[1]		,TAMSX3("F2_VALCSLL")[2]})
aAdd(aColumn,{"Valor IRRF"	,{||TMPSEL->F2_VALIRRF}		,TAMSX3("F2_VALIRRF")[3]	,PesqPict("SF2","F2_VALIRRF")	,1,TAMSX3("F2_VALIRRF")[1]		,TAMSX3("F2_VALIRRF")[2]})

//A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe
cArqTrb := CriaTrab(aStruSel, .T.)

//A função dbUseArea abre uma tabela de dados na área de trabalho
DbUseArea(.T.,,cArqTrb,"TMPSEL",.F.,.F.)

//Select e Filtro da tela
Processa( {|| FiltroSel(), CriaBrowser() }, "Aguarde...", "Carregando os dados...",.F.)

Return Nil 
  
*----------------------------*
Static Function CriaBrowser()
*----------------------------*
Local bValid        := { || .T. }  //** Code-block para definir alguma validacao na marcação, se houver necessidade          
Local cMsgErro		:= "Nenhum pedido foi selecionado!"  
Local lMarcar := .F.
Local bKeyF12		:= {||  FiltroSEL("F12"),oMarkB:SetInvert(.F.),oMarkB:Refresh(),oMarkB:GoTop(.T.) } //Programar a tecla F12    

If oMarkB <> nil 
	oMarkB:SetInvert(.F.)
	oMarkB:Refresh()
	oMarkB:GoTop(.T.)
	return
EndIf

TMPSEL->(DbGoTop())
If TMPSEL->(!BOF()) .AND. TMPSEL->(!EOF())
     
    oMarkB := FWMarkBrowse():New()
	oMarkB:SetOnlyFields( { "F2_COND" } )
	oMarkB:SetAlias( 'TMPSEL' )
	oMarkB:SetFieldMark( 'F2_OK' )
	oMarkB:SetValid( bValid )
    oMarkB:SetParam(bKeyF12) // Seta tecla F12	 
    
    //Seta Legenda		
	oMarkB:AddLegend("ALLTRIM(TMPSEL->F2_P_EMAIL) <> '1'", "BR_VERMELHO","Email não enviado.")
	oMarkB:AddLegend("ALLTRIM(TMPSEL->F2_P_EMAIL) == '1'", "BR_VERDE","Email enviado.")   
	
    //Adiciona coluna no Browse
	oMarkB:SetColumns(aColumn)
	
	//Adiciona botoes na janela
	oMarkB:AddButton("Processar"			, { || MsgRun( 'Gerando e transmitindo documentos.... favor aguarde' , '' , { || ;
		IIF(VldMark("TMPSEL"),Imprime(.F.),MsgInfo(cMsgErro, "HLB BRASIL")) } )},,,, .F., 2 )
	//oMarkB:AddButton("Preview"				, { || MsgRun( 'Gerando e transmitindo documentos.... favor aguarde' , '' , { || ;
	//	IIF(VldMark("TMPSEL"),Imprime(.T.),MsgInfo(cMsgErro, "HLB BRASIL")) } )},,,, .F., 2 )
	oMarkB:AddButton("Legenda"				, { || MostraLege()				   	},,,, .F., 2 )
	
	//Marcar Todos
	oMarkB:bAllMark := { || MarcaTds(oMarkB:Mark(),lMarcar := !lMarcar ), oMarkB:Refresh(.T.)  }
		
 	oMarkB:ForceQuitButton(.T.)
		
	oMarkB:Activate() 
	oMarkB:oBrowse:Setfocus()//Seta o foco na grade
	oMarkB:DeActivate()
	oMarkB:= Nil
Else
	MsgInfo("ATENÇÃO! Nenhum dado encontrado para geração do arquivo."," HLB BRASIL")
	Return Nil
EndIf

Return Nil

/*
Função..........: Imprime
Objetivo........: Imprimir Fatura
*/
*-------------------------------------------------*
Static Function Imprime( lPreview )               	
*-------------------------------------------------*                            
Local cAnexo 
Local aArea 
Local aAreaA1
Local aAreaM0

Private cLocal    	:= "" //RSB - 08/06/2017 - Impressão dos boletos na maquina do usuário.
Private nValImp		:= 0 

//RSB - 08/06/2017 - Impressão dos boletos na maquina do usuário.
If lPreview
	cLocal := ChooseDir()
Else
	cLocal := GetTempPath()
Endif		
	
TMPSEL->( DbGotop() )
While TMPSEL->( !Eof() )
	
	If ( TMPSEL->F2_OK == oMarkB:Mark() )
		
		aAreaM0 := SM0->(GetArea())
		dbSelectArea("SM0")
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt+TMPSEL->(F2_FILIAL))) 
		
		aArea := TMPSEL->(GetArea())
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(FwxFilial("SA1")+TMPSEL->(F2_CLIENTE+F2_LOJA)))
		
		cMailTo := ALLTRIM(SA1->A1_EMAIL)
		cAnexo 	:= "" 
		
		aAreaA1 := SA1->(GetArea())
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		SF2->(dbSeek(TMPSEL->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))

		If SA1->A1_P_BOLTE == '1'
			cAnexo := U_S2FIN002(.T. , lPreview ) //fonte do boleto - odair moraes
			Sleep( 1000 )
		EndIf  
		
		RestArea(aAreaA1)   
		
		cSubject := 'NFS-e '
		If SA1->A1_P_BOLTE == '1' 
			cSubject += '\Boleto"
		EndIf 
   		cSubject += Alltrim(SM0->M0_NOME)+'- Nota Fiscal de Serviço ' + Alltrim(SF2->F2_DOC) + '.'
   		
		cEmail := '<html><head><meta http-equiv="Content-Language" content="pt-br"><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cEmail += '</head><body>'
		cEmail += '<p align="center"><font face="verdana" size="2">
		cEmail += '<p align="left">Prezado Cliente,</p> ' 
		cEmail += '<br />'
		cEmail += '<p align="left">Segue nota fiscal'
		
		If SA1->A1_P_BOLTE == '1'
			cEmail += ' e boleto'
		EndIf
		cEmail += ', referente aos serviços prestados.</p>'
		cEmail += 'Link NFS-e: <a href="' +MontaLink()+ '">' +Alltrim(SF2->F2_DOC)+ '</a>'			
		cEmail += '<br />'
		cEmail += '<br />'
		cEmail += '<b>Atenciosamente,</b>' 
		cEmail += '<br />'
		cEmail += '<b>'+Alltrim(SM0->M0_NOME)+'</b>'
		cEmail += '</body></html>'    
		
		RestArea(aArea)		
	   	EnviaEma(cEmail,cSubject,cMailTo,,cAnexo) 
		 
		RecLock("SF2", .F.) 
		SF2->F2_P_EMAIL := '1'
		MsUnLock() 
        SF2->(DBCloseArea())
        
        RestArea(aAreaM0)
        
  EndIf      

TMPSEL->( DbSkip() )
EndDo

Processa( {|| FiltroSel(), CriaBrowser() }, "Aguarde...", "Atualizando os dados...",.F.)

Return

/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1                            
*-------------------------------------------------*
                                                                                           
u_PutSx1( cPerg ,'01' , 'Da Emissao' ,'Da Emissao'/*cPerSpa*/,'Da Emissao'/*cPerEng*/,'mv_ch1','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Inicial Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
u_PutSx1( cPerg ,'02' , 'Ate Emissao' ,'Ate Emissao'/*cPerSpa*/,'Ate Emissao'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Final Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
u_PutSx1( cPerg ,'03' , 'Opção Pagamento' ,'Opção Pagamento'/*cPerSpa*/,'Opção Pagamento'/*cPerEng*/,'mv_ch3','C' , 1, 0, 0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR03'/*cVar01*/,'1=Boleto'/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,'2=TED'/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,'3=Ambos'/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Informe a opçãode pagamento" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
u_PutSx1( cPerg ,'04' , 'Não Enviadas' ,'Não Enviadas'/*cPerSpa*/,'Não Enviadas'/*cPerEng*/,'mv_ch4','C' , 1 ,0 ,0/*nPresel*/,'C'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR04'/*cVar01*/,'1=Sim'/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,'2=Não'	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Considerar apenas NFS-e que não foram enviadas" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
u_PutSx1( cPerg ,'05' , 'Do Cliente' ,'Do Cliente'/*cPerSpa*/,'Do Cliente'/*cPerEng*/,'mv_ch5','C' , 6 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'CLI'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR05'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,''/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Cliente de inicio do filtro" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
u_PutSx1( cPerg ,'06' , 'Até Cliente' ,'Até Cliente'/*cPerSpa*/,'Até Cliente'/*cPerEng*/,'mv_ch6','C' , 6 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'CLI'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR06'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,'ZZZZZZ'/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Cliente final do filtro" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
u_PutSx1( cPerg ,'07' , 'Da Filial' ,'Da Filial'/*cPerSpa*/,'Da Filial'/*cPerEng*/,'mv_ch7','C' , 2 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'SM0_01'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR07'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,''/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Filial de inicio do filtro" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
u_PutSx1( cPerg ,'08' , 'Até Filial' ,'Até Filial'/*cPerSpa*/,'Até Filial'/*cPerEng*/,'mv_ch8','C' , 2 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,'SM0_01'/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR08'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,'ZZ'/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Filial final do filtro" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )

Return

/*
Funcao      : EnviaEma
Parametros  : cHtml,cSubject,cTo,cToOculto
Retorno     : Nil
Objetivos   : Conecta e envia e-mail
Autor       : Matheus Massarotto
Data/Hora   : 05/01/2015 10:20
*/

*--------------------------------------------------------------*
Static Function EnviaEma(cEmail,cSubject,cTo,cToOculto,cAnexos)
*--------------------------------------------------------------*
Local cFrom			:= ""
Local cAttachment	:= ""
Local cCC      		:= ""


IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	RETURN .F.
ENDIF


cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  	:= Alltrim(GetMv("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  	:= Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo 		:= AvLeGrupoEMail(cTo)
cCC			:= ""
cFrom		:= AllTrim(GetMv("MV_RELFROM"))
cAttachment := cAnexos

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	RETURN .F.
ELSE
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			MSGINFO("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			RETURN .F.
		EndIf
	EndIf
	IF !EMPTY(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		//SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
	ELSE
		SEND MAIL FROM cFrom TO cTo  ;
		SUBJECT cSubject BODY cEmail ATTACHMENT cAttachment RESULT lOK
		//SUBJECT cSubject BODY cBody1 ATTACHMENT cAttachment RESULT lOK
	ENDIF
	If !lOK
		ConOut("Falha no Envio do E-Mail: "+ALLTRIM(cTo))
		DISCONNECT SMTP SERVER
		RETURN .F.
	ENDIF
ENDIF

DISCONNECT SMTP SERVER   

Return( .t. )                                   

/*
Funcao.........: ChooseDir
Objetivo.......: Selecionar arquivo .Xls a ser importado
Autor..........: Richard Steinhauser Busso
*/
*---------------------------------------------*
Static Function ChooseDir
*---------------------------------------------*
Local cTitle        := "Selecione o diretorio"
Local cMask         := "Arquivos (*.txt) |*.txt"
Local nDefaultMask  := 1
Local cDefaultDir   := 'C:\'
Local nOptions      := nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_RETDIRECTORY )
Local cDir 			
Local aNomeArq	:= {}

cDir := cGetFile( cMask , cTitle , nDefaultMask , cDefaultDir , .F. , nOptions ,.T. , .T. )

Return( cDir ) 

*--------------------------*
Static Function MontaLink()
*--------------------------*
Local cLinkNFS := GetLink(AllTrim(SM0->M0_CODMUN))

If SM0->M0_CODMUN == "4125506" //São José dos Pinhais
	cLinkNFS := STRTran(cLinkNFS,"[#NUMERO_NF]",cValtoChar(val(SubStr(AllTrim(SF2->F2_NFELETR),5))))
Else
	cLinkNFS := STRTran(cLinkNFS,"[#NUMERO_NF]", AllTrim(SF2->F2_NFELETR))
EndIf 

cLinkNFS := STRTran(cLinkNFS,"[#IM]",AllTrim(SM0->M0_INSCM))
cLinkNFS := STRTran(cLinkNFS,"[#COD_VER]",If(SM0->M0_CODMUN == "3304557",StrTran(AllTrim(SF2->F2_CODNFE),"-",""),AllTrim(SF2->F2_CODNFE)))

Return cLinkNFS

*-----------------------------------*
Static Function GetLink(cMunicipio) 
*-----------------------------------*
Local cLink := ""

Do Case
	Case cMunicipio == "3550308"	//"SAO PAULO"
		cLink := "https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?nf=[#NUMERO_NF]&inscricao=[#IM]&verificacao=[#COD_VER]&returnurl=..%2fpublico%2fverificacao.aspx%3ftipo%3d0"
	Case cMunicipio == "3304557"	//"RIO DE JANEIRO"
		cLink := "https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?ccm=[#IM]&nf=[#NUMERO_NF]&cod=[#COD_VER]"
	Case cMunicipio == "4314902"	//"PORTO ALEGRE"
		cLink := "https://nfe.portoalegre.rs.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf"
	Case cMunicipio == "3106200"	//"BELO HORIZONTE"
		cLink := "https://bhissdigital.pbh.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf"
	Case cMunicipio == "3509502"	//"CAMPINAS"
		cLink := "http://nfse.campinas.sp.gov.br/NotaFiscal/verificarAutenticidade.php"
	Case cMunicipio == "4106902"	//"CURITIBA"
		cLink := "http://isscuritiba.curitiba.pr.gov.br/portalNfse/autenticidade.aspx"
	Case cMunicipio == "5208707"	//"GOIANIA"
		cLink := "http://www2.goiania.go.gov.br/sistemas/snfse/asp/snfse00210f0.asp"
	Case cMunicipio == "4125506"	//"São José dos Pinhais"
		//Homologação
   		//cLink := "https://nfe.sjp.pr.gov.br/servicos/validarnfsehomologacao/validar.php?CCM=[#IM]&verificador=[#COD_VER]&nrnfs=[#NUMERO_NF]" 
   		//Produção
		cLink := "https://nfe.sjp.pr.gov.br/servicos/validarnfse/validar.php?CCM=[#IM]&verificador=[#COD_VER]&nrnfs=[#NUMERO_NF]" 
End Case

Return cLink                                                                                             	

/*
Função  : FiltroSel()
Objetivo: Filtro e select do conteúdo da tela
Autor   : Renato Rezende
*/
*-----------------------------------*
 Static Function FiltroSel(cOpcao)
*-----------------------------------*
Default cOpcao := ""    


If cOpcao == "F12"
	//Chamando Pergunte
	If !Pergunte(cPerg,.T.)
		Return  
	EndIf
	aBroPar := {}
	aAdd(aBroPar,{DtoS(MV_PAR01)})
	aAdd(aBroPar,{DtoS(MV_PAR02)}) 
	aAdd(aBroPar,{MV_PAR03}) 
	aAdd(aBroPar,{MV_PAR04}) 
	aAdd(aBroPar,{MV_PAR05}) 
	aAdd(aBroPar,{MV_PAR06})
	aAdd(aBroPar,{MV_PAR07}) 
	aAdd(aBroPar,{MV_PAR08})  
EndIf
                                                                                       
//Verifico se ja existe esta Query
If Select("QRY1") > 0
	QRY1->(DbCloseArea())
EndIf 
                                                                       
//Verifico se já  existe esta tabela
If Select ("TMPSEL")>0
	TMPSEL->(DbCloseArea()) 
	
	//Cria tabela temporaria
	cNome	:=	CriaTrab(aStruSel, .T.)
	DbUseArea(.T.,,cNome,'TMPSEL',.F.,.F.)
EndIf

//Qyery para pegar os dados que seram apresentados
cQuery1 := "	SELECT A.F2_P_EMAIL, A.F2_DOC, A.F2_FILIAL, A.F2_SERIE, A.F2_CLIENTE, A.F2_LOJA, A.F2_EMISSAO," + CRLF
cQuery1 += " A.F2_VALBRUT, A.F2_VALICM, A.F2_VALISS, A.F2_VALPIS, A.F2_VALCOFI, A.F2_VALCSLL, A.F2_VALIRRF, B.A1_P_BOLTE" + CRLF
cQuery1 += " FROM "+RetSqlName("SF2")+" AS A" + CRLF
cQuery1 += " JOIN "+RetSqlName("SA1")+" AS B ON A1_COD = A.F2_CLIENTE" + CRLF
cQuery1 += " WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' AND (A.F2_EMISSAO BETWEEN '" +aBroPar[1][1]+ "' AND '" +aBroPar[2][1]+ "')"+ CRLF
If aBroPar[3][1] == 1 
	cQuery1 += " AND B.A1_P_BOLTE = '1'"
ElseIf aBroPar[3][1] == 2
	cQuery1 += " AND B.A1_P_BOLTE = '2'"
EndIf
If aBroPar[4][1] == 1
	cQuery1 += " AND A.F2_P_EMAIL <> '1'"
EndIf          
cQuery1 += " AND (A.F2_CLIENTE BETWEEN '"+aBroPar[5][1]+"' AND '"+aBroPar[6][1]+"')"
cQuery1 += " AND (A.F2_FILIAL BETWEEN '"+aBroPar[7][1]+"' AND '"+aBroPar[8][1]+"')"


dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery1),"QRY1",.F.,.T.)

//Coloco os dados da query na tabela temporaria
QRY1->(DbGoTop())
While QRY1->(!EOF())   

	RecLock("TMPSEL",.T.)
	
	TMPSEL->F2_FILIAL   := QRY1->F2_FILIAL 
	TMPSEL->F2_P_EMAIL	:= QRY1->F2_P_EMAIL
	TMPSEL->F2_DOC   	:= QRY1->F2_DOC
	TMPSEL->F2_SERIE	:= QRY1->F2_SERIE
	TMPSEL->F2_CLIENTE  := QRY1->F2_CLIENTE
	TMPSEL->A1_P_BOLTE  := QRY1->A1_P_BOLTE
	TMPSEL->F2_LOJA   	:= QRY1->F2_LOJA
	TMPSEL->F2_EMISSAO  := STOD(QRY1->F2_EMISSAO)
	TMPSEL->F2_VALBRUT  := QRY1->F2_VALBRUT 
	TMPSEL->F2_VALICM   := QRY1->F2_VALICM
	TMPSEL->F2_VALISS   := QRY1->F2_VALISS
	TMPSEL->F2_VALPIS   := QRY1->F2_VALPIS  
	TMPSEL->F2_VALCOFI  := QRY1->F2_VALCOFI
	TMPSEL->F2_VALCSLL  := QRY1->F2_VALCSLL
	TMPSEL->F2_VALIRRF  := QRY1->F2_VALIRRF
	
	TMPSEL->(MsUnlock())
	QRY1->(DbSkip())
EndDO

Return
/*
Funcao      : VldMark
Objetivos   : Valida se foi selecionado algum pedido no browser
Autor       : Renato Rezende
*/
*----------------------------------------*
 Static Function VldMark(cAlias)                  
*----------------------------------------* 
Local lRet := .F.

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	If(!Empty(Alltrim((cAlias)->F2_OK)))
		lRet:= .T.
		Exit
	EndIf
	(cAlias)->(DbSkip())
EndDo

Return lRet  
/*
Funcao      : MarcaTds
Objetivos   : Marcar todos os itens do Browser
*/ 
*----------------------------------------* 
Static Function MarcaTds(cMarca,lMarcar)  
*----------------------------------------* 
Local cAliasSF2 := 'TMPSEL'
Local aAreaSF2  := (cAliasSF2)->( GetArea() )
 
    dbSelectArea(cAliasSF2)
    (cAliasSF2)->( dbGoTop() )
    While !(cAliasSF2)->( Eof() )
        RecLock( (cAliasSF2), .F. )
        (cAliasSF2)->F2_OK := IIf( lMarcar, cMarca, '  ' )
        MsUnlock()
        (cAliasSF2)->( dbSkip() )
    EndDo
 
    RestArea( aAreaSF2 )
Return .T.   
/*
Funcao      : MostraLege
Objetivos   : Apresentar legenda de status.
*/ 
*----------------------------*
Static Function MostraLege()
*----------------------------*
Local oLegenda := FWLegend():New()

oLegenda:Add("","BR_VERDE"		,"Email enviado."  		)
oLegenda:Add("","BR_VERMELHO"	,"Email não enviado."	)
	
oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return nil

return
