#include "protheus.ch"

/*
Funcao      : F650DESCR
Retorno     : lRet
Objetivos   : Informar o motivo das Entradas Rejeitadas.
Autor       : João Silva 
Data/Hora   : 31/10/2013
Revisão		: 
Data/Hora   : 
Módulo      : Financeiro 
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
				cRet:= RTrim(cOcorr)+'-'+ 'SIGLA DO ESTADO INVÁLIDA                                                            '
			Case cMotivo =='05'     
				cRet:= RTrim(cOcorr)+'-'+ 'DATA VENCIMENTO PRAZO DA OPERAÇÃO MENOR QUE PRAZO MÍNIMO OU MAIOR QUE O MÁXIMO      '
			Case cMotivo =='07'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO TÍTULO MAIOR QUE 10.000.000,00                                             '
			Case cMotivo =='08'    
				cRet:= RTrim(cOcorr)+'-'+ 'NOME DO PAGADOR NÃO INFORMADO OU DESLOCADO                                          '
			Case cMotivo =='09'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA ENCERRADA                                                                   '
			Case cMotivo =='10'     
				cRet:= RTrim(cOcorr)+'-'+ 'LOGRADOURO NÃO INFORMADO OU DESLOCADO                                               '
			Case cMotivo =='11'    
				cRet:= RTrim(cOcorr)+'-'+ 'CEP NÃO NUMÉRICO OU CEP INVÁLIDO                                                    '
			Case cMotivo =='12'   
				cRet:= RTrim(cOcorr)+'-'+ 'SACADOR / AVALISTA NOME NÃO INFORMADO OU DESLOCADO (BANCOS CORRESPONDENTES)         '
			Case cMotivo =='13'     
				cRet:= RTrim(cOcorr)+'-'+ 'CEP INCOMPATÍVEL COM A SIGLA DO ESTADO                                              '
			Case cMotivo =='14'     
				cRet:= RTrim(cOcorr)+'-'+ 'NOSSO NÚMERO JÁ REGISTRADO NO CADASTRO DO BANCO OU FORA DA FAIXA       '
			Case cMotivo =='15'     
				cRet:= RTrim(cOcorr)+'-'+ 'NOSSO NÚMERO EM DUPLICIDADE NO MESMO MOVIMENTO                                      '
			Case cMotivo =='18'    
				cRet:= RTrim(cOcorr)+'-'+ 'DATA DE ENTRADA DATA DE ENTRADA INVÁLIDA PARA OPERAR COM ESTA CARTEIRA              '
			Case cMotivo =='19'    
				cRet:= RTrim(cOcorr)+'-'+ 'OCORRÊNCIA INVÁLIDA 21 AG. COBRADORA CARTEIRA NÃO ACEITA DEPOSITÁRIA CORRESPONDENTE '
			Case cMotivo =='22'     
				cRet:= RTrim(cOcorr)+'-'+ 'CARTEIRA NÃO PERMITIDA (NECESSÁRIO CADASTRAR FAIXA LIVRE)                           '
			Case cMotivo =='26'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA/CONTA AGÊNCIA/CONTA NÃO LIBERADA PARA OPERAR COM COBRANÇA                   '
			Case cMotivo =='27'     
				cRet:= RTrim(cOcorr)+'-'+ 'CNPJ DO BENEFICIÁRIO INAPTO DEVOLUÇÃO DE TÍTULO EM GARANTIA                         '
			Case cMotivo =='29'     
				cRet:= RTrim(cOcorr)+'-'+ 'CÓDIGO EMPRESA CATEGORIA DA CONTA INVÁLIDA                                          '
			Case cMotivo =='30'     
				cRet:= RTrim(cOcorr)+'-'+ 'ENTRADAS BLOQUEADAS, CONTA SUSPENSA EM COBRANÇA                                     '
			Case cMotivo =='31'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA/CONTA CONTA NÃO TEM PERMISSÃO PARA PROTESTAR (CONTATE SEU GERENTE)          '
			Case cMotivo =='35'     
				cRet:= RTrim(cOcorr)+'-'+ 'IOF MAIOR QUE 5%                                                                    '
			Case cMotivo =='36'     
				cRet:= RTrim(cOcorr)+'-'+ 'QTDADE DE MOEDA QUANTIDADE DE MOEDA INCOMPATÍVEL COM VALOR DO TÍTULO                '
			Case cMotivo =='37'     
				cRet:= RTrim(cOcorr)+'-'+ 'NÃO NUMÉRICO OU IGUAL A ZEROS                                                       '
			Case cMotivo =='42'     
				cRet:= RTrim(cOcorr)+'-'+ 'NOSSO NÚMERO NOSSO NÚMERO FORA DE FAIXA                                             '
			Case cMotivo =='52'     
				cRet:= RTrim(cOcorr)+'-'+ 'EMPRESA NÃO ACEITA BANCO CORRESPONDENTE                                             '
			Case cMotivo =='53'     
				cRet:= RTrim(cOcorr)+'-'+ 'AG. COBRADORA EMPRESA NÃO ACEITA BANCO CORRESPONDENTE - COBRANÇA MENSAGEM           '
			Case cMotivo =='54'     
				cRet:= RTrim(cOcorr)+'-'+ 'BANCO CORRESPONDENTE - TÍTULO COM VENCIMENTO INFERIOR A 15 DIAS                     '
			Case cMotivo =='55'     
				cRet:= RTrim(cOcorr)+'-'+ 'DEP/BCO CORRESP CEP NÃO PERTENCE À DEPOSITÁRIA INFORMADA                            '
			Case cMotivo =='56'     
				cRet:= RTrim(cOcorr)+'-'+ 'VENCTO SUPERIOR A 180 DIAS DA DATA DE ENTRADA                                       '
			Case cMotivo =='57'     '
				cRet:= RTrim(cOcorr)+'-'+ 'DATA DE VENCTO CEP SÓ DEPOSITÁRIA BCO DO BRASIL COM VENCTO INFERIOR A 8 DIAS        '
			Case cMotivo =='60'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO ABATIMENTO INVÁLIDO                                                        '
			Case cMotivo =='61'     
				cRet:= RTrim(cOcorr)+'-'+ 'JUROS DE MORA JUROS DE MORA MAIOR QUE O PERMITIDO                                   '
			Case cMotivo =='62'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO DESCONTO MAIOR QUE VALOR DO TÍTULO                                         '
			Case cMotivo =='63'     
				cRet:= RTrim(cOcorr)+'-'+ 'DESCONTO DE ANTECIPAÇÃO VALOR DA IMPORTÂNCIA POR DIA DE DESCONTO (IDD) NÃO PERMITIDO'
			Case cMotivo =='64'     
				cRet:= RTrim(cOcorr)+'-'+ 'DATA DE EMISSÃO DO TÍTULO INVÁLIDA                                                  '
			Case cMotivo =='65'     
				cRet:= RTrim(cOcorr)+'-'+ 'TAXA FINANCTO TAXA INVÁLIDA (VENDOR)                                                '
			Case cMotivo =='66'     
				cRet:= RTrim(cOcorr)+'-'+ 'INVALIDA/FORA DE PRAZO DE OPERAÇÃO (MÍNIMO OU MÁXIMO)                               '
			Case cMotivo =='67'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR/QTIDADE VALOR DO TÍTULO/QUANTIDADE DE MOEDA INVÁLIDO                          '
			Case cMotivo =='68'     
				cRet:= RTrim(cOcorr)+'-'+ 'CARTEIRA INVÁLIDA OU NÃO CADASTRADA NO INTERCÂMBIO DA COBRANÇA                      '
			Case cMotivo =='69'     
				cRet:= RTrim(cOcorr)+'-'+ 'CARTEIRA CARTEIRA INVÁLIDA PARA TÍTULOS COM RATEIO DE CRÉDITO                       '
			Case cMotivo =='70'     
				cRet:= RTrim(cOcorr)+'-'+ 'BENEFICIÁRIO NÃO CADASTRADO PARA FAZER RATEIO DE CRÉDITO                            '
			Case cMotivo =='78'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA/CONTA DUPLICIDADE DE AGÊNCIA/CONTA BENEFICIÁRIA DO RATEIO DE CRÉDITO        '
			Case cMotivo =='80'     
				cRet:= RTrim(cOcorr)+'-'+ 'QUANTIDADE DE CONTAS BENEFICIÁRIAS DO RATEIO MAIOR DO QUE O PERMITIDO (MÁXIMO DE 30 '
			Case cMotivo =='81'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA/CONTA CONTA PARA RATEIO DE CRÉDITO INVÁLIDA / NÃO PERTENCE AO ITAÚ          '
			Case cMotivo =='82'     
				cRet:= RTrim(cOcorr)+'-'+ 'DESCONTO/ABATIMENTO NÃO PERMITIDO PARA TÍTULOS COM RATEIO DE CRÉDITO                '
			Case cMotivo =='83'     
				cRet:= RTrim(cOcorr)+'-'+ 'VALOR DO TÍTULO VALOR DO TÍTULO MENOR QUE A SOMA DOS VALORES ESTIPULADOS PARA RATEIO'
			Case cMotivo =='84'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA/CONTA BENEFICIÁRIA DO RATEIO É A CENTRALIZADORA DE CRÉDITO DO BENEFICIÁRIO  '
			Case cMotivo =='85'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA/CONTA AGÊNCIA/CONTA DO BENEFICIÁRIO É CONTRATUAL / RATEIO DE CRÉDITO NÃO PER'
			Case cMotivo =='86'     
				cRet:= RTrim(cOcorr)+'-'+ 'CÓDIGO DO TIPO DE VALOR INVÁLIDO / NÃO PREVISTO PARA TÍTULOS COM RATEIO DE CRÉDITO  '
			Case cMotivo =='87'     
				cRet:= RTrim(cOcorr)+'-'+ 'AGÊNCIA/CONTA REGISTRO TIPO 4 SEM INFORMAÇÃO DE AGÊNCIAS/CONTAS BENEFICIÁRIAS DO RAT'
			Case cMotivo =='90'     
				cRet:= RTrim(cOcorr)+'-'+ 'COBRANÇA MENSAGEM - NÚMERO DA LINHA DA MENSAGEM INVÁLIDO OU QUANTIDADE DE LINHAS EXC'
			Case cMotivo =='97'     
				cRet:= RTrim(cOcorr)+'-'+ 'SEM MENSAGEM COBRANÇA MENSAGEM SEM MENSAGEM (SÓ DE CAMPOS FIXOS), PORÉM COM REGISTRO'
			Case cMotivo =='98'     
				cRet:= RTrim(cOcorr)+'-'+ 'REGISTRO MENSAGEM SEM FLASH CADASTRADO OU FLASH INFORMADO DIFERENTE DO CADASTRADO   '
			Case cMotivo =='99'     
				cRet:= RTrim(cOcorr)+'-'+ 'FLASH INVÁLIDO CONTA DE COBRANÇA COM FLASH CADASTRADO E SEM REGISTRO DE MENSAGEM COR'
		EndCase
		
	Next nCont			

Else
	
	cRet:=PARAMIXB[1]
	
EndIf

return(cRet)