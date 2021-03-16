//|=====================================================================|
//|Programa: SUFIN003.PRW   |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar os dados do contribuinte no  |
//|           titulo gerado de INSS.                                    |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA050                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "PROTHEUS.CH"
#Include "totvs.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"

User Function SUFIN003()
	Local _cRotina  := Alltrim(FunName())
	Local _cNome    := ""
	Local _cFornece := ""
	Local _cLoja    := ""
	Local _cCnpj    := ""
	Local _cRazao   := ""
	Local _cMes     := ""
	Local _cAno     := ""
	
	If _cRotina == "FINA050" .or. _cRotina == "MATA103" .or. _cRotina == "FINA750"
		
		If _cRotina == "FINA050" .or. _cRotina == "FINA750"
			_cFornece := M->E2_FORNECE
			_cLoja    := M->E2_LOJA
			_cMes     := Subs(Dtos(M->E2_EMISSAO),5,2)
			_cAno     := Subs(Dtos(M->E2_EMISSAO),1,4)
		Else
			_cFornece := SF1->F1_FORNECE
			_cLoja    := SF1->F1_LOJA
			_cMes     := Subs(Dtos(SF1->F1_EMISSAO),5,2)
			_cAno     := Subs(Dtos(SF1->F1_EMISSAO),1,4)
		EndIf
		
		_cNome  := GetAdvFval("SA2","A2_NREDUZ",xFilial("SA2")+_cFornece+_cLoja,1)
		_cCnpj  := GetAdvFval("SA2","A2_CGC"   ,xFilial("SA2")+_cFornece+_cLoja,1)
		_cRazao := GetAdvFval("SA2","A2_NOME"  ,xFilial("SA2")+_cFornece+_cLoja,1)
		
		RECLOCK("SE2",.F.)
		SE2->E2_HIST    := "INSS "+_cNome
		SE2->E2_P_CNPJC  := _cCnpj
		SE2->E2_P_CONTR  := _cRazao
		SE2->E2_P_CODRE := "2631"  // Fixo 2631 porque para terceiros é sempre este.
		SE2->E2_P_APUR  := LastDay(CTOD("01"+"/"+_cMes+"/"+_cAno))  //-- Competencia mes/ano referente a data de emissao da NF
		
		
		MSUNLOCK()
		
	EndIf
	
Return

//|=====================================================================|
//|Programa: SUFIN004.PRW  |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar histórico no titulo de IRRF  |
//|           Código da Retenção e Gera Dirf SIM.                       |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA050                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function SUFIN004()

  Local _cRotina  := Alltrim(FunName())
  Local _cCnpj    := ""
  Local _cMes     := "" 
  Local _cAno     := "" 
  
  If _cRotina == "FINA050" .or. _cRotina == "MATA103" .or. _cRotina == "FINA750"
     
      _cMes     := Subs(Dtos(SE2->E2_VENCREA),5,2) 
      _cAno     := Subs(Dtos(SE2->E2_VENCREA),1,4) 
                                                                                     
      //--- Retornar o CNPJ da Matriz - sempre 01 é Matriz.
      //---  1o. parametro: 02 - CNPJ
      //---  2o. parametro: 01 - Filial 01
      _cCnpj   :=  u_SUFIN010("02","01") 
     
     RECLOCK("SE2",.F.)
     If Empty(Alltrim(SE2->E2_CODRET))
        SE2->E2_CODRET  := "1708"
     EndIf
     SE2->E2_DIRF        := "1"
     SE2->E2_P_CNPJC   := _cCnpj
     SE2->E2_P_CONTR  := SM0->M0_NOMECOM   
     SE2->E2_P_APUR  := (CTOD("01"+"/"+_cMes+"/"+_cAno)-1)  //-- Competencia mes/ano - Ultimo dia do mes anterior a data do vencimento do imposto
     SE2->E2_HIST       := _cRotina+" "+SE2->E2_CODRET
     
     MSUNLOCK()               
  
  Else
  
     RECLOCK("SE2",.F.)
     SE2->E2_HIST       := _cRotina+" "+SE2->E2_CODRET
     MSUNLOCK()               
  
  EndIf

RETURN   

//|=====================================================================|
//|Programa: SUFIN004.PRW   |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar os dados do contribuinte no  |
//|titulo gerado de IRRF pela rotina de aglutinacao de imposto (FINA376)|
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA376                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function SUFIN005()

  Local _cCnpj    := ""
  Local _cMes     := "" 
  Local _cAno     := "" 

     _cMes     := Subs(Dtos(SE2->E2_VENCREA),5,2) 
     _cAno     := Subs(Dtos(SE2->E2_VENCREA),1,4) 
                                                                                     
      
     //--- Retornar o CNPJ da Matriz - sempre 01 é Matriz.
     //---  1o. parametro: 02 - CNPJ
     //---  2o. parametro: 01 - Filial 01
     _cCnpj   :=  u_SUFIN010("02","01") 
     
     RECLOCK("SE2",.F.)
        SE2->E2_P_CNPJC  := _cCnpj
        SE2->E2_P_CONTR  := SM0->M0_NOMECOM   
        SE2->E2_P_APUR  := (CTOD("01"+"/"+_cMes+"/"+_cAno)-1)  //-- Competencia mes/ano - Ultimo dia do mes anterior a data do vencimento do imposto
        If Empty(SE2->E2_CODRET)
          SE2->E2_CODRET := "1708"
        EndIf
     MSUNLOCK()               
    
return

//|=====================================================================|
//|Programa: SUFIN006.PRW   |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Ponto de entrada para gravar os dados do contribuinte no  |
//|titulo gerado de PIS/COFINS/CSLL pela rotina de aglutinacao de 		|
//|imposto (FINA378)							                        |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA378                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
#Include "rwmake.ch"

User Function SUFIN006()

  Local _cCnpj    := ""
      
     //--- Retornar o CNPJ da Matriz - sempre 01 é Matriz.
     //---  1o. parametro: 02 - CNPJ
     //---  2o. parametro: 01 - Filial 01
     _cCnpj   :=  u_SUFIN010("02","01") 
     
     RECLOCK("SE2",.F.)
        SE2->E2_P_CNPJC  := _cCnpj
        SE2->E2_P_CONTR  := SM0->M0_NOMECOM   
        SE2->E2_P_APUR  := MV_PAR02  //-- Competencia mes/ano - Parametro Data Final da rotina
     MSUNLOCK()               
    
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Rotina    ³ SUFIN007.PRW                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de Entrada para retornar Juros e Multa quando nao    ³±±
±±³          ³ tiver no arquivo de retorno do banco.                      ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desenvolvi³ João Vitor		                                          ³±±
±±³mento     ³ 13/05/2016	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/

#INCLUDE 'RWMAKE.CH'

USER FUNCTION SUFIN007()

Local _aAreaSE2 := GetArea()    
Local _nDescon  := 0
Local _nAcresc  := 0

If !Empty(cNumTit)

   //Busca por IdCnab (sem filial)
   SE2->(dbSetOrder(13)) // IdCnab
   If SE2->(MsSeek(Substr(cNumTit,1,10)))
      
      _nAcresc  := Round(NoRound(xMoeda(SE2->E2_SDACRES,SE2->E2_MOEDA,1,dBaixa,3),3),2)
	  _nDecres  := Round(NoRound(xMoeda(SE2->E2_SDDECRE,SE2->E2_MOEDA,1,dBaixa,3),3),2)

      If (nMulta+nJuros) = 0 .and. _nAcresc > 0
        
          nMulta := _nAcresc
      
      EndIf
      
      If (nDescont) = 0 .and. _nDecres > 0
        
          nDescont := _nDecres
      
      EndIf

   Endif
		


EndIf

RestArea(_aAreaSE2)
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Rotina    ³ SUFIN008.PRW                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de Entrada para retornar Juros e Multa quando nao    ³±±
±±³          ³ tiver no arquivo de retorno do banco (CNAB A PAGAR)        ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desenvolvi³ João Vitor		                                          ³±±
±±³mento     ³ 13/05/2016	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
#INCLUDE 'RWMAKE.CH'

User Function SUFIN008()

Local _aAreaSE2 := GetArea()    
Local _nDescon  := 0
Local _nAcresc  := 0

If !Empty(cNumTit) .and. MV_PAR07 == 2

   //Busca por IdCnab (sem filial)
   SE2->(dbSetOrder(13)) // IdCnab
   If SE2->(MsSeek(Substr(cNumTit,1,10)))
      
      _nAcresc  := Round(NoRound(xMoeda(SE2->E2_SDACRES,SE2->E2_MOEDA,1,dBaixa,3),3),2)
	  _nDecres  := Round(NoRound(xMoeda(SE2->E2_SDDECRE,SE2->E2_MOEDA,1,dBaixa,3),3),2)

      If (nMulta+nJuros) = 0 .and. _nAcresc > 0
        
          nMulta := _nAcresc
      
      EndIf
      
      If (nDescont) = 0 .and. _nDecres > 0
        
          nDescont := _nDecres
      
      EndIf

   Endif
		


EndIf

RestArea(_aAreaSE2)
	
Return         

//|=====================================================================|
//|Programa: SUFIN009.PRW   |Autor: João Vitor   | Data: 13/05/2016		|
//|=====================================================================|
//|Descricao: Gera as informacoes para o cnab a pagar o banco do		|
//| santander															|
//|=====================================================================|
//| Parametros:               
//|01 - Retorna o nome do contribuinte (segmento N)						|
//|02 - Retorna os detalhes do segmento N (depende do tipo do tributo) |
//|=====================================================================|
//|Uso: 										                        |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|---------------------------------------------------------------------|
//|=====================================================================|
#include "rwmake.ch"


User Function SUFIN009(_cOpcao)

Local _cReturn := ""
	
If _cOpcao == "01"   // Nome do Contribuinte
   
   If !Empty(SE2->E2_P_CNPJC)
      _cReturn := Subs(SE2->E2_P_CONTR,1,30)
      If Empty(_cReturn)
         MsgAlert('Nome do Contribuinte não informado para o segmento N - Titulo '+alltrim(se2->e2_prefixo)+"-"+alltrim(se2->e2_num)+"-"+alltrim(se2->e2_parcela)+'. Atualize o Nome do Contribuinte no titulo indicado e execute esta rotina novamente.')
      EndIf
  Else
      _cReturn := Subs(SM0->M0_NOMECOM,1,30)
  EndIf   
   
ElseIf _cOpcao == "02"   // Detalhes Segmento N 
   
  //--- Codigo Receita do Tributo - Posicao 111 a 116                                                                      
  If SEA->EA_MODELO == "18"   //--- Para DARF Simples - fixar código 6106
     _cReturn := "6106"+SPACE(2)
  Else
     _cReturn := If(!Empty(SE2->E2_P_CODRE),SE2->E2_P_CODRE,SE2->E2_CODRET)+SPACE(2)
  
  EndIf 

  //--- Tipo de Identificacao do Contribuinte - Posicao 117 a 118
  //--- CNPJ (1) /  CPF (2)             
  If !Empty(SE2->E2_P_CNPJC)
     _cReturn += Iif (len(alltrim(SE2->E2_P_CNPJC))>11,"01","02")
  Else               
     _cReturn += "01"           
  EndIf
             
  //--- Identificacao do Contribuinte - Posicao 119 a 132
  //--- CNPJ/CPF do Contribuinte    
  If SEA->EA_MODELO == "22"  //--- Para GARE ICMS - Retornar o CNPJ da Filial do SE2->E2_FILIAL
 
      _cReturn +=  Strzero(Val(u_SUFIN010("02",SE2->E2_FILIAL)),14)                               
  
  Else
  
      If !Empty(SE2->E2_P_CNPJC)
         _cReturn += Strzero(Val(SE2->E2_P_CNPJC),14)
      Else
        _cReturn += Subs(SM0->M0_CGC,1,14)
      EndIf
 
  EndIf
                                              
  //--- Identificacao do Tributo - Posicao 133 a 134  
  //--- 16 - DARF Normal   
  //--- 17 - GPS                 
  //--- 18 - DARF Simples
  //--- 19 - IPTU
  //--- 22 - GARE-SP ICMS
  //--- 23 - GARE-SP DR
  //--- 24 - GARE-SP ITCMD
  //--- 25 - IPVA
  //--- 26 - Licenciamento
  //--- 27 - DPVAT
  //--- 35 - FGTS   
  _cReturn += SEA->EA_MODELO 


  //--- GPS                  
  If SEA->EA_MODELO == "17" //--- GPS
     
     //--- Competencia (Mes/Ano) - Posicao 135 a 140  Formato MMAAAA
     _cReturn += Strzero(Month(SE2->E2_P_APUR),2)+Strzero(Year(SE2->E2_P_APUR),4)  

     //--- Valor do Tributo - Posicao 141 a 155
     _cReturn += Strzero((SE2->E2_SALDO-SE2->E2_P_VLENT)*100,15)
     
     //--- Valor Outras Entidades - Posicao 156 a 170             
     _cReturn += Strzero(SE2->E2_P_VLENT*100,15)     
     
     //--- Atualizacao Monetaria - Posicao 171 a 185                        
     _cReturn += Strzero((SE2->E2_P_MULTA+SE2->E2_P_JUROS)*100,15)                              

     //--- Mensagem ALERTA que está sem Codigo da Receita
     If Empty(SE2->E2_P_CODRE)                              
     
        MsgAlert('Tributo sem Codigo Receita. Informe o campo Cod.Receita no Titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')

     EndIf
     
     //--- Mensagem ALERTA que está sem periodo de apuração
     If Empty(se2->E2_P_APUR)                              
     
        MsgAlert('Tributo sem Periodo de Apuracao. Informe o campo Per.Apuracao no Titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')

     EndIf
     
  //--- DARF Normal                  
  ElseIf SEA->EA_MODELO == "16" //--- DARF Normal
  
     //--- Periodo de Apuracao - Posicao 135 a 142  Formato DDMMAAAA
     _cReturn += Gravadata(SE2->E2_P_APUR,.F.,5)                               

     //--- Referencia - Posicao 143 a 159                     
     _cReturn += Strzero(Val(SE2->E2_P_REFER),17)

     //--- Valor Principal - Posicao 160 a 174
     _cReturn += Strzero(SE2->E2_SALDO*100,15)
     
     //--- Valor da Multa - Posicao 175 a 189             
     _cReturn += Strzero(SE2->E2_P_MULTA*100,15)     
     
     //--- Valor Juros/Encargos - Posicao 190 a 204                        
     _cReturn += Strzero(SE2->E2_P_JUROS*100,15)                              
   
     //--- Data de Vencimento - Posicao 205 a 212  Formato DDMMAAAA
     _cReturn += Gravadata(SE2->E2_VENCTO,.F.,5)                               

     //--- Mensagem ALERTA que está sem Codigo da Receita para DARF de Retenção
     //If Empty(SE2->E2_CODRET)                              
     
     //   MsgAlert('Tributo sem Codigo Receita. Informe o campo Cd.Retenção no Titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')

     //EndIf
     
     //--- Mensagem ALERTA que está sem periodo de apuração
     If Empty(se2->E2_P_APUR)                              
     
        MsgAlert('Tributo sem Periodo de Apuracao. Informe o campo Per.Apuracao no Titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')

     EndIf
     
 
  //--- DARF Simples                  
  ElseIf SEA->EA_MODELO == "18" //--- DARF Simples
  
     //--- Periodo de Apuração  (Dia/Mes/Ano) - Posicao 135 a 142  Formato DDMMAAAA
     _cReturn += Gravadata(SE2->E2_P_APUR,.F.,5)                               

     //--- Receita Bruta - Posicao 143 a 157                     
     _cReturn += Repl("0",15)

     //--- Percentual - Posicao 158 a 164
     _cReturn += Repl("0",7)
     
     //--- Valor Principal - Posicao 165 a 179
     _cReturn += Strzero(SE2->E2_SALDO*100,15)
     
     //--- Valor da Multa - Posicao 180 a 194             
     _cReturn += Strzero(SE2->E2_P_MULTA*100,15)     
     
     //--- Valor Juros/Encargos - Posicao 195 a 209                        
     _cReturn += Strzero(SE2->E2_P_JUROS*100,15)                              

     //--- Mensagem ALERTA que está sem periodo de apuração
     If Empty(se2->E2_P_APUR)                              
     
        MsgAlert('Tributo sem Periodo de Apuracao. Informe o campo Per.Apuracao no Titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')

     EndIf
   
  //--- GARE ICMS SP                  
  ElseIf SEA->EA_MODELO == "22" //--- GARE ICMS - SP
 
     //--- Data de Vencimento - Posicao 135 a 142  Formato DDMMAAAA
     _cReturn += Gravadata(SE2->E2_VENCREA,.F.,5)                               

     //--- Inscricao Estadual - Posicao 143 a 154 
      _cReturn +=  Strzero(Val(u_SUFIN010("01",SE2->E2_FILIAL)),12)                               
                                                                           
     //--- Divida Ativa / Etiqueta - Posicao 155 a 167 
      _cReturn +=  Strzero(Val(SE2->E2_P_DIVID),13)                               

     //--- Periodo de Referencia (Mes/Ano) - Posicao 168 a 173  Formato MMAAAA
     _cReturn += Strzero(Month(SE2->E2_P_APUR),2)+Strzero(Year(SE2->E2_P_APUR),4)  

     //--- N. Parcela / Notificação - Posicao 174 a 186 
      _cReturn +=  Strzero(Val(SE2->E2_P_PARCE),13)                               

     //--- Valor da Receita (Principal) - Posicao 187 a 201
     _cReturn += Strzero(SE2->E2_SALDO*100,15)
     
     //--- Valor Juros/Encargos - Posicao 202 a 215                        
     _cReturn += Strzero(SE2->E2_P_JUROS*100,14)                              

     //--- Valor da Multa - Posicao 216 a 229             
     _cReturn += Strzero(SE2->E2_P_MULTA*100,14)     
     
  //--- 25 - IPVA SP   
  //--- 26 - Licenciamento
  //--- 27 - DPVAT              
  ElseIf SEA->EA_MODELO == "25"  .or. SEA->EA_MODELO == "26" .or. SEA->EA_MODELO == "27" 
   
     //--- Exercicio Ano Base - Posicao 135 a 138
     _cReturn += Strzero(SE2->E2_ANOBAS,4)                               

     //--- Renavam - Posicao 139 a 147 
      _cReturn +=  Strzero(Val(SE2->E2_RENAV),9)                               
                                                                           
     //--- Unidade Federação - Posicao 148 a 149 
      _cReturn +=  Upper(SE2->E2_IPVUF)                               

     //--- Codigo do Municipio - Posicao 150 a 154
     _cReturn += Strzero(Val(SE2->E2_CODMUN),5)    

     //--- Placa - Posicao 155 a 161 
      _cReturn +=  SE2->E2_PLACA                              

     //--- Opção de Pagamento - Posicao 162 a 162 - Para DPVAT sempre opção 5
     If SEA->EA_MODELO == "25"
        _cReturn += Alltrim(SE2->E2_OPCAO)
     Else
        _cReturn += "5"   //--- Para 27-DPVAT e 26-Licenciamento é obrigatório utilizar o código 5.
     EndIf
     
    //--- Opção de Retirada do CRVL - Posicao 163 a 163 - Somente para LICENCIAMENTO    
    //---- 1 = Correio
    //---  2 = Detran / Ciretran
     If SEA->EA_MODELO == "26"
        _cReturn += "1"    //--- Definido por Giovana sempre 1 = Correio
     EndIf
  EndIf           

EndIf       

Return(_cReturn)       

//--- Retornar Inscrição Estadual e CNPJ da Filial do Título do SE2
User Function SUFIN010(_cOpc,_cFilSE2)
                                                            
Local _cVolta := ""
Local _nRecnoSM0 :=SM0->(Recno())


  SM0->(dbSetOrder(1))
  SM0->(dbSeek(cEmpAnt+_cFilSE2))
		
  If _cOpc == "01"
     _cVolta := SM0->M0_INSC 
  Else
    _cVolta := SM0->M0_CGC
  EndIf
		
SM0->(dbGoto(_nRecnoSM0))

Return(_cVolta)


/*/{Protheus.doc} SUFIN011
@type Static Function
@author InfinIT Tecnologia
@since 29/04/2016
@version P11 R8

Descrição: Tela com filtro a escolha do usuário

/*/
User Function SUFIN011
	Local cEdit1:=""
	Local cEdit := Space(3)
	Local oEdit
	Local cEdit1 := Space(3)
	Local oEdit1
	Private cFil	 :=""
	Private cFil2	 :=""
	Private cTexto   :=""
	Private _oDlg
	Private oMemo
		
	DEFINE MSDIALOG _oDlg TITLE "Seleciona tipos" FROM C(350),C(575) TO C(487),C(721) PIXEL
	@ C(000),C(007) Say "Do Tipo: " Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(007),C(007) MSGET oEdit Var cEdit Size C(060),C(009) COLOR CLR_BLACK F3 "05" PIXEL OF _oDlg
	@ C(018),C(007) Say "Ate Tipo: " Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(025),C(007) MSGET oEdit1 Var cEdit1 Size C(060),C(009) COLOR CLR_BLACK F3 "05" PIXEL OF _oDlg
	@ C(038),C(007) Say "**Caso não queira utilizar este filtro aperte calcelar." Size C(040),C(020) COLOR CLR_BLACK PIXEL OF _oDlg
	DEFINE SBUTTON FROM C(057),C(026) TYPE 2 ENABLE OF _oDlg ACTION _bCanc(cEdit,cEdit1)
	DEFINE SBUTTON FROM C(057),C(049) TYPE 1 ENABLE OF _oDlg ACTION _bOk(cEdit,cEdit1)
	ACTIVATE MSDIALOG _oDlg CENTERED
	
	
Return(cFil)

//**************************
Static Function _bOk(cEdit,cEdit1)
	//**************************
	_oDlg:End()
	if !Empty(cEdit) .and. !Empty(cEdit1)
		cFil := "E2_TIPO >= '"+Upper(SubStr(cEdit,1,3))+"' .AND. E2_TIPO <= '"+Upper(SubStr(cEdit1,1,3))+"' "
	Else
		cFil := "E2_TIPO >= '   ' .AND. E2_TIPO <= 'ZZZ' "
	endif
	
Return cFil


//**************************
Static Function _bCanc(cEdit,cEdit1)
	//**************************
	_oDlg:End()
	cFil:= " "
	cEdit := cEdit1 := " "
	//
Return cFil


Static Function C(nTam)
	
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 900).Or.(nHRes == 1600)	// Resolucao 1600x900
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf
	
Return Int(nTam)
