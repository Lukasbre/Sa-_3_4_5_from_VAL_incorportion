DROP TABLE IF EXISTS liste_envie;
DROP TABLE IF EXISTS historique;
DROP TABLE IF EXISTS commentaire;
DROP TABLE IF EXISTS note;
DROP TABLE IF EXISTS ligne_panier;
DROP TABLE IF EXISTS ligne_commande;
DROP TABLE IF EXISTS declinaison_parfum;
DROP TABLE IF EXISTS commande;
DROP TABLE IF EXISTS parfum;
DROP TABLE IF EXISTS adresse;
DROP TABLE IF EXISTS pyramide_olfactive;
DROP TABLE IF EXISTS type_parfum;
DROP TABLE IF EXISTS etat;
DROP TABLE IF EXISTS utilsateur;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS volume;

-- ========================
-- TABLES SIMPLES
-- ========================

CREATE TABLE volume (
    id_volume_ INT AUTO_INCREMENT PRIMARY KEY,
    nom_volume VARCHAR(255)
);

CREATE TABLE genre (
    id_genre INT AUTO_INCREMENT PRIMARY KEY,
    nom_genre VARCHAR(255)
);

CREATE TABLE utilsateur (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    nom VARCHAR(255),
    role VARCHAR(255),
    est_actif TINYINT
);

CREATE TABLE etat (
    id_etat INT AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(255)
);

CREATE TABLE type_parfum (
    id_type_parfum INT AUTO_INCREMENT PRIMARY KEY,
    type_parfum_libelle VARCHAR(255)
);

CREATE TABLE pyramide_olfactive (
    id_pyramide_olfactive INT AUTO_INCREMENT PRIMARY KEY,
    note_de_tete VARCHAR(255),
    note_de_coeur VARCHAR(255),
    note_de_fond VARCHAR(255)
);

-- ========================
-- ADRESSE
-- ========================

CREATE TABLE adresse (
    id_adresse INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255),
    rue_ VARCHAR(255),
    code_postale VARCHAR(255),
    ville VARCHAR(255),
    date_utilisation DATE,
    id_utilisateur INT NOT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES utilsateur(id_utilisateur)
);

-- ========================
-- PARFUM
-- ========================

CREATE TABLE parfum (
    id_parfum INT AUTO_INCREMENT PRIMARY KEY,
    nom_parfum VARCHAR(255),
    prix_parfum DECIMAL(6,2),
    Description TEXT,
    Fournisseur VARCHAR(255),
    Marque VARCHAR(255),
    Photo VARCHAR(255),
    Stock INT,
    id_pyramide_olfactive INT NOT NULL,
    id_type_parfum INT NOT NULL,
    FOREIGN KEY (id_pyramide_olfactive) REFERENCES pyramide_olfactive(id_pyramide_olfactive),
    FOREIGN KEY (id_type_parfum) REFERENCES type_parfum(id_type_parfum)
);

-- ========================
-- COMMANDE
-- ========================

CREATE TABLE commande (
    id_commande INT AUTO_INCREMENT PRIMARY KEY,
    date_achat DATE,
    id_adresse INT NOT NULL,
    id_adresse_1 INT NOT NULL,
    id_utilisateur INT NOT NULL,
    id_etat INT NOT NULL,
    FOREIGN KEY (id_adresse) REFERENCES adresse(id_adresse),
    FOREIGN KEY (id_adresse_1) REFERENCES adresse(id_adresse),
    FOREIGN KEY (id_utilisateur) REFERENCES utilsateur(id_utilisateur),
    FOREIGN KEY (id_etat) REFERENCES etat(id_etat)
);

-- ========================
-- DECLINAISON PARFUM
-- ========================

CREATE TABLE declinaison_parfum (
    id_declinaison_parfum INT AUTO_INCREMENT PRIMARY KEY,
    stock INT,
    prix_declinaison DECIMAL(19,4),
    image TEXT,
    id_volume_ INT NOT NULL,
    id_genre INT NOT NULL,
    id_parfum INT NOT NULL,
    FOREIGN KEY (id_volume_) REFERENCES volume(id_volume_),
    FOREIGN KEY (id_genre) REFERENCES genre(id_genre),
    FOREIGN KEY (id_parfum) REFERENCES parfum(id_parfum)
);

-- ========================
-- LIGNE COMMANDE
-- ========================

CREATE TABLE ligne_commande (
    id_commande INT,
    id_declinaison_parfum INT,
    prix DECIMAL(6,2),
    quantite INT,
    PRIMARY KEY (id_commande, id_declinaison_parfum),
    FOREIGN KEY (id_commande) REFERENCES commande(id_commande),
    FOREIGN KEY (id_declinaison_parfum) REFERENCES declinaison_parfum(id_declinaison_parfum)
);

-- ========================
-- LIGNE PANIER
-- ========================

CREATE TABLE ligne_panier (
    id_utilisateur INT,
    id_declinaison_parfum INT,
    quantite INT,
    date_ajout DATE,
    PRIMARY KEY (id_utilisateur, id_declinaison_parfum),
    FOREIGN KEY (id_utilisateur) REFERENCES utilsateur(id_utilisateur),
    FOREIGN KEY (id_declinaison_parfum) REFERENCES declinaison_parfum(id_declinaison_parfum)
);

-- ========================
-- NOTE
-- ========================

CREATE TABLE note (
    id_parfum INT,
    id_utilisateur INT,
    note INT,
    PRIMARY KEY (id_parfum, id_utilisateur),
    FOREIGN KEY (id_parfum) REFERENCES parfum(id_parfum),
    FOREIGN KEY (id_utilisateur) REFERENCES utilsateur(id_utilisateur)
);

-- ========================
-- COMMENTAIRE
-- ========================

CREATE TABLE commentaire (
    id_parfum INT,
    id_utilisateur INT,
    date_publication DATE,
    commentaire TEXT,
    valider BOOLEAN,
    PRIMARY KEY (id_parfum, id_utilisateur, date_publication),
    FOREIGN KEY (id_parfum) REFERENCES parfum(id_parfum),
    FOREIGN KEY (id_utilisateur) REFERENCES utilsateur(id_utilisateur)
);

-- ========================
-- HISTORIQUE
-- ========================

CREATE TABLE historique (
    id_parfum INT,
    id_utilisateur INT,
    date_consultation DATE,
    PRIMARY KEY (id_parfum, id_utilisateur, date_consultation),
    FOREIGN KEY (id_parfum) REFERENCES parfum(id_parfum),
    FOREIGN KEY (id_utilisateur) REFERENCES utilsateur(id_utilisateur)
);

-- ========================
-- LISTE ENVIE
-- ========================

CREATE TABLE liste_envie (
    id_parfum INT,
    id_utilisateur INT,
    date_update DATE,
    PRIMARY KEY (id_parfum, id_utilisateur, date_update),
    FOREIGN KEY (id_parfum) REFERENCES parfum(id_parfum),
    FOREIGN KEY (id_utilisateur) REFERENCES utilsateur(id_utilisateur)
);