#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOTVS.CH"
/*
Funcao      : GTLOJ004
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de Integração de cupons.
Autor       : Jean Victor Rocha
Data/Hora   : 21/08/2016
*/
*----------------------*
User Function GTLOJ004()
*----------------------*                                             
Private cDirArq := Space(200)
Private cArqINI := "param.INI"
Private cSrvBanco	:= "\\SQLTB717\temp"
Private cDirBkp		:= "\FTP"
If !ExistDir(cDirBkp)
	MakeDir(cDirBkp)
EndIf
cDirBkp += "\"+cEmpAnt
If !ExistDir(cDirBkp)
	MakeDir(cDirBkp)
EndIf
cDirBkp += "\CUPOM"
If !ExistDir(cDirBkp)
	MakeDir(cDirBkp)
EndIf
cDirBkp += "\"+DTOS(Date())+"_"+STRTRAN(TIME(),":","")+"_"+cUserName
If !ExistDir(cDirBkp)
	MakeDir(cDirBkp)
EndIf

InWizardMan()

Return .T.                          
                                                
/*
Funcao      : InWizardMan()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard para integração
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function InWizardMan()
*---------------------------*
Local lWizMan := .F.

Private oWizMan
Private nOpc := GD_DELETE+GD_UPDATE//+GD_INSERT
Private aCoBrw1 := {}
Private aCoBrw2 := {}
Private aHoBrw2 := {}
Private noBrw2  := 0

Private oSelS	:= LoadBitmap( nil, "LBOK")
Private oSelN	:= LoadBitmap( nil, "LBNO")

oWizMan := APWizard():New("Integração de cupom fiscal", ""/*<chMsg>*/, FWEmpName(cEmpAnt)+" / "+FWFilialName(),;
									"Rotina de integração de arquivos de cupons fiscais."+CRLF,;
									 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )
          
//Painel 2
oWizMan:NewPanel( "Parametros", "Parametros para Integração.",{ ||.T.}/*<bBack>*/,;
					 {|| LoadDados(@oBrw2,@oWizMan)}/*<bNext>*/,;
					 {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

@ 010, 010 TO 125,280 OF oWizMan:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizMan:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay2 VAR "Diretorio ? " SIZE 100,10 OF oSBox1 PIXEL
ocDirArq:= TGet():New(20,85,{|u| If(PCount()>0,cDirArq:=u,cDirArq)},oSBox1,103,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'cDirArq')
@ 20,187.5 Button "..."	Size 7,10 Pixel of oSBox1 action (GetDir())


//--> PANEL 3
oWizMan:NewPanel( "Arquivos", "Apresentação dos arquivos que foram encontrados no diretorio informado."+CRLF+;
								"Caso não desejar a integração do arquivo, retirar a sua seleção.",;
								{ ||.F.}/*<bBack>*/,{|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, /*<bExecute>*/ )

//Aadd(aHoBrw1je,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"ALLWAYSTRUE()",SX3->X3_USADO, SX3->X3_TIPO,SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX } )
AADD(aHoBrw2,{ TRIM("Sel.")			,"SEL","@BMP",02,0,"","","C","",""})
AADD(aHoBrw2,{ TRIM("Arq.Dest.")	,"ARQ","@!  ",30,0,"","","C","",""})

noBrw2:= Len(aHoBrw2)
aAlter2 := {"SEL"}
                                                                                                 
oGrp2 := TGroup():New( 004,004,134,296,"Arquivos para integração",oWizMan:oMPanel[3],,,.T.,.F. )
oBrw2 := MsNewGetDados():New(012,008,130,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter2,0,9999,'AllwaysTrue()','','AllwaysTrue()',oGrp2,aHoBrw2,aCoBrw2 )
                
oBrw2:AddAction("SEL", {|| MudaStatus()})

//--> PANEL 4
oWizMan:NewPanel( "Processamento finalizado", "",;
								{ ||.F.}/*<bBack>*/,{|| }/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,{|| Main() } /*<bExecute>*/ )


@ 21,20 SAY oSayTxt1 VAR ""  SIZE 300,10 OF oWizMan:oMPanel[4] PIXEL
@ 31,20 SAY oSayTxt2 VAR ""  SIZE 300,10 OF oWizMan:oMPanel[4] PIXEL
@ 41,20 SAY oSayTxt3 VAR ""  SIZE 300,10 OF oWizMan:oMPanel[4] PIXEL
           
nMeter2 := 0
oMeter2 := TMeter():New(51,20,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},0,oWizMan:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter2:Set(0)

//oBtn1 := TButton():New( 81,200,"Visualizar Log",oWizMan:oMPanel[4],{|| ViewLog()},80,10,,,,.T.,,"",,,,.F. )

oWizMan:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )
                                          

Return .T.  

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*----------------------*
Static Function GetDir()
*----------------------*
Local cTitle:= "Selecione o diretorio"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := ALLTRIM(cDirArq)
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

cDirArq := ALLTRIM(cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.))

Return .T.

/*
Funcao     : LoadaCols
Parametros : Nenhum
Retorno    : 
Objetivos  : Carregar Informações
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-------------------------*
Static Function LoadDados()        
*-------------------------*
Local i
Local aArquivos := {}                  

If !ExistDir(cDirArq)
	MsgInfo("Diretorio informado não encontrado, favor verificar!")
	Return .F.
EndIf                
    
oBrw2:ACOLS := {}
aArquivos := directory(cDirArq+"*.*")

For i:=1 to len(aArquivos)
	aAdd(oBrw2:ACOLS,{oSelS,aArquivos[i][1]	,.F.})            
Next i

Return .T.

/*
Função  : vldFinaliza
Objetivo: Rotina de envio de arquivos para o servidor de banco de dados.
Autor   : Jean Victor Rocha
Data    : 
*/
*--------------------*
Static Function Main()
*--------------------*
Local lRet := .T.

oMeter2:NTOTAL := len(oBrw2:ACOLS)

For i:=1 to len(oBrw2:ACOLS)
	oMeter2:Set(i)
	oSayTxt1:CCAPTION := ALLTRIM(STR(i))+"/"+ALLTRIM(STR(Len(oBrw2:ACOLS)))+" Processando, aguarde... ["+ALLTRIM(oBrw2:ACOLS[i][2])+"]"
	If oBrw2:ACOLS[i][1] == oSelS
		If File(cDirArq+"\"+oBrw2:ACOLS[i][2])
			If !ExistDir(cSrvBanco+"\TXT")
				MakeDir(cSrvBanco+"\TXT")
			EndIf
			__CopyFile( cDirArq+"\"+oBrw2:ACOLS[i][2], cSrvBanco+"\TXT"+"\"+oBrw2:ACOLS[i][2] )
			
			//Copia de BKP para o Server PRotheus
			CpyT2S( cDirArq+"\"+oBrw2:ACOLS[i][2] , cDirBkp ,.T. )
			
		EndIf	
	EndIf
Next i

oMeter2:Set(i+1)
oMeter2:LVISIBLE 	:= .F.
oSayTxt1:CCAPTION 	:= "Arquivos exportados e iniciado o processamento!"

GrvINI()

IF TCSPExist("PROC_INTLOJAMAIN") 
	TCSQLExec( "EXEC PROC_INTLOJAMAIN")
	//TCSPExec("PROC_INTLOJAMAIN")
ENDIF 

Return lRet

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Jean Victor Rocha 
Data/Hora   : 
*/
*--------------------------*
Static Function MudaStatus()
*--------------------------*
Local cArqConte := oBrw2:aCols[oBrw2:Obrowse:nAt][oBrw2:Obrowse:ColPos]

If oSelS == cArqConte
	cArqConte := oSelN
Else 
	cArqConte := oSelS
Endif

Return(cArqConte)

/*
Funcao      : GrvINI
Parametros  : 
Retorno     : 
Objetivos   : Grava o arquivo INI
Autor       : Jean Victor Rocha
Data/Hora   : 
Obs         : 
*/                 
*----------------------*
Static Function GrvINI() 
*----------------------*
Local nHandle := 0
Local cTexto := ""
    
If File(cDirBkp+"\"+cArqINI)
	FErase(cDirBkp+"\"+cArqINI)
EndIf

//EMPRESA(2) //PARAMETRO(30) //CONTEUDO(250)                         
cTexto += UPPER(CEMPANT)+"SB1_GRAVA                     "+GETMV("MV_P_00084",,"SIM")+CHR(13)+CHR(10)
cTexto += UPPER(CEMPANT)+"SB1_FILIAL                    "+xFILIAL("SB1")+CHR(13)+CHR(10)
cTexto += UPPER(CEMPANT)+"SA1_FILIAL                    "+xFILIAL("SA1")+CHR(13)+CHR(10)
cTexto += UPPER(CEMPANT)+"SL_FILIAL                     "+xFILIAL("SL1")+CHR(13)+CHR(10)
cTexto += UPPER(CEMPANT)+"SITUA                         "+GETMV("MV_P_00085",,"PE")+CHR(13)+CHR(10)
                                          
nHandle := FCreate(cDirBkp+"\"+cArqINI, 0)
                
FSeek(nHandle,0,2)
FWRITE(nHandle, cTexto)
fclose(nHandle)
          
__CopyFile( cDirBkp+"\"+cArqINI, cSrvBanco+"\TXT"+"\"+cArqINI )

Return .T.