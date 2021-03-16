#include "RWMAKE.CH"  
#include "COLORS.CH" 

//*************************************************************************************************************************************************
//Nome:     José Augusto Pereira Alves
//Data:     30/07/2007
//Cliente : Exclusivo Ball Van Zanten
//Função:   GARCTB01
//Decrição: Gerar arquivos com lançamentos contábeis
//*************************************************************************************************************************************************

/*
Funcao      : GARCTB01
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar arquivos com lançamentos contábeis    
Autor     	: José Augusto Pereira Alves 
Data     	: 30/07/2007 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Contabilidade.
*/



*---------------------------------------*
User Function GARCTB01()                 
*---------------------------------------*
                         
Local oDlg
Private nHdlChk  := NIL
Private dDtIni   := AVCTOD("  /  /  ")   
Private dDtFim   := AVCTOD("  /  /  ")   

Begin Sequence   
               
   If cEmpAnt <> "GA"  
      MsgStop("Programa Específico Ball Van Zanten - Favor Entrar em contato com o suporte da Pryor Consulting.")
      Return
   EndIf    
   
   @ 0,0 TO 250,460 DIALOG oDlg TITLE " Gera Lanctos Contábeis - Ball Van Zanten "
	@ 11,10 TO 90,220                                                       
		
	@ 005,010 SAY "Geração de Arquivos:"  COLOR CLR_HRED, CLR_WHITE  
	@ 024,012 SAY "Data Inicial:" 
   @ 024,050 GET dDtIni SIZE 40,8 //Valid NaoVazio()      	   
   @ 037,012 SAY "Data Final:" 
   @ 037,050 GET dDtFim SIZE 40,8 Valid fConfData(dDtFim, dDtIni) //.And. NaoVazio() 

	@ 100 ,160 BMPBUTTON TYPE 01 ACTION mQuery()
	@ 100 ,190 BMPBUTTON TYPE 02 ACTION Close(oDlg)
		
	ACTIVATE DIALOG oDlg  CENTERED            


End Sequence

Return 
  

//*************************************************************************************************************************************************
//Função que gera as query´s retornando os dados de acordo com o item selecionado no filtro.
//*************************************************************************************************************************************************
*---------------------------------------*
Static Function mQuery()           
*---------------------------------------*

Private wDir := ""  

Begin Sequence           
	//---------------------------------//lancamentos Contabeis----------------------------------------------------- 
	
	_DataDe := "'"+"20" + substr(dtoc(dDtIni),7,2) + substr(dtoc(dDtIni),4,2) + substr(dtoc(dDtIni),1,2)+"'"
	_DataAte:= "'"+"20" + substr(dtoc(dDtFim),7,2) + substr(dtoc(dDtFim),4,2) + substr(dtoc(dDtFim),1,2)+"'"
	   
	cQuery := "SELECT CT2_DEBITO,CT2_CREDIT, 'CT2_VALOR' = CONVERT(VARCHAR(20),CAST(CT2_VALOR AS NUMERIC(15,2))),CT2_HIST,CT2_DATA "
	//cQuery += "FROM DADOS_AP7..CT2GA0 " 
	cQuery += "FROM AMB01_P10..CT2GA0 "
	cQuery += "WHERE D_E_L_E_T_ <> '*' " 
	cQuery += "AND CT2_VALOR <> 0 "   
	cQuery += "AND CT2_MOEDLC = '01' "  
	cQuery += "AND CT2_ORIGEM NOT IN ('799/','808/','FIN-510-06-ACOSTA',' ') "
	cQuery += "AND CT2_ROTINA <> 'IFOLOBR' "
	cQuery += "AND CT2_DATA BETWEEN "+ _DataDe +" AND "+ _DataAte    
	cQuery += "ORDER BY CT2_DATA " 
	
	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB',.F.,.T.)
	DBSELECTAREA("TRB")
	DBGOTOP()
		
	wDir := "C:\LCBVZ_" + _DataDe + "_" + _DataAte + ".TXT"
   wDir :=alltrim(wdir) 
	
	If CriaTXT()
	   GravaTXT()
	   If !Empty(MemoRead(wDir))
	      msgInfo("Arquivo "+wDir+" Gerado com Sucesso")
	      TRB->(DbCloseArea()) 
	   Else
	      Alert("Não existem dados para geração do arquivo, por favor verifique os parâmetros.") 
	      TRB->(DbCloseArea())
	   EndIf
	Else                                             
	   Alert("Falha na criação do arquivo, por favor verifique os parâmetros.") 
	   FClose(nHdlChk)
	   TRB->(DbCloseArea())
	EndIf         
	
End Sequence

Return
        
//************************************************************************************************************************************************* 
//Função que cria o arquivo TXT.
//*************************************************************************************************************************************************
*---------------------------------------*
Static Function CriaTXT()                
*---------------------------------------*
Local lRet := .T.  

Begin Sequence     

	cArqChk	:=	wDir
	nHdlChk	:=	MsFCreate(cArqChk)
	If nHdlChk < 0
		lRet := .F.
		Break 
	EndIf      
	
End Sequence 

Return lRet       
           

//************************************************************************************************************************************************* 
//Função que faz a gravação do arquivo TXT. 
//*************************************************************************************************************************************************
*---------------------------------------*
Static Function GravaTXT(cCombo)         
*---------------------------------------*

Private cLinha := ""                          

Begin Sequence               
   
   PROCREGUA(7)
   
   //---------------------------------//lancamentos Contabeis-----------------------------------------------------  
	   Do While !Eof()                                              
	   
	      INCPROC("Lancamentos Contabeis: ") 
	      If !Empty(Alltrim(TRB->CT2_DEBITO)) .And. !Empty(Alltrim(TRB->CT2_CREDIT))    //Partida dobrada
	         cLinha := "001"  + Space(6)
	      ElseIf !Empty(Alltrim(TRB->CT2_DEBITO)) .And. Empty(Alltrim(TRB->CT2_CREDIT)) //Debito
	         cLinha := "002"  + Space(6)
	      ElseIf Empty(Alltrim(TRB->CT2_DEBITO)) .And. !Empty(Alltrim(TRB->CT2_CREDIT)) //Credito
	         cLinha := "003"  + Space(6)
	      EndIf
	      If !Empty(Alltrim(TRB->CT2_DEBITO))                                           //Conta Debito
	         cLinha := cLinha + Alltrim(TRB->CT2_DEBITO) + Space(31)    
	      Else
	         cLinha := cLinha + Space(40) 
	      EndIf
	      If !Empty(Alltrim(TRB->CT2_CREDIT))                                           //Conta Credito
	         cLinha := cLinha + Alltrim(TRB->CT2_CREDIT) + Space(21)      
	      Else
	         cLinha := cLinha + Space(30) 
	      EndIf       
	      cValor := REPLACE(TRB->CT2_VALOR,".","") 
	      cLinha := cLinha + cValor + Space(1) + TRB->CT2_HIST +  TRB->CT2_DATA            //Valor Lacto   + Histórico do Lancto + Dt Lancto
	      cLinha += chr(13) + chr(10)             
	      
	      FWrite(nHdlChk,cLinha,Len(cLinha))
	      TRB->(dbskip())
	
	   EndDo
    
   FClose(nHdlChk)              

End Sequence

Return 

//************************************************************************************************************************************************* 
//Função que confere as datas digitadas como parâmetro. 
//Parâmetros: cDtFim / cDtIni
//*************************************************************************************************************************************************
*---------------------------------------*
Static Function fConfData(dDtFim,dDtIni)
*---------------------------------------*

Local lRet  := .F.

Begin Sequence
      
   if !empty(dDtFim) .and. dDtFim < dDtIni
      MsgInfo("Data Final não pode ser menor que Data Inicial.","Aviso")
   Else
      lRet := .T.
   Endif   

End Sequence
      
Return lRet    
