#include "protheus.ch"

/*
Funcao      : F650DESCR
Retorno     : lRet
Objetivos   : Informar o motivo das Entradas Rejeitadas.
Autor       : Jo�o Silva 
Data/Hora   : 31/10/2013
Revis�o		: 
Data/Hora   : 
M�dulo      : Financeiro 
Cliente		: Gartner
*/

*---------------------*
User Function F650DESCR                                       	
*---------------------*
Local cRet  := ''
Local nCont := 0

If AllTrim(cEmpAnt) $"40" .AND. AllTrim(cOcorr) $"03"   
	For nCont := 1 TO Len(Alltrim(cRej)) Step 2
		cMotivo:=Substr(cRej,nCont,2)
		Do Case
			Case cMotivo =='03'
				cRet:= RTrim(cOcorr)+'-'+ 'CEP SEM ATENDIMENTO DE PROTESTO NO MOMENTO                                          '
			Case cMotivo =='04'     
				cRet:= RTrim(cOcorr)+'-'+ 'SIGLA DO ESTADO INV�LIDA                                                            '
			Case cMotivo =='05'     
				cRet:= RTrim(cOcorr)+'-'+ 'DATA VENCIMENTO PRAZO DA OPERA��O MENOR QUE PRAZO M�NIMO OU MAIOR QUE O M�XIMO      '
			Case cMotivo =='07'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO T�TULO MAIOR QUE 10.000.000,00                                             '
			Case cMotivo =='08'    
				cRet:= RTrim(cOcorr)+'-'+ 'NOME DO PAGADOR N�O INFORMADO OU DESLOCADO                                          '
			Case cMotivo =='09'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA ENCERRADA                                                                   '
			Case cMotivo =='10'     
				cRet:= RTrim(cOcorr)+'-'+ 'LOGRADOURO N�O INFORMADO OU DESLOCADO                                               '
			Case cMotivo =='11'    
				cRet:= RTrim(cOcorr)+'-'+ 'CEP N�O NUM�RICO OU CEP INV�LIDO                                                    '
			Case cMotivo =='12'   
				cRet:= RTrim(cOcorr)+'-'+ 'SACADOR / AVALISTA NOME N�O INFORMADO OU DESLOCADO (BANCOS CORRESPONDENTES)         '
			Case cMotivo =='13'     
				cRet:= RTrim(cOcorr)+'-'+ 'CEP INCOMPAT�VEL COM A SIGLA DO ESTADO                                              '
			Case cMotivo =='14'     
				cRet:= RTrim(cOcorr)+'-'+ 'NOSSO N�MERO J� REGISTRADO NO CADASTRO DO BANCO OU FORA DA FAIXA       '
			Case cMotivo =='15'     
				cRet:= RTrim(cOcorr)+'-'+ 'NOSSO N�MERO EM DUPLICIDADE NO MESMO MOVIMENTO                                      '
			Case cMotivo =='18'    
				cRet:= RTrim(cOcorr)+'-'+ 'DATA DE ENTRADA DATA DE ENTRADA INV�LIDA PARA OPERAR COM ESTA CARTEIRA              '
			Case cMotivo =='19'    
				cRet:= RTrim(cOcorr)+'-'+ 'OCORR�NCIA INV�LIDA 21 AG. COBRADORA CARTEIRA N�O ACEITA DEPOSIT�RIA CORRESPONDENTE '
			Case cMotivo =='22'     
				cRet:= RTrim(cOcorr)+'-'+ 'CARTEIRA N�O PERMITIDA (NECESS�RIO CADASTRAR FAIXA LIVRE)                           '
			Case cMotivo =='26'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA/CONTA AG�NCIA/CONTA N�O LIBERADA PARA OPERAR COM COBRAN�A                   '
			Case cMotivo =='27'     
				cRet:= RTrim(cOcorr)+'-'+ 'CNPJ DO BENEFICI�RIO INAPTO DEVOLU��O DE T�TULO EM GARANTIA                         '
			Case cMotivo =='29'     
				cRet:= RTrim(cOcorr)+'-'+ 'C�DIGO EMPRESA CATEGORIA DA CONTA INV�LIDA                                          '
			Case cMotivo =='30'     
				cRet:= RTrim(cOcorr)+'-'+ 'ENTRADAS BLOQUEADAS, CONTA SUSPENSA EM COBRAN�A                                     '
			Case cMotivo =='31'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA/CONTA CONTA N�O TEM PERMISS�O PARA PROTESTAR (CONTATE SEU GERENTE)          '
			Case cMotivo =='35'     
				cRet:= RTrim(cOcorr)+'-'+ 'IOF MAIOR QUE 5%                                                                    '
			Case cMotivo =='36'     
				cRet:= RTrim(cOcorr)+'-'+ 'QTDADE DE MOEDA QUANTIDADE DE MOEDA INCOMPAT�VEL COM VALOR DO T�TULO                '
			Case cMotivo =='37'     
				cRet:= RTrim(cOcorr)+'-'+ 'N�O NUM�RICO OU IGUAL A ZEROS                                                       '
			Case cMotivo =='42'     
				cRet:= RTrim(cOcorr)+'-'+ 'NOSSO N�MERO NOSSO N�MERO FORA DE FAIXA                                             '
			Case cMotivo =='52'     
				cRet:= RTrim(cOcorr)+'-'+ 'EMPRESA N�O ACEITA BANCO CORRESPONDENTE                                             '
			Case cMotivo =='53'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG. COBRADORA EMPRESA N�O ACEITA BANCO CORRESPONDENTE - COBRAN�A MENSAGEM           '
			Case cMotivo =='54'     
				cRet:= RTrim(cOcorr)+'-'+ 'BANCO CORRESPONDENTE - T�TULO COM VENCIMENTO INFERIOR A 15 DIAS                     '
			Case cMotivo =='55'     
				cRet:= RTrim(cOcorr)+'-'+ 'DEP/BCO CORRESP CEP N�O PERTENCE � DEPOSIT�RIA INFORMADA                            '
			Case cMotivo =='56'     
				cRet:= RTrim(cOcorr)+'-'+ 'VENCTO SUPERIOR A 180 DIAS DA DATA DE ENTRADA                                       '
			Case cMotivo =='57'     '
				cRet:= RTrim(cOcorr)+'-'+ 'DATA DE VENCTO CEP S� DEPOSIT�RIA BCO DO BRASIL COM VENCTO INFERIOR A 8 DIAS        '
			Case cMotivo =='60'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO ABATIMENTO INV�LIDO                                                        '
			Case cMotivo =='61'     
				cRet:= RTrim(cOcorr)+'-'+ 'JUROS DE MORA JUROS DE MORA MAIOR QUE O PERMITIDO                                   '
			Case cMotivo =='62'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO DESCONTO MAIOR QUE VALOR DO T�TULO                                         '
			Case cMotivo =='63'     
				cRet:= RTrim(cOcorr)+'-'+ 'DESCONTO DE ANTECIPA��O VALOR DA IMPORT�NCIA POR DIA DE DESCONTO (IDD) N�O PERMITIDO'
			Case cMotivo =='64'     
				cRet:= RTrim(cOcorr)+'-'+ 'DATA DE EMISS�O DO T�TULO INV�LIDA                                                  '
			Case cMotivo =='65'     
				cRet:= RTrim(cOcorr)+'-'+ 'TAXA FINANCTO TAXA INV�LIDA (VENDOR)                                                '
			Case cMotivo =='66'     
				cRet:= RTrim(cOcorr)+'-'+ 'INVALIDA/FORA DE PRAZO DE OPERA��O (M�NIMO OU M�XIMO)                               '
			Case cMotivo =='67'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR/QTIDADE VALOR DO T�TULO/QUANTIDADE DE MOEDA INV�LIDO                          '
			Case cMotivo =='68'     
				cRet:= RTrim(cOcorr)+'-'+ 'CARTEIRA INV�LIDA OU N�O CADASTRADA NO INTERC�MBIO DA COBRAN�A                      '
			Case cMotivo =='69'     
				cRet:= RTrim(cOcorr)+'-'+ 'CARTEIRA CARTEIRA INV�LIDA PARA T�TULOS COM RATEIO DE CR�DITO                       '
			Case cMotivo =='70'     
				cRet:= RTrim(cOcorr)+'-'+ 'BENEFICI�RIO N�O CADASTRADO PARA FAZER RATEIO DE CR�DITO                            '
			Case cMotivo =='78'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA/CONTA DUPLICIDADE DE AG�NCIA/CONTA BENEFICI�RIA DO RATEIO DE CR�DITO        '
			Case cMotivo =='80'     
				cRet:= RTrim(cOcorr)+'-'+ 'QUANTIDADE DE CONTAS BENEFICI�RIAS DO RATEIO MAIOR DO QUE O PERMITIDO (M�XIMO DE 30 '
			Case cMotivo =='81'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA/CONTA CONTA PARA RATEIO DE CR�DITO INV�LIDA / N�O PERTENCE AO ITA�          '
			Case cMotivo =='82'     
				cRet:= RTrim(cOcorr)+'-'+ 'DESCONTO/ABATIMENTO N�O PERMITIDO PARA T�TULOS COM RATEIO DE CR�DITO                '
			Case cMotivo =='83'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO T�TULO VALOR DO T�TULO MENOR QUE A SOMA DOS VALORES ESTIPULADOS PARA RATEIO'
			Case cMotivo =='84'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA/CONTA BENEFICI�RIA DO RATEIO � A CENTRALIZADORA DE CR�DITO DO BENEFICI�RIO  '
			Case cMotivo =='85'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA/CONTA AG�NCIA/CONTA DO BENEFICI�RIO � CONTRATUAL / RATEIO DE CR�DITO N�O PER'
			Case cMotivo =='86'     
				cRet:= RTrim(cOcorr)+'-'+ 'C�DIGO DO TIPO DE VALOR INV�LIDO / N�O PREVISTO PARA T�TULOS COM RATEIO DE CR�DITO  '
			Case cMotivo =='87'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG�NCIA/CONTA REGISTRO TIPO 4 SEM INFORMA��O DE AG�NCIAS/CONTAS BENEFICI�RIAS DO RAT'
			Case cMotivo =='90'     
				cRet:= RTrim(cOcorr)+'-'+ 'COBRAN�A MENSAGEM - N�MERO DA LINHA DA MENSAGEM INV�LIDO OU QUANTIDADE DE LINHAS EXC'
			Case cMotivo =='97'     
				cRet:= RTrim(cOcorr)+'-'+ 'SEM MENSAGEM COBRAN�A MENSAGEM SEM MENSAGEM (S� DE CAMPOS FIXOS), POR�M COM REGISTRO'
			Case cMotivo =='98'     
				cRet:= RTrim(cOcorr)+'-'+ 'REGISTRO MENSAGEM SEM FLASH CADASTRADO OU FLASH INFORMADO DIFERENTE DO CADASTRADO   '
			Case cMotivo =='99'     
				cRet:= RTrim(cOcorr)+'-'+ 'FLASH INV�LIDO CONTA DE COBRAN�A COM FLASH CADASTRADO E SEM REGISTRO DE MENSAGEM COR'
		EndCase
		
	Next nCont			

Else
	
	cRet:=PARAMIXB[1]
	
EndIf

return(cRet)