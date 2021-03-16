#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"  
#Include "TopConn.Ch"  
#include 'fileio.ch'

/*
Função..................: N6FAT003
Objetivo................: Enviar Danfe Saida ao ftp DoTerra
Cliente HLB.............: N6( DoTerra )
Autor...................: BRL Consulting
Data....................: 29/01/2018
*/
*----------------------------*
User Function N6FAT003(aParam)
*----------------------------*
Local cFil          := "02"
Local cEmp			:= "N6"
Local cTitulo		:= 'Envio Danfe de Saida ao ftp DoTerra'
Local lJob			:= Type('oMainWnd') != 'O'
Local lExecNewJob	:= .T. 
Local nPos			:= 0

If !lJob 
	If !(cEmpAnt $ 'N6')
		SendMessage('Empresa nao autorizada.',lJob)
		Return
	EndIf

	//If MsgYesNo('Confirma envio dos arquivos ?','DoTerra - Envio de pdf ao servidor Ftp.')
		//Processa( { || EnviaXml( .F.,cFil ) } ,'Aguarde, enviando Xml\Danfe')
	//EndIf
	If MsgYesNo('Confirmar o envio dos arquivos ? (Será realizado em segundo plano)','DoTerra - Envio de pdf ao servidor Ftp.')
		aTeste := usrarray(GetEnvServer(),cEmpAnt,cFilAnt)
		If TYPE('aTeste') == "A"
			If (nPos := aScan(aTeste[1] ,{|X| UPPER(ALLTRIM(X[5])) == "U_N6FAT003" })) <> 0
				lExecNewJob := .F.
				MsgInfo("Já existe outro processo em segundo plano em execução."+Chr(13)+Chr(10)+"Iniciado por: "+ALLTRIM(aTeste[1][nPos][1])+Chr(13)+Chr(10)+"Em: "+ALLTRIM(aTeste[1][nPos][7]))		
			EndIf
		EndIf
		If lExecNewJob
			ConOut("N6FAT003 - Iniciado uma nova Thread de processamento, por: "+cUserName+" "+TIME())
			StartJob( "U_N6FAT003", GetEnvServer() , .F.)
		EndIf
	EndIf
Else
	ConOut("N6FAT003 - Nova execução de JOB iniciada. "+TIME())
	RPCSetType(3)	
	RpcSetEnv( cEmp , cFil , "" , "" , 'FAT' )
	EnviaXml( .T., cFil )
	ConOut("N6FAT003 - Execução de JOB Finalizada! "+TIME())
EndIf

Return

*---------------------------------*
Static Function EnviaXml(lJob,cFil)
*---------------------------------*
Local cSql		:= "" 	
Local cAlias	:= "SF2N6FAT3"

Local nRecCount	:= 0

Local aArea     := GetArea()
Local aAreaF2   := SF2->(GetArea())

Private cIdEnt	:= RetIdEnti( .F. )

DbSelectArea("SF2")
SF2->(DbSetOrder(1))
SF2->(DbGoTop())

//Verifico se ja existe esta Query
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
   
cSql := "SELECT R_E_C_N_O_ RECSF2, F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA, COUNT( * ) OVER ( PARTITION BY 1 ) TOTREG FROM " + RetSqlName( 'SF2' ) + " WHERE D_E_L_E_T_ = '' AND F2_FILIAL = '" + xFilial( 'SF2' ) + "' "
cSql += "AND F2_CHVNFE <> '' AND F2_TIPO = 'N' AND F2_P_ENVD <> '1' AND D_E_L_E_T_ = '' ORDER BY F2_DOC DESC" 

//cAlias := GetNextAlias()

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)
//TCQuery cSql ALIAS ( cAlias ) NEW

Count to nRecCount

(cAlias)->(DbGoTop())

If nRecCount > 0
//If ( cAlias )->( !Eof() )
	If !lJob 
		ProcRegua( ( cAlias )->TOTREG )
	EndIf

	While ( cAlias )->(!Eof() )   
		SF2->( DbGoTo( ( cAlias )->RECSF2 ) )

    	If !lJob
    		IncProc()
   	 	EndIf

    	If Envia(lJob,cFil,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SF2->F2_CHVNFE)
    		//SF2->( RecLock( 'SF2' , .F. ) , F2_P_ENVD := '1' , MSUnlock() )
    		TCSqlExec("UPDATE "+RetSqlName("SF2")+" SET F2_P_ENVD='1' WHERE R_E_C_N_O_ = "+Alltrim(cValtoChar((cAlias)->RECSF2))+" ")
    	Else
    		//SF2->( RecLock( 'SF2' , .F. ) , F2_P_ENVD := '3' , MSUnlock() )
    		TCSqlExec("UPDATE "+RetSqlName("SF2")+" SET F2_P_ENVD='3' WHERE R_E_C_N_O_ = "+Alltrim(cValtoChar((cAlias)->RECSF2))+" ")
    	EndIf	

		( cAlias )->( DbSkip() )
	EndDo     
EndIf 

SendMessage( 'Termino do processamento' , lJob )

//( cAlias )->( DbCloseArea() )
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

RestArea(aAreaF2)
RestArea(aArea)

Return

/*
Função............: Envia
Objetivo..........: Enviar Xml\Danfe ao servidor Ftp
Autor.............: Leandro Diniz de Brito
*/
*--------------------------------------------------------------------------*
Static Function Envia(lJob,cFil,cNota,cSerie,cCliente,cLoja,dEmissao,cChave)
*--------------------------------------------------------------------------*
Local cXml		:= "" 
Local cPdf		:= "" 
Local oDanfe	:= nil 
Local aArea		:= GetArea()
//Local cAlias     := GetNextAlias()    
Local cAlias	:= "SC5TMP"
Local aXml		:= {}           
Local cCSV		:= ""
Local cErro		:= ""                                       
Local cAviso	:= ""
Local cEmail	:= ""
Local cSql		:= ""
Local cModel	:= '55'
Local cDirXml	:= '\Ftp\N6\'
Local cArquivo	:= 'Nf_' + AllTrim( cNota ) + AllTrim( cSerie ) 
Local cDir		:= Alltrim(GETMV("MV_P_00119",,"\datatrax"))
Local cDirFisico:= alltrim(GetSrvProfString("ROOTPATH",""))+cDir
Local lRet		:= .F.
Local nRecSC5	:= 0

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

If !ExistDir( cDirXml )
	MakeDir( cDirXml )
EndIf
	
Begin Sequence                                                                  

If File( cDirXml + cArquivo + '.pdf' )
	FErase( cDirXml + cArquivo + '.pdf' )
EndIf 

If File( cDirXml + cArquivo + '.pd_' )
	FErase( cDirXml + cArquivo + '.pd_' )
EndIf 

If File( cDirXml + cArquivo + '.rel' )
	FErase( cDirXml + cArquivo + '.rel' )
EndIf

If File( cDirXml + cArquivo + '.xml' )
	FErase( cDirXml + cArquivo + '.xml' )	
EndIf

//Geração do arquivo .xml
cXml := u_N6GEN005(cSerie+cNota, dEmissao) 

If Empty(cXml)
	//Exibe mensagem na tela
	SendMessage( 'Nao foi possivel gerar pdf/xml ( Danfe ) para a nota fiscal ' + cNota + cSerie , lJob )
    
	//Insere informações na tabela de Log
	u_N6GEN002( "SF3","E","N6FAT003","","",cNota + cSerie,"",'Nao foi possivel gerar pdf ( Danfe ) para a nota fiscal ' + cNota + cSerie)						
	
	//Atualização de status (erro de impressao danfe)
	TCSqlExec("UPDATE  " + RetSqlName("SC5") + "  SET C5_P_STFED = '12' WHERE C5_NOTA = '"+cNota+"' AND C5_SERIE = '"+cSerie+"' AND C5_CLIENTE = '"+cCliente+"' AND C5_LOJACLI = '"+cLoja+"' AND C5_FILIAL = '"+cFil+"'") 	
	
	lRet := .F.  
	Break
Else
	// Geração Danfe em pdf 
	//oDanfe   := FWMSPrinter():New( cArquivo , IMP_PDF , .F. ,cDirXml, .T. )
	oDanfe   := FWMSPrinter():New( cArquivo , IMP_PDF , .F. ,, .T. )
	oDanfe:SetPortrait()
	oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
	oDanfe:SetPaperSize(DMPAPER_A4)
	oDanfe:SetMargin(60,60,60,60)
	oDanfe:cPathPDF := cDirXml
	oDanfe:SetViewPDF(.F.)     
	oDanfe:nDevice := IMP_PDF                                                         
	oDanfe:lServer := .T.
	oDanfe:lInJob := .T.

	MV_PAR01 := cNota
	MV_PAR02 := cNota
	MV_PAR03 := cSerie
	MV_PAR04 := 2	// [Operacao] NF de Saida
	MV_PAR05 := 1	// [Frente e Verso] Sim
	MV_PAR06 := 2	// [DANFE simplificado] Nao

	u_PrtNfeSef(cIdEnt, /*cVal1*/		, /*cVal2*/,	oDanfe,/*	oSetup*/, /*cFilePrint*/	, /*lIsLoja */, /*lView*/ , .T. /*lCallExt*/	)

	oDanfe:Print()             

	//Gera XML
	MemoWrit( cDirXml + cArquivo + '.xml' , cXML ) 

	//Grava informações na tabela de log
	u_N6GEN002( "SF3","E","N6FAT003","","",cNota + cSerie,'Pdf Gerado com sucesso . NF ' + cNota + cSerie,"")						

	//Atualização de status (impressao danfe ok)
	TCSqlExec("UPDATE "+RetSqlName("SC5")+" SET C5_P_STFED='11' WHERE C5_NOTA='"+cNota+"' AND C5_SERIE='"+cSerie+"' AND C5_CLIENTE='"+cCliente+"' AND C5_LOJACLI='"+cLoja+"' AND C5_FILIAL='"+cFil+"'") 

    //Envio de Email para cliente e transportadora
	cSql := "SELECT SC5.C5_NOTA,SA1.A1_EMAIL,SC5.C5_TRANSP,SC5.C5_P_DTRAX,SC5.C5_P_NSHIP,SC5.C5_NUM,CONVERT(VARCHAR, CONVERT(DATETIME, SC5.C5_EMISSAO, 103), 103) AS 'C5_EMISSAO' FROM " + RetSqlName( 'SC5' ) + " SC5 INNER JOIN " + RetSqlName( 'SA1' ) + " SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND "
	cSql += "SA1.D_E_L_E_T_ = '' WHERE SC5.C5_NOTA = '"+alltrim(cNota)+"' AND SC5.C5_SERIE = '"+alltrim(cSerie)+"' AND SC5.C5_CLIENTE = '"+cCliente+"' AND "
	cSql += "SC5.C5_LOJACLI = '"+cLoja+"' AND SC5.C5_FILIAL = '"+cFil+"' "
	
	//TCQuery cSql ALIAS ( cAlias ) NEW
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cSql),(cAlias),.F.,.T.)

	Count to nRecSC5

	(cAlias)->(DbGoTop())

	If nRecSC5 > 0
	//If ( cAlias )->( !Eof() )
		cEmail :="<p>Prezado Cliente</p>"
		cEmail +="<p>Segue em anexo o PDF da NF-e: <strong>"+alltrim(cNota)+"-"+alltrim(cSerie)+"</strong> referente ao seu pedido <strong>"+( cAlias )->C5_P_DTRAX+"</strong> realizado no dia <strong>"+( cAlias )->C5_EMISSAO+"</strong>. </p>"
		cEmail +="<p>Você poderá consultar a NF-e do seu pedido usando a chave abaixo no Portal da Nota Fiscal Eletronica em: <a href='http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&amp;tipoConteudo=XbSeqxE8pl8='>"
		cEmail +="http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&amp;tipoConteudo=XbSeqxE8pl8= </a></p>"
		cEmail +="<p>Chave: "+alltrim(cChave)+"</p>"
		cEmail +="<p>Atenciosamente.</p>"
		cEmail +="<p>doTerra Brasil</p>"

		u_N6GEN001(cEmail," - Faturamento de NFe: "+ cNota + cSerie,cDirXml + cArquivo + '.PDF',( cAlias )->A1_EMAIL) //email cliente
		u_N6GEN001(cEmail," - Faturamento de NFe: "+ cNota + cSerie,cDirXml + cArquivo + '.PDF',"centraldeprodutos@doterra.com") //email central de produtos

		cEmail :="<p>Prezada Transportadora</p>"
		cEmail +="<p>Segue em anexo o PDF da NF-e: <strong>"+alltrim(cNota)+"-"+alltrim(cSerie)+"</strong> referente ao pedido <strong>"+( cAlias )->C5_P_DTRAX+"</strong> realizado no dia <strong>"+( cAlias )->C5_EMISSAO+"</strong>. </p>"
		cEmail +="<p>Você poderá consultar a NF-e do seu pedido usando a chave abaixo no Portal da Nota Fiscal Eletronica em: <a href='http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&amp;tipoConteudo=XbSeqxE8pl8='>"
		cEmail +="http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&amp;tipoConteudo=XbSeqxE8pl8= </a></p>"
		cEmail +="<p>Chave: "+alltrim(cChave)+"</p>"
		cEmail +="<p>Atenciosamente.</p>"
		cEmail +="<p>doTerra Brasil</p>" 

		u_N6GEN001(cEmail," - Faturamento de NFe: "+ cNota + cSerie,cDirXml + cArquivo + '.XML',POSICIONE("SA4", 1, xFilial("SA4") + ( cAlias )->C5_TRANSP, "A4_EMAIL")) 
	EndIf

	//Gero o arquivo de retorno para o datatrax
    cCSV := "import_"+dtos(date())+substr(time(),1,2)+substr(time(),4,2)+".CSV" 
    N6GERINV(( cAlias )->C5_P_NSHIP,( cAlias )->C5_NUM,( cAlias )->C5_NOTA,cSerie,cCliente,cLoja,DTOS(dEmissao),cDir+"\import\"+cFil+"\"+cCSV)   

	( cAlias )->( DbCloseArea() )	

	//executo a batch para mover o arquivo processado para a pasta  /nf/archive no servidor de SFTP da doTerra (datatrax)
  	cFile := @cDirFisico+"\datatrax2.bat "+ space(3) + alltrim(".." + cDirXml + cArquivo + '.PDF') + "  2  " + cFil + space(3)+ alltrim(" .." + cDirXml + cArquivo + '.XML') + space(3) + " import\"+cFil+"\"+cCSV
	WaitRunSrv(@cfile,.T.,@cDirFisico)

	FERASE(cDir+"\import\"+cFil+"\"+cCSV)
	FErase( cDirXml + cArquivo + '.pdf' )
	FErase( cDirXml + cArquivo + '.pd_' )
    FErase( cDirXml + cArquivo + '.rel' )
	FErase( cDirXml + cArquivo + '.xml' )	
	
	lRet   := .T. 
	FreeObj( oDanfe )   
	oDanfe := nil 
	RestArea(aArea)

EndIf 
End Sequence																				   

Return( lRet )

/*
Função..........: SendMessage
Objetivo........: Enviar mensagem na tela ou console
*/
*----------------------------------------*
Static Function SendMessage(cMessage,lJob)
*----------------------------------------*
Default lJob := .F.

Return( If( lJob , ConOut( cMessage ) , MsgStop( cMessage ) ) )

/*
Função..........: N6GERINV
Objetivo........: Gerar arquivo CSV para datatrax
*/						  
*------------------------------------------------------------------------------------*
Static Function N6GERINV(cNship,cPedido,cNota,cSerie,cCliente,cLoja,cEmissao,cArquivo) 
*------------------------------------------------------------------------------------*
Local cCrLf		:= Chr(13) + Chr(10)
//Local cAlias	:= GetNextAlias()
Local cAlias	:= "SC6TMP"
Local cEmail	:= ""
Local cQuery	:= ""
Local nHandle	:= 0 

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery := "Select (case "
cQuery += "when C6_PRODUTO like '%I%'   then left(C6_PRODUTO, charindex('I', C6_PRODUTO) - 1)  "  
cQuery += "when C6_PRODUTO like '%I%'   then left(C6_PRODUTO, charindex('N', C6_PRODUTO) - 1)  " 
cQuery += "when C6_PRODUTO like '%IPA%' then left(C6_PRODUTO, charindex('IPA', C6_PRODUTO) - 3)  "
cQuery += "Else C6_PRODUTO end) as C6_PRODUTO, "
cQuery += "C6_QTDVEN from "+RetSqlName("SC6")+" "
cQuery += "where D_E_L_E_T_ = ' ' "
cQuery += "and   C6_NUM     = '"+cPedido+"' " 
cQuery += "and   C6_NOTA    = '"+cNota+"' " 
cQuery += "and   C6_CLI     = '"+cCliente+"' "
cQuery += "and   C6_LOJA    = '"+cLoja+"' "
cQuery += "and   C6_FILIAL  = '"+xFilial("SC6")+"'"  
cQuery += "and   D_E_L_E_T_ = ''" 

//TCQuery cQuery ALIAS ( cAlias ) NEW                
DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),(cAlias),.F.,.T.)

nHandle := FCreate(cArquivo,FC_NORMAL)

If nHandle == -1
	 cEmail :="<p>Não possível gerar o arquivo CSV de faturamento (NF-e: <strong>"+alltrim(cNota)+"-"+alltrim(cSerie)+"</strong> )para o Datatrax devido ao erro (Código:" + STR(FERROR())+"). </p>"
	 cEmail +="<p>Para maiores informações sobre o erro, visite o site http://tdn.totvs.com/display/tec/FError</p><br>"

     u_N6GEN001(cEmail," Falha na geração de arquivo CSV/Datatrax",,alltrim(GETMV("MV_P_00115"))) 
Else
     While ( cAlias )->(!Eof())
          fWrite(nHandle,cNship+","+cNota+cSerie+","+alltrim(( cAlias )->C6_PRODUTO)+","+alltrim(cvaltochar(( cAlias )->C6_QTDVEN))+","+cEmissao+","+"0,"+"0,"+cCrLf)
         ( cAlias )->(DbSkip())
     Enddo    
     ( cAlias )->(DbCloseArea())
    fWrite(nHandle, ""+cCrLf)
    fClose(nHandle)                                    
     
EndIf

Return
       
*--------------------------------------------*
Static Function usrarray(cAmb,cEmpAnt,cfilAtu)
*--------------------------------------------*
local oSrv     := nil
local aUsers   := {}
local nIdx     := 0
local aServers := {}
local aTmp     := {}

DEFAULT cAmb := "P11_01"

// neste caso, quero apenas o balance, que me retorna todos os slaves conectados.
aadd(aServers, {"10.0.30.4", 1024})
// voce pode também adicionar outros servers fora do balance, como servers de web ou workflows.
//aadd(aServers, {"127.0.0.1", 7001})

For nIdx := 1 to len(aServers)
     // conecta no slave via rpc
     oSrv := rpcconnect(aServers[nIdx,1], aServers[nIdx,2], cAmb, cEmpAnt,cfilAtu)
     if valtype(oSrv) == "O"
          oSrv:callproc("RPCSetType", 3)
          // chama a funcao remotamente no server, retornando a lista de usuarios conectados
          aTmp := oSrv:callproc("GetUserInfoArray")
          aadd(aUsers, aclone(aTmp))
          aTmp := nil
          // limpa o ambiente
          oSrv:callproc("RpcClearEnv")
          // fecha a conexao
          rpcdisconnect(oSrv)
     else
          return "Falha ao obter a lista de usuarios."
     endif
Next nIdx

Return aUsers