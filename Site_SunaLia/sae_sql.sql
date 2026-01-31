DROP TABLE IF EXISTS ligne_panier;
DROP TABLE IF EXISTS ligne_commande;
DROP TABLE IF EXISTS parfum;
DROP TABLE IF EXISTS commande;
DROP TABLE IF EXISTS pyramide_olfactive;
DROP TABLE IF EXISTS type_parfum;
DROP TABLE IF EXISTS etat;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS volume;

CREATE TABLE volume (
    id_volume INT AUTO_INCREMENT PRIMARY KEY,
    nom_volume VARCHAR(255)
);

CREATE TABLE genre (
    id_genre INT AUTO_INCREMENT PRIMARY KEY,
    nom_genre VARCHAR(255)
);

CREATE TABLE utilisateur (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(255),
    email VARCHAR(255),
    nom VARCHAR(255),
    password VARCHAR(255),
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

CREATE TABLE parfum (
    id_parfum INT AUTO_INCREMENT PRIMARY KEY,
    nom_parfum VARCHAR(255),
    prix_parfum DECIMAL(6,2),
    description TEXT,
    fournisseur VARCHAR(255),
    marque VARCHAR(255),
    photo VARCHAR(255),
    stock INT,
    pyramide_olfactive_id INT,
    type_parfum_id INT,
    genre_id INT,
    volume_id INT,
    FOREIGN KEY (pyramide_olfactive_id) REFERENCES pyramide_olfactive(id_pyramide_olfactive),
    FOREIGN KEY (type_parfum_id) REFERENCES type_parfum(id_type_parfum),
    FOREIGN KEY (genre_id) REFERENCES genre(id_genre),
    FOREIGN KEY (volume_id) REFERENCES volume(id_volume)
);

CREATE TABLE commande (
    id_commande INT AUTO_INCREMENT PRIMARY KEY,
    date_achat DATETIME,
    etat_id INT,
    utilisateur_id INT,
    FOREIGN KEY (etat_id) REFERENCES etat(id_etat),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);

CREATE TABLE ligne_commande (
    commande_id INT,
    parfum_id INT,
    prix DECIMAL(6,2),
    quantite INT,
    PRIMARY KEY (parfum_id, commande_id),
    FOREIGN KEY (parfum_id) REFERENCES parfum(id_parfum),
    FOREIGN KEY (commande_id) REFERENCES commande(id_commande)
);

CREATE TABLE ligne_panier (
    parfum_id INT,
    utilisateur_id INT,
    quantite INT,
    date_ajout DATETIME,
    PRIMARY KEY (parfum_id, utilisateur_id),
    FOREIGN KEY (parfum_id) REFERENCES parfum(id_parfum),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);

-- Utilisateurs
-- IMPORTANT: Ces hash doivent être identiques dans fixtures_load.py
-- admin/admin, client/client, client2/client2
INSERT INTO utilisateur(id_utilisateur, login, email, password, role, nom, est_actif) VALUES
(1, 'admin', 'admin@admin.fr', 'pbkdf2:sha256:1000000$HPCg1rfTeJRSDofA$e27299f5f572d238498ad29538716e4c88c8d3cd41014931df1f7addb9cbe403', 'ROLE_admin', 'admin', 1),
(2, 'client', 'client@client.fr', 'pbkdf2:sha256:1000000$AslM2zuUKE4HC8wt$82bbe00a8fd2e970b9a5b539e89f5faf0561071f6268d04df40f5ddadc9401b2', 'ROLE_client', 'client', 1),
(3, 'client2', 'client2@client2.fr', 'pbkdf2:sha256:1000000$0Ml0yKn01o8TNkHR$86aef9564ad03b4e5a967e0177f6d1c7dc345a44a32d9aca8dda6b052d804bb5', 'ROLE_client', 'client2', 1);

-- Catalogues de référence
INSERT INTO volume(id_volume, nom_volume) VALUES
(1, '30ml'),
(2, '50ml'),
(3, '75ml'),
(4, '100ml'),
(5, '150ml');

INSERT INTO genre(id_genre, nom_genre) VALUES
(1, 'Femme'),
(2, 'Homme'),
(3, 'Mixte'),
(4,'Enfant');

-- Pyramide Olfactive
INSERT INTO pyramide_olfactive (id_pyramide_olfactive, note_de_tete, note_de_coeur, note_de_fond) VALUES
(1, 'Agrumes', 'Rose', 'Patchouli'),
(2, 'Bergamote', 'Fleurs blanches', 'Musc'),
(3, 'Poire', 'Iris', 'Vanille'),
(4, 'Poivre rose', 'Fleur d’oranger', 'Café'),
(5, 'Mandarine', 'Rose', 'Musc'),
(6, 'Lavande', 'Jasmin', 'Vanille'),
(7, 'Aldéhydes', 'Rose', 'Santal'),
(8, 'Amande', 'Tubéreuse', 'Cacao'),
(9, 'Thé', 'Freesia', 'Patchouli'),
(10, 'Bergamote', 'Rose', 'Musc'),

(11, 'Poivre', 'Lavande', 'Ambroxan'),
(12, 'Citron', 'Encens', 'Bois'),
(13, 'Gingembre', 'Sauge', 'Cèdre'),
(14, 'Menthe', 'Épices', 'Cuir'),
(15, 'Notes marines', 'Jasmin', 'Musc'),
(16, 'Pamplemousse', 'Cardamome', 'Tabac'),
(17, 'Citron', 'Violette', 'Vétiver'),
(18, 'Agrumes', 'Thé vert', 'Musc'),
(19, 'Gingembre', 'Maninka', 'Cuir'),
(20, 'Bergamote', 'Ambrox', 'Encens'),

(21, 'Violette', 'Bois', 'Cuir'),
(22, 'Lavande', 'Fleur d’oranger', 'Vanille'),
(23, 'Épices', 'Tabac', 'Vanille'),
(24, 'Agrumes', 'Fleurs', 'Bois'),
(25, 'Truffe', 'Orchidée', 'Patchouli'),
(26, 'Poivre', 'Oud', 'Ambre'),
(27, 'Mandarine', 'Fleur d’oranger', 'Vanille'),
(28, 'Poivre rose', 'Châtaigne', 'Vanille'),
(29, 'Safran', 'Ambre gris', 'Bois'),
(30, 'Citron', 'Géranium', 'Bois'),
(31, 'Fruits rouges', 'Bonbon', 'Vanille'),
(32, 'Agrumes', 'Sucre', 'Musc'),
(33, 'Fruits', 'Fleurs', 'Vanille');

-- Type parfum
INSERT INTO type_parfum (id_type_parfum, type_parfum_libelle) VALUES
(1, 'Floral'),
(2, 'Boisé'),
(3, 'Oriental'),
(4, 'Frais'),
(5, 'Gourmand'),
(6, 'Épicé'),
(7, 'Ambré'),
(8, 'Fruitée'),
(9, 'Aromatique');

-- Parfums
INSERT INTO parfum(nom_parfum, prix_parfum, description, fournisseur, marque, photo, stock, pyramide_olfactive_id, type_parfum_id, genre_id, volume_id) VALUES
-- Femme
('Coco Mademoiselle', 89.90, 'Une fragrance élégante et moderne, pensée pour une femme indépendante et affirmée.', 'Sephora', 'Chanel', 'femme/coco_mademoiselle.png', 15, 1, 7, 1, 2),
('J''adore', 95.00, 'Un parfum emblématique qui incarne la féminité, la sophistication et le luxe.', 'Sephora', 'Dior', 'femme/jadore.png', 20, 2, 1, 1, 2),
('La Vie Est Belle', 92.00, 'Une création lumineuse et raffinée, symbole de joie, de liberté et de bonheur.', 'parfum collection', 'Lancôme', 'femme/la_vie_est_belle.png', 18, 3, 5, 1, 2),
('Black Opium', 85.00, 'Un parfum audacieux et intense, destiné aux femmes sûres d’elles et charismatiques.', 'parfum collection', 'Yves Saint Laurent', 'femme/black_opium.png', 25, 4, 5, 1, 2),
('Miss Dior', 88.00, 'Une fragrance romantique et élégante, reflet d’une féminité moderne et délicate.', 'parfum collection', 'Dior', 'femme/miss_dior.png', 12, 5, 1, 1, 2),
('Mon Guerlain', 94.00, 'Une signature raffinée qui met en valeur une femme forte, libre et sensible.', 'Guerlain', 'Guerlain', 'femme/mon_guerlain.png', 10, 6, 7, 1, 2),
('Chanel N°5', 105.00, 'Un parfum mythique et intemporel, symbole absolu de l’élégance et du luxe.', 'Guerlain', 'Chanel', 'femme/chanel_5.png', 8, 7, 1, 1, 2),
('Good Girl', 98.00, 'Une fragrance contrastée et moderne, incarnant la dualité et la confiance.', 'Guerlain', 'Carolina Herrera', 'femme/good_girl.png', 14, 8, 5, 1, 2),
('Flowerbomb', 102.00, 'Un parfum intense et sophistiqué, conçu pour laisser une impression durable.', 'Parfum en gros', 'Viktor&Rolf', 'femme/flowerbomb.png', 16, 9, 1, 1, 2),
('Idôle', 79.00, 'Une fragrance contemporaine qui célèbre la détermination et l’ambition féminine.', 'Parfum en gros', 'Lancôme', 'femme/idole.png', 22, 10, 1, 1, 2),

-- Homme
('Sauvage', 82.00, 'Un parfum puissant et moderne, inspiré par la liberté et l’aventure.', 'Parfum grossiste', 'Dior', 'homme/sauvage.png', 30, 11, 4, 2, 2),
('Bleu de Chanel', 95.00, 'Une fragrance élégante et intemporelle, pensée pour un homme sûr de lui.', 'Parfum grossiste', 'Chanel', 'homme/bleu_chanel.png', 18, 12, 2, 2, 2),
('Y', 75.00, 'Un parfum dynamique et contemporain, symbole de réussite et de créativité.', 'Kcosmetique', 'Yves Saint Laurent', 'homme/y_ysl.png', 20, 13, 9, 2, 2),
('One Million', 79.00, 'Une fragrance audacieuse et affirmée, conçue pour un homme charismatique.', 'Kcosmetique', 'Paco Rabanne', 'homme/one_million.png', 25, 14, 3, 2, 2),
('Acqua di Giò', 85.00, 'Un parfum frais et élégant, évoquant la liberté et l’harmonie.', 'Kcosmetique', 'Giorgio Armani', 'homme/acqua_gio.png', 17, 15, 4, 2, 2),
('The One', 72.00, 'Une fragrance sophistiquée et élégante, parfaite pour un style raffiné.', 'Maison des fragrances', 'Dolce & Gabbana', 'homme/the_one.png', 13, 16, 3, 2, 2),
('L''Homme', 68.00, 'Un parfum moderne et distingué, incarnant l’élégance masculine.', 'Maison des fragrances', 'Yves Saint Laurent', 'homme/lhomme_ysl.png', 19, 17, 2, 2, 2),
('CK One', 45.00, 'Une fragrance iconique et universelle, pensée pour un usage quotidien.', 'Eleven parfum ', 'Calvin Klein', 'homme/ck_one.png', 28, 18, 4, 2, 2),
('The Scent', 70.00, 'Un parfum intense et séduisant, idéal pour une personnalité affirmée.', 'Eleven parfum ', 'Hugo Boss', 'homme/the_scent.png', 15, 19, 6, 2, 2),
('Dylan Blue', 77.00, 'Une fragrance moderne et élégante, inspirée par la force et le caractère.', 'Eleven parfum ', 'Versace', 'homme/dylan_blue.png', 12, 20, 9, 2, 2),

-- Mixte
('Santal 33', 195.00, 'Un parfum de caractère au style contemporain, apprécié pour son originalité.', 'Alibaba', 'Le Labo', 'mixte/santal_33.png', 8, 21, 2, 3, 2),
('Libre', 88.00, 'Une fragrance audacieuse et moderne, symbole de liberté et d’indépendance.', 'Robertet', 'Yves Saint Laurent', 'mixte/libre.png', 10, 22, 3, 3, 2),
('Tobacco Vanille', 215.00, 'Un parfum luxueux et intense, conçu pour une présence affirmée.', 'Robertet', 'Tom Ford', 'mixte/tobacco_vanille.png', 5, 23, 3, 3, 2),
('CK Everyone', 52.00, 'Une fragrance moderne et inclusive, pensée pour tous les styles.', 'Essence de parfum', 'Calvin Klein', 'mixte/ck_everyone.png', 24, 24, 4, 3, 2),
('Black Orchid', 125.00, 'Un parfum mystérieux et sophistiqué, au caractère profond et élégant.', 'Essence de parfum', 'Tom Ford', 'mixte/black_orchid.png', 9, 25, 7, 3, 2),
('Oud Wood', 205.00, 'Une fragrance raffinée et précieuse, symbole de luxe et d’élégance.', 'Perfume club', 'Tom Ford', 'mixte/oud_wood.png', 6, 26, 2, 3, 2),
('Code Absolu', 89.00, 'Un parfum intense et moderne, conçu pour une allure affirmée.', 'Perfume club', 'Giorgio Armani', 'mixte/code_absolu.png', 11, 27, 3, 3, 2),
('Stronger With You', 76.00, 'Une fragrance contemporaine et élégante, symbole de confiance et de lien.', 'News parfums', 'Giorgio Armani', 'mixte/stronger_with_you.png', 18, 28, 5, 3, 2),
('Baccarat Rouge 540', 250.00, 'Un parfum d’exception, reconnu pour son raffinement et son prestige.', 'News parfums', 'Maison Francis Kurkdjian', 'mixte/baccarat_rouge.png', 4, 29, 7, 3, 2),
('Eros Flame', 82.00, 'Une fragrance intense et passionnée, inspirée par la force et l’émotion.', 'Shein', 'Versace', 'mixte/eros_flame.png', 13, 30, 6, 3, 2),

-- Enfant
('Parfum Cars', 12.0, 'Fraîche et vrombissante', 'Action', 'Disney', 'enfant/cars.png', 120, 31, 8, 4, 2),
('Eau de toilette Naruto', 15.0, 'Fort et Rasengan', 'Action', 'Naruto', 'enfant/naruto.png', 3, 32, 9, 4, 2),
('Eau de toilette Peppa Pig', 14.0, 'Doux et pétillant', 'Jouet Club', 'Peppa Pig', 'enfant/peppa_pig.png', 3, 33, 8, 4, 2);

-- États des commandes
INSERT INTO etat(id_etat, libelle) VALUES
(1,'en cours de traitement'),
(2,'expédié'),
(3,'validé'),
(4,'en attente');

-- Commande
INSERT INTO commande (id_commande, date_achat, etat_id, utilisateur_id) VALUES
(1, '2024-01-15 10:30:00', 2, 3),
(2, '2024-01-16 14:20:00', 1, 3),
(3, '2024-01-18 09:15:00', 2, 2),
(4, '2024-01-20 16:45:00', 1, 2),
(5, '2024-01-22 11:30:00', 3, 2),
(6, '2024-01-24 13:00:00', 1, 2),
(7, '2024-01-25 15:30:00', 1, 3),
(8, '2024-01-26 10:00:00', 2, 3);

-- Lignes de commandes
INSERT INTO ligne_commande(commande_id, parfum_id, prix, quantite) VALUES
(1, 1, 89.90, 1),
(1, 11, 82.00, 1),
(2, 4, 85.00, 2),
(2, 21, 195.00, 1),
(3, 7, 105.00, 1),
(3, 14, 79.00, 1),
(4, 2, 95.00, 1),
(4, 12, 95.00, 1),
(5, 18, 45.00, 2),
(5, 24, 52.00, 1),
(6, 29, 250.00, 1),
(7, 5, 88.00, 1),
(7, 15, 85.00, 1),
(8, 9, 102.00, 1),
(8, 20, 77.00, 1);

-- Lignes de panier
INSERT INTO ligne_panier(utilisateur_id, parfum_id, date_ajout, quantite) VALUES
(2, 3, '2024-01-27 10:00:00', 1),
(2, 13, '2024-01-27 10:15:00', 2),
(3, 8, '2024-01-27 14:30:00', 1),
(3, 22, '2024-01-27 14:35:00', 1);