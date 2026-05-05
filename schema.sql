-- Script para criação das tabelas no MySQL.
-- Execute este arquivo no seu banco de dados MySQL para preparar as tabelas necessárias.

CREATE TABLE IF NOT EXISTS noticias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo TEXT,
  categoria TEXT,
  autor TEXT,
  data_pub TEXT,
  status TEXT,
  resumo TEXT,
  conteudo TEXT,
  img_url TEXT
);

CREATE TABLE IF NOT EXISTS licencas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  processo TEXT,
  objeto TEXT,
  modalidade TEXT,
  valor TEXT,
  abertura TEXT,
  status TEXT
);

CREATE TABLE IF NOT EXISTS obras (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome TEXT,
  secretaria TEXT,
  valor TEXT,
  inicio TEXT,
  progresso INT,
  status TEXT,
  descricao TEXT
);

-- Inserindo alguns dados de exemplo (opcional)
INSERT INTO noticias (titulo, categoria, autor, data_pub, status, resumo, conteudo) VALUES
('Portal da Transparencia atualizado', 'Transparencia', 'Admin', '30/04/2025', 'Publicada', 'O Municipio cumpre determinacoes da Acao...', 'Conteudo completo...'),
('Obra de pavimentacao no Bairro Centro', 'Obras', 'Comunicacao', '25/04/2025', 'Publicada', 'Pavimentacao de 2,4km...', 'Conteudo completo...');

INSERT INTO licencas (processo, objeto, modalidade, valor, abertura, status) VALUES
('012/2025', 'Aquisicao de medicamentos - Farmacia Basica', 'Pregao Eletronico', 'R$ 380.000', '15/05/2025', 'Aberto'),
('011/2025', 'Reforma do Ginasio Municipal', 'Concorrencia', 'R$ 920.000', '08/05/2025', 'Aberto');

INSERT INTO obras (nome, secretaria, valor, inicio, progresso, status, descricao) VALUES
('Pavimentacao Bairro Centro - Rua XV', 'Obras', 'R$ 280.000', 'Abr 2025', 38, 'Em andamento', 'Pavimentacao de 2,4 km...'),
('Reforma UBS Central', 'Saude', 'R$ 145.000', 'Mar 2025', 72, 'Em andamento', 'Reforma e ampliacao da UBS Central...');
