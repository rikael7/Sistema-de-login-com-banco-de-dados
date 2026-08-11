-- =========================================================
-- Schema do banco de dados — Sistema de Login com Banco de Dados
-- Baseado nas queries usadas em authController.js
--
-- Como rodar:
--   psql -U seu_usuario -d seu_banco -f schema.sql
-- Ou cole o conteúdo direto no editor SQL do DBeaver.
-- =========================================================

-- ---------------------------------------------------------
-- Extensão usada para gerar UUID, caso queira usar no futuro
-- (não obrigatória para este schema, mas comum em projetos Node/PG)
-- ---------------------------------------------------------
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------
-- Tabela: users
-- Usada por findUserByEmail, finduserbyname, findUserById,
-- createUser, obterPerfil e updateUserProfile
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(150) NOT NULL,
    email          VARCHAR(150) UNIQUE NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    bio            TEXT,
    phone          VARCHAR(30),
    avatar_url     TEXT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_name ON users (name);

-- Mantém updated_at sempre atualizado automaticamente em qualquer UPDATE,
-- mesmo que o controller esqueça de setar (updateUserProfile já seta manualmente,
-- mas o trigger cobre qualquer outro UPDATE futuro na tabela).
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------
-- Tabela: videos
-- Usada por uploadVideo (upload feito pelo admin)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS videos (
    id             SERIAL PRIMARY KEY,
    titulo         VARCHAR(150) NOT NULL,
    descricao      TEXT,
    nome_arquivo   VARCHAR(255) NOT NULL,
    tipo_arquivo   VARCHAR(100),
    tamanho        INTEGER,
    usuario_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    criado_em      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_videos_usuario_id ON videos (usuario_id);

-- ---------------------------------------------------------
-- Tabela: session
-- Necessária se você usa express-session + connect-pg-simple
-- para persistir sessões no PostgreSQL em vez de memória.
-- Se createTableIfMissing estiver ativo no connect-pg-simple,
-- ele cria isso sozinho — deixado aqui só como referência/backup.
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS session (
    sid     VARCHAR NOT NULL COLLATE "default",
    sess    JSON NOT NULL,
    expire  TIMESTAMP(6) NOT NULL
)
WITH (OIDS = FALSE);

ALTER TABLE session DROP CONSTRAINT IF EXISTS session_pkey;
ALTER TABLE session
    ADD CONSTRAINT session_pkey
    PRIMARY KEY (sid)
    NOT DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS idx_session_expire ON session (expire);