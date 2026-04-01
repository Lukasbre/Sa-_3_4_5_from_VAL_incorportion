-- ============================================================
--  SUPPRESSION DES TABLES (ordre inverse des dépendances)
-- ============================================================
DROP TABLE IF EXISTS liste_envie;
DROP TABLE IF EXISTS historique;
DROP TABLE IF EXISTS commentaire;
DROP TABLE IF EXISTS note;
DROP TABLE IF EXISTS ligne_panier;
DROP TABLE IF EXISTS ligne_commande;
DROP TABLE IF EXISTS declinaison_parfum;
DROP TABLE IF EXISTS parfum;
DROP TABLE IF EXISTS commande;
DROP TABLE IF EXISTS adresse;
DROP TABLE IF EXISTS pyramide_olfactive;
DROP TABLE IF EXISTS type_parfum;
DROP TABLE IF EXISTS etat;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS volume;

-- ============================================================
--  TABLES DE RÉFÉRENCE
-- ============================================================
CREATE TABLE volume (
    id_volume   INT AUTO_INCREMENT PRIMARY KEY,
    nom_volume  VARCHAR(255)
);

CREATE TABLE genre (
    id_genre   INT AUTO_INCREMENT PRIMARY KEY,
    nom_genre  VARCHAR(255)
);

CREATE TABLE etat (
    id_etat   INT AUTO_INCREMENT PRIMARY KEY,
    libelle   VARCHAR(255)
);

CREATE TABLE type_parfum (
    id_type_parfum       INT AUTO_INCREMENT PRIMARY KEY,
    type_parfum_libelle  VARCHAR(255)
);

CREATE TABLE pyramide_olfactive (
    id_pyramide_olfactive  INT AUTO_INCREMENT PRIMARY KEY,
    note_de_tete           VARCHAR(255),
    note_de_coeur          VARCHAR(255),
    note_de_fond           VARCHAR(255)
);

-- ============================================================
--  UTILISATEUR
-- ============================================================
CREATE TABLE utilisateur (
    id_utilisateur  INT AUTO_INCREMENT PRIMARY KEY,
    login           VARCHAR(255),
    email           VARCHAR(255),
    nom             VARCHAR(255),
    password        VARCHAR(255),
    role            VARCHAR(255),
    est_actif       TINYINT
);

-- ============================================================
--  ADRESSE  (nouvelle table)
-- ============================================================
CREATE TABLE adresse (
    id_adresse        INT AUTO_INCREMENT PRIMARY KEY,
    nom               VARCHAR(255),
    rue               VARCHAR(255),
    code_postale      VARCHAR(255),
    ville             VARCHAR(255),
    date_utilisation  DATE,
    utilisateur_id    INT,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);

-- ============================================================
--  PARFUM  (genre et volume retirés → declinaison_parfum)
-- ============================================================
CREATE TABLE parfum (
    id_parfum              INT AUTO_INCREMENT PRIMARY KEY,
    nom_parfum             VARCHAR(255),
    prix_parfum            DECIMAL(6,2),
    description            TEXT,
    fournisseur            VARCHAR(255),
    marque                 VARCHAR(255),
    photo                  VARCHAR(255),
    stock                  INT,
    pyramide_olfactive_id  INT,
    type_parfum_id         INT,
    FOREIGN KEY (pyramide_olfactive_id) REFERENCES pyramide_olfactive(id_pyramide_olfactive),
    FOREIGN KEY (type_parfum_id)        REFERENCES type_parfum(id_type_parfum)
);

-- ============================================================
--  DECLINAISON_PARFUM  (reprend genre + volume de l'ancien parfum)
-- ============================================================
CREATE TABLE declinaison_parfum (
    id_declinaison_parfum  INT AUTO_INCREMENT PRIMARY KEY,
    stock                  INT,
    prix_declinaison       DECIMAL(19,4),
    image                  TEXT,
    volume_id              INT,
    genre_id               INT,
    parfum_id              INT,
    FOREIGN KEY (volume_id)  REFERENCES volume(id_volume),
    FOREIGN KEY (genre_id)   REFERENCES genre(id_genre),
    FOREIGN KEY (parfum_id)  REFERENCES parfum(id_parfum)
);

-- ============================================================
--  COMMANDE  (deux FK adresse : livraison + facturation)
-- ============================================================
CREATE TABLE commande (
    id_commande              INT AUTO_INCREMENT PRIMARY KEY,
    date_achat               DATE,
    adresse_livraison_id     INT,
    adresse_facturation_id   INT,
    utilisateur_id           INT,
    etat_id                  INT,
    FOREIGN KEY (adresse_livraison_id)   REFERENCES adresse(id_adresse),
    FOREIGN KEY (adresse_facturation_id) REFERENCES adresse(id_adresse),
    FOREIGN KEY (utilisateur_id)         REFERENCES utilisateur(id_utilisateur),
    FOREIGN KEY (etat_id)                REFERENCES etat(id_etat)
);

-- ============================================================
--  LIGNE_COMMANDE  (pointe vers declinaison_parfum)
-- ============================================================
CREATE TABLE ligne_commande (
    commande_id            INT,
    declinaison_parfum_id  INT,
    prix                   DECIMAL(6,2),
    quantite               INT,
    PRIMARY KEY (commande_id, declinaison_parfum_id),
    FOREIGN KEY (commande_id)           REFERENCES commande(id_commande),
    FOREIGN KEY (declinaison_parfum_id) REFERENCES declinaison_parfum(id_declinaison_parfum)
);

-- ============================================================
--  LIGNE_PANIER  (pointe vers declinaison_parfum)
-- ============================================================
CREATE TABLE ligne_panier (
    utilisateur_id         INT,
    declinaison_parfum_id  INT,
    quantite               INT,
    date_ajout             DATE,
    PRIMARY KEY (utilisateur_id, declinaison_parfum_id),
    FOREIGN KEY (utilisateur_id)        REFERENCES utilisateur(id_utilisateur),
    FOREIGN KEY (declinaison_parfum_id) REFERENCES declinaison_parfum(id_declinaison_parfum)
);

-- ============================================================
--  NOTE  (nouvelle table)
-- ============================================================
CREATE TABLE note (
    parfum_id      INT,
    utilisateur_id INT,
    note           INT,
    PRIMARY KEY (parfum_id, utilisateur_id),
    FOREIGN KEY (parfum_id)      REFERENCES parfum(id_parfum),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);

-- ============================================================
--  COMMENTAIRE  (nouvelle table)
-- ============================================================
CREATE TABLE commentaire (
    parfum_id        INT,
    utilisateur_id   INT,
    date_publication DATE,
    commentaire      TEXT,
    valider          BOOLEAN,
    PRIMARY KEY (parfum_id, utilisateur_id),
    FOREIGN KEY (parfum_id)      REFERENCES parfum(id_parfum),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);

-- ============================================================
--  HISTORIQUE  (nouvelle table)
-- ============================================================
CREATE TABLE historique (
    parfum_id         INT,
    utilisateur_id    INT,
    date_consultation DATE,
    PRIMARY KEY (parfum_id, utilisateur_id),
    FOREIGN KEY (parfum_id)      REFERENCES parfum(id_parfum),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);

-- ============================================================
--  LISTE_ENVIE  (nouvelle table)
-- ============================================================
CREATE TABLE liste_envie (
    parfum_id      INT,
    utilisateur_id INT,
    date_update    DATE,
    PRIMARY KEY (parfum_id, utilisateur_id),
    FOREIGN KEY (parfum_id)      REFERENCES parfum(id_parfum),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);


-- ============================================================
--  DONNÉES DE RÉFÉRENCE
-- ============================================================

INSERT INTO volume (id_volume, nom_volume) VALUES
(1, '30ml'), (2, '50ml'), (3, '75ml'), (4, '100ml'), (5, '150ml');

-- Genre : Enfant (id=4) présent dans cette version source
INSERT INTO genre (id_genre, nom_genre) VALUES
(1, 'Femme'), (2, 'Homme'), (3, 'Mixte'), (4, 'Enfant');

INSERT INTO etat (id_etat, libelle) VALUES
(1, 'en cours de traitement'),
(2, 'expédié'),
(3, 'validé'),
(4, 'en attente');

INSERT INTO type_parfum (id_type_parfum, type_parfum_libelle) VALUES
(1, 'Floral'), (2, 'Boisé'), (3, 'Oriental'), (4, 'Frais'),
(5, 'Gourmand'), (6, 'Épicé'), (7, 'Ambré'), (8, 'Fruitée'), (9, 'Aromatique');

INSERT INTO pyramide_olfactive (id_pyramide_olfactive, note_de_tete, note_de_coeur, note_de_fond) VALUES
(1,  'Agrumes',       'Rose',             'Patchouli'),
(2,  'Bergamote',     'Fleurs blanches',  'Musc'),
(3,  'Poire',         'Iris',             'Vanille'),
(4,  'Poivre rose',   'Fleur d''oranger', 'Café'),
(5,  'Mandarine',     'Rose',             'Musc'),
(6,  'Lavande',       'Jasmin',           'Vanille'),
(7,  'Aldéhydes',     'Rose',             'Santal'),
(8,  'Amande',        'Tubéreuse',        'Cacao'),
(9,  'Thé',           'Freesia',          'Patchouli'),
(10, 'Bergamote',     'Rose',             'Musc'),
(11, 'Poivre',        'Lavande',          'Ambroxan'),
(12, 'Citron',        'Encens',           'Bois'),
(13, 'Gingembre',     'Sauge',            'Cèdre'),
(14, 'Menthe',        'Épices',           'Cuir'),
(15, 'Notes marines', 'Jasmin',           'Musc'),
(16, 'Pamplemousse',  'Cardamome',        'Tabac'),
(17, 'Citron',        'Violette',         'Vétiver'),
(18, 'Agrumes',       'Thé vert',         'Musc'),
(19, 'Gingembre',     'Maninka',          'Cuir'),
(20, 'Bergamote',     'Ambrox',           'Encens'),
(21, 'Violette',      'Bois',             'Cuir'),
(22, 'Lavande',       'Fleur d''oranger', 'Vanille'),
(23, 'Épices',        'Tabac',            'Vanille'),
(24, 'Agrumes',       'Fleurs',           'Bois'),
(25, 'Truffe',        'Orchidée',         'Patchouli'),
(26, 'Poivre',        'Oud',              'Ambre'),
(27, 'Mandarine',     'Fleur d''oranger', 'Vanille'),
(28, 'Poivre rose',   'Châtaigne',        'Vanille'),
(29, 'Safran',        'Ambre gris',       'Bois'),
(30, 'Citron',        'Géranium',         'Bois'),
(31, 'Fruits rouges', 'Bonbon',           'Vanille'),
(32, 'Agrumes',       'Sucre',            'Musc'),
(33, 'Fruits',        'Fleurs',           'Vanille');

-- ============================================================
--  UTILISATEURS
-- ============================================================
-- admin/admin, client/client, client2/client2
INSERT INTO utilisateur (id_utilisateur, login, email, nom, password, role, est_actif) VALUES
(1, 'admin',   'admin@admin.fr',     'admin',   'pbkdf2:sha256:1000000$HPCg1rfTeJRSDofA$e27299f5f572d238498ad29538716e4c88c8d3cd41014931df1f7addb9cbe403', 'ROLE_admin',  1),
(2, 'client',  'client@client.fr',   'client',  'pbkdf2:sha256:1000000$AslM2zuUKE4HC8wt$82bbe00a8fd2e970b9a5b539e89f5faf0561071f6268d04df40f5ddadc9401b2', 'ROLE_client', 1),
(3, 'client2', 'client2@client2.fr', 'client2', 'pbkdf2:sha256:1000000$0Ml0yKn01o8TNkHR$86aef9564ad03b4e5a967e0177f6d1c7dc345a44a32d9aca8dda6b052d804bb5', 'ROLE_client', 1);

-- ============================================================
--  PARFUMS  (genre_id et volume_id retirés)
-- ============================================================
INSERT INTO parfum (nom_parfum, prix_parfum, description, fournisseur, marque, photo, stock, pyramide_olfactive_id, type_parfum_id) VALUES
-- Femme (ids 1-10)
('Coco Mademoiselle', 89.90,  'Une fragrance élégante et moderne, pensée pour une femme indépendante et affirmée.',   'Sephora',              'Chanel',                   'femme/coco_mademoiselle.png', 15,  1,  7),
('J''adore',          95.00,  'Un parfum emblématique qui incarne la féminité, la sophistication et le luxe.',        'Sephora',              'Dior',                     'femme/jadore.png',            20,  2,  1),
('La Vie Est Belle',  92.00,  'Une création lumineuse et raffinée, symbole de joie, de liberté et de bonheur.',       'parfum collection',    'Lancôme',                  'femme/la_vie_est_belle.png',  18,  3,  5),
('Black Opium',       85.00,  'Un parfum audacieux et intense, destiné aux femmes sûres d''elles et charismatiques.', 'parfum collection',    'Yves Saint Laurent',       'femme/black_opium.png',       25,  4,  5),
('Miss Dior',         88.00,  'Une fragrance romantique et élégante, reflet d''une féminité moderne et délicate.',    'parfum collection',    'Dior',                     'femme/miss_dior.png',         12,  5,  1),
('Mon Guerlain',      94.00,  'Une signature raffinée qui met en valeur une femme forte, libre et sensible.',         'Guerlain',             'Guerlain',                 'femme/mon_guerlain.png',      10,  6,  7),
('Chanel N°5',       105.00,  'Un parfum mythique et intemporel, symbole absolu de l''élégance et du luxe.',          'Guerlain',             'Chanel',                   'femme/chanel_5.png',           8,  7,  1),
('Good Girl',         98.00,  'Une fragrance contrastée et moderne, incarnant la dualité et la confiance.',           'Guerlain',             'Carolina Herrera',         'femme/good_girl.png',         14,  8,  5),
('Flowerbomb',       102.00,  'Un parfum intense et sophistiqué, conçu pour laisser une impression durable.',         'Parfum en gros',       'Viktor&Rolf',              'femme/flowerbomb.png',        16,  9,  1),
('Idôle',             79.00,  'Une fragrance contemporaine qui célèbre la détermination et l''ambition féminine.',    'Parfum en gros',       'Lancôme',                  'femme/idole.png',             22, 10,  1),
-- Homme (ids 11-20)
('Sauvage',           82.00,  'Un parfum puissant et moderne, inspiré par la liberté et l''aventure.',                'Parfum grossiste',     'Dior',                     'homme/sauvage.png',           30, 11,  4),
('Bleu de Chanel',    95.00,  'Une fragrance élégante et intemporelle, pensée pour un homme sûr de lui.',             'Parfum grossiste',     'Chanel',                   'homme/bleu_chanel.png',       18, 12,  2),
('Y',                 75.00,  'Un parfum dynamique et contemporain, symbole de réussite et de créativité.',           'Kcosmetique',          'Yves Saint Laurent',       'homme/y_ysl.png',             20, 13,  9),
('One Million',       79.00,  'Une fragrance audacieuse et affirmée, conçue pour un homme charismatique.',            'Kcosmetique',          'Paco Rabanne',             'homme/one_million.png',       25, 14,  3),
('Acqua di Giò',      85.00,  'Un parfum frais et élégant, évoquant la liberté et l''harmonie.',                      'Kcosmetique',          'Giorgio Armani',           'homme/acqua_gio.png',         17, 15,  4),
('The One',           72.00,  'Une fragrance sophistiquée et élégante, parfaite pour un style raffiné.',              'Maison des fragrances','Dolce & Gabbana',          'homme/the_one.png',           13, 16,  3),
('L''Homme',          68.00,  'Un parfum moderne et distingué, incarnant l''élégance masculine.',                     'Maison des fragrances','Yves Saint Laurent',       'homme/lhomme_ysl.png',        19, 17,  2),
('CK One',            45.00,  'Une fragrance iconique et universelle, pensée pour un usage quotidien.',               'Eleven parfum',        'Calvin Klein',             'homme/ck_one.png',            28, 18,  4),
('The Scent',         70.00,  'Un parfum intense et séduisant, idéal pour une personnalité affirmée.',                'Eleven parfum',        'Hugo Boss',                'homme/the_scent.png',         15, 19,  6),
('Dylan Blue',        77.00,  'Une fragrance moderne et élégante, inspirée par la force et le caractère.',            'Eleven parfum',        'Versace',                  'homme/dylan_blue.png',        12, 20,  9),
-- Mixte (ids 21-30)
('Santal 33',        195.00,  'Un parfum de caractère au style contemporain, apprécié pour son originalité.',         'Alibaba',              'Le Labo',                  'mixte/santal_33.png',          8, 21,  2),
('Libre',             88.00,  'Une fragrance audacieuse et moderne, symbole de liberté et d''indépendance.',          'Robertet',             'Yves Saint Laurent',       'mixte/libre.png',             10, 22,  3),
('Tobacco Vanille',  215.00,  'Un parfum luxueux et intense, conçu pour une présence affirmée.',                      'Robertet',             'Tom Ford',                 'mixte/tobacco_vanille.png',    5, 23,  3),
('CK Everyone',       52.00,  'Une fragrance moderne et inclusive, pensée pour tous les styles.',                     'Essence de parfum',    'Calvin Klein',             'mixte/ck_everyone.png',       24, 24,  4),
('Black Orchid',     125.00,  'Un parfum mystérieux et sophistiqué, au caractère profond et élégant.',               'Essence de parfum',    'Tom Ford',                 'mixte/black_orchid.png',       9, 25,  7),
('Oud Wood',         205.00,  'Une fragrance raffinée et précieuse, symbole de luxe et d''élégance.',                 'Perfume club',         'Tom Ford',                 'mixte/oud_wood.png',           6, 26,  2),
('Code Absolu',       89.00,  'Un parfum intense et moderne, conçu pour une allure affirmée.',                       'Perfume club',         'Giorgio Armani',           'mixte/code_absolu.png',       11, 27,  3),
('Stronger With You', 76.00,  'Une fragrance contemporaine et élégante, symbole de confiance et de lien.',            'News parfums',         'Giorgio Armani',           'mixte/stronger_with_you.png', 18, 28,  5),
('Baccarat Rouge 540',250.00, 'Un parfum d''exception, reconnu pour son raffinement et son prestige.',                'News parfums',         'Maison Francis Kurkdjian', 'mixte/baccarat_rouge.png',     4, 29,  7),
('Eros Flame',        82.00,  'Une fragrance intense et passionnée, inspirée par la force et l''émotion.',            'Shein',                'Versace',                  'mixte/eros_flame.png',        13, 30,  6),
-- Enfant (ids 31-33)
('Parfum Cars',               12.00, 'Fraîche et vrombissante', 'Action',    'Disney',    'enfant/cars.png',      120, 31, 8),
('Eau de toilette Naruto',    15.00, 'Fort et Rasengan',        'Action',    'Naruto',    'enfant/naruto.png',      3, 32, 9),
('Eau de toilette Peppa Pig', 14.00, 'Doux et pétillant',       'Jouet Club','Peppa Pig', 'enfant/peppa_pig.png',   3, 33, 8);

-- ============================================================
--  DÉCLINAISONS  (une par parfum, volume 50ml)
--  id_declinaison_parfum = id_parfum pour cohérence des données
-- ============================================================
INSERT INTO declinaison_parfum (id_declinaison_parfum, stock, prix_declinaison, image, volume_id, genre_id, parfum_id) VALUES
-- Femme (genre_id = 1)
(1,  15,   89.90, 'femme/coco_mademoiselle.png', 2, 1,  1),
(2,  20,   95.00, 'femme/jadore.png',            2, 1,  2),
(3,  18,   92.00, 'femme/la_vie_est_belle.png',  2, 1,  3),
(4,  25,   85.00, 'femme/black_opium.png',       2, 1,  4),
(5,  12,   88.00, 'femme/miss_dior.png',         2, 1,  5),
(6,  10,   94.00, 'femme/mon_guerlain.png',      2, 1,  6),
(7,   8,  105.00, 'femme/chanel_5.png',          2, 1,  7),
(8,  14,   98.00, 'femme/good_girl.png',         2, 1,  8),
(9,  16,  102.00, 'femme/flowerbomb.png',        2, 1,  9),
(10, 22,   79.00, 'femme/idole.png',             2, 1, 10),
-- Homme (genre_id = 2)
(11, 30,   82.00, 'homme/sauvage.png',           2, 2, 11),
(12, 18,   95.00, 'homme/bleu_chanel.png',       2, 2, 12),
(13, 20,   75.00, 'homme/y_ysl.png',             2, 2, 13),
(14, 25,   79.00, 'homme/one_million.png',       2, 2, 14),
(15, 17,   85.00, 'homme/acqua_gio.png',         2, 2, 15),
(16, 13,   72.00, 'homme/the_one.png',           2, 2, 16),
(17, 19,   68.00, 'homme/lhomme_ysl.png',        2, 2, 17),
(18, 28,   45.00, 'homme/ck_one.png',            2, 2, 18),
(19, 15,   70.00, 'homme/the_scent.png',         2, 2, 19),
(20, 12,   77.00, 'homme/dylan_blue.png',        2, 2, 20),
-- Mixte (genre_id = 3)
(21,  8,  195.00, 'mixte/santal_33.png',         2, 3, 21),
(22, 10,   88.00, 'mixte/libre.png',             2, 3, 22),
(23,  5,  215.00, 'mixte/tobacco_vanille.png',   2, 3, 23),
(24, 24,   52.00, 'mixte/ck_everyone.png',       2, 3, 24),
(25,  9,  125.00, 'mixte/black_orchid.png',      2, 3, 25),
(26,  6,  205.00, 'mixte/oud_wood.png',          2, 3, 26),
(27, 11,   89.00, 'mixte/code_absolu.png',       2, 3, 27),
(28, 18,   76.00, 'mixte/stronger_with_you.png', 2, 3, 28),
(29,  4,  250.00, 'mixte/baccarat_rouge.png',    2, 3, 29),
(30, 13,   82.00, 'mixte/eros_flame.png',        2, 3, 30),
-- Enfant (genre_id = 4)
(31, 120,  12.00, 'enfant/cars.png',             2, 4, 31),
(32,   3,  15.00, 'enfant/naruto.png',           2, 4, 32),
(33,   3,  14.00, 'enfant/peppa_pig.png',        2, 4, 33);

-- ============================================================
--  COMMANDES
--  adresse_livraison_id et adresse_facturation_id laissés NULL :
--  aucune adresse n'existait dans le script source.
-- ============================================================
INSERT INTO commande (id_commande, date_achat, adresse_livraison_id, adresse_facturation_id, utilisateur_id, etat_id) VALUES
(1, '2024-01-15', NULL, NULL, 3, 2),
(2, '2024-01-16', NULL, NULL, 3, 1),
(3, '2024-01-18', NULL, NULL, 2, 2),
(4, '2024-01-20', NULL, NULL, 2, 1),
(5, '2024-01-22', NULL, NULL, 2, 3),
(6, '2024-01-24', NULL, NULL, 2, 1),
(7, '2024-01-25', NULL, NULL, 3, 1),
(8, '2024-01-26', NULL, NULL, 3, 2);

-- ============================================================
--  LIGNES DE COMMANDE  (parfum_id → declinaison_parfum_id)
-- ============================================================
INSERT INTO ligne_commande (commande_id, declinaison_parfum_id, prix, quantite) VALUES
(1,  1,  89.90, 1),
(1, 11,  82.00, 1),
(2,  4,  85.00, 2),
(2, 21, 195.00, 1),
(3,  7, 105.00, 1),
(3, 14,  79.00, 1),
(4,  2,  95.00, 1),
(4, 12,  95.00, 1),
(5, 18,  45.00, 2),
(5, 24,  52.00, 1),
(6, 29, 250.00, 1),
(7,  5,  88.00, 1),
(7, 15,  85.00, 1),
(8,  9, 102.00, 1),
(8, 20,  77.00, 1);

-- ============================================================
--  LIGNES DE PANIER  (parfum_id → declinaison_parfum_id)
-- ============================================================
INSERT INTO ligne_panier (utilisateur_id, declinaison_parfum_id, quantite, date_ajout) VALUES
(2,  3, 1, '2024-01-27'),
(2, 13, 2, '2024-01-27'),
(3,  8, 1, '2024-01-27'),
(3, 22, 1, '2024-01-27');