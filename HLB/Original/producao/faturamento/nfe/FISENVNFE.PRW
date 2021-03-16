//--------------------------------------------------------------------------------------------------------------------------------------------//
// Sandro Ez4 - 2020/2021
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Específico                                                                                                                        //
// Faturamento                                                                                                                                //
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Envio de Boleto,Danfe e xml por e-mail
//--------------------------------------------------------------------------------------------------------------------------------------------//

#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'tbiconn.ch'
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

User Function FISENVNFE() 


Do Case

   Case cEmpAnt == "R7"  //Shiseido
      //Sandro Ez4   22/02/2021 - Projeto envio de boleto e danfe por E-mail
      U_R7FAT003() 
 
   Case cEmpAnt == "LN"  //NEOGEN
      //Sandro Ez4   22/01/2021 - Projeto envio de boleto e danfe por E-mail
      U_LNFAT002()  
      
EndCase  
 
Return()


User Function GerDanfe(cNota, cSerie, cPasta)

    Local aArea     := GetArea()
    Local cIdent    := ""
    Local oDanfe    := Nil
    Local lEnd      := .F.
    Local nTamNota  := TamSX3('F2_DOC')[1]
    Local nTamSerie := TamSX3('F2_SERIE')[1]

    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux
    Default cNota   := ""
    Default cSerie  := ""
         
    //Se existir nota
    If !Empty(cNota)
        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
        //Se o último caracter da pasta não for barra, será barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf
         
        //Gera o XML da Nota
        cArquivo := "NF"+cNota + "_" + dToS(Date()) + "_" + cHora
        //SpedXML(cNota, cSerie, cPasta + cArquivo  + ".xml", .F.)
        SpedXML(cNota, cSerie,, .F.,cPasta )
         
        //Define as perguntas da DANFE
        Pergunte("NFSIGW",.F.)
        MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
        MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
        MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
        MV_PAR04 := 2                          //NF de Saida
        MV_PAR05 := 2                          //Frente e Verso = Sim
        MV_PAR06 := 2                          //DANFE simplificado = Nao
      
        //Cria a Danfe
        oDanfe := FWMSPrinter():New(cArquivo, IMP_PDF, .F., , .T.)
         
        //Propriedades da DANFE
        oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)
         
        //Força a impressão em PDF
        oDanfe:nDevice  := 6
        oDanfe:cPathPDF := cPasta                
        oDanfe:lServer  := .F.
        oDanfe:lViewPDF := .F.
         
        //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
         
        //Chamando a impressão da danfe no RDMAKE
        //U_DanfeProc( @oDanfe, @lEnd, cIdent, , , .F.)
        StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, cIdent, , , .F.)
        oDanfe:Print()
    EndIf
     
    RestArea(aArea)
Return

//-----------------------------------
Static Function SpedXML(cDocumento, cSerie, cArqXML, lMostra,cPasta)

    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := StaticCall(SPEDNFE, GetIdEnt)
    Local cTextoXML    := ""
    Default cDocumento := ""
    Default cSerie     := ""    
    Default cArqXML    := cPasta+"XM"+cDocumento+ "_" + dToS(Date()) + "_" + cHora+".xml"
    Default lMostra    := .F.
     
    //Se tiver documento
    *
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
         
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"   
         
        //Se tiver notas
        If oWebServ:RetornaNotas()
         
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
             
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                     
                //Senão, pega o xml normal
                Else
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                EndIf
               
                //Gera o arquivo
                MemoWrite(cArqXML, cTextoXML)
                
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                 
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                 
                If lMostra
                    Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
         
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
             
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return


/*
Funcao      : Email
Parametros  : pasta em que sera gerado o arquivo
Retorno     : Nil
Objetivos   : Monta o texto do Email, conecta ao servidor de e-mail e envia 
Autor       : Sandro Silva
Data/Hora   : 10/10/2020
*/
*--------------------------*
User Function Email(cPasta)
*--------------------------*
Local nX 
Local cAssunto    := "Envio de Documento"       
Local aFiles	  := {}
Local aAnexos     := {}
Private aArquivos := {}

aDir(cPasta+"*.*",aFiles)

For nX := 1 To Len(aFiles)
  __CopyFile( cPasta + aFiles[nX], cPCopy + aFiles[nX],,,.F.)	//Copia os arqquivos para o servidor pasta protheus_data	
    aAdd(aAnexos  , cPCopy+aFiles[nX])
    aAdd(aArquivos, cPasta+aFiles[nX])    				
Next nX

cPara := SA1->A1_EMAIL 

cHTML := '<html>'
cHTML += '<body>'
cHTML += '<p align="center"><font face="verdana" size="2">
cHTML += '<b><u>Nota Fiscal Eletrônica Nacional</u></b></p>'				
cHTML += '<p align="left">Prezado(a) cliente,</p> '
cHTML += '<br />'
If cEmpAnt == "LN"  //NEOGEN 
    If SA1->A1_BLEMAIL == '1' //Cliente utiliza boleto
       cHTML += '<p align="left">Segue boleto,Danfe e XML anexado e abaixo o link para a nota fiscal eletrônica.</p> '
    Else
       cHTML += '<p align="left">Segue Danfe e XML anexado e abaixo o link para a nota fiscal eletrônica.</p> '
    EndIf 
Else
    cHTML += '<p align="left">Segue boleto,Danfe e XML anexado e abaixo o link para a nota fiscal eletrônica.</p> '
EndIf
cHTML += '<br />'
cHTML += '<p align="left"><b>Nota Fiscal Eletronica Nacional: </b>'+AllTrim(SF2->F2_DOC )+'-'+SF2->F2_SERIE+' </p> '
cHTML += '<p align="left"><b>Razão Social: </b> '+SA1->A1_NOME+' </p> '
cHTML += '<p align="left"><b>CNPJ : </b> '+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")+'</p> '
cHTML += '<br />'
cHTML += '<p align="left"><b>Chave de acesso : </b>'+SF2->F2_CHVNFE+'</p> '
cHTML += '<br />'
cHTML += '<p align="left">Para verificar a autorização da SEFAZ referente à nota acima mencionada, acesse o sitio http://www.nfe.fazenda.gov.br/portal 
cHTML += '<br />'
cHTML += '<p align="left">Este e-mail foi enviado automaticamente pelo Sistema de Nota Fiscal Eletrônica (NF-e) da :</b> '+'<b>'+SM0->M0_NOMECOM +'</B>'+'</p>' 
cHTML += '<br />'

U_EnvMail(cPara,cAssunto,cHTML,aAnexos)   //

Return


/*
{Protheus.doc} EnvMail                                                                                     
Função para disparo do e-mail utilizando TMailMessage e tMailManager com opção de múltiplos anexos             
Author Sandro Silva                                                                                               
Since 10/10/2020                                                                                                                                                                                              
Type function                                                                                                 
Param cPara, characters, Destinatário que irá receber o e-Mail                                                
Param cAssunto, characters, Assunto do e-Mail                                                                 
Param cMensagem, characters, Corpo do e-Mail (com suporte à html)                                                
Param aAnexos, array, Anexos que estarão no e-mail (devem estar na mesma pasta da protheus data)              
Param lMostraLog, logical, Define se será mostrado mensagem de log ao usuário (uma tela de aviso)             
Param lUsaTLS, logical, Define se irá utilizar o protocolo criptográfico TLS                                  
Return lRet, Retorna se houve falha ou não no disparo do e-Mail           
*/
User Function EnvMail(cPara,cAssunto,cMensagem,aAnexos,lMostraLog)          

Local nDelSrv
Local nDelLocal
Local xRet 
Local oServer, oMessage
Local cMsg      := ""	
Local lRet      := .T.       
Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)	  
Local cSrvFull  := Alltrim(GetMV("MV_RELSERV"))  
Local cFromEnv  := Alltrim(GetMV("MV_RELFROM")) 
Local cServer   := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)                  
Local nPorta    := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587) 
Local aArea     := GetArea()   		

Private cMailConta	:= NIL
Private cMailServer	:= NIL
Private cMailSenha	:= NIL

Default cMensagem   := ''   
Default lMostraLog  := .F.  

cMailConta :=If(cMailConta == NIL,GETMV("MV_RELACNT"),cMailConta)    //Conta utilizada para envio do email
cMailServer:=If(cMailServer == NIL,cServer,cMailServer)              //Servidor SMTP
cMailSenha :=If(cMailSenha == NIL,GETMV("MV_RELPSW"),cMailSenha)     //Senha da conta de e-mail utilizada para envio

oMessage:= TMailMessage():New()
oMessage:Clear()
   
oMessage:cDate	 := cValToChar( Date() )
oMessage:cFrom 	 := cFromEnv
oMessage:cTo 	 := cPara
oMessage:cSubject:= cAssunto
oMessage:cBody 	 := cMensagem
	
For nAtual := 1 To Len(aAnexos)                                                                                
	//Se o arquivo existir                                                                                         
	If File(aAnexos[nAtual])                                                                                                               
	   xRet := oMessage:AttachFile(aAnexos[nAtual])                                                                       
		 If xRet < 0                                                                                                    
		   cMsg += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF      
           lRet := .F.                               
		 EndIf                                                                                                               
	  //Senao, acrescenta no log                                                                                     
	Else                                                                                                           
		cMsg += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF         
        lRet := .F.                                       
	EndIf                                                                                                          
Next nAtual
  
oServer := tMailManager():New()
oServer:SetUseTLS( .T. ) //Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
   
xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor

If xRet != 0
	cMsg += "O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet )  + CRLF  
    lRet := .F.  
EndIf

If lRet

    xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
    If xRet != 0
        cMsg += "Nao foi possivel definir o TimeOut : "+cValToChar(nTimeOut)+"'" + CRLF  
    EndIf
    //Conecta no servidor 
    xRet := oServer:SMTPConnect()
    If xRet <> 0
        cMsg += "Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet )  + CRLF  
        lRet := .F.
    EndIf

    If lRet                                                                                                        		

        If lMailAuth	
            //Realiza a autenticação do usuário e senha  	
            xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
            If xRet <> 0
                cMsg += "Nao foi possivel autenticar no servidor SMTP:" + oServer:GetErrorString( xRet ) + CRLF  	
                oServer:SMTPDisconnect()
                lRet := .F.
            EndIf
        EndIf

        If lRet 
            //Envia a mensagem 
            xRet := oMessage:Send( oServer )
            If xRet <> 0
                cMsg += "Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet )  + CRLF  
                lRet := .F. 
            EndIf
        EndIf

    EndIf   

    xRet := oServer:SMTPDisconnect()
    If xRet <> 0
        cMsg += "Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet )  + CRLF  
    EndIf

EndIf

For nDelSrv := 1 To Len(aAnexos)   
    FErase(aAnexos[nDelSrv])    
Next nDelSrv    

For nDelLocal := 1 To Len(aArquivos)   
    FErase(aArquivos[nDelLocal])
Next nDelLocal    

If !Empty(cMsg)                                                                                                
	cMsg := "EMail - "+dToC(Date())+ " " + Time() + CRLF + ;                                                    
	"Funcao - " + FunName() + CRLF + CRLF +;                                                                       
	"Existem mensagens de aviso: "+ CRLF +;                                                                        
	cMsg                                                                                                           
	ConOut(cMsg)                                                                                                   
																												   
	//Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
	If lMostraLog .And. ! IsBlind()                                                                                
	   Aviso("Log", cMsg, {"Ok"}, 2)                                                                                  
	EndIf                                                                                                          
EndIf                                                                                                          
                                                                                                               
RestArea(aArea)                                                                                                

Return lRet 
