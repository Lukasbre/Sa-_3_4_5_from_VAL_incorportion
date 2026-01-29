DROP TABLE IF EXISTS ligne_panier;
DROP TABLE IF EXISTS ligne_commande;
DROP TABLE IF EXISTS commande;
DROP TABLE IF EXISTS etat;
DROP TABLE IF EXISTS parfum;
DROP TABLE IF EXISTS volume;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS marque;
DROP TABLE IF EXISTS utilisateur;


CREATE TABLE utilisateur(
   id_utilisateur INT AUTO_INCREMENT,
   login VARCHAR(255),
   email VARCHAR(255),
   nom_utilisateur VARCHAR(255),
   password VARCHAR(255),
   role VARCHAR(255),
   est_actif TINYINT(1),
   PRIMARY KEY(id_utilisateur)
);

CREATE TABLE volume (
   id_volume INT AUTO_INCREMENT PRIMARY KEY,
   nom_volume VARCHAR(255)
);

CREATE TABLE genre (
   id_genre INT AUTO_INCREMENT PRIMARY KEY,
   nom_genre VARCHAR(255)
);

CREATE TABLE marque (
   id_marque INT AUTO_INCREMENT PRIMARY KEY,
   nom_marque VARCHAR(255)
);

CREATE TABLE parfum (
   id_parfum INT AUTO_INCREMENT,
   nom_parfum VARCHAR(255),
   prix_parfum NUMERIC(6,2) DEFAULT 50.00,
   description TEXT,
   fournisseur VARCHAR(255),
   photo VARCHAR(255) DEFAULT 'no_photo.jpeg',
   stock INT DEFAULT 10,
   volume_id INT DEFAULT 1,
   genre_id INT DEFAULT 1,
   marque_id INT,
   PRIMARY KEY(id_parfum),
   FOREIGN KEY(volume_id) REFERENCES volume(id_volume),
   FOREIGN KEY(genre_id) REFERENCES genre(id_genre),
   FOREIGN KEY(marque_id) REFERENCES marque(id_marque)
);

CREATE TABLE etat (
  id_etat INT AUTO_INCREMENT,
  libelle VARCHAR(255),
  PRIMARY KEY (id_etat)
);

CREATE TABLE commande(
   id_commande INT AUTO_INCREMENT,
   date_achat DATETIME,
   etat_id INT NOT NULL,
   utilisateur_id INT NOT NULL,
   PRIMARY KEY(id_commande),
   FOREIGN KEY(etat_id) REFERENCES etat(id_etat),
   FOREIGN KEY(utilisateur_id) REFERENCES utilisateur(id_utilisateur)
);

CREATE TABLE ligne_commande (
  commande_id INT,
  parfum_id INT,
  prix DECIMAL(10,2),
  quantite INT,
  PRIMARY KEY (commande_id, parfum_id),
  FOREIGN KEY (commande_id) REFERENCES commande (id_commande),
  FOREIGN KEY (parfum_id) REFERENCES parfum (id_parfum)
);

CREATE TABLE ligne_panier (
  utilisateur_id INT,
  parfum_id INT,
  date_ajout DATETIME,
  quantite INT,
  PRIMARY KEY (utilisateur_id, parfum_id, date_ajout),
  FOREIGN KEY (utilisateur_id) REFERENCES utilisateur (id_utilisateur),
  FOREIGN KEY (parfum_id) REFERENCES parfum (id_parfum)
);


-- Utilisateurs
-- IMPORTANT: Ces hash doivent être identiques dans fixtures_load.py
-- admin/admin, client/client, client2/client2
INSERT INTO utilisateur(id_utilisateur, login, email, password, role, nom_utilisateur, est_actif) VALUES
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
(3, 'Mixte');

INSERT INTO marque(id_marque, nom_marque) VALUES
(1, 'Chanel'),
(2, 'Dior'),
(3, 'Yves Saint Laurent'),
(4, 'Guerlain'),
(5, 'Lancôme'),
(6, 'Giorgio Armani'),
(7, 'Paco Rabanne'),
(8, 'Calvin Klein'),
(9, 'Hugo Boss'),
(10, 'Versace');

-- Parfums (30 parfums variés avec des noms connus de Sephora)
-- Parfums Femme
INSERT INTO parfum(nom_parfum, prix_parfum, description, fournisseur, photo, stock, volume_id, genre_id, marque_id) VALUES
('Coco Mademoiselle', 89.90, 'Un parfum oriental frais et moderne', 'Sephora', 'coco_mademoiselle.png', 15, 2, 1, 1),
('J''adore', 95.00, 'Bouquet floral sensuel et féminin', 'Sephora', 'jadore.png', 20, 2, 1, 2),
('La Vie Est Belle', 92.00, 'Parfum gourmand aux notes d''iris', 'Sephora', 'la_vie_est_belle.png', 18, 2, 1, 5),
('Black Opium', 85.00, 'Parfum addictif au café et vanille', 'Sephora', 'black_opium.png', 25, 2, 1, 3),
('Miss Dior', 88.00, 'Bouquet floral pétillant', 'Sephora', 'miss_dior.png', 12, 2, 1, 2),
('Mon Guerlain', 94.00, 'Parfum oriental frais à la lavande', 'Sephora', 'mon_guerlain.png', 10, 2, 1, 4),
('Chanel N°5', 105.00, 'Le parfum iconique par excellence', 'Sephora', 'chanel_5.png', 8, 4, 1, 1),
('Good Girl', 98.00, 'Parfum floral oriental sensuel', 'Sephora', 'good_girl.png', 14, 3, 1, 2),
('Flowerbomb', 102.00, 'Explosion florale intense', 'Sephora', 'flowerbomb.png', 16, 2, 1, 7),
('Idôle', 79.00, 'Parfum floral clean et moderne', 'Sephora', 'idole.png', 22, 2, 1, 5),

-- Parfums Homme
('Sauvage', 82.00, 'Frais, brut et noble', 'Sephora', 'sauvage.png', 30, 4, 2, 2),
('Bleu de Chanel', 95.00, 'Boisé aromatique élégant', 'Sephora', 'bleu_chanel.png', 18, 4, 2, 1),
('Y', 75.00, 'Frais et boisé pour homme moderne', 'Sephora', 'y_ysl.png', 20, 4, 2, 3),
('One Million', 79.00, 'Oriental épicé intense', 'Sephora', 'one_million.png', 25, 4, 2, 7),
('Acqua di Giò', 85.00, 'Aquatique frais et masculin', 'Sephora', 'acqua_gio.png', 17, 4, 2, 6),
('The One', 72.00, 'Oriental épicé raffiné', 'Sephora', 'the_one.png', 13, 4, 2, 2),
('L''Homme', 68.00, 'Boisé aromatique sophistiqué', 'Sephora', 'lhomme_ysl.png', 19, 4, 2, 3),
('CK One', 45.00, 'Frais et épicé iconique', 'Sephora', 'ck_one.png', 28, 4, 2, 8),
('The Scent', 70.00, 'Cuir et boisé sensuel', 'Sephora', 'the_scent.png', 15, 2, 2, 9),
('Dylan Blue', 77.00, 'Fougère aromatique méditerranéen', 'Sephora', 'dylan_blue.png', 12, 4, 2, 10),

-- Parfums Mixte
('Santal 33', 195.00, 'Boisé épicé unisexe culte', 'Sephora', 'santal_33.png', 8, 2, 3, 1),
('Libre', 88.00, 'Floral lavande audacieux', 'Sephora', 'libre.png', 16, 2, 3, 3),
('Tobacco Vanille', 215.00, 'Oriental épicé luxueux', 'Sephora', 'tobacco_vanille.png', 5, 2, 3, 2),
('CK Everyone', 52.00, 'Frais et clean pour tous', 'Sephora', 'ck_everyone.png', 24, 4, 3, 8),
('Black Orchid', 125.00, 'Oriental floral mystérieux', 'Sephora', 'black_orchid.png', 9, 2, 3, 2),
('Oud Wood', 205.00, 'Boisé oriental raffiné', 'Sephora', 'oud_wood.png', 6, 2, 3, 2),
('Code Absolu', 89.00, 'Oriental boisé intense', 'Sephora', 'code_absolu.png', 11, 3, 3, 6),
('Stronger With You', 76.00, 'Oriental épicé gourmand', 'Sephora', 'stronger_with_you.png', 18, 4, 3, 6),
('Baccarat Rouge 540', 250.00, 'Floral ambré lumineux', 'Sephora', 'baccarat_rouge.png', 4, 2, 3, 4),
('Eros Flame', 82.00, 'Oriental épicé passionné', 'Sephora', 'eros_flame.png', 13, 4, 3, 10);

-- États des commandes
INSERT INTO etat(libelle) VALUES
('en cours de traitement'),
('expédié'),
('validé'),
('en attente');

-- Commandes
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