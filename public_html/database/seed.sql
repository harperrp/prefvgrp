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
