#Include "Protheus.ch"

/*
Funcao      : UTAF001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Update que cria as tabelas autocontidas e apenda de acordo com uma empresa modelo
Autor       : Matheus Massarotto
Data/Hora   : 03/09/2015 
Revisão		: 
Autor		: Matheus Massarotto
Data/Hora	: 03/09/2015
*/

*-----------------------*
User Function UTAF001
*-----------------------*
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                           
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd
Private NL := CHR(13) + CHR(10)

Begin Sequence
   Set Dele On
   
   lHistorico	:= MsgYesNo("Deseja efetuar a atualização das tabelas autocontidas","Atenção")
                            
   lEmpenho		:= .F.
   lAtuMnu		:= .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização de tabelas autocontidas"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},;
                                         "Processando",;
                                         "Aguarde , Processando Preparação dos Arquivos",;
                                         .F.) , Final("Atualização efetuada.")),;
                                         oMainWnd:End())
End Sequence

Return
*----------------------*
Static Function UPDProc
*----------------------*
Local aRecnoSM0 := {}
Local cTexto 	:= ""
Local lOpen  	:= .F.

Private cBancoOri	:="P11_09"
Private cEmpOri		:="1Z"
Private cVerAutoc	:="1005"+space(5)

Private lSobresc	:=.F.

Begin Sequence

   ProcRegua(1)

   IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )
	  lCheck := .F.    
	  aAux := {}
	  If !Tela()
	  	  Return .T.
	  EndIf
    
      dbSelectArea("SM0")
	  dbGotop()
	  While !Eof()
  	     
		 If lCheck
			If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		 Else
			If Ascan(aAux,{ |x| LEFT(x,2)  == M0_CODIGO}) <> 0 .and.;
				Ascan(aAux,{ |x| RIGHT(x,2) == M0_CODFIL}) <> 0 .and.;
				Ascan(aRecnoSM0,{ |x| x[2]  == M0_CODIGO}) == 0 
				
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			EndIf
		 EndIf
		 
		 dbSkip()
	  EndDo
	
	  RpcClearEnv()

	  If lOpen := MyOpenSm0Ex()
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)
				
			 ProcTAF(@cTexto)

			 RpcClearEnv()
			 If !( lOpen := MyOpenSm0Ex() )
				Exit 
			 EndIf 
		 Next nI 

		 If lOpen

			cTexto := "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

			Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
			Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

			@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
			Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			Activate MsDialog oDlg Center
		 EndIf
	  EndIf
   EndIf
End Sequence

Return

*-----------------------------*
Static Function ProcTAF(cTexto)
*-----------------------------*

Local aTabs:={;
'C02',;
'C03',;
'C04',;
'C05',;
'C06',;
'C07',;
'C08',;
'C09',;
'C0A',;
'C0B',;
'C0C',;
'C0D',;
'C0E',;
'C0F',;
'C0G',;
'C0H',;
'C0I',;
'C0J',;
'C0K',;
'C0L',;
'C0M',;
'C0N',;
'C0O',;
'C0Q',;
'C0R',;
'C0S',;
'C0T',;
'C0U',;
'C0V',;
'C0W',;
'C0X',;
'C0Y',;
'C0Z',;
'C10',;
'C11',;
'C12',;
'C13',;
'C14',;
'C15',;
'C16',;
'C17',;
'C18',;
'C19',;
'C1A',;
'C1B',;
'C1C',;
'C1D',;
'C1E',;
'C1F',;
'C1G',;
'C1H',;
'C1I',;
'C1J',;
'C1K',;
'C1L',;
'C1M',;
'C1N',;
'C1O',;
'C1P',;
'C1Q',;
'C1R',;
'C1S',;
'C1T',;
'C1U',;
'C1V',;
'C1W',;
'C1X',;
'C1Y',;
'C1Z',;
'C20',;
'C21',;
'C22',;
'C23',;
'C24',;
'C25',;
'C26',;
'C27',;
'C28',;
'C29',;
'C2A',;
'C2B',;
'C2C',;
'C2D',;
'C2E',;
'C2F',;
'C2G',;
'C2H',;
'C2I',;
'C2J',;
'C2K',;
'C2L',;
'C2M',;
'C2N',;
'C2O',;
'C2P',;
'C2Q',;
'C2R',;
'C2S',;
'C2T',;
'C2U',;
'C2V',;
'C2X',;
'C2Z',;
'C30',;
'C31',;
'C32',;
'C33',;
'C34',;
'C35',;
'C36',;
'C37',;
'C38',;
'C39',;
'C3A',;
'C3B',;
'C3C',;
'C3D',;
'C3E',;
'C3F',;
'C3G',;
'C3H',;
'C3I',;
'C3J',;
'C3K',;
'C3L',;
'C3M',;
'C3N',;
'C3O',;
'C3P',;
'C3Q',;
'C3R',;
'C3S',;
'C3T',;
'C3U',;
'C3V',;
'C3X',;
'C3Z',;
'C40',;
'C41',;
'C42',;
'C43',;
'C44',;
'C45',;
'C46',;
'C47',;
'C48',;
'C49',;
'C4A',;
'C4B',;
'C4C',;
'C4D',;
'C4E',;
'C4F',;
'C4G',;
'C4H',;
'C4I',;
'C4J',;
'C4K',;
'C4L',;
'C4M',;
'C4N',;
'C4O',;
'C4P',;
'C4Q',;
'C4R',;
'C4S',;
'C4T',;
'C4U',;
'C4V',;
'C4X',;
'C4Z',;
'C50',;
'C51',;
'C52',;
'C53',;
'C54',;
'C55',;
'C56',;
'C57',;
'C58',;
'C59',;
'C5A',;
'C5B',;
'C5C',;
'C5D',;
'C5E',;
'C5F',;
'C5G',;
'C5H',;
'C5I',;
'C5J',;
'C5K',;
'C5L',;
'C5M',;
'C5N',;
'C5O',;
'C5P',;
'C5Q',;
'C5R',;
'C5S',;
'C5T',;
'C5U',;
'C5V',;
'C5X',;
'C5Z',;
'C6A',;
'C6B',;
'C6C',;
'C6D',;
'C6E',;
'C6F',;
'C6G',;
'C6H',;
'C6I',;
'C6J',;
'C6K',;
'C6L',;
'C6M',;
'C6N',;
'C6O',;
'C6P',;
'C6Q',;
'C6R',;
'C6S',;
'C6T',;
'C6U',;
'C6V',;
'C6W',;
'C6X',;
'C6Y',;
'C70',;
'C71',;
'C72',;
'C73',;
'C74',;
'C75',;
'C76',;
'C77',;
'C78',;
'C79',;
'C7B',;
'C7C',;
'C7E',;
'C7F',;
'C7G',;
'C7H',;
'C7I',;
'C7J',;
'C7K',;
'C7L',;
'C7M',;
'C7N',;
'C7O',;
'C7Q',;
'C7R',;
'C7S',;
'C7U',;
'C7V',;
'C7X',;
'C7Z',;
'C80',;
'C81',;
'C82',;
'C83',;
'C84',;
'C85',;
'C86',;
'C87',;
'C88',;
'C8A',;
'C8C',;
'C8E',;
'C8F',;
'C8H',;
'C8J',;
'C8K',;
'C8M',;
'C8N',;
'C8R',;
'C8S',;
'C8V',;
'C8Y',;
'C92',;
'C93',;
'C94',;
'C95',;
'C96',;
'C97',;
'C98',;
'C99',;
'C9A',;
'C9B',;
'C9F',;
'C9G',;
'C9H',;
'C9I',;
'C9M',;
'C9S',;
'C9T',;
'C9U',;
'C9V',;
'C9Y',;
'C9Z',;
'CAI',;
'CAJ',;
'CAK',;
'CAL',;
'CAP',;
'CAQ',;
'CAR',;
'CAT',;
'CAX',;
'CEL',;
'CFQ',;
'CFR',;
'CFS',;
'CGU',;
'CGV',;
'CGW',;
'CGX',;
'CH1',;
'CH2',;
'CH5',;
'CHB',;
'CHC',;
'CHE',;
'CHH',;
'CHI',;
'CHJ',;
'CHK',;
'CKL',;
'CM4',;
'CM5',;
'CM9',;
'CMA',;
'CMB',;
'CMC',;
'CMD',;
'CME',;
'CMF',;
'CMG',;
'CMH',;
'CMI',;
'CMY',;
'CR9',;
'CRA',;
'CRB',;
'CRC',;
'CRD',;
'CRE',;
'CRF',;
'CRH',;
'CRI',;
'CRJ',;
'CRM',;
'CRN',;
'CRQ',;
'CU0',;
'CU4',;
'CU5',;
'CUA',;
'CUB',;
'CUC',;
'CUD',;
'CUE',;
'CUF',;
'CUM',;
'CUN',;
'CUP',;
'CUQ',;
'CUR',;
'CUS',;
'CUT',;
'CUU',;
'CUW',;
'CW6',;
'CW9',;
'CZS',;
'CZT',;
'CZU',;
'CZV',;
'C8L',;
'C8O',;
'C8P',;
'C8T',;
'C8U',;
'C8Z',;
'CA0',;
'CAH',;
'CFL',;
'CFM',;
'CFU',;
'CGN',;
'CH0',;
'CH6',;
'CH8',;
'CHA',; 
'CHW',;
'CHY',;
'CMM',;
'CUV',;
'CUY',;
'CUZ',;
'CW4',;
'CW5',;
'C89',;
'C8D',;
'C8G',;
'C8I',;
'T13';
}


For i:=1 to len(aTabs)

IncProc("Atualizando estruturas. Aguarde... ["+aTabs[i]+"]")

	//Chama o Job
	StartJob( "U__UTAF001      "+aTabs[i], GetEnvServer() , .F.,cEmpAnt,cFilAnt,aTabs[i])
   	sleep(400)
    
    if !(aTabs[i] $ "CU0/C1O/C0A")
	    //Chama o Job de atualização da tabela
		StartJob( "U__UTAF002       "+aTabs[i], GetEnvServer() , .F.,cEmpAnt,cFilAnt,aTabs[i],cBancoOri,cEmpOri,lSobresc)
	    sleep(100)
	endif
	
	//Para evitar sobrecarga no serviço
	if ThreadCount()>50
		sleep(1000)	
	endif
	
Next
cTexto+="Tabelas atualizadas"+NL


//Atualiza o SX6
DbSelectArea("SX6")
SX6->(DbSetOrder(1))

if SX6->(DbSeek(xFilial("SX6")+"MV_VAUTCON"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := alltrim(cVerAutoc)
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := alltrim(cVerAutoc)
		endif
			SX6->X6_CONTEUD := alltrim(cVerAutoc)
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_VAUTCON "+NL	
endif

if SX6->(DbSeek(xFilial("SX6")+"MV_TAFINT"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := ".T."
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := ".T."
		endif
			SX6->X6_CONTEUD := ".T."
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_TAFINT "+NL	
endif

if SX6->(DbSeek(xFilial("SX6")+"MV_TAFTALI"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := GetSrvProfString ( "DbAlias","")   //P1108_19
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := GetSrvProfString ( "DbAlias","")
		endif
			SX6->X6_CONTEUD := GetSrvProfString ( "DbAlias","")
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_TAFTALI "+NL	
endif

if SX6->(DbSeek(xFilial("SX6")+"MV_TAFTDB"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := "MSSQL"
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := "MSSQL"
		endif
			SX6->X6_CONTEUD := "MSSQL"
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_TAFTDB "+NL	
endif

if SX6->(DbSeek(xFilial("SX6")+"MV_TAFPORT"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := "7891"
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := "7891"
		endif
			SX6->X6_CONTEUD := "7891"
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_TAFPORT "+NL	
endif

if SX6->(DbSeek(xFilial("SX6")+"MV_TAFVER"))
	RecLock( "SX6" , .F. )
		if FieldPos("X6_CONTSPA")>0
			SX6->X6_CONTSPA := "R8"
		endif
		if FieldPos("X6_CONTENG")>0
			SX6->X6_CONTENG := "R8"
		endif
			SX6->X6_CONTEUD := "R8"
	SX6->(MsUnLock())
	cTexto += "Atualizado Parametro MV_TAFVER "+NL	
endif


Return

//Função para criar a tabela na empresa
*----------------------------------------*
User Function _UTAF001(cEmp,cFilEmp,cTab)
*----------------------------------------*

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

	for nSeq:=1 to 5
		if CHKFILE(cTab)
			exit	
		endif
    next
    
RpcClearEnv()

Return

//Função para criar a tabela na empresa
*--------------------------------------------------------------------*
User Function _UTAF002(cEmp,cFilEmp,cTab,cBancoOri,cEmpOri,lSobresc)
*--------------------------------------------------------------------*
Local cQry		:= ""
Local cPasta	:= "\BKP"
Local cPasta1	:= "\TAF"
Local aStruc	:= {}
Local nErro		:= 0

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)


cQry+=" Declare @COLS VARCHAR(400)
cQry+=" Declare @QRY  VARCHAR(1000)

cQry+=" SET @COLS =(SELECT
cQry+=" STUFF((
cQry+=" SELECT ','+name FROM sys.columns
cQry+=" WHERE is_identity=0 and object_id =
cQry+=" (
cQry+=" SELECT object_id FROM sys.tables
cQry+=" WHERE name = '"+cTab+cEmp+"0'
cQry+=" )
cQry+=" FOR XML PATH('')
cQry+=" ),1,1,'')
cQry+=" )

cQry+=" IF(SELECT COUNT(*) FROM "+cTab+cEmp+"0)=0"
cQry+=" 	BEGIN
cQry+=" 	SET @QRY='INSERT INTO "+cTab+cEmp+"0('+@COLS+') SELECT '+@COLS+' FROM "+cBancoOri+".dbo."+cTab+cEmpOri+"0'
cQry+=" 	END


if lSobresc
/*
	if !file(cPasta)
		if (nErro:=MakeDir(cPasta)) == 0
			if !file(cPasta+cPasta1)
				if (nErro:=MakeDir(cPasta+cPasta1)) == 0
				

				endif
			endif
		endif
	else
		if !file(cPasta+cPasta1)
		
		endif
	endif


						DbSelectArea(cTab)
						aStruc:= (cTab)->(DbStruct())
						
						_cArqDBF := AllTrim(cPasta+cPasta1)+"\"+RETSQLNAME(cTab)+".DBF"

						dbCreate(_cArqDBF,aStruc)
						dbUseArea( .T.,"dbfcdxads", _cArqDBF,"TRBAUX", .T., .F. )
					
					    dbSelectArea(_cAlias)
						dbSelectArea("TRBAUX")
						MsAppend(,_cAlias)
					
						TRBAUX->(DbCloseArea())
                        (cTab)->(DbCloseArea())
*/

	cQry+=" 	ELSE
	cQry+=" 		BEGIN
	cQry+="				IF (SELECT COUNT(*) FROM "+cBancoOri+".dbo."+cTab+cEmpOri+"0)>0
	cQry+=" 			BEGIN
	cQry+=" 				DELETE FROM "+cTab+cEmp+"0"
	cQry+=" 			END
	cQry+=" 			SET @QRY='INSERT INTO "+cTab+cEmp+"0('+@COLS+') SELECT '+@COLS+' FROM "+cBancoOri+".dbo."+cTab+cEmpOri+"0'	
	cQry+=" 		END	

endif

cQry+=" exec(@QRY)

//CONOUT(cQry)

TcSqlExec(cQry)

RpcClearEnv()

Return


//------------- INTERFACE ---------------------------------------------------
*--------------------*
Static Function Tela()
*--------------------*
Local lRet := .F.
Private cAliasWork := "Work"
private aCpos :=  {	{"MARCA"	,,""} ,;
						{"M0_CODIGO",,"Cod.Empresa"	},;
						{"M0_CODFIL",,"Filial" 		},;
		   				{"M0_NOME"	,,"Nome Empresa"}}
		   				
private aCampos :=  {	{"MARCA"	,"C",2 ,0} ,;
						{"M0_CODIGO","C",2 ,0},;
						{"M0_CODFIL","C",2 ,0},;
		   				{"M0_NOME"	,"C",30,0}}

If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf     

dbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(DbSetOrder(1))
RpcSetType(2)
RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)


cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)
cAux:= ""
While SM0->(!EOF())
	If cAux <> SM0->M0_CODIGO
		(cAliasWork)->(RecLock(cAliasWork,.T.))           
		(cAliasWork)->MARCA		:= ""
		(cAliasWork)->M0_CODIGO	:= SM0->M0_CODIGO
		(cAliasWork)->M0_CODFIL	:= SM0->M0_CODFIL
		(cAliasWork)->M0_NOME	:= SM0->M0_NOME
		(cAliasWork)->(MsUnlock())
		cAux := SM0->M0_CODIGO
	EndIf
	SM0->(DbSkip())
EndDo

(cAliasWork)->(DbGoTop())

Private cMarca := GetMark()

SetPrvt("oDlg1","oSay1","oBrw1","oCBox1","oSBtn1","oSBtn2")

oDlg1      := MSDialog():New( 091,232,451,612,"Equipe TI da HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oGroup	   := tGroup():New(004,002,28,190,'Dados de Origem',oDlg1,,,.T.)

oSay3      := TSay():New( 016,004,{||"Banco:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet1	   := TGet():New(  14,25,{|u| if(PCount()>0,cBancoOri:=u,cBancoOri)}, oDlg1,30,8,'@!',,,,,,,.T.,,,,,,,,,,'cBancoOri')

oSay4      := TSay():New( 016,60,{||"Empresa:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet2	   := TGet():New(  14,85,{|u| if(PCount()>0,cEmpOri:=u,cEmpOri)}, oDlg1,20,8,'@!',,,,,,,.T.,,,,,,,,,,'cEmpOri')

oSay5      := TSay():New( 016,110,{||"Versão Auto:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
oGet3	   := TGet():New(  14,145,{|u| if(PCount()>0,cVerAutoc:=u,cVerAutoc)}, oDlg1,20,8,'@!',,,,,,,.T.,,,,,,,,,,'cVerAutoc')

oGroup	   := tGroup():New(032,002,163,190,'Selecione as empresas a serem atualizadas',oDlg1,,,.T.)
DbSelectArea(cAliasWork)

oBrw1      := MsSelect():New( cAliasWork,"MARCA","",aCpos,.F.,cMarca,{041,004,149,180},,, oDlg1 ) 
oBrw1:bAval := {||cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.
oCBox1     := TCheckBox():New( 153,004,"Todas empresas.",,oDlg1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oCBox2     := TCheckBox():New( 167,004,"Sobrescrever tabelas existentes",,oDlg1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oSBtn1     := SButton():New( 167,116,1,{|| (Dados(), lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 167,152,2,{|| (lret := .f. , oDlg1:END())},oDlg1,,"", )

// Seta Eventos do primeiro Check
oCBox1:bSetGet := {|| lCheck }
oCBox1:bLClicked := {|| lCheck:=!lCheck }
oCBox1:bWhen := {|| .T. }
                           
// Seta Eventos do segundo Check
oCBox2:bSetGet := {|| lSobresc }
oCBox2:bLClicked := {|| lSobresc:=!lSobresc }
oCBox2:bWhen := {|| .T. }


oDlg1:Activate(,,,.T.)

Return lRet

*-----------------------*
Static Function cMark()
*-----------------------*
Local lDesMarca := (cAliasWork)->(IsMark("Marca", cMarca))

RecLock(cAliasWork, .F.)
if lDesmarca
   (cAliasWork)->MARCA := "  "
else
   (cAliasWork)->MARCA := cMarca
endif

(cAliasWork)->(MsUnlock())

return 

*-----------------------*
Static Function Dados()
*-----------------------*
dbSelectArea(cAliasWork)
(cAliasWork)->(DbGoTop())
While (cAliasWork)->(!EOF())
	If (cAliasWork)->MARCA <> " "
		aAdd(aAux, (cAliasWork)->M0_CODIGO+(cAliasWork)->M0_CODFIL)
	EndIf
	(cAliasWork)->(DbSkip())
EndDo
Return .t.

/*
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0 exclusivo
Obs.        :
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
	   //dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .T. ) //abre compartilhado 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
End Sequence

Return(lOpen)