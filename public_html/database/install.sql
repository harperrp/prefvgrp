SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS poll_votes, polls, content_versions, audit_logs, redirects, external_integrations, settings, manifestation_messages, manifestations, gallery_images, galleries, secretariats, services, faqs, works, documents, contracts, bids, laws, news, files, users;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('super_admin','editor','operator','viewer') NOT NULL DEFAULT 'editor',
  permissions_json JSON NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_users_active (is_active, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  original_name VARCHAR(255) NOT NULL,
  stored_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(120) NOT NULL,
  size INT NOT NULL,
  path VARCHAR(255) NOT NULL,
  public_url VARCHAR(500) NOT NULL,
  uploaded_by INT NULL,
  created_at DATETIME NOT NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_files_user FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_files_path (path)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE news (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  slug VARCHAR(240) NOT NULL UNIQUE,
  summary TEXT NULL,
  content LONGTEXT NULL,
  category VARCHAR(90) NULL,
  status ENUM('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  featured_image_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_news_image FOREIGN KEY (featured_image_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_news_public (status, published_at, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE laws (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(90) NOT NULL,
  number VARCHAR(60) NOT NULL,
  year INT NOT NULL,
  description TEXT NOT NULL,
  status ENUM('draft','published','archived','revoked') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_laws_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_laws_public (status, year, number, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bids (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  modality VARCHAR(90) NOT NULL,
  number VARCHAR(80) NOT NULL,
  opening_date DATE NULL,
  amount DECIMAL(14,2) NULL,
  status ENUM('draft','published','open','judgment','homologated','closed','archived') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_bids_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_bids_public (status, opening_date, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE contracts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  bid_id INT NULL,
  title VARCHAR(220) NOT NULL,
  number VARCHAR(80) NOT NULL,
  supplier VARCHAR(190) NULL,
  amount DECIMAL(14,2) NULL,
  signed_at DATE NULL,
  status ENUM('draft','published','active','finished','archived') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_contract_bid FOREIGN KEY (bid_id) REFERENCES bids(id) ON DELETE SET NULL,
  CONSTRAINT fk_contract_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_contract_status (status, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE documents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  category VARCHAR(90) NOT NULL,
  description TEXT NULL,
  status ENUM('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_docs_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_documents_public (status, category, published_at, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE works (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  description TEXT NULL,
  location VARCHAR(220) NULL,
  budget DECIMAL(14,2) NULL,
  progress TINYINT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('draft','published','planned','in_progress','paused','completed','archived') NOT NULL DEFAULT 'draft',
  image_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_works_image FOREIGN KEY (image_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_works_public (status, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE faqs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question VARCHAR(255) NOT NULL,
  answer TEXT NOT NULL,
  category VARCHAR(90) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_published TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_faq_public (is_published, sort_order, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(160) NOT NULL,
  description TEXT NULL,
  external_url VARCHAR(500) NULL,
  icon VARCHAR(20) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_services_active (is_active, sort_order, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE secretariats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  responsible VARCHAR(160) NULL,
  phone VARCHAR(60) NULL,
  email VARCHAR(190) NULL,
  address VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_secretariats_active (is_active, name, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE galleries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  description TEXT NULL,
  status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
  cover_file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_gallery_cover FOREIGN KEY (cover_file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_galleries_public (status, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE gallery_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  gallery_id INT NOT NULL,
  file_id INT NOT NULL,
  caption VARCHAR(255) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_gallery_images_gallery FOREIGN KEY (gallery_id) REFERENCES galleries(id) ON DELETE CASCADE,
  CONSTRAINT fk_gallery_images_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
  INDEX idx_gallery_images (gallery_id, sort_order, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE manifestations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  protocol VARCHAR(40) NOT NULL UNIQUE,
  type ENUM('SIC','Denuncia','Reclamacao','Sugestao','Elogio') NOT NULL DEFAULT 'SIC',
  subject VARCHAR(220) NOT NULL,
  description TEXT NOT NULL,
  citizen_name VARCHAR(160) NULL,
  citizen_email VARCHAR(190) NULL,
  citizen_phone VARCHAR(60) NULL,
  status ENUM('open','in_analysis','answered','closed') NOT NULL DEFAULT 'open',
  priority ENUM('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  assigned_to INT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  due_at DATETIME NULL,
  closed_at DATETIME NULL,
  CONSTRAINT fk_manifest_assigned FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_manifest_status (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE manifestation_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  manifestation_id INT NOT NULL,
  user_id INT NULL,
  message TEXT NOT NULL,
  is_public TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_msg_manifest FOREIGN KEY (manifestation_id) REFERENCES manifestations(id) ON DELETE CASCADE,
  CONSTRAINT fk_msg_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_msg_manifest (manifestation_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(120) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  is_public TINYINT(1) NOT NULL DEFAULT 1,
  updated_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE external_integrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  slug VARCHAR(120) NOT NULL UNIQUE,
  url VARCHAR(500) NULL,
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE redirects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  label VARCHAR(160) NOT NULL,
  slug VARCHAR(120) NOT NULL UNIQUE,
  url VARCHAR(500) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id INT NULL,
  before_json JSON NULL,
  after_json JSON NULL,
  ip VARCHAR(60) NULL,
  user_agent VARCHAR(255) NULL,
  created_at DATETIME NOT NULL,
  INDEX idx_audit_entity (entity_type, entity_id),
  INDEX idx_audit_date (created_at),
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE content_versions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  entity_type VARCHAR(80) NOT NULL,
  entity_id INT NOT NULL,
  data_json JSON NOT NULL,
  user_id INT NULL,
  created_at DATETIME NOT NULL,
  INDEX idx_versions_entity (entity_type, entity_id),
  CONSTRAINT fk_versions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE polls (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question VARCHAR(255) NOT NULL,
  options_json JSON NOT NULL,
  status ENUM('draft','published','closed','archived') NOT NULL DEFAULT 'draft',
  starts_at DATETIME NULL,
  ends_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_polls_public (status, starts_at, ends_at, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE poll_votes (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  poll_id INT NOT NULL,
  option_index INT NOT NULL,
  ip_hash VARCHAR(128) NOT NULL,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_poll_votes_poll FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE,
  UNIQUE KEY uq_poll_vote (poll_id, ip_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
SET NAMES utf8mb4;
INSERT INTO users(name,email,password_hash,role,permissions_json,is_active,created_at) VALUES
('Administrador','admin@radgov.com.br','$2y$12$2abPwQTHD41v78Q0vwSxTeGsHFyHsFFEGxN6s7I3Gce4uPmChoQXy','super_admin',JSON_OBJECT('all', true),1,NOW());

INSERT INTO settings(setting_key,setting_value,is_public,updated_at) VALUES
('municipality_name','Prefeitura de Vargem Grande do Rio Pardo',1,NOW()),
('cnpj','19.851.397/0001-39',1,NOW()),
('address','Praça Municipal, Centro, Vargem Grande do Rio Pardo - MG',1,NOW()),
('phone','(00) 0000-0000',1,NOW()),
('email','contato@radgov.com.br',1,NOW()),
('business_hours','Segunda a sexta, 08h às 17h',1,NOW()),
('facebook','',1,NOW()),
('instagram','',1,NOW()),
('transparency_url','https://portaldatransparencia.gov.br',1,NOW()),
('esic_url','',1,NOW()),
('nfse_url','',1,NOW()),
('official_gazette_url','',1,NOW());

INSERT INTO external_integrations(name,slug,url,description,is_active,created_at) VALUES
('Portal da Transparência Federal','portal-transparencia','https://portaldatransparencia.gov.br','Consulta externa de receitas, despesas e pessoal.',1,NOW()),
('e-SIC','esic','','Sistema eletrônico do Serviço de Informação ao Cidadão.',0,NOW()),
('NFS-e','nfse','','Sistema de emissão e consulta de notas fiscais.',0,NOW()),
('Diário Oficial','diario-oficial','','Publicações oficiais do município.',0,NOW());

INSERT INTO redirects(label,slug,url,is_active,created_at) VALUES
('Portal da Transparência','portal-transparencia','https://portaldatransparencia.gov.br',1,NOW()),
('e-SIC','esic','#ouvidoria',1,NOW()),
('Diário Oficial','diario-oficial','#documentos',1,NOW());

INSERT INTO news(title,slug,summary,content,category,status,published_at,created_at) VALUES
('Portal municipal passa a operar com conteúdo dinâmico','portal-municipal-conteudo-dinamico','Portal integrado ao banco de dados para publicação de notícias, documentos, leis, obras e serviços.','A Prefeitura disponibiliza um portal público conectado ao painel administrativo, com publicação controlada por status e registro de auditoria.','Transparência','published',NOW(),NOW()),
('Canal de Ouvidoria e SIC disponível','canal-ouvidoria-sic-disponivel','Cidadãos podem registrar solicitações e acompanhar pelo número de protocolo.','O sistema gera protocolo automaticamente e permite resposta pelo painel administrativo.','Ouvidoria','published',NOW(),NOW());

INSERT INTO laws(type,number,year,description,status,published_at,created_at) VALUES
('Lei Ordinária','001',2025,'Dispõe sobre a organização administrativa inicial cadastrada no portal.', 'published', NOW(), NOW()),
('Decreto','010',2025,'Regulamenta procedimentos de publicação eletrônica no portal municipal.', 'published', NOW(), NOW());

INSERT INTO bids(title,modality,number,opening_date,amount,status,published_at,created_at) VALUES
('Contratação de serviços de tecnologia para manutenção do portal','Pregão Eletrônico','010/2025','2025-05-02',148000.00,'published',NOW(),NOW()),
('Aquisição de materiais de expediente','Dispensa','004/2025','2025-04-15',32500.00,'published',NOW(),NOW());

INSERT INTO documents(title,category,description,status,published_at,created_at) VALUES
('Relatório de Gestão Fiscal - 1º Quadrimestre 2025','RGF','Documento inicial migrado para o banco de dados.','published',NOW(),NOW()),
('Plano de Contratações Anual 2025','PCA','Planejamento anual de contratações públicas.','published',NOW(),NOW());

INSERT INTO works(title,description,location,budget,progress,status,published_at,created_at) VALUES
('Pavimentação no bairro Centro','Obra de pavimentação e sinalização viária.','Bairro Centro',520000.00,38,'published',NOW(),NOW()),
('Reforma da UBS Central','Reforma estrutural e adequação de ambientes de atendimento.','UBS Central',310000.00,72,'published',NOW(),NOW()),
('Ampliação do CMEI Jardim das Flores','Ampliação de salas e área de convivência.','Jardim das Flores',275000.00,100,'published',NOW(),NOW());

INSERT INTO faqs(question,answer,category,sort_order,is_published,created_at) VALUES
('Como solicitar informações ao município via SIC?','Use o formulário de Ouvidoria/SIC no portal. O sistema gera um protocolo para acompanhamento.','SIC',1,1,NOW()),
('Onde encontro licitações e contratos?','Acesse a seção Licitações no portal público. Apenas processos publicados aparecem para consulta.','Licitações',2,1,NOW()),
('Como reportar um problema urbano?','Registre uma manifestação na Ouvidoria, selecionando o tipo adequado e descrevendo o problema.','Ouvidoria',3,1,NOW());

INSERT INTO services(title,description,external_url,icon,is_active,sort_order,created_at) VALUES
('Licitações e Contratos','Editais, atas, homologações e contratos publicados.','#licitacoes','📄',1,1,NOW()),
('Legislação Municipal','Leis, decretos, portarias e resoluções.','#legislacao','⚖️',1,2,NOW()),
('Ouvidoria / SIC','Solicitações de informação, denúncias, reclamações e sugestões.','#ouvidoria','🎧',1,3,NOW()),
('Obras Públicas','Acompanhamento de obras, progresso e orçamento.','#obras','🏗️',1,4,NOW());

INSERT INTO secretariats(name,responsible,phone,email,address,is_active,created_at) VALUES
('Secretaria Municipal de Administração','A definir','(00) 0000-0000','administracao@radgov.com.br','Sede da Prefeitura',1,NOW()),
('Secretaria Municipal de Saúde','A definir','(00) 0000-0000','saude@radgov.com.br','Unidade Central',1,NOW()),
('Secretaria Municipal de Educação','A definir','(00) 0000-0000','educacao@radgov.com.br','Sede da Educação',1,NOW()),
('Secretaria Municipal de Obras','A definir','(00) 0000-0000','obras@radgov.com.br','Pátio Municipal',1,NOW());

INSERT INTO galleries(title,description,status,published_at,created_at) VALUES
('Galeria institucional','Imagens institucionais cadastradas no portal.', 'published', NOW(), NOW());

INSERT INTO polls(question,options_json,status,starts_at,ends_at,created_at) VALUES
('Qual área deve receber prioridade nos próximos serviços?', JSON_ARRAY('Saúde','Educação','Obras'), 'published', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), NOW());
