# Análise Inicial de Dados Sujeitos à LGPD

Este documento foi elaborado a partir dos arquivos em `docs/database/md`.

Objetivo desta etapa:
- listar quais dados podem estar sujeitos à LGPD;
- apontar riscos de exposição;
- registrar a direção preferida para tratamento em homologação: anonimização com dados fictícios.

## Resumo executivo

Há forte indício de presença de dados pessoais, dados cadastrais, credenciais de acesso, conteúdo livre digitado por usuários e anexos. Em alguns pontos, esses dados também aparecem consolidados em views, o que aumenta a superfície de exposição.

A opção mais adequada para o ambiente de homologação, considerando a diretriz fornecida, é substituir dados reais por dados fictícios consistentes, preservando formato e utilidade operacional, em vez de preencher campos com `NULL` ou usar identificadores previsíveis como `CLIENTE + ID`.

## Grupos de dados com potencial incidência de LGPD

### 1. Identificação direta de pessoas físicas ou representantes

Campos e estruturas com maior risco:
- `clientes`: `NOMEREPRESENTANTE`, `CPFREPRESENTANTE`, `DATANASCREPRESENTANTE`, `EMAIL`, `EMAILCOMERCIAL`, `EMAILFINANCEIRO`, `cli_contatos`, `cli_logins`, `SENHAPORTAL`
- `clientesContatos`: `NOME`, `TELEFONE`, `EMAIL`
- `CLIENTESUSUARIOS`: `EMAIL`, `USUARIO`, `SENHA`, `TELEFONE`, `WHATSAPP`, `CODIGOTEMPORARIO`, `DATAULTIMOACESSO`
- `UserDetalhes`: `email`, `userName`, `user`, `senha`, `codigotemporario`, `ultimo_login`
- `PROPOSTASCONTATOS`: `NOME`, `TELEFONE`, `EMAIL`
- `leads_fenabrave`: `nome`, `email`, `telefone`

Risco:
- identificação direta de titulares;
- contato indevido;
- exposição de credenciais ou fluxos de autenticação;
- reidentificação fácil mesmo em base parcial.

### 2. Documentos e identificadores cadastrais

Campos e estruturas com maior risco:
- `clientes`: `CNPJCPF`, `cli_cpf`
- `PROPOSTAS`: `CNPJCPF`
- `PROPOSTASCNPJ`: `CNPJCPF`
- `fornecedores`: `CNPJCPF`
- `FORNECEDORESFINANCEIRO`: `CNPJCPF`
- `dadosMTR`: `CNPJCPFDESTINADOR`, `CNPJCPFTRANSPORTADORA`, `CNPJCPFGERADOR`
- views como `LISTARUSUARIOS`, `LISTARDEMANDAS`, `DEMANDASPORCLIENTE`, `DADOSCARDS`, `LISTAMTR`, `LISTAMTRGRUPO`

Risco:
- exposição de CPF e CNPJ vinculados a nomes, empresas ou contexto operacional;
- cruzamento com bases externas;
- rastreabilidade de clientes, fornecedores, motoristas, representantes e responsáveis.

### 3. Endereço e localização

Campos e estruturas com maior risco:
- `clientes`: `UF`, `MUNICIPIO`, `BAIRRO`, `ENDERECO`, `NUMERO`, `COMPLEMENTO`, `CEP`
- `PROPOSTAS`: `ENDERECO`
- `PROPOSTASCNPJ`: `ENDERECO`
- `fornecedores`: `CEP`, `UF`, `MUNICIPIO`, `ENDERECO`, `NUMERO`, `COMPLEMENTO`, `BAIRRO`
- `FORNECEDORESFINANCEIRO`: mesmos campos de endereço

Risco:
- localização de pessoas físicas, representantes ou estabelecimentos;
- reidentificação por combinação de endereço com documento, nome, email ou telefone.

### 4. Credenciais e segredos operacionais

Campos e estruturas com maior risco:
- `clientesCredenciais`: `USUARIO`, `SENHA`, `USUARIO2`, `OBSERVACAO`
- `clientes`: `SENHAPORTAL`
- `CLIENTESUSUARIOS`: `SENHA`, `CODIGOTEMPORARIO`
- `UserDetalhes`: `senha`, `codigotemporario`
- `DADOSINTEGRACAOMTR`: `USUARIO`, `SENHA`

Risco:
- acesso indevido a portais, integrações e contas de usuário;
- reutilização de senha em outros ambientes;
- vazamento de segredos mesmo quando o dado não é estritamente pessoal.

### 5. Conteúdo livre digitado por usuários

Campos e estruturas com maior risco:
- `demandas`: `OBSERVACOES`
- `PROPOSTAS`: `OBSERVACOESDAPROPOSTA`, `OBSERVACOESINTERNAS`, `OBSERVACOESFINANCEIRAS`, `RESUMOPROPOSTA`
- `planoAcaoItem`: `OBSERVACAO`
- `planoAcaoAnexos`: `COMENTARIO`
- `demandasAnexos`: `COMENTARIO`
- `avaliacoes`: `OBSERVACAO`
- `avaliacoesAnexos`: `COMENTARIO`
- `LOGS`: `TEXTO`
- várias tabelas `CLIDEMANDAS*`: `OBSERVACOES`

Risco:
- esses campos podem conter nomes, emails, telefones, documentos, histórico de atendimento, informações financeiras, dados internos e até dados sensíveis digitados manualmente;
- é uma das áreas com maior incerteza e maior probabilidade de vazamento não mapeado por nome de coluna.

### 6. Anexos, caminhos e links para arquivos

Campos e estruturas com maior risco:
- `documentos`: `LINK`, `LINKDOWNLOAD`, `NOMEARQUIVO`, `PATHLOCAL`
- `CLIDEMANDASANEXOS`: `CAMINHO`, `NOMEARQUIVO`
- `dadosMTRAnexo`: `LINK`, `NOMEARQUIVO`
- `demandasAnexos`: `URL`, `NOMEARQUIVO`
- `KANBANANEXOS`: `FILEURL`, `DESCRICAO`
- `planoAcaoAnexos`: `PATHANEXO`, `COMENTARIO`
- `avaliacoes`, `avaliacoesAnexos`: `PATHANEXO`, `COMENTARIO`
- `dadosMTR`: `NOMEARQUIVOMTR`, `NOMEARQUIVOCDF`, `NOMEARQUIVONOTAPDF`, `NOMEARQUIVONOTAXML`

Risco:
- o próprio arquivo pode conter dados pessoais ou sensíveis;
- o nome do arquivo pode expor cliente, documento, pessoa ou conteúdo;
- links e caminhos podem revelar estrutura interna de armazenamento.

### 7. Views que ampliam a exposição

Views com maior concentração de dados:
- `LISTARUSUARIOS`
- `LISTARDOCUMENTOS`
- `LISTARDEMANDAS`
- `LISTAMTR`
- `LISTAMTRGRUPO`
- `DEMANDASPORRESPONSAVEL`
- `DEMANDASPORCLIENTE`
- `aniversariosdetalhes`

Risco:
- centralizam múltiplos atributos em uma única consulta;
- facilitam exportação, consulta manual e uso por terceiros;
- aumentam o impacto de uma exposição acidental.

## Tabelas com maior prioridade de atenção

Prioridade alta:
- `clientes`
- `clientesContatos`
- `clientesCredenciais`
- `CLIENTESUSUARIOS`
- `UserDetalhes`
- `PROPOSTAS`
- `PROPOSTASCONTATOS`
- `PROPOSTASCNPJ`
- `documentos`
- `dadosMTR`
- `DADOSINTEGRACAOMTR`
- `leads_fenabrave`

Prioridade alta por conteúdo não estruturado ou anexos:
- `demandas`
- `demandasAnexos`
- `CLIDEMANDASANEXOS`
- `planoAcaoAnexos`
- `avaliacoes`
- `avaliacoesAnexos`
- `KANBANANEXOS`
- `LOGS`

Prioridade média:
- `fornecedores`
- `FORNECEDORESFINANCEIRO`
- tabelas `CLIDEMANDAS*`

## Direção recomendada para homologação

Direção escolhida para as próximas etapas:
- preferir anonimização por substituição com dados fictícios;
- evitar padrão baseado em `ID` concatenado com texto;
- evitar nulidade massiva quando isso prejudicar testes, telas, integrações e validações;
- manter coerência interna entre tabelas relacionadas.

### Motivos para preferir dados fictícios

- preserva melhor o comportamento do sistema;
- reduz quebra em regras de validação, busca, filtros e telas;
- evita aparência artificial demais em homologação;
- diminui o risco de reidentificação por padrões previsíveis;
- permite testar fluxos com emails, telefones, documentos e nomes em formato plausível, mas não reais.

## Pontos de atenção adicionais

- Campos `jsonb` como `cli_contatos` e `cli_logins` merecem inspeção específica, porque podem concentrar dados pessoais e credenciais fora do modelo tabular principal.
- Campos de observação, comentário, descrição e log exigem cuidado especial, pois podem conter dados pessoais não padronizados.
- Anexos e links de arquivos não devem ser tratados só pelo metadado; o conteúdo real do arquivo pode carregar o maior risco.
- Algumas estruturas parecem misturar dados corporativos e dados de pessoas físicas. Mesmo quando o contexto é empresarial, pode haver incidência de LGPD se houver representante, contato, usuário, motorista ou responsável identificado.

## Escopo desta entrega

Esta entrega apenas documenta:
- quais dados podem estar sujeitos à LGPD;
- os principais riscos de exposição;
- a decisão inicial de seguir com anonimização por dados fictícios.

Não foram feitos nesta etapa:
- script de anonimização;
- mapeamento campo a campo de transformação;
- alterações no banco;
- tratamento de anexos;
- validação de exceções de negócio.

<!-- AUTO:UNMENTIONED_FIELDS:START -->
## Campos restantes não mencionados explicitamente

Total identificado via JSON e nao citado explicitamente no texto: 347

Lista automatica gerada a partir de `docs/database/json`:

- `ACAO`
- `ACAOREALIZADA`
- `ACESSOELOVERDE`
- `AGUA`
- `AMBIENTE`
- `ANOTACOES`
- `ANTIGO`
- `APROVADO`
- `ARQUIVADA`
- `ASPECTO`
- `ATIVIDADE`
- `ativo`
- `ATIVO`
- `BENCHMARK`
- `capitulo`
- `cargo`
- `CARGO`
- `CATEGORIA`
- `CDF`
- `CERTIFICADOEMITIDO`
- `checklist`
- `CLASSE`
- `cli_nklgama`
- `cli_razaoSocial`
- `cli_segmento`
- `cli_status`
- `cliente`
- `CLIENTEGAMA`
- `CLIENTEPORTAL`
- `CNPJCPFCLIENTE`
- `CNPJCPFFORNECEDOR`
- `CODIGO`
- `CODIGOCONTA`
- `CODIGOKLGAMA`
- `CODKLGAMA`
- `COMENTARIOS`
- `COMPLETO`
- `COMPLEXIDADE`
- `CONCLUIDA`
- `CONCLUIDO`
- `CONFORME`
- `CONFORMEUSO`
- `CONFORMIDADE`
- `CONSUMOESTIMADO`
- `CONTA`
- `CONTAPAI`
- `cor`
- `COR`
- `CORSITUACAOEXECUCAO`
- `CORSTATUS`
- `count`
- `created_at`
- `CUSTO`
- `data`
- `DATA`
- `DATAAVALIACAO`
- `DATACADASTRO`
- `DATACOLETA`
- `DATACONCLUSAO`
- `DATACRIACAO`
- `DATACUSTO`
- `DATAEMISSAO`
- `DATAENCERRAMENTO`
- `DATAENTRADA`
- `DATAENTREGA`
- `DATAEXECUCAO`
- `datahoracodigotemp`
- `DATAHORACODIGOTEMP`
- `DATAINICIO`
- `DATALEMBRETE`
- `DATALIBERACAO`
- `DATAMOVIMENTO`
- `DATAPAGAMENTO`
- `DATAPREVISTA`
- `DATAPROXIMOMONITORAMENTO`
- `DATARECEBIMENTO`
- `DATAREFERENCIA`
- `DATATRANSMISSAO`
- `DATAUPLOAD`
- `DATAVALIDADE`
- `DATAVENCIMENTO`
- `DESCDETALHADA`
- `DESCPRECO`
- `DESCQUESTAO`
- `descresiduo`
- `DESCRESIDUO`
- `descresumida`
- `DESCRESUMIDA`
- `descricao`
- `DESCRICAOACAO`
- `descricaocapitulo`
- `descsubcapitulo`
- `DIASENTREPARC`
- `DIFERENCA`
- `DOCUMENTO`
- `EDITADO`
- `emaildemanda`
- `empresa`
- `ENERGIA`
- `ENERGIACONSUMIDA`
- `ENQUADRAMENTO`
- `ENVIADOPOR`
- `enviaemail`
- `EQUIPAMENTO`
- `ESTADOFISICO`
- `ESTADOTELA`
- `FONTEEMISSAO`
- `form`
- `FORMAPAGTO`
- `FREQUENCIA`
- `FUNCAO`
- `FUNCIONALIDADEPRONTA`
- `GERANOTAFISCAL`
- `GERARFINANCEIRO`
- `grupo`
- `GRUPO`
- `HODOMETRO`
- `HORARIO`
- `id`
- `IDAVALIACAO`
- `IDCARD`
- `IDCENTROCUSTO`
- `IDCLIENTE`
- `IDCLIENTEREF`
- `IDCOLUNA`
- `IDCONDICAOPAGTO`
- `IDCONDPAGTO`
- `IDDEMANDA`
- `IDDEMANDAPRINCIPAL`
- `IDFORNECEDOR`
- `IDGRUPO`
- `IDITEM`
- `IDITEMPLANO`
- `IDKANBAN`
- `IDMTR`
- `IDORGAO`
- `IDPAGAR`
- `idperfil`
- `IDPERFIL`
- `IDPLANO`
- `IDPLANOCONTA`
- `IDPROCESSO`
- `IDPROPOSTA`
- `IDRECEBER`
- `IDRESIDUO`
- `IDSEGMENTO`
- `IDSETOR`
- `IDSITUACAO`
- `IDSITUACAOEXECUCAO`
- `IDTAG`
- `IDTELA`
- `IDTIPODOCUMENTO`
- `IDUSUARIO`
- `IDUSUARIOCAD`
- `IDUSUARIORESP`
- `IMPACTOS`
- `INDICADOR`
- `interesse`
- `ip_address`
- `ITEMCONFIRMADO`
- `LEMBRARANTES`
- `LIBERADO`
- `LIMITE`
- `LIMITEMAX`
- `LIMITEMAXIMO`
- `LIMITEREFERENCIA`
- `LINKANEXO`
- `LINKCDF`
- `LINKMTR`
- `LINKPDFNOTA`
- `LINKXMLNOTA`
- `LISTAEMPRESAS`
- `LOCAL`
- `LOCALCOLETA`
- `material_solicitado`
- `MEDIAAVALIACAO`
- `MEDIAINDICADOR`
- `MENUPAI`
- `MESANO`
- `META`
- `METODO`
- `MODO`
- `month`
- `MOTIVOCANCELAMENTO`
- `MULTIEMP`
- `NIVEL`
- `NMCLIENTE`
- `NMFORNECEDOR`
- `NMPROCESSO`
- `NMSITUACAO`
- `NMSITUACAOEXECUCAO`
- `NMTIPO`
- `NMUSUARIO`
- `NOMEDESTINADOR`
- `NOMEEVENTO`
- `NOMEFANTASIA`
- `NOMEGERADOR`
- `NOMEGRUPO`
- `NOMEICONE`
- `NOMEMOTORISTA`
- `NOMERESPONSAVEL`
- `NOMEROTA`
- `NOMETELA`
- `NOMETELAREDUZIDO`
- `NOMETRANSPORTADORA`
- `NOTAPONDERADA`
- `NOTAQUESTAO`
- `NOTASECAO`
- `NUMCNPJ`
- `NUMEROMTR`
- `NUMEROOCORRENCIA`
- `NUMEROPARCELA`
- `NUMEROPARCELAS`
- `NUMEROPROPOSTA`
- `NUMEROVERSAO`
- `OBSPERGUNTA`
- `ORDEM`
- `ORDEMEXECUCAO`
- `ORDEMITEM`
- `ORDEMSETOR`
- `orgao`
- `origem`
- `ORIGEM`
- `OTIMIZADO`
- `papel`
- `PARAMETRO`
- `percagua`
- `percar`
- `PERCENTUAL`
- `PERCESPERADO`
- `percgeral`
- `percica`
- `percidg`
- `percido`
- `PERCREAL`
- `percsolo`
- `perigoso`
- `PERMISSAO`
- `PERMISSAOALTERAR`
- `PERMISSAOCONSULTAR`
- `PERMISSAOEXCLUIR`
- `PERMISSAOINCLUIR`
- `PESOICA`
- `PESOIDG`
- `PESOIDO`
- `PESOINDICADOR`
- `PESOSECAO`
- `PESSOA`
- `PLACAVEICULO`
- `POSSIVEISCONCORRENTES`
- `PREVISAOINICIO`
- `PRIMEIROVENCIMENTO`
- `PRIORIDADE`
- `PRIORIDADEINTERNA`
- `processo`
- `PRODUTO`
- `PROXIMOVENCIMENTO`
- `QTDE`
- `QTDECDF`
- `QTDECONSUMO`
- `QTDEEMP`
- `QTDEFATURA`
- `QTDERESIDUO`
- `QTDESEMCDF`
- `QTDETONELADA`
- `QTDETOTAL`
- `QTDEUNIDADE`
- `QTDEUNITARIO`
- `QTDPARCELAS`
- `QUANTIDADE`
- `RAZAOSOCIAL`
- `recebeemailproposta`
- `RECORRENCIA`
- `REFERENCIA`
- `residuo`
- `RESIDUO`
- `RESPONSAVEL`
- `RESULTADO`
- `REVISAO`
- `SECAO`
- `secoes`
- `segmento`
- `seguimento`
- `SEQUENCIA`
- `SEQUENCIAOCORRENCIA`
- `SERVICOS`
- `SETOR`
- `SITUACAO`
- `SOLICITANTE`
- `status`
- `subcapitulo`
- `SUBCATEGORIA`
- `SUBMENU`
- `TAXACREA`
- `TAXAORGAO`
- `TECNICO`
- `TECNOLOGIAFINAL`
- `temp`
- `teste`
- `tipo`
- `TIPO`
- `TIPOANEXO`
- `TIPOCOBRANCA`
- `TIPOCUSTO`
- `TIPODEMANDA`
- `TIPOLANCAMENTO`
- `TIPOLEMBRETE`
- `tipoPercentual`
- `TIPOTAXA`
- `TIPOVENCIMENTO`
- `TITULO`
- `TOTAL`
- `total_clients`
- `unidade`
- `UNIDADE`
- `UNIDADEDESC`
- `UNIDADEMTR`
- `updated_at`
- `URGENTE`
- `URLBASE`
- `user_agent`
- `usuarioadmin`
- `USUARIOALTERACAO`
- `USUARIOCADASTRO`
- `USUARIOKLGAMA`
- `USUARIOMASTER`
- `utm_campaign`
- `utm_medium`
- `utm_source`
- `uuid`
- `VALOR`
- `VALORCALCULADO`
- `VALORDENSIDADE`
- `VALORDESCONTO`
- `VALORDESPESA`
- `VALORENTRADA`
- `VALORFATURA`
- `VALORFECHADO`
- `VALORPAGO`
- `VALORPROPOSTO`
- `VALORRECEITA`
- `VALORTOTAL`
- `VARIACAO`
- `VERSAOLIBERACAO`
- `VOLUME`
- `WPP`
- `year`
<!-- AUTO:UNMENTIONED_FIELDS:END -->
