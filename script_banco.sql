-- ==========================================================
-- 1. CRIAÇÃO DAS TABELAS (DDL)
-- ==========================================================

CREATE TABLE membro (
    id_membro SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    idade INT NOT NULL CHECK (idade > 0),
    votos_eliminacao INT DEFAULT 0,
    aprovado BOOLEAN DEFAULT TRUE
);

-- Tabela para registrar quem votou em quem na eliminação
CREATE TABLE voto_membro (
    id_voto SERIAL PRIMARY KEY,
    id_eleitor INT NOT NULL REFERENCES membro(id_membro) ON DELETE CASCADE,
    id_votado INT NOT NULL REFERENCES membro(id_membro) ON DELETE CASCADE,
    UNIQUE (id_eleitor) -- Cada membro vota apenas uma vez
);

CREATE TABLE cargo (
    id_cargo SERIAL PRIMARY KEY,
    nome_cargo VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE membro_cargo (
    id_membro INT NOT NULL REFERENCES membro(id_membro) ON DELETE CASCADE,
    id_cargo INT NOT NULL REFERENCES cargo(id_cargo) ON DELETE CASCADE,
    PRIMARY KEY (id_membro, id_cargo)
);

CREATE TABLE recurso (
    id_recurso SERIAL PRIMARY KEY,
    nome_recurso VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    durabilidade_meses INT NOT NULL,
    votos INT DEFAULT 0,
    aprovado BOOLEAN DEFAULT TRUE,
    id_responsavel INT REFERENCES membro(id_membro) ON DELETE SET NULL
);

CREATE TABLE atividade (
    id_atividade SERIAL PRIMARY KEY,
    descricao VARCHAR(150) NOT NULL,
    status VARCHAR(30) DEFAULT 'Pendente',
    id_responsavel INT REFERENCES membro(id_membro) ON DELETE SET NULL
);

-- ==========================================================
-- 2. INSERÇÃO DOS DADOS ATUALIZADOS (DML)
-- ==========================================================

-- Membros (Marcus recebeu 3 votos de eliminação e fica com aprovado = FALSE)
INSERT INTO membro (nome, idade, votos_eliminacao, aprovado) VALUES
('José', 19, 0, TRUE),
('Winnicius', 19, 0, TRUE),
('Celso', 20, 1, TRUE),
('Marcus', 24, 3, FALSE);

-- Registro individual dos votos (José, Winnicius e Celso votaram no Marcus; Marcus votou no Celso)
INSERT INTO voto_membro (id_eleitor, id_votado) VALUES
(1, 4), -- José (1) votou em Marcus (4)
(2, 4), -- Winnicius (2) votou em Marcus (4)
(3, 4), -- Celso (3) votou em Marcus (4)
(4, 3); -- Marcus (4) votou em Celso (3)

INSERT INTO cargo (nome_cargo) VALUES
('Beta tester'),
('Líder de projeto'),
('Organizador'),
('Programador'),
('Analista de requisitos'),
('Analista de sistema'),
('Engenheiro de software'),
('Provedor de recursos'),
('Engenheiro de hardware');

INSERT INTO membro_cargo (id_membro, id_cargo) VALUES
(1, 1), (1, 2), (1, 3),
(2, 4), (2, 5),
(3, 6), (3, 7),
(4, 8), (4, 9);

INSERT INTO recurso (nome_recurso, categoria, durabilidade_meses, votos, aprovado, id_responsavel) VALUES
('Teclado', 'Periférico', 36, 4, TRUE, 4),
('CPU', 'Hardware', 60, 4, TRUE, 4),
('Monitor', 'Periférico', 60, 4, TRUE, 4),
('Mouse', 'Periférico', 24, 4, TRUE, 4),
('Placa-mãe', 'Hardware', 60, 4, TRUE, 4),
('Cronograma', 'Planejamento', 6, 4, TRUE, 1),
('Impressora', 'Periférico', 48, 1, FALSE, 4),
('Wi-Fi', 'Conectividade', 36, 4, TRUE, 4),
('Bluetooth', 'Conectividade', 36, 1, FALSE, 4),
('Pendrives', 'Armazenamento', 24, 1, FALSE, 4),
('Memória RAM', 'Hardware', 72, 4, TRUE, 4),
('SSD', 'Armazenamento', 60, 4, TRUE, 4),
('Placa de vídeo', 'Hardware', 60, 3, TRUE, 4),
('Orçamento', 'Planejamento', 6, 4, TRUE, 1),
('Processador', 'Hardware', 72, 4, TRUE, 4),
('HD', 'Armazenamento', 48, 1, FALSE, 4);

INSERT INTO atividade (descricao, id_responsavel) VALUES
('Reunião para discussão do sistema', 1),
('Implementação de login', 2),
('Implementação de autenticação', 2),
('Implementação de interface', 2),
('Implementação de ambiente virtual', 4),
('Implementação de banco de dados', 2),
('Implementação de recursos de segurança', 3),
('Implementação de recursos de acessibilidade', 3),
('Implementação de repositórios', 2),
('Implementação de assistente virtual', 2);

-- ==========================================================
-- 3. CONSULTAS E OPERAÇÕES PEDIDAS NA LOUSA
-- ==========================================================

-- Conferência da votação (quem votou em quem antes da remoção)
SELECT 
    e.nome AS eleitor,
    v.nome AS votado_para_sair
FROM voto_membro vm
JOIN membro e ON vm.id_eleitor = e.id_membro
JOIN membro v ON vm.id_votado = v.id_membro;

-- 1) Lista de materiais e seus responsáveis
SELECT 
    r.nome_recurso AS material,
    r.categoria,
    COALESCE(m.nome, 'Sem responsável (A reatribuir)') AS responsavel
FROM recurso r
LEFT JOIN membro m ON r.id_responsavel = m.id_membro
ORDER BY responsavel, r.nome_recurso;

-- 2) Lista de membros da equipe com suas funções
SELECT 
    m.nome AS membro,
    STRING_AGG(c.nome_cargo, ', ') AS funcoes
FROM membro m
JOIN membro_cargo mc ON m.id_membro = mc.id_membro
JOIN cargo c ON mc.id_cargo = c.id_cargo
GROUP BY m.id_membro, m.nome
ORDER BY m.nome;

-- 3) Remoção de materiais e membros que não foram escolhidos (por voto)
DELETE FROM recurso WHERE aprovado = FALSE;
DELETE FROM membro WHERE aprovado = FALSE;

-- 4) Lista de materiais que vão durar mais
SELECT 
    nome_recurso AS material,
    categoria,
    durabilidade_meses
FROM recurso
ORDER BY durabilidade_meses DESC, nome_recurso ASC;

-- 5) Lista de pessoas por idade
SELECT 
    nome AS membro,
    idade
FROM membro
ORDER BY idade ASC, nome ASC;
