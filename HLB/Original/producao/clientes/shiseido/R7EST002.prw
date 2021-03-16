#Include "topconn.ch"
#Include "rwmake.ch"
#Include "protheus.ch"

/*
Funcao      : R7EST002
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de NFs e Devoluções
Autor     	: Jean Victor Rocha	
Data     	: 21/05/2014
*/
*----------------------*
User Function R7EST002()
*----------------------*
Private cPerg := "R7EST002"

//Ajuste Do SX1.
AjustaSX1()

//Pergunte
If !Pergunte(cPerg)
	Return .T.
EndIf

//Busca os dados
BuscarDados()

//Geração do Arquivo
MakeArq()

Return .T.  

/*
Funcao      : AjustaSX1
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Rotina de ajuste do SX1.
Autor     	: Jean Victor Rocha	
Data     	: 21/05/2014
*/
*-----------------------*
User Function AjustaSX1()
*-----------------------*
     
U_PUTSX1(cPerg	,"01","Data de				","","","mv_ch1" ,"D",08,00,00,"G","","","","","Mv_Par01","","","","","","","","","","","","","","","","",{"Informe a data Inicial"})
U_PUTSX1(cPerg	,"02","Data até				","","","mv_ch2" ,"D",08,00,00,"G","","","","","Mv_Par02","","","","","","","","","","","","","","","","",{"Informe a data Final"})
U_PUTSX1(cPerg	,"03","Produto de			","","","mv_ch3" ,"C",08,00,00,"G","","","","","Mv_Par03","","","","","","","","","","","","","","","","",{"Informe o Produto Inicial"})
U_PUTSX1(cPerg	,"04","Produto até			","","","mv_ch4" ,"C",08,00,00,"G","","","","","Mv_Par04","","","","","","","","","","","","","","","","",{"Informe o Produto Final"})
U_PUTSX1(cPerg	,"05","Marca de 			","","","mv_ch5" ,"C",08,00,00,"G","","","","","Mv_Par05","","","","","","","","","","","","","","","","",{"Informe a Marca Inicial"})
U_PUTSX1(cPerg	,"06","Marca até			","","","mv_ch6" ,"C",08,00,00,"G","","","","","Mv_Par06","","","","","","","","","","","","","","","","",{"Informe a Marca Final"})
U_PUTSX1(cPerg	,"07","Cliente de			","","","mv_ch7" ,"C",08,00,00,"G","","","","","Mv_Par07","","","","","","","","","","","","","","","","",{"Informe a Cliente Inicial"})
U_PUTSX1(cPerg	,"08","Cliente ate			","","","mv_ch8" ,"C",08,00,00,"G","","","","","Mv_Par08","","","","","","","","","","","","","","","","",{"Informe a Cliente Final"})
U_PUTSX1(cPerg	,"09","Armazem de			","","","mv_ch9" ,"C",08,00,00,"G","","","","","Mv_Par09","","","","","","","","","","","","","","","","",{"Informe a Armazem Inicial"})
U_PUTSX1(cPerg	,"10","Armazem ate			","","","mv_ch10","C",08,00,00,"G","","","","","Mv_Par10","","","","","","","","","","","","","","","","",{"Informe a Armazem Final"})
U_PUTSX1(cPerg	,"11","Tipo de relatório	","","","mv_ch11","D",01,00,00,"G","","","","","Mv_Par11","","","","","","","","","","","","","","","","",{"Informe o tipo de Relatorio"})
U_PUTSX1(cPerg	,"12","CFOP´s Saídas		","","","mv_ch12","C",50,00,00,"G","","","","","Mv_Par12","","","","","","","","","","","","","","","","",{"Informe os CFOP's de Saida separador por ';'"})
U_PUTSX1(cPerg	,"13","Devoluções vendas	","","","mv_ch13","C",08,00,00,"G","","","","","Mv_Par13","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{"Exibe Devoluções de Vendas"})
U_PUTSX1(cPerg	,"14","Aglutina Clientes?	","","","mv_ch14","C",08,00,00,"G","","","","","Mv_Par14","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{"Aglutina Cliente?"})
U_PUTSX1(cPerg	,"15","Imprime em Excel		","","","mv_ch15","C",08,00,00,"G","","","","","Mv_Par15","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{"Gera Excel."})

Return .T.
