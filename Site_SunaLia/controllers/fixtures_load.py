from flask import Blueprint, redirect
from connexion_db import get_db

fixtures_load = Blueprint('fixtures_load', __name__, template_folder='templates')


@fixtures_load.route('/base/init')
def fct_fixtures_load():
    db = get_db()
    cursor = db.cursor()

    # --- Supprimer les tables dans le bon ordre (inverse des dépendances) ---
    # D'abord les tables qui dépendent d'autres (avec FK), puis les tables indépendantes
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")  # Désactiver temporairement les contraintes

    tables = ['ligne_panier', 'ligne_commande', 'commande', 'etat', 'parfum', 'volume', 'genre', 'marque',
              'utilisateur']
    for t in tables:
        cursor.execute(f"DROP TABLE IF EXISTS {t};")

    cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")  # Réactiver les contraintes

    # --- Recréation des tables ---
    cursor.execute('''
    CREATE TABLE utilisateur(
       id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
       login VARCHAR(255),
       email VARCHAR(255),
       nom_utilisateur VARCHAR(255),
       password VARCHAR(255),
       role VARCHAR(255),
       est_actif TINYINT(1)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE volume(
       id_volume INT AUTO_INCREMENT PRIMARY KEY,
       nom_volume VARCHAR(255)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE genre(
       id_genre INT AUTO_INCREMENT PRIMARY KEY,
       nom_genre VARCHAR(255)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE marque(
       id_marque INT AUTO_INCREMENT PRIMARY KEY,
       nom_marque VARCHAR(255)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE parfum(
       id_parfum INT AUTO_INCREMENT PRIMARY KEY,
       nom_parfum VARCHAR(255),
       prix_parfum NUMERIC(6,2) DEFAULT 50.00,
       description TEXT,
       fournisseur VARCHAR(255),
       photo VARCHAR(255) DEFAULT 'no_photo.jpeg',
       stock INT DEFAULT 10,
       volume_id INT DEFAULT 1,
       genre_id INT DEFAULT 1,
       marque_id INT,
       FOREIGN KEY(volume_id) REFERENCES volume(id_volume),
       FOREIGN KEY(genre_id) REFERENCES genre(id_genre),
       FOREIGN KEY(marque_id) REFERENCES marque(id_marque)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE etat(
       id_etat INT AUTO_INCREMENT PRIMARY KEY,
       libelle VARCHAR(255)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE commande(
       id_commande INT AUTO_INCREMENT PRIMARY KEY,
       date_achat DATETIME,
       etat_id INT NOT NULL,
       utilisateur_id INT NOT NULL,
       FOREIGN KEY(etat_id) REFERENCES etat(id_etat),
       FOREIGN KEY(utilisateur_id) REFERENCES utilisateur(id_utilisateur)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE ligne_commande(
       commande_id INT,
       parfum_id INT,
       prix DECIMAL(10,2),
       quantite INT,
       PRIMARY KEY(commande_id, parfum_id),
       FOREIGN KEY(commande_id) REFERENCES commande(id_commande),
       FOREIGN KEY(parfum_id) REFERENCES parfum(id_parfum)
    ) DEFAULT CHARSET=utf8;
    ''')

    cursor.execute('''
    CREATE TABLE ligne_panier(
       utilisateur_id INT,
       parfum_id INT,
       date_ajout DATETIME,
       quantite INT,
       PRIMARY KEY(utilisateur_id, parfum_id, date_ajout),
       FOREIGN KEY(utilisateur_id) REFERENCES utilisateur(id_utilisateur),
       FOREIGN KEY(parfum_id) REFERENCES parfum(id_parfum)
    ) DEFAULT CHARSET=utf8;
    ''')

    # --- Insertions initiales (fixtures) ---
    # IMPORTANT: Ces hash doivent être identiques dans sae_sql_parfums.sql
    # admin/admin, client/client, client2/client2
    cursor.execute('''
    INSERT INTO utilisateur(login,email,password,role,nom_utilisateur,est_actif) VALUES
    ('admin','admin@admin.fr','pbkdf2:sha256:1000000$HPCg1rfTeJRSDofA$e27299f5f572d238498ad29538716e4c88c8d3cd41014931df1f7addb9cbe403','ROLE_admin','admin',1),
    ('client','client@client.fr','pbkdf2:sha256:1000000$AslM2zuUKE4HC8wt$82bbe00a8fd2e970b9a5b539e89f5faf0561071f6268d04df40f5ddadc9401b2','ROLE_client','client',1),
    ('client2','client2@client2.fr','pbkdf2:sha256:1000000$0Ml0yKn01o8TNkHR$86aef9564ad03b4e5a967e0177f6d1c7dc345a44a32d9aca8dda6b052d804bb5','ROLE_client','client2',1);
    ''')

    cursor.execute('''
    INSERT INTO volume(nom_volume) VALUES 
    ('30ml'), ('50ml'), ('75ml'), ('100ml'), ('150ml');
    ''')

    cursor.execute('''
    INSERT INTO genre(nom_genre) VALUES 
    ('Femme'), ('Homme'), ('Mixte');
    ''')

    cursor.execute('''
    INSERT INTO marque(nom_marque) VALUES 
    ('Chanel'), ('Dior'), ('Yves Saint Laurent'), ('Guerlain'), ('Lancôme'),
    ('Giorgio Armani'), ('Paco Rabanne'), ('Calvin Klein'), ('Hugo Boss'), ('Versace');
    ''')

    cursor.execute('''
    INSERT INTO etat(libelle) VALUES 
    ('en cours de traitement'), ('expédié'), ('validé'), ('en attente');
    ''')

    # Insertion de quelques parfums pour démarrer
    cursor.execute('''
    INSERT INTO parfum(nom_parfum, prix_parfum, description, fournisseur, photo, stock, volume_id, genre_id, marque_id) VALUES
    ('Coco Mademoiselle', 89.90, 'Un parfum oriental frais et moderne', 'Sephora', 'femme/coco_mademoiselle.png', 15, 2, 1, 1),
    ('J''adore', 95.00, 'Bouquet floral sensuel et féminin', 'Sephora', 'femme/jadore.png', 20, 2, 1, 2),
    ('La Vie Est Belle', 92.00, 'Parfum gourmand aux notes d''iris', 'Sephora', 'femme/la_vie_est_belle.png', 18, 2, 1, 5),
    ('Black Opium', 85.00, 'Parfum addictif au café et vanille', 'Sephora', 'femme/black_opium.png', 25, 2, 1, 3),
    ('Sauvage', 82.00, 'Frais, brut et noble', 'Sephora', 'homme/sauvage.png', 30, 4, 2, 2),
    ('Bleu de Chanel', 95.00, 'Boisé aromatique élégant', 'Sephora', 'homme/bleu_chanel.png', 18, 4, 2, 1),
    ('One Million', 79.00, 'Oriental épicé intense', 'Sephora', 'homme/one_million.png', 25, 4, 2, 7),
    ('Libre', 88.00, 'Floral lavande audacieux', 'Sephora', 'mixte/libre.png', 16, 2, 3, 3),
    ('CK Everyone', 52.00, 'Frais et clean pour tous', 'Sephora', 'mixte/ck_everyone.png', 24, 4, 3, 8),
    ('Baccarat Rouge 540', 250.00, 'Floral ambré lumineux', 'Sephora', 'mixte/baccarat_rouge.png', 4, 2, 3, 4),
    ('Miss Dior', 88.00, 'Bouquet floral pétillant', 'Sephora', 'femme/miss_dior.png', 12, 2, 1, 2),
    ('Mon Guerlain', 94.00, 'Parfum oriental frais à la lavande', 'Sephora', 'femme/mon_guerlain.png', 10, 2, 1, 4),
    ('Chanel N°5', 105.00, 'Le parfum iconique par excellence', 'Sephora', 'femme/chanel_5.png', 8, 4, 1, 1),
    ('Y', 75.00, 'Frais et boisé pour homme moderne', 'Sephora', 'homme/y_ysl.png', 20, 4, 2, 3),
    ('Acqua di Giò', 85.00, 'Aquatique frais et masculin', 'Sephora', 'homme/acqua_gio.png', 17, 4, 2, 6);
    ''')

    # Insertion des commandes
    cursor.execute('''
    INSERT INTO commande (date_achat, etat_id, utilisateur_id) VALUES
    ('2024-01-15 10:30:00', 2, 3),
    ('2024-01-16 14:20:00', 1, 3),
    ('2024-01-18 09:15:00', 2, 2),
    ('2024-01-20 16:45:00', 1, 2);
    ''')

    # Insertion des lignes de commande
    cursor.execute('''
    INSERT INTO ligne_commande(commande_id, parfum_id, prix, quantite) VALUES
    (1, 1, 89.90, 1),
    (1, 5, 82.00, 1),
    (2, 4, 85.00, 2),
    (3, 2, 95.00, 1),
    (4, 6, 95.00, 1);
    ''')

    # Insertion des lignes de panier (articles déjà dans le panier au démarrage)
    # PANIER BIEN REMPLI POUR EXEMPLE/DÉMONSTRATION
    cursor.execute('''
    INSERT INTO ligne_panier(utilisateur_id, parfum_id, date_ajout, quantite) VALUES
    -- Panier du client (id=2) - Panier mixte bien rempli
    (2, 1, '2024-01-27 09:00:00', 1),  -- Coco Mademoiselle
    (2, 3, '2024-01-27 10:00:00', 2),  -- La Vie Est Belle x2
    (2, 5, '2024-01-27 10:30:00', 1),  -- Sauvage
    (2, 7, '2024-01-27 11:15:00', 3),  -- One Million x3
    (2, 9, '2024-01-27 12:00:00', 1),  -- CK Everyone
    (2, 13, '2024-01-27 13:00:00', 1), -- Chanel N°5
    -- Panier du client2 (id=3) - Panier luxe
    (3, 2, '2024-01-27 14:00:00', 1),  -- J'adore
    (3, 6, '2024-01-27 14:15:00', 2),  -- Bleu de Chanel x2
    (3, 8, '2024-01-27 14:30:00', 1),  -- Libre
    (3, 10, '2024-01-27 14:45:00', 1), -- Baccarat Rouge 540
    (3, 11, '2024-01-27 15:00:00', 1), -- Miss Dior
    (3, 15, '2024-01-27 15:30:00', 2); -- Acqua di Giò x2
    ''')

    db.commit()
    return redirect('/')