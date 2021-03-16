#INCLUDE "Protheus.ch"
#INCLUDE "SHELL.ch"

/*
Funcao      : GTGEN034
Parametros  : Nil
Retorno     : Nil
Objetivos   : Download de tabela do banco em excel (formato dbf)
Autor       : Matheus Massarotto
Data/Hora   : 09/01/2015    
Revisão		:                    
Data/Hora   : 
Módulo      : Generico
*/

*--------------------------*
User function GTGEN034 
*--------------------------*
Local cTab:= space(3)

SetPrvt("oDlg","oGrp1","oGet1","oBtn1")

oDlg      := MSDialog():New( 095,232,271,421,"Download de tabela",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 012,016,044,072,"Tabela",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGet1      := TGet():New( 024,020,{|u| if(PCount()>0,cTab:=u,cTab)},oGrp1,048,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oBtn1      := TButton():New( 052,028,"Gerar",oDlg,{||iif(Barra(cTab),oDlg:End(),)},037,012,,,,.T.,,"",,,,.F. )

oDlg:Activate(,,,.T.)

Return

*-------------------------*
Static Function Barra(cTab)
*-------------------------*
Private oDlg1

if UPPER(substr(cTab,1,2))<>"SN"
	alert("Só é permitido gerar as tabelas do grupo SN")
	Return .F.
elseif !TCCanOpen(RETSQLNAME("cTab"))
	alert("Tabela "+RETSQLNAME("cTab")+" não encontrada!")
	Return .F.
endif
	
	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Buscando informacoes..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(Baixatab(@oMeter,oDlg1,cTab))

Return(.T.)

*----------------------------------------*
Static function Baixatab(oMeter,oDlg1,cTab)
*----------------------------------------*
Local cDest :=  GetTempPath()
Local cNome	:= CriaTrab(nil,.f.)
Local cArqTmp := cNome+".xls"

//Inicia a régua
oMeter:Set(25) //seta o valor na régua

dbUseArea( .T., "TOPCONN", RETSQLNAME(UPPER(cTab)), RETSQLNAME(UPPER(cTab)), if(.T. .OR. .F., !.F., NIL), .F. )

__dbCopy((cArqTmp),{ },,,,,.F.,"DBFCDX")

if !CPYS2T("\"+curdir()+alltrim(cArqTmp) ,cDest  )
	alert("Não foi possível gerar o arquivo!")
endif

IF FILE ("\"+curdir()+alltrim(cArqTmp))
	FERASE ("\"+curdir()+alltrim(cArqTmp))
ENDIF

IF FILE ("\"+curdir()+alltrim(cNome)+".fpt")
	FERASE ("\"+curdir()+alltrim(cNome)+".fpt")
ENDIF

GExecl(cDest+cArqTmp)	

//Fecho a barra de processamento.
oDlg1:end()
Return


/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Função para abrir o excel
Autor       : Matheus Massarotto
Data/Hora   : 11/04/2013	17:17
*/
*------------------------------*
Static Function GExecl(cArqExcel)
*------------------------------*
/***********************GERANDO EXCEL************************************/

	cArq := alltrim(cArqExcel)
	
	SHELLEXECUTE("open",(cArq),"","",5)   // Abre o arquivo em Excel
	
/***********************GERANDO EXCEL************************************/          
    sleep(2000)
	FERASE (cArq)

Return