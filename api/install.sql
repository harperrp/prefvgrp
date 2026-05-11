CREATE TABLE IF NOT EXISTS usuarios (
  id VARCHAR(64) PRIMARY KEY,
  nome VARCHAR(160) NOT NULL,
  usuario VARCHAR(80) NOT NULL UNIQUE,
  senha_hash VARCHAR(255) NOT NULL,
  perfil VARCHAR(80) NOT NULL DEFAULT 'Administrador',
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS portal_conteudo (
  id VARCHAR(80) PRIMARY KEY,
  modulo VARCHAR(40) NOT NULL,
  titulo VARCHAR(255) NULL,
  status VARCHAR(60) NULL,
  ordem INT NOT NULL DEFAULT 0,
  data_json JSON NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_modulo (modulo),
  INDEX idx_status (status),
  INDEX idx_ordem (ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO usuarios (id, nome, usuario, senha_hash, perfil)
VALUES ('usr_admin', 'Administrador', 'admin', '$2y$12$YHfoo7IfKh0qC.p9aWVdZeSq/gy3ttd84o8SwGlWBqxuTfNSDP2nm', 'Administrador')
ON DUPLICATE KEY UPDATE nome = VALUES(nome), perfil = VALUES(perfil);

INSERT INTO portal_conteudo (id, modulo, titulo, status, data_json) VALUES
('not_1','noticias','Portal da Transparência atualizado — LAI 12.527/2011','Publicada', JSON_OBJECT('id','not_1','titulo','Portal da Transparência atualizado — LAI 12.527/2011','categoria','Transparência','autor','Admin','data','30/04/2025','status','Publicada','resumo','Portal atualizado com dados da LAI e atalhos de acesso ao cidadão.')),
('lic_1','licitacoes','Aquisição de medicamentos — Farmácia Básica','Aberto', JSON_OBJECT('id','lic_1','numero','012/2025','objeto','Aquisição de medicamentos — Farmácia Básica','modalidade','Pregão Eletrônico','valor','R$ 380.000','abertura','15/05/2025','status','Aberto')),
('obr_1','obras','Reforma UBS Central','Em andamento', JSON_OBJECT('id','obr_1','nome','Reforma UBS Central','secretaria','Saúde','valor','R$ 145.000','inicio','2025-01-15','previsao','2025-07-30','descricao','Reforma e adequação da unidade.','progresso',72,'status','Em andamento'))
ON DUPLICATE KEY UPDATE titulo = VALUES(titulo), status = VALUES(status), data_json = VALUES(data_json);
